module brala.dine.builder.builder;

private {
    import brala.dine.chunk : Block;
    import brala.dine.builder.tessellator : Vertex;
    import brala.dine.builder.constants : Side, Facing;
}

public {
    import std.array : array, join;
    import std.algorithm : map;
    import std.functional : memoize;
    import std.typetuple : TypeTuple;
    
    import brala.dine.builder.biomes : BiomeData, Color4;
    import brala.dine.builder.vertices /+: BLOCK_VERTICES_LEFT, BLOCK_VERTICES_RIGHT, BLOCK_VERTICES_NEAR,
                                         BLOCK_VERTICES_FAR, BLOCK_VERTICES_TOP, BLOCK_VERTICES_BOTTOM,
                                         get_vertices, TextureSlice, SlabTextureSlice, ProjTextureSlice,
                                         simple_block, simple_slab, simple_stair, simple_plant, side_stem,
                                         simple_food_plant+/;
}


protected {
    template WoolPair(byte xi, byte yi) {
        enum x = xi;
        enum y = yi;
    }
}

mixin template BlockBuilder() {
    void add_template_vertices(T : Vertex)(const auto ref T[] vertices,
                               const ref Block block,
                               float x_offset, float y_offset, float z_offset,
                               ubyte r=0xff, ubyte g=0xff, ubyte b=0xff, ubyte a=0xff)
        in { assert(elements+vertices.length <= buffer.length, "not enough allocated memory for tessellator"); }
        body {
            size_t end = elements + vertices.length*Vertex.sizeof;
            
            buffer.ptr[elements..end] = cast(void[])vertices;
            
            for(; elements < end; elements += Vertex.sizeof) {
                Vertex* vertex = cast(Vertex*)&((buffer.ptr)[elements]);
                vertex.x += x_offset;
                vertex.y += y_offset;
                vertex.z += z_offset;
                vertex.r = r;
                vertex.g = g;
                vertex.b = b;
                vertex.a = a;
                vertex.sky_light = block.sky_light;
                vertex.block_light = block.block_light;
            }
        }

    void add_vertices(T : Vertex)(const auto ref T[] vertices)
        in { assert(elements+vertices.length <= buffer.length, "not enough allocated memory for tessellator"); }
        body {
            buffer.ptr[elements..(elements += vertices.length*Vertex.sizeof)] = cast(void[])vertices;
        }

    // blocks
    void grass_block(Side s)(const ref Block block, const ref BiomeData biome_data,
                             float x_offset, float y_offset, float z_offset) {
        Vertex[] vertices = get_vertices!(s)(block.id);

        add_template_vertices(vertices, block, x_offset, y_offset, z_offset, biome_data.color.grass.field);
    }

    void plank_block(Side s)(const ref Block block, const ref BiomeData biome_data,
                             float x_offset, float y_offset, float z_offset) {       
        final switch(block.metadata & 0x3) {
            case 0: mixin(add_block_enum_vertices("4", "1")); break; // oak
            case 1: mixin(add_block_enum_vertices("6", "13")); break; // spruce
            case 2: mixin(add_block_enum_vertices("6", "14")); break; // birch
            case 3: mixin(add_block_enum_vertices("7", "13")); break; // jungle
        }
    }

    void wood_block(Side s)(const ref Block block, const ref BiomeData biome_data,
                            float x_offset, float y_offset, float z_offset) {

        if(block.metadata == 0) {
            return tessellate_simple_block!(s)(block, biome_data, x_offset, y_offset, z_offset);
        }

        enum set_tex = ```
        final switch(block.metadata & 0x3) {
            case 0: tex = TextureSlice(4, 2); break; // oak
            case 1: tex = TextureSlice(4, 8); break; // spruce
            case 2: tex = TextureSlice(5, 8); break; // birch
            case 3: tex = TextureSlice(9, 10); break; // jungle
        }
        ```;
        
        TextureSlice tex;
        short[2][4] texcoords;
        // TODO: rewrite it/think of something better, I don't like it
        static if(s == Side.NEAR || s == Side.FAR) { // south and north
            if((block.metadata & 0xc) == 0) {
                mixin(set_tex);
                texcoords = tex.texcoords;
            } else if(block.metadata & 0x4) {
                mixin(set_tex);
                texcoords = tex.texcoords_90;
            } else { // it is 0x8
                texcoords = TextureSlice(5, 2).texcoords;
            }
        } else static if(s == Side.LEFT || s == Side.RIGHT) { // west and east
            if((block.metadata & 0xc) == 0) {
                mixin(set_tex);
                texcoords = tex.texcoords;
            } else if(block.metadata & 0x8) {
                mixin(set_tex);
                texcoords = tex.texcoords_90;
            } else { // it is 0x4
                texcoords = TextureSlice(5, 2).texcoords;
            }
        } else static if(s == Side.TOP || s == Side.BOTTOM) {
            if(block.metadata & 0x4) {
                mixin(set_tex);
                texcoords = tex.texcoords_90;
            } else if(block.metadata & 0x8) {
                mixin(set_tex);
                texcoords = tex.texcoords;
            } else { // it is 0x0
                texcoords = TextureSlice(5, 2).texcoords;
            }
        } else {
            static assert(false, "use single_side string-mixin gen for wood_block.");
        }
        
        auto sb = memoize!(simple_block, 16)(s, texcoords); // memoize is faster!
        add_template_vertices(sb, block, x_offset, y_offset, z_offset);
    }
        
    void leave_block(Side s)(const ref Block block, const ref BiomeData biome_data,
                             float x_offset, float y_offset, float z_offset) {

        final switch(block.metadata & 0x03) {
            case 0: enum vertices = simple_block(s, TextureSlice(5, 4)); // oak
                    add_template_vertices(vertices, block, x_offset, y_offset, z_offset, biome_data.color.leave.field); break;
            case 1: enum vertices = simple_block(s, TextureSlice(5, 9)); // spruce
                    add_template_vertices(vertices, block, x_offset, y_offset, z_offset, biome_data.color.leave.field); break;
            case 2: enum vertices = simple_block(s, TextureSlice(5, 4)); // birch, uses oak texture
                    // birch trees have a different biome color?
                    add_template_vertices(vertices, block, x_offset, y_offset, z_offset, biome_data.color.leave.field); break;
            case 3: enum vertices = simple_block(s, TextureSlice(5, 13)); // jungle
                    add_template_vertices(vertices, block, x_offset, y_offset, z_offset, biome_data.color.leave.field); break;
        }
    }

    void sandstone_block(Side s)(const ref Block block, const ref BiomeData biome_data,
                                 float x_offset, float y_offset, float z_offset) {
        if(block.metadata == 0) {
            return tessellate_simple_block!(s)(block, biome_data, x_offset, y_offset, z_offset);
        }

        static if(s == Side.TOP) {
            mixin(add_block_enum_vertices("0", "12"));
        } else static if(s == Side.BOTTOM) {
            mixin(add_block_enum_vertices("0", "14"));
        } else {
            if(block.metadata == 0x1) { // chiseled
                mixin(add_block_enum_vertices("5", "15"));
            } else { // smooth
                mixin(add_block_enum_vertices("6", "15"));
            }
        }
    }

    void wool_block(Side s)(const ref Block block, const ref BiomeData biome_data,
                            float x_offset, float y_offset, float z_offset) {
        static string wool_vertices() {
                    // no enum possible due to CTFE bug?
            return `auto vertices = memoize!(simple_block, 16)(s, TextureSlice(slice.x, slice.y).texcoords);
                    add_template_vertices(vertices, block, x_offset, y_offset, z_offset);`;
        }

        alias WoolPair t;
        final switch(block.metadata) {                                                     
            foreach(i, slice; TypeTuple!(t!(0, 5),  t!(2, 14), t!(2, 13), t!(2, 12), t!(2, 11), t!(2, 10), t!(2, 9), t!(2, 8),
                                         t!(1, 15), t!(1, 14), t!(1, 13), t!(1, 12), t!(1, 11), t!(1, 10), t!(1, 9), t!(1, 8))) {
                case i: mixin(wool_vertices()); break;
            }
        }
    }

    void stone_double_slab(Side s)(const ref Block block, const ref BiomeData biome_data,
                                   float x_offset, float y_offset, float z_offset) {
        final switch(block.metadata & 0x7) {
            case 0: tessellate_simple_block!(s)(block, biome_data, x_offset, y_offset, z_offset); break;
            case 1: Block sandstone = Block(24); // sandstone
                    tessellate_simple_block!(s)(sandstone, biome_data, x_offset, y_offset, z_offset); break;
            case 2: mixin(add_block_enum_vertices("4", "1")); break; // wooden stone
            case 3: mixin(add_block_enum_vertices("0", "2")); break; // cobblestone
            case 4: mixin(add_block_enum_vertices("7", "1")); break; // brick
            case 5: mixin(add_block_enum_vertices("6", "4")); break; // stone brick
        }
    }

    void stone_slab(Side s)(const ref Block block, const ref BiomeData biome_data,
                             float x_offset, float y_offset, float z_offset) {
        bool upside_down = (block.metadata & 0x8) != 0;

        static if(s == Side.TOP) {
            if((block.metadata & 0x7) == 0) { // stone
                mixin(add_slab_enum_vertices(s, "6", "1"));
                return;
            } else if((block.metadata & 0x7) == 1) { // sandstone
                mixin(add_slab_enum_vertices(s, "0", "12"));
                return;
            }
        } else static if(s == Side.BOTTOM) {
            if((block.metadata & 0x7) == 0) { // stone
                mixin(add_slab_enum_vertices(s, "6", "1"));
                return;
            } else if((block.metadata & 0x7) == 1) { // sandstone
                mixin(add_slab_enum_vertices(s, "0", "14"));
                return;
            }
        }

        final switch(block.metadata & 0x7) {
            case 0: mixin(add_slab_enum_vertices(s, "5", "1")); break; // stone
            case 1: mixin(add_slab_enum_vertices(s, "0", "13")); break; // sandstone
            case 2: mixin(add_slab_enum_vertices(s, "4", "1")); break; // wooden stone
            case 3: mixin(add_slab_enum_vertices(s, "0", "2")); break; // cobblestone
            case 4: mixin(add_slab_enum_vertices(s, "7", "1")); break; // brick
            case 5: mixin(add_slab_enum_vertices(s, "6", "4")); break; // stone brick
        }
    }

    void stonebrick_block(Side s)(const ref Block block, const ref BiomeData biome_data,
                                  float x_offset, float y_offset, float z_offset) {
        final switch(block.metadata & 0x3) {
            case 0: mixin(add_block_enum_vertices("6", "4")); break; // normal
            case 1: mixin(add_block_enum_vertices("4", "7")); break; // mossy
            case 2: mixin(add_block_enum_vertices("5", "7")); break; // cracked
            case 3: mixin(add_block_enum_vertices("5", "14")); break; // chiseled
        }
    }

    void wooden_double_slab(Side s)(const ref Block block, const ref BiomeData biome_data,
                                    float x_offset, float y_offset, float z_offset) {
        final switch(block.metadata & 0x3) {
            case 0: mixin(add_block_enum_vertices("4", "1")); break; // oak
            case 1: mixin(add_block_enum_vertices("6", "13")); break; // spruce
            case 2: mixin(add_block_enum_vertices("6", "14")); break; // birch
            case 3: mixin(add_block_enum_vertices("7", "13")); break; // jungle
        }
    }

    void wooden_slab(Side s)(const ref Block block, const ref BiomeData biome_data,
                             float x_offset, float y_offset, float z_offset) {
        bool upside_down = (block.metadata & 0x8) != 0;
        final switch(block.metadata & 0x3) {
            case 0: mixin(add_slab_enum_vertices(s, "4", "1")); break; // oak
            case 1: mixin(add_slab_enum_vertices(s, "6", "13")); break; // spruce
            case 2: mixin(add_slab_enum_vertices(s, "6", "14")); break; // birch
            case 3: mixin(add_slab_enum_vertices(s, "7", "13")); break; // jungle
        }
    }

    void stair(Side s)(const ref Block block, ProjTextureSlice tex, const ref BiomeData biome_data,
                       float x_offset, float y_offset, float z_offset) {
        enum fs = [Facing.WEST, Facing.EAST, Facing.NORTH, Facing.SOUTH];

        Facing f = fs[block.metadata & 0x3];
        bool upside_down = (block.metadata & 0x4) != 0;

        add_template_vertices(memoize!(simple_stair, 72)(s, f, upside_down, tex), block, x_offset, y_offset, z_offset);
    }

    void wheat(Side s)(const ref Block block, const ref BiomeData biome_data,
                       float x_offset, float y_offset, float z_offset) {
        byte x = cast(byte)8;

        x += block.metadata & 0x7;
        //y_offset -= 0.0625f; // 1/16.0

        add_template_vertices(simple_food_plant(TextureSlice(x, 6)), block, x_offset, y_offset, z_offset);
    }

    void farmland(Side s)(const ref Block block, const ref BiomeData biome_data,
                          float x_offset, float y_offset, float z_offset) {
        static if(s == Side.TOP) {
            if(block.metadata == 0) { // dry
                enum fb = farmland_block(s, ProjTextureSlice(7, 6));
                add_template_vertices(fb, block, x_offset, y_offset, z_offset);
            } else { // wet
                enum fb = farmland_block(s, ProjTextureSlice(6, 6));
                add_template_vertices(fb, block, x_offset, y_offset, z_offset);
            }
        } else {
            enum fb = farmland_block(s, ProjTextureSlice(2, 1));
            add_template_vertices(fb, block, x_offset, y_offset, z_offset);
        }
    }

    void furnace(Side s, string tex = "TextureSlice(12, 3)")(const ref Block block, const ref BiomeData biome_data,
                                                                 float x_offset, float y_offset, float z_offset) {
        enum fs = [Facing.WEST, Facing.EAST, Facing.NORTH, Facing.SOUTH];

        Facing f = fs[block.metadata & 0x3];

        if(cast(Side)f == s) { // special side
            add_template_vertices(simple_block(s, mixin(tex)), block, x_offset, y_offset, z_offset);
        } else {
            tessellate_simple_block!(s)(block, biome_data, x_offset, y_offset, z_offset);
        }
    }

    void burning_furnace(Side s)(const ref Block block, const ref BiomeData biome_data,
                                 float x_offset, float y_offset, float z_offset) {
        furnace!(s, "TextureSlice(13, 4)")(block, biome_data, x_offset, y_offset, z_offset);
    }

    void dispenser(Side s)(const ref Block block, const ref BiomeData biome_data,
                           float x_offset, float y_offset, float z_offset) {
        furnace!(s, "TextureSlice(14, 3)")(block, biome_data, x_offset, y_offset, z_offset);
    }

    void pumpkin(Side s, bool is_jako = false)(const ref Block block, const ref BiomeData biome_data,
                         float x_offset, float y_offset, float z_offset) {
        enum fs = [Facing.SOUTH, Facing.WEST, Facing.NORTH, Facing.EAST];

        Facing f = fs[block.metadata & 0x3];

        static if(s == Side.TOP) {
            add_template_vertices(simple_block(s, TextureSlice(6, 7), f), block, x_offset, y_offset, z_offset);
        } else {
            if(cast(Side)f == s) { // side with the face
                static if(is_jako) { // it's a jako lantern
                    add_template_vertices(simple_block(s, TextureSlice(8, 8)), block, x_offset, y_offset, z_offset);
                } else {
                    add_template_vertices(simple_block(s, TextureSlice(7, 8)), block, x_offset, y_offset, z_offset);
                }
            } else {
                tessellate_simple_block!(s)(block, biome_data, x_offset, y_offset, z_offset);
            }
        }
    }

    void jack_o_lantern(Side s)(const ref Block block, const ref BiomeData biome_data,
                                float x_offset, float y_offset, float z_offset) {
        pumpkin!(s, true)(block, biome_data, x_offset, y_offset, z_offset);
    }

    void plant(Side s)(const ref Block block, short[2][4] tex, const ref BiomeData biome_data,
                       float x_offset, float y_offset, float z_offset) {
        add_template_vertices(simple_plant(tex), block, x_offset, y_offset, z_offset);
    }

    void saplings(Side s)(const ref Block block, const ref BiomeData biome_data,
                          float x_offset, float y_offset, float z_offset) {
        short[2][4] tex;

        final switch(block.metadata & 0x3) {
            case 0: tex = TextureSlice(15, 1); break;
            case 1: tex = TextureSlice(15, 4); break;
            case 2: tex = TextureSlice(15, 5); break;
            case 3: tex = TextureSlice(14, 2); break;
        }

        add_template_vertices(simple_plant(tex), block, x_offset, y_offset, z_offset);
    }

    void tall_grass(Side s)(const ref Block block, const ref BiomeData biome_data,
                            float x_offset, float y_offset, float z_offset) {
        short[2][4] tex;
        Color4 color = Color4(cast(ubyte)0xff, cast(ubyte)0xff, cast(ubyte)0xff, cast(ubyte)0xff);

        final switch(block.metadata & 0x3) {
            case 0: tex = TextureSlice(7, 4); break;
            case 1: tex = TextureSlice(7, 3); color = biome_data.color.grass; break;
            case 2: tex = TextureSlice(8, 4); color = biome_data.color.grass; break;
            case 3: tex = TextureSlice(7, 3); color = biome_data.color.grass; break;
        }

        add_template_vertices(simple_plant(tex), block, x_offset, y_offset, z_offset, color.field);
    }

    void stem(Side s)(const ref Block block, const ref BiomeData biome_data,
                      vec3i world_coords, float x_offset, float y_offset, float z_offset) {

        enum stem = TextureSlice(15, 7);
        Color4 color = Color4(cast(ubyte)0x0, cast(ubyte)0xad, cast(ubyte)0x17, cast(ubyte)0xff);

        enum stem2 = TextureSlice(15, 8);
        bool render_stem2 = false;
        
        int id = 86; // pumpkin
        if(block.id == 105) {
            id = 103; // melon
        }

        Facing face = Facing.SOUTH;

        if((block.metadata & 0x7) == 0x7) { // fully grown
            color = Color4(cast(ubyte)0x8a, cast(ubyte)0x77, cast(ubyte)0x11, cast(ubyte)0xff);

            if(world.get_block_safe(vec3i(world_coords.x+1, world_coords.y, world_coords.z)).id == id) {
                face = Facing.EAST; render_stem2 = true;
            } else if(world.get_block_safe(vec3i(world_coords.x-1, world_coords.y, world_coords.z)).id == id) {
                face = Facing.WEST; render_stem2 = true;
            } else if(world.get_block_safe(vec3i(world_coords.x, world_coords.y, world_coords.z+1)).id == id) {
                face = Facing.SOUTH; render_stem2 = true;
            } else if(world.get_block_safe(vec3i(world_coords.x, world_coords.y, world_coords.z-1)).id == id) {
                face = Facing.NORTH; render_stem2 = true;
            }
        }

        if(render_stem2) {
            add_template_vertices(side_stem(face, stem2), block, x_offset, y_offset, z_offset, color.field);
            y_offset -= 0.4f;
        }

        y_offset -= 0.1f;
        y_offset -= (7-block.metadata)/10.0f;

        add_template_vertices(simple_plant(stem, face), block, x_offset, y_offset, z_offset, color.field);
    }

    void nether_wart(Side s)(const ref Block block, const ref BiomeData biome_data,
                             float x_offset, float y_offset, float z_offset) {
        enum stages = [0, 1, 1, 2];

        byte x = cast(byte)(2 + stages[block.metadata & 0x3]);

        return add_template_vertices(simple_food_plant(TextureSlice(x, 15)), block, x_offset, y_offset, z_offset);
    }

    void rail(Side s)(const ref Block block, float x_offset, float y_offset, float z_offset) {
        short[2][4] tex = TextureSlice(0, 9);
        
        if(block.metadata < 2) {
            enum fs = [Facing.SOUTH, Facing.WEST];

            add_template_vertices(simple_rail(tex, fs[block.metadata]), block, x_offset, y_offset, z_offset);
        } else if(block.metadata < 6) {
            enum fs = [Facing.EAST, Facing.WEST, Facing.NORTH, Facing.SOUTH];

            add_template_vertices(simple_ascending_rail(tex, fs[block.metadata-2]), block, x_offset, y_offset, z_offset);
        } else { // curved
            enum fs = [Facing.SOUTH, Facing.WEST, Facing.NORTH, Facing.EAST];
            tex = TextureSlice(0, 8);

            add_template_vertices(simple_rail(tex, fs[block.metadata-6]), block, x_offset, y_offset, z_offset);
        }

    }

    void special_rail(Side s)(const ref Block block, float x_offset, float y_offset, float z_offset) {
        short[2][4] tex = TextureSlice(3, 13);

        if(block.id == 27) { // powered rail
            if(block.metadata & 0x8) { // powered
                tex = TextureSlice(3, 12);
            } else {
                tex = TextureSlice(3, 11);
            }
        }

        final switch(block.metadata & 0x07) {
            case 0: add_template_vertices(simple_rail(tex, Facing.SOUTH), block, x_offset, y_offset, z_offset); break;
            case 1: add_template_vertices(simple_rail(tex, Facing.WEST), block, x_offset, y_offset, z_offset); break;
            case 2: add_template_vertices(simple_ascending_rail(tex, Facing.EAST), block, x_offset, y_offset, z_offset); break;
            case 3: add_template_vertices(simple_ascending_rail(tex, Facing.WEST), block, x_offset, y_offset, z_offset); break;
            case 4: add_template_vertices(simple_ascending_rail(tex, Facing.NORTH), block, x_offset, y_offset, z_offset); break;
            case 5: add_template_vertices(simple_ascending_rail(tex, Facing.SOUTH), block, x_offset, y_offset, z_offset); break;
        }
    }

    void ladder(Side s)(const ref Block block, float x_offset, float y_offset, float z_offset) {
        enum fs = [Facing.WEST, Facing.EAST, Facing.NORTH, Facing.SOUTH];

        add_template_vertices(simple_ladder(TextureSlice(3, 6), fs[block.metadata & 0x3]), block, x_offset, y_offset, z_offset);
    }

    void vines(Side s)(const ref Block block, const ref BiomeData biome_data, vec3i world_coords,
                       float x_offset, float y_offset, float z_offset) {
        enum fs = [Facing.NORTH, Facing.EAST, Facing.SOUTH, Facing.WEST];

        foreach(shift; 0..4) {
            if(block.metadata & (1 << shift)) {
                add_template_vertices(simple_vine(TextureSlice(15, 9), fs[shift]), block,
                                      x_offset, y_offset, z_offset, biome_data.color.grass.field);
            }
        }

        if(block.metadata == 0 || BLOCKS[world.get_block_safe(vec3i(world_coords.x, world_coords.y+1, world_coords.z)).id].opaque) {
            add_template_vertices(top_vine(TextureSlice(15, 9)), block, x_offset, y_offset, z_offset, biome_data.color.grass.field);
        }
    }
    

    void dispatch(Side side)(const ref Block block, const ref BiomeData biome_data,
                             vec3i world_coords, float x_offset, float y_offset, float z_offset) {
        switch(block.id) {
            case 2: mixin(single_side("grass_block")); break; // grass
            case 5: mixin(single_side("plank_block")); break; // planks
            case 6: dispatch_once!(saplings, side)(block, biome_data, x_offset, y_offset, z_offset); break; // saplings
            case 17: mixin(single_side("wood_block")); break; // wood
            case 18: mixin(single_side("leave_block")); break; // leaves
            case 23: mixin(single_side("dispenser")); break; // dispenser
            case 24: mixin(single_side("sandstone_block")); break; // sandstone
            case 27: dispatch_once!(special_rail, side)(block, x_offset, y_offset, z_offset); break; // powered rail
            case 28: dispatch_once!(special_rail, side)(block, x_offset, y_offset, z_offset); break; // detector rail
            case 30: dispatch_once!(plant, side)(block, TextureSlice(11, 1), // cobweb
                     biome_data, x_offset, y_offset, z_offset); break;
            case 31: dispatch_once!(tall_grass, side)(block, biome_data, x_offset, y_offset, z_offset); break; // tall grass
            case 35: mixin(single_side("wool_block")); break; // wool
            case 37: dispatch_once!(plant, side)(block, TextureSlice(13, 1), // dandelion
                     biome_data, x_offset, y_offset, z_offset); break;
            case 38: dispatch_once!(plant, side)(block, TextureSlice(12, 1), // rose
                     biome_data, x_offset, y_offset, z_offset); break;
            case 39: dispatch_once!(plant, side)(block, TextureSlice(13, 2), // brown mushroom
                     biome_data, x_offset, y_offset, z_offset); break;
            case 40: dispatch_once!(plant, side)(block, TextureSlice(12, 2), // red mushroom
                     biome_data, x_offset, y_offset, z_offset); break;
            case 43: mixin(single_side("stone_double_slab")); break; // stone double slaps
            case 44: mixin(single_side("stone_slab")); break; // stone slabs - stone, sandstone, wooden stone, cobblestone, brick, stone brick
            case 53: dispatch_single_side!(stair, side)(block, ProjTextureSlice(4, 1, 4, 1), // oak wood stair
                     biome_data, x_offset, y_offset, z_offset); break;
            case 59: dispatch_once!(wheat, side)(block, biome_data, x_offset, y_offset, z_offset); break; // wheat
            case 60: mixin(single_side("farmland")); break; // farmland
            case 61: mixin(single_side("furnace")); break; // furnace
            case 62: mixin(single_side("burning_furnace")); break; // burning furnace
            case 65: dispatch_once!(ladder, side)(block, x_offset, y_offset, z_offset); break; // ladder
            case 66: dispatch_once!(rail, side)(block, x_offset, y_offset, z_offset); break; // rail
            case 67: dispatch_single_side!(stair, side)(block, ProjTextureSlice(0, 2, 0, 2), // cobblestone stair
                     biome_data, x_offset, y_offset, z_offset); break;
            case 83: dispatch_once!(plant, side)(block, TextureSlice(9, 5), // reeds
                     biome_data, x_offset, y_offset, z_offset); break;
            case 86: mixin(single_side("pumpkin")); break;
            case 91: mixin(single_side("jack_o_lantern")); break;
            case 98: mixin(single_side("stonebrick_block")); break; // stone brick
            case 104: dispatch_once!(stem, side)(block, biome_data, world_coords, x_offset, y_offset, z_offset); break; // pumpkin stem
            case 105: dispatch_once!(stem, side)(block, biome_data, world_coords, x_offset, y_offset, z_offset); break; // melon stem
            case 106: dispatch_once!(vines, side)(block, biome_data, world_coords, x_offset, y_offset, z_offset); break; // vines
            case 108: dispatch_single_side!(stair, side)(block, ProjTextureSlice(7, 1, 7, 1), // brick stair
                      biome_data, x_offset, y_offset, z_offset); break;
            case 109: dispatch_single_side!(stair, side)(block, ProjTextureSlice(6, 4, 6, 4), // stone brick stair
                      biome_data, x_offset, y_offset, z_offset); break;
            case 114: dispatch_single_side!(stair, side)(block, ProjTextureSlice(0, 15, 0, 15), // nether brick stair
                      biome_data, x_offset, y_offset, z_offset); break;
            case 115: dispatch_once!(nether_wart, side)(block, biome_data, x_offset, y_offset, z_offset); break; // nether wart
            case 125: mixin(single_side("wooden_double_slab")); break; // wooden double slab
            case 126: mixin(single_side("wooden_slab")); break; // wooden slab
            case 128: dispatch_single_side!(stair, side)(block, ProjTextureSlice(0, 13, 0, 12, 0, 14), // sandstone stair
                      biome_data, x_offset, y_offset, z_offset); break;
            case 134: dispatch_single_side!(stair, side)(block, ProjTextureSlice(6, 13, 6, 13), // spruce wood stair
                      biome_data, x_offset, y_offset, z_offset); break;
            case 135: dispatch_single_side!(stair, side)(block, ProjTextureSlice(6, 14, 6, 14), // birch wood stair
                      biome_data, x_offset, y_offset, z_offset); break;
            case 136: dispatch_single_side!(stair, side)(block, ProjTextureSlice(7, 13, 7, 13), // jungle wood stair
                      biome_data, x_offset, y_offset, z_offset); break;
            default: tessellate_simple_block!(side)(block, biome_data, x_offset, y_offset, z_offset);
        }
    }

    void dispatch_single_side(alias func, Side s, Args...)(Args args) {
        static if(s == Side.ALL) {
            func!(Side.LEFT)(args);
            func!(Side.RIGHT)(args);
            func!(Side.NEAR)(args);
            func!(Side.FAR)(args);
            func!(Side.TOP)(args);
            func!(Side.BOTTOM)(args);
        } else {
            func!(s)(args);
        }
    }

    void dispatch_once(alias func, Side s, Args...)(Args args) {
        static if(s == Side.ALL || s == Side.RIGHT) {
            func!(Side.ALL)(args);
        }
    }

    void tessellate_simple_block(Side side)(const ref Block block, const ref BiomeData biome_data,
                                            float x_offset, float y_offset, float z_offset) {
        static if(side == Side.LEFT) {
            add_template_vertices(BLOCK_VERTICES_LEFT[block.id], block, x_offset, y_offset, z_offset);
        } else static if(side == Side.RIGHT) {
            add_template_vertices(BLOCK_VERTICES_RIGHT[block.id], block, x_offset, y_offset, z_offset);
        } else static if(side == Side.NEAR) {
            add_template_vertices(BLOCK_VERTICES_NEAR[block.id], block, x_offset, y_offset, z_offset);
        } else static if(side == Side.FAR) {
            add_template_vertices(BLOCK_VERTICES_FAR[block.id], block, x_offset, y_offset, z_offset);
        } else static if(side == Side.TOP) {
            add_template_vertices(BLOCK_VERTICES_TOP[block.id], block, x_offset, y_offset, z_offset);
        } else static if(side == Side.BOTTOM) {
            add_template_vertices(BLOCK_VERTICES_BOTTOM[block.id], block, x_offset, y_offset, z_offset);
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

static string add_block_enum_vertices(string x, string y) {
    return `enum vertices = simple_block(s, TextureSlice(` ~ x ~ `, ` ~ y ~ `).texcoords);
            add_template_vertices(vertices, block, x_offset, y_offset, z_offset);`;
}

static string add_slab_enum_vertices(Side s, string x, string y) {
    string v;
    if(s == Side.TOP || s == Side.BOTTOM) {
        v = `enum vertices = simple_slab(s, false, TextureSlice(` ~ x ~ `, ` ~ y ~ `).texcoords);
             enum vertices_usd = simple_slab(s, true, TextureSlice(` ~ x ~ `, ` ~ y ~ `).texcoords);`;
    } else {
        v = `enum vertices = simple_slab(s, false, SlabTextureSlice(` ~ x ~ `, ` ~ y ~ `).texcoords);
             enum vertices_usd = simple_slab(s, true, SlabTextureSlice(` ~ x ~ `, ` ~ y ~ `).texcoords);`;
    }
    
    return  v ~ `
            if(upside_down) {
                add_template_vertices(vertices_usd, block, x_offset, y_offset, z_offset);
            } else {
                add_template_vertices(vertices, block, x_offset, y_offset, z_offset);
            }`;
}

string single_side(string func) {
    return 
    `static if(side == Side.ALL) {` ~
        func ~ `!(Side.LEFT)(block, biome_data, x_offset, y_offset, z_offset);` ~
        func ~ `!(Side.RIGHT)(block, biome_data, x_offset, y_offset, z_offset);` ~
        func ~ `!(Side.NEAR)(block, biome_data, x_offset, y_offset, z_offset);` ~
        func ~ `!(Side.FAR)(block, biome_data, x_offset, y_offset, z_offset);` ~
        func ~ `!(Side.TOP)(block, biome_data, x_offset, y_offset, z_offset);` ~
        func ~ `!(Side.BOTTOM)(block, biome_data, x_offset, y_offset, z_offset);` ~
    `} else {` ~
        func ~ `!(side)(block, biome_data, x_offset, y_offset, z_offset);` ~
    `}`;
}