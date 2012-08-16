module brala.dine.builder.constants;


enum Side : ubyte {
    NEAR, // south
    LEFT, // west
    FAR, // north
    RIGHT, // east
    TOP,
    BOTTOM,
    ALL
}

enum Facing {
    SOUTH,
    WEST,
    NORTH,
    EAST
}

enum Biome {
    OCEAN = 0,
    PLAINS,
    DESERT,
    EXTREME_HILLS,
    FOREST,
    TAIGA,
    SWAMPLAND,
    RIVER,
    HELL,
    SKY,
    FROZEN_OCEAN,
    FROZEN_RIVER,
    ICE_PLAINS,
    ICE_MOUNTAINS,
    MUSHROOM_ISLAND,
    MUSHROOM_ISLAND_SHORE,
    BEACH,
    DESERT_HILLS,
    FOREST_HILLS,
    TAIGA_HILLS,
    EXTREME_HILLS_EDGE,
    JUNGLE,
    JUNGLE_HILLS
}

enum Coal {
    Coal = 0,
    CharCoal
}

enum Jukebox {
    Nothing = 0,
    GoldDisc,
    GreenDisc,
    OrangeDisc,
    RedDisc,
    LimeDisc,
    PurpleDisc,
    VioletDisc,
    BlackDisc,
    WhiteDisc,
    SeaGreenDisc,
    BrokenDisc
}