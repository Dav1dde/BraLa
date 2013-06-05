module brala.dine.builder.vertices;

private {
    import std.traits : isIntegral;

    import brala.dine.builder.tessellator : Vertex;
    import brala.dine.builder.constants : Side;
}

public import brala.dine.builder.vertices_.blocks;
public import brala.dine.builder.vertices_.slabs;
public import brala.dine.builder.vertices_.stairs;
public import brala.dine.builder.vertices_.plants;
public import brala.dine.builder.vertices_.rails;
public import brala.dine.builder.vertices_.misc;
public import brala.dine.builder.vertices_.redstone;
public import brala.gfx.terrain : CubeSideData, BLOCK_IDS;

struct TextureInformation {
    string name;
    string overlay = "";
}

TextureInformation[BLOCK_IDS] TEXTURE_INFORMATION_LEFT = [
    {""}, // air
    {"stone"}, // stone
    {"grass_side", "grass_side_overlay"}, // grass
    {"dirt"}, // dirt
    {"stonebrick"}, // cobble
    {"wood"}, // wooden plank
    {""}, // sappling
    {"bedrock"}, // bedrock
    {""}, // water
    {""}, // stationary water
    {""}, // lava
    {""}, // stationary lava
    {"sand"}, // sand
    {"gravel"}, // gravel
    {"oreGold"}, // gold ore
    {"oreIron"}, // iron ore
    {"oreCoal"}, // coal ore
    {"tree_side"}, // wood
    {"leaves"}, // leaf
    {"sponge"}, // sponge
    {"glass"}, // glass
    {"oreLapis"}, // lapis lazuli ore
    {"blockLapis"}, // lapis lazuli block
    {"furnace_side"}, // dispenser
    {"sandstone_side"}, // sandstone
    {"musicBlock"}, // noteblock
    {""}, // bed
    {""}, // powered rail
    {""}, // detector rail
    {""}, // sticky piston
    {""}, // cobweb
    {""}, // tall grass
    {""}, // dead bush
    {""}, // piston
    {""}, // piston extension
    {""}, // wool
    {""}, // block moved by piston
    {""}, // dandelion
    {""}, // rose
    {""}, // brown mushroom
    {""}, // red mushroom
    {"blockGold"}, // gold block
    {"blockIron"}, // iron block
    {"stoneslab_side"}, // double slab
    {""}, // slab
    {"brick"}, // brick
    {"tnt_side"}, // tnt
    {"bookshelf"}, // bookshelf
    {"stoneMoss"}, // mossy stone
    {"obsidian"}, // obsidian
    {""}, // torch
    {""}, // fire
    {"mobSpawner"}, // spawner
    {""}, // wooden stair
    {""}, // chest
    {""}, // redstone wire
    {"oreDiamond"}, // diamond ore
    {"blockDiamond"}, // diamond block
    {"workbench_side"}, // crafting table
    {""}, // wheat
    {"dirt"}, // farmland
    {"furnace_side"}, // furnace
    {"furnace_side"}, // burning furnace
    {""}, // sign post
    {""}, // wooden door
    {""}, // ladder
    {""}, // rail
    {""}, // cobblestone stair
    {""}, // wall sign
    {""}, // lever
    {""}, // stone pressure plate
    {""}, // iron door
    {""}, // wooden pressure plate
    {"oreRedstone"}, // redstone ore
    {"oreRedstone"}, // glowing redstone ore TODO
    {""}, // redstone torch
    {""}, // redstone torch on
    {""}, // stone button
    {""}, // snow
    {"ice"}, // ice
    {"snow_side"}, // snow block
    {""}, // cactus
    {"clay"}, // clay block
    {""}, // sugar cane
    {"musicBlock"}, // jukebox
    {""}, // fence
    {"pumpkin_side"}, // pumpkin
    {"hellrock"}, // netherrack
    {"hellsand"}, // soul sand
    {"lightgem"}, // glowstone block
    {""}, // portal
    {"pumpkin_side"}, // jack-o-lantern
    {""}, // cake block
    {""}, // redstone repeater
    {""}, // redstone repeater on
    {""}, // locked chest
    {""}, // trapdoor
    {""}, // hidden silverfish
    {"stonebricksmooth"}, // stone brick
    {""}, // huge brown mushroom
    {""}, // huge red mushroom
    {""}, // iron bar
    {""}, // glass pane
    {"melon_side"}, // melon
    {""}, // pumpkin stem
    {""}, // melon stem
    {""}, // vine
    {""}, // fence gate
    {""}, // brick stair
    {""}, // stone brick stair
    {"mycel_side"}, // mycelium
    {""}, // lilly pad
    {"netherBrick"}, // nether brick
    {""}, // nether brick fence
    {""}, // nether wart
    {""}, // nether brick stair
    {""}, // enchantment table
    {""}, // brewing stand
    {"cauldron_side"}, // cauldron
    {""}, // end portal
    {""}, // end portal frame
    {"whiteStone"}, // end stone
    {""}, // dragon egg
    {"redstoneLight"}, // redstone lamp
    {"redstoneLight_lit"}, // redstone lamp on
    {""}, // wooden double slab
    {""}, // wooden slab
    {""}, // cocoa plant
    {""}, // sandstone stairs
    {"oreEmerald"}, // emerald ore
    {""}, // ender chest
    {""}, // tripwire hook
    {""}, // tripwire
    {"blockEmerald"}, // emerald block
    {""}, // spruce wood stairs
    {""}, // birch wood stairs
    {""}, // jungle wood stairs
    {""}, // command block
    {""}  // beacon block
];

