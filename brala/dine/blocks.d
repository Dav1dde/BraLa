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
    static struct TexCoord {
        ubyte u;
        ubyte v;
    }
    
    bool opaque;
    BlockType type = BlockType.NA;
    TexCoord texcoord;
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
BlockDescriptor blocks[256] = [
    { false, Air,       {0, 0}, "air" },
    { true,  Block,     {0, 0}, "stone" },
    { true,  Block,     {0, 0}, "grass" },
    { true,  Block,     {0, 0}, "dirt" },
    { true,  Block,     {0, 0}, "cobble" },
    { true,  Block,     {0, 0}, "wooden plank" },
    { false, DataBlock, {0, 0}, "sapling" },
    { true,  Block,     {0, 0}, "bedrock" },
    { false, DataBlock, {0, 0}, "water" },
    { false, DataBlock, {0, 0}, "stationary water" },
    { false, DataBlock, {0, 0}, "lava" },
    { false, DataBlock, {0, 0}, "stationary lava" },
    { true,  Block,     {0, 0}, "sand" },
    { true,  Block,     {0, 0}, "gravel" },
    { true,  Block,     {0, 0}, "gold ore" },
    { true,  Block,     {0, 0}, "iron" },
    { true,  Block,     {0, 0}, "coal" },
    { true,  DataBlock, {0, 0}, "wood" },
    { false, DataBlock, {0, 0}, "leave" },
    { true,  Block,     {0, 0}, "sponge" },
    { false, Block,     {0, 0}, "glass" },
    { true,  Block,     {0, 0}, "lapis lazuli ore" },
    { true,  Block,     {0, 0}, "lapis lazuli block" },
    { true,  DataBlock, {0, 0}, "dispenser" },
    { true,  Block,     {0, 0}, "sandstone" },
    { true,  Block,     {0, 0}, "noteblock" },
    { false, DataBlock, {0, 0}, "bed" },
    { false, DataBlock, {0, 0}, "powered rail" },
    { false, DataBlock, {0, 0}, "detector rail" },
    { false, DataBlock, {0, 0}, "sticky piston" },
    { false, Block,     {0, 0}, "cobweb" },
    { false, DataBlock, {0, 0}, "tall grass" },
    { false, DataBlock, {0, 0}, "dead bush" },
    { false, DataBlock, {0, 0}, "piston" },
    { false, DataBlock, {0, 0}, "piston extension" },
    { true,  DataBlock, {0, 0}, "wool" },
    { false, NA,        {0, 0}, "block moved by piston" },
    { false, Block,     {0, 0}, "dandelion" },
    { false, Block,     {0, 0}, "rose" },
    { false, Block,     {0, 0}, "brown mushroom" },
    { false, Block,     {0, 0}, "red mushroom" },
    { true,  Block,     {0, 0}, "gold block" },
    { true,  Block,     {0, 0}, "iron block" },
    { true,  DataBlock, {0, 0}, "double slab" },
    { false, DataBlock, {0, 0}, "slab" },
    { true,  Block,     {0, 0}, "brick" },
    { false, Block,     {0, 0}, "tnt" },
    { true,  Block,     {0, 0}, "bookshelf" },
    { true,  Block,     {0, 0}, "mossy stone" },
    { true,  Block,     {0, 0}, "obsidian" },
    { false, Block,     {0, 0}, "torch" },
    { false, DataBlock, {0, 0}, "fire" },
    { false, Block,     {0, 0}, "spawner" },
    { false, DataBlock, {0, 0}, "wooden stair" },
    { false, DataBlock, {0, 0}, "chest" },
    { false, DataBlock, {0, 0}, "redstone wire" },
    { true,  Block,     {0, 0}, "diamond ore" },
    { true,  Block,     {0, 0}, "diamond block" },
    { true,  Block,     {0, 0}, "crafting table" },
    { false, DataBlock, {0, 0}, "wheat" },
    { false, DataBlock, {0, 0}, "farmland" },
    { true,  DataBlock, {0, 0}, "furnace" },
    { true,  DataBlock, {0, 0}, "burning furnace" },
    { false, DataBlock, {0, 0}, "sign post" },
    { false, DataBlock, {0, 0}, "wooden door" },
    { false, DataBlock, {0, 0}, "ladder" },
    { false, DataBlock, {0, 0}, "rail" },
    { false, DataBlock, {0, 0}, "cobblestone stair" },
    { false, DataBlock, {0, 0}, "wall sign" },
    { false, DataBlock, {0, 0}, "lever" },
    { false, DataBlock, {0, 0}, "stone pressure plate" },
    { false, DataBlock, {0, 0}, "iron door" },
    { false, DataBlock, {0, 0}, "wooden pressure plate" },
    { true,  Block,     {0, 0}, "redstone ore" },
    { true,  Block,     {0, 0}, "glowing redstone ore" },
    { false, Block,     {0, 0}, "redstone torch" },
    { false, Block,     {0, 0}, "redstone torch on" },
    { false, Block,     {0, 0}, "stone button" },
    { false, DataBlock, {0, 0}, "snow" },
    { false, Block,     {0, 0}, "ice" },
    { true,  Block,     {0, 0}, "snow block" },
    { false, DataBlock, {0, 0}, "cactus" },
    { true,  Block,     {0, 0}, "clay block" },
    { false, DataBlock, {0, 0}, "sugar cane" },
    { true,  DataBlock, {0, 0}, "jukebox" },
    { false, Block,     {0, 0}, "fence" },
    { true,  DataBlock, {0, 0}, "pumpkin" },
    { true,  Block,     {0, 0}, "netherrack" },
    { true,  Block,     {0, 0}, "soul sand" },
    { false, Block,     {0, 0}, "glowstone block" },
    { false, Block,     {0, 0}, "protal" },
    { true,  DataBlock, {0, 0}, "jack-o-lantern" },
    { false, DataBlock, {0, 0}, "cake block" },
    { false, DataBlock, {0, 0}, "redstone repeater" },
    { false, DataBlock, {0, 0}, "redstone repeater on" },
    { false, DataBlock, {0, 0}, "locked chest" },
    { false, DataBlock, {0, 0}, "trapdoor" },
    { true,  Block,     {0, 0}, "hidden silverfish" },
    { true,  DataBlock, {0, 0}, "stone brick" },
    { true,  DataBlock, {0, 0}, "huge brown mushroom" },
    { true,  DataBlock, {0, 0}, "huge red mushroom" },
    { false, Block,     {0, 0}, "iron bar" },
    { false, Block,     {0, 0}, "glass pane" },
    { true,  Block,     {0, 0}, "melon" },
    { false, DataBlock, {0, 0}, "pumpkin stem" },
    { false, DataBlock, {0, 0}, "melon stem" },
    { false, DataBlock, {0, 0}, "vine" },
    { false, DataBlock, {0, 0}, "fence gate" },
    { false, DataBlock, {0, 0}, "brick stair" },
    { false, DataBlock, {0, 0}, "stone brick stair" },
    { true,  Block,     {0, 0}, "mycelium" },
    { false, Block,     {0, 0}, "lily pad" },
    { true,  Block,     {0, 0}, "nether brick" },
    { false, Block,     {0, 0}, "nether brick fence" },
    { false, DataBlock, {0, 0}, "nether wart" },
    { false, Block,     {0, 0}, "enchantment table" },
    { false, DataBlock, {0, 0}, "brewing stand" },
    { false, DataBlock, {0, 0}, "cauldron" },
    { false, Block,     {0, 0}, "end portal" },
    { false, DataBlock, {0, 0}, "end portal frame" },
    { true,  Block,     {0, 0}, "end stone" },
    { false, Block,     {0, 0}, "dragon egg" },
    { true,  Block,     {0, 0}, "redstone lamp" },
    { true,  Block,     {0, 0}, "redstone lamp on" } // 124
];

