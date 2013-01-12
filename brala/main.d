module brala.main;


private {
    import glamour.gl;
    import glamour.sampler : Sampler;
    import glamour.texture : Texture2D;
    import glamour.util : gl_error_string, glamour_set_error_callback = set_error_callback;
    import glwtf.glfw;
    import glwtf.window;
    import glwtf.input : register_glfw_error_callback;

    import std.conv : to;
    import std.path : buildPath;
    import std.zlib : ZlibException;
    import file = std.file;
    import std.string : format;
    import std.process : getenv;
    import std.exception : enforceEx;

    import brala.engine : BraLaEngine;
    import brala.game : BraLaGame;
    import brala.config : app_arguments, AppArguments, load_default_resources;
    import brala.network.session : minecraft_folder, minecraft_credentials;
    import brala.network.packets.types : IPacket;
    import brala.gfx.palette : palette_atlas;
    import brala.gfx.terrain : extract_minecraft_terrain, preprocess_terrain;
    import brala.exception : InitError;
    import brala.utils.image : Image;

    import brala.utils.stdio : stderr, writefln;
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



Window _window;

Window open_glfw_win(int width, int height) {
    _window = new Window();
    _window.set_hint(GLFW_RESIZABLE, GL_FALSE);

    _window.create(width, height, "BraLa - Minecraft on a lower level");
    _window.make_context_current();
    _window.set_input_mode(GLFW_CURSOR_MODE, GLFW_CURSOR_CAPTURED);

    glfwSwapInterval(0); // change this to 1?

    return _window;
}

GLVersion init_opengl() {
    return DerelictGL3.reload();
}

BraLaEngine init_engine(Window window, AppArguments args, GLVersion glv) {
    auto engine = new BraLaEngine(window, args.width, args.height, glv);

    engine.resmgr.load_default_resources(args.res);

    string path = buildPath(minecraft_folder(), "bin", "minecraft.jar");
    if(args.default_tp && file.exists(path)) {
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
    string username = app_arguments.username;
    string password = app_arguments.password;
    if(app_arguments.credentials) {
        auto credentials = minecraft_credentials();

        if(credentials.username.length) {
            username = credentials.username;
        }
        if(credentials.password.length) {
            password = credentials.password;
        }
    }

//     return test_connection(username, password);

    scope(exit) glfwTerminate();

    debug writefln("init: %dx%d", app_arguments.width, app_arguments.height);
    Window win = open_glfw_win(app_arguments.width, app_arguments.height);

    GLVersion glv = init_opengl();
    debug writefln("Supported OpenGL version: %s\n"
                   "Loaded OpenGL version: %d", to!string(glGetString(GL_VERSION)), glv);

    enforceEx!InitError(glv >= 30, "Loaded OpenGL version too low, need at least OpenGL 3.0");

    auto engine = init_engine(win, app_arguments, glv);

    auto game = new BraLaGame(engine, username, password, app_arguments);

    try {
        game.start(app_arguments.host, app_arguments.port);
    } catch(Exception e) {
        stderr.writeln(e.toString());
    }

    return 0;
}

int test_connection(string username, string password) {
    import brala.network.connection;
    import brala.utils.stdio;

    int exit_status = 13;

    auto c = new Connection(username, password, false);
        
    void dispatch(ubyte id, void* packet) {
//         writefln("id: %s", id);
        if(id == 4) {
            c.disconnect();
            exit_status = 0;
        }
    }

    c.callback = &dispatch;

    c.connect(app_arguments.host, app_arguments.port);
    c.login();

    c.run();

    return exit_status;
}