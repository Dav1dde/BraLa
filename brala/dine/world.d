module brala.dine.world;

private {
    import glamour.gl : GLuint, glDrawArrays, GL_TRIANGLES, GL_FLOAT;
    import glamour.vbo : Buffer;
    
    import gl3n.linalg : vec3i, mat4;
    
    import brala.dine.chunk : Chunk, Block;
    import brala.dine.vertices : BLOCK_VERTICES_LEFT, BLOCK_VERTICES_RIGHT, BLOCK_VERTICES_NEAR,
                                 BLOCK_VERTICES_FAR, BLOCK_VERTICES_TOP, BLOCK_VERTICES_BOTTOM;
    import brala.dine.util : malloc, realloc, free
    import brala.exception : WorldError;
    import brala.engine : BraLaEngine;
}

private const Block AIR_BLOCK = Block(0);

class World {
    static float* tessellate_buffer;
    static size_t tessellate_buffer_length;
    
    static this() {
        tessellate_buffer_length = width*height*depth*12; // this value is the result of testing!
        tessellate_buffer = cast(float*)malloc(tessellate_buffer_length*float.sizeof);
    }
    
    static ~this() {
    }
    
    const int width = 16;
    const int height = 256;
    const int depth = 16;
    const int zstep = width*height;
    const int min_height = 0;
    const int max_height = height;    
    
    Chunk[vec3i] chunks;
    vec3i spawn;
    
    this() {}
    
    this(vec3i spawn) {
        this.spawn = spawn;
    }
    
    ~this() {
        remove_all_chunks();
    }
    
    // when a chunk is passed to this method, the world will take care of it's memory
    // you should also lose all other references to this chunk
    //
    // old chunk will be cleared
    void add_chunk(Chunk chunk, vec3i chunkc) {
        if(Chunk* c = chunkc in chunks) {
            c.empty_chunk();
        } 
        
        chunks[chunkc] = chunk;
        mark_surrounding_chunks_dirty(chunkc);
    }
    
    void remove_chunk(vec3i chunkc)
        in { assert(chunkc in chunks); }
        body {
            chunks[chunkc].empty_chunk();
            chunks.remove(chunkc);

            mark_surrounding_chunks_dirty(chunkc);
        }
    