TextureInformation[BLOCK_IDS] TEXTURE_INFORMATION_RIGHT = [
    {""}, // air
    {"stone"}, // stone
    {"grass_side", "grass_side_overlay"}, // grass
    {"dirt"}, // dirt
    {"stonebrick"}, // cobble
    {"wood"}, // wooden plank
    {""}, // sappling
    {"bedrock"}, // bedrock
    {""}, // water
    {""}, // stationary water
    {""}, // lava
    {""}, // stationary lava
    {"sand"}, // sand
    {"gravel"}, // gravel
    {"oreGold"}, // gold ore
    {"oreIron"}, // iron ore
    {"oreCoal"}, // coal ore
    {"tree_side"}, // wood
    {"leaves"}, // leaf
    {"sponge"}, // sponge
    {"glass"}, // glass
    {"oreLapis"}, // lapis lazuli ore
    {"blockLapis"}, // lapis lazuli block
    {"furnace_side"}, // dispenser
    {"sandstone_side"}, // sandstone
    {"musicBlock"}, // noteblock
    {""}, // bed
    {""}, // powered rail
    {""}, // detector rail
    {""}, // sticky piston
    {""}, // cobweb
    {""}, // tall grass
    {""}, // dead bush
    {""}, // piston
    {""}, // piston extension
    {""}, // wool
    {""}, // block moved by piston
    {""}, // dandelion
    {""}, // rose
    {""}, // brown mushroom
    {""}, // red mushroom
    {"blockGold"}, // gold block
    {"blockIron"}, // iron block
    {"stoneslab_side"}, // double slab
    {""}, // slab
    {"brick"}, // brick
    {"tnt_side"}, // tnt
    {"bookshelf"}, // bookshelf
    {"stoneMoss"}, // mossy stone
    {"obsidian"}, // obsidian
    {""}, // torch
    {""}, // fire
    {"mobSpawner"}, // spawner
    {""}, // wooden stair
    {""}, // chest
    {""}, // redstone wire
    {"oreDiamond"}, // diamond ore
    {"blockDiamond"}, // diamond block
    {"workbench_side"}, // crafting table
    {""}, // wheat
    {"dirt"}, // farmland
    {"furnace_side"}, // furnace
    {"furnace_side"}, // burning furnace
    {""}, // sign post
    {""}, // wooden door
    {""}, // ladder
    {""}, // rail
    {""}, // cobblestone stair
    {""}, // wall sign
    {""}, // lever
    {""}, // stone pressure plate
    {""}, // iron door
    {""}, // wooden pressure plate
    {"oreRedstone"}, // redstone ore
    {"oreRedstone"}, // glowing redstone ore TODO
    {""}, // redstone torch
    {""}, // redstone torch on
    {""}, // stone button
    {""}, // snow
    {"ice"}, // ice
    {"snow_side"}, // snow block
    {""}, // cactus
    {"clay"}, // clay block
    {""}, // sugar cane
    {"musicBlock"}, // jukebox
    {""}, // fence
    {"pumpkin_side"}, // pumpkin
    {"hellrock"}, // netherrack
    {"hellsand"}, // soul sand
    {"lightgem"}, // glowstone block
    {""}, // portal
    {"pumpkin_side"}, // jack-o-lantern
    {""}, // cake block
    {""}, // redstone repeater
    {""}, // redstone repeater on
    {""}, // locked chest
    {""}, // trapdoor
    {""}, // hidden silverfish
    {"stonebricksmooth"}, // stone brick
    {""}, // huge brown mushroom
    {""}, // huge red mushroom
    {""}, // iron bar
    {""}, // glass pane
    {"melon_side"}, // melon
    {""}, // pumpkin stem
    {""}, // melon stem
    {""}, // vine
    {""}, // fence gate
    {""}, // brick stair
    {""}, // stone brick stair
    {"mycel_side"}, // mycelium
    {""}, // lilly pad
    {"netherBrick"}, // nether brick
    {""}, // nether brick fence
    {""}, // nether wart
    {""}, // nether brick stair
    {""}, // enchantment table
    {""}, // brewing stand
    {"cauldron_side"}, // cauldron
    {""}, // end portal
    {""}, // end portal frame
    {"whiteStone"}, // end stone
    {""}, // dragon egg
    {"redstoneLight"}, // redstone lamp
    {"redstoneLight_lit"}, // redstone lamp on
    {""}, // wooden double slab
    {""}, // wooden slab
    {""}, // cocoa plant
    {""}, // sandstone stairs
    {"oreEmerald"}, // emerald ore
    {""}, // ender chest
    {""}, // tripwire hook
    {""}, // tripwire
    {"blockEmerald"}, // emerald block
    {""}, // spruce wood stairs
    {""}, // birch wood stairs
    {""}, // jungle wood stairs
    {""}, // command block
    {""}  // beacon block
];

