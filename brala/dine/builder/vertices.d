module brala.dine.builder.vertices;

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
    {"cobblestone"}, // cobble
    {"planks_oak"}, // wooden plank
    {""}, // sappling
    {"bedrock"}, // bedrock
    {""}, // water
    {""}, // stationary water
    {""}, // lava
    {""}, // stationary lava
    {"sand"}, // sand
    {"gravel"}, // gravel
    {"gold_ore"}, // gold ore
    {"iron_ore"}, // iron ore
    {"coal_ore"}, // coal ore
    {"log_oak"}, // wood
    {"leaves_oak"}, // leafs
    {"sponge"}, // sponge
    {"glass"}, // glass
    {"lapis_ore"}, // lapis lazuli ore
    {"lapis_block"}, // lapis lazuli block
    {"furnace_side"}, // dispenser
    {"sandstone_normal"}, // sandstone
    {"noteblock"}, // noteblock
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
    {"gold_block"}, // gold block
    {"iron_block"}, // iron block
    {"stone_slab_side"}, // double slab
    {""}, // slab
    {"brick"}, // brick
    {"tnt_side"}, // tnt
    {"bookshelf"}, // bookshelf
    {"cobblestone_mossy"}, // mossy stone
    {"obsidian"}, // obsidian
    {""}, // torch
    {""}, // fire
    {"mob_spawner"}, // spawner
    {""}, // wooden stair
    {""}, // chest
    {""}, // redstone wire
    {"diamond_ore"}, // diamond ore
    {"diamond_block"}, // diamond block
    {"crafting_table_side"}, // crafting table TODO front
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
    {"redstone_ore"}, // redstone ore
    {"redstone_ore"}, // glowing redstone ore TODO
    {""}, // redstone torch
    {""}, // redstone torch on
    {""}, // stone button
    {""}, // snow
    {"ice"}, // ice
    {"snow"}, // snow block
    {""}, // cactus
    {"clay"}, // clay block
    {""}, // sugar cane
    {"noteblock"}, // jukebox
    {""}, // fence
    {"pumpkin_side"}, // pumpkin
    {"netherrack"}, // netherrack
    {"soul_sand"}, // soul sand
    {"glowstone"}, // glowstone block
    {""}, // portal
    {"pumpkin_side"}, // jack-o-lantern
    {""}, // cake block
    {""}, // redstone repeater
    {""}, // redstone repeater on
    {""}, // locked chest
    {""}, // trapdoor
    {""}, // hidden silverfish
    {"stonebrick"}, // stone brick
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
    {"mycelium_side"}, // mycelium
    {""}, // lilly pad
    {"nether_brick"}, // nether brick
    {""}, // nether brick fence
    {""}, // nether wart
    {""}, // nether brick stair
    {""}, // enchantment table
    {""}, // brewing stand
    {"cauldron_side"}, // cauldron
    {""}, // end portal
    {""}, // end portal frame
    {"end_stone"}, // end stone
    {""}, // dragon egg
    {"redstone_lamp_off"}, // redstone lamp
    {"redstone_lamp_on"}, // redstone lamp on
    {""}, // wooden double slab
    {""}, // wooden slab
    {""}, // cocoa plant
    {""}, // sandstone stairs
    {"emerald_ore"}, // emerald ore
    {""}, // ender chest
    {""}, // tripwire hook
    {""}, // tripwire
    {"emerald_block"}, // emerald block
    {""}, // spruce wood stairs
    {""}, // birch wood stairs
    {""}, // jungle wood stairs
    {""}, // command block
    {""}, // beacon block
    {""}, // cobblestone wall
    {""}, // flower pot
    {""}, // carrots
    {""}, // potatoes
    {""}, // wooden button
    {""}, // mob head
    {""}, // anvil
    {""}, // trapped chest
    {""}, // weighted pressure plate (light/gold)
    {""}, // weighted preasure plate (heavy/iron)
    {""}, // redstone comparator off
    {""}, // redstone comparator on
    {""}, // daylight sensor
    {"redstone_block"}, // block of redstone
    {"quartz_ore"}, // quartz ore
    {""}, // hopper
    {"quartz_block_side"}, // block of quartz
    {""}, // activator rail
    {""}, // dropper
    {""}, // stained clay
    {""}, // 160
    {""}, // 161
    {""}, // 162
    {""}, // 163
    {""}, // 164
    {""}, // 165
    {""}, // 166
    {""}, // 167
    {""}, // 168
    {""}, // 169
    {"hay_block_side"}, // hay block
    {""}, // carpet
    {""}, // hardened clay
    {"coal_block"}, // block of coal
    {""}, // 174
    {""}, // 175
];

