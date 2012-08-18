module brala.dine.builder.vertices;

private {
    import std.array : join;
    import std.math : abs;
    import std.traits : isIntegral;

    import brala.dine.builder.tessellator : Vertex;
    import brala.dine.builder.constants : Side;
    import brala.dine.util : to_triangles;
}


struct TextureSlice {
    byte x;
    byte y;

    alias texcoords this;

    this(byte lower_left_x, byte lower_left_y)
        in { assert(abs(lower_left_x*2) <= byte.max && abs(lower_left_y*2) <= byte.max); }
        body {
            x = cast(byte)(lower_left_x*2);
            y = cast(byte)(lower_left_y*2);
        }

    @property byte[2][4] texcoords() {
        return [[cast(byte)x,     cast(byte)y],
                [cast(byte)(x+2), cast(byte)y],
                [cast(byte)(x+2), cast(byte)(y-2)],
                [cast(byte)x,     cast(byte)(y-2)]];
    }

    @property byte[2][4] texcoords_90() {
        return [[cast(byte)(x+2), cast(byte)y],
                [cast(byte)(x+2), cast(byte)(y-2)],
                [cast(byte)x,     cast(byte)(y-2)],
                [cast(byte)x,     cast(byte)y]];
    }

    @property byte[2][4] texcoords_180() {
        return [[cast(byte)(x+2), cast(byte)(y-2)],
                [cast(byte)x,     cast(byte)(y-2)],
                [cast(byte)x,     cast(byte)y],
                [cast(byte)(x+2), cast(byte)y]];
    }

    @property byte[2][4] texcoords_270() {
        return [[cast(byte)x,     cast(byte)(y-2)],
                [cast(byte)x,     cast(byte)y],
                [cast(byte)(x+2), cast(byte)y],
                [cast(byte)(x+2), cast(byte)(y-2)]];
    }
}

struct SlabTextureSlice {
    byte x;
    byte y;

    alias texcoords this;

    this(byte lower_left_x, byte lower_left_y)
        in { assert(abs(lower_left_x*2) <= byte.max && abs(lower_left_y*2) <= byte.max); }
        body {
            x = cast(byte)(lower_left_x*2);
            y = cast(byte)(lower_left_y*2);
        }
    
    @property byte[2][4] texcoords() {
        return [[cast(byte)x,     cast(byte)y],
                [cast(byte)(x+2), cast(byte)y],
                [cast(byte)(x+2), cast(byte)(y-1)],
                [cast(byte)x,     cast(byte)(y-1)]];
    }
}


struct CubeSideData {
    float[3][4] positions; // 3*4, it's a cube!
    float[3] normal;
}

immutable CubeSideData[6] CUBE_VERTICES = [
    { [[-0.5f, -0.5f, 0.5f], [0.5f, -0.5f, 0.5f], [0.5f, 0.5f, 0.5f], [-0.5f, 0.5f, 0.5f]], // front
       [0.0f, 0.0f, 1.0f] },
    
    { [[-0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, 0.5f], [-0.5f, 0.5f, 0.5f], [-0.5f, 0.5f, -0.5f]], // left
       [-1.0f, 0.0f, 0.0f] },

    { [[0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, -0.5f], [-0.5f, 0.5f, -0.5f], [0.5f, 0.5f, -0.5f]], // back
       [0.0f, 0.0f, -1.0f] },

    { [[0.5f, -0.5f, 0.5f], [0.5f, -0.5f, -0.5f], [0.5f, 0.5f, -0.5f], [0.5f, 0.5f, 0.5f]], // right
       [1.0f, 0.0f, 0.0f] },

    { [[-0.5f, 0.5f, 0.5f], [0.5f, 0.5f, 0.5f], [0.5f, 0.5f, -0.5f], [-0.5f, 0.5f, -0.5f]], // top
       [0.0f, 1.0f, 0.0f]  },

    { [[-0.5f, -0.5f, -0.5f], [0.5f, -0.5f, -0.5f], [0.5f, -0.5f, 0.5f], [-0.5f, -0.5f, 0.5f]], // bottom
       [0.0f, -1.0f, 0.0f] }
];

private enum mk_vertices = `
    float[3][6] positions = to_triangles(cbsd.positions);
    byte[2][6] texcoords = to_triangles(texture_slice);
    byte[2][6] mask;
    if(mask_slice == nslice) {
        mask = texcoords;
    } else {
        mask = to_triangles(mask_slice);
    }

    Vertex[6] data;

    foreach(i; 0..6) {
        data[i] = Vertex(positions[i][0], positions[i][1], positions[i][2],
                         cbsd.normal[0], cbsd.normal[1], cbsd.normal[2],
                         texcoords[i][0], texcoords[i][1],
                         mask[i][0], mask[i][1],
                         0, 0);
    }

    return data.dup;`;

private const byte[2][4] nslice = TextureSlice(-1, -1).texcoords;

Vertex[] simple_block(Side side, byte[2][4] texture_slice) pure {
    return simple_block(side, texture_slice, nslice);
}

Vertex[] simple_block(Side side, byte[2][4] texture_slice, byte[2][4] mask_slice) pure {
    CubeSideData cbsd = CUBE_VERTICES[side];

    mixin(mk_vertices);
}

