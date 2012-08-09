module brala.main;


private {
    import glamour.gl;
    import glamour.sampler : Sampler;
    import glamour.texture : Texture2D;
    import glamour.util : gl_error_string, glamour_set_error_callback = set_error_callback;
    import derelict.glfw3.glfw3;

    import std.conv : to;
    import std.path : buildPath;
    import std.zlib : ZlibException;
    import file = std.file;
    import std.process : getenv;
    
    import brala.engine : BraLaEngine;
    import brala.game : BraLaGame;
    import brala.input : register_glfw_error_callback;
    import brala.config : load_default_resources;
    import brala.network.session : minecraft_folder, minecraft_credentials;
    import brala.network.packets.types : IPacket;
    import brala.gfx.palette : palette_atlas;
    import brala.gfx.terrain : extract_minecraft_terrain, preprocess_terrain;
    import brala.exception : InitError;
    import brala.utils.image : Image;
    import brala.utils.dargs : get_options, Alias;
    
    import std.stdio : stderr, writefln;
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
        stderr.writefln("GLFW ERROR(%d): %s", errno, error);
        last_errno = errno;
    }
}

void glamour_error_cb(GLenum errno, string func) {
    static GLenum last_errno = GL_NO_ERROR;
    static string last_func = "";

    if(last_errno != errno && last_func != func) {
        stderr.writefln(`OpenGL function "%s" failed: "%s."`, func, gl_error_string(errno));
        last_errno = errno;
        last_func = func;
    }
}

GLVersion init_opengl() {
    return DerelictGL3.reload();
}

BraLaEngine init_engine(int width, int height, GLVersion glv) {
    auto engine = new BraLaEngine(width, height, glv);
    
    engine.resmgr.load_default_resources(); // I like! ~15mb in 837ms

    string path = buildPath(minecraft_folder(), "bin", "minecraft.jar");
    if(file.exists(path)) {
        try {
            Image mc_terrain = extract_minecraft_terrain(path);

            engine.resmgr.remove!Image("terrain");
            engine.resmgr.add("terrain", mc_terrain);
        } catch(ZlibException e) {
            stderr.writefln(`Failed to load minecraft terrain.png, Zlib Error: "%s"`, e.msg);
        }
    }

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

struct AppArguments {
    string username;
    Alias!("username") u;

    string password;
    Alias!("password") p;

    bool credentials;
    Alias!("credentials") c;
    
    uint width = 1024;
    uint height = 800;

    string host;
    Alias!("host") h;
    ushort port = 25565;

    bool no_snoop = false;
}


int main() {
    scope(exit) glfwTerminate();

    auto args = get_options!AppArguments();
    
    debug register_glfw_error_callback(&glfw_error_cb);
    debug glamour_set_error_callback(&glamour_error_cb);
    
    debug writefln("init: %dx%d", args.width, args.height);
    GLFWwindow win = open_glfw_win(args.width, args.height);
    
    GLVersion glv = init_opengl();
    debug writefln("Supported OpenGL version: %s\n"
                   "Loaded OpenGL version: %d", to!string(glGetString(GL_VERSION)), glv);


    string username = args.username;
    string password = args.password;
    if(args.credentials) {
        auto credentials = minecraft_credentials();

        if(credentials.username.length) {
            username = credentials.username;
        }
        if(credentials.password.length) {
            password = credentials.password;
        }
    }
   
    auto engine = init_engine(args.width, args.height, glv);

    auto game = new BraLaGame(engine, win, username, password, !args.no_snoop);
    game.start(args.host, args.port);

    return 0;
}