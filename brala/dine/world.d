module brala.dine.world;

private {
    import glamour.gl;
    import glamour.vbo : Buffer;
    import glamour.vao : VAO;
    import glamour.shader : Shader;
    
    import gl3n.linalg;
    import gl3n.aabb : AABB;

    import std.typecons : Tuple;
    import core.time : dur;

    import brala.dine.chunk : Chunk, Block;
    import brala.dine.builder.biomes : BiomeSet;
    import brala.dine.builder.tessellator : Tessellator, Vertex;
    import brala.dine.util : py_div, py_mod;
    import brala.exception : WorldError;
    import brala.resmgr : ResourceManager;
    import brala.engine : BraLaEngine;
    import brala.utils.queue : Queue, Empty;
    import brala.utils.thread : Thread, VerboseThread, Event, thread_isMainThread;
    import brala.utils.memory : MemoryCounter, malloc, realloc, free;

    debug import std.stdio : stderr;
}

private enum Block AIR_BLOCK = Block(0);

struct TessellationBuffer {
    void* ptr = null;
    alias ptr this; 
    size_t length = 0;

    private Event _event;
    @property event() {
        if(_event is null) {
            _event = new Event();
            available = true;
        }

        return _event;
    }

    @property bool available() {
        return !event.is_set();
    }

    @property void available(bool yn) {
        if(yn) {
            event.set();
        } else {
            event.clear();
        }
    }

    void wait_available() {
        event.wait();
    }

    this(size_t size) {
        ptr = cast(void*)malloc(size);
        length = size;
    }

    void realloc(size_t size) {
        ptr = cast(void*).realloc(ptr, size);
        length = size;
    }
    
    void free() {
        .free(ptr);
        ptr = null;
        length = 0;
    }
}

alias Tuple!(Chunk, "chunk", TessellationBuffer*, "buffer", size_t, "elements") TessOut;
alias Tuple!(Chunk, "chunk", vec3i, "position") ChunkData;

class World {
    static const default_tessellation_bufer_size = width*height*depth*100;
    
    const int width = 16;
    const int height = 256;
    const int depth = 16;
    const int ystep = width*depth;
    const int min_height = 0;
    const int max_height = height;    

    Chunk[vec3i] chunks;
    vec3i spawn;

    MemoryCounter vram = MemoryCounter("vram");

    BiomeSet biome_set;

    protected Queue!ChunkData input;
    protected Queue!TessOut output;
    protected TessellationThread[] tessellation_threads;
    
    this(ResourceManager resmgr, size_t threads) {
        biome_set.update_colors(resmgr);

        threads = threads ? threads : 1;

        input = new Queue!ChunkData();
        output = new Queue!TessOut(threads);

        version(NoThreads) {
            threads = 1;
        }
        
        foreach(i; 0..threads) {
            auto t = new TessellationThread(this, input, output);
            t.name = "BraLa Tessellation Thread %s/%s".format(i+1, threads);
            version(NoThreads) {} else { t.start(); }
            tessellation_threads ~= t;
        }
    }
    
    this(ResourceManager resmgr, vec3i spawn, size_t threads) {
        this.spawn = spawn;
        this(resmgr, threads);
    }
    
    ~this() {
        remove_all_chunks();

        foreach(t; tessellation_threads) {
            clear(t);
        }
    }
   
    // when a chunk is passed to this method, the world will take care of it's memory
    // you should also lose all other references to this chunk
    //
    // old chunk will be cleared
    void add_chunk(Chunk chunk, vec3i chunkc, bool mark_dirty=true) {
        if(Chunk* c = chunkc in chunks) {
            c.empty_chunk();
        } 
        
        chunks[chunkc] = chunk;
        if(mark_dirty) {
            mark_surrounding_chunks_dirty(chunkc);
        }
    }

