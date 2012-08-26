module brala.dine.world;

private {
    import glamour.gl;
    import glamour.vbo : Buffer;
    
    import gl3n.linalg : vec3i, mat4;

    import core.thread : Thread;

    import brala.dine.chunk : Chunk, Block;
    import brala.dine.builder.biomes : BiomeSet;
    import brala.dine.builder.tessellator : Tessellator, Vertex;
    import brala.dine.util : py_div, py_mod;
    import brala.exception : WorldError;
    import brala.resmgr : ResourceManager;
    import brala.engine : BraLaEngine;
    import brala.utils.queue : Queue;
    import brala.utils.memory : MemoryCounter, malloc, realloc, free;
}

private const Block AIR_BLOCK = Block(0);

struct TessellationBuffer {
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
    
    void free() {
        .free(ptr);
        ptr = null;
        length = 0;
    }
}


class World {
    static const default_tessellation_bufer_size = width*height*depth*80;
    
    const int width = 16;
    const int height = 256;
    const int depth = 16;
    const int zstep = width*height;
    const int min_height = 0;
    const int max_height = height;    
    
    Chunk[vec3i] chunks;
    vec3i spawn;

    MemoryCounter vram = MemoryCounter("vram");

    BiomeSet biome_set;

    protected TessellationBuffer[] tesselation_buffer;
    
    this(ResourceManager resmgr, size_t threads) {
        biome_set.update_colors(resmgr);
        
        threads = threads ? threads : 1;
        foreach(i; 0..threads) {
            tesselation_buffer ~= TessellationBuffer(default_tessellation_bufer_size);
        }
    }
    
    this(ResourceManager resmgr, vec3i spawn, size_t threads) {
        this.spawn = spawn;
        this(resmgr, threads);
    }
    
    ~this() {
        remove_all_chunks();
        
        foreach(ref tb; tesselation_buffer) {
            tb.free();
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

        foreach(z; 0..depth) {
            z_offset = z + 0.5f;
            z_offset_n = z + 1.5f;

            wcoords.z = wcoords_orig.z + z;

            foreach(b; 0..hds) {
                if((chunk.primary_bitmask >> b) & 1 ^ 1) continue;

                foreach(y_; 0..hds) {
                    y = b*hds + y_;

                    y_offset = y+0.5f;
                    y_offset_t = y+1.5f;

                    wcoords.x = wcoords_orig.x;
                    wcoords.y = wcoords_orig.y + y;

                    value = get_block_safe(wcoords);

                    tessellator.realloc_buffer_if_needed(1024*(depth-z));

                    foreach(x; 0..width) {
                        x_offset = x+0.5f;
                        x_offset_r = x+1.5f;
                        wcoords.x = wcoords_orig.x + x;

                        index = x+y*width+z*zstep;

                        if(x == width-1) {
                            right_block = get_block_safe(vec3i(wcoords.x+1, wcoords.y,   wcoords.z),   AIR_BLOCK);
                        } else {
                            right_block = chunk.blocks[index+1];
                        }

                        if(z == depth-1) {
                            front_block = get_block_safe(vec3i(wcoords.x,  wcoords.y,   wcoords.z+1), AIR_BLOCK);
                        } else {
                            front_block = chunk.blocks[index+zstep];
                        }

                        if(y == height-1) {
                            top_block = AIR_BLOCK;
                        } else {
                            top_block = chunk.blocks[index+width];
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

    void bind(BraLaEngine engine, Chunk chunk)
        in { assert(chunk.vbo !is null); assert(engine.current_shader !is null, "no current shader"); }
        body {
            GLuint position = engine.current_shader.get_attrib_location("position");
            GLuint normal = engine.current_shader.get_attrib_location("normal");
            GLuint color = engine.current_shader.get_attrib_location("color");
            GLuint texcoord = engine.current_shader.get_attrib_location("texcoord");
            GLuint mask = engine.current_shader.get_attrib_location("mask");

            uint stride = Vertex.sizeof;
            chunk.vbo.bind(position, GL_FLOAT, 3, 0, stride);
            chunk.vbo.bind(normal, GL_FLOAT, 3, 12, stride);
            chunk.vbo.bind(color, GL_UNSIGNED_BYTE, 4, 24, stride, true); // normalize it
            chunk.vbo.bind(texcoord, GL_BYTE, 2, 28, stride);
            chunk.vbo.bind(mask, GL_BYTE, 2, 30, stride);
        }
    
    void draw(BraLaEngine engine) {
        foreach(chunkc, chunk; chunks) {
            if(chunk.dirty) {
                auto buffer = tesselation_buffer[0];
                size_t elements = tessellate(chunk, chunkc, &buffer);
                if(chunk.vbo is null) {
                    chunk.vbo = new Buffer();
                }

                debug size_t prev = chunk.vbo.length;

                chunk.vbo.set_data(buffer.ptr, elements);
                chunk.dirty = false;

                debug {
                    if(prev == 0 && chunk.vbo.length) {
                        vram.add(chunk.vbo.length);
                    } else {
                        vram.adjust(chunk.vbo.length - prev);
                    }
                }
            }
            
            bind(engine, chunk);
 
            engine.model = mat4.translation(chunkc.x*width, chunkc.y*height, chunkc.z*depth);
            engine.flush_uniforms();

            glDrawArrays(GL_TRIANGLES, 0, cast(uint)chunk.vbo_vcount);
        }
    }
}