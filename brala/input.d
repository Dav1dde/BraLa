module brala.input;


private {
    import derelict.glfw3.glfw3;
    
    debug {
        import std.stdio : writefln;
    }
}

extern(C) struct CBHandle {
    AInputHandler ai;
    
    void key_callback(void* window, int key, int state) { ai.key_callback(window, key, state); }
    void char_callback(void* window, int c) { ai.char_callback(window, c); }
    void mouse_button_callback(void* window, int button, int state) { ai.mouse_button_callback(window, button, state); }
    void mouse_pos_callback(void* window, int x, int y) { ai.mouse_pos_callback(window, x, y); }
    void scroll_callback(void* window, int xoffset, int yoffset) { ai.scroll_callback(window, xoffset, yoffset); }
    
    void opAssign(AInputHandler a) {
        ai = a;
    }
}

CBHandle input_handler;

abstract class AInputHandler {
    bool quit;
    
    void key_callback(void* window, int key, int state) {}
    void char_callback(void* window, int c) {}
    void mouse_button_callback(void* window, int button, int state) {}
    void mouse_pos_callback(void* window, int x, int y) {}
    void scroll_callback(void* window, int xoffset, int yoffset) {}
    
    // used for generating sdl callbacks?
    void poll() {}
}

extern(C) {
    void keycb(void* window, int key, int state) { input_handler.key_callback(window, key, state); }
    void charcb(void* window, int c) { input_handler.char_callback(window, c); }
    void mousebtncb(void* window, int button, int state) { input_handler.mouse_button_callback(window, button, state); }
    void mouseposcb(void* window, int x, int y) { input_handler.mouse_pos_callback(window, x, y); }
    void scrollcb(void* window, int xoffset, int yoffset) { input_handler.scroll_callback(window, xoffset, yoffset); }
}

class BaseGLFWInputHandler : AInputHandler {    
    this() {
        glfwSetKeyCallback(&keycb);
        glfwSetCharCallback(&charcb);
        glfwSetMouseButtonCallback(&mousebtncb);
        glfwSetMousePosCallback(&mouseposcb);
        glfwSetScrollCallback(&scrollcb);
    }
}

class GLFWInputHandler : BaseGLFWInputHandler {
}