    /// only safe when called from mainthread
    void remove_chunk(vec3i chunkc, bool mark_dirty=true)
        in { assert(chunkc in chunks); }
        body {
            Chunk chunk = chunks[chunkc];
            chunk.empty_chunk();

            if(chunk.vbo !is null && chunk.vbo.buffer != 0) {
                vram.remove(chunk.vbo.length);
                chunk.vbo.remove();
            }

            if(chunk.vao !is null) {
                chunk.vao.remove();
            }
            
            chunks.remove(chunkc);

            if(mark_dirty) {
                mark_surrounding_chunks_dirty(chunkc);
            }
        }
    
    void remove_all_chunks() {
        foreach(key; chunks.keys()) {
            remove_chunk(key);
        }
    }

    void shutdown() {
        debug stderr.writefln("Sending stop to all tessellation threads");
        foreach(t; tessellation_threads) {
            t.stop();
        }

        // threads wait on the buffer until it gets available,
        // so tell them the buffer is free, so they actually reach
        // the stop code, otherwise we'll wait for ever!
        debug stderr.writefln("Marking all buffers as available");
        foreach(tess_out; output) {
            tess_out.buffer.available = true;
        }

        foreach(t; tessellation_threads) {
            if(t.isRunning) {
                debug stderr.writefln(`Waiting on thread: "%s"`, t.name);
                t.join(false);
            } else {
                debug stderr.writefln(`Thread "%s" already terminated`, t.name);
            }
        }

        debug stderr.writefln("Removing all chunks");
        remove_all_chunks();
    }
    
    Chunk get_chunk(int x, int y, int z) {
        return get_chunk(vec3i(x, y, z));
    }
    
    Chunk get_chunk(vec3i chunkc) {
        if(Chunk* c = chunkc in chunks) {
            return *c;
        }
        return null;
    }
    
    void set_block(vec3i position, Block block)
        in { assert(position.y >= min_height && position.y <= max_height); }
        body {
            vec3i chunkc = vec3i(py_div(position.x, width),
                                 py_div(position.y, height),
                                 py_div(position.z, depth));
            Chunk chunk = get_chunk(chunkc);
            
            if(chunk is null) {
                throw new WorldError("No chunk available for position " ~ position.toString());
            }
            
            uint flat = chunk.to_flat(py_mod(position.x, width),
                                      py_mod(position.y, height),
                                      py_mod(position.z, depth));
            
            if(chunk[flat] != block) {
                chunk[flat] = block;
                mark_surrounding_chunks_dirty(chunkc);
            }
        }
    
    Block get_block(vec3i position)
        in { assert(position.y >= min_height && position.y <= max_height); }
        body {
            Chunk chunk = get_chunk(py_div(position.x, width),
                                    py_div(position.y, height),
                                    py_div(position.z, depth));
            
            if(chunk is null) {
                throw new WorldError("No chunk available for position " ~ position.toString());
            }
            
            return chunk[chunk.to_flat(py_mod(position.x, width),
                                       py_mod(position.y, height),
                                       py_mod(position.z, depth))];
        }

    Block get_block_safe(vec3i position, Block def = AIR_BLOCK) {
        Chunk chunk = get_chunk(py_div(position.x, width),
                                py_div(position.y, height),
                                py_div(position.z, depth));

        if(chunk is null) { return def; }

        int x = py_mod(position.x, width);
        int y = py_mod(position.y, height);
        int z = py_mod(position.z, depth);
        
        if(x >= 0 && x < chunk.width && y >= 0 && y < chunk.height && z >= 0 && z < chunk.depth) {
            return chunk[chunk.to_flat(x, y, z)];
        } else {
            return def;
        }
    }
    
    void mark_surrounding_chunks_dirty(int x, int y, int z) {
        return mark_surrounding_chunks_dirty(vec3i(x, y, z));
    }
    
