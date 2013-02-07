module brala.resmgr;

private {
    import std.path : extension, baseName, stripExtension;
    import std.file : exists;
    import std.typecons : Tuple;
    import std.string : toLower;
    import std.format : format;
    import std.traits : isIterable;
    import std.range : ElementType;
    import std.algorithm : map;
    import core.thread : thread_isMainThread;
    
    import glamour.shader : Shader;
    import glamour.texture : ITexture, Texture2D;

    import brala.log : logger = resmgr_logger;
    import brala.utils.log;
    import brala.utils.image : Image;
    import brala.exception : ResmgrError;    
}

Image load_image(ResourceManager rsmg, string id, string filename) {
    Image img = Image.from_file(filename);
    rsmg.done_loading!Image(img, id);
    return img;
}

Shader load_shader(ResourceManager rsmg, string id, string filename) {
    Shader sdr = new Shader(filename);
    rsmg.done_loading(sdr, id);
    return sdr;
}

Texture2D load_texture(ResourceManager rsmg, string id, string filename) {
    Texture2D tex = Texture2D.from_image(filename);
    rsmg.done_loading(tex, id);
    return tex;
}

private template is_loadable(T) {
    static if(is(T : Image) || is(T : Shader) || is(T : ITexture)) {
        enum is_loadable = true;
    } else {
        enum is_loadable = false;
    }
}

private struct CBS {
    union {
        void delegate(Image) imgcb;
        void delegate(Shader) sdrcb;
        void delegate(ITexture) texcb;
    }
    
    void opCall(T)(T arg) {
        static if(is(T : Image)) {
            auto cb = imgcb;
        } else static if(is(T : Shader)) {
            auto cb = sdrcb;
        } else static if(is(T : ITexture)) {
            auto cb = texcb;
        } else {
            static assert(false, "Unknown argument type, no matching callback");
        }
        
        if(cb !is null) {
            cb(arg);
        }
    }
    
    static CBS from_cb(T)(T cb) {
        CBS ret;
        
        static if(is(T : void delegate(Image))) {
            ret.imgcb = cb;
        } else static if(is(T : void delegate(Shader))) {
            ret.sdrcb = cb;
        } else static if(is(T : void delegate(ITexture))) {
            ret.texcb = cb;
        } else {
            static assert(false, "Unknown callback-type.");
        }
        
        return ret;
    }
}

enum { AUTO_TYPE = -1, IMAGE_TYPE, SHADER_TYPE, TEXTURE_TYPE }

alias Tuple!(string, "id", string, "filename", int, "type") Resource;

class ResourceManager {
    protected CBS[string] open_tasks;    
    protected Shader[string] shaders;
    protected ITexture[string] textures;
    protected Image[string] images;
        
    this() {}

    void shutdown()
        in { assert(thread_isMainThread(), "ResourceManager.shutdown not called from main thread"); }
        body {
            logger.log!Info("Removing Shaders from ResourceManager");
            foreach(shader; shaders.values) {
                shader.remove();
            }
            shaders = shaders.init;

            logger.log!Info("Removing Textures from ResourceManager");
            foreach(texture; textures.values) {
                texture.remove();
            }
            textures = textures.init;

            logger.log!Info("Removing Images from ResourceManager");
            images = images.init;
        }
  
    protected auto _add(alias taskfun, T)(string id, string filename, void delegate(T) cb = null) {
        logger.log!Info("Requesting resource \"" ~ filename ~ "\" as \"" ~ id ~ "\", type: \"" ~ T.stringof ~ "\".");
        
        if(!filename.exists()) {
            throw new ResmgrError("Can not load file \"" ~ filename ~ "\", it does not exist!");
        }
        
        string idt = id ~ T.stringof; 
        if((is(T : Image) && id in images) ||
           (is(T : Shader) && id in shaders) ||
           (is(T : ITexture) && id in textures) ||
           idt in open_tasks) {
            throw new ResmgrError("ID: \"" ~ id ~ "\" is already used.");
        }
        
        open_tasks[idt] = CBS.from_cb(cb);

        taskfun(this, id, filename);
    }
    