immutable CubeSideData[6] SLAB_VERTICES = [
    { [[-0.5f, -0.5f, 0.5f], [0.5f, -0.5f, 0.5f], [0.5f, 0.0f, 0.5f], [-0.5f, 0.0f, 0.5f]], // front
       [0.0f, 0.0f, 1.0f] },

    { [[-0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, 0.5f], [-0.5f, 0.0f, 0.5f], [-0.5f, 0.0f, -0.5f]], // left
       [-1.0f, 0.0f, 0.0f] },

    { [[0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, -0.5f], [-0.5f, 0.0f, -0.5f], [0.5f, 0.0f, -0.5f]], // back
       [0.0f, 0.0f, -1.0f] },

    { [[0.5f, -0.5f, 0.5f], [0.5f, -0.5f, -0.5f], [0.5f, 0.0f, -0.5f], [0.5f, 0.0f, 0.5f]], // right
       [1.0f, 0.0f, 0.0f] },

    { [[-0.5f, 0.0f, 0.5f], [0.5f, 0.0f, 0.5f], [0.5f, 0.0f, -0.5f], [-0.5f, 0.0f, -0.5f]], // top
       [0.0f, 1.0f, 0.0f]  },

    { [[-0.5f, -0.5f, -0.5f], [0.5f, -0.5f, -0.5f], [0.5f, -0.5f, 0.5f], [-0.5f, -0.5f, 0.5f]], // bottom
       [0.0f, -1.0f, 0.0f] }
];

immutable CubeSideData[6] SLAB_VERTICES_UPSIDEDOWN = upside_down_slabs();

private CubeSideData[6] upside_down_slabs() {
    CubeSideData[6] ret = SLAB_VERTICES.dup;

    foreach(ref side; ret) {
        foreach(ref vertex; side.positions) {
            vertex[1] += 0.5f;
        }
    }

    return ret;
}

Vertex[] simple_slab(Side side, bool upside_down, byte[2][4] texture_slice) pure {
    return simple_slab(side, upside_down, texture_slice, nslice);
}

Vertex[] simple_slab(Side side, bool upside_down, byte[2][4] texture_slice, byte[2][4] mask_slice) pure {
    CubeSideData cbsd;
    if(upside_down) {
        cbsd = SLAB_VERTICES_UPSIDEDOWN[side];
    } else {
        cbsd = SLAB_VERTICES[side];
    }

    mixin(mk_vertices);
}


enum size_t BLOCK_IDS = 139;

private alias TextureSlice t;

Vertex[][BLOCK_IDS] BLOCK_VERTICES_LEFT = [
    [], // air
    simple_block(Side.LEFT, t(1, 1)), // stone
    simple_block(Side.LEFT, t(3, 1), t(6, 3)), // grass
    simple_block(Side.LEFT, t(2, 1)), // dirt
    simple_block(Side.LEFT, t(0, 2)), // cobble
    simple_block(Side.LEFT, t(4, 1)), // wooden plank
    [], // sapling
    simple_block(Side.LEFT, t(1, 2)), // bedrock
    [], // water
    [], // stationary water
    [], // lava
    [], // stationary lava
    simple_block(Side.LEFT, t(2, 2)), // sand
    simple_block(Side.LEFT, t(3, 2)), // gravel
    simple_block(Side.LEFT, t(0, 3)), // gold ore
    simple_block(Side.LEFT, t(1, 3)), // iron ore
    simple_block(Side.LEFT, t(2, 3)), // coal ore
    simple_block(Side.LEFT, t(4, 2)), // wood
    simple_block(Side.LEFT, t(4, 4)), // leave
    simple_block(Side.LEFT, t(0, 4)), // sponge
    simple_block(Side.LEFT, t(1, 4)), // glass
    simple_block(Side.LEFT, t(0, 11)), // lapis lazuli ore
    simple_block(Side.LEFT, t(0, 10)), // lapis lazuli block
    simple_block(Side.LEFT, t(13, 3)), // dispenser
    simple_block(Side.LEFT, t(0, 13)), // sandstone
    simple_block(Side.LEFT, t(2, 10)), // noteblock
    [], // bed
    [], // powered rail
    [], // detector rail
    [], // sticky piston
    [], // cobweb
    [], // tall grass
    [], // dead bush
    [], // piston
    [], // piston extension
    [], // wool
    [], // block moved by piston
    [], // dandelion
    [], // rose
    [], // brown mushroom
    [], // red mushroom
    simple_block(Side.LEFT, t(7, 2)), // gold block
    simple_block(Side.LEFT, t(6, 2)), // iron block
    simple_block(Side.LEFT, t(5, 1)), // double slab
    [], // slab
    simple_block(Side.LEFT, t(7, 1)), // brick
    simple_block(Side.LEFT, t(8, 1)), // tnt
    simple_block(Side.LEFT, t(3, 3)), // bookshelf
    simple_block(Side.LEFT, t(4, 3)), // mossy stone
    simple_block(Side.LEFT, t(5, 3)), // obsidian
    [], // torch
    [], // fire
    simple_block(Side.LEFT, t(1, 5)), // spawner
    [], // wooden stair
    [], // chest
    [], // redstone wire
    simple_block(Side.LEFT, t(2, 4)), // diamond ore
    simple_block(Side.LEFT, t(8, 2)), // diamond block
    simple_block(Side.LEFT, t(12, 4)), // crafting table
    [], // wheat
    [], // farmland
    simple_block(Side.LEFT, t(13, 3)),  // furnace
    simple_block(Side.LEFT, t(13, 3)),  // burning furnace
    [], // sign post
    [], // wooden door
    [], // ladder
    [], // rail
    [], // cobblestone stair
    [], // wall sign
    [], // lever
    [], // stone pressure plate
    [], // iron door
    [], // wooden pressure plate
    simple_block(Side.LEFT, t(3, 4)), // redstone ore
    simple_block(Side.LEFT, t(3, 4)), // glowing redstone ore
    [], // redstone torch
    [], // redstone torch on
    [], // stone button
    [], // snow
    simple_block(Side.LEFT, t(3, 5)), // ice
    simple_block(Side.LEFT, t(2, 5)), // snow block
    [], // cactus
    simple_block(Side.LEFT, t(8, 5)), // clay block
    [], // sugar cane
    simple_block(Side.LEFT, t(10, 5)), // jukebox
    [], // fence
    simple_block(Side.LEFT, t(6, 8)), // pumpkin
    simple_block(Side.LEFT, t(7, 7)), // netherrack
    simple_block(Side.LEFT, t(8, 7)), // soul sand
    simple_block(Side.LEFT, t(9, 7)), // glowstone block
    [], // portal
    simple_block(Side.LEFT, t(6, 8)), // jack-o-lantern
    [], // cake block
    [], // redstone repeater
    [], // redstone repeater on
    [], // locked chest
    [], // trapdoor
    [], // hidden silverfish
    simple_block(Side.LEFT, t(6, 4)), // stone brick
    [], // huge brown mushroom
    [], // huge red mushroom
    [], // iron bar
    [], // glass pane
    simple_block(Side.LEFT, t(8, 9)), // melon
    [], // pumpkin stem
    [], // melon stem
    [], // vine
    [], // fence gate
    [], // brick stair
    [], // stone brick stair
    simple_block(Side.LEFT, t(13, 5)), // mycelium
    [], // lilly pad
    simple_block(Side.LEFT, t(0, 15)), // nether brick
    [], // nether brick fence
    [], // nether wart
    [], // nether brick stair
    [], // enchantment table
    [], // brewing stand
    simple_block(Side.LEFT, t(10, 10)), // cauldron
    [], // end portal
    [], // end portal frame
    simple_block(Side.LEFT, t(15, 11)), // end stone
    [], // dragon egg
    simple_block(Side.LEFT, t(3, 14)), // redstone lamp
    simple_block(Side.LEFT, t(4, 14)), // redstone lamp on
    [], // wooden double slab
    [], // wooden slab
    [], // cocoa plant
    [], // sandstone stairs
    simple_block(Side.LEFT, t(11, 11)), // emerald ore
    [], // ender chest
    [], // tripwire hook
    [], // tripwire
    simple_block(Side.LEFT, t(9, 2)), // emerald block
    [], // spruce wood stairs
    [], // birch wood stairs
    [], // jungle wood stairs
    [], // command block
    []  // beacon block
];

