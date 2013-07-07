module brala.gfx.terrain;

private {
    import stb_image : stbi_load_from_memory, stbi_image_free;
    import gl3n.linalg : vec2;
    import gl3n.math : sign;
    import glamour.sampler : Sampler;
    import glamour.gl;
    import glamour.util;
    
    import std.path : buildPath, expandTilde, baseName, extension,
                      stripExtension, setExtension;
    import std.algorithm : canFind, min, max, countUntil;
    import std.string : format, splitLines, strip;
    import std.array : split, replace;
    import std.exception : enforceEx;
    import std.typecons : tuple;
    import std.conv : to;
    import file = std.file;
    import std.json;
    
    import brala.log : logger = terrain_logger;
    import brala.engine : BraLaEngine;
    import brala.minecraft.folder : minecraft_jar;
    import brala.gfx.data : Vertex, Normal;
    import brala.gfx.util : is_power_of_two;
    import brala.dine.builder.constants : Side;
    import brala.dine.builder.vertices : TEXTURE_INFORMATION, simple_block;
    import brala.utils.log;
    import brala.utils.config : Config, Path;
    import brala.utils.ctfe : TupleRange;
    import brala.utils.atlas : Atlas, Rectangle;
    import brala.utils.image : Image, RGB, RGBA;
    import brala.utils.exception : ImageException, AtlasException;
    import brala.utils.zip : ZipArchive, ArchiveMember;
}


struct TextureCoordinate {
    short x;
    short y;

    short half_width;
    short half_height;

    // the *full* texture without rotation
    short[2][4] def;

    this(Rectangle rect) {
        assert((rect.x + rect.width / 2) <= short.max);
        assert((rect.y + rect.height / 2) <= short.max);
        half_width = cast(short)(rect.width / 2);
        half_height = cast(short)(rect.height / 2);
        x = cast(short)(rect.x + half_width);
        y = cast(short)(rect.y + half_height);

        def = [
            [cast(short)(rect.x), cast(short)(rect.y+rect.height)],
            [cast(short)(rect.x+rect.width), cast(short)(rect.y+rect.height)],
            [cast(short)(rect.x+rect.width), cast(short)(rect.y)],
            [cast(short)(rect.x), cast(short)(rect.y)]
        ];
    }

    @safe nothrow const pure
    auto unify(short left, short right, short top, short bottom) {
        return tuple(cast(short)((left/8.0)*half_width), cast(short)((right/8.0)*half_width),
                     cast(short)((top/8.0)*half_height), cast(short)((bottom/8.0)*half_height));
    }

    @safe nothrow const pure
    short[2][4] r0() {
        return def;
    }

    @safe nothrow const pure
    short[2][4] r90() {
        return [[cast(short)(x+half_width), cast(short)(y+half_height)],
                [cast(short)(x+half_width), cast(short)(y-half_height)],
                [cast(short)(x-half_width), cast(short)(y-half_height)],
                [cast(short)(x-half_width), cast(short)(y+half_height)]];
    }

    @safe nothrow const pure
    short[2][4] r180() {
        return [[cast(short)(x+half_width), cast(short)(y-half_height)],
                [cast(short)(x-half_width), cast(short)(y-half_height)],
                [cast(short)(x-half_width), cast(short)(y+half_height)],
                [cast(short)(x+half_width), cast(short)(y+half_height)]];
    }

    @safe nothrow const pure
    short[2][4] r270() {
        return [[cast(short)(x-half_width), cast(short)(y-half_height)],
                [cast(short)(x-half_width), cast(short)(y+half_height)],
                [cast(short)(x+half_width), cast(short)(y+half_height)],
                [cast(short)(x+half_width), cast(short)(y-half_height)]];
    }

    @safe nothrow const pure
    short[2][4] r0(short left, short right, short top, short bottom) {
        return [[cast(short)(x-left), cast(short)(y+bottom)],
                [cast(short)(x+right), cast(short)(y+bottom)],
                [cast(short)(x+right), cast(short)(y-top)],
                [cast(short)(x-left), cast(short)(y-top)]];
    }