    alias _add!(load_image, Image) add_image;
    alias _add!(load_shader, Shader) add_shader;
    alias _add!(load_texture, ITexture) add_texture;
    
    auto add(T)(string id, string filename, void delegate(T) cb = null) if(is_loadable!T) {
        static if(is(T : Image)) {
            return add_image(id, filename, cb);
        } else static if(is(T : Shader)) {
            return add_shader(id, filename, cb);
        } else {
            return add_texture(id, filename, cb);
        }
    }

    void add(T)(string id, T t) if(is_loadable!T) {
        string idt = id ~ T.stringof;
        
        if((is(T : Image) && id in images) ||
           (is(T : Shader) && id in shaders) ||
           (is(T : ITexture) && id in textures) ||
           idt in open_tasks) {
            throw new ResmgrError("ID: \"" ~ id ~ "\" is already used.");
        }

        static if(is(T : Image)) {
            images[id] = t;
        } else static if(is(T : Shader)) {
            shaders[id] = t;
        } else static if(is(T : ITexture)) {
            textures[id] = t;
        }
    }
    
    void add_many(T)(T resources) if(isIterable!(T) && is(ElementType!T : Resource)) {
        foreach(res; resources) {
            int type = res.type == AUTO_TYPE ? guess_type(res.filename) : res.type;
            switch(type) {
                case IMAGE_TYPE: add_image(res.id, res.filename); break;
                case SHADER_TYPE: add_shader(res.id, res.filename); break;
                case TEXTURE_TYPE: add_texture(res.id, res.filename); break;
                default: throw new ResmgrError("Unknown resource-type.");
            }
        }
    }

    void add_many(T)(T paths) if(isIterable!(T) && is(ElementType!T : string)) {
        add_many(paths.map!(ResourceManager.guess_resource));
    }
    
    void remove(T)(string id) if(is_loadable!T) {
        static if(is(T : Image)) {
            images.remove(id);
        } else static if(is(T : Shader)) {
            shaders.remove(id);
        } else static if(is(T : ITexture)) {
            textures.remove(id);
        }
    }
    
    T get(T)(string id) if(is_loadable!T) {
        static if(is(T : Image)) {
            if(Image* img = id in images) return *img;
        } else static if(is(T : Shader)) {
            if(Shader* shader = id in shaders) return *shader;
        } else static if(is(T : ITexture)) {
            if(ITexture* tex = id in textures) return *tex;
        }

        throw new ResmgrError("No %s with id \"%s\" available.".format(T.stringof, id));
    }
    
    static int guess_type(string filename) {
        string ext = extension(filename).toLower();
        
        switch(ext) {
            case ".png": return IMAGE_TYPE;
            case ".jpg": return IMAGE_TYPE;
            case ".jpeg": return IMAGE_TYPE;
            case ".tga": return IMAGE_TYPE;
            case ".shader": return SHADER_TYPE;
            case ".glsl": return SHADER_TYPE;
            case ".texture": return TEXTURE_TYPE;
            case ".texture2d": return TEXTURE_TYPE;
            default: throw new ResmgrError(`Unable to guess resource-type for "%s"`.format(filename));
        }
    }

    static Resource guess_resource(string path) {
        return Resource(path.baseName().stripExtension(), path, guess_type(path));
    }
    
    protected void done_loading(T)(T res, string id) if(is_loadable!T){
        logger.log!Info("Loaded resource \"" ~ id ~ "\" with type: \"" ~ T.stringof ~ "\".");
        
        static if(is(T : Image)) images[id] = res;
        else static if(is(T : Shader)) shaders[id] = res;
        else static if(is(T : ITexture)) textures[id] = res;

        string idt = id ~ T.stringof;
        if(CBS* t = idt in open_tasks) {
            auto cb = *t;
            cb(res);

            open_tasks.remove(idt);
        }
    }
}