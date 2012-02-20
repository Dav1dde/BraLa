module brala.game;

private {
    import glamour.gl;
    import derelict.glfw3.glfw3;
    
    import gl3n.linalg : vec2i;
    
    import brala.engine : BraLaEngine;
    import brala.event : BaseGLFWEventHandler;
    import brala.camera : ICamera, FreeCamera;
    import brala.types : DefaultAA;
    import brala.util : clear;
    import brala.config;
    
    debug import std.stdio;
}


class BraLaGame : BaseGLFWEventHandler {
    BraLaEngine engine;
    
    ICamera cam;
    
    DefaultAA!(bool, int, false) keymap;
    vec2i mouse_offset = vec2i(0, 0);
    
    bool quit = false;
    
    this(BraLaEngine engine, void* window) {
        this.engine = engine;
        cam = new FreeCamera(engine);

        super(window); // call this at the end or have a life with segfaults!
    }
    
    void start() {
        engine.mainloop(&poll);
    }
    
    bool poll(uint delta_t) {
        if(keymap[MOVE_FORWARD])  cam.move_forward(delta_t);
        if(keymap[MOVE_BACKWARD]) cam.move_backward(delta_t);
        if(keymap[STRAFE_LEFT])  cam.strafe_left(delta_t);
        if(keymap[STRAFE_RIGHT]) cam.strafe_right(delta_t);
        if(mouse_offset.x > 0)      cam.rotatex(delta_t);
        else if(mouse_offset.x < 0) cam.rotatex(-delta_t);
        if(mouse_offset.y > 0)      cam.rotatey(delta_t);
        else if(mouse_offset.y < 0) cam.rotatey(-delta_t);
        cam.apply();
        
        display();
        
        return quit || keymap[GLFW_KEY_ESCAPE];
    }
    
    void display() {
        clear();
    }
    
    override void on_key_down(int key) {
        keymap[key] = true;
    }
    
    override void on_key_up(int key) {
        keymap[key] = false;
    }
    
    override void on_mouse_pos(int x, int y) {
        static int last_x = 0;
        static int last_y = 0;
        
        if((x != engine.viewport.x /2) || (y != engine.viewport.y)) {
            mouse_offset.x = x - last_x;
            mouse_offset.y = y - last_y;
            
            // this will create a GLFE_ERROR 458761 / "The specified window is not active"
            // for the first callback, just ignore it.
            glfwSetMousePos(window, engine.viewport.x / 2, engine.viewport.y / 2);
        }
                
        last_x = x;
        last_y = y;
    }
    
    override bool on_window_close() {
        quit = true;
        return true;
    }
}