TextureInformation[BLOCK_IDS] TEXTURE_INFORMATION_RIGHT = [
    {""}, // air
    {"stone"}, // stone
    {"grass_side", "grass_side_overlay"}, // grass
    {"dirt"}, // dirt
    {"cobblestone"}, // cobble
    {"planks_oak"}, // wooden plank
    {""}, // sappling
    {"bedrock"}, // bedrock
    {""}, // water
    {""}, // stationary water
    {""}, // lava
    {""}, // stationary lava
    {"sand"}, // sand
    {"gravel"}, // gravel
    {"gold_ore"}, // gold ore
    {"iron_ore"}, // iron ore
    {"coal_ore"}, // coal ore
    {"log_oak"}, // wood
    {"leaves_oak"}, // leaf
    {"sponge"}, // sponge
    {"glass"}, // glass
    {"lapis_ore"}, // lapis lazuli ore
    {"lapis_block"}, // lapis lazuli block
    {"furnace_side"}, // dispenser
    {"sandstone_normal"}, // sandstone
    {"noteblock"}, // noteblock
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
    {"gold_block"}, // gold block
    {"iron_block"}, // iron block
    {"stone_slab_side"}, // double slab
    {""}, // slab
    {"brick"}, // brick
    {"tnt_side"}, // tnt
    {"bookshelf"}, // bookshelf
    {"cobblestone_mossy"}, // mossy stone
    {"obsidian"}, // obsidian
    {""}, // torch
    {""}, // fire
    {"mob_spawner"}, // spawner
    {""}, // wooden stair
    {""}, // chest
    {""}, // redstone wire
    {"diamond_ore"}, // diamond ore
    {"diamond_block"}, // diamond block
    {"crafting_table_side"}, // crafting table
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
    {"redstone_ore"}, // redstone ore
    {"redstone_ore"}, // glowing redstone ore TODO
    {""}, // redstone torch
    {""}, // redstone torch on
    {""}, // stone button
    {""}, // snow
    {"ice"}, // ice
    {"snow"}, // snow block
    {""}, // cactus
    {"clay"}, // clay block
    {""}, // sugar cane
    {"noteblock"}, // jukebox
    {""}, // fence
    {"pumpkin_side"}, // pumpkin
    {"netherrack"}, // netherrack
    {"soul_sand"}, // soul sand
    {"glowstone"}, // glowstone block
    {""}, // portal
    {"pumpkin_side"}, // jack-o-lantern
    {""}, // cake block
    {""}, // redstone repeater
    {""}, // redstone repeater on
    {""}, // locked chest
    {""}, // trapdoor
    {""}, // hidden silverfish
    {"stonebrick"}, // stone brick
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
    {"mycelium_side"}, // mycelium
    {""}, // lilly pad
    {"nether_brick"}, // nether brick
    {""}, // nether brick fence
    {""}, // nether wart
    {""}, // nether brick stair
    {""}, // enchantment table
    {""}, // brewing stand
    {"cauldron_side"}, // cauldron
    {""}, // end portal
    {""}, // end portal frame
    {"end_stone"}, // end stone
    {""}, // dragon egg
    {"redstone_lamp_off"}, // redstone lamp
    {"redstone_lamp_on"}, // redstone lamp on
    {""}, // wooden double slab
    {""}, // wooden slab
    {""}, // cocoa plant
    {""}, // sandstone stairs
    {"emerald_ore"}, // emerald ore
    {""}, // ender chest
    {""}, // tripwire hook
    {""}, // tripwire
    {"emerald_block"}, // emerald block
    {""}, // spruce wood stairs
    {""}, // birch wood stairs
    {""}, // jungle wood stairs
    {""}, // command block
    {""}, // beacon block
    {""}, // cobblestone wall
    {""}, // flower pot
    {""}, // carrots
    {""}, // potatoes
    {""}, // wooden button
    {""}, // mob head
    {""}, // anvil
    {""}, // trapped chest
    {""}, // weighted pressure plate (light/gold)
    {""}, // weighted preasure plate (heavy/iron)
    {""}, // redstone comparator off
    {""}, // redstone comparator on
    {""}, // daylight sensor
    {"redstone_block"}, // block of redstone
    {"quartz_ore"}, // quartz ore
    {""}, // hopper
    {"quartz_block_side"}, // block of quartz
    {""}, // activator rail
    {""}, // dropper
    {""}, // stained clay
    {""}, // 160
    {""}, // 161
    {""}, // 162
    {""}, // 163
    {""}, // 164
    {""}, // 165
    {""}, // 166
    {""}, // 167
    {""}, // 168
    {""}, // 169
    {"hay_block_side"}, // hay block
    {""}, // carpet
    {""}, // hardened clay
    {"coal_block"}, // block of coal
    {""}, // 174
    {""}, // 175
];

