module brala.utils.log;

private {
    import std.string : toLower, format;
    import std.range : retro;
    import std.stdio : File, stdout, stderr;
    import std.exception : enforceEx;
    import std.datetime : Clock;

    import brala.utils.exception : LoggerException;
}


enum LogLevel {
    Debug = 0,
    Info = 1,
    Warn = 2,
    Error = 3,
    Fatal = 4
}

alias LogLevel.Debug Debug;
alias LogLevel.Info Info;
alias LogLevel.Warn Warn;
alias LogLevel.Error Error_;
alias LogLevel.Fatal Fatal;


LogLevel string2loglevel(string inp) {
    string ll = inp.toLower();

    switch(ll) {
        case "debug": return LogLevel.Debug;
        case "info": return LogLevel.Info;
        case "warn": return LogLevel.Warn;
        case "error": return LogLevel.Error;
        case "fatal": return LogLevel.Fatal;
        default: throw new LoggerException(`"%s" is not a valid loglevel`.format(inp));
    }
}

template cstring2loglevel(string l) {
    enum cstring2loglevel = string2loglevel(l);
}

unittest {
    assert(cstring2loglevel!("deBug") == LogLevel.Debug);
    assert(cstring2loglevel!("Info") == LogLevel.Info);
    assert(cstring2loglevel!("warN") == LogLevel.Warn);
    assert(cstring2loglevel!("errOr") == LogLevel.Error);
    assert(cstring2loglevel!("fatal") == LogLevel.Fatal);
}

string loglevel2string(LogLevel inp) {
    static immutable string[] levels = ["DEBUG", "INFO", "WARN", "ERROR", "FATAL"];
    return levels[inp];
}

template cloglevel2string(LogLevel inp) {
    enum cloglevel2string = loglevel2string(inp);
}


interface IWriter {
    void log(LogLevel level, string name, string message);
    @property bool bubbles();
    @property void bubbles(bool);
}

mixin template Bubbler() {
    protected bool _bubbles = false;
    override bool bubbles() { return _bubbles; }
    override void bubbles(bool b) { _bubbles = b; }
}


class NullWriter : IWriter {
    override void log(LogLevel level, string name, string message) {}
    override @property bool bubbles() { return false; }
    override @property void bubbles(bool b) {};
}

class BubbleWriter : NullWriter {
    override @property bool bubbles() { return true; }
}

class MultiWriter : IWriter {
    IWriter[] children;

    mixin Bubbler!();

    this(IWriter[] writer...) {
        this.children = writer;
    }

    this(bool bubbles, IWriter[] writer...) {
        this(writer);
        _bubbles = bubbles;
    }

    static opCall(Args...)(Args args) {
        return new MultiWriter(args);
    }

    override void log(LogLevel level, string name, string message) {
        foreach(child; children) {
            if(child !is null) {
                child.log(level, name, message);
            }
        }
    }
}

class FileWriter : IWriter {
    protected static File[string] _files;
    
    protected File file;

    mixin Bubbler!();

    this(File file, bool bubbles = false) {
        enforceEx!LoggerException(file.isOpen, "file not open");
        file.rawWrite(""); // check if we can write to file
        
        this.file = file;
        _bubbles = bubbles;
    }

    this(string path, bool bubbles = false) {
        file = File(path, "w");
        _bubbles = bubbles;
        _files[path] = file;
    }

    static FileWriter opCall(string name, bool bubbles = false) {
        if(auto f = name in _files) {
            return new FileWriter(*f, bubbles);
        }

        return new FileWriter(name, bubbles);
    }

    static FileWriter opCall(File file, bool bubbles = false) {
        return new FileWriter(file, bubbles);
    }

    override void log(LogLevel level, string name, string message) {
        string slevel = loglevel2string(level);

        auto time = Clock.currTime().toString();

        file.writefln("[%-28s] %s: %s: %s", time, slevel, name, message);
        file.flush();
    }
}

private __gshared FileWriter _StdoutWriter;
private __gshared FileWriter _StderrWriter;

static this() {
    _StdoutWriter = new FileWriter(stdout);
    _StderrWriter = new FileWriter(stderr);
}

private class _OutWriter(string fname) : IWriter {
    mixin Bubbler!();

    this(bool bubbles = false) {
        _bubbles = bubbles;
    }

    static typeof(this) opCall(bool bubbles = false) {
        return new typeof(this)(bubbles);
    }

    override void log(LogLevel level, string name, string message) {
        mixin(fname).log(level, name, message);
    }
}

alias _OutWriter!("_StdoutWriter") StdoutWriter;
alias _OutWriter!("_StderrWriter") StderrWriter;


class Logger {
    protected static Logger[string] _logger;
    
    immutable string name;

    IWriter[LogLevel.max+1] writer;
    LogLevel loglevel = LogLevel.Debug;

    this(string name, LogLevel loglevel = LogLevel.Debug) {
        enforceEx!LoggerException(name !in _logger, `There is already a logger named "%s"`.format(name));
        
        this.name = name;
        this.loglevel = loglevel;

        _logger[name] = this;
    }

    static Logger existing(string name) {
        enforceEx!LoggerException(name in _logger, `There is no logger named "%s"`.format(name));

        return _logger[name];
    }

    static Logger if_exists(string name, LogLevel loglevel = LogLevel.Debug) {
        if(auto l = name in _logger) {
            return *l;
        }

        return new Logger(name, loglevel);
    }

    void log(string level, Args...)(auto ref Args args) if(__traits(compiles, cstring2loglevel!(level))) {
        log!(cstring2loglevel!(level))(args);
    }

    void log(LogLevel level, Args...)(auto ref Args args) {
        if(level < this.loglevel) {
            return;
        }

        IWriter[] wr = this.writer[this.loglevel..$];
        
        string message = format(args);

        foreach(w; wr) {
            if(w is null) {
                continue;
            }
            
            w.log(level, name, message);

            if(w.bubbles) {
                continue;
            }
            break;
        }
    }

    void opIndexAssign(IWriter writer, string level) {
        opIndexAssign(writer, string2loglevel(level));
    }

    void opIndexAssign(IWriter writer, LogLevel level) {
        this.writer[level] = writer;
    }
}