module brala.dine.blocks;

private {
}

enum BlockType {
    Air = 0,
    Block, // no metadata
    DataBlock, // metadata is important?
    NA // placeholder for non existent ids
}

struct BlockDescriptor {
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

// TODO: add correct tex-coords
// TODO: add more, like bed, redstone repeater etc.
BlockDescriptor[256] blocks = [
    { false, Air,       "air" },
    { true,  Block,     "stone" },
    { true,  Block,     "grass" },
    { true,  Block,     "dirt" },
    { true,  Block,     "cobble" },
    { true,  Block,     "wooden plank" },
    { false, DataBlock, "sapling" },
    { true,  Block,     "bedrock" },
    { false, DataBlock, "water" },
    { false, DataBlock, "stationary water" },
    { false, DataBlock, "lava" },
    { false, DataBlock, "stationary lava" },
    { true,  Block,     "sand" },
    { true,  Block,     "gravel" },
    { true,  Block,     "gold ore" },
    { true,  Block,     "iron ore" },
    { true,  Block,     "coal ore" },
    { true,  DataBlock, "wood" },
    { false, DataBlock, "leave" },
    { true,  Block,     "sponge" },
    { false, Block,     "glass" },
    { true,  Block,     "lapis lazuli ore" },
    { true,  Block,     "lapis lazuli block" },
    { true,  DataBlock, "dispenser" },
    { true,  Block,     "sandstone" },
    { true,  Block,     "noteblock" },
    { false, DataBlock, "bed" },
    { false, DataBlock, "powered rail" },
    { false, DataBlock, "detector rail" },
    { false, DataBlock, "sticky piston" },
    { false, Block,     "cobweb" },
    { false, DataBlock, "tall grass" },
    { false, DataBlock, "dead bush" },
    { false, DataBlock, "piston" },
    { false, DataBlock, "piston extension" },
    { true,  DataBlock, "wool" },
    { false, NA,        "block moved by piston" },
    { false, Block,     "dandelion" },
    { false, Block,     "rose" },
    { false, Block,     "brown mushroom" },
    { false, Block,     "red mushroom" },
    { true,  Block,     "gold block" },
    { true,  Block,     "iron block" },
    { true,  DataBlock, "double slab" },
    { false, DataBlock, "slab" },
    { true,  Block,     "brick" },
    { false, Block,     "tnt" },
    { true,  Block,     "bookshelf" },
    { true,  Block,     "mossy stone" },
    { true,  Block,     "obsidian" },
    { false, Block,     "torch" },
    { false, DataBlock, "fire" },
    { false, Block,     "spawner" },
    { false, DataBlock, "wooden stair" },
    { false, DataBlock, "chest" },
    { false, DataBlock, "redstone wire" },
    { true,  Block,     "diamond ore" },
    { true,  Block,     "diamond block" },
    { true,  Block,     "crafting table" },
    { false, DataBlock, "wheat" },
    { false, DataBlock, "farmland" },
    { true,  DataBlock, "furnace" },
    { true,  DataBlock, "burning furnace" },
    { false, DataBlock, "sign post" },
    { false, DataBlock, "wooden door" },
    { false, DataBlock, "ladder" },
    { false, DataBlock, "rail" },
    { false, DataBlock, "cobblestone stair" },
    { false, DataBlock, "wall sign" },
    { false, DataBlock, "lever" },
    { false, DataBlock, "stone pressure plate" },
    { false, DataBlock, "iron door" },
    { false, DataBlock, "wooden pressure plate" },
    { true,  Block,     "redstone ore" },
    { true,  Block,     "glowing redstone ore" },
    { false, Block,     "redstone torch" },
    { false, Block,     "redstone torch on" },
    { false, Block,     "stone button" },
    { false, DataBlock, "snow" },
    { false, Block,     "ice" },
    { true,  Block,     "snow block" },
    { false, DataBlock, "cactus" },
    { true,  Block,     "clay block" },
    { false, DataBlock, "sugar cane" },
    { true,  DataBlock, "jukebox" },
    { false, Block,     "fence" },
    { true,  DataBlock, "pumpkin" },
    { true,  Block,     "netherrack" },
    { true,  Block,     "soul sand" },
    { false, Block,     "glowstone block" },
    { false, Block,     "protal" },
    { true,  DataBlock, "jack-o-lantern" },
    { false, DataBlock, "cake block" },
    { false, DataBlock, "redstone repeater" },
    { false, DataBlock, "redstone repeater on" },
    { false, DataBlock, "locked chest" },
    { false, DataBlock, "trapdoor" },
    { true,  Block,     "hidden silverfish" },
    { true,  DataBlock, "stone brick" },
    { true,  DataBlock, "huge brown mushroom" },
    { true,  DataBlock, "huge red mushroom" },
    { false, Block,     "iron bar" },
    { false, Block,     "glass pane" },
    { true,  Block,     "melon" },
    { false, DataBlock, "pumpkin stem" },
    { false, DataBlock, "melon stem" },
    { false, DataBlock, "vine" },
    { false, DataBlock, "fence gate" },
    { false, DataBlock, "brick stair" },
    { false, DataBlock, "stone brick stair" },
    { true,  Block,     "mycelium" },
    { false, Block,     "lily pad" },
    { true,  Block,     "nether brick" },
    { false, Block,     "nether brick fence" },
    { false, DataBlock, "nether wart" },
    { false, Block,     "enchantment table" },
    { false, DataBlock, "brewing stand" },
    { false, DataBlock, "cauldron" },
    { false, Block,     "end portal" },
    { false, DataBlock, "end portal frame" },
    { true,  Block,     "end stone" },
    { false, Block,     "dragon egg" },
    { true,  Block,     "redstone lamp" },
    { true,  Block,     "redstone lamp on" } // 124
];

BlockDescriptor[4] wood_types = [
    { true, Block, "oak wood" },
    { true, Block, "pine wood" },
    { true, Block, "birch wood" },
    { true, Block, "jungle wood" }
];

BlockDescriptor[4] leave_types = [
    { false, DataBlock, "oak leave" },
    { false, DataBlock, "pine leave" },
    { false, DataBlock, "birch leave" },
    { false, DataBlock, "jungle leave" }
];

BlockDescriptor[5] sapling_types = [
    { true, DataBlock, "oak sapling" },
    { true, DataBlock, "pine sapling" },
    { true, DataBlock, "birch sapling" },
    { true, DataBlock, "jungle sapling" },
    { true, DataBlock, "normal sapling" } // ?
];

BlockDescriptor[8] wheat_types = [
    { false, Block, "wheat 0" },
    { false, Block, "wheat 1" },
    { false, Block, "wheat 2" },
    { false, Block, "wheat 3" },
    { false, Block, "wheat 4" },
    { false, Block, "wheat 5" },
    { false, Block, "wheat 6" },
    { false, Block, "wheat 7" }
];

BlockDescriptor[3] nether_wart_types = [
    { false, Block, "nether wart 0" },
    { false, Block, "nether wart 1-2" },
    { false, Block, "nether wart 3" }
];

BlockDescriptor[16] wool_types = [
    { true, Block, "white" },
    { true, Block, "orange" },
    { true, Block, "magenta" },
    { true, Block, "light blue" },
    { true, Block, "yellow" },
    { true, Block, "lime" },
    { true, Block, "pink" },
    { true, Block, "gray" },
    { true, Block, "light gray" },
    { true, Block, "cyan" },
    { true, Block, "purple" },
    { true, Block, "blue" },
    { true, Block, "brown" },
    { true, Block, "green" },
    { true, Block, "red" },
    { true, Block, "black" }
];

BlockDescriptor[6] slab_types = [
    { false, DataBlock, "stone slab" },
    { false, DataBlock, "sandstone slab" },
    { false, DataBlock, "wooden slab" },
    { false, DataBlock, "cobblestone slab" },
    { false, DataBlock, "brick slab" },
    { false, DataBlock, "stone brick slab" }
];

BlockDescriptor[3] tall_grass_types = [
    { false, Block, "dead bush" },
    { false, Block, "tall grass" },
    { false, Block, "fern" }
];

BlockDescriptor[4] stone_brick_types = [
    { true, Block, "stone brick" },
    { true, Block, "mossy stone brick" },
    { true, Block, "cracked stone brick" },
    { true, Block, "circle stone brick" }
];