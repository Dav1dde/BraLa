module brala.gfx.terrain;

private {
    import brala.utils.image : Image, RGBA;
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
