module brala.dine.world;

private {
    import glamour.gl;
    import glamour.vbo : Buffer;
    import glamour.vao : VAO;
    import glamour.shader : Shader;
    
    import gl3n.linalg;
    import gl3n.aabb : AABB;

    import std.typecons : Tuple;
    import core.time : TickDuration, dur;

    import brala.log : logger = world_logger;
    import brala.utils.log;
    import brala.dine.chunk : Chunk, Block;
    import brala.dine.builder.biomes : BiomeSet;
    import brala.dine.builder.tessellator : Tessellator;
    import brala.dine.util : py_div, py_mod;
    import brala.gfx.data : Vertex;
    import brala.gfx.terrain : MinecraftAtlas;
    import brala.exception : WorldError;
    import brala.resmgr : ResourceManager;
    import brala.engine : BraLaEngine;
    import brala.utils.aa : ThreadAA;
    import brala.utils.gloom : Gloom;
    import brala.utils.pqueue : PseudoQueue, Empty;
    alias Queue = PseudoQueue;
//     import brala.utils.queue : Queue, Empty;
    import brala.utils.thread : Thread, VerboseThread, Event, thread_isMainThread;
    import brala.utils.memory : MemoryCounter, malloc, realloc, free;
}

private enum Block AIR_BLOCK = Block(0);

struct Pointer {
    void* ptr = null;
    alias ptr this;
    size_t length = 0;

    this(size_t size) {
        ptr = cast(void*)malloc(size);
        length = size;
    }

    void realloc(size_t size) {
        ptr = cast(void*).realloc(ptr, size);
        length = size;
    }

    void realloc_interval(ptrdiff_t interval) {
        realloc(length + interval);
    }

    void realloc_interval_if_needed(size_t stored, ptrdiff_t interval) {
        if(stored+interval >= length) {
            realloc_interval(interval);
        }
    }

    void free() {
        .free(ptr);
        ptr = null;
        length = 0;
    }
}

struct TessellationBuffer {
    Pointer terrain;
    Pointer light;

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

    this(size_t size, size_t light_size) {
        terrain = Pointer(size);
        light = Pointer(light_size);
    }

    void free() {
        terrain.free();
        light.free();
    }
}

alias Tuple!(Chunk, "chunk", TessellationBuffer*, "buffer", size_t, "elements") TessOut;
alias Tuple!(Chunk, "chunk", vec3i, "position") ChunkData;

final class World {
    // approximations / educated guesses
    static const default_tessellation_buffer_size = width*height*depth*Vertex.sizeof*6;
    static const default_light_buffer_size = 12*4*500;
    
    const int width = 16;
    const int height = 256;
    const int depth = 16;
    const int ystep = width*depth;
    const int min_height = 0;
    const int max_height = height;    

    //ThreadAA!(Chunk, vec3i) chunks;
    Chunk[vec3i] chunks;
    vec3i spawn;

    protected BraLaEngine engine;
    BiomeSet biome_set;
    MinecraftAtlas atlas;

    // NOTE: don't join on these queues!
    protected Queue!ChunkData input;
    protected Queue!TessOut output;
    protected TessOut[] output_buffer;
    protected TessellationThread[] tessellation_threads;
    