TextureInformation[BLOCK_IDS] TEXTURE_INFORMATION_NEAR = [
    {""}, // air
    {"stone"}, // stone
    {"grass_side", "grass_side_overlay"}, // grass
    {"dirt"}, // dirt
    {"stonebrick"}, // cobble
    {"wood"}, // wooden plank
    {""}, // sappling
    {"bedrock"}, // bedrock
    {""}, // water
    {""}, // stationary water
    {""}, // lava
    {""}, // stationary lava
    {"sand"}, // sand
    {"gravel"}, // gravel
    {"oreGold"}, // gold ore
    {"oreIron"}, // iron ore
    {"oreCoal"}, // coal ore
    {"tree_side"}, // wood
    {"leaves"}, // leaf
    {"sponge"}, // sponge
    {"glass"}, // glass
    {"oreLapis"}, // lapis lazuli ore
    {"blockLapis"}, // lapis lazuli block
    {"furnace_side"}, // dispenser
    {"sandstone_side"}, // sandstone
    {"musicBlock"}, // noteblock
    {""}, // bed
    {""}, // powered rail
    {""}, // detector rail
    {""}, // sticky piston
    {""}, // cobweb
    {""}, // tall grass
    {""}, // dead bush
    {""}, // piston
    {""}, // piston extension
    {""}, // wool
    {""}, // block moved by piston
    {""}, // dandelion
    {""}, // rose
    {""}, // brown mushroom
    {""}, // red mushroom
    {"blockGold"}, // gold block
    {"blockIron"}, // iron block
    {"stoneslab_side"}, // double slab
    {""}, // slab
    {"brick"}, // brick
    {"tnt_side"}, // tnt
    {"bookshelf"}, // bookshelf
    {"stoneMoss"}, // mossy stone
    {"obsidian"}, // obsidian
    {""}, // torch
    {""}, // fire
    {"mobSpawner"}, // spawner
    {""}, // wooden stair
    {""}, // chest
    {""}, // redstone wire
    {"oreDiamond"}, // diamond ore
    {"blockDiamond"}, // diamond block
    {"workbench_side"}, // crafting table
    {""}, // wheat
    {"dirt"}, // farmland
    {"furnace_side"}, // furnace
    {"furnace_side"}, // burning furnace
    {""}, // sign post
    {""}, // wooden door
    {""}, // ladder
    {""}, // rail
    {""}, // cobblestone stair
    {""}, // wall sign
    {""}, // lever
    {""}, // stone pressure plate
    {""}, // iron door
    {""}, // wooden pressure plate
    {"oreRedstone"}, // redstone ore
    {"oreRedstone"}, // glowing redstone ore TODO
    {""}, // redstone torch
    {""}, // redstone torch on
    {""}, // stone button
    {""}, // snow
    {"ice"}, // ice
    {"snow_side"}, // snow block
    {""}, // cactus
    {"clay"}, // clay block
    {""}, // sugar cane
    {"musicBlock"}, // jukebox
    {""}, // fence
    {"pumpkin_side"}, // pumpkin
    {"hellrock"}, // netherrack
    {"hellsand"}, // soul sand
    {"lightgem"}, // glowstone block
    {""}, // portal
    {"pumpkin_side"}, // jack-o-lantern
    {""}, // cake block
    {""}, // redstone repeater
    {""}, // redstone repeater on
    {""}, // locked chest
    {""}, // trapdoor
    {""}, // hidden silverfish
    {"stonebricksmooth"}, // stone brick
    {""}, // huge brown mushroom
    {""}, // huge red mushroom
    {""}, // iron bar
    {""}, // glass pane
    {"melon_side"}, // melon
    {""}, // pumpkin stem
    {""}, // melon stem
    {""}, // vine
    {""}, // fence gate
    {""}, // brick stair
    {""}, // stone brick stair
    {"mycel_side"}, // mycelium
    {""}, // lilly pad
    {"netherBrick"}, // nether brick
    {""}, // nether brick fence
    {""}, // nether wart
    {""}, // nether brick stair
    {""}, // enchantment table
    {""}, // brewing stand
    {"cauldron_side"}, // cauldron
    {""}, // end portal
    {""}, // end portal frame
    {"whiteStone"}, // end stone
    {""}, // dragon egg
    {"redstoneLight"}, // redstone lamp
    {"redstoneLight_lit"}, // redstone lamp on
    {""}, // wooden double slab
    {""}, // wooden slab
    {""}, // cocoa plant
    {""}, // sandstone stairs
    {"oreEmerald"}, // emerald ore
    {""}, // ender chest
    {""}, // tripwire hook
    {""}, // tripwire
    {"blockEmerald"}, // emerald block
    {""}, // spruce wood stairs
    {""}, // birch wood stairs
    {""}, // jungle wood stairs
    {""}, // command block
    {""}  // beacon block
];

