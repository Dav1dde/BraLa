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
    import brala.config : initialize_config;
    import brala.network.session : minecraft_folder;
    import brala.network.packets.types : IPacket;
    import brala.gfx.palette : palette_atlas;
    import brala.gfx.terrain : extract_minecraft_terrain, preprocess_terrain;
    import brala.exception : InitError;
    import brala.utils.image : Image;
    import brala.utils.config : Config, Path;

    import std.stdio : stderr, writefln;
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

static ~this() {
    glfwTerminate();
}


class BraLa {
    Config config;
    Window window;
    
    BraLaEngine engine;
    BraLaGame game;

    this() {
        config = initialize_config();
        window = new Window();

        initialize_context();
        initialize_engine();

        game = new BraLaGame(engine, config);
        game.start(config.get!string("connection.host"),
                   config.get!short("connection.port"));
    }

    void initialize_context() {
        window.resizable = false;

        auto cv = window.create_highest_available_context(config.get!int("window.width"),
                                                          config.get!int("window.height"),
                                                          "BraLa - Minecraft on a lower level");
        
        debug writefln("Initialized Window with context version: %s.%s", cv.major, cv.minor);

        window.make_context_current();
        window.set_input_mode(GLFW_CURSOR_MODE, GLFW_CURSOR_CAPTURED);

        DerelictGL3.reload();
        glViewport(0, 0, config.get!int("window.width"), config.get!int("window.height"));
    }

    void initialize_engine() {
        engine = new BraLaEngine(window, config);

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

        Sampler terrain_sampler = new Sampler();
        terrain_sampler.set_parameter(GL_TEXTURE_WRAP_S, GL_REPEAT);
        terrain_sampler.set_parameter(GL_TEXTURE_WRAP_T, GL_REPEAT);
        terrain_sampler.set_parameter(GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        terrain_sampler.set_parameter(GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_LINEAR);

        engine.set_sampler("terrain", terrain_sampler);
    }
}


int main() {
    new BraLa();

    return 0;
}