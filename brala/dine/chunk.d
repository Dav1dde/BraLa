module brala.dine.chunk;

private {
    import glamour.gl : GLuint, GLenum;
    import glamour.vbo : Buffer;
    
    import std.bitmanip : bitfields;
    
    import gl3n.linalg : vec3i;
    import brala.dine.util : calloc, free, log2_ub;
}


struct Block {
    ubyte id;
    
    mixin(bitfields!(ubyte, "metadata", 4,
                     ubyte, "block_light", 4,
                     ubyte, "sky_light", 4,
                     ubyte, "", 4));  // padding
                     
    const bool opEquals(const ref Block other) {
        return other.id == id && other.metadata == metadata;
    }
    
    const bool opEquals(const int id) {
        return id == this.id;
    }
}

// NOTE to prgrammer, ctor will maybe called from a seperate thread
// => dont do opengl stuff in the ctor
class Chunk {
    // width, height, depth must be a power of two
    const int width = 16;
    const int height = 256;
    const int depth = 16;

    const int zstep = width*height;
    const int log2width = log2_ub(width);
    const int log2height = log2_ub(height);
    const int log2depth = log2_ub(depth);
    const int log2heightwidth = log2_ub(height*width);
    
    const int block_count = width*height*depth;
    const int data_size = block_count*Block.sizeof;
    
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
    GLenum vbo_type;
    GLenum vbo_vcount;
    
    protected void free_chunk() {
        if(!empty) {
            free(blocks);
        }
    }
    
    this() {
        blocks = empty_blocks;
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
    
    Block get_block(vec3i position) {
        return get_block(to_flat(position));
    }
    
    Block get_block(uint x, uint y, uint z) {
        return get_block(to_flat(x, y, z));
    }
    
    Block get_block(uint flat)
        in { assert(!empty); assert(flat < block_count); }
        body {
            return blocks[flat];
        }
    
    Block get_block_safe(vec3i position) {
        return get_block_safe(position.x, position.y, position.z);
    }
    
    Block get_block_safe(int x, int y, int z) {
        if(x >= 0 && x < width && y >= 0 && y < height && z >= 0 && z < depth) {
            return get_block(to_flat(x, y, z));
        } else {
            return Block(0, 0);
        }
    }
        
    // operator overloading
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
         
    // static stuff
    static int to_flat(vec3i inp) {
        return to_flat(inp.x, inp.y, inp.z);
    }
    
    static int to_flat(int x, int y, int z)
        in { assert(x >= 0 && x < width && y >= 0 && y < height && z >= 0 && z < depth); }
        out (result) { assert(result < block_count); }
        body {
            return x + y*width + z*zstep;
        }
    
    static vec3i from_flat(int flat)
        in { assert(flat < block_count); }
        out (result) { assert(result.vector[0] < width && result.vector[1] < height && result.vector[2] < depth); }
        body {
            return vec3i(flat & (width-1), // x: flat % width
                         (flat >> log2width) & (height-1), // y: (flat / width) % height
                         flat >> log2heightwidth); // z: flat / (height*width)
        }
}