TextureInformation[BLOCK_IDS] TEXTURE_INFORMATION_NEAR = [
    {""}, // air
    {"stone"}, // stone
    {"grass_side", "grass_side_overlay"}, // grass
    {"dirt"}, // dirt
    {"cobblestone"}, // cobble
    {"planks_oak"}, // wooden plank
    {""}, // sappling
    {"bedrock"}, // bedrock
    {""}, // water
    {""}, // stationary water
    {""}, // lava
    {""}, // stationary lava
    {"sand"}, // sand
    {"gravel"}, // gravel
    {"gold_ore"}, // gold ore
    {"iron_ore"}, // iron ore
    {"coal_ore"}, // coal ore
    {"log_oak"}, // wood
    {"leaves_oak"}, // leaf
    {"sponge"}, // sponge
    {"glass"}, // glass
    {"lapis_ore"}, // lapis lazuli ore
    {"lapis_block"}, // lapis lazuli block
    {"furnace_side"}, // dispenser
    {"sandstone_normal"}, // sandstone
    {"noteblock"}, // noteblock
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
    {"gold_block"}, // gold block
    {"iron_block"}, // iron block
    {"stone_slab_side"}, // double slab
    {""}, // slab
    {"brick"}, // brick
    {"tnt_side"}, // tnt
    {"bookshelf"}, // bookshelf
    {"cobblestone_mossy"}, // mossy stone
    {"obsidian"}, // obsidian
    {""}, // torch
    {""}, // fire
    {"mob_spawner"}, // spawner
    {""}, // wooden stair
    {""}, // chest
    {""}, // redstone wire
    {"diamond_ore"}, // diamond ore
    {"diamond_block"}, // diamond block
    {"crafting_table_side"}, // crafting table
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
    {"redstone_ore"}, // redstone ore
    {"redstone_ore"}, // glowing redstone ore TODO
    {""}, // redstone torch
    {""}, // redstone torch on
    {""}, // stone button
    {""}, // snow
    {"ice"}, // ice
    {"snow"}, // snow block
    {""}, // cactus
    {"clay"}, // clay block
    {""}, // sugar cane
    {"noteblock"}, // jukebox
    {""}, // fence
    {"pumpkin_side"}, // pumpkin
    {"netherrack"}, // netherrack
    {"soul_sand"}, // soul sand
    {"glowstone"}, // glowstone block
    {""}, // portal
    {"pumpkin_side"}, // jack-o-lantern
    {""}, // cake block
    {""}, // redstone repeater
    {""}, // redstone repeater on
    {""}, // locked chest
    {""}, // trapdoor
    {""}, // hidden silverfish
    {"stonebrick"}, // stone brick
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
    {"mycelium_side"}, // mycelium
    {""}, // lilly pad
    {"nether_brick"}, // nether brick
    {""}, // nether brick fence
    {""}, // nether wart
    {""}, // nether brick stair
    {""}, // enchantment table
    {""}, // brewing stand
    {"cauldron_side"}, // cauldron
    {""}, // end portal
    {""}, // end portal frame
    {"end_stone"}, // end stone
    {""}, // dragon egg
    {"redstone_lamp_off"}, // redstone lamp
    {"redstone_lamp_on"}, // redstone lamp on
    {""}, // wooden double slab
    {""}, // wooden slab
    {""}, // cocoa plant
    {""}, // sandstone stairs
    {"emerald_ore"}, // emerald ore
    {""}, // ender chest
    {""}, // tripwire hook
    {""}, // tripwire
    {"emerald_block"}, // emerald block
    {""}, // spruce wood stairs
    {""}, // birch wood stairs
    {""}, // jungle wood stairs
    {""}, // command block
    {""}, // beacon block
    {""}, // cobblestone wall
    {""}, // flower pot
    {""}, // carrots
    {""}, // potatoes
    {""}, // wooden button
    {""}, // mob head
    {""}, // anvil
    {""}, // trapped chest
    {""}, // weighted pressure plate (light/gold)
    {""}, // weighted preasure plate (heavy/iron)
    {""}, // redstone comparator off
    {""}, // redstone comparator on
    {""}, // daylight sensor
    {"redstone_block"}, // block of redstone
    {"quartz_ore"}, // quartz ore
    {""}, // hopper
    {"quartz_block_side"}, // block of quartz
    {""}, // activator rail
    {""}, // dropper
    {""}, // stained clay
    {""}, // 160
    {""}, // 161
    {""}, // 162
    {""}, // 163
    {""}, // 164
    {""}, // 165
    {""}, // 166
    {""}, // 167
    {""}, // 168
    {""}, // 169
    {"hay_block_side"}, // hay block
    {""}, // carpet
    {""}, // hardened clay
    {"coal_block"}, // block of coal
    {""}, // 174
    {""}, // 175
];

