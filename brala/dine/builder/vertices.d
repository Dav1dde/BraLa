module brala.dine.builder.vertices;

private {
    import std.traits : isIntegral;

    import brala.dine.builder.tessellator : Vertex;
    import brala.dine.builder.constants : Side;
}

public import brala.dine.builder.vertices_.tex;
public import brala.dine.builder.vertices_.blocks;
public import brala.dine.builder.vertices_.slabs;
public import brala.dine.builder.vertices_.stairs;
public import brala.dine.builder.vertices_.plants;
public import brala.dine.builder.vertices_.rails;
public import brala.dine.builder.vertices_.misc;
public import brala.dine.builder.vertices_.redstone;


struct CubeSideData {
    float[3][4] positions; // 3*4, it's a cube!
    float[3] normal;
}

enum size_t BLOCK_IDS = 139;

// stuipid dmd bug
private {
    import brala.dine.builder.vertices_.util;
    
    short[2][4] t(short x, short y) { return TextureSlice(x, y).texcoords; }

    Vertex[] simple_block_(Side side, short[2][4] texture_slice) pure {
        return simple_block_(side, texture_slice, nslice);
    }

    Vertex[] simple_block_(Side side, short[2][4] texture_slice, short[2][4] mask_slice) pure {
        CubeSideData cbsd = CUBE_VERTICES[side];

        mixin(mk_vertices);
        return data.dup;
    }
}

Vertex[][BLOCK_IDS] BLOCK_VERTICES_LEFT = [
    [], // air
    simple_block_(Side.LEFT, t(1, 1)), // stone
    simple_block_(Side.LEFT, t(3, 1), t(6, 3)), // grass
    simple_block_(Side.LEFT, t(2, 1)), // dirt
    simple_block_(Side.LEFT, t(0, 2)), // cobble
    simple_block_(Side.LEFT, t(4, 1)), // wooden plank
    [], // sapling
    simple_block_(Side.LEFT, t(1, 2)), // bedrock
    [], // water
    [], // stationary water
    [], // lava
    [], // stationary lava
    simple_block_(Side.LEFT, t(2, 2)), // sand
    simple_block_(Side.LEFT, t(3, 2)), // gravel
    simple_block_(Side.LEFT, t(0, 3)), // gold ore
    simple_block_(Side.LEFT, t(1, 3)), // iron ore
    simple_block_(Side.LEFT, t(2, 3)), // coal ore
    simple_block_(Side.LEFT, t(4, 2)), // wood
    simple_block_(Side.LEFT, t(4, 4)), // leave
    simple_block_(Side.LEFT, t(0, 4)), // sponge
    simple_block_(Side.LEFT, t(1, 4)), // glass
    simple_block_(Side.LEFT, t(0, 11)), // lapis lazuli ore
    simple_block_(Side.LEFT, t(0, 10)), // lapis lazuli block
    simple_block_(Side.LEFT, t(13, 3)), // dispenser
    simple_block_(Side.LEFT, t(0, 13)), // sandstone
    simple_block_(Side.LEFT, t(2, 10)), // noteblock
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
    simple_block_(Side.LEFT, t(7, 2)), // gold block
    simple_block_(Side.LEFT, t(6, 2)), // iron block
    simple_block_(Side.LEFT, t(5, 1)), // double slab
    [], // slab
    simple_block_(Side.LEFT, t(7, 1)), // brick
    simple_block_(Side.LEFT, t(8, 1)), // tnt
    simple_block_(Side.LEFT, t(3, 3)), // bookshelf
    simple_block_(Side.LEFT, t(4, 3)), // mossy stone
    simple_block_(Side.LEFT, t(5, 3)), // obsidian
    [], // torch
    [], // fire
    simple_block_(Side.LEFT, t(1, 5)), // spawner
    [], // wooden stair
    [], // chest
    [], // redstone wire
    simple_block_(Side.LEFT, t(2, 4)), // diamond ore
    simple_block_(Side.LEFT, t(8, 2)), // diamond block
    simple_block_(Side.LEFT, t(12, 4)), // crafting table
    [], // wheat
    simple_block_(Side.LEFT, t(2, 1)), // farmland
    simple_block_(Side.LEFT, t(13, 3)),  // furnace
    simple_block_(Side.LEFT, t(13, 3)),  // burning furnace
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
    simple_block_(Side.LEFT, t(3, 4)), // redstone ore
    simple_block_(Side.LEFT, t(3, 4)), // glowing redstone ore
    [], // redstone torch
    [], // redstone torch on
    [], // stone button
    [], // snow
    simple_block_(Side.LEFT, t(3, 5)), // ice
    simple_block_(Side.LEFT, t(2, 5)), // snow block
    cactus_block(Side.LEFT, t(6, 5)), // cactus
    simple_block_(Side.LEFT, t(8, 5)), // clay block
    [], // sugar cane
    simple_block_(Side.LEFT, t(10, 5)), // jukebox
    [], // fence
    simple_block_(Side.LEFT, t(6, 8)), // pumpkin
    simple_block_(Side.LEFT, t(7, 7)), // netherrack
    simple_block_(Side.LEFT, t(8, 7)), // soul sand
    simple_block_(Side.LEFT, t(9, 7)), // glowstone block
    [], // portal
    simple_block_(Side.LEFT, t(6, 8)), // jack-o-lantern
    [], // cake block
    [], // redstone repeater
    [], // redstone repeater on
    [], // locked chest
    [], // trapdoor
    [], // hidden silverfish
    simple_block_(Side.LEFT, t(6, 4)), // stone brick
    [], // huge brown mushroom
    [], // huge red mushroom
    [], // iron bar
    [], // glass pane
    simple_block_(Side.LEFT, t(8, 9)), // melon
    [], // pumpkin stem
    [], // melon stem
    [], // vine
    [], // fence gate
    [], // brick stair
    [], // stone brick stair
    simple_block_(Side.LEFT, t(13, 5)), // mycelium
    [], // lilly pad
    simple_block_(Side.LEFT, t(0, 15)), // nether brick
    [], // nether brick fence
    [], // nether wart
    [], // nether brick stair
    [], // enchantment table
    [], // brewing stand
    simple_block_(Side.LEFT, t(10, 10)), // cauldron
    [], // end portal
    [], // end portal frame
    simple_block_(Side.LEFT, t(15, 11)), // end stone
    [], // dragon egg
    simple_block_(Side.LEFT, t(3, 14)), // redstone lamp
    simple_block_(Side.LEFT, t(4, 14)), // redstone lamp on
    [], // wooden double slab
    [], // wooden slab
    [], // cocoa plant
    [], // sandstone stairs
    simple_block_(Side.LEFT, t(11, 11)), // emerald ore
    [], // ender chest
    [], // tripwire hook
    [], // tripwire
    simple_block_(Side.LEFT, t(9, 2)), // emerald block
    [], // spruce wood stairs
    [], // birch wood stairs
    [], // jungle wood stairs
    [], // command block
    []  // beacon block
];

