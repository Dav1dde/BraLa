module brala.dine.world;

private {
    import gl3n.linalg : vec2i, vec3i;
    
    import brala.dine.chunk : Chunk;
}


class World {
    const uint height = 256;
    
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
    
    Chunk get_chunk(vec2i chunkc) {
        return chunks[chunkc];
    }
}