Vertex[][BLOCK_IDS] BLOCK_VERTICES_RIGHT = [
    [], // air
    simple_block(Side.RIGHT, t(1, 1)), // stone
    simple_block(Side.RIGHT, t(3, 1), t(6, 3)), // grass
    simple_block(Side.RIGHT, t(2, 1)), // dirt
    simple_block(Side.RIGHT, t(0, 2)), // cobble
    simple_block(Side.RIGHT, t(4, 1)), // wooden plank
    [], // sapling
    simple_block(Side.RIGHT, t(1, 2)), // bedrock
    [], // water
    [], // stationary water
    [], // lava
    [], // stationary lava
    simple_block(Side.RIGHT, t(2, 2)), // sand
    simple_block(Side.RIGHT, t(3, 2)), // gravel
    simple_block(Side.RIGHT, t(0, 3)), // gold ore
    simple_block(Side.RIGHT, t(1, 3)), // iron ore
    simple_block(Side.RIGHT, t(2, 3)), // coal ore
    simple_block(Side.RIGHT, t(4, 2)), // wood
    simple_block(Side.RIGHT, t(4, 4)), // leave
    simple_block(Side.RIGHT, t(0, 4)), // sponge
    simple_block(Side.RIGHT, t(1, 4)), // glass
    simple_block(Side.RIGHT, t(0, 11)), // lapis lazuli ore
    simple_block(Side.RIGHT, t(0, 10)), // lapis lazuli block
    simple_block(Side.RIGHT, t(13, 3)), // dispenser
    simple_block(Side.RIGHT, t(0, 13)), // sandstone
    simple_block(Side.RIGHT, t(2, 10)), // noteblock
    [], // bed
    [], // powered rail
    [], // detector rail
    [], // sticky piston
    [], // cobweb
    [], // tall grass
    [], // dead bush
    [], // piston
    [], // piston extension
    [], // wool
    [], // block moved by piston
    [], // dandelion
    [], // rose
    [], // brown mushroom
    [], // red mushroom
    simple_block(Side.RIGHT, t(7, 2)), // gold block
    simple_block(Side.RIGHT, t(6, 2)), // iron block
    simple_block(Side.RIGHT, t(5, 1)), // double slab
    [], // slab
    simple_block(Side.RIGHT, t(7, 1)), // brick
    simple_block(Side.RIGHT, t(8, 1)), // tnt
    simple_block(Side.RIGHT, t(3, 3)), // bookshelf
    simple_block(Side.RIGHT, t(4, 3)), // mossy stone
    simple_block(Side.RIGHT, t(5, 3)), // obsidian
    [], // torch
    [], // fire
    simple_block(Side.RIGHT, t(1, 5)), // spawner
    [], // wooden stair
    [], // chest
    [], // redstone wire
    simple_block(Side.RIGHT, t(2, 4)), // diamond ore
    simple_block(Side.RIGHT, t(8, 2)), // diamond block
    simple_block(Side.RIGHT, t(12, 4)), // crafting table
    [], // wheat
    [], // farmland
    simple_block(Side.RIGHT, t(13, 3)),  // furnace
    simple_block(Side.RIGHT, t(13, 3)),  // burning furnace
    [], // sign post
    [], // wooden door
    [], // ladder
    [], // rail
    [], // cobblestone stair
    [], // wall sign
    [], // lever
    [], // stone pressure plate
    [], // iron door
    [], // wooden pressure plate
    simple_block(Side.RIGHT, t(3, 4)), // redstone ore
    simple_block(Side.RIGHT, t(3, 4)), // glowing redstone ore
    [], // redstone torch
    [], // redstone torch on
    [], // stone button
    [], // snow
    simple_block(Side.RIGHT, t(3, 5)), // ice
    simple_block(Side.RIGHT, t(2, 5)), // snow block
    [], // cactus
    simple_block(Side.RIGHT, t(8, 5)), // clay block
    [], // sugar cane
    simple_block(Side.RIGHT, t(10, 5)), // jukebox
    [], // fence
    simple_block(Side.RIGHT, t(6, 8)), // pumpkin
    simple_block(Side.RIGHT, t(7, 7)), // netherrack
    simple_block(Side.RIGHT, t(8, 7)), // soul sand
    simple_block(Side.RIGHT, t(9, 7)), // glowstone block
    [], // portal
    simple_block(Side.RIGHT, t(6, 8)), // jack-o-lantern
    [], // cake block
    [], // redstone repeater
    [], // redstone repeater on
    [], // locked chest
    [], // trapdoor
    [], // hidden silverfish
    simple_block(Side.RIGHT, t(6, 4)), // stone brick
    [], // huge brown mushroom
    [], // huge red mushroom
    [], // iron bar
    [], // glass pane
    simple_block(Side.RIGHT, t(8, 9)), // melon
    [], // pumpkin stem
    [], // melon stem
    [], // vine
    [], // fence gate
    [], // brick stair
    [], // stone brick stair
    simple_block(Side.RIGHT, t(13, 5)), // mycelium
    [], // lilly pad
    simple_block(Side.RIGHT, t(0, 15)), // nether brick
    [], // nether brick fence
    [], // nether wart
    [], // nether brick stair
    [], // enchantment table
    [], // brewing stand
    simple_block(Side.RIGHT, t(10, 10)), // cauldron
    [], // end portal
    [], // end portal frame
    simple_block(Side.RIGHT, t(15, 11)), // end stone
    [], // dragon egg
    simple_block(Side.RIGHT, t(3, 14)), // redstone lamp
    simple_block(Side.RIGHT, t(4, 14)), // redstone lamp on
    [], // wooden double slab
    [], // wooden slab
    [], // cocoa plant
    [], // sandstone stairs
    simple_block(Side.RIGHT, t(11, 11)), // emerald ore
    [], // ender chest
    [], // tripwire hook
    [], // tripwire
    simple_block(Side.RIGHT, t(9, 2)), // emerald block
    [], // spruce wood stairs
    [], // birch wood stairs
    [], // jungle wood stairs
    [], // command block
    []  // beacon block
];

