module brala.main;


private {
    import derelict.glfw3.glfw3;
    import glamour.gl;
    
    import std.conv : to, ConvException;
    
    debug {
        import std.stdio;
    }
    
    import brala.engine : BraLaEngine;
    import brala.game : BraLaGame;
}

static this() {
    DerelictGLFW3.load();
    DerelictGL3.load();

    if(!glfwInit()) {
        throw new Exception("glfwInit failure: " ~ to!string(glfwErrorString(glfwGetError())));
    }
}

GLFWwindow _window;

GLFWwindow open_glfw_win(int width, int height) {    
    glfwOpenWindowHint(GLFW_OPENGL_VERSION_MAJOR, 4); 
    glfwOpenWindowHint(GLFW_OPENGL_VERSION_MINOR, 1); 
    glfwOpenWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
    glfwOpenWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwOpenWindowHint(GLFW_WINDOW_RESIZABLE, GL_FALSE);
    
    _window = glfwOpenWindow(width, height, GLFW_WINDOWED, "BraLa - Minecraft on a higher level", null);
    if(!_window) {
        throw new Exception("Failed to create window: " ~ to!string(glfwErrorString(glfwGetError())));
    }
    
    glfwSwapInterval(0); // change this to 1?
    
    return _window;
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
    // important set any input_handler after initializing
    // glfw and before glfw window initialation.
//     input_handler = new BaseGLFWInputHandler();
    
    debug writefln("init: %dx%d", width, height);
    GLFWwindow win = open_glfw_win(width, height);
    
    GLVersion glv = init_opengl();
    debug writefln("OpenGL: %d", glv);
    
    auto engine = new BraLaEngine(width, height, glv);
    auto game = new BraLaGame(engine, win);
    game.start();
    
    return 0;
}