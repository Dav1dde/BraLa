module brala.utils.log;

private {
    import std.string : sformat, format, icmp, leftJustify;
    import std.range : retro;
    import std.stdio : File, stdout, stderr;
    import std.exception : enforceEx;
    import std.datetime : Clock;
    import std.array : replace;
    import core.exception : InvalidMemoryOperationError;

    import clib = std.c.stdlib;

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


    if(inp.icmp("debug") == 0) {
        return LogLevel.Debug;
    } else if(inp.icmp("info") == 0) {
        return LogLevel.Info;
    } else if(inp.icmp("warn") == 0) {
        return LogLevel.Warn;
    } else if(inp.icmp("error") == 0) {
        return LogLevel.Error;
    } else if(inp.icmp("fatal") == 0) {
        return LogLevel.Fatal;
    }

    assert(false);
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
    void log(LogLevel level, string name, const(char)[] message);
    @property bool bubbles();
    @property void bubbles(bool);
}

mixin template Bubbler() {
    protected bool _bubbles = false;
    override bool bubbles() { return _bubbles; }
    override void bubbles(bool b) { _bubbles = b; }
}


class NullWriter : IWriter {
    override void log(LogLevel level, string name, const(char)[] message) {}
    override @property bool bubbles() { return false; }
    override @property void bubbles(bool b) {};
}

class BubbleWriter : NullWriter {
    override @property bool bubbles() { return true; }
}

class MultiWriter : IWriter {
    IWriter[] children;

    mixin Bubbler!();

    this(IWriter[] writer) {
        this.children = writer;
    }

    this(bool bubbles, IWriter[] writer) {
        this(writer);
        _bubbles = bubbles;
    }
    
    override void log(LogLevel level, string name, const(char)[] message) {
        foreach(child; children) {
            if(child !is null) {
                child.log(level, name, message);
            }
        }
    }
}

class FileWriter : IWriter {
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
    }

    override void log(LogLevel level, string name, const(char)[] message) {
        string slevel = loglevel2string(level);

        auto time = Clock.currTime();

        size_t whitespaces = 15;
        whitespaces += name.length + 2; // +1 trailing colon and whitespace
        whitespaces += slevel.length + 2;

        file.writefln("[%02s:%02s:%02s.%03s] %s: %s: %s",
                      time.hour, time.minute, time.second, time.fracSec.msecs,
                      name, slevel, message.replace("\n", "\n".leftJustify(whitespaces+1)));
        file.flush();
    }
}

private __gshared FileWriter _StdoutWriter;
private __gshared FileWriter _StderrWriter;

shared static this() {
    _StdoutWriter = new FileWriter(stdout);
    _StderrWriter = new FileWriter(stderr);
}

private class _OutWriter(string fname) : IWriter {
    mixin Bubbler!();

    this(bool bubbles = false) {
        _bubbles = bubbles;
    }

    override void log(LogLevel level, string name, const(char)[] message) {
        mixin(fname).log(level, name, message);
    }
}

alias _OutWriter!("_StdoutWriter") StdoutWriter;
alias _OutWriter!("_StderrWriter") StderrWriter;

alias NamedLogger = Logger.NamedLogger;

class Logger {
    protected NamedLogger[string] _logger;
    
    IWriter[LogLevel.max+1] writer;
    LogLevel loglevel = LogLevel.Debug;

    protected void* format_buffer;

    this(LogLevel loglevel = LogLevel.Debug) {
        this.loglevel = loglevel;

        _logger["default"] = new NamedLogger("default");
    }

    class NamedLogger {
        immutable string name;

        this(string name) {
            this.name = name;
        }

        void log(string level, Args...)(auto ref Args args) if(__traits(compiles, cstring2loglevel!(level))) {
            log!(cstring2loglevel!(level))(args);
        }

        void log(LogLevel level, Args...)(auto ref Args args) {
            if(level < this.outer.loglevel) {
                return;
            }

            IWriter[] wr = this.outer.writer[level..$];

            const(char)[] message;
            try {
                message = format(args);
            } catch(InvalidMemoryOperationError) {
                stderr.writef("NOT LOGGED: ");
                stderr.writefln(args);
                stderr.flush();
                return;
            }

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
    }

    NamedLogger get(string name) {
        if(auto l = name in _logger) {
            return *l;
        }

        auto logger = new NamedLogger(name);
        _logger[name] = logger;
        return logger;
    }

    void log(string level, Args...)(auto ref Args args) if(__traits(compiles, cstring2loglevel!(level))) {
        log!(cstring2loglevel!(level))(args);
    }

    void log(LogLevel level, Args...)(auto ref Args args) {
        _logger["default"].log!(level)(args);
    }


    void opIndexAssign(IWriter writer, string level) {
        opIndexAssign(writer, string2loglevel(level));
    }

    void opIndexAssign(IWriter writer, LogLevel level) {
        this.writer[level] = writer;
    }
}