BlockDescriptor wood_types[4] = [
    { true, Block, {0, 0}, "oak wood" },
    { true, Block, {0, 0}, "pine wood" },
    { true, Block, {0, 0}, "birch wood" },
    { true, Block, {0, 0}, "jungle wood" }
];

BlockDescriptor leave_types[4] = [
    { false, DataBlock, {0, 0}, "oak leave" },
    { false, DataBlock, {0, 0}, "pine leave" },
    { false, DataBlock, {0, 0}, "birch leave" },
    { false, DataBlock, {0, 0}, "jungle leave" }
];

BlockDescriptor sapling_types[5] = [
    { true, DataBlock, {0, 0}, "oak sapling" },
    { true, DataBlock, {0, 0}, "pine sapling" },
    { true, DataBlock, {0, 0}, "birch sapling" },
    { true, DataBlock, {0, 0}, "jungle sapling" },
    { true, DataBlock, {0, 0}, "normal sapling" } // ?
];

BlockDescriptor wheat_types[8] = [
    { false, Block, {0, 0}, "wheat 0" },
    { false, Block, {0, 0}, "wheat 1" },
    { false, Block, {0, 0}, "wheat 2" },
    { false, Block, {0, 0}, "wheat 3" },
    { false, Block, {0, 0}, "wheat 4" },
    { false, Block, {0, 0}, "wheat 5" },
    { false, Block, {0, 0}, "wheat 6" },
    { false, Block, {0, 0}, "wheat 7" }
];
    
BlockDescriptor nether_wart_types[3] = [
    { false, Block, {0, 0}, "nether wart 0" },
    { false, Block, {0, 0}, "nether wart 1-2" },
    { false, Block, {0, 0}, "nether wart 3" }
];

BlockDescriptor wool_types[16] = [
    { true, Block, {0, 0}, "white" },
    { true, Block, {0, 0}, "orange" },
    { true, Block, {0, 0}, "magenta" },
    { true, Block, {0, 0}, "light blue" },
    { true, Block, {0, 0}, "yellow" },
    { true, Block, {0, 0}, "lime" },
    { true, Block, {0, 0}, "pink" },
    { true, Block, {0, 0}, "gray" },
    { true, Block, {0, 0}, "light gray" },
    { true, Block, {0, 0}, "cyan" },
    { true, Block, {0, 0}, "purple" },
    { true, Block, {0, 0}, "blue" },
    { true, Block, {0, 0}, "brown" },
    { true, Block, {0, 0}, "green" },
    { true, Block, {0, 0}, "red" },
    { true, Block, {0, 0}, "black" }
];
    
BlockDescriptor slab_types[6] = [
    { false, DataBlock, {0, 0}, "stone slab" },
    { false, DataBlock, {0, 0}, "sandstone slab" },
    { false, DataBlock, {0, 0}, "wooden slab" },
    { false, DataBlock, {0, 0}, "cobblestone slab" },
    { false, DataBlock, {0, 0}, "brick slab" },
    { false, DataBlock, {0, 0}, "stone brick slab" }
];

BlockDescriptor tall_grass_types[3] = [
    { false, Block, {0, 0}, "dead bush" },
    { false, Block, {0, 0}, "tall grass" },
    { false, Block, {0, 0}, "fern" }
];

BlockDescriptor stone_brick_types[4] = [
    { true, Block, {0, 0}, "stone brick" },
    { true, Block, {0, 0}, "mossy stone brick" },
    { true, Block, {0, 0}, "cracked stone brick" },
    { true, Block, {0, 0}, "circle stone brick" }
];