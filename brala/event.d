module brala.event;


private {
    import derelict.glfw3.glfw3;
    import std.conv : to;
    
    debug import std.stdio : writefln;
}

AEventHandler cast_userptr(void* window) {
    void* user_ptr = glfwGetWindowUserPointer(window);
    AEventHandler ae = cast(AEventHandler)user_ptr;
    
    if(ae is null) {
        throw new Exception("dang unable to get the EventHandler class from the user-pointer, "
                            "did glfwGetWindowUserPointer return garbage?");
    }
    
    return ae;
}

private void function(int, string) glfw_error_callback;

void register_glfw_error_callback(void function(int, string) cb) {
    glfw_error_callback = cb;
    
    glfwSetErrorCallback(&error_callback);
}

extern(C) {
    // window events //
    void window_resize_callback(void* window, int width, int height) {
        AEventHandler ae = cast_userptr(window);
        
        ae.on_window_resize(width, height);
    }
    
    int window_close_callback(void* window) {
        AEventHandler ae = cast_userptr(window);
        
        return cast(int)ae.on_window_close();
    }
    
    void window_refresh_callback(void* window) {
        AEventHandler ae = cast_userptr(window);
        
        ae.on_window_refresh();
    }
    
    void window_focus_callback(void* window, int focused) {
        AEventHandler ae = cast_userptr(window);
        
        ae.on_window_focus(focused == GLFW_PRESS);
    }
    
    void window_iconify_callback(void* window, int iconified) {
        AEventHandler ae = cast_userptr(window);
        
        ae.on_window_iconify(iconified == GLFW_PRESS); // TODO: test this
    }
    
    // user input //
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
    
    // misc //
    void error_callback(int errno, const(char)* error) {
        glfw_error_callback(errno, to!string(error));
    }
}

abstract class AEventHandler {
    // window
    void on_window_resize(int width, int height) {}
    bool on_window_close() { return true; }
    void on_window_refresh() {}
    void on_window_focus(bool focused) {}
    void on_window_iconify(bool iconified) {}
    
    // input
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
        
        glfwSetWindowSizeCallback(&window_resize_callback);
        glfwSetWindowCloseCallback(&window_close_callback);
        glfwSetWindowRefreshCallback(&window_refresh_callback);
        glfwSetWindowFocusCallback(&window_focus_callback);
        glfwSetWindowIconifyCallback(&window_iconify_callback);
        
        glfwSetKeyCallback(&key_callback);
        glfwSetCharCallback(&char_callback);
        glfwSetMouseButtonCallback(&mouse_button_callback);
        glfwSetMousePosCallback(&mouse_pos_callback);
        glfwSetScrollCallback(&scroll_callback);
    }
}