    void mark_surrounding_chunks_dirty(vec3i chunkc) {
        mark_chunk_dirty(chunkc.x+1, chunkc.y, chunkc.z);
        mark_chunk_dirty(chunkc.x-1, chunkc.y, chunkc.z);
        mark_chunk_dirty(chunkc.x, chunkc.y+1, chunkc.z);
        mark_chunk_dirty(chunkc.x, chunkc.y-1, chunkc.z);
        mark_chunk_dirty(chunkc.x, chunkc.y, chunkc.z+1);
        mark_chunk_dirty(chunkc.x, chunkc.y, chunkc.z-1);
    }
    
    void mark_chunk_dirty(int x, int y, int z) {
        return mark_chunk_dirty(vec3i(x, y, z));
    }
    
    void mark_chunk_dirty(vec3i chunkc) {
        if(Chunk* c = chunkc in chunks) {
            c.dirty = true;
        }
    }
       
    // rendering

    // fills the vbo with the chunk content
    // original version from florian boesch - http://codeflow.org/
    size_t tessellate(Chunk chunk, vec3i chunkc, TessellationBuffer* tb) {
        Tessellator tessellator = Tessellator(this, tb);

        int index;
        int y;
        int hds = height / 16;

        float z_offset, z_offset_n;
        float y_offset, y_offset_t;
        float x_offset, x_offset_r;

        Block value;
        Block right_block;
        Block front_block;
        Block top_block;

        vec3i wcoords_orig = vec3i(chunkc.x*chunk.width, chunkc.y*chunk.height, chunkc.z*chunk.depth);
        vec3i wcoords = wcoords_orig;


        foreach(b; 0..hds) {
            if((chunk.primary_bitmask >> b) & 1 ^ 1) continue;
            foreach(y_; 0..hds) {
                y = b*hds + y_;

                y_offset = wcoords_orig.y + y + 0.5f;
                y_offset_t = y_offset + 1.0f;

                wcoords.y = wcoords_orig.y + y;
                wcoords.z = wcoords_orig.z;

                tessellator.realloc_buffer_if_needed(256*(hds-y));

                foreach(z; 0..depth) {
                    z_offset = wcoords_orig.z + z + 0.5f;
                    z_offset_n = z_offset + 1.0f;

                    wcoords.x = wcoords_orig.x;
                    wcoords.z = wcoords_orig.z + z;

                    value = get_block_safe(wcoords);

                    foreach(x; 0..width) {
                        x_offset = wcoords_orig.x + x + 0.5f;
                        x_offset_r = x_offset + 1.0f;
                        wcoords.x = wcoords_orig.x + x;

                        index = x+z*depth+y*ystep;

                        if(x == width-1) {
                            right_block = get_block_safe(vec3i(wcoords.x+1, wcoords.y,   wcoords.z),   AIR_BLOCK);
                        } else {
                            right_block = chunk.blocks[index+1];
                        }

                        if(z == depth-1) {
                            front_block = get_block_safe(vec3i(wcoords.x,  wcoords.y,   wcoords.z+1), AIR_BLOCK);
                        } else {
                            front_block = chunk.blocks[index+width];
                        }

                        if(y == height-1) {
                            top_block = AIR_BLOCK;
                        } else {
                            top_block = chunk.blocks[index+ystep];
                        }

                        tessellator.feed(wcoords, x, y, z,
                                        x_offset, x_offset_r, y_offset, y_offset_t, z_offset, z_offset_n,
                                        value, right_block, top_block, front_block,
                                        biome_set.biomes[chunk.biome_data[chunk.get_biome_safe(x+z*15)]]);

                        value = right_block;
                    }
                }
            }
        }

        chunk.vbo_vcount = tessellator.elements / Vertex.sizeof;

        debug assert(cast(size_t)tb.ptr % 4 == 0); assert(tessellator.elements*40 % 4 == 0);

        return tessellator.elements;
    }

