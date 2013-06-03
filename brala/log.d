module brala.log;

private {
    import std.path : dirName, absolutePath, buildPath;
    import core.runtime : Runtime;

    import brala.utils.debugger : is_debugged;
}

public import brala.utils.log;


class BraLaLogger : Logger {
    this() {
        super(LogLevel.Debug);

        string exedir = (Runtime.args[0].dirName().absolutePath());
        string logfile = buildPath(exedir, "brala.log");
        
        IWriter w1 = new StderrWriter();
        IWriter w2 = new FileWriter(logfile);
        
        this["INFO"] = new StdoutWriter(false);
        this["FATAL"] = new MultiWriter(false, [w1, w2]);
    }
}


__gshared Logger brala_logger;
__gshared NamedLogger main_logger;
__gshared NamedLogger memory_logger;
__gshared NamedLogger resmgr_logger;
__gshared NamedLogger world_logger;
__gshared NamedLogger engine_logger;
__gshared NamedLogger game_logger;
__gshared NamedLogger ui_logger;
__gshared NamedLogger api_logger;
__gshared NamedLogger session_logger;
__gshared NamedLogger thread_logger;
__gshared NamedLogger connection_logger;
__gshared NamedLogger terrain_logger;

shared static this() {
    // on linux this function relies on open file descriptors
    // so call it before we are opening FDs
    is_debugged();

    brala_logger = new BraLaLogger();

    main_logger = brala_logger.get("Main");
    memory_logger = brala_logger.get("Memory");
    resmgr_logger = brala_logger.get("Resmgr");
    world_logger = brala_logger.get("World");
    engine_logger = brala_logger.get("Engine");
    game_logger = brala_logger.get("Game");
    ui_logger = brala_logger.get("UI");
    api_logger = brala_logger.get("API");
    session_logger = brala_logger.get("Session");
    thread_logger = brala_logger.get("Thread");
    connection_logger = brala_logger.get("Connection");
    terrain_logger = brala_logger.get("Terrain");
}