TextureInformation[BLOCK_IDS] TEXTURE_INFORMATION_FAR = [
    {""}, // air
    {"stone"}, // stone
    {"grass_side", "grass_side_overlay"}, // grass
    {"dirt"}, // dirt
    {"cobblestone"}, // cobble
    {"planks_oak"}, // wooden plank
    {""}, // sappling
    {"bedrock"}, // bedrock
    {""}, // water
    {""}, // stationary water
    {""}, // lava
    {""}, // stationary lava
    {"sand"}, // sand
    {"gravel"}, // gravel
    {"gold_ore"}, // gold ore
    {"iron_ore"}, // iron ore
    {"coal_ore"}, // coal ore
    {"log_oak"}, // wood
    {"leaves_oak"}, // leaf
    {"sponge"}, // sponge
    {"glass"}, // glass
    {"lapis_ore"}, // lapis lazuli ore
    {"lapis_block"}, // lapis lazuli block
    {"furnace_side"}, // dispenser
    {"sandstone_normal"}, // sandstone
    {"noteblock"}, // noteblock
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
    {"gold_block"}, // gold block
    {"iron_block"}, // iron block
    {"stone_slab_side"}, // double slab
    {""}, // slab
    {"brick"}, // brick
    {"tnt_side"}, // tnt
    {"bookshelf"}, // bookshelf
    {"cobblestone_mossy"}, // mossy stone
    {"obsidian"}, // obsidian
    {""}, // torch
    {""}, // fire
    {"mob_spawner"}, // spawner
    {""}, // wooden stair
    {""}, // chest
    {""}, // redstone wire
    {"diamond_ore"}, // diamond ore
    {"diamond_block"}, // diamond block
    {"crafting_table_side"}, // crafting table
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
    {"redstone_ore"}, // redstone ore
    {"redstone_ore"}, // glowing redstone ore TODO
    {""}, // redstone torch
    {""}, // redstone torch on
    {""}, // stone button
    {""}, // snow
    {"ice"}, // ice
    {"snow"}, // snow block
    {""}, // cactus
    {"clay"}, // clay block
    {""}, // sugar cane
    {"noteblock"}, // jukebox
    {""}, // fence
    {"pumpkin_side"}, // pumpkin
    {"netherrack"}, // netherrack
    {"soul_sand"}, // soul sand
    {"glowstone"}, // glowstone block
    {""}, // portal
    {"pumpkin_side"}, // jack-o-lantern
    {""}, // cake block
    {""}, // redstone repeater
    {""}, // redstone repeater on
    {""}, // locked chest
    {""}, // trapdoor
    {""}, // hidden silverfish
    {"stonebrick"}, // stone brick
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
    {"mycelium_side"}, // mycelium
    {""}, // lilly pad
    {"nether_brick"}, // nether brick
    {""}, // nether brick fence
    {""}, // nether wart
    {""}, // nether brick stair
    {""}, // enchantment table
    {""}, // brewing stand
    {"cauldron_side"}, // cauldron
    {""}, // end portal
    {""}, // end portal frame
    {"end_stone"}, // end stone
    {""}, // dragon egg
    {"redstone_lamp_off"}, // redstone lamp
    {"redstone_lamp_on"}, // redstone lamp on
    {""}, // wooden double slab
    {""}, // wooden slab
    {""}, // cocoa plant
    {""}, // sandstone stairs
    {"emerald_ore"}, // emerald ore
    {""}, // ender chest
    {""}, // tripwire hook
    {""}, // tripwire
    {"emerald_block"}, // emerald block
    {""}, // spruce wood stairs
    {""}, // birch wood stairs
    {""}, // jungle wood stairs
    {""}, // command block
    {""}, // beacon block
    {""}, // cobblestone wall
    {""}, // flower pot
    {""}, // carrots
    {""}, // potatoes
    {""}, // wooden button
    {""}, // mob head
    {""}, // anvil
    {""}, // trapped chest
    {""}, // weighted pressure plate (light/gold)
    {""}, // weighted preasure plate (heavy/iron)
    {""}, // redstone comparator off
    {""}, // redstone comparator on
    {""}, // daylight sensor
    {"redstone_block"}, // block of redstone
    {"quartz_ore"}, // quartz ore
    {""}, // hopper
    {"quartz_block_side"}, // block of quartz
    {""}, // activator rail
    {""}, // dropper
    {""}, // stained clay
    {""}, // 160
    {""}, // 161
    {""}, // 162
    {""}, // 163
    {""}, // 164
    {""}, // 165
    {""}, // 166
    {""}, // 167
    {""}, // 168
    {""}, // 169
    {"hay_block_side"}, // hay block
    {""}, // carpet
    {""}, // hardened clay
    {"coal_block"}, // block of coal
    {""}, // 174
    {""}, // 175
];