Vertex[][BLOCK_IDS] BLOCK_VERTICES_NEAR = [
    [], // air
    simple_block(Side.NEAR, t(1, 1)), // stone
    simple_block(Side.NEAR, t(3, 1), t(6, 3)), // grass
    simple_block(Side.NEAR, t(2, 1)), // dirt
    simple_block(Side.NEAR, t(0, 2)), // cobble
    simple_block(Side.NEAR, t(4, 1)), // wooden plank
    [], // sapling
    simple_block(Side.NEAR, t(1, 2)), // bedrock
    [], // water
    [], // stationary water
    [], // lava
    [], // stationary lava
    simple_block(Side.NEAR, t(2, 2)), // sand
    simple_block(Side.NEAR, t(3, 2)), // gravel
    simple_block(Side.NEAR, t(0, 3)), // gold ore
    simple_block(Side.NEAR, t(1, 3)), // iron ore
    simple_block(Side.NEAR, t(2, 3)), // coal ore
    simple_block(Side.NEAR, t(4, 2)), // wood
    simple_block(Side.NEAR, t(4, 4)), // leave
    simple_block(Side.NEAR, t(0, 4)), // sponge
    simple_block(Side.NEAR, t(1, 4)), // glass
    simple_block(Side.NEAR, t(0, 11)), // lapis lazuli ore
    simple_block(Side.NEAR, t(0, 10)), // lapis lazuli block
    simple_block(Side.NEAR, t(14, 3)), // dispenser
    simple_block(Side.NEAR, t(0, 13)), // sandstone
    simple_block(Side.NEAR, t(2, 10)), // noteblock
    [], // bed
    [], // powered rail
    [], // detector rail
    [], // sticky piston
    [], // cobweb
    [], // tall grass
    [], // dead bush
    [], // piston
    [], // piston extension
    [], // wool
    [], // block moved by piston
    [], // dandelion
    [], // rose
    [], // brown mushroom
    [], // red mushroom
    simple_block(Side.NEAR, t(7, 2)), // gold block
    simple_block(Side.NEAR, t(6, 2)), // iron block
    simple_block(Side.NEAR, t(5, 1)), // double slab
    [], // slab
    simple_block(Side.NEAR, t(7, 1)), // brick
    simple_block(Side.NEAR, t(8, 1)), // tnt
    simple_block(Side.NEAR, t(3, 3)), // bookshelf
    simple_block(Side.NEAR, t(4, 3)), // mossy stone
    simple_block(Side.NEAR, t(5, 3)), // obsidian
    [], // torch
    [], // fire
    simple_block(Side.NEAR, t(1, 5)), // spawner
    [], // wooden stair
    [], // chest
    [], // redstone wire
    simple_block(Side.NEAR, t(2, 4)), // diamond ore
    simple_block(Side.NEAR, t(8, 2)), // diamond block
    simple_block(Side.NEAR, t(12, 4)), // crafting table
    [], // wheat
    [], // farmland
    simple_block(Side.NEAR, t(12, 3)),  // furnace
    simple_block(Side.NEAR, t(13, 4)),  // burning furnace
    [], // sign post
    [], // wooden door
    [], // ladder
    [], // rail
    [], // cobblestone stair
    [], // wall sign
    [], // lever
    [], // stone pressure plate
    [], // iron door
    [], // wooden pressure plate
    simple_block(Side.NEAR, t(3, 4)), // redstone ore
    simple_block(Side.NEAR, t(3, 4)), // glowing redstone ore
    [], // redstone torch
    [], // redstone torch on
    [], // stone button
    [], // snow
    simple_block(Side.NEAR, t(3, 5)), // ice
    simple_block(Side.NEAR, t(2, 5)), // snow block
    [], // cactus
    simple_block(Side.NEAR, t(8, 5)), // clay block
    [], // sugar cane
    simple_block(Side.NEAR, t(10, 5)), // jukebox
    [], // fence
    simple_block(Side.NEAR, t(7, 8)), // pumpkin
    simple_block(Side.NEAR, t(7, 7)), // netherrack
    simple_block(Side.NEAR, t(8, 7)), // soul sand
    simple_block(Side.NEAR, t(9, 7)), // glowstone block
    [], // portal
    simple_block(Side.NEAR, t(8, 8)), // jack-o-lantern
    [], // cake block
    [], // redstone repeater
    [], // redstone repeater on
    [], // locked chest
    [], // trapdoor
    [], // hidden silverfish
    simple_block(Side.NEAR, t(6, 4)), // stone brick
    [], // huge brown mushroom
    [], // huge red mushroom
    [], // iron bar
    [], // glass pane
    simple_block(Side.NEAR, t(8, 9)), // melon
    [], // pumpkin stem
    [], // melon stem
    [], // vine
    [], // fence gate
    [], // brick stair
    [], // stone brick stair
    simple_block(Side.NEAR, t(13, 5)), // mycelium
    [], // lilly pad
    simple_block(Side.NEAR, t(0, 15)), // nether brick
    [], // nether brick fence
    [], // nether wart
    [], // nether brick stair
    [], // enchantment table
    [], // brewing stand
    simple_block(Side.NEAR, t(10, 10)), // cauldron
    [], // end portal
    [], // end portal frame
    simple_block(Side.NEAR, t(15, 11)), // end stone
    [], // dragon egg
    simple_block(Side.NEAR, t(3, 14)), // redstone lamp
    simple_block(Side.NEAR, t(4, 14)), // redstone lamp on
    [], // wooden double slab
    [], // wooden slab
    [], // cocoa plant
    [], // sandstone stairs
    simple_block(Side.NEAR, t(11, 11)), // emerald ore
    [], // ender chest
    [], // tripwire hook
    [], // tripwire
    simple_block(Side.NEAR, t(9, 2)), // emerald block
    [], // spruce wood stairs
    [], // birch wood stairs
    [], // jungle wood stairs
    [], // command block
    []  // beacon block
];

