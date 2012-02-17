module brala.resmgr;

private {
    import std.parallelism : task, taskPool, TaskPool;
    import std.path : baseName, stripExtension, extension;
    import core.thread : Thread;
    import core.time : dur;
    import std.algorithm : SwapStrategy, remove, countUntil;
    
    import glamour.shader : Shader;
    import glamour.texture : Texture2D;
    
    import brala.types : Image;
}

private RessourceManager _resmgr;
private bool _initialized = false;
@property RessourceManager resmgr() {
    if(!_initialized) {
        _resmgr = new RessourceManager();
    }
    
    return _resmgr;
}

void load_image(RessourceManager rsmg, string id, string filename) {
    rsmg.done_loading!Image(Image.from_file(filename), id);
}

void load_shader(RessourceManager rsmg, string id, string filename) {
    rsmg.done_loading(Shader(filename), id);
}

void load_texture(RessourceManager rsmg, string id, string filename) {
    rsmg.done_loading(Texture2D.from_image(filename), id);
}

private struct CBS {
    union {
        void delegate(Image) imgcb;
        void delegate(Shader) sdrcb;
        void delegate(Texture2D) texcb;
    }
    ushort t;
    
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
            ret.imgcb = cb; ret.t = 0;
        } else static if(is(T : void delegate(Shader))) {
            ret.sdrcb = cb; ret.t = 1;
        } else static if(is(T : void delegate(Texture2D))) {
            ret.texcb = cb; ret.t = 2;
        } else {
            static assert(false, "Unknown callback-type.");
        }
        
        return ret;
    }
}

class RessourceManager {
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
  
    auto add_image(string id, string filename, void delegate(Image) cb = null) {
        auto t = task!load_image(this, id, filename);
        task_pool.put(t);
        synchronized (_lock) open_tasks[id] = CBS.from_cb(cb);
        
        return t;      
    }
    
    auto add_shader(string id, string filename, void delegate(Shader) cb = null) {
        auto t = task!load_shader(this, id, filename);
        task_pool.put(t);
        synchronized (_lock) open_tasks[id] = CBS.from_cb(cb);
        
        return t;
    }
    
    auto add_texture(string id, string filename, void delegate(Texture2D) cb = null) {
        auto t = task!load_texture(this, id, filename);
        task_pool.put(t); 
        synchronized (_lock) open_tasks[id] = CBS.from_cb(cb);
        
        return t; 
    }
    
    void wait() {
        while(open_tasks.length > 0) {
            Thread.sleep(dur!("msecs")(100));
        }
    }
    
    private void done_loading(T)(T res, string id) if(is(T : Image) ||
                                                      is(T : Shader) ||
                                                      is(T : Texture2D)){
        synchronized (_lock) { 
            static if(is(T : Image)) images[id] = res;
            else static if(is(T : Shader)) shaders[id] = res;
            else static if(is(T : Texture2D)) textures[id] = res;
        
            if(id in open_tasks) {
                open_tasks[id](res);
                
                open_tasks.remove(id);
            }
        }
    }
}