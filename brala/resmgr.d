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
    rsmg.done_loading(Image.from_file(filename), id);
}

void load_shader(RessourceManager rsmg, string id, string filename) {
    rsmg.done_loading(Shader(filename), id);
}

void load_texture(RessourceManager rsmg, string id, string filename) {
    rsmg.done_loading(Texture2D.from_image(filename), id);
}

class RessourceManager {
    private TaskPool task_pool;
    private __gshared void delegate()[string] open_tasks;
    
    Shader[string] shaders;
    Texture2D[string] textures;
    Image[string] images;
        
    this(bool new_taskpool = true) {
        if(new_taskpool) {
            task_pool = new TaskPool();
        } else {
            task_pool = taskPool;
        }
    }
          
    auto add_image(string id, string filename, void delegate() cb = null) {
        auto t = task!load_image(this, id, filename);
        task_pool.put(t);
        open_tasks[id] = cb;
        
        return t;      
    }
    
    auto add_shader(string id, string filename, void delegate() cb = null) {
        auto t = task!load_shader(this, id, filename);
        task_pool.put(t);
        open_tasks[id] = cb;
        
        return t;
    }
    
    auto add_texture(string id, string filename, void delegate() cb = null) {
        auto t = task!load_texture(this, id, filename);
        task_pool.put(t); 
        open_tasks[id] = cb;
        
        return t; 
    }
    
    void wait() {
        while(open_tasks.length > 0) {
            Thread.sleep(dur!("msecs")(100));
        }
    }
    
    private void done_loading(T)(T res, string id) if(is(T : Image) || is(T : Shader) || is(T : Texture2D)) {
        static if(is(T : Image)) images[id] = res;
        else static if(is(T : Shader)) shaders[id] = res;
        else static if(is(T : Texture2D)) textures[id] = res;
        
        if(id in open_tasks) {
            auto cb = open_tasks[id]; // calls the callback passed to add_*
            if(cb !is null) {
                cb();
            }
            
            open_tasks.remove(id);
        }
    }
}