    this(BraLaEngine engine, MinecraftAtlas atlas, size_t threads) {
        this.engine = engine;
        this.atlas = atlas;
        biome_set.update_colors(engine.resmgr);

        assert(engine.resmgr.get!Gloom("sphere").stride == 3, "invalid sphere");

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
    
    this(BraLaEngine engine, MinecraftAtlas atlas, vec3i spawn, size_t threads) {
        this(engine, atlas, threads);
        this.spawn = spawn;
    }
    
    ~this() {
        remove_all_chunks();
    }

    @property
    bool is_ok() {
        foreach(thread; tessellation_threads) {
            if(!thread.isRunning) {
                return false;
            }
        }

        return true;
    }
   
    // when a chunk is passed to this method, the world will take care of it's memory
    // you should also lose all other references to this chunk
    //
    // old chunk will be cleared
    void add_chunk(Chunk chunk, vec3i chunkc, bool mark_dirty=true) {
        if(Chunk* c = chunkc in chunks) {
            c.empty_chunk();
        } 

        vec3i w_chunkc = vec3i(chunkc.x*width, chunkc.y*height, chunkc.z*depth);
        AABB aabb = AABB(vec3(w_chunkc), vec3(w_chunkc.x+width, w_chunkc.y+height, w_chunkc.z+depth));
        chunk.aabb = aabb;
        
        chunks[chunkc] = chunk;
        if(mark_dirty) {
            mark_surrounding_chunks_dirty(chunkc);
        }
    }

    /// only safe when called from mainthread
    void remove_chunk(vec3i chunkc, bool mark_dirty=true)
        in { assert(chunkc in chunks, "Chunkc not in chunks: %s".format(chunkc)); }
        body {
            Chunk chunk = chunks[chunkc];
            chunk.empty_chunk();

            if(chunk.vbo !is null) {
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
            remove_chunk(key, false);
        }
    }

    void shutdown() {
        logger.log!Info("Sending stop to all tessellation threads");
        foreach(t; tessellation_threads) {
            t.stop();
        }

        // threads wait on the buffer until it gets available,
        // so tell them the buffer is free, so they actually reach
        // the stop code, otherwise we'll wait for ever!        
        logger.log!Info("Marking all buffers as available");
        foreach(tess_out; output.get_all(output_buffer, true)) {
            tess_out.buffer.available = true;
        }

        foreach(ref t; tessellation_threads) {
            if(t.isRunning) {
                logger.log!Info(`Waiting on thread: "%s"`, t.name);
                t.join(false);
            } else {
                logger.log!Info(`Thread "%s" already terminated`, t.name);
            }

            destroy(t);
        }

        logger.log!Info("Removing all chunks");
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
        in { assert(position.y >= min_height && position.y <= max_height, "Invalid height"); }
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
        in { assert(position.y >= min_height && position.y <= max_height, "Invalid height"); }
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
        return get_block_safe(position.x, position.y, position.z, def);
    }

    Block get_block_safe(int wx, int wy, int wz, Block def = AIR_BLOCK) {
        Chunk chunk = get_chunk(py_div(wx, width),
                                py_div(wy, height),
                                py_div(wz, depth));

        if(chunk is null/+ || chunk.empty+/) { return def; }

        int x = py_mod(wx, width);
        int y = py_mod(wy, height);
        int z = py_mod(wz, depth);
        
        if(x >= 0 && x < Chunk.width && y >= 0 && y < Chunk.height && z >= 0 && z < Chunk.depth) {
            return chunk.blocks[chunk.to_flat(x, y, z)];
        } else {
            return def;
        }
    }

    Block get_block_safe(Chunk chunk, vec3i chunkpos, vec3i position, Block def = AIR_BLOCK) {
        return get_block_safe(chunk, chunkpos.x, chunkpos.y, chunkpos.z, position.x, position.y, position.z, def);
    }

    Block get_block_safe(Chunk chunk, int x, int y, int z, int wx, int wy, int wz, Block def = AIR_BLOCK) {
        if(chunk !is null && !chunk.empty && x >= 0 && x < Chunk.width && y >= 0 && y < Chunk.height && z >= 0 && z < Chunk.depth) {
            return chunk.blocks[chunk.to_flat(x, y, z)];
        }

        return get_block_safe(wx, wy, wz);
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
        Tessellator tessellator = Tessellator(this, atlas, engine.resmgr.get!Gloom("sphere"), tb);

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

                tessellator.trigger_realloc();

                foreach(z; 0..depth) {
                    z_offset = wcoords_orig.z + z + 0.5f;
                    z_offset_n = z_offset + 1.0f;

                    wcoords.x = wcoords_orig.x;
                    wcoords.z = wcoords_orig.z + z;

                    value = chunk.get_block_safe(0, y, z, AIR_BLOCK);

                    foreach(x; 0..width) {
                        x_offset = wcoords_orig.x + x + 0.5f;
                        x_offset_r = x_offset + 1.0f;
                        wcoords.x = wcoords_orig.x + x;

                        index = x+z*depth+y*ystep;

                        if(x == width-1) {
                            right_block = get_block_safe(wcoords.x+1, wcoords.y, wcoords.z, AIR_BLOCK);
                        } else {
                            right_block = chunk.blocks[index+1];
                        }

                        if(z == depth-1) {
                            front_block = get_block_safe(wcoords.x, wcoords.y, wcoords.z+1, AIR_BLOCK);
                        } else {
                            front_block = chunk.blocks[index+width];
                        }

                        if(y == height-1) {
                            top_block = AIR_BLOCK;
                        } else {
                            top_block = chunk.blocks[index+ystep];
                        }

                        tessellator.feed(chunk, wcoords, x, y, z,
                                        x_offset, x_offset_r, y_offset, y_offset_t, z_offset, z_offset_n,
                                        value, right_block, top_block, front_block,
                                        biome_set.biomes[chunk.get_biome_safe(x+z*15)]);

                        value = right_block;
                    }
                }
            }
        }

