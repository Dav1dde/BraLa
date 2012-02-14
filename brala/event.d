module brala.event;


private {
    import derelict.glfw3.glfw3;
    import std.conv : to;
    import std.utf;
    
    debug {
        import std.stdio : writefln;
    }
}

AEventHandler cast_userptr(void* window) {
    void* user_ptr = glfwGetWindowUserPointer(window);
    AEventHandler ae = cast(AEventHandler)user_ptr;
    
    if(ae is null) {
        throw new Exception("dang, glfwGetWindowUserPointer did return garbage? cast to AEventHandler failed");
    }
    
    return ae;
}
    

extern(C) {
    void key_callback(void* window, int key, int state) {
        AEventHandler ae = cast_userptr(window);
    
        if(state == GLFW_PRESS) {
            ae.on_key_down(key);
        } else {
            ae.on_key_up(key);
        }
    }

    void char_callback(void* window, int c) {
        AEventHandler ae = cast_userptr(window);
        
        ae.on_char(cast(dchar)c);
    }

    void mouse_button_callback(void* window, int button, int state) {
        AEventHandler ae = cast_userptr(window);
    
        if(state == GLFW_PRESS) {
            ae.on_mouse_button_down(button);
        } else {
            ae.on_mouse_button_up(button);
        }
    }

    void mouse_pos_callback(void* window, int x, int y) {
        AEventHandler ae = cast_userptr(window);
        
        ae.on_mouse_pos(x, y);
    }

    void scroll_callback(void* window, int xoffset, int yoffset) {
        AEventHandler ae = cast_userptr(window);
    
        ae.on_scroll(xoffset, yoffset);
    }
}

abstract class AEventHandler {
    void on_key_down(int key) {}
    void on_key_up(int key) {}
    void on_char(dchar c) {}
    void on_mouse_button_down(int button) {}
    void on_mouse_button_up(int button) {}
    void on_mouse_pos(int x, int y) {}
    void on_scroll(int xoffset, int yoffset) {}
    
    // used for generating sdl callbacks?
    void poll() {}
}

class BaseGLFWEventHandler : AEventHandler {
    void* window;
    
    this(void* window) {
        this.window = window;
        
        glfwSetWindowUserPointer(window, cast(void *)this);
        
        glfwSetKeyCallback(&key_callback);
        glfwSetCharCallback(&char_callback);
        glfwSetMouseButtonCallback(&mouse_button_callback);
        glfwSetMousePosCallback(&mouse_pos_callback);
        glfwSetScrollCallback(&scroll_callback);
    }
}

class BralaEventHandler : BaseGLFWEventHandler {
    this(void* window) {
        super(window);
    }
    
    override void on_key_down(int key) {writefln("%d", key);}
}