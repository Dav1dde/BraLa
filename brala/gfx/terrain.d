module brala.gfx.terrain;

private {
    import stb_image : stbi_load_from_memory, stbi_image_free;
    
    import std.zip : ZipArchive;
    import std.path : expandTilde;
    import file = std.file;
    
    import brala.utils.image : Image, RGB, RGBA;
    import brala.utils.exception : ImageException;
}


Image preprocess_terrain(Image terrain) {
    if(terrain.comp != RGBA) {
        terrain = terrain.convert(RGBA);
    }

    int tile_width = terrain.width / 16; // 16 tiles
    int tile_height = terrain.height / 16; // 16 tiles
    
    Image grass_overlay = terrain.crop(tile_width*6, tile_height*2,
                                       tile_width*7, tile_height*3);

    terrain.blend(tile_width*3, 0, grass_overlay,
                  (t, o) => o[3] > 0 ? o : t.dup);

    return terrain;
}


Image extract_minecraft_terrain(string path) {
    ZipArchive za = new ZipArchive(file.read(path));

    auto am = za.directory["terrain.png"];
    auto content = za.expand(am);

    int x;
    int y;
    int comp;    
    ubyte* data = stbi_load_from_memory(content.ptr, cast(uint)content.length, &x, &y, &comp, 0);

    if(data is null) {
        throw new ImageException("Unable to load terrain.png");
    }

    scope(exit) stbi_image_free(data);

    if(!(comp == RGB || comp == RGBA)) {
        throw new ImageException("Unknown/Unsupported stbi image format");
    }

    return new Image(data[0..x*y*comp].dup, x, y, comp);
}
