module brala.dine.builder.biomes;

private {
    import std.typecons : Tuple;

    import brala.resmgr : ResourceManager;
    import brala.utils.image : Image;
}

public import brala.dine.builder.constants : Biome;


alias Tuple!(ubyte, "r", ubyte, "g", ubyte, "b", ubyte, "a") Color4;


struct BiomeSet {
    BiomeData[23] biomes = DEFAULT_BIOMES.dup;

    this(ResourceManager resmgr) {
        update_colors(resmgr);
    }

    this(BiomeData[23] biomes) {
        this.biomes = biomes;
    }

    this(ResourceManager resmgr, BiomeData[23] biomes) {
        this(biomes);
        update_colors(resmgr);
    }

    void update_colors(ResourceManager resmgr) {
        foreach(ref biome; biomes) {
            Image grass_img = resmgr.get!Image("grasscolor");
            Pixel pixel = biome.to_pixel(grass_img.width, grass_img.height);

            ubyte[] grass = grass_img.get_pixel(pixel.field);
            ubyte[] leave = resmgr.get!Image("leavecolor").get_pixel(pixel.field);
            ubyte[] water = resmgr.get!Image("watercolor").get_pixel(pixel.field);

            biome.color.grass = Color4(grass[0], grass[1], grass[2], cast(ubyte)0xff);
            biome.color.leave = Color4(leave[0], leave[1], leave[2], cast(ubyte)0xff);
            biome.color.water = Color4(water[0], water[1], water[2], cast(ubyte)0xff);
        }
    }
}

alias Tuple!(int, "x", int, "y") Pixel;

struct BiomeData {
    byte id;
    float temperature;
    float rainfall;

    struct Color {
        Color4 grass;
        Color4 leave;
        Color4 water;
    }

    Color color;

    Pixel to_pixel(int width, int height) const {       
        int x = cast(int)((width-1)*(1-temperature/2.0f));
        int y = cast(int)((height-1)*(1-rainfall/2.0f));
        
        return Pixel(x, y);
    }
}

const BiomeData[23] DEFAULT_BIOMES = [
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