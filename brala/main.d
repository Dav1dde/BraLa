module brala.main;


private {
    import glamour.gl;
    import glamour.sampler : Sampler, Texture2D;
    import derelict.glfw3.glfw3;

    import std.conv : to, ConvException;
    
    import brala.engine : BraLaEngine;
    import brala.game : BraLaGame;
    import brala.resmgr : resmgr;
    import brala.input : register_glfw_error_callback;
    import brala.config : load_default_resources;
    import brala.network.packets.types : IPacket;
    import brala.gfx.palette : palette_atlas;
    import brala.gfx.terrain : preprocess_terrain;
    import brala.exception : InitError;
    import brala.utils.image : Image;
    
    import std.stdio : writefln;
}

static this() {
    DerelictGLFW3.load();
    DerelictGL3.load();

    if(!glfwInit()) {
        throw new InitError("glfwInit failure: " ~ to!string(glfwErrorString(glfwGetError())));
    }
}

GLFWwindow _window;

GLFWwindow open_glfw_win(int width, int height) {
    glfwOpenWindowHint(GLFW_WINDOW_RESIZABLE, GL_FALSE);
    
    _window = glfwOpenWindow(width, height, GLFW_WINDOWED, "BraLa - Minecraft on a higher level", null);
    
    if(!_window) {
        throw new InitError("I am sorry man, I am not able to initialize a window/create an OpenGL context :/.");
    }
    
    glfwSetInputMode(_window, GLFW_CURSOR_MODE, GLFW_CURSOR_CAPTURED);
    
    glfwSwapInterval(0); // change this to 1?
    
    return _window;
}

void glfw_error_cb(int errno, string error) {
    static int last_errno = -1;
    if(last_errno != errno) {
        writefln("GLFW ERROR(%d): %s", errno, error);
        last_errno = errno;
    }
}

GLVersion init_opengl() {
    return DerelictGL3.reload();
}

BraLaEngine init_engine(int width, int height, GLVersion glv) {
    auto engine = new BraLaEngine(width, height, glv);
    
    engine.resmgr.load_default_resources(); // I like! ~15mb in 837ms
    Image terrain = preprocess_terrain(engine.resmgr.get!Image("terrain"));
    engine.resmgr.add("terrain", terrain.to_texture());
    
    Image palette = palette_atlas(engine.resmgr.get!Image("grasscolor"),
                                  engine.resmgr.get!Image("leavecolor"),
                                  engine.resmgr.get!Image("watercolor"));
    Texture2D palette_tex = palette.to_texture();
    palette_tex.unit = GL_TEXTURE0 + 1;
    engine.resmgr.add("palette", palette_tex);
    
    Sampler terrain_sampler = new Sampler();
    terrain_sampler.set_parameter(GL_TEXTURE_WRAP_S, GL_REPEAT);
    terrain_sampler.set_parameter(GL_TEXTURE_WRAP_T, GL_REPEAT);
    terrain_sampler.set_parameter(GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    terrain_sampler.set_parameter(GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_LINEAR);

    GLenum GL_TEXTURE_MAX_ANISOTROPY_EXT = 0x84FE;
    float max_aniso = 0.0f;
    glGetFloatv(GL_TEXTURE_MAX_ANISOTROPY_EXT, &max_aniso);
    terrain_sampler.set_parameter(GL_TEXTURE_MAX_ANISOTROPY_EXT, max_aniso);
    
    engine.set_sampler("terrain", terrain_sampler);

    return engine;
}

int main(string[] args) {
    scope(exit) glfwTerminate();
    
    int width = 1024;
    int height = 800;
    
    if(args.length == 7) {
        try {
            width = to!(int)(args[5]);
        } catch(ConvException) {
            throw new InitError("Width is not a number.");
        }
        
        try {
            height = to!(int)(args[6]);
        } catch(ConvException) {
            throw new InitError("Height is not a number.");
        }
    }
    
    debug register_glfw_error_callback(&glfw_error_cb);
    
    debug writefln("init: %dx%d", width, height);
    GLFWwindow win = open_glfw_win(width, height);
    
    GLVersion glv = init_opengl();
    debug writefln("Supported OpenGL version: %s\n"
                   "Loaded OpenGL version: %d", to!string(glGetString(GL_VERSION)), glv);
                   
    auto engine = init_engine(width, height, glv);

    auto game = new BraLaGame(engine, win, args[1], args[2]);
    game.start(args[3], to!ushort(args[4]));
    
    return 0;
}