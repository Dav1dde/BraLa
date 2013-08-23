module brala.main;


private {
    import glamour.gl;
    import glamour.util : gl_error_string, glamour_set_error_callback = set_error_callback;
    import glwtf.glfw;
    import glwtf.window : Window;
    import glwtf.input : register_glfw_error_callback;
    import glad.gl.loader;

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
    import brala.network.session : Session, DelayedSnooper;
    import brala.network.packets.types : IPacket;
    import brala.gfx.palette : palette_atlas;
    import brala.gfx.terrain : MinecraftAtlas;
    import brala.exception : InitError;
    import brala.utils.image : Image;
    import brala.utils.config : Config, Path;
    import brala.utils.debugger : is_debugged;

    import std.stdio : writefln;
}


shared static this() {
    static if(__traits(compiles, {
        import etc.linux.memoryerror;
        registerMemoryErrorHandler();
    })) {
        import etc.linux.memoryerror;
        logger.log!Info("Registering segfault handler");
        logger.log_if!Warn(!registerMemoryErrorHandler(), "Could not register handler");
    }
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
    

final class BraLa {
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

        this.window = new Window();

        initialize_context();
        initialize_engine();

        // initialize snooper after opengl was initialized!
        this.snooper = new DelayedSnooper();

        window.single_key_down[GLFW_KEY_ESCAPE].connect!"exit"(this);
        window.on_close = &on_close;

        if(!config.get!bool("brala.no_snoop") && !config.get!bool("connection.offline")) {
            snooper.start(dur!"minutes"(10));
        }
    }

    void shutdown()
        in { assert(thread_isMainThread(), "BraLa.shutdown has to be called from main thread"); }
        body {
            engine.shutdown();
            snooper.stop();
        }

    void start() {
        if(config.has_key!string("connection.host")) {
            if(config.get!bool("connection.offline")) {
                session.minecraft_username = config.get!(string, false)("account.username");
            } else if(config.has_key!string("account.session")) {
                session.session_id = config.get!(string, false)("account.session");
                session.minecraft_username = config.get!(string, false)("account.username");
                session.username = config.get!(string, false)("account.realusername");
            } else {
                session.authenticate(
                    config.get!(string, false)("account.username"),
                    config.get!(string, false)("account.password")
                );
            }

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

        auto cv = window.create_highest_available_context(
            config.get!int("window.width"),
            config.get!int("window.height"),
            "BraLa - Minecraft on a lower level",
            null, null, GLFW_OPENGL_CORE_PROFILE, false
        );
        
        logger.log!Info("Initialized Window with context version: %s.%s", cv.major, cv.minor);

        window.make_context_current();
        glfwSwapInterval(0);

        if(!is_debugged) {
            window.set_input_mode(GLFW_CURSOR, GLFW_CURSOR_DISABLED);
        }

        auto glv = gladLoadGL();
    }

    void initialize_engine() {
        engine = new BraLaEngine(window, config);

        engine.resmgr.add_many(config.get!(Path[])("engine.resources"));
    }

    void start_game(string host, short port) {
        if(snooper.is_running) collectException(snooper.snoop());
        
        auto atlas = new MinecraftAtlas(engine);
        game = new BraLaGame(engine, session, atlas);
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
    version(DynamicGLFW) { DerelictGLFW3.load(); }
    enforceEx!InitError(glfwInit(), "glfwInit failed!");
    scope(exit) glfwTerminate();

    register_glfw_error_callback(&glfw_error_cb);
    debug glamour_set_error_callback(&glamour_error_cb);

    Config config = initialize_config();
    string exedir = (args[0].dirName().absolutePath());

    auto brala = new BraLa(config);

    scope(exit) brala.shutdown();

    try brala.start();
    catch(Throwable t) logger.log_exception(t);

    return 0;
}