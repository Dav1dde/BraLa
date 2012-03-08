module brala.dine.chunk;

private {
    import glamour.vbo : Buffer;
    
    import std.c.string : memset;
    import std.bitmanip : bitfields;
    
    import gl3n.linalg : vec3i;

    import brala.dine.util : calloc, malloc, free, log2_ub;
}


struct Block {
    ubyte id;
    
    mixin(bitfields!(ubyte, "metadata", 4,
                     ubyte, "block_light", 4,
                     ubyte, "sky_light", 4,
                     ubyte, "", 4));  // padding
                     
    const bool opEquals(ref Block other) {
        return other.id == id && other.metadata == metadata;
    }
}

class Chunk {
    // width, height, depth must be a power of two
    const uint width = 16;
    const uint height = 256;
    const uint depth = 16;
    
    const uint log2width = log2_ub(width);
    const uint log2height = log2_ub(height);
    const uint log2depth = log2_ub(depth);
    const uint log2heightdepth = log2_ub(height*depth);
    
    const uint block_count = width*height*depth;
    const uint data_size = block_count*Block.sizeof;
    
    static Block* empty_blocks;
    
    private static this() {
        empty_blocks = cast(Block*)calloc(block_count, Block.sizeof);
    }
    
    private static ~this() {
        free(empty_blocks);
    }
    
    bool dirty;
    
    bool empty;
    Block* blocks;
    ubyte[] biome_data;
    
    Buffer vbo;
    
    protected void free_chunk() {
        if(!empty) {
            free(blocks);
        }
    }
    
    this() {
        blocks = empty_blocks;
        vbo = new Buffer();
        empty = true;
        dirty = false;
    }
    
    ~this() {
        free_chunk();
    }
    
    // Make sure you allocated *blocks with malloc,
    // the chunk will free the memory when needed.
    void fill_chunk(Block* blocks) {
        free_chunk();
        
        this.blocks = blocks;
        empty = false;
        dirty = true;
    }
    
    void fill_chunk_with_nothing() {
        free_chunk();
        
        blocks = cast(Block*)calloc(block_count, Block.sizeof);
        empty = false;
        dirty = true;
    }
    
    void empty_chunk() {
        free(blocks);
        blocks = empty_blocks;
        empty = true;
        dirty = true;
    }
    
    Block opIndex(size_t flat)
    in { assert(!empty); assert(flat < block_count); }
    body {
        return blocks[flat];        
    }
    
    Block opIndex(vec3i position)
        in { assert(!empty); }
        body {
            return blocks[to_flat(position)];
        }
    
    void opIndexAssign(Block value, size_t flat)
        in { assert(!empty); assert(flat < block_count); }
        body {
            blocks[flat] = value;
            dirty = true;
        }
        
    void opIndexAssign(Block value, vec3i position)
        in { assert(!empty); }
        body {
            blocks[to_flat(position)] = value;
            dirty = true;
        }
    
    int opApply(int delegate(const ref Block) dg)
        in { assert(!empty); }
        body {
            int result;
            
            foreach(b; 0..block_count) {
                result = dg(blocks[b]);
                if(result) break;
            }
            
            return result;
        }
    
    int opApply(int delegate(uint, const ref Block) dg)
        in { assert(!empty); }
        body {
            int result;
            
            foreach(b; 0..block_count) {
                result = dg(b, blocks[b]);
                if(result) break;
            }
            
            return result;
        }
            
    static uint to_flat(vec3i inp) {
        return to_flat(inp.x, inp.y, inp.z);
    }
    
    static uint to_flat(uint x, uint y, uint z)
        in { assert(x <= width && y <= height && z <= depth); }
        out (result) { assert(result < block_count); }
        body {
            return y + z*height + x*height*depth;
        }
    
    static vec3i from_flat(uint flat)
        in { assert(flat < block_count); }
        out (result) { assert(result.vector[0] <= width && result.vector[1] <= height && result.vector[2] <= depth); }
        body {
            return vec3i(flat >> log2heightdepth, // x: flat / (height*depth)
                         flat & (height-1), // y: flat % height
                         (flat >> log2height) & (depth-1)); // z: (flat / height) % depth
        }
}