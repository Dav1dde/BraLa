module brala.dine.builder.biomes;

private {
    import std.typecons : Tuple;
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

alias Tuple!(float, "u", float, "v") UVTuple;

struct BiomeData {
    byte id;
    float temperature;
    float rainfall;

    @property UVTuple grass_uv() const {
        return UVTuple(0.5 + (1-temperature/2.0f)/2.0f, (1-rainfall/2.0)/2.0f);
    }

    @property UVTuple leave_uv() const {
        return UVTuple((1-temperature/2.0f)/2.0f, 0.5f + (1-rainfall/2.0f)/2.0f);
    }

    @property UVTuple water_uv() const {
        return UVTuple(0.5f + (1-temperature/2.0f)/2.0f, 0.5f + (1-rainfall/2.0f)/2.0f);
    }
}

BiomeData[23] BIOMES = [
    {0, 0.50f, 0.50f},   // Ocean
    {1, 0.80f, 0.40f},   // Plains
    {2, 2.00f, 0.00f},   // Desert
    {3, 0.20f, 0.30f},   // Extreme Hills
    {4, 0.70f, 0.80f},   // Forest
    {5, 0.05f, 0.80f},   // Taiga
    {6, 0.80f, 0.90f},   // Swampland
    {7, 0.50f, 0.50f},   // River
    {8, 2.00f, 0.00f},   // Hell
    {9, 0.50f, 0.00f},   // Sky
    {10, 0.00f, 0.50f},  // FrozenOcean
    {11, 0.00f, 0.50f},  // FrozenRiver
    {12, 0.00f, 0.50f},  // Ice Plains
    {13, 0.00f, 0.50f},  // Ice Mountains
    {14, 0.90f, 1.00f},  // MushroomIsland
    {15, 0.90f, 1.00f},  // MushroomIslandShore
    {16, 0.80f, 0.40f},  // Beach
    {17, 2.00f, 0.00f},  // DesertHills
    {18, 0.70f, 0.80f},  // ForestHills
    {19, 0.05f, 0.80f},  // TaigaHills
    {20, 0.20f, 0.30f},  // Extreme Hills Edge
    {21, 1.20f, 0.90f},  // Jungle
    {22, 1.20f, 0.90f}  // Jungle Hills
];