Vertex[][BLOCK_IDS] BLOCK_VERTICES_RIGHT = [
    [], // air
    simple_block_(Side.RIGHT, t(1, 1)), // stone
    simple_block_(Side.RIGHT, t(3, 1), t(6, 3)), // grass
    simple_block_(Side.RIGHT, t(2, 1)), // dirt
    simple_block_(Side.RIGHT, t(0, 2)), // cobble
    simple_block_(Side.RIGHT, t(4, 1)), // wooden plank
    [], // sapling
    simple_block_(Side.RIGHT, t(1, 2)), // bedrock
    [], // water
    [], // stationary water
    [], // lava
    [], // stationary lava
    simple_block_(Side.RIGHT, t(2, 2)), // sand
    simple_block_(Side.RIGHT, t(3, 2)), // gravel
    simple_block_(Side.RIGHT, t(0, 3)), // gold ore
    simple_block_(Side.RIGHT, t(1, 3)), // iron ore
    simple_block_(Side.RIGHT, t(2, 3)), // coal ore
    simple_block_(Side.RIGHT, t(4, 2)), // wood
    simple_block_(Side.RIGHT, t(4, 4)), // leave
    simple_block_(Side.RIGHT, t(0, 4)), // sponge
    simple_block_(Side.RIGHT, t(1, 4)), // glass
    simple_block_(Side.RIGHT, t(0, 11)), // lapis lazuli ore
    simple_block_(Side.RIGHT, t(0, 10)), // lapis lazuli block
    simple_block_(Side.RIGHT, t(13, 3)), // dispenser
    simple_block_(Side.RIGHT, t(0, 13)), // sandstone
    simple_block_(Side.RIGHT, t(2, 10)), // noteblock
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
    simple_block_(Side.RIGHT, t(7, 2)), // gold block
    simple_block_(Side.RIGHT, t(6, 2)), // iron block
    simple_block_(Side.RIGHT, t(5, 1)), // double slab
    [], // slab
    simple_block_(Side.RIGHT, t(7, 1)), // brick
    simple_block_(Side.RIGHT, t(8, 1)), // tnt
    simple_block_(Side.RIGHT, t(3, 3)), // bookshelf
    simple_block_(Side.RIGHT, t(4, 3)), // mossy stone
    simple_block_(Side.RIGHT, t(5, 3)), // obsidian
    [], // torch
    [], // fire
    simple_block_(Side.RIGHT, t(1, 5)), // spawner
    [], // wooden stair
    [], // chest
    [], // redstone wire
    simple_block_(Side.RIGHT, t(2, 4)), // diamond ore
    simple_block_(Side.RIGHT, t(8, 2)), // diamond block
    simple_block_(Side.RIGHT, t(12, 4)), // crafting table
    [], // wheat
    simple_block_(Side.RIGHT, t(2, 1)), // farmland
    simple_block_(Side.RIGHT, t(13, 3)),  // furnace
    simple_block_(Side.RIGHT, t(13, 3)),  // burning furnace
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
    simple_block_(Side.RIGHT, t(3, 4)), // redstone ore
    simple_block_(Side.RIGHT, t(3, 4)), // glowing redstone ore
    [], // redstone torch
    [], // redstone torch on
    [], // stone button
    [], // snow
    simple_block_(Side.RIGHT, t(3, 5)), // ice
    simple_block_(Side.RIGHT, t(2, 5)), // snow block
    cactus_block(Side.RIGHT, t(6, 5)), // cactus
    simple_block_(Side.RIGHT, t(8, 5)), // clay block
    [], // sugar cane
    simple_block_(Side.RIGHT, t(10, 5)), // jukebox
    [], // fence
    simple_block_(Side.RIGHT, t(6, 8)), // pumpkin
    simple_block_(Side.RIGHT, t(7, 7)), // netherrack
    simple_block_(Side.RIGHT, t(8, 7)), // soul sand
    simple_block_(Side.RIGHT, t(9, 7)), // glowstone block
    [], // portal
    simple_block_(Side.RIGHT, t(6, 8)), // jack-o-lantern
    [], // cake block
    [], // redstone repeater
    [], // redstone repeater on
    [], // locked chest
    [], // trapdoor
    [], // hidden silverfish
    simple_block_(Side.RIGHT, t(6, 4)), // stone brick
    [], // huge brown mushroom
    [], // huge red mushroom
    [], // iron bar
    [], // glass pane
    simple_block_(Side.RIGHT, t(8, 9)), // melon
    [], // pumpkin stem
    [], // melon stem
    [], // vine
    [], // fence gate
    [], // brick stair
    [], // stone brick stair
    simple_block_(Side.RIGHT, t(13, 5)), // mycelium
    [], // lilly pad
    simple_block_(Side.RIGHT, t(0, 15)), // nether brick
    [], // nether brick fence
    [], // nether wart
    [], // nether brick stair
    [], // enchantment table
    [], // brewing stand
    simple_block_(Side.RIGHT, t(10, 10)), // cauldron
    [], // end portal
    [], // end portal frame
    simple_block_(Side.RIGHT, t(15, 11)), // end stone
    [], // dragon egg
    simple_block_(Side.RIGHT, t(3, 14)), // redstone lamp
    simple_block_(Side.RIGHT, t(4, 14)), // redstone lamp on
    [], // wooden double slab
    [], // wooden slab
    [], // cocoa plant
    [], // sandstone stairs
    simple_block_(Side.RIGHT, t(11, 11)), // emerald ore
    [], // ender chest
    [], // tripwire hook
    [], // tripwire
    simple_block_(Side.RIGHT, t(9, 2)), // emerald block
    [], // spruce wood stairs
    [], // birch wood stairs
    [], // jungle wood stairs
    [], // command block
    []  // beacon block
];