Vertex[][BLOCK_IDS] BLOCK_VERTICES_FAR = [
    [], // air
    simple_block(Side.FAR, t(1, 1)), // stone
    simple_block(Side.FAR, t(3, 1), t(6, 3)), // grass
    simple_block(Side.FAR, t(2, 1)), // dirt
    simple_block(Side.FAR, t(0, 2)), // cobble
    simple_block(Side.FAR, t(4, 1)), // wooden plank
    [], // sapling
    simple_block(Side.FAR, t(1, 2)), // bedrock
    [], // water
    [], // stationary water
    [], // lava
    [], // stationary lava
    simple_block(Side.FAR, t(2, 2)), // sand
    simple_block(Side.FAR, t(3, 2)), // gravel
    simple_block(Side.FAR, t(0, 3)), // gold ore
    simple_block(Side.FAR, t(1, 3)), // iron ore
    simple_block(Side.FAR, t(2, 3)), // coal ore
    simple_block(Side.FAR, t(4, 2)), // wood
    simple_block(Side.FAR, t(4, 4)), // leave
    simple_block(Side.FAR, t(0, 4)), // sponge
    simple_block(Side.FAR, t(1, 4)), // glass
    simple_block(Side.FAR, t(0, 11)), // lapis lazuli ore
    simple_block(Side.FAR, t(0, 10)), // lapis lazuli block
    simple_block(Side.FAR, t(13, 3)), // dispenser
    simple_block(Side.FAR, t(0, 13)), // sandstone
    simple_block(Side.FAR, t(2, 10)), // noteblock
    [], // bed
    [], // powered rail
    [], // detector rail
    [], // sticky piston
    [], // cobweb
    [], // tall grass
    [], // dead bush
    [], // piston
    [], // piston extension
    [], // wool
    [], // block moved by piston
    [], // dandelion
    [], // rose
    [], // brown mushroom
    [], // red mushroom
    simple_block(Side.FAR, t(7, 2)), // gold block
    simple_block(Side.FAR, t(6, 2)), // iron block
    simple_block(Side.FAR, t(5, 1)), // double slab
    [], // slab
    simple_block(Side.FAR, t(7, 1)), // brick
    simple_block(Side.FAR, t(8, 1)), // tnt
    simple_block(Side.FAR, t(3, 3)), // bookshelf
    simple_block(Side.FAR, t(4, 3)), // mossy stone
    simple_block(Side.FAR, t(5, 3)), // obsidian
    [], // torch
    [], // fire
    simple_block(Side.FAR, t(1, 5)), // spawner
    [], // wooden stair
    [], // chest
    [], // redstone wire
    simple_block(Side.FAR, t(2, 4)), // diamond ore
    simple_block(Side.FAR, t(8, 2)), // diamond block
    simple_block(Side.FAR, t(12, 4)), // crafting table
    [], // wheat
    [], // farmland
    simple_block(Side.FAR, t(13, 3)),  // furnace
    simple_block(Side.FAR, t(13, 3)),  // burning furnace
    [], // sign post
    [], // wooden door
    [], // ladder
    [], // rail
    [], // cobblestone stair
    [], // wall sign
    [], // lever
    [], // stone pressure plate
    [], // iron door
    [], // wooden pressure plate
    simple_block(Side.FAR, t(3, 4)), // redstone ore
    simple_block(Side.FAR, t(3, 4)), // glowing redstone ore
    [], // redstone torch
    [], // redstone torch on
    [], // stone button
    [], // snow
    simple_block(Side.FAR, t(3, 5)), // ice
    simple_block(Side.FAR, t(2, 5)), // snow block
    [], // cactus
    simple_block(Side.FAR, t(8, 5)), // clay block
    [], // sugar cane
    simple_block(Side.FAR, t(10, 5)), // jukebox
    [], // fence
    simple_block(Side.FAR, t(6, 8)), // pumpkin
    simple_block(Side.FAR, t(7, 7)), // netherrack
    simple_block(Side.FAR, t(8, 7)), // soul sand
    simple_block(Side.FAR, t(9, 7)), // glowstone block
    [], // portal
    simple_block(Side.FAR, t(6, 8)), // jack-o-lantern
    [], // cake block
    [], // redstone repeater
    [], // redstone repeater on
    [], // locked chest
    [], // trapdoor
    [], // hidden silverfish
    simple_block(Side.FAR, t(6, 4)), // stone brick
    [], // huge brown mushroom
    [], // huge red mushroom
    [], // iron bar
    [], // glass pane
    simple_block(Side.FAR, t(8, 9)), // melon
    [], // pumpkin stem
    [], // melon stem
    [], // vine
    [], // fence gate
    [], // brick stair
    [], // stone brick stair
    simple_block(Side.FAR, t(13, 5)), // mycelium
    [], // lilly pad
    simple_block(Side.FAR, t(0, 15)), // nether brick
    [], // nether brick fence
    [], // nether wart
    [], // nether brick stair
    [], // enchantment table
    [], // brewing stand
    simple_block(Side.FAR, t(10, 10)), // cauldron
    [], // end portal
    [], // end portal frame
    simple_block(Side.FAR, t(15, 11)), // end stone
    [], // dragon egg
    simple_block(Side.FAR, t(3, 14)), // redstone lamp
    simple_block(Side.FAR, t(4, 14)), // redstone lamp on
    [], // wooden double slab
    [], // wooden slab
    [], // cocoa plant
    [], // sandstone stairs
    simple_block(Side.FAR, t(11, 11)), // emerald ore
    [], // ender chest
    [], // tripwire hook
    [], // tripwire
    simple_block(Side.FAR, t(9, 2)), // emerald block
    [], // spruce wood stairs
    [], // birch wood stairs
    [], // jungle wood stairs
    [], // command block
    []  // beacon block
];

