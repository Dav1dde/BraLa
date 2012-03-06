module brala.dine.chunk;

private {
    import std.c.stdlib : malloc, calloc, free;
    import std.c.string : memset;
    import std.bitmanip : bitfields;
    import std.string : format;
}


struct Block {
    ubyte id;
    
    mixin(bitfields!(ubyte, "metadata", 4,
                     ubyte, "block_light", 4,
                     ubyte, "sky_light", 4,
                     ubyte, "", 4));  // padding
}

// TODO: replace malloc with a custom malloc version, which checks the return-value of malloc
class Chunk {
    const uint width = 16;
    const uint height = 256;
    const uint depth = 16;
    const uint block_count = 16*256*16;
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
    
    private void free_chunk() {
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
        blocks = cast(Block*)malloc(data_size);
        memset(blocks, 0, data_size);
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
    
    static size_t flat(int x, int y, int z) {
        return y + z*(height-1) + x*(height-1)*(width-1);
    }
}