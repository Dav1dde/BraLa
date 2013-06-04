module brala.dine.builder.builder;

private {
    import brala.dine.chunk : Block;
    import brala.dine.builder.tessellator : Vertex;
    import brala.dine.builder.constants : Side, Facing;
}

public {
    import std.array : array, join;
    import std.algorithm : map, canFind;
    import std.functional : memoize;
    import std.typetuple : TypeTuple;
    import std.conv : to;

    import brala.gfx.terrain : ProjectionTextureCoordinates;
    import brala.dine.builder.blocks : BLOCKS, BlockDescriptor;
    import brala.dine.builder.biomes : BiomeData, Color4;
    import brala.dine.builder.vertices /+: BLOCK_VERTICES_LEFT, BLOCK_VERTICES_RIGHT, BLOCK_VERTICES_NEAR,
                                         BLOCK_VERTICES_FAR, BLOCK_VERTICES_TOP, BLOCK_VERTICES_BOTTOM,
                                         get_vertices, TextureSlice, SlabTextureSlice, ProjTextureSlice,
                                         simple_block, simple_slab, simple_stair, simple_plant, side_stem,
                                         simple_food_plant+/;
    import brala.utils.ctfe : TupleRange;
}


protected {
    template WoolPair(byte xi, byte yi) {
        enum x = xi;
        enum y = yi;
    }
}