        chunk.vbo_vcount = tessellator.terrain_elements / Vertex.sizeof;

        debug {
            assert(cast(size_t)tb.terrain.ptr % 4 == 0, "whatever I did check here isn't true anylonger");
            //assert(tessellator.terrain_elements*Vertex.sizeof % 4 == 0, "");
            static assert(Vertex.sizeof % 4 == 0, "Vertex struct is not a multiple of 4");
        }

        return tessellator.terrain_elements;
    }

    void postprocess_chunks() {
        // NOTE queue opApply changed, eventual fix required
        if(!output.empty) foreach(tess_out; output.get_all(output_buffer, true)) with(tess_out) {
            if(chunk.vbo is null) {
                chunk.vao = new VAO();
                chunk.vbo = new Buffer();
            }

            chunk.vao.bind();
            chunk.vbo.bind();
            scope(exit) chunk.vbo.unbind();
            scope(exit) chunk.vao.unbind();

            chunk.vbo.set_data(buffer.terrain.ptr, elements);

            assert(chunk.vbo !is null, "chunk vbo is null");
            assert(engine.current_shader !is null, "current shader is null");
            Vertex.bind(engine.current_shader, chunk.vbo);

            chunk.tessellated = true;
            buffer.available = true;
        }

        version(NoThreads) {
            if(!input.empty) {
                tessellation_threads[0].poll();
            }
        }
    }

    void check_chunk(Chunk chunk, vec3i chunkc) {
        if(chunk.dirty && chunk.tessellated) {
            chunk.dirty = false;
            chunk.tessellated = false;
            // this queue is never full and we don't wanna waste time waiting
            input.put(ChunkData(chunk, chunkc));
        }
    }
}


final class TessellationThread : VerboseThread {
    protected TessellationBuffer buffer;
    protected World world;
    protected Queue!ChunkData input;
    protected Queue!TessOut output;

    protected Event stop_event;

    this(World world, Queue!ChunkData input, Queue!TessOut output) {
        super(&run);

        this.world = world;
        this.buffer = TessellationBuffer(world.default_tessellation_buffer_size,
                                         world.default_light_buffer_size);
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
        logger.log!Info(`Setting stop for: "%s"`, this.name);
        stop_event.set();
    }
            
    void poll() {
        // waits only if the buffer is not available
        buffer.wait_available();

        ChunkData chunk_data;
        try {
            // continue loop every 500ms to check if we should continue or exit
            chunk_data = input.get(true, dur!"msecs"(500));
        } catch(Empty) {
            return;
        }
        scope(exit) input.task_done();

        with(chunk_data) {
            if(chunk.tessellated) {
                logger.log!Debug("Chunk is already tessellated! %s", position);
                return;
            } else {
                buffer.available = false;
            }

            size_t elements = world.tessellate(chunk, position, &buffer);

            output.put(TessOut(chunk, &buffer, elements));
        }       
    }
}
