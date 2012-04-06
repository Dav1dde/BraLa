module brala.resmgr;

private {
    import std.parallelism : task, Task, taskPool, TaskPool;
    import std.path : extension;
    import std.file : exists;
    import core.thread : Thread;
    import core.time : dur;
    import std.typecons : Tuple;
    import std.string : toLower;
    
    import glamour.shader : Shader;
    import glamour.texture : Texture2D;
    
    import brala.utils.image : Image;
    import brala.exception : ResmgrError;
    
    debug import std.stdio : writefln;
}

version(none) {
    private __gshared Object _texlock;
    static this() {
        _texlock = new Object();
    }
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
    static if(is(T : Image) || is(T : Shader) || is(T : Texture2D)) {
        enum is_loadable = true;
    } else {
        enum is_loadable = false;
    }
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
    protected Object _lock;
    protected TaskPool task_pool;
    protected CBS[string] open_tasks;
    
    __gshared Shader[string] shaders;
    __gshared Texture2D[string] textures;
    __gshared Image[string] images;
        
    this(bool new_taskpool = true) {
        _lock = new Object();
        
        if(new_taskpool) {
            task_pool = new TaskPool();
        } else {
            task_pool = taskPool;
        }
    } 
  
    protected auto _add(alias taskfun, T)(string id, string filename, void delegate(T) cb = null) {
        debug writefln("Requesting resource \"" ~ filename ~ "\" as \"" ~ id ~ "\", type: \"" ~ T.stringof ~ "\".");
        
        if(!exists(filename)) {
            throw new ResmgrError("Can not load file \"" ~ filename ~ "\", it does not exist!");
        }
        
        string idt = id ~ T.stringof; 
        if((is(T : Image) && id in images) ||
           (is(T : Shader) && id in shaders) ||
           (is(T : Texture2D) && id in textures) ||
           idt in open_tasks) {
            throw new ResmgrError("ID: \"" ~ id ~ "\" is already used.");
        }
        
        synchronized (_lock) open_tasks[idt] = CBS.from_cb(cb);
        // use add_many_wait for multithreaded texture loading, shaders to come.
        static if(true) { // FIXME: is(T : Texture2D) || is(T : Shader)
            taskfun(this, id, filename); 
            return null;
        } else {
            auto t = task!taskfun(this, id, filename);
            task_pool.put(t);
            return t;
        }
    }
    
    alias _add!(load_image, Image) add_image;
    alias _add!(load_shader, Shader) add_shader;
    alias _add!(load_texture, Texture2D) add_texture;
    
    auto add(T)(string id, string filename, void delegate(T) cb = null) if(is_loadable!T) {
        static if(is(T : Image)) {
            return add_image(id, filename, cb);
        } else static if(is(T : Shader)) {
            return add_shader(id, filename, cb);
        } else {
            return add_texture(id, filename, cb);
        }
    }
    
    void add_many(const Resource[] resources) {
        foreach(res; resources) {
            int type = res.type == AUTO_TYPE ? guess_type(res.filename) : res.type;
            switch(type) {
                case IMAGE_TYPE: add_image(res.id, res.filename); break;
                case SHADER_TYPE: add_shader(res.id, res.filename); break;
                case TEXTURE2D_TYPE: add_texture(res.id, res.filename); break;
                default: throw new ResmgrError("Unknown resource-type.");
            }
        }
    }
    
    // Use this when you would call, after feeding the resmgr, anyways .wait()
    // it will load the texture-images seperatly and then upload them to opengl
    // as texture.
    void add_many_wait(const Resource[] resources) {
        alias Tuple!(Task!(load_image, typeof(this), string, string)*, "task", Resource, "res") TTT;
        TTT[] textasks;
        
        foreach(res; resources) {
            int type = res.type == AUTO_TYPE ? guess_type(res.filename) : res.type;
            
            switch(type) {
                case IMAGE_TYPE: add_image(res.id, res.filename); break;
                case SHADER_TYPE: add_shader(res.id, res.filename); break;
                case TEXTURE2D_TYPE: textasks ~= TTT(add_image(res.id, res.filename), res); break;
                default: throw new ResmgrError("Unknown resource-type.");
            }
        }           
    
        foreach(textask; textasks) {
            Image img = textask.task.workForce();

            // FIXME
            auto tex = new Texture2D();
            tex.set_data(img.data, img.dest_format, img.width, img.height, img.dest_format, img.dest_type);

            // we are still in the mainthread, so let's upload this sh*t to the gpu
            // but we still need to synchronize!
            synchronized(_lock) {
                images.remove(textask.res.id);
                textures[textask.res.id] = tex;
            }
        }
        
        wait();
    }
    
    void wait() {
        while(open_tasks.length > 0) {
            Thread.sleep(dur!("msecs")(100));
        }
    }
    
    T get(T)(string id) if(is_loadable!T) {
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
            default: throw new ResmgrError("Unable to guess resource-type.");
        }
    }
    
    protected void done_loading(T)(T res, string id) if(is_loadable!T){
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