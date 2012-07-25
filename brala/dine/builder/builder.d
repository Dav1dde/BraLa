module brala.dine.builder.builder;

private {
    import brala.dine.chunk : Block;
    import brala.dine.builder.tessellator : Vertex, Side;
}

public {
    import std.array : array, join;
    import std.algorithm : map;
    
    import brala.dine.builder.biomes : BiomeData, BIOMES;
    import brala.dine.builder.vertices : BLOCK_VERTICES_LEFT, BLOCK_VERTICES_RIGHT, BLOCK_VERTICES_NEAR,
                                         BLOCK_VERTICES_FAR, BLOCK_VERTICES_TOP, BLOCK_VERTICES_BOTTOM,
                                         get_vertices;
}


mixin template BlockBuilder() {
    void add_vertex(float x, float y, float z, float nx, float ny, float nz,
                    float u, float v, float u_biome, float v_biome)
        in { assert(elements+1 <= buffer_length, "not enough allocated memory for tessellator"); }
        body {
            buffer[elements..elements+4] = (cast(void*)&x)[0..4];
            buffer[elements+4..elements+8] = (cast(void*)&y)[0..4];
            buffer[elements+8..elements+12] = (cast(void*)&z)[0..4];
            buffer[elements+12..elements+16] = (cast(void*)&nx)[0..4];
            buffer[elements+16..elements+20] = (cast(void*)&ny)[0..4];
            buffer[elements+20..elements+24] = (cast(void*)&nz)[0..4];
            buffer[elements+24..elements+28] = (cast(void*)&u)[0..4];
            buffer[elements+28..elements+32] = (cast(void*)&v)[0..4];
            buffer[elements+32..elements+36] = (cast(void*)&u_biome)[0..4];
            buffer[elements+36..elements+40] = (cast(void*)&v_biome)[0..4];
            elements += 40;
        }

    void add_template_vertices(const ref Vertex[] vertices,
                               float x_offset, float y_offset, float z_offset,
                               float u_biome, float v_biome)
        in { assert(elements+vertices.length <= buffer_length, "not enough allocated memory for tessellator"); }
        body {
            float[] data;
            foreach(ref Vertex vertex; vertices) {
                data ~= [vertex.x + x_offset, vertex.y + y_offset, vertex.z + z_offset,
                         vertex.nx, vertex.ny, vertex.nz,
                         vertex.u_terrain, vertex.v_terrain, u_biome, v_biome];
            }

            buffer[elements..(elements+(data.length*float.sizeof))] = cast(void[])data;
            elements += data.length*float.sizeof;
            
            //import std.stdio; writeln(vertices);
            //auto vv = cast(void*)vertices.ptr;
            //buffer[elements..(elements+(vertices.length*Vertex.sizeof))] = vv[0..vertices.length*Vertex.sizeof];
            //elements += vertices.length*Vertex.sizeof;
        }

    void add_vertices(const ref Vertex[] vertices)
        in { assert(elements+vertices.length <= buffer_length, "not enough allocated memory for tesselator"); }
        body {
            // TODO
            throw new Exception("not implemented");
        }

    // blocks
    void grass_block(Side s)(const ref Block block, const ref BiomeData biome_data,
                             float x_offset, float y_offset, float z_offset) {
        Vertex[] vertices = get_vertices!(s)(block.id);

        add_template_vertices(vertices, x_offset, y_offset, z_offset,
                              biome_data.grass_uv.field);
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
            case 2: mixin(single_side("grass_block")); break;
            case 18: mixin(single_side("leave_block")); break;
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