TextureInformation[BLOCK_IDS] TEXTURE_INFORMATION_TOP = [
    {""}, // air
    {"stone"}, // stone
    {"grass_top"}, // grass
    {"dirt"}, // dirt
    {"cobblestone"}, // cobble
    {"planks_oak"}, // wooden plank
    {""}, // sappling
    {"bedrock"}, // bedrock
    {""}, // water
    {""}, // stationary water
    {""}, // lava
    {""}, // stationary lava
    {"sand"}, // sand
    {"gravel"}, // gravel
    {"gold_ore"}, // gold ore
    {"iron_ore"}, // iron ore
    {"coal_ore"}, // coal ore
    {"log_oak_top"}, // wood
    {"leaves_oak"}, // leaf
    {"sponge"}, // sponge
    {"glass"}, // glass
    {"lapis_ore"}, // lapis lazuli ore
    {"lapis_block"}, // lapis lazuli block
    {"furnace_top"}, // dispenser
    {"sandstone_top"}, // sandstone
    {"noteblock"}, // noteblock
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
    {"gold_block"}, // gold block
    {"iron_block"}, // iron block
    {"stone_slab_top"}, // double slab
    {""}, // slab
    {"brick"}, // brick
    {"tnt_bottom"}, // tnt
    {"planks_oak"}, // bookshelf
    {"cobblestone_mossy"}, // mossy stone
    {"obsidian"}, // obsidian
    {""}, // torch
    {""}, // fire
    {"mob_spawner"}, // spawner
    {""}, // wooden stair
    {""}, // chest
    {""}, // redstone wire
    {"diamond_ore"}, // diamond ore
    {"diamond_block"}, // diamond block
    {"crafting_table_side"}, // crafting table
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
    {"redstone_ore"}, // redstone ore
    {"redstone_ore"}, // glowing redstone ore TODO
    {""}, // redstone torch
    {""}, // redstone torch on
    {""}, // stone button
    {""}, // snow
    {"ice"}, // ice
    {"snow"}, // snow block
    {""}, // cactus
    {"clay"}, // clay block
    {""}, // sugar cane
    {"jukebox_top"}, // jukebox
    {""}, // fence
    {"pumpkin_top"}, // pumpkin
    {"netherrack"}, // netherrack
    {"soul_sand"}, // soul sand
    {"glowstone"}, // glowstone block
    {""}, // portal
    {"pumpkin_top"}, // jack-o-lantern
    {""}, // cake block
    {""}, // redstone repeater
    {""}, // redstone repeater on
    {""}, // locked chest
    {""}, // trapdoor
    {""}, // hidden silverfish
    {"stonebrick"}, // stone brick
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
    {"mycelium_top"}, // mycelium
    {""}, // lilly pad
    {"nether_brick"}, // nether brick
    {""}, // nether brick fence
    {""}, // nether wart
    {""}, // nether brick stair
    {""}, // enchantment table
    {""}, // brewing stand
    {"cauldron_top"}, // cauldron
    {""}, // end portal
    {""}, // end portal frame
    {"end_stone"}, // end stone
    {""}, // dragon egg
    {"redstone_lamp_off"}, // redstone lamp
    {"redstone_lamp_on"}, // redstone lamp on
    {""}, // wooden double slab
    {""}, // wooden slab
    {""}, // cocoa plant
    {""}, // sandstone stairs
    {"emerald_ore"}, // emerald ore
    {""}, // ender chest
    {""}, // tripwire hook
    {""}, // tripwire
    {"emerald_block"}, // emerald block
    {""}, // spruce wood stairs
    {""}, // birch wood stairs
    {""}, // jungle wood stairs
    {""}, // command block
    {""}, // beacon block
    {""}, // cobblestone wall
    {""}, // flower pot
    {""}, // carrots
    {""}, // potatoes
    {""}, // wooden button
    {""}, // mob head
    {""}, // anvil
    {""}, // trapped chest
    {""}, // weighted pressure plate (light/gold)
    {""}, // weighted preasure plate (heavy/iron)
    {""}, // redstone comparator off
    {""}, // redstone comparator on
    {""}, // daylight sensor
    {"redstone_block"}, // block of redstone
    {"quartz_ore"}, // quartz ore
    {""}, // hopper
    {"quartz_block_top"}, // block of quartz
    {""}, // activator rail
    {""}, // dropper
    {""}, // stained clay
    {""}, // 160
    {""}, // 161
    {""}, // 162
    {""}, // 163
    {""}, // 164
    {""}, // 165
    {""}, // 166
    {""}, // 167
    {""}, // 168
    {""}, // 169
    {"hay_block_top"}, // hay block
    {""}, // carpet
    {""}, // hardened clay
    {"coal_block"}, // block of coal
    {""}, // 174
    {""}, // 175
];

