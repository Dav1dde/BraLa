module brala.dine.builder.blocks;

private {
}

enum BlockType {
    Air = 0,
    Block, // no metadata
    DataBlock, // metadata is important?
    NA // placeholder for non existent ids
}

struct BlockDescriptor {
    bool empty; // this is for tessellation, if true sides have to be rendered. or tessellate_neighbours
    bool opaque;
    BlockType type = BlockType.NA;
    string name;
}

private {
    alias BlockType.Air Air;
    alias BlockType.Block Block;
    alias BlockType.DataBlock DataBlock;
    alias BlockType.NA NA;
}

// some opaque values might be wrong
BlockDescriptor[256] BLOCKS = [
    { true,  false, Air,       "air" },
    { false, true,  Block,     "stone" },
    { false, true,  Block,     "grass" },
    { false, true,  Block,     "dirt" },
    { false, true,  Block,     "cobble" },
    { false, true,  Block,     "wooden plank" },
    { true,  false, DataBlock, "sapling" },
    { false, true,  Block,     "bedrock" },
    { true,  false, DataBlock, "water" },
    { true,  false, DataBlock, "stationary water" },
    { true,  false, DataBlock, "lava" },
    { true,  false, DataBlock, "stationary lava" },
    { false, true,  Block,     "sand" },
    { false, true,  Block,     "gravel" },
    { false, true,  Block,     "gold ore" },
    { false, true,  Block,     "iron ore" },
    { false, true,  Block,     "coal ore" },
    { false, true,  DataBlock, "wood" },
    { true,  false, DataBlock, "leave" },
    { false, true,  Block,     "sponge" },
    { true, false, Block,     "glass" },
    { false, true,  Block,     "lapis lazuli ore" },
    { false, true,  Block,     "lapis lazuli block" },
    { false, true,  DataBlock, "dispenser" },
    { false, true,  Block,     "sandstone" },
    { false, true,  Block,     "noteblock" },
    { true,  false, DataBlock, "bed" },
    { true,  false, DataBlock, "powered rail" },
    { true,  false, DataBlock, "detector rail" },
    { true,  false, DataBlock, "sticky piston" },
    { true,  false, Block,     "cobweb" },
    { true,  false, DataBlock, "tall grass" },
    { true,  false, DataBlock, "dead bush" },
    { true,  false, DataBlock, "piston" },
    { true,  false, DataBlock, "piston extension" },
    { false, true,  DataBlock, "wool" },
    { false, false, NA,        "block moved by piston" },
    { true,  false, Block,     "dandelion" },
    { true,  false, Block,     "rose" },
    { true,  false, Block,     "brown mushroom" },
    { true,  false, Block,     "red mushroom" },
    { false, true,  Block,     "gold block" },
    { false, true,  Block,     "iron block" },
    { false, true,  DataBlock, "double slab" },
    { true,  false, DataBlock, "slab" },
    { false, true,  Block,     "brick" },
    { false, false, Block,     "tnt" },
    { false, true,  Block,     "bookshelf" },
    { false, true,  Block,     "mossy stone" },
    { false, true,  Block,     "obsidian" },
    { true,  false, Block,     "torch" },
    { true,  false, DataBlock, "fire" },
    { true,  false, Block,     "spawner" },
    { true,  false, DataBlock, "wooden stair" },
    { true,  false, DataBlock, "chest" },
    { true,  false, DataBlock, "redstone wire" },
    { false, true,  Block,     "diamond ore" },
    { false, true,  Block,     "diamond block" },
    { false, true,  Block,     "crafting table" },
    { true,  false, DataBlock, "wheat" },
    { true,  false, DataBlock, "farmland" },
    { false, true,  DataBlock, "furnace" },
    { false, true,  DataBlock, "burning furnace" },
    { true,  false, DataBlock, "sign post" },
    { true,  false, DataBlock, "wooden door" },
    { true,  false, DataBlock, "ladder" },
    { true,  false, DataBlock, "rail" },
    { true,  false, DataBlock, "cobblestone stair" },
    { true,  false, DataBlock, "wall sign" },
    { true,  false, DataBlock, "lever" },
    { true,  false, DataBlock, "stone pressure plate" },
    { true,  false, DataBlock, "iron door" },
    { true,  false, DataBlock, "wooden pressure plate" },
    { false, true,  Block,     "redstone ore" },
    { false, true,  Block,     "glowing redstone ore" },
    { true,  false, Block,     "redstone torch" },
    { true,  false, Block,     "redstone torch on" },
    { true,  false, Block,     "stone button" },
    { true,  false, DataBlock, "snow" },
    { false, false, Block,     "ice" },
    { false, true,  Block,     "snow block" },
    { true,  false, DataBlock, "cactus" },
    { false, true,  Block,     "clay block" },
    { true,  false, DataBlock, "sugar cane" },
    { false, true,  DataBlock, "jukebox" },
    { true,  false, Block,     "fence" },
    { false, true,  DataBlock, "pumpkin" },
    { false, true,  Block,     "netherrack" },
    { false, true,  Block,     "soul sand" },
    { false, false, Block,     "glowstone block" },
    { true,  false, Block,     "protal" },
    { false, true,  DataBlock, "jack-o-lantern" },
    { true,  false, DataBlock, "cake block" },
    { true,  false, DataBlock, "redstone repeater" },
    { true,  false, DataBlock, "redstone repeater on" },
    { true,  false, DataBlock, "locked chest" },
    { true,  false, DataBlock, "trapdoor" },
    { false, true,  Block,     "hidden silverfish" },
    { false, true,  DataBlock, "stone brick" },
    { false, true,  DataBlock, "huge brown mushroom" },
    { false, true,  DataBlock, "huge red mushroom" },
    { true,  false, Block,     "iron bar" },
    { true,  false, Block,     "glass pane" },
    { false, true,  Block,     "melon" },
    { true,  false, DataBlock, "pumpkin stem" },
    { true,  false, DataBlock, "melon stem" },
    { true,  false, DataBlock, "vine" },
    { true,  false, DataBlock, "fence gate" },
    { true,  false, DataBlock, "brick stair" },
    { true,  false, DataBlock, "stone brick stair" },
    { false, true,  Block,     "mycelium" },
    { true,  false, Block,     "lily pad" },
    { false, true,  Block,     "nether brick" },
    { true,  false, Block,     "nether brick fence" },
    { true,  false, DataBlock, "nether brick stair" },
    { true,  false, DataBlock, "nether wart" },
    { true,  false, Block,     "enchantment table" },
    { true,  false, DataBlock, "brewing stand" },
    { true,  false, DataBlock, "cauldron" },
    { true,  false, Block,     "end portal" },
    { true,  false, DataBlock, "end portal frame" },
    { false, true,  Block,     "end stone" },
    { true,  false, Block,     "dragon egg" },
    { false, true,  Block,     "redstone lamp" },
    { false, true,  Block,     "redstone lamp on" },
    { false, false, DataBlock, "wooden double slab" },
    { true,  true,  DataBlock, "wooden slab" },
    { true,  true,  DataBlock, "cocoa plant" },
    { true,  false, DataBlock, "sandstone stair" },
    { false, false, Block,     "emerald ore" },
    { true,  false, Block,     "ender chest" },
    { true,  true,  Block,     "tripwire hook" },
    { true,  true,  Block,     "tripwire" },
    { false, false, Block,     "emerald block" },
    { true,  false, DataBlock, "spruce wood stair" },
    { true,  false, DataBlock, "birch wood stair" },
    { true,  false, DataBlock, "jungle wood stair" },
    { false, false, Block,     "command block" },
    { true,  true,  Block,     "beacon block" }
];

