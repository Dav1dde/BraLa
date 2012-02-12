module brala.game;

private {
    import derelict.glfw3.glfw3;
    import glamour.gl;
    
    import brala.engine : BraLaEngine;
    import brala.input : input_handler, GLFWInputHandler;
    
    import std.stdio;
}


class BraLaGame {
    BraLaEngine engine;    
    
    this(BraLaEngine engine_) {
        engine = engine_;
        input_handler.ai = new GLFWInputHandler();
    }
    
    void start() {
        engine.mainloop(&poll);
    }
    
    
    bool poll(float delta_t) {
        display();
        
        return input_handler.ai.quit;
        
    }
    
    void display() {
        glClearColor(0.0f, 1.0f, 0.0f, 1.0f);
        glClearDepth(1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    }
}