TextureInformation[BLOCK_IDS] TEXTURE_INFORMATION_BOTTOM = [
    {""}, // air
    {"stone"}, // stone
    {"dirt"}, // grass
    {"dirt"}, // dirt
    {"cobblestone"}, // cobble
    {"planks_oak"}, // wooden plank
    {""}, // sappling
    {"bedrock"}, // bedrock
    {""}, // water
    {""}, // stationary water
    {""}, // lava
    {""}, // stationary lava
    {"sand"}, // sand
    {"gravel"}, // gravel
    {"gold_ore"}, // gold ore
    {"iron_ore"}, // iron ore
    {"coal_ore"}, // coal ore
    {"log_oak_top"}, // wood
    {"leaves_oak"}, // leaf
    {"sponge"}, // sponge
    {"glass"}, // glass
    {"lapis_ore"}, // lapis lazuli ore
    {"lapis_block"}, // lapis lazuli block
    {"furnace_top"}, // dispenser
    {"sandstone_bottom"}, // sandstone
    {"noteblock"}, // noteblock
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
    {"gold_block"}, // gold block
    {"iron_block"}, // iron block
    {"stone_slab_top"}, // double slab
    {""}, // slab
    {"brick"}, // brick
    {"tnt_bottom"}, // tnt
    {"planks_oak"}, // bookshelf
    {"cobblestone_mossy"}, // mossy stone
    {"obsidian"}, // obsidian
    {""}, // torch
    {""}, // fire
    {"mob_spawner"}, // spawner
    {""}, // wooden stair
    {""}, // chest
    {""}, // redstone wire
    {"diamond_ore"}, // diamond ore
    {"diamond_block"}, // diamond block
    {"crafting_table_side"}, // crafting table
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
    {"redstone_ore"}, // redstone ore
    {"redstone_ore"}, // glowing redstone ore TODO
    {""}, // redstone torch
    {""}, // redstone torch on
    {""}, // stone button
    {""}, // snow
    {"ice"}, // ice
    {"snow"}, // snow block
    {""}, // cactus
    {"clay"}, // clay block
    {""}, // sugar cane
    {"noteblock"}, // jukebox
    {""}, // fence
    {"pumpkin_top"}, // pumpkin
    {"netherrack"}, // netherrack
    {"soul_sand"}, // soul sand
    {"glowstone"}, // glowstone block
    {""}, // portal
    {"pumpkin_top"}, // jack-o-lantern
    {""}, // cake block
    {""}, // redstone repeater
    {""}, // redstone repeater on
    {""}, // locked chest
    {""}, // trapdoor
    {""}, // hidden silverfish
    {"stonebrick"}, // stone brick
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
    {"mycelium_side"}, // mycelium
    {""}, // lilly pad
    {"nether_brick"}, // nether brick
    {""}, // nether brick fence
    {""}, // nether wart
    {""}, // nether brick stair
    {""}, // enchantment table
    {""}, // brewing stand
    {"cauldron_bottom"}, // cauldron
    {""}, // end portal
    {""}, // end portal frame
    {"end_stone"}, // end stone
    {""}, // dragon egg
    {"redstone_lamp_off"}, // redstone lamp
    {"redstone_lamp_on"}, // redstone lamp on
    {""}, // wooden double slab
    {""}, // wooden slab
    {""}, // cocoa plant
    {""}, // sandstone stairs
    {"emerald_ore"}, // emerald ore
    {""}, // ender chest
    {""}, // tripwire hook
    {""}, // tripwire
    {"emerald_block"}, // emerald block
    {""}, // spruce wood stairs
    {""}, // birch wood stairs
    {""}, // jungle wood stairs
    {""}, // command block
    {""}, // beacon block
    {""}, // cobblestone wall
    {""}, // flower pot
    {""}, // carrots
    {""}, // potatoes
    {""}, // wooden button
    {""}, // mob head
    {""}, // anvil
    {""}, // trapped chest
    {""}, // weighted pressure plate (light/gold)
    {""}, // weighted preasure plate (heavy/iron)
    {""}, // redstone comparator off
    {""}, // redstone comparator on
    {""}, // daylight sensor
    {"redstone_block"}, // block of redstone
    {"quartz_ore"}, // quartz ore
    {""}, // hopper
    {"quartz_block_bottom"}, // block of quartz
    {""}, // activator rail
    {""}, // dropper
    {""}, // stained clay
    {""}, // 160
    {""}, // 161
    {""}, // 162
    {""}, // 163
    {""}, // 164
    {""}, // 165
    {""}, // 166
    {""}, // 167
    {""}, // 168
    {""}, // 169
    {"hay_block_top"}, // hay block
    {""}, // carpet
    {""}, // hardened clay
    {"coal_block"}, // block of coal
    {""}, // 174
    {""}, // 175
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