BlockDescriptor[4] WOOD_TYPES = [
    { false, true, Block, "oak wood" },
    { false, true, Block, "pine wood" },
    { false, true, Block, "birch wood" },
    { false, true, Block, "jungle wood" }
];

BlockDescriptor[4] LEAVE_TYPES = [
    { true, false, DataBlock, "oak leave" },
    { true, false, DataBlock, "pine leave" },
    { true, false, DataBlock, "birch leave" },
    { true, false, DataBlock, "jungle leave" }
];

BlockDescriptor[5] SAPLING_TYPES = [
    { true, true, DataBlock, "oak sapling" },
    { true, true, DataBlock, "pine sapling" },
    { true, true, DataBlock, "birch sapling" },
    { true, true, DataBlock, "jungle sapling" },
    { true, true, DataBlock, "normal sapling" } // ?
];

BlockDescriptor[8] WHEAT_TYPES = [
    { true, false, Block, "wheat 0" },
    { true, false, Block, "wheat 1" },
    { true, false, Block, "wheat 2" },
    { true, false, Block, "wheat 3" },
    { true, false, Block, "wheat 4" },
    { true, false, Block, "wheat 5" },
    { true, false, Block, "wheat 6" },
    { true, false, Block, "wheat 7" }
];

BlockDescriptor[3] NETHERWART_TYPES = [
    { true, false, Block, "nether wart 0" },
    { true, false, Block, "nether wart 1-2" },
    { true, false, Block, "nether wart 3" }
];

BlockDescriptor[16] WOOL_TYPES = [
    { false, true, Block, "white" },
    { false, true, Block, "orange" },
    { false, true, Block, "magenta" },
    { false, true, Block, "light blue" },
    { false, true, Block, "yellow" },
    { false, true, Block, "lime" },
    { false, true, Block, "pink" },
    { false, true, Block, "gray" },
    { false, true, Block, "light gray" },
    { false, true, Block, "cyan" },
    { false, true, Block, "purple" },
    { false, true, Block, "blue" },
    { false, true, Block, "brown" },
    { false, true, Block, "green" },
    { false, true, Block, "red" },
    { false, true, Block, "black" }
];

BlockDescriptor[6] SLAB_TYPES = [
    { true, false, DataBlock, "stone slab" },
    { true, false, DataBlock, "sandstone slab" },
    { true, false, DataBlock, "wooden slab" },
    { true, false, DataBlock, "cobblestone slab" },
    { true, false, DataBlock, "brick slab" },
    { true, false, DataBlock, "stone brick slab" }
];

BlockDescriptor[3] TALL_GRASS_TYPES = [
    { true, false, Block, "dead bush" },
    { true, false, Block, "tall grass" },
    { true, false, Block, "fern" }
];

BlockDescriptor[4] STONE_BRICK_TYPES = [
    { false, true, Block, "stone brick" },
    { false, true, Block, "mossy stone brick" },
    { false, true, Block, "cracked stone brick" },
    { false, true, Block, "circle stone brick" }
];