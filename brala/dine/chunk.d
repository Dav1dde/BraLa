module brala.dine.chunk;

private {
    import std.c.string : memset;
    import std.bitmanip : bitfields;
    import std.string : format;
    import std.typecons : Tuple, tuple;
    
    import gl3n.linalg : vec3i;

    import brala.dine.util : calloc, malloc, free, log2_ub;
}


struct Block {
    ubyte id;
    
    mixin(bitfields!(ubyte, "metadata", 4,
                     ubyte, "block_light", 4,
                     ubyte, "sky_light", 4,
                     ubyte, "", 4));  // padding
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
    
    immutable int x;
    immutable int z;
    
    bool empty;
    Block* blocks;
    
    protected void free_chunk() {
        if(!empty) {
            free(blocks);
        }
    }
    
    this(int x, int z) {
        blocks = empty_blocks;
        empty = true;
        
        this.x = x;
        this.z = z;
    }
    
    ~this() {
        free_chunk();
    }
    
    // Make sure you allocated *blocks with malloc,
    // the chunk will free the memory when needed.
    void fill_chunk(Block* blocks) {
        free_chunk();
        
        this.blocks = blocks;
        this.empty = false;
    }
    
    void fill_chunk_with_nothing() {
        blocks = cast(Block*)calloc(block_count, Block.sizeof);
        empty = false;
    }
    
    void empty_chunk() {
        free(blocks);
        blocks = empty_blocks;
        empty = true;
    }
    
    string toString() {
        return format("Chunk(x : %d, z : %d)", x, z);
    }
    
    static uint to_flat(vec3i inp) {
        return to_flat(inp.x, inp.y, inp.z);
    }
    
    static uint to_flat(uint x, uint y, uint z)
        in { assert(x <= width && y <= height && z <= depth); }
        out (result) { assert(result <= block_count); }
        body {
            return y + z*height + x*height*depth;
        }
    
    static vec3i from_flat(uint flat)
        in { assert(flat <= block_count); }
        out (result) { assert(result.vector[0] <= width && result.vector[1] <= height && result.vector[2] <= depth); }
        body {
            return vec3i(flat >> log2heightdepth, // x: flat / (height*depth)
                         flat & (height-1), // y: flat % height
                         (flat >> log2height) & (depth-1)); // z: (flat / height) % depth
        }
}