    void bind(Shader shader, Chunk chunk)
        in { assert(chunk.vbo !is null, "chunk vbos is null");
             assert(shader !is null, "no current shader"); }
        body {
            GLuint position = shader.get_attrib_location("position");
            GLuint normal = shader.get_attrib_location("normal");
            GLuint color = shader.get_attrib_location("color");
            GLuint texcoord = shader.get_attrib_location("texcoord");
            GLuint mask = shader.get_attrib_location("mask");
            GLuint light = shader.get_attrib_location("light");
            
            enum stride = Vertex.sizeof;
            chunk.vbo.bind(position, GL_FLOAT, 3, 0, stride);
//             chunk.vbo.bind(normal, GL_FLOAT, 3, 12, stride);
            chunk.vbo.bind(color, GL_UNSIGNED_BYTE, 4, 12, stride, true); // normalize it
            chunk.vbo.bind(texcoord, GL_SHORT, 2, 16, stride);
            chunk.vbo.bind(mask, GL_SHORT, 2, 20, stride);
            chunk.vbo.bind(light, GL_UNSIGNED_BYTE, 2, 22, stride);
        }
    
    void draw(BraLaEngine engine) {       
        foreach(tess_out; output) {
            with(tess_out) {                
                if(chunk.vbo is null) {
                    chunk.vao = new VAO();
                    chunk.vbo = new Buffer();
                }

                chunk.vao.bind();
                chunk.vbo.bind();

                debug size_t prev = chunk.vbo.length;

                chunk.vbo.set_data(buffer.ptr, elements);
                bind(engine.current_shader, chunk);

                chunk.vao.unbind();

                chunk.tessellated = true;

                debug {
                    if(prev == 0 && chunk.vbo.length) {
                        vram.add(chunk.vbo.length);
                    } else {
                        vram.adjust(chunk.vbo.length - prev);
                    }
                }
                
                buffer.available = true;
            }
        }

        version(NoThreads) {
            if(!input.empty) {
                tessellation_threads[0].poll();
            }
        }

        auto frustum = engine.frustum;
        engine.flush_uniforms();
        
        foreach(chunkc, chunk; chunks) {
            if(chunk.dirty) {
                chunk.dirty = false;
                chunk.tessellated = false;
                // this queue is never full and we don't wanna waste time waiting
                input.put(ChunkData(chunk, chunkc), false);
            }

            if(chunk.vbo !is null && chunk.vao !is null) {
                vec3i w_chunkc = vec3i(chunkc.x*width, chunkc.y*height, chunkc.z*depth);

                AABB aabb = AABB(vec3(w_chunkc), vec3(w_chunkc.x+width, w_chunkc.y+height, w_chunkc.z+depth));
                if(aabb in frustum) {
                    chunk.vao.bind();
                    glDrawArrays(GL_TRIANGLES, 0, cast(uint)chunk.vbo_vcount);
                }
            }
        }
    }
}


class TessellationThread : VerboseThread {
    protected TessellationBuffer buffer;
    protected World world;
    protected Queue!ChunkData input;
    protected Queue!TessOut output;

    protected Event stop_event;

    this(World world, Queue!ChunkData input, Queue!TessOut output) {
        super(&run);

        this.world = world;
        this.buffer = TessellationBuffer(world.default_tessellation_bufer_size);
        this.input = input;
        this.output = output;

        this.stop_event = new Event();
    }

    ~this() {
        buffer.free();
    }
    
    void run() {
        while(!stop_event.is_set) {
            poll();
        }
    }

    void stop() {
        debug stderr.writefln(`Setting stop for: "%s"`, this.name);
        stop_event.set();
    }
            
    void poll() {
        // waits only if the buffer is not available
        buffer.wait_available();

        ChunkData chunk_data;
        try {
            // continue loop every 300ms to check if we should continue or exit
            chunk_data = input.get(true, dur!"msecs"(300));
        } catch(Empty) {
            return;
        }

        with(chunk_data) {
            if(chunk.tessellated) {
                debug stderr.writefln("Chunk is already tessellated! %s", position);

                input.task_done();
                return;
            } else {
                buffer.available = false;
            }

            size_t elements = world.tessellate(chunk, position, &buffer);

            output.put(TessOut(chunk, &buffer, elements));
        }

        input.task_done();
    }
}
