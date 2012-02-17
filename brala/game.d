module brala.game;

private {
    import glamour.gl;
    import derelict.glfw3.glfw3;
    
    import brala.engine : BraLaEngine;
    import brala.event : BaseGLFWEventHandler;
    
    debug import std.stdio;
}


class BraLaGame : BaseGLFWEventHandler {
    BraLaEngine engine;
    
    bool quit = false;
    
    this(BraLaEngine engine, void* window) {
        super(window);

        this.engine = engine;
    }
    
    void start() {
        engine.mainloop(&poll);
    }
    
    bool poll(uint delta_t) {
        display();
        
        return quit;
    }
    
    void display() {
        glClearColor(0.0f, 1.0f, 0.0f, 1.0f);
        glClearDepth(1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    }
    
    override void on_key_down(int key) {
        if(key == GLFW_KEY_ESCAPE) {
            quit = true;
        }
    }
    
    override bool on_window_close() {
        quit = true;
        return true;
    }
}