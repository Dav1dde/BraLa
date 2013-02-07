module brala.log;

private {
    import std.path : dirName, absolutePath, buildPath;
    import core.runtime : Runtime;
}

public import brala.utils.log;


class BraLaLogger : Logger {
    this(string name, LogLevel loglevel = DEFAULT_LOGLEVEL) {
        super(name, loglevel);

        string exedir = (Runtime.args[0].dirName().absolutePath());
        string logfile = buildPath(exedir, "brala.log");
        
        this["INFO"] = StdoutWriter(false);
        this["FATAL"] = MultiWriter(false,
            StderrWriter(),
            FileWriter(logfile)
        );
    }
}