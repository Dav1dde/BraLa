module brala.log;

private {
    import std.path : dirName, absolutePath, buildPath;
    import core.runtime : Runtime;

    import brala.utils.debugger : is_debugged;
}

public import brala.utils.log;


class BraLaLogger : Logger {
    this(string name) {
        super(name, LogLevel.Debug);

        string exedir = (Runtime.args[0].dirName().absolutePath());
        string logfile = buildPath(exedir, "brala.log");
        
        IWriter w1 = new StderrWriter();
        IWriter w2 = new FileWriter(logfile);
        
        this["INFO"] = new StdoutWriter(false);
        this["FATAL"] = new MultiWriter(false, [w1, w2]);
    }
}

__gshared Logger main_logger;
__gshared Logger memory_logger;
__gshared Logger resmgr_logger;
__gshared Logger world_logger;
__gshared Logger engine_logger;
__gshared Logger game_logger;
__gshared Logger ui_logger;
__gshared Logger api_logger;
__gshared Logger session_logger;
__gshared Logger thread_logger;
__gshared Logger connection_logger;

shared static this() {
    // on linux this function relies on open file descriptors
    // so call it before we are opening FDs
    is_debugged();
    
    main_logger = new BraLaLogger("Main");
    memory_logger = new BraLaLogger("Memory");
    resmgr_logger = new BraLaLogger("Resmgr");
    world_logger = new BraLaLogger("World");
    engine_logger = new BraLaLogger("Engine");
    game_logger = new BraLaLogger("Game");
    ui_logger = new BraLaLogger("UI");
    api_logger = new BraLaLogger("API");
    session_logger = new BraLaLogger("Session");
    thread_logger = new BraLaLogger("Thread");
    connection_logger = new BraLaLogger("Connection");
}