Vertex[][BLOCK_IDS] BLOCK_VERTICES_NEAR = [
    [], // air
    simple_block_(Side.NEAR, t(1, 1)), // stone
    simple_block_(Side.NEAR, t(3, 1), t(6, 3)), // grass
    simple_block_(Side.NEAR, t(2, 1)), // dirt
    simple_block_(Side.NEAR, t(0, 2)), // cobble
    simple_block_(Side.NEAR, t(4, 1)), // wooden plank
    [], // sapling
    simple_block_(Side.NEAR, t(1, 2)), // bedrock
    [], // water
    [], // stationary water
    [], // lava
    [], // stationary lava
    simple_block_(Side.NEAR, t(2, 2)), // sand
    simple_block_(Side.NEAR, t(3, 2)), // gravel
    simple_block_(Side.NEAR, t(0, 3)), // gold ore
    simple_block_(Side.NEAR, t(1, 3)), // iron ore
    simple_block_(Side.NEAR, t(2, 3)), // coal ore
    simple_block_(Side.NEAR, t(4, 2)), // wood
    simple_block_(Side.NEAR, t(4, 4)), // leave
    simple_block_(Side.NEAR, t(0, 4)), // sponge
    simple_block_(Side.NEAR, t(1, 4)), // glass
    simple_block_(Side.NEAR, t(0, 11)), // lapis lazuli ore
    simple_block_(Side.NEAR, t(0, 10)), // lapis lazuli block
    simple_block_(Side.NEAR, t(13, 3)), // dispenser
    simple_block_(Side.NEAR, t(0, 13)), // sandstone
    simple_block_(Side.NEAR, t(2, 10)), // noteblock
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
    simple_block_(Side.NEAR, t(7, 2)), // gold block
    simple_block_(Side.NEAR, t(6, 2)), // iron block
    simple_block_(Side.NEAR, t(5, 1)), // double slab
    [], // slab
    simple_block_(Side.NEAR, t(7, 1)), // brick
    simple_block_(Side.NEAR, t(8, 1)), // tnt
    simple_block_(Side.NEAR, t(3, 3)), // bookshelf
    simple_block_(Side.NEAR, t(4, 3)), // mossy stone
    simple_block_(Side.NEAR, t(5, 3)), // obsidian
    [], // torch
    [], // fire
    simple_block_(Side.NEAR, t(1, 5)), // spawner
    [], // wooden stair
    [], // chest
    [], // redstone wire
    simple_block_(Side.NEAR, t(2, 4)), // diamond ore
    simple_block_(Side.NEAR, t(8, 2)), // diamond block
    simple_block_(Side.NEAR, t(12, 4)), // crafting table
    [], // wheat
    simple_block_(Side.NEAR, t(2, 1)), // farmland
    simple_block_(Side.NEAR, t(13, 3)),  // furnace
    simple_block_(Side.NEAR, t(13, 3)),  // burning furnace
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
    simple_block_(Side.NEAR, t(3, 4)), // redstone ore
    simple_block_(Side.NEAR, t(3, 4)), // glowing redstone ore
    [], // redstone torch
    [], // redstone torch on
    [], // stone button
    [], // snow
    simple_block_(Side.NEAR, t(3, 5)), // ice
    simple_block_(Side.NEAR, t(2, 5)), // snow block
    cactus_block(Side.NEAR, t(6, 5)), // cactus
    simple_block_(Side.NEAR, t(8, 5)), // clay block
    [], // sugar cane
    simple_block_(Side.NEAR, t(10, 5)), // jukebox
    [], // fence
    simple_block_(Side.NEAR, t(6, 8)), // pumpkin
    simple_block_(Side.NEAR, t(7, 7)), // netherrack
    simple_block_(Side.NEAR, t(8, 7)), // soul sand
    simple_block_(Side.NEAR, t(9, 7)), // glowstone block
    [], // portal
    simple_block_(Side.NEAR, t(6, 8)), // jack-o-lantern
    [], // cake block
    [], // redstone repeater
    [], // redstone repeater on
    [], // locked chest
    [], // trapdoor
    [], // hidden silverfish
    simple_block_(Side.NEAR, t(6, 4)), // stone brick
    [], // huge brown mushroom
    [], // huge red mushroom
    [], // iron bar
    [], // glass pane
    simple_block_(Side.NEAR, t(8, 9)), // melon
    [], // pumpkin stem
    [], // melon stem
    [], // vine
    [], // fence gate
    [], // brick stair
    [], // stone brick stair
    simple_block_(Side.NEAR, t(13, 5)), // mycelium
    [], // lilly pad
    simple_block_(Side.NEAR, t(0, 15)), // nether brick
    [], // nether brick fence
    [], // nether wart
    [], // nether brick stair
    [], // enchantment table
    [], // brewing stand
    simple_block_(Side.NEAR, t(10, 10)), // cauldron
    [], // end portal
    [], // end portal frame
    simple_block_(Side.NEAR, t(15, 11)), // end stone
    [], // dragon egg
    simple_block_(Side.NEAR, t(3, 14)), // redstone lamp
    simple_block_(Side.NEAR, t(4, 14)), // redstone lamp on
    [], // wooden double slab
    [], // wooden slab
    [], // cocoa plant
    [], // sandstone stairs
    simple_block_(Side.NEAR, t(11, 11)), // emerald ore
    [], // ender chest
    [], // tripwire hook
    [], // tripwire
    simple_block_(Side.NEAR, t(9, 2)), // emerald block
    [], // spruce wood stairs
    [], // birch wood stairs
    [], // jungle wood stairs
    [], // command block
    []  // beacon block
];

