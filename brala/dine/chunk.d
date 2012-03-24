module brala.dine.chunk;

private {
    import glamour.gl : GLuint, GLenum, GL_FLOAT;
    import glamour.vbo : Buffer;
    
    import std.c.string : memcpy;
    import std.bitmanip : bitfields;
    
    import gl3n.linalg : vec3i;

    import brala.dine.vertices : BLOCK_VERTICES_LEFT, BLOCK_VERTICES_RIGHT, BLOCK_VERTICES_NEAR,
                                 BLOCK_VERTICES_FAR, BLOCK_VERTICES_TOP, BLOCK_VERTICES_BOTTOM;
    import brala.dine.util : calloc, malloc, realloc, free, log2_ub;
    import brala.engine : BraLaEngine;
    import brala.utils.ctfe : TupleRange;
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

private const Block AIR_BLOCK = Block(0);

private struct NeighbourChunks {
    Chunk* left;
    Chunk* right;
    Chunk* near;
    Chunk* far;
    Chunk* top;
    Chunk* bottom;
}

// NOTE to prgrammer, ctor will maybe called from a seperate thread
// => dont do opengl stuff in the ctor
class Chunk {
    // width, height, depth must be a power of two
    const int width = 16;
    const int height = 256;
    const int depth = 16;
    
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

    NeighbourChunks neighbour_chunks;
    
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
        if(x < width && y < height && z < depth) {
            return get_block(to_flat(x, y, z));
        } else {
            return Block(0, 0);
        }
    }

    Block blockss(int i) {
        if(i < 0) return Block(0, 0);
        if(i > block_count) return Block(0, 0);
        return blocks[i];
    }
    
    // rendering
    
    // fills the vbo with the chunk content    
    // credits to Florian Boesch - http://codeflow.org/
    void tessellate(ref float* v, ref size_t length, bool force = false){
        if(vbo is null) {
            vbo = new Buffer();
        }

        if(dirty || force) {
            int zstep = width*height;
            int index;
            int w = 0;

            float x_offset;
            float x_offset_r;
            float y_offset;
            float y_offset_t;
            float z_offset;
            float z_offset_n;

            Block value;
            Block right_block;
            Block top_block;
            Block front_block;

            foreach(z; -1..depth) {
                z_offset = z+0.5f;
                z_offset_n = z+1.5f;

                foreach(y; -1..height-1) {
                    y_offset = y+0.5f;
                    y_offset_t = y+1.5f;

                    value = AIR_BLOCK;

                    if(w+1024 > length) {
                        length = length + (depth-z)*width*height;
                        v = cast(float*)realloc(v, length*float.sizeof);
                    }

                    foreach(x; -1..width) {
                        x_offset = x+0.5f;
                        x_offset_r = x+1.5f;
                        
                        index = x+y*width+z*zstep;

                        if(z == -1) {
                            right_block = AIR_BLOCK;
                            top_block = AIR_BLOCK;

                            if(y >= 0 && y < height-1 && x >= 0 && x < width-1) {
                                front_block = blocks[index+zstep];
                            } else {
                                front_block = AIR_BLOCK;
                            }
                        } else if(z == depth-1) {
                            if(x < width-1) {
                                right_block = blocks[index+1];
                            } else {
                                right_block = AIR_BLOCK;
                            }

                            if(x >= 0) {
                                top_block = blocks[index+width];
                            } else {
                                top_block = AIR_BLOCK;
                            }
                            
                            front_block = AIR_BLOCK;
                        } else {
                            if(y == height-1) {
                                right_block = AIR_BLOCK;
                                top_block = AIR_BLOCK;
                                front_block = AIR_BLOCK;
                            } else if(y == -1) {
                                right_block = AIR_BLOCK;
                                front_block = AIR_BLOCK;

                                if(x >= 0 || x < width-1 || z >= 0 || z < depth-1) {
                                    top_block = blocks[index+width];
                                } else {
                                    top_block = AIR_BLOCK;
                                }
                            } else {
                                if(x == -1) {
                                    right_block = blocks[index+1];
                                    top_block = AIR_BLOCK;
                                    front_block = AIR_BLOCK;
                                } else if(x == width-1) {
                                    right_block = AIR_BLOCK;
                                    top_block = blocks[index+width];
                                    front_block = blocks[index+zstep];
                                } else {
                                    right_block = blocks[index+1];
                                    top_block = blocks[index+width];
                                    front_block = blocks[index+zstep];
                                }
                            }
                        }
                        
                        // TODO: use primary bitmask
                        // TODO: octree?
                        // TODO: maybe dont use a "template vertices" for easy blocks, which only consist of 2 triangles per side
                        if(value == 0) {
                            if(right_block.id != 0) {
                                float[] vertices = BLOCK_VERTICES_LEFT[right_block.id];
                                v[w..(w+(vertices.length))] = vertices;
                                size_t rw = w;
                                for(; w < (rw+vertices.length); w += 5) {
                                    v[w++] += x_offset_r;
                                    v[w++] += y_offset;
                                    v[w++] += z_offset;
                                }
                            }
                            if(top_block.id != 0) {
                                float[] vertices = BLOCK_VERTICES_BOTTOM[top_block.id];
                                v[w..(w+(vertices.length))] = vertices;
                                size_t rw = w;
                                for(; w < (rw+vertices.length); w += 5) {
                                    v[w++] += x_offset;
                                    v[w++] += y_offset_t;
                                    v[w++] += z_offset;
                                }
                            }
                            if(front_block.id != 0) {
                                float[] vertices = BLOCK_VERTICES_FAR[front_block.id];
                                v[w..(w+(vertices.length))] = vertices;
                                size_t rw = w;
                                for(; w < (rw+vertices.length); w += 5) {
                                    v[w++] += x_offset;
                                    v[w++] += y_offset;
                                    v[w++] += z_offset_n;
                                }
                            }
                        } else {
                            if(right_block == 0) {
                                float[] vertices = BLOCK_VERTICES_RIGHT[value.id];
                                v[w..(w+(vertices.length))] = vertices;
                                size_t rw = w;
                                for(; w < (rw+vertices.length); w += 5) {
                                    v[w++] += x_offset;
                                    v[w++] += y_offset;
                                    v[w++] += z_offset;
                                }
                            }
                            if(top_block == 0) {
                                float[] vertices = BLOCK_VERTICES_TOP[value.id];
                                v[w..(w+(vertices.length))] = vertices;
                                size_t rw = w;
                                for(; w < (rw+vertices.length); w += 5) {
                                    v[w++] += x_offset;
                                    v[w++] += y_offset;
                                    v[w++] += z_offset;
                                }
                            }
                            if(front_block == 0) {
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

                        value = right_block;
                    }
                }
            }

            vbo_type = GL_FLOAT;
            vbo_vcount = w / 8; // 8 = vertex: x,y,z, normal: xn, yn, zn, texcoords: u, v
            vbo.set_data(v[0..w], GL_FLOAT);

            dirty = false;
        }
    }
    
    void bind(BraLaEngine engine)
        in { assert(vbo !is null); assert(engine.current_shader !is null, "no current shader"); }
        body {
            GLuint position = engine.current_shader.get_attrib_location("position");
            GLuint normal = engine.current_shader.get_attrib_location("normal");
            GLuint texcoord = engine.current_shader.get_attrib_location("texcoord");
            
            // stride = vertex: x,y,z, normal: xn, xy, xz, texcoords: u, v
            uint stride = (3+3+2)*float.sizeof;
            
            vbo.bind(position, 3, 0, stride);
            vbo.bind(normal, 3, 3*float.sizeof, stride);
            vbo.bind(texcoord, 2, (3+3)*float.sizeof, stride);
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
    static uint to_flat(vec3i inp) {
        return to_flat(inp.x, inp.y, inp.z);
    }
    
    static uint to_flat(uint x, uint y, uint z)
        in { assert(x < width && y < height && z < depth); }
        out (result) { assert(result < block_count); }
        body {
            return x + y*width + z*width*height;
        }
    
    static vec3i from_flat(uint flat)
        in { assert(flat < block_count); }
        out (result) { assert(result.vector[0] < width && result.vector[1] < height && result.vector[2] < depth); }
        body {
            return vec3i(flat & (width-1), // x: flat % width
                         (flat >> log2width) & (height-1), // y: (flat / width) % height
                         flat >> log2heightwidth); // z: flat / (height*width)
        }
}