mixin template BlockBuilder() {
    void add_template_vertices(T : Vertex)(const auto ref T[] vertices,
                               const Block block,
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
    void grass_block(Side s)(const Block block, const ref BiomeData biome_data,
                             float x_offset, float y_offset, float z_offset) {
        Vertex[] vertices = atlas.get_vertices!(s)(block.id);

        add_template_vertices(vertices, block, x_offset, y_offset, z_offset, biome_data.color.grass.field);
    }

    void plank_block(Side s)(const Block block, const ref BiomeData biome_data,
                             float x_offset, float y_offset, float z_offset) {       
        final switch(block.metadata & 0x3) {
            case 0: mixin(add_block_vertices("wood")); break; // oak
            case 1: mixin(add_block_vertices("wood_spruce")); break; // spruce
            case 2: mixin(add_block_vertices("wood_birch")); break; // birch
            case 3: mixin(add_block_vertices("wood_jungle")); break; // jungle
        }
    }

    void wood_block(Side s)(const Block block, const ref BiomeData biome_data,
                            float x_offset, float y_offset, float z_offset) {

        if(block.metadata == 0) {
            return tessellate_simple_block!(s)(block, biome_data, x_offset, y_offset, z_offset);
        }

        static string set_tex(string rot) {
            return ```
                final switch(block.metadata & 0x3) {
                    case 0: texcoords = atlas.get!("tree_side", ` ~ rot ~ `)(); break; // oak
                    case 1: texcoords = atlas.get!("tree_spruce", ` ~ rot ~ `)(); break; // spruce
                    case 2: texcoords = atlas.get!("tree_birch", ` ~ rot ~ `)(); break; // birch
                    case 3: texcoords = atlas.get!("tree_jungle", ` ~ rot ~ `)(); break; // jungle
                }```;
        }
        
        short[2][4] texcoords;
        // TODO: rewrite it/think of something better, I don't like it
        static if(s == Side.NEAR || s == Side.FAR) { // south and north
            if((block.metadata & 0xc) == 0) {
                mixin(set_tex("0"));
            } else if(block.metadata & 0x4) {
                mixin(set_tex("90"));
            } else { // it is 0x8
                texcoords = atlas.get!("tree_top");
            }
        } else static if(s == Side.LEFT || s == Side.RIGHT) { // west and east
            if((block.metadata & 0xc) == 0) {
                mixin(set_tex("0"));
            } else if(block.metadata & 0x8) {
                mixin(set_tex("90"));
            } else { // it is 0x4
                texcoords = atlas.get!("tree_top");
            }
        } else static if(s == Side.TOP || s == Side.BOTTOM) {
            if(block.metadata & 0x4) {
                mixin(set_tex("90"));
            } else if(block.metadata & 0x8) {
                mixin(set_tex("0"));
            } else { // it is 0x0
                texcoords = atlas.get!("tree_top");
            }
        } else {
            static assert(false, "use single_side string-mixin gen for wood_block.");
        }
        
        auto sb = memoize!(simple_block, 16)(s, texcoords); // memoize is faster!
        add_template_vertices(sb, block, x_offset, y_offset, z_offset);
    }
        
    void leave_block(Side s)(const Block block, const ref BiomeData biome_data,
                             float x_offset, float y_offset, float z_offset) {

        final switch(block.metadata & 0x03) {
            case 0: auto vertices = simple_block(s, atlas.get!("leaves_opaque")); // oak
                    add_template_vertices(vertices, block, x_offset, y_offset, z_offset, biome_data.color.leave.field); break;
            case 1: auto vertices = simple_block(s, atlas.get!("leaves_spruce_opaque")); // spruce
                    add_template_vertices(vertices, block, x_offset, y_offset, z_offset, biome_data.color.leave.field); break;
            case 2: auto vertices = simple_block(s, atlas.get!("leaves_opaque")); // birch, uses oak texture
                    // birch trees have a different biome color?
                    add_template_vertices(vertices, block, x_offset, y_offset, z_offset, biome_data.color.leave.field); break;
            case 3: auto vertices = simple_block(s, atlas.get!("leaves_jungle_opaque")); // jungle
                    add_template_vertices(vertices, block, x_offset, y_offset, z_offset, biome_data.color.leave.field); break;
        }
    }

    void sandstone_block(Side s)(const Block block, const ref BiomeData biome_data,
                                 float x_offset, float y_offset, float z_offset) {
        if(block.metadata == 0) {
            return tessellate_simple_block!(s)(block, biome_data, x_offset, y_offset, z_offset);
        }

        static if(s == Side.TOP) {
            mixin(add_block_vertices("sandstone_top"));
        } else static if(s == Side.BOTTOM) {
            mixin(add_block_vertices("sandstone_bottom"));
        } else {
            if(block.metadata == 0x1) { // chiseled aka carved
                mixin(add_block_vertices("sandstone_carved"));
            } else { // smooth
                mixin(add_block_vertices("sandstone_smooth"));
            }
        }
    }

    void wool_block(Side s)(const Block block, const ref BiomeData biome_data,
                            float x_offset, float y_offset, float z_offset) {
        static string wool_vertices(string index) {
                    // no enum possible due to CTFE bug?
            return `auto vertices = memoize!(simple_block, 16)(s, atlas.get!("cloth_` ~ index ~ `"));
                    add_template_vertices(vertices, block, x_offset, y_offset, z_offset);`;
        }

        alias WoolPair t;
        final switch(block.metadata) {                                                     
            foreach(i, index; TypeTuple!("0", "1", "2", "3", "4", "5", "6", "7", "8",
                                         "9", "10", "11", "12", "13", "14", "15")) {
                case i: mixin(wool_vertices(index)); break;
            }
        }
    }

    void stone_double_slab(Side s)(const Block block, const ref BiomeData biome_data,
                                   float x_offset, float y_offset, float z_offset) {
        final switch(block.metadata & 0x7) {
            case 0: tessellate_simple_block!(s)(block, biome_data, x_offset, y_offset, z_offset); break;
            case 1: enum sandstone = Block(24); // sandstone
                    tessellate_simple_block!(s)(sandstone, biome_data, x_offset, y_offset, z_offset); break;
            case 2: mixin(add_block_vertices("wood")); break; // wooden stone
            case 3: mixin(add_block_vertices("stonebrick")); break; // cobblestone
            case 4: mixin(add_block_vertices("brick")); break; // brick
            case 5: mixin(add_block_vertices("stonebricksmooth")); break; // stone brick
        }
    }

    void stone_slab(Side s)(const Block block, const ref BiomeData biome_data,
                             float x_offset, float y_offset, float z_offset) {
        bool upside_down = (block.metadata & 0x8) != 0;

        static if(s == Side.TOP) {
            if((block.metadata & 0x7) == 0) { // stone
                mixin(add_slab_vertices(s, "stoneslab_side"));
                return;
            } else if((block.metadata & 0x7) == 1) { // sandstone
                mixin(add_slab_vertices(s, "sandstone_side"));
                return;
            }
        } else static if(s == Side.BOTTOM) {
            if((block.metadata & 0x7) == 0) { // stone
                mixin(add_slab_vertices(s, "stoneslab_top"));
                return;
            } else if((block.metadata & 0x7) == 1) { // sandstone
                mixin(add_slab_vertices(s, "sandstone_top"));
                return;
            }
        }

        final switch(block.metadata & 0x7) {
            case 0: mixin(add_slab_vertices(s, "stoneslab_side")); break; // stone
            case 1: mixin(add_slab_vertices(s, "sandstone_side")); break; // sandstone
            case 2: mixin(add_slab_vertices(s, "wood")); break; // wooden stone
            case 3: mixin(add_slab_vertices(s, "stonebrick")); break; // cobblestone
            case 4: mixin(add_slab_vertices(s, "brick")); break; // brick
            case 5: mixin(add_slab_vertices(s, "stonebricksmooth")); break; // stone brick
        }
    }

    void stonebrick_block(Side s)(const Block block, const ref BiomeData biome_data,
                                  float x_offset, float y_offset, float z_offset) {
        final switch(block.metadata & 0x3) {
            case 0: mixin(add_block_vertices("stonebricksmooth")); break; // normal
            case 1: mixin(add_block_vertices("stonebricksmooth_mossy")); break; // mossy
            case 2: mixin(add_block_vertices("stonebricksmooth_cracked")); break; // cracked
            case 3: mixin(add_block_vertices("stonebricksmooth_carved")); break; // chiseled aka carved
        }
    }

    void wooden_double_slab(Side s)(const Block block, const ref BiomeData biome_data,
                                    float x_offset, float y_offset, float z_offset) {
        final switch(block.metadata & 0x3) {
            case 0: mixin(add_block_vertices("wood")); break; // oak
            case 1: mixin(add_block_vertices("wood_spruce")); break; // spruce
            case 2: mixin(add_block_vertices("wood_birch")); break; // birch
            case 3: mixin(add_block_vertices("wood_jungle")); break; // jungle
        }
    }

    void wooden_slab(Side s)(const Block block, const ref BiomeData biome_data,
                             float x_offset, float y_offset, float z_offset) {
        bool upside_down = (block.metadata & 0x8) != 0;
        final switch(block.metadata & 0x3) {
            case 0: mixin(add_slab_vertices(s, "wood")); break; // oak
            case 1: mixin(add_slab_vertices(s, "wood_spruce")); break; // spruce
            case 2: mixin(add_slab_vertices(s, "wood_birch")); break; // birch
            case 3: mixin(add_slab_vertices(s, "wood_jungle")); break; // jungle
        }
    }

    void stair(Side s)(const Block block, ProjectionTextureCoordinates tex, const ref BiomeData biome_data,
                       float x_offset, float y_offset, float z_offset) {
        enum fs = [Facing.WEST, Facing.EAST, Facing.NORTH, Facing.SOUTH];

        Facing f = fs[block.metadata & 0x3];
        bool upside_down = (block.metadata & 0x4) != 0;

        add_template_vertices(memoize!(simple_stair, 72)(s, f, upside_down, tex), block, x_offset, y_offset, z_offset);
    }

    void wheat(Side s)(const Block block, const ref BiomeData biome_data,
                       float x_offset, float y_offset, float z_offset) {
        short[2][4] tex;
        final switch(block.metadata & 0x7) {
            foreach(i; TupleRange!(0, 8)) {
                case i: tex = atlas.get!("crops_" ~ to!string(i))(); break;
            }
        }

        add_template_vertices(simple_food_plant(tex), block, x_offset, y_offset, z_offset);
    }

    void farmland(Side s)(const Block block, const ref BiomeData biome_data,
                          float x_offset, float y_offset, float z_offset) {
        Vertex[] fb;
        static if(s == Side.TOP) {
            if(block.metadata == 0) { // dry
                fb = farmland_block(s, atlas.get_proj!("farmland_dry"));
            } else { // wet
                fb = farmland_block(s, atlas.get_proj!("farmland_wet"));
            }
        } else {
            fb = farmland_block(s, atlas.get_proj!("dirt"));
        }

        add_template_vertices(fb, block, x_offset, y_offset, z_offset);
    }

    void furnace(Side s, string tex = `atlas.get!("furnace_front")`)(const Block block, const ref BiomeData biome_data,
                                                                 float x_offset, float y_offset, float z_offset) {
        enum fs = [Facing.WEST, Facing.EAST, Facing.NORTH, Facing.SOUTH];

        Facing f = fs[block.metadata & 0x3];

        if(cast(Side)f == s) { // special side
            add_template_vertices(simple_block(s, mixin(tex)), block, x_offset, y_offset, z_offset);
        } else {
            tessellate_simple_block!(s)(block, biome_data, x_offset, y_offset, z_offset);
        }
    }

    void burning_furnace(Side s)(const Block block, const ref BiomeData biome_data,
                                 float x_offset, float y_offset, float z_offset) {
        furnace!(s, `atlas.get!("furnace_front_lit")`)(block, biome_data, x_offset, y_offset, z_offset);
    }

    void dispenser(Side s)(const Block block, const ref BiomeData biome_data,
                           float x_offset, float y_offset, float z_offset) {
        furnace!(s, `atlas.get!("dispenser_front")`)(block, biome_data, x_offset, y_offset, z_offset);
    }

    void pumpkin(Side s, bool is_jako = false)(const Block block, const ref BiomeData biome_data,
                         float x_offset, float y_offset, float z_offset) {
        enum fs = [Facing.SOUTH, Facing.WEST, Facing.NORTH, Facing.EAST];

        Facing f = fs[block.metadata & 0x3];

        static if(s == Side.TOP) {
            add_template_vertices(simple_block(s, atlas.get!("pumpkin_top"), f), block, x_offset, y_offset, z_offset);
        } else {
            if(cast(Side)f == s) { // side with the face
                static if(is_jako) { // it's a jako lantern
                    add_template_vertices(simple_block(s, atlas.get!("pumpkin_jack")), block, x_offset, y_offset, z_offset);
                } else {
                    add_template_vertices(simple_block(s, atlas.get!("pumpkin_face")), block, x_offset, y_offset, z_offset);
                }
            } else {
                tessellate_simple_block!(s)(block, biome_data, x_offset, y_offset, z_offset);
            }
        }
    }

    void jack_o_lantern(Side s)(const Block block, const ref BiomeData biome_data,
                                float x_offset, float y_offset, float z_offset) {
        pumpkin!(s, true)(block, biome_data, x_offset, y_offset, z_offset);
    }

    void plant(Side s)(const Block block, short[2][4] tex, const ref BiomeData biome_data,
                       float x_offset, float y_offset, float z_offset) {
        add_template_vertices(simple_plant(tex), block, x_offset, y_offset, z_offset);
    }

    void saplings(Side s)(const Block block, const ref BiomeData biome_data,
                          float x_offset, float y_offset, float z_offset) {
        short[2][4] tex;

        final switch(block.metadata & 0x3) {
            case 0: tex = atlas.get!("sapling"); break; // oak
            case 1: tex = atlas.get!("sapling_spruce"); break; // spruce
            case 2: tex = atlas.get!("sapling_birch"); break; // birch
            case 3: tex = atlas.get!("sapling_jungle"); break; // jungle
        }

        add_template_vertices(simple_plant(tex), block, x_offset, y_offset, z_offset);
    }

    void tall_grass(Side s)(const Block block, const ref BiomeData biome_data,
                            float x_offset, float y_offset, float z_offset) {
        short[2][4] tex;
        Color4 color = Color4(cast(ubyte)0xff, cast(ubyte)0xff, cast(ubyte)0xff, cast(ubyte)0xff);

        final switch(block.metadata & 0x3) {
            case 0: tex = atlas.get!("deadbush"); break; // shrub aka deadbush
            case 1: tex = atlas.get!("tallgrass"); color = biome_data.color.grass; break; // grass
            case 2: tex = atlas.get!("fern");      color = biome_data.color.grass; break; // fern
            case 3: tex = atlas.get!("tallgrass"); color = biome_data.color.grass; break; // grass
        }

        add_template_vertices(simple_plant(tex), block, x_offset, y_offset, z_offset, color.field);
    }

    void stem(Side s)(const Block block, const ref BiomeData biome_data,
                      vec3i world_coords, float x_offset, float y_offset, float z_offset) {

        auto stem = atlas.get!("stem_straight")();
        Color4 color = Color4(cast(ubyte)0x0, cast(ubyte)0xad, cast(ubyte)0x17, cast(ubyte)0xff);
        
        int id = 86; // pumpkin
        if(block.id == 105) {
            id = 103; // melon
        }

        Facing face = Facing.SOUTH;
        bool render_stem2 = false;

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
            auto stem2 = atlas.get!("stem_bent")();
            add_template_vertices(side_stem(face, stem2), block, x_offset, y_offset, z_offset, color.field);
            y_offset -= 0.4f;
        }

        y_offset -= 0.1f;
        y_offset -= (7-block.metadata)/10.0f;

        add_template_vertices(simple_plant(stem, face), block, x_offset, y_offset, z_offset, color.field);
    }

    void nether_wart(Side s)(const Block block, const ref BiomeData biome_data,
                             float x_offset, float y_offset, float z_offset) {
        short[2][4] tex;
        final switch(block.metadata & 0x3) {
            case 0: tex = atlas.get!("netherStalk_0")();
            case 1: tex = atlas.get!("netherStalk_1")();
            case 2: tex = atlas.get!("netherStalk_1")();
            case 3: tex = atlas.get!("netherStalk_2")();
        }

        return add_template_vertices(simple_food_plant(tex), block, x_offset, y_offset, z_offset);
    }

    void rail(Side s)(const Block block, float x_offset, float y_offset, float z_offset) {
        short[2][4] tex = atlas.get!("rail")();
        
        if(block.metadata < 2) {
            enum fs = [Facing.SOUTH, Facing.WEST];

            add_template_vertices(simple_rail(tex, fs[block.metadata]), block, x_offset, y_offset, z_offset);
        } else if(block.metadata < 6) {
            enum fs = [Facing.EAST, Facing.WEST, Facing.NORTH, Facing.SOUTH];

            add_template_vertices(simple_ascending_rail(tex, fs[block.metadata-2]), block, x_offset, y_offset, z_offset);
        } else { // curved
            enum fs = [Facing.SOUTH, Facing.WEST, Facing.NORTH, Facing.EAST];
            tex = atlas.get!("rail_turn");

            add_template_vertices(simple_rail(tex, fs[block.metadata-6]), block, x_offset, y_offset, z_offset);
        }

    }

    void special_rail(Side s)(const Block block, float x_offset, float y_offset, float z_offset) {
        short[2][4] tex;

        if(block.id == 27) { // powered rail
            if(block.metadata & 0x8) { // powered
                tex = atlas.get!("goldenRail_powered");
            } else {
                tex = atlas.get!("goldenRail");
            }
        } else {
            if(block.metadata & 0x8) { // powered
                tex = atlas.get!("detectorRail_on");
            } else {
                tex = atlas.get!("detectorRail");
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

    void ladder(Side s)(const Block block, float x_offset, float y_offset, float z_offset) {
        enum fs = [Facing.WEST, Facing.EAST, Facing.NORTH, Facing.SOUTH];

        add_template_vertices(simple_ladder(atlas.get!("ladder"), fs[block.metadata & 0x3]), block, x_offset, y_offset, z_offset);
    }

    void vines(Side s)(const Block block, const ref BiomeData biome_data, vec3i world_coords,
                       float x_offset, float y_offset, float z_offset) {
        enum fs = [Facing.NORTH, Facing.EAST, Facing.SOUTH, Facing.WEST];

        foreach(shift; 0..4) {
            if(block.metadata & (1 << shift)) {
                add_template_vertices(simple_vine(atlas.get!("vine"), fs[shift]), block,
                                      x_offset, y_offset, z_offset, biome_data.color.leave.field);
            }
        }

        if(block.metadata == 0 || BLOCKS[world.get_block_safe(vec3i(world_coords.x, world_coords.y+1, world_coords.z)).id].opaque) {
            add_template_vertices(top_vine(atlas.get!("vine")), block, x_offset, y_offset, z_offset, biome_data.color.leave.field);
        }
    }

    
    void piston_block_sticky(Side s)(const Block block, const ref BiomeData biome_data,
                                     float x_offset, float y_offset, float z_offset) {
        piston_block!(s, true)(block, biome_data, x_offset, y_offset, z_offset);
    }

    void piston_block(Side s, bool sticky = false)(const Block block, const ref BiomeData biome_data,
                                                   float x_offset, float y_offset, float z_offset) {
        static assert(s != Side.ALL);

        enum fs = [Side.BOTTOM, Side.TOP, Side.FAR, Side.NEAR, Side.LEFT, Side.RIGHT];
       
        if(block.metadata & 0x8) {
            short[2][4] tex;
            final switch(s) {
                case 0: tex = atlas.get!("piston_inner_top")(); break;
                case 1: tex = atlas.get!("piston_side", 90, 8, 8, 4, 8)(); break;
                case 2: tex = atlas.get!("piston_bottom")(); break;
                case 3: tex = atlas.get!("piston_side", 270, 8, 8, 4, 8)(); break;
                case 4: tex = atlas.get!("piston_side", 180, 8, 8, 4, 8)(); break;
                case 5: tex = atlas.get!("piston_side", 0  , 8, 8, 4, 8)(); break;
                case 6: break;
            }

            size_t m = (block.metadata & 0x7) > 5 ? 5 : block.metadata;

            auto vertices = extended_piston(s, fs[(m & 0x7)], tex);
            add_template_vertices(vertices, block, x_offset, y_offset, z_offset); 
        } else {
            short[2][4] tex;
            final switch(s) {
                case 0:
                    static if(sticky) {
                        tex = atlas.get!("piston_top_sticky");
                    } else {
                        tex = atlas.get!("piston_top");
                    }
                    break;
                case 1: tex = atlas.get!("piston_side", 90)(); break;
                case 2: tex = atlas.get!("piston_bottom")(); break;
                case 3: tex = atlas.get!("piston_side", 270)(); break;
                case 4: tex = atlas.get!("piston_side", 180)(); break;
                case 5: tex = atlas.get!("piston_side")(); break;
                case 6: break;
            }

            size_t m = (block.metadata & 0x7) > 5 ? 5 : block.metadata;

            auto vertices = retracted_piston(s, fs[(m & 0x7)], tex);
            add_template_vertices(vertices, block, x_offset, y_offset, z_offset); 
        }
    }

    void piston_arm(Side s)(const Block block, const ref BiomeData biome_data,
                            float x_offset, float y_offset, float z_offset) {
        short[2][4] tex;
        final switch(s) {
            case 0:
            case 2:
                if(block.metadata & 0x8) {
                    tex = atlas.get!("piston_top_sticky");
                } else {
                    tex = atlas.get!("piston_top");
                }
                break;
            case 1: tex = atlas.get!("piston_side", 90, 8, 8, 8, -4)(); break;
            case 3: tex = atlas.get!("piston_side", 270, 8, 8, 8, -4)(); break;
            case 4: tex = atlas.get!("piston_side", 180, 8, 8, 8, -4)(); break;
            case 5: tex = atlas.get!("piston_side", 0, 8, 8, 8, -4)(); break;
            case 6: break;
        }

        static if(s == Side.LEFT || s == Side.RIGHT) {
            auto arm_tex = atlas.get!("piston_side")();
        } else {
            auto arm_tex = atlas.get!("piston_side", 90)();
        }

        enum fs = [Side.BOTTOM, Side.TOP, Side.FAR, Side.NEAR, Side.LEFT, Side.RIGHT];
        
        size_t m = (block.metadata & 0x7) > 5 ? 5 : block.metadata;
        auto vertices = .piston_arm(s, fs[(m & 0x7)], tex, arm_tex);
        add_template_vertices(vertices, block, x_offset, y_offset, z_offset);
    }

    void torch(Side s, string tex)(const Block block,
                       float x_offset, float y_offset, float z_offset) {


        static if(s == Side.TOP) {
            enum left = 1;
            enum right = 1;
            enum top = 2;
            enum bottom = 0;
        } else static if(s == Side.BOTTOM) {
            enum left = 1;
            enum right = 1;
            enum top = -6;
            enum bottom = 8;
        } else {
            enum left = 2;
            enum right = 2;
            enum top = 2;
            enum bottom = 8;
        }

        enum fs = [Facing.EAST, Facing.WEST, Facing.SOUTH, Facing.NORTH];

        auto vertices = simple_torch(s, fs[block.metadata > 0x4 ? 3 : block.metadata-1], block.metadata > 0x4,
                                     atlas.get!(tex, 0, left, right, top, bottom)());
        add_template_vertices(vertices, block, x_offset, y_offset, z_offset);
    }

    void redstone_repeater_active(Side s)(const Block block, const ref BiomeData biome_data,
                                          float x_offset, float y_offset, float z_offset) {
        redstone_repeater!(s, true)(block, biome_data, x_offset, y_offset, z_offset);
    }

    void redstone_repeater(Side s, bool powered = false)(const Block block, const ref BiomeData biome_data,
                                                         float x_offset, float y_offset, float z_offset) {
        short[2][4] tex;
        short[2][4] torch_tex;
        static if(s == Side.TOP || s == Side.BOTTOM) {
            static if(powered) {
                tex = atlas.get!("repeater");
                torch_tex = atlas.get!("redtorch", 0, 1, 1, 2, 0);
            } else {
                tex = atlas.get!("repeater_lit");
                torch_tex = atlas.get!("redtorch_lit", 0, 1, 1, 2, 0);
            }
        } else static if(s != Side.TOP && s != Side.BOTTOM) {
            tex = atlas.get!("stoneslab_side", 0, 8, 8, -6, 8); // double slab texture
            static if(powered) {
                torch_tex = atlas.get!("redtorch_lit", 0, 1, 1, 2, 0);
            } else {
                torch_tex = atlas.get!("redtorch", 0, 1, 1, 2, 0);
            }
        }

        enum fs = [Facing.SOUTH, Facing.EAST, Facing.NORTH, Facing.WEST];

        float offset = -0.0625f + ((block.metadata >> 2) & 0x3) * 0.125f;

        alias memoize!(.redstone_repeater, 16) rr;
        add_template_vertices(rr(s, fs[block.metadata & 0x3], offset, tex, torch_tex), block, x_offset, y_offset, z_offset);
    }

    void redstone(Side s)(const Block block, vec3i world_coords, float x_offset, float y_offset, float z_offset) {
        enum rs_id = 55;
        enum redstone_devices = [rs_id, 69, 70, 75, 76, 77, 131, 143];
        enum special_redstone_devices = [93, 94];

        static bool connects_to(string side, const Block other) {
            if(redstone_devices.canFind(other.id)) {
                return true;
            } else if(other.id == 93 || other.id == 94) {
                if(side == "FRONT" || side == "BACK") {
                    return (other.metadata & 0x3) % 2 == 0;
                } else {
                    return (other.metadata & 0x3) % 2 == 1;
                }
            }
            
            return false;
        }

        auto color = Color4(cast(ubyte)(0x5a+block.metadata*10), cast(ubyte)0x00, cast(ubyte)0x00, cast(ubyte)0xff);
        
        enum {
            FRONT =     0b00000001,
            BACK =      0b00000010,
            LEFT =      0b00000100,
            RIGHT =     0b00001000,
            FRONT_TOP = 0b00010000,
            BACK_TOP =  0b00100000,
            LEFT_TOP =  0b01000000,
            RIGHT_TOP = 0b10000000
        }

        ubyte data = 0;
        ubyte sides = 0;

        
        Block b = world.get_block_safe(vec3i(world_coords.x , world_coords.y+1, world_coords.z));
        BlockDescriptor orig_block_desc;
        
        bool can_travel_up = !BLOCKS[b.id].opaque;

        static string make_check(string x, string z, string flag) {
            return `b = world.get_block_safe(vec3i(world_coords.x+` ~ x ~ ` , world_coords.y, world_coords.z+` ~ z ~ `));
                    orig_block_desc = BLOCKS[b.id];

                    if(connects_to("` ~ flag ~ `", b)) {
                        data |= ` ~ flag ~ `;
                        sides++;
                    } else if(can_travel_up && orig_block_desc.opaque) {
                        b = world.get_block_safe(vec3i(world_coords.x+` ~ x ~ ` , world_coords.y+1, world_coords.z+` ~ z ~ `));
                        if(b.id == rs_id) {
                            data |= ` ~ flag ~ `;
                            data |= ` ~ flag ~ `_TOP;
                            sides++;
                        }
                    }

                    if(!orig_block_desc.opaque) {
                        b = world.get_block_safe(vec3i(world_coords.x+` ~ x ~ ` , world_coords.y-1, world_coords.z+` ~ z ~ `));
                        if(b.id == rs_id) {
                            if((data & ` ~ flag ~ `) == 0) {
                                data |= ` ~ flag ~ `;
                                sides++;
                            }
                        }
                    }
                    `;
        }

        mixin(make_check("0", "1", "FRONT"));
        mixin(make_check("0", "-1", "BACK"));
        mixin(make_check("1", "0", "RIGHT"));
        mixin(make_check("-1", "0", "LEFT"));

        if(sides == 0) {
            auto vertices = redstone_wire(Facing.SOUTH, atlas.get!("redstoneDust_cross", 0, 3, 3, 3, 3)(), 3, 3, 3, 3);
            add_template_vertices(vertices, block, x_offset, y_offset, z_offset, color.field);
        } else if(sides == 1 || (data & 0b1111) == 0b1100 || (data & 0b1111) == 0b0011) {
            if(data & 0b1100) {
                auto vertices = redstone_wire(Facing.SOUTH, atlas.get!("redstoneDust_line")());
                add_template_vertices(vertices, block, x_offset, y_offset, z_offset, color.field);
            } else if(data & 0b0011) {
                auto vertices = redstone_wire(Facing.EAST, atlas.get!("redstoneDust_line")());
                add_template_vertices(vertices, block, x_offset, y_offset, z_offset, color.field);
            }
        } else {
            short top = (data & 1) ? 8 : 3;
            short bottom = (data & 2) ? 8 : 3;
            short right = (data & 4) ? 8 : 3;
            short left = (data & 8) ? 8 : 3;
            auto tex = atlas.get_tex!("redstoneDust_cross")().r0(left, right, top, bottom);

            auto vertices = memoize!(redstone_wire, 8)(Facing.SOUTH, tex, left, right, top, bottom);
            add_template_vertices(vertices, block, x_offset, y_offset, z_offset, color.field);
        }

        foreach(i; TypeTuple!(4, 5, 6, 7)) {
            if(data & (1 << i)) {
                enum s = [Facing.SOUTH, Facing.NORTH, Facing.WEST, Facing.EAST];
                auto vertices = redstone_wire_side(s[i-4], atlas.get!("redstoneDust_line", 90)());
                add_template_vertices(vertices, block, x_offset, y_offset, z_offset, color.field);
            }
        }
    }

    void dispatch(Side side)(const Block block, const ref BiomeData biome_data,
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
            case 29: mixin(single_side("piston_block_sticky")); break; // sticky-piston
            case 30: dispatch_once!(plant, side)(block, atlas.get!("web")(), // cobweb
                     biome_data, x_offset, y_offset, z_offset); break;
            case 31: dispatch_once!(tall_grass, side)(block, biome_data, x_offset, y_offset, z_offset); break; // tall grass
            case 33: mixin(single_side("piston_block")); break; // normal piston
            case 34: mixin(single_side("piston_arm")); break; // piston arm/extension
            case 35: mixin(single_side("wool_block")); break; // wool
            case 37: dispatch_once!(plant, side)(block, atlas.get!("flower"), // dandelion
                     biome_data, x_offset, y_offset, z_offset); break;
            case 38: dispatch_once!(plant, side)(block, atlas.get!("rose"), // rose
                     biome_data, x_offset, y_offset, z_offset); break;
            case 39: dispatch_once!(plant, side)(block, atlas.get!("mushroom_brown"), // brown mushroom
                     biome_data, x_offset, y_offset, z_offset); break;
            case 40: dispatch_once!(plant, side)(block, atlas.get!("mushroom_red"), // red mushroom
                     biome_data, x_offset, y_offset, z_offset); break;
            case 50: dispatch_single_side_torch!(torch, side, "torch")(block, x_offset, y_offset, z_offset); break; // torch
            case 43: mixin(single_side("stone_double_slab")); break; // stone double slaps
            case 44: mixin(single_side("stone_slab")); break; // stone slabs - stone, sandstone, wooden stone, cobblestone, brick, stone brick
            case 53: dispatch_single_side!(stair, side)(block, atlas.get_proj!("wood", "wood"), // oak wood stair
                     biome_data, x_offset, y_offset, z_offset); break;
            case 55: dispatch_once!(redstone, side)(block, world_coords, x_offset, y_offset, z_offset); break; // redstone wire
            case 59: dispatch_once!(wheat, side)(block, biome_data, x_offset, y_offset, z_offset); break; // wheat
            case 60: mixin(single_side("farmland")); break; // farmland
            case 61: mixin(single_side("furnace")); break; // furnace
            case 62: mixin(single_side("burning_furnace")); break; // burning furnace
            case 65: dispatch_once!(ladder, side)(block, x_offset, y_offset, z_offset); break; // ladder
            case 66: dispatch_once!(rail, side)(block, x_offset, y_offset, z_offset); break; // rail
            case 67: dispatch_single_side!(stair, side)(block, atlas.get_proj!("stonebrick", "stonebrick"), // cobblestone stair
                     biome_data, x_offset, y_offset, z_offset); break;
            case 75: dispatch_single_side_torch!(torch, side, "redtorch")(block, x_offset, y_offset, z_offset); break; // rs-torch inactive
            case 76: dispatch_single_side_torch!(torch, side, "redtorch_lit")(block, x_offset, y_offset, z_offset); break; // rs-torch active
            case 83: dispatch_once!(plant, side)(block, atlas.get!("reeds"), // reeds
                     biome_data, x_offset, y_offset, z_offset); break;
            case 86: mixin(single_side("pumpkin")); break;
            case 91: mixin(single_side("jack_o_lantern")); break;
            case 93: mixin(single_side("redstone_repeater")); break; // redstone repeater inactive
            case 94: mixin(single_side("redstone_repeater_active")); break; // redstone repeater active
            case 98: mixin(single_side("stonebrick_block")); break; // stone brick
            case 104: dispatch_once!(stem, side)(block, biome_data, world_coords, x_offset, y_offset, z_offset); break; // pumpkin stem
            case 105: dispatch_once!(stem, side)(block, biome_data, world_coords, x_offset, y_offset, z_offset); break; // melon stem
            case 106: dispatch_once!(vines, side)(block, biome_data, world_coords, x_offset, y_offset, z_offset); break; // vines
            case 108: dispatch_single_side!(stair, side)(block, atlas.get_proj!("brick", "brick"), // brick stair
                      biome_data, x_offset, y_offset, z_offset); break;
            case 109: dispatch_single_side!(stair, side)(block, atlas.get_proj!("stonebricksmooth", "stonebricksmooth"), // stone brick stair
                      biome_data, x_offset, y_offset, z_offset); break;
            case 114: dispatch_single_side!(stair, side)(block, atlas.get_proj!("netherBrick", "netherBrick"), // nether brick stair
                      biome_data, x_offset, y_offset, z_offset); break;
            case 115: dispatch_once!(nether_wart, side)(block, biome_data, x_offset, y_offset, z_offset); break; // nether wart
            case 125: mixin(single_side("wooden_double_slab")); break; // wooden double slab
            case 126: mixin(single_side("wooden_slab")); break; // wooden slab
            case 128: dispatch_single_side!(stair, side)(block, atlas.get_proj!("sandstone_side", "sandstone_top", "sandstone_bottom"), // sandstone stair
                      biome_data, x_offset, y_offset, z_offset); break;
            case 134: dispatch_single_side!(stair, side)(block, atlas.get_proj!("wood_spruce", "wood_spruce"), // spruce wood stair
                      biome_data, x_offset, y_offset, z_offset); break;
            case 135: dispatch_single_side!(stair, side)(block, atlas.get_proj!("wood_birch", "wood_birch"), // birch wood stair
                      biome_data, x_offset, y_offset, z_offset); break;
            case 136: dispatch_single_side!(stair, side)(block, atlas.get_proj!("wood_jungle", "wood_jungle"), // jungle wood stair
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

    void dispatch_single_side_torch(alias func, Side s, string str, Args...)(Args args) {
        static if(s == Side.ALL) {
            func!(Side.LEFT, str)(args);
            func!(Side.RIGHT, str)(args);
            func!(Side.NEAR, str)(args);
            func!(Side.FAR, str)(args);
            func!(Side.TOP, str)(args);
            func!(Side.BOTTOM, str)(args);
        } else {
            func!(s, str)(args);
        }
    }

    void dispatch_once(alias func, Side s, Args...)(Args args) {
        static if(s == Side.ALL || s == Side.RIGHT) {
            func!(Side.ALL)(args);
        }
    }

    void tessellate_simple_block(Side side)(const Block block, const ref BiomeData biome_data,
                                            float x_offset, float y_offset, float z_offset) {
        static if(side == Side.ALL) {
            tessellate_simple_block!(Side.LEFT)(block, biome_data, x_offset, y_offset, z_offset);
            tessellate_simple_block!(Side.RIGHT)(block, biome_data, x_offset, y_offset, z_offset);
            tessellate_simple_block!(Side.NEAR)(block, biome_data, x_offset, y_offset, z_offset);
            tessellate_simple_block!(Side.FAR)(block, biome_data, x_offset, y_offset, z_offset);
            tessellate_simple_block!(Side.TOP)(block, biome_data, x_offset, y_offset, z_offset);
            tessellate_simple_block!(Side.BOTTOM)(block, biome_data, x_offset, y_offset, z_offset);
        } else {
            add_template_vertices(atlas.get_vertices!(side)(block.id), block, x_offset, y_offset, z_offset);
        }
    }
}

static string add_block_vertices(string name) {
    return `auto vertices = simple_block(s, atlas.get!("` ~ name ~ `")());
            add_template_vertices(vertices, block, x_offset, y_offset, z_offset);`;
}

static string add_slab_vertices(Side s, string name) {
    string v;
    if(s == Side.TOP || s == Side.BOTTOM) {
        v = `auto vertices = simple_slab(s, false, atlas.get!("` ~ name ~ `")());
             auto vertices_usd = simple_slab(s, true, atlas.get!("` ~ name ~ `")());`;
    } else {
        v = `auto vertices = simple_slab(s, false, atlas.get!("` ~ name ~ `", 0, 8, 8, 8, 0)());
             auto vertices_usd = simple_slab(s, true, atlas.get!("` ~ name ~ `", 0, 8, 8, 8, 0)());`;
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