    void remove_all_chunks() {
        foreach(key, chunk; chunks) {
            chunk.empty_chunk();
            chunks.remove(key);
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
            vec3i chunkc = vec3i(position.x / width, position.y / height, position.z / depth);
            Chunk chunk = get_chunk(chunkc);
            
            if(chunk is null) {
                throw new WorldError("No chunk available for position " ~ position.toString());
            }
            
            vec3i block_position = vec3i(position.x % width, position.y % height, position.z % depth);
            uint flat = chunk.to_flat(block_position);
            
            if(chunk[flat] != block) {
                chunk[flat] = block;
                mark_surrounding_chunks_dirty(chunkc);
            }
        }
    
    Block get_block(vec3i position)
        in { assert(position.y >= min_height && position.y <= max_height); }
        body {
            Chunk chunk = get_chunk(position.x / width, position.y / height, position.z / depth);
            
            if(chunk is null) {
                throw new WorldError("No chunk available for position " ~ position.toString());
            }
            
            return chunk[chunk.to_flat(position.x % width, position.y % height, position.z % depth)];
        }

    Block get_block_safe(vec3i position, Block def = AIR_BLOCK) {
        Chunk chunk = get_chunk(position.x / width, position.y / height, position.z / depth);

        if(chunk is null) return def;

        int x = position.x % width;
        int y = position.y % height;
        int z = position.z % depth;

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
   
    bool is_air(Chunk chunk, vec3i chunkc, int x, int y, int z) {
        if(x >= 0 && x < width && y >= 0 && y < height && z >= 0 && z < depth) {
            return chunk.blocks[x+y*width+z*zstep].id == 0;
        } else {
            return get_block_safe(vec3i(chunkc.x*chunk.width+x, chunkc.y*chunk.height+y, chunkc.z*chunk.depth+z), AIR_BLOCK).id == 0;
        }
    }
    
    // rendering
    void tessellate(Chunk chunk, vec3i chunkc,
                    ref float* v = tessellate_buffer, ref size_t length = tessellate_buffer_length,
                    bool force = false) {
        if(chunk.vbo is null) {
            chunk.vbo = new Buffer();
        }

        if(chunk.dirty || force) {
            int index;
            int w = 0;

            float z_offset;
            float y_offset;
            float x_offset;
            
            Block value;

            // TODO: use the optimized code with 3 lookups
            // TODO: primary bitmask, octree?

            foreach(z; 0..depth) {
                z_offset = z+0.5f;
                foreach(y; 0..height) {
                    y_offset = y+0.5f;

                    if(w+1024 > length) {
                        length = length + (depth-z)*width*height;
                        v = cast(float*)realloc(v, length*float.sizeof);
                    }

                    foreach(x; 0..width) {
                        x_offset = x+0.5f;
                        
                        value = chunk.blocks[x+y*width+z*zstep];

                        if(is_air(chunk, chunkc, x-1, y, z)) {
                            float[] vertices = BLOCK_VERTICES_LEFT[value.id];
                            v[w..(w+(vertices.length))] = vertices;
                            size_t rw = w;
                            for(; w < (rw+vertices.length); w += 5) {
                                v[w++] += x_offset;
                                v[w++] += y_offset;
                                v[w++] += z_offset;
                            }
                        }
                        if(is_air(chunk, chunkc, x, y-1, z)) {
                            float[] vertices = BLOCK_VERTICES_BOTTOM[value.id];
                            v[w..(w+(vertices.length))] = vertices;
                            size_t rw = w;
                            for(; w < (rw+vertices.length); w += 5) {
                                v[w++] += x_offset;
                                v[w++] += y_offset;
                                v[w++] += z_offset;
                            }
                        }
                        if(is_air(chunk, chunkc, x, y, z-1)) {
                            float[] vertices = BLOCK_VERTICES_FAR[value.id];
                            v[w..(w+(vertices.length))] = vertices;
                            size_t rw = w;
                            for(; w < (rw+vertices.length); w += 5) {
                                v[w++] += x_offset;
                                v[w++] += y_offset;
                                v[w++] += z_offset;
                            }
                        }
                        if(is_air(chunk, chunkc, x+1, y, z)) {
                            float[] vertices = BLOCK_VERTICES_RIGHT[value.id];
                            v[w..(w+(vertices.length))] = vertices;
                            size_t rw = w;
                            for(; w < (rw+vertices.length); w += 5) {
                                v[w++] += x_offset;
                                v[w++] += y_offset;
                                v[w++] += z_offset;
                            }
                        }
                        if(is_air(chunk, chunkc, x, y+1, z)) {
                            float[] vertices = BLOCK_VERTICES_TOP[value.id];
                            v[w..(w+(vertices.length))] = vertices;
                            size_t rw = w;
                            for(; w < (rw+vertices.length); w += 5) {
                                v[w++] += x_offset;
                                v[w++] += y_offset;
                                v[w++] += z_offset;
                            }
                        }
                        if(is_air(chunk, chunkc, x, y, z+1)) {
                            float[] vertices = BLOCK_VERTICES_NEAR[value.id];
                            v[w..(w+(vertices.length))] = vertices;
                            size_t rw = w;
                            for(; w < (rw+vertices.length); w += 5) {
                                v[w++] += x_offset;
                                v[w++] += y_offset;
                                v[w++] += z_offset;
                            }
                        }
                    }
                }
            }

            chunk.vbo_type = GL_FLOAT;
            chunk.vbo_vcount = w / 8; // 8 = vertex: x,y,z, normal: xn, yn, zn, texcoords: u, v
            chunk.vbo.set_data(v[0..w], GL_FLOAT);

            chunk.dirty = false;
        }
    }

    void bind(BraLaEngine engine, Chunk chunk)
        in { assert(chunk.vbo !is null); assert(engine.current_shader !is null, "no current shader"); }
        body {
            GLuint position = engine.current_shader.get_attrib_location("position");
            GLuint normal = engine.current_shader.get_attrib_location("normal");
            GLuint texcoord = engine.current_shader.get_attrib_location("texcoord");

            // stride = vertex: x,y,z, normal: xn, xy, xz, texcoords: u, v
            uint stride = (3+3+2)*float.sizeof;

            chunk.vbo.bind(position, 3, 0, stride);
            chunk.vbo.bind(normal, 3, 3*float.sizeof, stride);
            chunk.vbo.bind(texcoord, 2, (3+3)*float.sizeof, stride);
        }

    
    void draw(BraLaEngine engine) {
        foreach(chunkc, chunk; chunks) {
            tessellate(chunk, chunkc, tessellate_buffer, tessellate_buffer_length, false);
            bind(engine, chunk);
            
            engine.model = mat4.translation(chunkc.x*width, chunkc.y*height, chunkc.z*depth);
            engine.flush_uniforms();
            
            glDrawArrays(GL_TRIANGLES, 0, chunk.vbo_vcount);
        }
    }
}