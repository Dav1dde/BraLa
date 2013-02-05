module brala.main;


private {
    import glamour.gl;
    import glamour.sampler : Sampler;
    import glamour.texture : Texture2D;
    import glamour.util : gl_error_string, glamour_set_error_callback = set_error_callback;
    import glwtf.glfw;
    import glwtf.window : Window;
    import glwtf.input : register_glfw_error_callback;
    import wonne.all;

    import std.conv : to;
    import std.path : buildPath, dirName, absolutePath;
    import std.zlib : ZlibException;
    import file = std.file;
    import std.string : format;
    import std.exception : enforceEx;
    import core.thread : thread_isMainThread;
    import core.time : dur;

    import brala.engine : BraLaEngine;
    import brala.game : BraLaGame;
    import brala.config : initialize_config;
    import brala.network.session : Session, DelayedSnooper, minecraft_folder;
    import brala.network.packets.types : IPacket;
    import brala.ui.ui : WebUI;
    import brala.ui.api : UIApi;
    import brala.gfx.palette : palette_atlas;
    import brala.gfx.terrain : extract_minecraft_terrain, preprocess_terrain;
    import brala.exception : InitError;
    import brala.utils.image : Image;
    import brala.utils.config : Config, Path;
    import brala.utils.debugger : is_debugged;

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
    

class BraLa {
    Config config;
    Window window;

    Session session;
    DelayedSnooper snooper;
   
    BraLaEngine engine;
    BraLaGame game;

    WebUI ui;
    UIApi ui_api;

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

        this.ui = new WebUI(config, window);
        this.ui_api = new UIApi("api", this);

        if(config.has_key!string("connection.host")) {
            session.login(config.get!string("account.username"),
                          config.get!string("account.password"));

            start_game(config.get!string("connection.host"),
                       config.get!short("connection.port"));
        } else {
            start_ui();
        }
    }

    void shutdown()
        in { assert(thread_isMainThread(), "BraLa.shutdown has to be called from main thread"); }
        body {
            ui.shutdown();
            engine.shutdown();
            snooper.stop();
        }

    void exit() {
        exit_game();
        exit_ui();
    }
        

    void initialize_context() {
        window.resizable = config.get!bool("window.resizable");

        auto cv = window.create_highest_available_context(config.get!int("window.width"),
                                                          config.get!int("window.height"),
                                                          "BraLa - Minecraft on a lower level");
        
        debug writefln("Initialized Window with context version: %s.%s", cv.major, cv.minor);

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

    void start_game(string host, short port) {
        snooper.snoop();
        
        game = new BraLaGame(engine, session, config);
        game.start(host, port);
    }

    void exit_game() {
        if(game !is null) {
            game.quit();
        }
    }

    void start_ui() {
        window.set_input_mode(GLFW_CURSOR_MODE, GLFW_CURSOR_NORMAL);
        scope(success) window.set_input_mode(GLFW_CURSOR_MODE, GLFW_CURSOR_CAPTURED);

        string entry = "login.html";

        ui.run(entry);
    }

    void exit_ui() {
        ui.stop();
    }

    bool on_close() {
        return true;
    }
}

int Main(string[] args) {
    DerelictGL3.load();
    version(DynamicGLFW) { DerelictGLFW3.load(); }

    register_glfw_error_callback(&glfw_error_cb);
    debug glamour_set_error_callback(&glamour_error_cb);

    enforceEx!InitError(glfwInit(), "glfwInit failed!");
    scope(exit) glfwTerminate();


    Config config = initialize_config();

    string exedir = (args[0].dirName().absolutePath());

    webcore.initialize(config.get!bool("ui.webcore.enable_plugins", false), // enable plugins
                       config.get!bool("ui.webcore.enable_javascript", true), // enable javascript
                       config.get!bool("ui.webcore.enable_databases", false), // enable databases
                       exedir, // package path
                       exedir, // locale path
                       "", // user-data path
                       "", // plugin path
                       exedir, // log path
                       awe_loglevel.AWE_LL_VERBOSE, // loglevel
                       false, // force single process
                       "self", // child process path (if "self", requires AWESingleProcessMain!())
                       true, // enable auto detect encoding
                       "", // accept language override
                       "", // default charset override
                       "", // user-agent override
                       config.get!string("ui.webcore.proxy_server", ""), // proxy-server
                       "", // proxy-config script
                       "", // auth-server whitelist
                       false, // save cache and cookies
                       4096, // max cache size
                       false, // disable same origin policy
                       false, // disable win-message pump
                       "body{font-size:12px}"); // custom css

    webcore.set_base_directory(config.get!Path("ui.path"));
    
    auto brala = new BraLa(config);
    scope(exit) brala.shutdown();

    webcore.update();
    webcore.shutdown();

    return 0;
}

mixin AWESingleProcessMain!(Main);