module brala.resmgr;

private {
    import std.parallelism : task, taskPool, TaskPool;
    import std.path : extension;
    import std.file : exists;
    import core.thread : Thread;
    import core.time : dur;
    import std.algorithm : SwapStrategy, remove, countUntil;
    import std.typecons : Tuple;
    import std.string : toLower;
    
    import glamour.shader : Shader;
    import glamour.texture : Texture2D;
    
    import brala.types : Image;
    import brala.exception : ResmgrException;
    
    debug import std.stdio : writefln;
}


@property ResourceManager resmgr() {
    static bool initialized = false;
    __gshared static ResourceManager _resmgr;
    
    if(!initialized) {
        synchronized {
            if(!_resmgr) {
                _resmgr = new ResourceManager();
            }
        }
        
        initialized = true;
    }
    
    return _resmgr;
}

void load_image(ResourceManager rsmg, string id, string filename) {
    rsmg.done_loading!Image(Image.from_file(filename), id);
}

void load_shader(ResourceManager rsmg, string id, string filename) {
    rsmg.done_loading(Shader(filename), id);
}

void load_texture(ResourceManager rsmg, string id, string filename) {
    rsmg.done_loading(Texture2D.from_image(filename), id);
}

private struct CBS {
    union {
        void delegate(Image) imgcb;
        void delegate(Shader) sdrcb;
        void delegate(Texture2D) texcb;
    }
    
    void opCall(T)(T arg) {
        static if(is(T : Image)) {
            auto cb = imgcb;
        } else static if(is(T : Shader)) {
            auto cb = sdrcb;
        } else static if(is(T : Texture2D)) {
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
        } else static if(is(T : void delegate(Texture2D))) {
            ret.texcb = cb;
        } else {
            static assert(false, "Unknown callback-type.");
        }
        
        return ret;
    }
}

enum { AUTO_TYPE = -1, IMAGE_TYPE, SHADER_TYPE, TEXTURE2D_TYPE }

alias Tuple!(string, "id", string, "filename", int, "type") Resource;

class ResourceManager {
    private Object _lock;
    private TaskPool task_pool;
    private CBS[string] open_tasks;
    
    Shader[string] shaders;
    Texture2D[string] textures;
    Image[string] images;
        
    this(bool new_taskpool = true) {
        _lock = new Object();
        
        if(new_taskpool) {
            task_pool = new TaskPool();
        } else {
            task_pool = taskPool;
        }
    } 
  
    private auto _add(alias taskfun, T)(string id, string filename, void delegate(T) cb = null) {
        debug writefln("Requesting resource \"" ~ filename ~ "\" as \"" ~ id ~ "\", type: \"" ~ T.stringof ~ "\".");
        
        if(!exists(filename)) {
            throw new ResmgrException("Can not load file \"" ~ filename ~ "\", it does not exist!");
        }
        
        string idt = id ~ T.stringof; 
        if((is(T : Image) && id in images) ||
           (is(T : Shader) && id in shaders) ||
           (is(T : Texture2D) && id in textures) ||
           idt in open_tasks) {
            throw new ResmgrException("ID: \"" ~ id ~ "\" is already used.");
        }
        
        static if(is(T : Image) || is(T : Texture2D)) {
            taskfun(this, id, filename); // I am sorry dave, devil isn't thread-safe
            return null;
        } else {
            auto t = task!taskfun(this, id, filename);
            task_pool.put(t);
            synchronized (_lock) open_tasks[idt] = CBS.from_cb(cb);
            return t;
        }
    }
    
    alias _add!(load_image, Image) add_image;
    alias _add!(load_shader, Shader) add_shader;
    alias _add!(load_texture, Texture2D) add_texture;
    
    void add_many(const Resource[] resources) {
        foreach(res; resources) {
            int type = res.type == AUTO_TYPE ? guess_type(res.filename) : res.type;
            switch(type) {
                case IMAGE_TYPE: add_image(res.id, res.filename); break;
                case SHADER_TYPE: add_shader(res.id, res.filename); break;
                case TEXTURE2D_TYPE: add_texture(res.id, res.filename); break;
                default: throw new ResmgrException("unknown resource-type");
            }
        }
    }
    
    void add_many(const Resource[] resources...) {
        add_many(resources);
    }
    
    void wait() {
        while(open_tasks.length > 0) {
            Thread.sleep(dur!("msecs")(100));
        }
    }
    
    T get(T)(string id) if(is(T : Image) || is(T : Shader) || is(T : Texture2D)) {
        static if(is(T : Image)) {
            return images[id];
        } else static if(is(T : Shader)) {
            return shaders[id];
        } else static if(is(T : Texture2D)) {
            return textures[id];
        }
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
            case ".texture": return TEXTURE2D_TYPE;
            case ".texture2d": return TEXTURE2D_TYPE;
            default: throw new ResmgrException("unable to guess resource-type");
        }
    }
    
    private void done_loading(T)(T res, string id) if(is(T : Image) ||
                                                      is(T : Shader) ||
                                                      is(T : Texture2D)){
        debug writefln("Loaded resource \"" ~ id ~ "\" with type: \"" ~ T.stringof ~ "\".");
                                                          
        synchronized (_lock) { 
            static if(is(T : Image)) images[id] = res;
            else static if(is(T : Shader)) shaders[id] = res;
            else static if(is(T : Texture2D)) textures[id] = res;
            
            string idt = id ~ T.stringof;
            if(CBS* t = idt in open_tasks) {
                (*t)(res);
                
                open_tasks.remove(idt);
            }
        }
    }
}