module brala.main;


private {
    import glamour.gl;
    import glamour.sampler : Sampler;
    import glamour.texture : Texture2D;
    import glamour.util : gl_error_string, glamour_set_error_callback = set_error_callback;
    import glwtf.glfw;
    import glwtf.window : Window;
    import glwtf.input : register_glfw_error_callback;

    import std.conv : to;
    import std.path : buildPath;
    import std.zlib : ZlibException;
    import file = std.file;
    import std.string : format;
    import std.exception : enforceEx;

    import brala.engine : BraLaEngine;
    import brala.game : BraLaGame;
    import brala.config : app_arguments, AppArguments;
    import brala.network.session : minecraft_folder, minecraft_credentials;
    import brala.network.packets.types : IPacket;
    import brala.gfx.palette : palette_atlas;
    import brala.gfx.terrain : extract_minecraft_terrain, preprocess_terrain;
    import brala.exception : InitError;
    import brala.utils.image : Image;
    import brala.utils.config : Config, Path;

    import std.stdio : stderr, writefln;
}


static this() {
    DerelictGL3.load();

    version(DynamicGLFW) {
        DerelictGLFW3.load();
    }

    register_glfw_error_callback(&glfw_error_cb);
    debug glamour_set_error_callback(&glamour_error_cb);

    auto err = glfwInit();
    enforceEx!InitError(err, "glfwInit failure, returned: %s".format(err));
}

void glfw_error_cb(int errno, string error) {
    static int last_errno = -1;
    if(last_errno != errno) {
        stderr.writefln("GLFW ERROR(%d): %s", errno, error);
        last_errno = errno;
    }
}

void glamour_error_cb(GLenum errno, string func, string args) {
    static GLenum last_errno = GL_NO_ERROR;
    static string last_func = "";

    if(last_errno != errno && last_func != func) {
        stderr.writefln(`OpenGL function "%s(%s)" failed: "%s."`, func, args, gl_error_string(errno));
        last_errno = errno;
        last_func = func;
    }
}


Window open_glfw_win(int width, int height) {
    Window window = new Window();
    window.resizable = false;

    // Creates a window with the highest available context with the CORE profile.
    // throws WindowError if it fails to create the window
    auto context_version = window.create_highest_available_context(width, height, "BraLa - Minecraft on a lower level");
    debug writefln("Initialized Window with context version: %s.%s", context_version.major, context_version.minor);

    window.make_context_current();
    window.set_input_mode(GLFW_CURSOR_MODE, GLFW_CURSOR_CAPTURED);

    return window;
}

BraLaEngine init_engine(Window window, Config config, GLVersion glv) {
    auto engine = new BraLaEngine(window, config, glv);

    engine.resmgr.add_many(config.get!(Path[])("engine.resources"));

    string path = buildPath(minecraft_folder(), "bin", "minecraft.jar");
    if(config.get!bool("brala.default_tp") && file.exists(path)) {
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

//     Image palette = palette_atlas(engine.resmgr.get!Image("grasscolor"),
//                                   engine.resmgr.get!Image("leavecolor"),
//                                   engine.resmgr.get!Image("watercolor"));
//     engine.resmgr.add("palette", palette);

    Sampler terrain_sampler = new Sampler();
    terrain_sampler.set_parameter(GL_TEXTURE_WRAP_S, GL_REPEAT);
    terrain_sampler.set_parameter(GL_TEXTURE_WRAP_T, GL_REPEAT);
    terrain_sampler.set_parameter(GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    terrain_sampler.set_parameter(GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_LINEAR);

//     float max_aniso = 0.0f;
//     glGetFloatv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, &max_aniso);
//     terrain_sampler.set_parameter(GL_TEXTURE_MAX_ANISOTROPY_EXT, max_aniso >= 8 ? 8.0f : max_aniso);

    engine.set_sampler("terrain", terrain_sampler);

    return engine;
}


int main() {
    auto config = new Config();
    config.dont_save = ["account.password"];
    config.read(app_arguments.brala_conf);

    config.set_default("path.res", "");
    config.set_if("path.res", app_arguments.res);

    config.set_default("account.credentials", false);
    config.set_if("account.credentials", app_arguments.credentials);
    config.set_if("account.username", app_arguments.username);
    config.set_if("account.password", app_arguments.password);

    if(config.get!bool("account.credentials")) {
        auto credentials = minecraft_credentials();

        config.set_if("account.username", credentials.username);
        config.set_if("account.password", credentials.password);
    }

    config.set_default("window.width", 1024);
    config.set_default("window.height", 800);
    config.set_if("window.width", app_arguments.width);
    config.set_if("window.height", app_arguments.height);

    config.set_assert("connection.host", app_arguments.host, "You have to specify a host to connect to!");

    config.set_default("connection.port", 25565);
    config.set_if("connection.port", app_arguments.port);

    config.set_default("brala.no_snoop", false);
    config.set_if("brala.no_snoop", app_arguments.no_snoop);

    config.set_default("brala.tessellation_threads", 3);
    config.set_if("brala.tessellation_threads", app_arguments.tessellation_threads);

    config.set_default("brala.default_tp", false);
    config.set_if("brala.default_tp", app_arguments.default_tp);
    
    scope(exit) glfwTerminate();

    debug writefln("init: %dx%d", config.get!int("window.width"),
                                  config.get!int("window.height"));
    Window win = open_glfw_win(config.get!int("window.width"), config.get!int("window.height"));

    GLVersion glv = DerelictGL3.reload();
    debug writefln("Supported OpenGL version: %s\n"
                   "Loaded OpenGL version: %d", to!string(glGetString(GL_VERSION)), glv);

    enforceEx!InitError(glv >= 30, "Loaded OpenGL version too low, need at least OpenGL 3.0");

    auto engine = init_engine(win, config, glv);

    auto game = new BraLaGame(engine, config);

    try {
        game.start(config.get!string("connection.host"), config.get!short("connection.port"));
    } catch(Exception e) {
        stderr.writeln(e.toString());
    }

    return 0;
}