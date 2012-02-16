module brala.main;


private {
    import glamour.gl;
    import derelict.glfw3.glfw3;
    import derelict.devil.il;
    
    import std.conv : to, ConvException;
    
    import brala.engine : BraLaEngine;
    import brala.game : BraLaGame;
    import brala.event : register_glfw_error_callback;
    
    debug import std.stdio : writefln;
}

static this() {
    DerelictGLFW3.load();
    DerelictGL3.load();
    DerelictIL.load();

    if(!glfwInit()) {
        throw new Exception("glfwInit failure: " ~ to!string(glfwErrorString(glfwGetError())));
    }
    
    ilInit();
}

GLFWwindow _window;

GLFWwindow open_glfw_win(int width, int height) {    
    glfwOpenWindowHint(GLFW_OPENGL_VERSION_MAJOR, 3); 
    glfwOpenWindowHint(GLFW_OPENGL_VERSION_MINOR, 1); 
    glfwOpenWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
    glfwOpenWindowHint(GLFW_WINDOW_RESIZABLE, GL_FALSE);
    
    _window = glfwOpenWindow(width, height, GLFW_WINDOWED, "BraLa - Minecraft on a higher level", null);
    if(!_window) {
        throw new Exception("Failed to create window: " ~ to!string(glfwErrorString(glfwGetError())));
    }
    
    debug {} else { glfwSetInputMode(_window, GLFW_CURSOR_MODE, GLFW_CURSOR_CAPTURED); }
       
    glfwSwapInterval(0); // change this to 1?
    
    return _window;
}

void glfw_error_cb(int errno, string error) {
    static int last_errno = -1;
    if(last_errno != errno) {
        debug writefln("GLFW ERROR(%d): %s", errno, error);
        last_errno = errno;
    }
}

GLVersion init_opengl() {
    return DerelictGL3.reload();
}

int main(string[] args) {
    scope(exit) glfwTerminate();
    
    int width = 1024;
    int height = 800;
    
    if(args.length == 3) {
        try {
            width = to!(int)(args[1]);
        } catch(ConvException) {
            throw new Exception("width is not a number.");
        }
        
        try {
            height = to!(int)(args[2]);
        } catch(ConvException) {
            throw new Exception("height is not a number.");
        }
    }

    register_glfw_error_callback(&glfw_error_cb);
    
    debug writefln("init: %dx%d", width, height);
    GLFWwindow win = open_glfw_win(width, height);
    
    GLVersion glv = init_opengl();
    debug writefln("OpenGL: %d", glv);
    
    auto engine = new BraLaEngine(width, height, glv);
    auto game = new BraLaGame(engine, win);
    game.start();
    
    return 0;
}