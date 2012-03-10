module brala.dine.world;

private {
    import glamour.gl : glDrawArrays, GL_TRIANGLES;
    
    import gl3n.linalg : vec2i, vec3i, mat4;
    
    import brala.dine.chunk : Chunk, Block;
    import brala.exception : WorldError;
    import brala.engine : BraLaEngine;
    
    debug import std.stdio : writefln;
}


class World {
    const uint width = 16;
    const uint height = 256;
    const uint depth = 16;
    const int min_height = 0;
    const int max_height = height;    
    
    Chunk[vec2i] chunks;
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
    void add_chunk(Chunk chunk, vec2i chunkc) {
        if(Chunk* c = chunkc in chunks) {
            c.empty_chunk();
        } 
        
        chunks[chunkc] = chunk;
        mark_surrounding_chunks_dirty(chunkc);
    }
    
    void remove_chunk(vec2i chunkc) {
        chunks[chunkc].empty_chunk();
        chunks.remove(chunkc);
    }
    
    void remove_all_chunks() {
        foreach(key, chunk; chunks) {
            chunk.empty_chunk();
            chunks.remove(key);
        }
    }
    
    Chunk get_chunk(int x, int z) {
        return get_chunk(vec2i(x, z));
    }
    
    Chunk get_chunk(vec2i chunkc) {
        return chunks[chunkc];
    }
    
    void set_block(vec3i position, Block block)
        in { assert(position.y >= min_height && position.y <= max_height); }
        body {
            vec2i chunkc = vec2i(position.x / width, position.z / depth);
            Chunk chunk = get_chunk(chunkc);
            
            if(chunk is null) {
                throw new WorldError("No chunk available for position " ~ position.toString());
            }
            
            vec3i block_position = vec3i(position.x % width, position.y, position.z % depth);
            uint flat = chunk.to_flat(block_position);
            
            if(chunk[flat] != block) {
                chunk[flat] = block;
                mark_surrounding_chunks_dirty(chunkc);
            }
        }
    
    Block get_block(vec3i position)
        in { assert(position.y >= min_height && position.y <= max_height); }
        body {
            Chunk chunk = get_chunk(position.x / width, position.z / depth);
            
            if(chunk is null) {
                throw new WorldError("No chunk available for position " ~ position.toString());
            }
            
            return chunk[chunk.to_flat(position.x % width, position.y, position.z % depth)];
        }
    
    void mark_surrounding_chunks_dirty(int x, int z) {
        return mark_surrounding_chunks_dirty(vec2i(x, z));
    }
    
    void mark_surrounding_chunks_dirty(vec2i chunkc) {
        mark_chunk_dirty(chunkc.x+1, chunkc.y);
        mark_chunk_dirty(chunkc.x-1, chunkc.y);
        mark_chunk_dirty(chunkc.x, chunkc.y+1);
        mark_chunk_dirty(chunkc.x, chunkc.y-1);
    }
    
    void mark_chunk_dirty(int x, int z) {
        return mark_chunk_dirty(vec2i(x, z));
    }
    
    void mark_chunk_dirty(vec2i chunkc) {
        if(Chunk* c = chunkc in chunks) {
            c.dirty = true;
        }
    }
    
    void draw(BraLaEngine engine) {
        foreach(chunkc, chunk; chunks) {
            chunk.tesselate(false);
            chunk.bind(engine);
            
            engine.model = mat4.translation(chunkc.x*width, 0, chunkc.y*depth);

            glDrawArrays(GL_TRIANGLES, 0, chunk.vbo_vcount);
        }
    }
}