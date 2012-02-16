module brala.resmgr;

private {
    import std.parallelism : task, taskPool, TaskPool;
    import std.path : baseName, stripExtension, extension;
    import core.thread : Thread;
    import core.time : dur;
    import std.algorithm : remove, countUntil;
    
    import glamour.shader : Shader;
    import glamour.texture : Texture2D;
    
    import brala.types : Image;
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
    private __gshared string[] open_tasks;
    
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
        open_tasks ~= id;
        
        return t;      
    }
    
    auto add_shader(string id, string filename, void delegate() cb = null) {
        auto t = task!load_shader(this, id, filename);
        task_pool.put(t);
        open_tasks ~= id;
        
        return t;
    }
    
    auto add_texture(string id, string filename, void delegate() cb = null) {
        auto t = task!load_texture(this, id, filename);
        task_pool.put(t); 
        open_tasks ~= id;
        
        return t; 
    }
    
    void wait() {
        while(open_tasks.length > 0) {
            Thread.sleep(dur!("msecs")(100));
        }
    }
    
    private void done_loading(Image res, string id) {
        images[id] = res;
        sizediff_t cu = open_tasks.countUntil(id);
        if(cu >= 0) {
            open_tasks.remove(cu);
        }
    }
    
    private void done_loading(Shader res, string id) {
        shaders[id] = res;
        sizediff_t cu = open_tasks.countUntil(id);
        if(cu >= 0) {
            open_tasks.remove(cu);
        }
    }
    
    private void done_loading(Texture2D res, string id) {
        textures[id] = res;
        sizediff_t cu = open_tasks.countUntil(id);
        if(cu >= 0) {
            open_tasks.remove(cu);
        }
    }
}