Vertex[][BLOCK_IDS] BLOCK_VERTICES_FAR = [
    [], // air
    simple_block_(Side.FAR, t(1, 1)), // stone
    simple_block_(Side.FAR, t(3, 1), t(6, 3)), // grass
    simple_block_(Side.FAR, t(2, 1)), // dirt
    simple_block_(Side.FAR, t(0, 2)), // cobble
    simple_block_(Side.FAR, t(4, 1)), // wooden plank
    [], // sapling
    simple_block_(Side.FAR, t(1, 2)), // bedrock
    [], // water
    [], // stationary water
    [], // lava
    [], // stationary lava
    simple_block_(Side.FAR, t(2, 2)), // sand
    simple_block_(Side.FAR, t(3, 2)), // gravel
    simple_block_(Side.FAR, t(0, 3)), // gold ore
    simple_block_(Side.FAR, t(1, 3)), // iron ore
    simple_block_(Side.FAR, t(2, 3)), // coal ore
    simple_block_(Side.FAR, t(4, 2)), // wood
    simple_block_(Side.FAR, t(4, 4)), // leave
    simple_block_(Side.FAR, t(0, 4)), // sponge
    simple_block_(Side.FAR, t(1, 4)), // glass
    simple_block_(Side.FAR, t(0, 11)), // lapis lazuli ore
    simple_block_(Side.FAR, t(0, 10)), // lapis lazuli block
    simple_block_(Side.FAR, t(13, 3)), // dispenser
    simple_block_(Side.FAR, t(0, 13)), // sandstone
    simple_block_(Side.FAR, t(2, 10)), // noteblock
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
    simple_block_(Side.FAR, t(7, 2)), // gold block
    simple_block_(Side.FAR, t(6, 2)), // iron block
    simple_block_(Side.FAR, t(5, 1)), // double slab
    [], // slab
    simple_block_(Side.FAR, t(7, 1)), // brick
    simple_block_(Side.FAR, t(8, 1)), // tnt
    simple_block_(Side.FAR, t(3, 3)), // bookshelf
    simple_block_(Side.FAR, t(4, 3)), // mossy stone
    simple_block_(Side.FAR, t(5, 3)), // obsidian
    [], // torch
    [], // fire
    simple_block_(Side.FAR, t(1, 5)), // spawner
    [], // wooden stair
    [], // chest
    [], // redstone wire
    simple_block_(Side.FAR, t(2, 4)), // diamond ore
    simple_block_(Side.FAR, t(8, 2)), // diamond block
    simple_block_(Side.FAR, t(12, 4)), // crafting table
    [], // wheat
    simple_block_(Side.FAR, t(2, 1)), // farmland
    simple_block_(Side.FAR, t(13, 3)),  // furnace
    simple_block_(Side.FAR, t(13, 3)),  // burning furnace
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
    simple_block_(Side.FAR, t(3, 4)), // redstone ore
    simple_block_(Side.FAR, t(3, 4)), // glowing redstone ore
    [], // redstone torch
    [], // redstone torch on
    [], // stone button
    [], // snow
    simple_block_(Side.FAR, t(3, 5)), // ice
    simple_block_(Side.FAR, t(2, 5)), // snow block
    cactus_block(Side.FAR, t(6, 5)), // cactus
    simple_block_(Side.FAR, t(8, 5)), // clay block
    [], // sugar cane
    simple_block_(Side.FAR, t(10, 5)), // jukebox
    [], // fence
    simple_block_(Side.FAR, t(6, 8)), // pumpkin
    simple_block_(Side.FAR, t(7, 7)), // netherrack
    simple_block_(Side.FAR, t(8, 7)), // soul sand
    simple_block_(Side.FAR, t(9, 7)), // glowstone block
    [], // portal
    simple_block_(Side.FAR, t(6, 8)), // jack-o-lantern
    [], // cake block
    [], // redstone repeater
    [], // redstone repeater on
    [], // locked chest
    [], // trapdoor
    [], // hidden silverfish
    simple_block_(Side.FAR, t(6, 4)), // stone brick
    [], // huge brown mushroom
    [], // huge red mushroom
    [], // iron bar
    [], // glass pane
    simple_block_(Side.FAR, t(8, 9)), // melon
    [], // pumpkin stem
    [], // melon stem
    [], // vine
    [], // fence gate
    [], // brick stair
    [], // stone brick stair
    simple_block_(Side.FAR, t(13, 5)), // mycelium
    [], // lilly pad
    simple_block_(Side.FAR, t(0, 15)), // nether brick
    [], // nether brick fence
    [], // nether wart
    [], // nether brick stair
    [], // enchantment table
    [], // brewing stand
    simple_block_(Side.FAR, t(10, 10)), // cauldron
    [], // end portal
    [], // end portal frame
    simple_block_(Side.FAR, t(15, 11)), // end stone
    [], // dragon egg
    simple_block_(Side.FAR, t(3, 14)), // redstone lamp
    simple_block_(Side.FAR, t(4, 14)), // redstone lamp on
    [], // wooden double slab
    [], // wooden slab
    [], // cocoa plant
    [], // sandstone stairs
    simple_block_(Side.FAR, t(11, 11)), // emerald ore
    [], // ender chest
    [], // tripwire hook
    [], // tripwire
    simple_block_(Side.FAR, t(9, 2)), // emerald block
    [], // spruce wood stairs
    [], // birch wood stairs
    [], // jungle wood stairs
    [], // command block
    []  // beacon block
];