TextureInformation[BLOCK_IDS] TEXTURE_INFORMATION_FAR = [
    {""}, // air
    {"stone"}, // stone
    {"grass_side", "grass_side_overlay"}, // grass
    {"dirt"}, // dirt
    {"stonebrick"}, // cobble
    {"wood"}, // wooden plank
    {""}, // sappling
    {"bedrock"}, // bedrock
    {""}, // water
    {""}, // stationary water
    {""}, // lava
    {""}, // stationary lava
    {"sand"}, // sand
    {"gravel"}, // gravel
    {"oreGold"}, // gold ore
    {"oreIron"}, // iron ore
    {"oreCoal"}, // coal ore
    {"tree_side"}, // wood
    {"leaves"}, // leaf
    {"sponge"}, // sponge
    {"glass"}, // glass
    {"oreLapis"}, // lapis lazuli ore
    {"blockLapis"}, // lapis lazuli block
    {"furnace_side"}, // dispenser
    {"sandstone_side"}, // sandstone
    {"musicBlock"}, // noteblock
    {""}, // bed
    {""}, // powered rail
    {""}, // detector rail
    {""}, // sticky piston
    {""}, // cobweb
    {""}, // tall grass
    {""}, // dead bush
    {""}, // piston
    {""}, // piston extension
    {""}, // wool
    {""}, // block moved by piston
    {""}, // dandelion
    {""}, // rose
    {""}, // brown mushroom
    {""}, // red mushroom
    {"blockGold"}, // gold block
    {"blockIron"}, // iron block
    {"stoneslab_side"}, // double slab
    {""}, // slab
    {"brick"}, // brick
    {"tnt_side"}, // tnt
    {"bookshelf"}, // bookshelf
    {"stoneMoss"}, // mossy stone
    {"obsidian"}, // obsidian
    {""}, // torch
    {""}, // fire
    {"mobSpawner"}, // spawner
    {""}, // wooden stair
    {""}, // chest
    {""}, // redstone wire
    {"oreDiamond"}, // diamond ore
    {"blockDiamond"}, // diamond block
    {"workbench_side"}, // crafting table
    {""}, // wheat
    {"dirt"}, // farmland
    {"furnace_side"}, // furnace
    {"furnace_side"}, // burning furnace
    {""}, // sign post
    {""}, // wooden door
    {""}, // ladder
    {""}, // rail
    {""}, // cobblestone stair
    {""}, // wall sign
    {""}, // lever
    {""}, // stone pressure plate
    {""}, // iron door
    {""}, // wooden pressure plate
    {"oreRedstone"}, // redstone ore
    {"oreRedstone"}, // glowing redstone ore TODO
    {""}, // redstone torch
    {""}, // redstone torch on
    {""}, // stone button
    {""}, // snow
    {"ice"}, // ice
    {"snow_side"}, // snow block
    {""}, // cactus
    {"clay"}, // clay block
    {""}, // sugar cane
    {"musicBlock"}, // jukebox
    {""}, // fence
    {"pumpkin_side"}, // pumpkin
    {"hellrock"}, // netherrack
    {"hellsand"}, // soul sand
    {"lightgem"}, // glowstone block
    {""}, // portal
    {"pumpkin_side"}, // jack-o-lantern
    {""}, // cake block
    {""}, // redstone repeater
    {""}, // redstone repeater on
    {""}, // locked chest
    {""}, // trapdoor
    {""}, // hidden silverfish
    {"stonebricksmooth"}, // stone brick
    {""}, // huge brown mushroom
    {""}, // huge red mushroom
    {""}, // iron bar
    {""}, // glass pane
    {"melon_side"}, // melon
    {""}, // pumpkin stem
    {""}, // melon stem
    {""}, // vine
    {""}, // fence gate
    {""}, // brick stair
    {""}, // stone brick stair
    {"mycel_side"}, // mycelium
    {""}, // lilly pad
    {"netherBrick"}, // nether brick
    {""}, // nether brick fence
    {""}, // nether wart
    {""}, // nether brick stair
    {""}, // enchantment table
    {""}, // brewing stand
    {"cauldron_side"}, // cauldron
    {""}, // end portal
    {""}, // end portal frame
    {"whiteStone"}, // end stone
    {""}, // dragon egg
    {"redstoneLight"}, // redstone lamp
    {"redstoneLight_lit"}, // redstone lamp on
    {""}, // wooden double slab
    {""}, // wooden slab
    {""}, // cocoa plant
    {""}, // sandstone stairs
    {"oreEmerald"}, // emerald ore
    {""}, // ender chest
    {""}, // tripwire hook
    {""}, // tripwire
    {"blockEmerald"}, // emerald block
    {""}, // spruce wood stairs
    {""}, // birch wood stairs
    {""}, // jungle wood stairs
    {""}, // command block
    {""}  // beacon block
];

