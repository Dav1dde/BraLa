module brala.dine.vertices;

private {
    import std.array : join;

    import brala.dine.util : to_triangles;
}

enum Side : ubyte {
    LEFT,
    RIGHT,
    NEAR,
    FAR,
    TOP,
    BOTTOM
}

struct TextureSlice(float w, float h) {
    static const float width = w;
    static const float height = h;

    float x;
    float y;
    float x_step = 1.0f/width;
    float y_step = 1.0f/height;

    alias texcoords this;

    this(float lower_left_x, float lower_left_y) {
        x = lower_left_x/width;
        y = lower_left_y/height;
    }

    @property float[2][4] texcoords() {
             // lower left, lower right,   upper left,    upper right
        return [[x, y],     [x+x_step, y], [x, y-y_step], [x+x_step, y-y_step]];
    }
}

alias TextureSlice!(16.0f, 16.0f) MCTextureSlice;

struct CubeSideData {
    float[3][4] positions; // 3*4, it's a cube!
    float[3] normal;
}

// TODO texcoords
immutable CubeSideData[6] CUBE_VERTICES = [
    { [[-0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, 0.5f], [-0.5f, 0.5f, 0.5f], [-0.5f, 0.5f, -0.5f]], // left
       [-1.0f, 0.0f, 0.0f] },

    { [[0.5f, -0.5f, -0.5f], [0.5f, 0.5f, -0.5f], [0.5f, 0.5f, 0.5f], [0.5f, -0.5f, 0.5f]], // right
       [1.0f, 0.0f, 0.0f] },

    { [[-0.5f, -0.5f, 0.5f], [0.5f, -0.5f, 0.5f], [0.5f, 0.5f, 0.5f], [-0.5f, 0.5f, 0.5f]], // front
       [0.0f, 0.0f, 1.0f] },

    { [[-0.5f, -0.5f, -0.5f], [-0.5f, 0.5f, -0.5f], [0.5f, 0.5f, -0.5f], [0.5f, -0.5f, -0.5f]], // back
       [0.0f, 0.0f, -1.0f] },

    { [[-0.5f, 0.5f, -0.5f], [-0.5f, 0.5f, 0.5f], [0.5f, 0.5f, 0.5f], [0.5f, 0.5f, -0.5f]], // top
       [0.0f, 1.0f, 0.0f]  },

    { [[-0.5f, -0.5f, -0.5f], [0.5f, -0.5f, -0.5f], [0.5f, -0.5f, 0.5f], [-0.5f, -0.5f, 0.5f]], // bottom
       [0.0f, -1.0f, 0.0f] }
];

float[] simple_block(Side side, MCTextureSlice texture_slice) {
    CubeSideData cbsd = CUBE_VERTICES[side];

    float[3][6] positions = to_triangles(cbsd.positions);
    float[2][6] texcoords = to_triangles(texture_slice.texcoords);
    
    return join([positions[0], cbsd.normal, texcoords[0],
                 positions[1], cbsd.normal, texcoords[1],
                 positions[2], cbsd.normal, texcoords[2],
                 positions[3], cbsd.normal, texcoords[3],
                 positions[4], cbsd.normal, texcoords[4],
                 positions[5], cbsd.normal, texcoords[5]]);
}

private alias MCTextureSlice t;