Vertex[][BLOCK_IDS] BLOCK_VERTICES_TOP = [
    [], // air
    simple_block(Side.TOP, t(1, 1)), // stone
    simple_block(Side.TOP, t(0, 1)), // grass
    simple_block(Side.TOP, t(2, 1)), // dirt
    simple_block(Side.TOP, t(0, 2)), // cobble
    simple_block(Side.TOP, t(4, 1)), // wooden plank
    [], // sapling
    simple_block(Side.TOP, t(1, 2)), // bedrock
    [], // water
    [], // stationary water
    [], // lava
    [], // stationary lava
    simple_block(Side.TOP, t(2, 2)), // sand
    simple_block(Side.TOP, t(3, 2)), // gravel
    simple_block(Side.TOP, t(0, 3)), // gold ore
    simple_block(Side.TOP, t(1, 3)), // iron ore
    simple_block(Side.TOP, t(2, 3)), // coal ore
    simple_block(Side.TOP, t(5, 2)), // wood
    simple_block(Side.TOP, t(4, 4)), // leave
    simple_block(Side.TOP, t(0, 4)), // sponge
    simple_block(Side.TOP, t(1, 4)), // glass
    simple_block(Side.TOP, t(0, 11)), // lapis lazuli ore
    simple_block(Side.TOP, t(0, 10)), // lapis lazuli block
    simple_block(Side.TOP, t(14, 4)), // dispenser
    simple_block(Side.TOP, t(0, 12)), // sandstone
    simple_block(Side.TOP, t(2, 10)), // noteblock
    [], // bed
    [], // powered rail
    [], // detector rail
    [], // sticky piston
    [], // cobweb
    [], // tall grass
    [], // dead bush
    [], // piston
    [], // piston extension
    [], // wool
    [], // block moved by piston
    [], // dandelion
    [], // rose
    [], // brown mushroom
    [], // red mushroom
    simple_block(Side.TOP, t(7, 2)), // gold block
    simple_block(Side.TOP, t(6, 2)), // iron block
    simple_block(Side.TOP, t(5, 1)), // double slab
    [], // slab
    simple_block(Side.TOP, t(7, 1)), // brick
    simple_block(Side.TOP, t(9, 1)), // tnt
    simple_block(Side.TOP, t(1, 4)), // bookshelf
    simple_block(Side.TOP, t(4, 3)), // mossy stone
    simple_block(Side.TOP, t(5, 3)), // obsidian
    [], // torch
    [], // fire
    simple_block(Side.TOP, t(1, 5)), // spawner
    [], // wooden stair
    [], // chest
    [], // redstone wire
    simple_block(Side.TOP, t(2, 4)), // diamond ore
    simple_block(Side.TOP, t(8, 2)), // diamond block
    simple_block(Side.TOP, t(4, 1)), // crafting table
    [], // wheat
    [], // farmland
    simple_block(Side.TOP, t(14, 4)),  // furnace
    simple_block(Side.TOP, t(14, 4)),  // burning furnace
    [], // sign post
    [], // wooden door
    [], // ladder
    [], // rail
    [], // cobblestone stair
    [], // wall sign
    [], // lever
    [], // stone pressure plate
    [], // iron door
    [], // wooden pressure plate
    simple_block(Side.TOP, t(3, 4)), // redstone ore
    simple_block(Side.TOP, t(3, 4)), // glowing redstone ore
    [], // redstone torch
    [], // redstone torch on
    [], // stone button
    [], // snow
    simple_block(Side.TOP, t(3, 5)), // ice
    simple_block(Side.TOP, t(2, 5)), // snow block
    [], // cactus
    simple_block(Side.TOP, t(8, 5)), // clay block
    [], // sugar cane
    simple_block(Side.TOP, t(11, 5)), // jukebox
    [], // fence
    simple_block(Side.TOP, t(6, 8)), // pumpkin
    simple_block(Side.TOP, t(7, 7)), // netherrack
    simple_block(Side.TOP, t(8, 7)), // soul sand
    simple_block(Side.TOP, t(9, 7)), // glowstone block
    [], // portal
    simple_block(Side.TOP, t(6, 8)), // jack-o-lantern
    [], // cake block
    [], // redstone repeater
    [], // redstone repeater on
    [], // locked chest
    [], // trapdoor
    [], // hidden silverfish
    simple_block(Side.TOP, t(6, 4)), // stone brick
    [], // huge brown mushroom
    [], // huge red mushroom
    [], // iron bar
    [], // glass pane
    simple_block(Side.TOP, t(9, 9)), // melon
    [], // pumpkin stem
    [], // melon stem
    [], // vine
    [], // fence gate
    [], // brick stair
    [], // stone brick stair
    simple_block(Side.TOP, t(0, 1)), // mycelium
    [], // lilly pad
    simple_block(Side.TOP, t(0, 15)), // nether brick
    [], // nether brick fence
    [], // nether wart
    [], // nether brick stair
    [], // enchantment table
    [], // brewing stand
    simple_block(Side.TOP, t(10, 9)), // cauldron
    [], // end portal
    [], // end portal frame
    simple_block(Side.TOP, t(15, 11)), // end stone
    [], // dragon egg
    simple_block(Side.TOP, t(3, 14)), // redstone lamp
    simple_block(Side.TOP, t(4, 14)), // redstone lamp on
    [], // wooden double slab
    [], // wooden slab
    [], // cocoa plant
    [], // sandstone stairs
    simple_block(Side.TOP, t(11, 11)), // emerald ore
    [], // ender chest
    [], // tripwire hook
    [], // tripwire
    simple_block(Side.TOP, t(9, 2)), // emerald block
    [], // spruce wood stairs
    [], // birch wood stairs
    [], // jungle wood stairs
    [], // command block
    []  // beacon block
];

