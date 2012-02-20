module brala.game;

private {
    import glamour.gl;
    import derelict.glfw3.glfw3;
    
    import brala.engine : BraLaEngine;
    import brala.event : BaseGLFWEventHandler;
    import brala.camera : ICamera, FreeCamera;
    import brala.types : DefaultAA;
    import brala.config;
    
    debug import std.stdio;
}


class BraLaGame : BaseGLFWEventHandler {
    BraLaEngine engine;
    
    ICamera cam;
    
    DefaultAA!(bool, int, false) keymap;
    
    bool quit = false;
    
    this(BraLaEngine engine, void* window) {
        super(window);

        this.engine = engine;
        cam = new FreeCamera(engine);
    }
    
    void start() {
        engine.mainloop(&poll);
    }
    
    bool poll(uint delta_t) {
        if(keymap[MOVE_FORWARD])  cam.move_forward(delta_t);
        if(keymap[MOVE_BACKWARD]) cam.move_backward(delta_t);
        if(keymap[STRAFE_LEFT])  cam.strafe_left(delta_t);
        if(keymap[STRAFE_RIGHT]) cam.strafe_right(delta_t);
        cam.apply();
        
        display();
        
        return quit || keymap[GLFW_KEY_ESCAPE];
    }
    
    void display() {
        glClearColor(0.0f, 1.0f, 0.0f, 1.0f);
        glClearDepth(1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    }
    
    override void on_key_down(int key) {
        keymap[key] = true;
    }
    
    override void on_key_up(int key) {
        keymap[key] = false;
    }
    
    override bool on_window_close() {
        quit = true;
        return true;
    }
}