    @safe nothrow const pure
    short[2][4] r90(short left, short right, short top, short bottom) {
        return [[cast(short)(x+right), cast(short)(y+bottom)],
                [cast(short)(x+right), cast(short)(y-top)],
                [cast(short)(x-left), cast(short)(y-top)],
                [cast(short)(x-left), cast(short)(y+bottom)]];
    }

    @safe nothrow const pure
    short[2][4] r180(short left, short right, short top, short bottom) {
        return [[cast(short)(x+right), cast(short)(y-top)],
                [cast(short)(x-left), cast(short)(y-top)],
                [cast(short)(x-left), cast(short)(y+bottom)],
                [cast(short)(x+right), cast(short)(y+bottom)]];
    }

    @safe nothrow const pure
    short[2][4] r270(short left, short right, short top, short bottom) {
        return [[cast(short)(x-left), cast(short)(y-top)],
                [cast(short)(x-left), cast(short)(y+bottom)],
                [cast(short)(x+right), cast(short)(y+bottom)],
                [cast(short)(x+right), cast(short)(y-top)]];
    }
}

struct CubeSideData {
    float[3][4] positions;
    Normal normal;
}

struct ProjectionTextureCoordinates {
    short x;
    short y;

    short x2; // texture for normal +y
    short y2;

    short x3; // texture for normal -y
    short y3;

    short width;
    short height;

    @safe nothrow const pure
    short[2][4] project_on_cbsd(CubeSideData cbsd) {
        // an normale erkennbar welche koordinate fix ist
        // die koodinaten zu UVs umformen? cast(short)(foo*2)?

        short x = this.x;
        short y = this.y;

        size_t index_1;
        size_t index_2;

        // n is the counterpart to s, it allows to midify the x coordinates
        float n = 1.0f;
        // used to flip the signs if normal doesn't point toward +y
        // since in OpenGL +y goes up but in the texture atlas +y goes down
        float s = 1.0f;

        if(cbsd.normal == Normal.X_POSITIVE || cbsd.normal == Normal.X_NEGATIVE) {
            // x
            index_1 = 2;
            index_2 = 1;
            s = -1.0f; // flip here

            //n = sign(cbsd.normal[0]);
//             n = sign(-cbsd.normal[0]);
            n = cbsd.normal == Normal.X_POSITIVE ? -1 : 1;
        } else if(cbsd.normal == Normal.Y_POSITIVE || cbsd.normal == Normal.Y_NEGATIVE) {
            // y
            index_1 = 0;
            index_2 = 2;
//             n = s = sign(cbsd.normal[1]);
            n = s = cbsd.normal == Normal.Y_POSITIVE ? 1 : 0;

            if(n > 0) { // y+
                x = x2;
                y = y2;
            } else if(n < 0) { // y-
                x = x3;
                y = y3;
            }
        } else if(cbsd.normal == Normal.Z_POSITIVE || cbsd.normal == Normal.Z_NEGATIVE) {
            // z
            index_1 = 0;
            index_2 = 1;
            s = -1.0f; // flip here
//             n = sign(cbsd.normal[2]);
            n = cbsd.normal == Normal.Z_POSITIVE ? 1 : -1;
        } else {
            assert(false, "normal not supported");
        }

        short[2][4] ret;

        foreach(i, ref vertex; cbsd.positions) {
            ret[i][0] = cast(short)(x + vertex[index_1]*width*n);
            ret[i][1] = cast(short)(y + vertex[index_2]*height*s);
        }

        return ret;
    }
}

public import brala.gfx._texlist : ORDER;

enum BLOCK_IDS = 200;

struct AtlasImage {
    Image image;
    alias image this;

    Image[] images;
    int frametime;

    size_t position;
    int frame;

    Image get_next() {
        return image;
    }
}


final class MinecraftAtlas : Atlas {
    BraLaEngine engine;
    Sampler sampler;

    vec2 dimensions;

    TextureCoordinate[ORDER.length] texture_coordinates;

    // Order matches Side.* brala.dine.builder.constants
    Vertex[][BLOCK_IDS][6] vertices;

