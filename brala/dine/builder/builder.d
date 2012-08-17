module brala.dine.builder.builder;

private {
    import brala.dine.chunk : Block;
    import brala.dine.builder.tessellator : Vertex;
    import brala.dine.builder.constants : Side;
}

public {
    import std.array : array, join;
    import std.algorithm : map;
    import std.functional : memoize;
    import std.metastrings : toStringNow;
    
    import brala.dine.builder.biomes : BiomeData, BIOMES;
    import brala.dine.builder.vertices : BLOCK_VERTICES_LEFT, BLOCK_VERTICES_RIGHT, BLOCK_VERTICES_NEAR,
                                         BLOCK_VERTICES_FAR, BLOCK_VERTICES_TOP, BLOCK_VERTICES_BOTTOM,
                                         get_vertices, MCTextureSlice, simple_block;
}


mixin template BlockBuilder() {
    void add_vertex(float x, float y, float z,
                    float nx, float ny, float nz,
                    ubyte u_terrain, ubyte v_terrain,
                    ubyte u_mask, ubyte v_mask,
                    float u_biome, float v_biome)
        in { assert(elements+1 <= buffer.length, "not enough allocated memory for tessellator"); }
        body {
            buffer.ptr[elements..(elements+=4)] = (cast(void*)&x)[0..4];
            buffer.ptr[elements..(elements+=4)] = (cast(void*)&y)[0..4];
            buffer.ptr[elements..(elements+=4)] = (cast(void*)&z)[0..4];
            buffer.ptr[elements..(elements+=4)] = (cast(void*)&nx)[0..4];
            buffer.ptr[elements..(elements+=4)] = (cast(void*)&ny)[0..4];
            buffer.ptr[elements..(elements+=4)] = (cast(void*)&nz)[0..4];
            buffer.ptr[elements..(elements+=1)] = (cast(void*)&u_terrain)[0..1];
            buffer.ptr[elements..(elements+=1)] = (cast(void*)&v_terrain)[0..1];
            buffer.ptr[elements..(elements+=1)] = (cast(void*)&u_mask)[0..1];
            buffer.ptr[elements..(elements+=1)] = (cast(void*)&v_mask)[0..1];
            buffer.ptr[elements..(elements+=4)] = (cast(void*)&u_biome)[0..4];
            buffer.ptr[elements..(elements+=4)] = (cast(void*)&v_biome)[0..4];
        }

    void add_template_vertices(T : Vertex)(const auto ref T[] vertices,
                               float x_offset, float y_offset, float z_offset,
                               float u_biome, float v_biome)
        in { assert(elements+vertices.length <= buffer.length, "not enough allocated memory for tessellator"); }
        body {
            size_t end = elements + vertices.length*Vertex.sizeof;
            
            buffer.ptr[elements..end] = cast(void[])vertices;
            
            for(; elements < end; elements += Vertex.sizeof) {
                Vertex* vertex = cast(Vertex*)&((buffer.ptr)[elements]);
                vertex.x += x_offset;
                vertex.y += y_offset;
                vertex.z += z_offset;
                vertex.u_biome = u_biome;
                vertex.v_biome = v_biome;
            }
        }

    void add_vertices(T : Vertex)(const auto ref T[] vertices)
        in { assert(elements+vertices.length <= buffer.length, "not enough allocated memory for tesselator"); }
        body {
            buffer.ptr[elements..(elements += vertices.length*Vertex.sizeof)] = cast(void[])vertices;
        }

    // blocks
    void grass_block(Side s)(const ref Block block, const ref BiomeData biome_data,
                             float x_offset, float y_offset, float z_offset) {
        Vertex[] vertices = get_vertices!(s)(block.id);

        add_template_vertices(vertices, x_offset, y_offset, z_offset,
                              biome_data.grass_uv.field);
    }

    void plank_block(Side s)(const ref Block block, const ref BiomeData biome_data,
                             float x_offset, float y_offset, float z_offset) {
        static string plank_vertices(string x, string y) {
            return `enum tex = MCTextureSlice(` ~ x ~ `, ` ~ y ~ `);
                    static if(s == Side.TOP) {
                        enum vertices = simple_block(s, tex.texcoords_90);
                    } else {
                        enum vertices = simple_block(s, tex.texcoords);
                    }
                    add_template_vertices(vertices, x_offset, y_offset, z_offset, 0, 0);`;
        }
        
        final switch(block.metadata & 0x3) {
            case 0: mixin(plank_vertices("4", "1")); break; // oak
            case 1: mixin(plank_vertices("6", "13")); break; // spruce
            case 2: mixin(plank_vertices("6", "14")); break; // birch
            case 3: mixin(plank_vertices("7", "13")); break; // jungle
        }
    }

    void wood_block(Side s)(const ref Block block, const ref BiomeData biome_data,
                            float x_offset, float y_offset, float z_offset) {

        if(block.metadata == 0) {
            tessellate_simple_block!(s)(block, biome_data, x_offset, y_offset, z_offset);
        }

        enum set_tex = ```
        final switch(block.metadata & 0x3) {
            case 0: tex = MCTextureSlice(4, 2); break; // oak
            case 1: tex = MCTextureSlice(4, 8); break; // spruce
            case 2: tex = MCTextureSlice(5, 8); break; // birch
            case 3: tex = MCTextureSlice(9, 10); break; // jungle
        }
        ```;
        
        MCTextureSlice tex;
        byte[2][4] texcoords;
        // TODO: rewrite it/think of something better, I don't like it
        static if(s == Side.NEAR || s == Side.FAR) { // south and north
            if((block.metadata & 0xc) == 0) {
                mixin(set_tex);
                texcoords = tex.texcoords;
            } else if(block.metadata & 0x4) {
                mixin(set_tex);
                texcoords = tex.texcoords_90;
            } else { // it is 0x8
                texcoords = MCTextureSlice(5, 2).texcoords;
            }
        } else static if(s == Side.LEFT || s == Side.RIGHT) { // west and east
            if((block.metadata & 0xc) == 0) {
                mixin(set_tex);
                texcoords = tex.texcoords;
            } else if(block.metadata & 0x8) {
                mixin(set_tex);
                texcoords = tex.texcoords_90;
            } else { // it is 0x4
                texcoords = MCTextureSlice(5, 2).texcoords;
            }
        } else static if(s == Side.TOP || s == Side.BOTTOM) {
            if(block.metadata & 0x4) {
                mixin(set_tex);
                texcoords = tex.texcoords;
            } else if(block.metadata & 0x8) {
                mixin(set_tex);
                texcoords = tex.texcoords_90;
            } else { // it is 0x0
                texcoords = MCTextureSlice(5, 2).texcoords;
            }
        } else {
            static assert(false, "use single_side string-mixin gen for wood_block.");
        }

        // TODO: find out if memoize speeds things up, since this is not an expensive computation
        auto sb = memoize!(simple_block, 16)(s, texcoords);
        add_template_vertices(sb, x_offset, y_offset, z_offset, 0, 0);
    }
        
    void leave_block(Side s)(const ref Block block, const ref BiomeData biome_data,
                             float x_offset, float y_offset, float z_offset) {
        Vertex[] vertices = get_vertices!(s)(block.id);

        add_template_vertices(vertices, x_offset, y_offset, z_offset,
                              biome_data.leave_uv.field);
    }

    void dispatch(Side side)(const ref Block block, const ref BiomeData biome_data,
                             float x_offset, float y_offset, float z_offset) {
        switch(block.id) {
            case 2: mixin(single_side("grass_block")); break; // grass
            case 5: mixin(single_side("plank_block")); break; // planks
            case 17: mixin(single_side("wood_block")); break; // wood
            case 18: mixin(single_side("leave_block")); break; // leaves
            default: tessellate_simple_block!(side)(block, biome_data, x_offset, y_offset, z_offset);
        }
    }

    void tessellate_simple_block(Side side)(const ref Block block, const ref BiomeData biome_data,
                                            float x_offset, float y_offset, float z_offset) {
        static if(side == Side.LEFT) {
            add_template_vertices(BLOCK_VERTICES_LEFT[block.id], x_offset, y_offset, z_offset, 0, 0);
        } else static if(side == Side.RIGHT) {
            add_template_vertices(BLOCK_VERTICES_RIGHT[block.id], x_offset, y_offset, z_offset, 0, 0);
        } else static if(side == Side.NEAR) {
            add_template_vertices(BLOCK_VERTICES_NEAR[block.id], x_offset, y_offset, z_offset, 0, 0);
        } else static if(side == Side.FAR) {
            add_template_vertices(BLOCK_VERTICES_FAR[block.id], x_offset, y_offset, z_offset, 0, 0);
        } else static if(side == Side.TOP) {
            add_template_vertices(BLOCK_VERTICES_TOP[block.id], x_offset, y_offset, z_offset, 0, 0);
        } else static if(side == Side.BOTTOM) {
            add_template_vertices(BLOCK_VERTICES_BOTTOM[block.id], x_offset, y_offset, z_offset, 0, 0);
        } else static if(side == Side.ALL) {
            tessellate_simple_block!(Side.LEFT)(block, biome_data, x_offset, y_offset, z_offset);
            tessellate_simple_block!(Side.RIGHT)(block, biome_data, x_offset, y_offset, z_offset);
            tessellate_simple_block!(Side.NEAR)(block, biome_data, x_offset, y_offset, z_offset);
            tessellate_simple_block!(Side.FAR)(block, biome_data, x_offset, y_offset, z_offset);
            tessellate_simple_block!(Side.TOP)(block, biome_data, x_offset, y_offset, z_offset);
            tessellate_simple_block!(Side.BOTTOM)(block, biome_data, x_offset, y_offset, z_offset);
        }
    }
}

string single_side(string cmd) {
    return 
    `static if(side == Side.ALL) {` ~
        cmd ~ `!(Side.LEFT)(block, biome_data, x_offset, y_offset, z_offset);` ~
        cmd ~ `!(Side.RIGHT)(block, biome_data, x_offset, y_offset, z_offset);` ~
        cmd ~ `!(Side.NEAR)(block, biome_data, x_offset, y_offset, z_offset);` ~
        cmd ~ `!(Side.FAR)(block, biome_data, x_offset, y_offset, z_offset);` ~
        cmd ~ `!(Side.TOP)(block, biome_data, x_offset, y_offset, z_offset);` ~
        cmd ~ `!(Side.BOTTOM)(block, biome_data, x_offset, y_offset, z_offset);` ~
    `} else {` ~
        cmd ~ `!(side)(block, biome_data, x_offset, y_offset, z_offset);` ~
    `}`;
}