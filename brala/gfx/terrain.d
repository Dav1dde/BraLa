module brala.gfx.terrain;

private {
    import stb_image : stbi_load_from_memory, stbi_image_free;
    
    import std.path : expandTilde, baseName, extension, stripExtension, setExtension;
    import std.string : format, splitLines, strip;
    import std.algorithm : canFind, min, max;
    import std.array : split, replace;
    import std.exception : enforceEx;
    import std.conv : to;
    import file = std.file;
    
    import brala.utils.atlas : Atlas;
    import brala.utils.image : Image, RGB, RGBA;
    import brala.utils.exception : ImageException, AtlasException;
    import brala.utils.zip : ZipArchive, ArchiveMember;
}



struct AtlasImage {
    Image image;
    alias image this;

    AnimatedImage[] images;

    size_t position;
    int frame;

    Image get_next() {
        return image;
    }
}

struct AnimatedImage {
    Image image;
    alias image this;

    int duration;
}

bool is_power_of_two(Image image) {
    if(image.width == 0 || image.height == 0 ||
        (image.width & (image.width - 1)) ||
        (image.height & (image.height - 1))) {

        return false;
    }

    return true;
}



class MinecraftAtlas : Atlas {
    this() {
        super(256, 256);
    }

    this(string path) {
        this();

        load(path);
    }

    void load(string path) {
        ZipArchive za = new ZipArchive(path);

        string[] files = za.list_dir("textures/blocks", false);
        foreach(f; files) {
            string name = f.baseName();

            if(f.extension() == ".png") {
                auto am = za.directory[f];
                Image image = Image.from_memory(za.expand(am));

                if(image.comp != RGBA) {
                    image = image.convert(RGBA);
                }

                AtlasImage atlas_image;
                atlas_image.image = image;

                string anim_file = f.setExtension(".txt");
                if(files.canFind(anim_file)) {
                    am = za.directory[anim_file];
                    auto data = cast(char[])za.expand(am);

                    foreach(line; data.splitLines()) {
                        foreach(comma; line.split(",")) {
                            auto anim_data = comma.replace(" ", "").split("*");
                            if(anim_data.length == 0) {
                                continue;
                            } else if(anim_data.length > 2) {
                                throw new AtlasException("Malformed animation file: " ~ anim_file);
                            }

                            AnimatedImage anim_image;

                            int index = to!int(anim_data[0]);
                            if(index < 0) {
                                throw new AtlasException("Negative animation frame: " ~ anim_file);
                            }

                            int min_ = min(image.width, image.height);
                            int max_ = max(image.width, image.height);
                            if((index+1)*min_ > max_) {
                                throw new AtlasException("Animation frame %s does not exist in %s".format(index, f));
                            }

                            if(image.width > image.height) {
                                anim_image.image = image.crop(index*image.height, 0, (index+1)*image.height, image.height);
                            } else {
                                anim_image.image = image.crop(0, index*image.width, image.width, (index+1)*image.width);
                            }

                            assert(anim_image.image.width == min(image.width, image.height));
                            assert(anim_image.image.width == anim_image.image.height);

                            if(anim_data.length == 2) {
                                int duration = to!int(anim_data[1]);

                                if(duration < 0) {
                                    throw new AtlasException("Negative animation duration: " ~ anim_file);
                                }
                                anim_image.duration = duration;
                            }

                            enforceEx!AtlasException(anim_image.is_power_of_two(),
                                                     "Animationframe %s is not a power of two: %s".format(index, f));

                            atlas_image.images ~= anim_image;
                        }
                    }

                    if(atlas_image.images.length) {
                        insert(atlas_image.images[0], name.stripExtension());
                    }

                    continue;
                }

                enforceEx!AtlasException(atlas_image.is_power_of_two(), "Image sides are not a power of two: " ~ f);
                insert(atlas_image.image, name.stripExtension());
            }
        }

//         atlas.write("/tmp/atlas.debug.png");
    }

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