    this(BraLaEngine engine) {
        super(256, 256);

        this.dimensions = vec2(atlas.width, atlas.height);
        this.engine = engine;

        string path = engine.config.get!Path("game.texture.pack");
        if(path == "default" || path.length == 0) {
            path = minecraft_jar;
        }
        enforceEx!AtlasException(file.exists(path), "Unable to load textures from: " ~ path);

        sampler = new Sampler();
        sampler.set_parameter(GL_TEXTURE_WRAP_S, GL_REPEAT);
        sampler.set_parameter(GL_TEXTURE_WRAP_T, GL_REPEAT);
        sampler.set_parameter(GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        if(engine.config.get!bool("game.texture.mipmap", true)) {
            sampler.set_parameter(GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_LINEAR);
        } else {
            sampler.set_parameter(GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        }

        string ani = engine.config.get!string("game.texture.anisotropic", "");
        if(ani.length && ani != "0") {
            float level = 0.0f;
            if(ani == "max") {
                checkgl!glGetFloatv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, &level);
            } else {
                level = engine.config.get!int("game.texture.anisotropic");
            }

            sampler.set_parameter(GL_TEXTURE_MAX_ANISOTROPY_EXT, level);
        }

        load(path);
    }

    override
    void resize(int width, int height) {
        logger.log!Info("Resizing atlas from %dx%d to %dx%d", atlas.width, atlas.height, width, height);
        super.resize(width, height);
        dimensions = vec2(width, height);
    }

    void load(string path) {
        logger.log!Info("Opening texturepack: %s", path);
        ZipArchive za = new ZipArchive(path);

        string[] files = za.list_dir("textures/blocks", false);
        if(files.length == 0) {
            files = za.list_dir("assets/minecraft/textures/blocks", false);
        }
        enforceEx!AtlasException(files.length > 0, "No textures found");

        logger.log!Info("Processing ~%d textures", files.length);
        foreach(f; files) {
            string name = f.baseName();

            if(f.extension() == ".png") {
                auto am = za.directory[f];
                Image image = Image.from_memory(za.expand(am));

                if(image.comp != RGBA) {
                    image = image.convert(RGBA);
                }
                // Prf_Jakob o/
                image.fill_empty_with_average();

                AtlasImage atlas_image;
                atlas_image.image = image;

                string meta = f ~ ".mcmeta";
                if(files.canFind(meta)) {
                    am = za.directory[meta];
                    auto data = cast(char[])za.expand(am);

                    auto json = parseJSON(data);
                    auto j_animation = json["animation"].object;
                    if(j_animation is null) {
                        continue;
                    }

                    atlas_image.frametime = "frametime" in j_animation ? cast(int)j_animation["frametime"].integer : 1;

                    int min_ = min(image.width, image.height);
                    int max_ = max(image.width, image.height);

                    if(auto j_frames = "frames" in j_animation) {
                        enforceEx!AtlasException(j_frames.array !is null, "Malformed mcmeta: " ~ meta);

                        foreach(j_frame; j_frames.array) {
                            enforceEx!AtlasException(j_frame.type == JSON_TYPE.INTEGER, "Malformed mcmeta: " ~ meta);

                            int index = cast(int)j_frame.integer;
                            enforceEx!AtlasException(index >= 0, "Negative animation frame: " ~ meta);
                            enforceEx!AtlasException((index+1)*min_ <= max_,
                                    "Animation frame %s does not exist in %s".format(index, f));

                            Image anim_image;
                            if(image.width > image.height) {
                                anim_image = image.crop(index*image.height, 0, (index+1)*image.height, image.height);
                            } else {
                                anim_image = image.crop(0, index*image.width, image.width, (index+1)*image.width);
                            }

                            assert(anim_image.width == min(image.width, image.height));
                            assert(anim_image.width == anim_image.height);

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

        logger.log!Info("All files processed");

        update_everything();

        engine.set_texture("terrain", atlas.to_texture(), sampler);
    }

    protected void update_everything() {
        logger.log!Info("Updating texture coordinates...");

        foreach(name; map.keys()) {
            int index = cast(int)(ORDER.countUntil(name));
            if(index < 0) {
                logger.log!Info("Found unexpected texture %s", name);
                continue;
            }

            texture_coordinates[index] = TextureCoordinate(map[name].area);
        }

        logger.log!Info("Done");
        logger.log!Info("Updating Vertices");

        foreach(side; 0..6) {
            foreach(index, tex_info; TEXTURE_INFORMATION[side]) {
                if(tex_info.name.length == 0) continue;

                auto tex_index = ORDER.countUntil(tex_info.name);
                enforceEx!AtlasException(tex_index >= 0, `"%s" not found`.format(tex_info.name));

                short[2][4] tex = texture_coordinates[tex_index].def;
                short[2][4] tex_overlay;
                if(tex_info.name == tex_info.overlay || tex_info.overlay.length == 0) {
                    tex_overlay = tex;
                } else {
                    tex_overlay = texture_coordinates[ORDER.countUntil(tex_info.overlay)].def;
                }

                vertices[side][index] = simple_block(cast(Side)side, tex, tex_overlay);
            }
        }

        logger.log!Info("Done");
    }

    short[2][4] get(string s, int rotation = 0)() if(rotation == 0 || rotation == 90 ||
                                                     rotation == 180 || rotation == 270) {
        enum index = ORDER.countUntil(s);
        static assert(index >= 0, "No valid texture name");

        static if(rotation == 0) {
            return texture_coordinates[index].def;
        } else static if(rotation == 90) {
            return texture_coordinates[index].r90();
        } else static if(rotation == 180) {
            return texture_coordinates[index].r180();
        } else static if(rotation == 270) {
            return texture_coordinates[index].r270();
        }
    }

    short[2][4] get(string s, int rotation, short left, short right, short top, short bottom)()
        if(rotation == 0 || rotation == 90 || rotation == 180 || rotation == 270) {

        enum index = ORDER.countUntil(s);
        static assert(index >= 0, "Unknown texture: " ~ s);

        enum leftc = left/8.0;
        enum rightc = right/8.0;
        enum topc = top/8.0;
        enum bottomc = bottom/8.0;

        auto tex = texture_coordinates[index];
        static if(rotation == 0) {
            return tex.r0(cast(short)(tex.half_width*leftc), cast(short)(tex.half_width*rightc),
                          cast(short)(tex.half_height*topc), cast(short)(tex.half_height*bottomc));
        } else static if(rotation == 90) {
            return tex.r90(cast(short)(tex.half_width*leftc), cast(short)(tex.half_width*rightc),
                           cast(short)(tex.half_height*topc), cast(short)(tex.half_height*bottomc));
        } else static if(rotation == 180) {
            return tex.r180(cast(short)(tex.half_width*leftc), cast(short)(tex.half_width*rightc),
                            cast(short)(tex.half_height*topc), cast(short)(tex.half_height*bottomc));
        } else static if(rotation == 270) {
            return tex.r270(cast(short)(tex.half_width*leftc), cast(short)(tex.half_width*rightc),
                            cast(short)(tex.half_height*topc), cast(short)(tex.half_height*bottomc));
        }
    }

    TextureCoordinate get_tex(string s)() {
        enum index = ORDER.countUntil(s);
        static assert(index >= 0, "Unknown texture: " ~ s);

        return texture_coordinates[index];
    }

    ProjectionTextureCoordinates get_proj(string s1, string s2="", string s3="")() {
        enum index1 = ORDER.countUntil(s1);
        static assert(index1 >= 0, "Unknown texture: " ~ s1);

        TextureCoordinate tex1 = texture_coordinates[index1];

        static if(s2.length == 0) {
            TextureCoordinate tex2 = tex1;
        } else {
            enum index2 = ORDER.countUntil(s2);
            static assert(index2 >= 0, "Unknown texture: " ~ s2);
            TextureCoordinate tex2 = texture_coordinates[index2];
        }

        static if(s3.length == 0) {
            TextureCoordinate tex3 = tex1;
        } else {
            enum index3 = ORDER.countUntil(s3);
            static assert(index3 >= 0, "Unknown texture: " ~ s3);
            TextureCoordinate tex3 = texture_coordinates[index3];
        }

        return ProjectionTextureCoordinates(tex1.x, tex1.y, tex2.x, tex2.y, tex3.x, tex3.y,
                            cast(short)(tex1.half_width*2), cast(short)(tex1.half_height*2));
    }

    Vertex[] get_vertices(Side side)(size_t id) {
        static assert(side != Side.ALL, "Returning all sides at once is not supported for get_vertices");

        return vertices[side][id];
    }
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
