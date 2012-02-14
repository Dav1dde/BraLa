module brala.game;

private {
    import derelict.glfw3.glfw3;
    import glamour.gl;
    
    import brala.engine : BraLaEngine;
    import brala.input : BralaInputHandler;
    
    import std.stdio;
}


class BraLaGame {
    BraLaEngine engine;
    BralaInputHandler input;
    
    this(BraLaEngine engine, void* window) {
        this.engine = engine;
        input = new BralaInputHandler(window);
    }
    
    void start() {
        engine.mainloop(&poll);
    }
    
    
    bool poll(float delta_t) {
        display();
        
        return false;
        
    }
    
    void display() {
        glClearColor(0.0f, 1.0f, 0.0f, 1.0f);
        glClearDepth(1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    }
}