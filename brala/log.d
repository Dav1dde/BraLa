module brala.log;

private {
    import std.path : dirName, absolutePath, buildPath;
    import core.runtime : Runtime;
}

public import brala.utils.log;


class BraLaLogger : Logger {
    this(string name) {
        super(name, LogLevel.Debug);

        string exedir = (Runtime.args[0].dirName().absolutePath());
        string logfile = buildPath(exedir, "brala.log");
        
        this["INFO"] = new StdoutWriter(false);
//         this["FATAL"] = MultiWriter(false,
//             new StderrWriter(),
//             new FileWriter(logfile)
//         );
        this["FATAL"] = new StdoutWriter(false);

    }
}

mixin template MakeBraLaLogger(string name) {
    __gshared Logger logger;

    shared static this() {
        logger = new BraLaLogger(name);
    }
}