Vertex[][BLOCK_IDS] BLOCK_VERTICES_BOTTOM = [
    [], // air
    simple_block(Side.BOTTOM, t(1, 1)), // stone
    simple_block(Side.BOTTOM, t(2, 1)), // grass
    simple_block(Side.BOTTOM, t(2, 1)), // dirt
    simple_block(Side.BOTTOM, t(0, 2)), // cobble
    simple_block(Side.BOTTOM, t(4, 1)), // wooden plank
    [], // sapling
    simple_block(Side.BOTTOM, t(1, 2)), // bedrock
    [], // water
    [], // stationary water
    [], // lava
    [], // stationary lava
    simple_block(Side.BOTTOM, t(2, 2)), // sand
    simple_block(Side.BOTTOM, t(3, 2)), // gravel
    simple_block(Side.BOTTOM, t(0, 3)), // gold ore
    simple_block(Side.BOTTOM, t(1, 3)), // iron ore
    simple_block(Side.BOTTOM, t(2, 3)), // coal ore
    simple_block(Side.BOTTOM, t(5, 2)), // wood
    simple_block(Side.BOTTOM, t(4, 4)), // leave
    simple_block(Side.BOTTOM, t(0, 4)), // sponge
    simple_block(Side.BOTTOM, t(1, 4)), // glass
    simple_block(Side.BOTTOM, t(0, 11)), // lapis lazuli ore
    simple_block(Side.BOTTOM, t(0, 10)), // lapis lazuli block
    simple_block(Side.BOTTOM, t(13, 3)), // dispenser
    simple_block(Side.BOTTOM, t(0, 14)), // sandstone
    simple_block(Side.BOTTOM, t(2, 10)), // noteblock
    [], // bed
    [], // powered rail
    [], // detector rail
    [], // sticky piston
    [], // cobweb
    [], // tall grass
    [], // dead bush
    [], // piston
    [], // piston extension
    [], // wool
    [], // block moved by piston
    [], // dandelion
    [], // rose
    [], // brown mushroom
    [], // red mushroom
    simple_block(Side.BOTTOM, t(7, 2)), // gold block
    simple_block(Side.BOTTOM, t(6, 2)), // iron block
    simple_block(Side.BOTTOM, t(5, 1)), // double slab
    [], // slab
    simple_block(Side.BOTTOM, t(7, 1)), // brick
    simple_block(Side.BOTTOM, t(10, 1)), // tnt
    simple_block(Side.BOTTOM, t(1, 4)), // bookshelf
    simple_block(Side.BOTTOM, t(4, 3)), // mossy stone
    simple_block(Side.BOTTOM, t(5, 3)), // obsidian
    [], // torch
    [], // fire
    simple_block(Side.BOTTOM, t(1, 5)), // spawner
    [], // wooden stair
    [], // chest
    [], // redstone wire
    simple_block(Side.BOTTOM, t(2, 4)), // diamond ore
    simple_block(Side.BOTTOM, t(8, 2)), // diamond block
    simple_block(Side.BOTTOM, t(4, 1)), // crafting table
    [], // wheat
    [], // farmland
    simple_block(Side.BOTTOM, t(14, 4)),  // furnace
    simple_block(Side.BOTTOM, t(14, 4)),  // burning furnace
    [], // sign post
    [], // wooden door
    [], // ladder
    [], // rail
    [], // cobblestone stair
    [], // wall sign
    [], // lever
    [], // stone pressure plate
    [], // iron door
    [], // wooden pressure plate
    simple_block(Side.BOTTOM, t(3, 4)), // redstone ore
    simple_block(Side.BOTTOM, t(3, 4)), // glowing redstone ore
    [], // redstone torch
    [], // redstone torch on
    [], // stone button
    [], // snow
    simple_block(Side.BOTTOM, t(3, 5)), // ice
    simple_block(Side.BOTTOM, t(2, 5)), // snow block
    [], // cactus
    simple_block(Side.BOTTOM, t(8, 5)), // clay block
    [], // sugar cane
    simple_block(Side.BOTTOM, t(10, 5)), // jukebox
    [], // fence
    simple_block(Side.BOTTOM, t(6, 9)), // pumpkin
    simple_block(Side.BOTTOM, t(7, 7)), // netherrack
    simple_block(Side.BOTTOM, t(8, 7)), // soul sand
    simple_block(Side.BOTTOM, t(9, 7)), // glowstone block
    [], // portal
    simple_block(Side.BOTTOM, t(6, 9)), // jack-o-lantern
    [], // cake block
    [], // redstone repeater
    [], // redstone repeater on
    [], // locked chest
    [], // trapdoor
    [], // hidden silverfish
    simple_block(Side.BOTTOM, t(6, 4)), // stone brick
    [], // huge brown mushroom
    [], // huge red mushroom
    [], // iron bar
    [], // glass pane
    simple_block(Side.BOTTOM, t(8, 9)), // melon
    [], // pumpkin stem
    [], // melon stem
    [], // vine
    [], // fence gate
    [], // brick stair
    [], // stone brick stair
    simple_block(Side.BOTTOM, t(2, 1)), // mycelium
    [], // lilly pad
    simple_block(Side.BOTTOM, t(0, 15)), // nether brick
    [], // nether brick fence
    [], // nether wart
    [], // nether brick stair
    [], // enchantment table
    [], // brewing stand
    simple_block(Side.BOTTOM, t(10, 9)), // cauldron
    [], // end portal
    [], // end portal frame
    simple_block(Side.BOTTOM, t(15, 11)), // end stone
    [], // dragon egg
    simple_block(Side.BOTTOM, t(3, 14)), // redstone lamp
    simple_block(Side.BOTTOM, t(4, 14)), // redstone lamp on
    [], // wooden double slab
    [], // wooden slab
    [], // cocoa plant
    [], // sandstone stairs
    simple_block(Side.BOTTOM, t(11, 11)), // emerald ore
    [], // ender chest
    [], // tripwire hook
    [], // tripwire
    simple_block(Side.BOTTOM, t(9, 2)), // emerald block
    [], // spruce wood stairs
    [], // birch wood stairs
    [], // jungle wood stairs
    [], // command block
    []  // beacon block
];

ref Vertex[] get_vertices(Side side, T)(T index) if(isIntegral!T) {
    static if(side == Side.LEFT) {
        return BLOCK_VERTICES_LEFT[index];
    } else static if(side == Side.RIGHT) {
        return BLOCK_VERTICES_RIGHT[index];
    } else static if(side == Side.NEAR) {
        return BLOCK_VERTICES_NEAR[index];
    } else static if(side == Side.FAR) {
        return BLOCK_VERTICES_FAR[index];
    } else static if(side == Side.TOP) {
        return BLOCK_VERTICES_TOP[index];
    } else static if(side == Side.BOTTOM) {
        return BLOCK_VERTICES_BOTTOM[index];
    } else static if(side == Side.ALL) {
        static assert(false, "can only return vertices for one side at a time");
    } else {
        static assert(false, "unknown side");
    }
}