version(update_vertices) {
    float[][] BLOCK_VERTICES_LEFT = [
        [], // air
        simple_block(Side.LEFT, t(1, 1)), // stone
        simple_block(Side.LEFT, t(3, 1)), // grass
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
        simple_block(Side.LEFT, t(2, 2)), // wood
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
        [], // double slab
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
        simple_block(Side.LEFT, t(4, 4)), // diamond ore
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
        [], // stone brick
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
        [], // enchantment table
        [], // brewing stand
        simple_block(Side.LEFT, t(10, 10)), // cauldron
        [], // end portal
        [], // end portal frame
        simple_block(Side.LEFT, t(15, 11)), // end stone
        [], // dragon egg
        simple_block(Side.LEFT, t(3, 14)), // redstone lamp
        simple_block(Side.LEFT, t(4, 14)), // redstone lamp on
        [], // padding to 128 blocks
        [],
        [],
        [],
        []
    ];

    float[][] BLOCK_VERTICES_RIGHT = [
        [], // air
        simple_block(Side.RIGHT, t(1, 1)), // stone
        simple_block(Side.RIGHT, t(3, 1)), // grass
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
        simple_block(Side.RIGHT, t(2, 2)), // wood
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
        [], // double slab
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
        simple_block(Side.RIGHT, t(4, 4)), // diamond ore
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
        [], // stone brick
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
        [], // enchantment table
        [], // brewing stand
        simple_block(Side.RIGHT, t(10, 10)), // cauldron
        [], // end portal
        [], // end portal frame
        simple_block(Side.RIGHT, t(15, 11)), // end stone
        [], // dragon egg
        simple_block(Side.RIGHT, t(3, 14)), // redstone lamp
        simple_block(Side.RIGHT, t(4, 14)), // redstone lamp on
        [], // padding to 128 blocks
        [],
        [],
        [],
        []
    ];

    float[][] BLOCK_VERTICES_NEAR = [
        [], // air
        simple_block(Side.NEAR, t(1, 1)), // stone
        simple_block(Side.NEAR, t(3, 1)), // grass
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
        simple_block(Side.NEAR, t(2, 2)), // wood
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
        [], // double slab
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
        simple_block(Side.NEAR, t(4, 4)), // diamond ore
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
        [], // stone brick
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
        [], // enchantment table
        [], // brewing stand
        simple_block(Side.NEAR, t(10, 10)), // cauldron
        [], // end portal
        [], // end portal frame
        simple_block(Side.NEAR, t(15, 11)), // end stone
        [], // dragon egg
        simple_block(Side.NEAR, t(3, 14)), // redstone lamp
        simple_block(Side.NEAR, t(4, 14)), // redstone lamp on
        [], // padding to 128 blocks
        [],
        [],
        [],
        []
    ];

    float[][] BLOCK_VERTICES_FAR = [
        [], // air
        simple_block(Side.FAR, t(1, 1)), // stone
        simple_block(Side.FAR, t(3, 1)), // grass
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
        simple_block(Side.FAR, t(2, 2)), // wood
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
        [], // double slab
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
        simple_block(Side.FAR, t(4, 4)), // diamond ore
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
        [], // stone brick
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
        [], // enchantment table
        [], // brewing stand
        simple_block(Side.FAR, t(10, 10)), // cauldron
        [], // end portal
        [], // end portal frame
        simple_block(Side.FAR, t(15, 11)), // end stone
        [], // dragon egg
        simple_block(Side.FAR, t(3, 14)), // redstone lamp
        simple_block(Side.FAR, t(4, 14)), // redstone lamp on
        [], // padding to 128 blocks
        [],
        [],
        [],
        []
    ];

    float[][] BLOCK_VERTICES_TOP = [
        [], // air
        simple_block(Side.TOP, t(1, 1)), // stone
        simple_block(Side.TOP, t(2, 1)), // grass
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
        simple_block(Side.TOP, t(2, 2)), // wood
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
        [], // double slab
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
        simple_block(Side.TOP, t(4, 4)), // diamond ore
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
        [], // stone brick
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
        [], // enchantment table
        [], // brewing stand
        simple_block(Side.TOP, t(10, 9)), // cauldron
        [], // end portal
        [], // end portal frame
        simple_block(Side.TOP, t(15, 11)), // end stone
        [], // dragon egg
        simple_block(Side.TOP, t(3, 14)), // redstone lamp
        simple_block(Side.TOP, t(4, 14)), // redstone lamp on
        [], // padding to 128 blocks
        [],
        [],
        [],
        []
    ];

    float[][] BLOCK_VERTICES_BOTTOM = [
        [], // air
        simple_block(Side.BOTTOM, t(1, 1)), // stone
        simple_block(Side.BOTTOM, t(0, 1)), // grass
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
        simple_block(Side.BOTTOM, t(2, 2)), // wood
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
        [], // double slab
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
        simple_block(Side.BOTTOM, t(4, 4)), // diamond ore
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
        [], // stone brick
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
        [], // enchantment table
        [], // brewing stand
        simple_block(Side.BOTTOM, t(10, 9)), // cauldron
        [], // end portal
        [], // end portal frame
        simple_block(Side.BOTTOM, t(15, 11)), // end stone
        [], // dragon egg
        simple_block(Side.BOTTOM, t(3, 14)), // redstone lamp
        simple_block(Side.BOTTOM, t(4, 14)), // redstone lamp on
        [], // padding to 128 blocks
        [],
        [],
        [],
        []
    ];

    static this() {
        import std.file;
        import std.string;

        string f = "brala/dine/vertices.txt";
        if(isFile(f)) {
            remove(f);
        }
        
        write(f, format("float[][] BLOCK_VERTICES_LEFT = %s;\n\n", BLOCK_VERTICES_LEFT));
        append(f, format("float[][] BLOCK_VERTICES_RIGHT = %s;\n\n", BLOCK_VERTICES_RIGHT));
        append(f, format("float[][] BLOCK_VERTICES_NEAR = %s;\n\n", BLOCK_VERTICES_NEAR));
        append(f, format("float[][] BLOCK_VERTICES_FAR = %s;\n\n", BLOCK_VERTICES_FAR));
        append(f, format("float[][] BLOCK_VERTICES_TOP = %s;\n\n", BLOCK_VERTICES_TOP));
        append(f, format("float[][] BLOCK_VERTICES_BOTTOM = %s;\n\n", BLOCK_VERTICES_BOTTOM));
    }
} else {
    mixin(import("vertices.txt"));
}