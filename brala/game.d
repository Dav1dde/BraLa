module brala.game;

private {
    import glamour.gl;
    
    import brala.engine : BraLaEngine;
    import brala.event : BralaEventHandler;
    
    debug import std.stdio;
}


class BraLaGame {
    BraLaEngine engine;
    BralaEventHandler input;
    
    this(BraLaEngine engine, void* window) {
        this.engine = engine;
        input = new BralaEventHandler(window);
    }
    
    void start() {
        engine.mainloop(&poll);
    }
    
    
    bool poll(uint delta_t) {
        display();
        
        return false;
        
    }
    
    void display() {
        glClearColor(0.0f, 1.0f, 0.0f, 1.0f);
        glClearDepth(1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    }
}