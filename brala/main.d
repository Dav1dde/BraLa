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
    import std.path : buildPath, dirName, absolutePath;
    import std.zlib : ZlibException;
    import file = std.file;
    import std.string : format;
    import std.exception : enforceEx, collectException;
    import core.thread : thread_isMainThread;
    import core.time : dur;

    import brala.log : logger = main_logger;
    import brala.utils.log;
    import brala.engine : BraLaEngine;
    import brala.game : BraLaGame;
    import brala.config : initialize_config;
    import brala.network.session : Session, DelayedSnooper, minecraft_folder;
    import brala.network.packets.types : IPacket;
    import brala.gfx.palette : palette_atlas;
    import brala.gfx.terrain : extract_minecraft_terrain, preprocess_terrain;
    import brala.exception : InitError;
    import brala.utils.image : Image;
    import brala.utils.config : Config, Path;
    import brala.utils.debugger : is_debugged;

    import std.stdio : writefln;
}

void glfw_error_cb(int errno, string error) {
    static int last_errno = -1;
    if(last_errno != errno) {
        logger.log!Warn("GLFW ERROR(%d): %s", errno, error);
        last_errno = errno;
    }
}

void glamour_error_cb(GLenum errno, string func, string args) {
    static GLenum last_errno = GL_NO_ERROR;
    static string last_func = "";

    if(last_errno != errno && last_func != func) {
        logger.log!Warn(`OpenGL function "%s(%s)" failed: "%s."`, func, args, gl_error_string(errno));
        last_errno = errno;
        last_func = func;
    }
}
    

class BraLa {
    Config config;
    Window window;

    Session session;
    DelayedSnooper snooper;
   
    BraLaEngine engine;
    BraLaGame game;

    this() {
        this(initialize_config());
    }

    this(Config config) {
        this.config = config;
        this.session = new Session();
        this.snooper = new DelayedSnooper();
        if(!config.get!bool("brala.no_snoop")) {
            snooper.start(dur!"minutes"(10));
        }
        
        this.window = new Window();

        initialize_context();
        initialize_engine();

        window.single_key_down[GLFW_KEY_ESCAPE].connect(&exit);
        window.on_close = &on_close;
    }

    void shutdown()
        in { assert(thread_isMainThread(), "BraLa.shutdown has to be called from main thread"); }
        body {
            engine.shutdown();
            snooper.stop();
        }

    void start() {
        if(config.has_key!string("connection.host")) {
            session.login(config.get!(string, false)("account.username"),
                          config.get!(string, false)("account.password"));

            start_game(config.get!string("connection.host"),
                       config.get!short("connection.port"));
        } else {
            writefln("No UI implemented");
        }
    }

    void exit() {
        exit_game();
    }
        

    void initialize_context() {
        window.resizable = config.get!bool("window.resizable");

        auto cv = window.create_highest_available_context(config.get!int("window.width"),
                                                          config.get!int("window.height"),
                                                          "BraLa - Minecraft on a lower level",
                                                          null, null, GLFW_OPENGL_CORE_PROFILE, false);
        
        logger.log!Info("Initialized Window with context version: %s.%s", cv.major, cv.minor);

        window.make_context_current();

        if(!is_debugged) {
            window.set_input_mode(GLFW_CURSOR_MODE, GLFW_CURSOR_CAPTURED);
        }

        DerelictGL3.reload();
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
                logger.log!Warn(`Failed to load minecraft terrain.png, Zlib Error: "%s"`, e.msg);
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

    void start_game(string host, short port) {
        collectException(snooper.snoop());
        
        game = new BraLaGame(engine, session, config);
        game.start(host, port);
    }

    void exit_game() {
        if(game !is null) {
            game.quit();
        }
    }

    bool on_close() {
        return true;
    }
}

int main(string[] args) {
    DerelictGL3.load();
    version(DynamicGLFW) { DerelictGLFW3.load(); }

    register_glfw_error_callback(&glfw_error_cb);
    debug glamour_set_error_callback(&glamour_error_cb);

    enforceEx!InitError(glfwInit(), "glfwInit failed!");
    scope(exit) glfwTerminate();
    glfwSwapInterval(0);

    Config config = initialize_config();
    string exedir = (args[0].dirName().absolutePath());

    auto brala = new BraLa(config);

    scope(exit) {
        brala.shutdown();
    }

    brala.start();

    return 0;
}