TextureInformation[BLOCK_IDS] TEXTURE_INFORMATION_TOP = [
    {""}, // air
    {"stone"}, // stone
    {"grass_top"}, // grass
    {"dirt"}, // dirt
    {"stonebrick"}, // cobble
    {"wood"}, // wooden plank
    {""}, // sappling
    {"bedrock"}, // bedrock
    {""}, // water
    {""}, // stationary water
    {""}, // lava
    {""}, // stationary lava
    {"sand"}, // sand
    {"gravel"}, // gravel
    {"oreGold"}, // gold ore
    {"oreIron"}, // iron ore
    {"oreCoal"}, // coal ore
    {"tree_top"}, // wood
    {"leaves"}, // leaf
    {"sponge"}, // sponge
    {"glass"}, // glass
    {"oreLapis"}, // lapis lazuli ore
    {"blockLapis"}, // lapis lazuli block
    {"furnace_top"}, // dispenser
    {"sandstone_top"}, // sandstone
    {"musicBlock"}, // noteblock
    {""}, // bed
    {""}, // powered rail
    {""}, // detector rail
    {""}, // sticky piston
    {""}, // cobweb
    {""}, // tall grass
    {""}, // dead bush
    {""}, // piston
    {""}, // piston extension
    {""}, // wool
    {""}, // block moved by piston
    {""}, // dandelion
    {""}, // rose
    {""}, // brown mushroom
    {""}, // red mushroom
    {"blockGold"}, // gold block
    {"blockIron"}, // iron block
    {"stoneslab_top"}, // double slab
    {""}, // slab
    {"brick"}, // brick
    {"tnt_bottom"}, // tnt
    {"wood"}, // bookshelf
    {"stoneMoss"}, // mossy stone
    {"obsidian"}, // obsidian
    {""}, // torch
    {""}, // fire
    {"mobSpawner"}, // spawner
    {""}, // wooden stair
    {""}, // chest
    {""}, // redstone wire
    {"oreDiamond"}, // diamond ore
    {"blockDiamond"}, // diamond block
    {"workbench_side"}, // crafting table
    {""}, // wheat
    {"farmland_wet"}, // farmland
    {"furnace_top"}, // furnace
    {"furnace_top"}, // burning furnace
    {""}, // sign post
    {""}, // wooden door
    {""}, // ladder
    {""}, // rail
    {""}, // cobblestone stair
    {""}, // wall sign
    {""}, // lever
    {""}, // stone pressure plate
    {""}, // iron door
    {""}, // wooden pressure plate
    {"oreRedstone"}, // redstone ore
    {"oreRedstone"}, // glowing redstone ore TODO
    {""}, // redstone torch
    {""}, // redstone torch on
    {""}, // stone button
    {""}, // snow
    {"ice"}, // ice
    {"snow_side"}, // snow block
    {""}, // cactus
    {"clay"}, // clay block
    {""}, // sugar cane
    {"jukebox_top"}, // jukebox
    {""}, // fence
    {"pumpkin_top"}, // pumpkin
    {"hellrock"}, // netherrack
    {"hellsand"}, // soul sand
    {"lightgem"}, // glowstone block
    {""}, // portal
    {"pumpkin_top"}, // jack-o-lantern
    {""}, // cake block
    {""}, // redstone repeater
    {""}, // redstone repeater on
    {""}, // locked chest
    {""}, // trapdoor
    {""}, // hidden silverfish
    {"stonebricksmooth"}, // stone brick
    {""}, // huge brown mushroom
    {""}, // huge red mushroom
    {""}, // iron bar
    {""}, // glass pane
    {"melon_side"}, // melon
    {""}, // pumpkin stem
    {""}, // melon stem
    {""}, // vine
    {""}, // fence gate
    {""}, // brick stair
    {""}, // stone brick stair
    {"mycel_top"}, // mycelium
    {""}, // lilly pad
    {"netherBrick"}, // nether brick
    {""}, // nether brick fence
    {""}, // nether wart
    {""}, // nether brick stair
    {""}, // enchantment table
    {""}, // brewing stand
    {"cauldron_top"}, // cauldron
    {""}, // end portal
    {""}, // end portal frame
    {"whiteStone"}, // end stone
    {""}, // dragon egg
    {"redstoneLight"}, // redstone lamp
    {"redstoneLight_lit"}, // redstone lamp on
    {""}, // wooden double slab
    {""}, // wooden slab
    {""}, // cocoa plant
    {""}, // sandstone stairs
    {"oreEmerald"}, // emerald ore
    {""}, // ender chest
    {""}, // tripwire hook
    {""}, // tripwire
    {"blockEmerald"}, // emerald block
    {""}, // spruce wood stairs
    {""}, // birch wood stairs
    {""}, // jungle wood stairs
    {""}, // command block
    {""}  // beacon block
];

