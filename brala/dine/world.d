module brala.dine.world;

private {
    import glamour.gl : glDrawArrays, GL_TRIANGLES;
    
    import gl3n.linalg : vec3i, mat4;
    
    import brala.dine.chunk : Chunk, Block;
    import brala.dine.util : malloc, free;
    import brala.exception : WorldError;
    import brala.engine : BraLaEngine;
}


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
        update_neighbours(&chunk, chunkc);
    }
    
    void remove_chunk(vec3i chunkc)
        in { assert(chunkc in chunks); }
        body {
            chunks[chunkc].empty_chunk();
            chunks.remove(chunkc);

            mark_surrounding_chunks_dirty(chunkc);
            update_neighbours(chunkc);
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
        return chunks[chunkc];
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

    void update_neighbours(vec3i chunkc) {
        Chunk* c = chunkc in chunks;
        update_neighbours(c, chunkc);
    }
        
    void update_neighbours(Chunk* chunk, vec3i chunkc) {
        Chunk* c_left = vec3i(chunkc.x-1, chunkc.yz) in chunks;
        Chunk* c_right = vec3i(chunkc.x+1, chunkc.yz) in chunks;
        Chunk* c_near = vec3i(chunkc.xy, chunkc.z+1) in chunks;
        Chunk* c_far = vec3i(chunkc.xy, chunkc.z-1) in chunks;
        Chunk* c_top = vec3i(chunkc.x, chunkc.y+1, chunkc.z) in chunks;
        Chunk* c_bottom = vec3i(chunkc.x, chunkc.y-1, chunkc.z) in chunks;

        if(chunk is null) {
            if(c_left !is null)     c_left.neighbour_chunks.right = chunk;
            if(c_right !is null)   c_right.neighbour_chunks.left = chunk;
            if(c_near !is null)     c_near.neighbour_chunks.far = chunk;
            if(c_far !is null)       c_far.neighbour_chunks.near = chunk;
            if(c_top !is null)       c_top.neighbour_chunks.bottom = chunk;
            if(c_bottom !is null) c_bottom.neighbour_chunks.top = chunk;
        } else {
            chunk.neighbour_chunks.left = c_left;
            chunk.neighbour_chunks.right = c_right;
            chunk.neighbour_chunks.near = c_near;
            chunk.neighbour_chunks.far = c_far;
            chunk.neighbour_chunks.top = c_top;
            chunk.neighbour_chunks.bottom = c_bottom;
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
    
    void draw(BraLaEngine engine) {
        foreach(chunkc, chunk; chunks) {
            chunk.tessellate(tessellate_buffer, tessellate_buffer_length, false);
            chunk.bind(engine);
            
            engine.model = mat4.translation(chunkc.x*width, chunkc.y*height, chunkc.z*depth);
            engine.flush_uniforms();
            
            glDrawArrays(GL_TRIANGLES, 0, chunk.vbo_vcount);
        }
    }
}