Vertex[][BLOCK_IDS] BLOCK_VERTICES_TOP = [
    [], // air
    simple_block_(Side.TOP, t(1, 1)), // stone
    simple_block_(Side.TOP, t(0, 1)), // grass
    simple_block_(Side.TOP, t(2, 1)), // dirt
    simple_block_(Side.TOP, t(0, 2)), // cobble
    simple_block_(Side.TOP, t(4, 1)), // wooden plank
    [], // sapling
    simple_block_(Side.TOP, t(1, 2)), // bedrock
    [], // water
    [], // stationary water
    [], // lava
    [], // stationary lava
    simple_block_(Side.TOP, t(2, 2)), // sand
    simple_block_(Side.TOP, t(3, 2)), // gravel
    simple_block_(Side.TOP, t(0, 3)), // gold ore
    simple_block_(Side.TOP, t(1, 3)), // iron ore
    simple_block_(Side.TOP, t(2, 3)), // coal ore
    simple_block_(Side.TOP, t(5, 2)), // wood
    simple_block_(Side.TOP, t(4, 4)), // leave
    simple_block_(Side.TOP, t(0, 4)), // sponge
    simple_block_(Side.TOP, t(1, 4)), // glass
    simple_block_(Side.TOP, t(0, 11)), // lapis lazuli ore
    simple_block_(Side.TOP, t(0, 10)), // lapis lazuli block
    simple_block_(Side.TOP, t(14, 4)), // dispenser
    simple_block_(Side.TOP, t(0, 12)), // sandstone
    simple_block_(Side.TOP, t(2, 10)), // noteblock
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
    simple_block_(Side.TOP, t(7, 2)), // gold block
    simple_block_(Side.TOP, t(6, 2)), // iron block
    simple_block_(Side.TOP, t(6, 1)), // double slab
    [], // slab
    simple_block_(Side.TOP, t(7, 1)), // brick
    simple_block_(Side.TOP, t(9, 1)), // tnt
    simple_block_(Side.TOP, t(4, 1)), // bookshelf
    simple_block_(Side.TOP, t(4, 3)), // mossy stone
    simple_block_(Side.TOP, t(5, 3)), // obsidian
    [], // torch
    [], // fire
    simple_block_(Side.TOP, t(1, 5)), // spawner
    [], // wooden stair
    [], // chest
    [], // redstone wire
    simple_block_(Side.TOP, t(2, 4)), // diamond ore
    simple_block_(Side.TOP, t(8, 2)), // diamond block
    simple_block_(Side.TOP, t(4, 1)), // crafting table
    [], // wheat
    simple_block_(Side.TOP, t(6, 6)), // farmland
    simple_block_(Side.TOP, t(14, 4)),  // furnace
    simple_block_(Side.TOP, t(14, 4)),  // burning furnace
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
    simple_block_(Side.TOP, t(3, 4)), // redstone ore
    simple_block_(Side.TOP, t(3, 4)), // glowing redstone ore
    [], // redstone torch
    [], // redstone torch on
    [], // stone button
    [], // snow
    simple_block_(Side.TOP, t(3, 5)), // ice
    simple_block_(Side.TOP, t(2, 5)), // snow block
    cactus_block(Side.TOP, t(5, 5)), // cactus
    simple_block_(Side.TOP, t(8, 5)), // clay block
    [], // sugar cane
    simple_block_(Side.TOP, t(11, 5)), // jukebox
    [], // fence
    simple_block_(Side.TOP, t(6, 7)), // pumpkin
    simple_block_(Side.TOP, t(7, 7)), // netherrack
    simple_block_(Side.TOP, t(8, 7)), // soul sand
    simple_block_(Side.TOP, t(9, 7)), // glowstone block
    [], // portal
    simple_block_(Side.TOP, t(6, 7)), // jack-o-lantern
    [], // cake block
    [], // redstone repeater
    [], // redstone repeater on
    [], // locked chest
    [], // trapdoor
    [], // hidden silverfish
    simple_block_(Side.TOP, t(6, 4)), // stone brick
    [], // huge brown mushroom
    [], // huge red mushroom
    [], // iron bar
    [], // glass pane
    simple_block_(Side.TOP, t(9, 9)), // melon
    [], // pumpkin stem
    [], // melon stem
    [], // vine
    [], // fence gate
    [], // brick stair
    [], // stone brick stair
    simple_block_(Side.TOP, t(0, 1)), // mycelium
    [], // lilly pad
    simple_block_(Side.TOP, t(0, 15)), // nether brick
    [], // nether brick fence
    [], // nether wart
    [], // nether brick stair
    [], // enchantment table
    [], // brewing stand
    simple_block_(Side.TOP, t(10, 9)), // cauldron
    [], // end portal
    [], // end portal frame
    simple_block_(Side.TOP, t(15, 11)), // end stone
    [], // dragon egg
    simple_block_(Side.TOP, t(3, 14)), // redstone lamp
    simple_block_(Side.TOP, t(4, 14)), // redstone lamp on
    [], // wooden double slab
    [], // wooden slab
    [], // cocoa plant
    [], // sandstone stairs
    simple_block_(Side.TOP, t(11, 11)), // emerald ore
    [], // ender chest
    [], // tripwire hook
    [], // tripwire
    simple_block_(Side.TOP, t(9, 2)), // emerald block
    [], // spruce wood stairs
    [], // birch wood stairs
    [], // jungle wood stairs
    [], // command block
    []  // beacon block
];