TextureInformation[BLOCK_IDS] TEXTURE_INFORMATION_BOTTOM = [
    {""}, // air
    {"stone"}, // stone
    {"dirt"}, // grass
    {"dirt"}, // dirt
    {"stonebrick"}, // cobble
    {"wood"}, // wooden plank
    {""}, // sappling
    {"bedrock"}, // bedrock
    {""}, // water
    {""}, // stationary water
    {""}, // lava
    {""}, // stationary lava
    {"sand"}, // sand
    {"gravel"}, // gravel
    {"oreGold"}, // gold ore
    {"oreIron"}, // iron ore
    {"oreCoal"}, // coal ore
    {"tree_top"}, // wood
    {"leaves"}, // leaf
    {"sponge"}, // sponge
    {"glass"}, // glass
    {"oreLapis"}, // lapis lazuli ore
    {"blockLapis"}, // lapis lazuli block
    {"furnace_top"}, // dispenser
    {"sandstone_bottom"}, // sandstone
    {"musicBlock"}, // noteblock
    {""}, // bed
    {""}, // powered rail
    {""}, // detector rail
    {""}, // sticky piston
    {""}, // cobweb
    {""}, // tall grass
    {""}, // dead bush
    {""}, // piston
    {""}, // piston extension
    {""}, // wool
    {""}, // block moved by piston
    {""}, // dandelion
    {""}, // rose
    {""}, // brown mushroom
    {""}, // red mushroom
    {"blockGold"}, // gold block
    {"blockIron"}, // iron block
    {"stoneslab_top"}, // double slab
    {""}, // slab
    {"brick"}, // brick
    {"tnt_bottom"}, // tnt
    {"wood"}, // bookshelf
    {"stoneMoss"}, // mossy stone
    {"obsidian"}, // obsidian
    {""}, // torch
    {""}, // fire
    {"mobSpawner"}, // spawner
    {""}, // wooden stair
    {""}, // chest
    {""}, // redstone wire
    {"oreDiamond"}, // diamond ore
    {"blockDiamond"}, // diamond block
    {"workbench_side"}, // crafting table
    {""}, // wheat
    {"dirt"}, // farmland
    {"furnace_top"}, // furnace
    {"furnace_top"}, // burning furnace
    {""}, // sign post
    {""}, // wooden door
    {""}, // ladder
    {""}, // rail
    {""}, // cobblestone stair
    {""}, // wall sign
    {""}, // lever
    {""}, // stone pressure plate
    {""}, // iron door
    {""}, // wooden pressure plate
    {"oreRedstone"}, // redstone ore
    {"oreRedstone"}, // glowing redstone ore TODO
    {""}, // redstone torch
    {""}, // redstone torch on
    {""}, // stone button
    {""}, // snow
    {"ice"}, // ice
    {"snow_side"}, // snow block
    {""}, // cactus
    {"clay"}, // clay block
    {""}, // sugar cane
    {"musicBlock"}, // jukebox
    {""}, // fence
    {"pumpkin_top"}, // pumpkin
    {"hellrock"}, // netherrack
    {"hellsand"}, // soul sand
    {"lightgem"}, // glowstone block
    {""}, // portal
    {"pumpkin_top"}, // jack-o-lantern
    {""}, // cake block
    {""}, // redstone repeater
    {""}, // redstone repeater on
    {""}, // locked chest
    {""}, // trapdoor
    {""}, // hidden silverfish
    {"stonebricksmooth"}, // stone brick
    {""}, // huge brown mushroom
    {""}, // huge red mushroom
    {""}, // iron bar
    {""}, // glass pane
    {"dirt"}, // melon
    {""}, // pumpkin stem
    {""}, // melon stem
    {""}, // vine
    {""}, // fence gate
    {""}, // brick stair
    {""}, // stone brick stair
    {"mycel_side"}, // mycelium
    {""}, // lilly pad
    {"netherBrick"}, // nether brick
    {""}, // nether brick fence
    {""}, // nether wart
    {""}, // nether brick stair
    {""}, // enchantment table
    {""}, // brewing stand
    {"cauldron_bottom"}, // cauldron
    {""}, // end portal
    {""}, // end portal frame
    {"whiteStone"}, // end stone
    {""}, // dragon egg
    {"redstoneLight"}, // redstone lamp
    {"redstoneLight_lit"}, // redstone lamp on
    {""}, // wooden double slab
    {""}, // wooden slab
    {""}, // cocoa plant
    {""}, // sandstone stairs
    {"oreEmerald"}, // emerald ore
    {""}, // ender chest
    {""}, // tripwire hook
    {""}, // tripwire
    {"blockEmerald"}, // emerald block
    {""}, // spruce wood stairs
    {""}, // birch wood stairs
    {""}, // jungle wood stairs
    {""}, // command block
    {""}  // beacon block
];

// Order matches Side.*
TextureInformation[BLOCK_IDS][6] TEXTURE_INFORMATION;

static this() {
    TEXTURE_INFORMATION = [
        TEXTURE_INFORMATION_NEAR,
        TEXTURE_INFORMATION_LEFT,
        TEXTURE_INFORMATION_FAR,
        TEXTURE_INFORMATION_RIGHT,
        TEXTURE_INFORMATION_TOP,
        TEXTURE_INFORMATION_BOTTOM
    ];
}