Vertex[][BLOCK_IDS] BLOCK_VERTICES_BOTTOM = [
    [], // air
    simple_block_(Side.BOTTOM, t(1, 1)), // stone
    simple_block_(Side.BOTTOM, t(2, 1)), // grass
    simple_block_(Side.BOTTOM, t(2, 1)), // dirt
    simple_block_(Side.BOTTOM, t(0, 2)), // cobble
    simple_block_(Side.BOTTOM, t(4, 1)), // wooden plank
    [], // sapling
    simple_block_(Side.BOTTOM, t(1, 2)), // bedrock
    [], // water
    [], // stationary water
    [], // lava
    [], // stationary lava
    simple_block_(Side.BOTTOM, t(2, 2)), // sand
    simple_block_(Side.BOTTOM, t(3, 2)), // gravel
    simple_block_(Side.BOTTOM, t(0, 3)), // gold ore
    simple_block_(Side.BOTTOM, t(1, 3)), // iron ore
    simple_block_(Side.BOTTOM, t(2, 3)), // coal ore
    simple_block_(Side.BOTTOM, t(5, 2)), // wood
    simple_block_(Side.BOTTOM, t(4, 4)), // leave
    simple_block_(Side.BOTTOM, t(0, 4)), // sponge
    simple_block_(Side.BOTTOM, t(1, 4)), // glass
    simple_block_(Side.BOTTOM, t(0, 11)), // lapis lazuli ore
    simple_block_(Side.BOTTOM, t(0, 10)), // lapis lazuli block
    simple_block_(Side.BOTTOM, t(14, 4)), // dispenser
    simple_block_(Side.BOTTOM, t(0, 14)), // sandstone
    simple_block_(Side.BOTTOM, t(2, 10)), // noteblock
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
    simple_block_(Side.BOTTOM, t(7, 2)), // gold block
    simple_block_(Side.BOTTOM, t(6, 2)), // iron block
    simple_block_(Side.BOTTOM, t(6, 1)), // double slab
    [], // slab
    simple_block_(Side.BOTTOM, t(7, 1)), // brick
    simple_block_(Side.BOTTOM, t(10, 1)), // tnt
    simple_block_(Side.BOTTOM, t(4, 1)), // bookshelf
    simple_block_(Side.BOTTOM, t(4, 3)), // mossy stone
    simple_block_(Side.BOTTOM, t(5, 3)), // obsidian
    [], // torch
    [], // fire
    simple_block_(Side.BOTTOM, t(1, 5)), // spawner
    [], // wooden stair
    [], // chest
    [], // redstone wire
    simple_block_(Side.BOTTOM, t(2, 4)), // diamond ore
    simple_block_(Side.BOTTOM, t(8, 2)), // diamond block
    simple_block_(Side.BOTTOM, t(4, 1)), // crafting table
    [], // wheat
    simple_block_(Side.BOTTOM, t(2, 1)), // farmland
    simple_block_(Side.BOTTOM, t(14, 4)),  // furnace
    simple_block_(Side.BOTTOM, t(14, 4)),  // burning furnace
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
    simple_block_(Side.BOTTOM, t(3, 4)), // redstone ore
    simple_block_(Side.BOTTOM, t(3, 4)), // glowing redstone ore
    [], // redstone torch
    [], // redstone torch on
    [], // stone button
    [], // snow
    simple_block_(Side.BOTTOM, t(3, 5)), // ice
    simple_block_(Side.BOTTOM, t(2, 5)), // snow block
    cactus_block(Side.BOTTOM, t(7, 5)), // cactus
    simple_block_(Side.BOTTOM, t(8, 5)), // clay block
    [], // sugar cane
    simple_block_(Side.BOTTOM, t(10, 5)), // jukebox
    [], // fence
    simple_block_(Side.BOTTOM, t(6, 9)), // pumpkin
    simple_block_(Side.BOTTOM, t(7, 7)), // netherrack
    simple_block_(Side.BOTTOM, t(8, 7)), // soul sand
    simple_block_(Side.BOTTOM, t(9, 7)), // glowstone block
    [], // portal
    simple_block_(Side.BOTTOM, t(6, 9)), // jack-o-lantern
    [], // cake block
    [], // redstone repeater
    [], // redstone repeater on
    [], // locked chest
    [], // trapdoor
    [], // hidden silverfish
    simple_block_(Side.BOTTOM, t(6, 4)), // stone brick
    [], // huge brown mushroom
    [], // huge red mushroom
    [], // iron bar
    [], // glass pane
    simple_block_(Side.BOTTOM, t(8, 9)), // melon
    [], // pumpkin stem
    [], // melon stem
    [], // vine
    [], // fence gate
    [], // brick stair
    [], // stone brick stair
    simple_block_(Side.BOTTOM, t(2, 1)), // mycelium
    [], // lilly pad
    simple_block_(Side.BOTTOM, t(0, 15)), // nether brick
    [], // nether brick fence
    [], // nether wart
    [], // nether brick stair
    [], // enchantment table
    [], // brewing stand
    simple_block_(Side.BOTTOM, t(10, 9)), // cauldron
    [], // end portal
    [], // end portal frame
    simple_block_(Side.BOTTOM, t(15, 11)), // end stone
    [], // dragon egg
    simple_block_(Side.BOTTOM, t(3, 14)), // redstone lamp
    simple_block_(Side.BOTTOM, t(4, 14)), // redstone lamp on
    [], // wooden double slab
    [], // wooden slab
    [], // cocoa plant
    [], // sandstone stairs
    simple_block_(Side.BOTTOM, t(11, 11)), // emerald ore
    [], // ender chest
    [], // tripwire hook
    [], // tripwire
    simple_block_(Side.BOTTOM, t(9, 2)), // emerald block
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