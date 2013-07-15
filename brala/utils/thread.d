module brala.utils.thread;

private {
    import std.traits : ParameterTypeTuple, isCallable;
    import std.string : format;
    import core.time : Duration;
    import core.sync.mutex : Mutex;
    import core.sync.condition : Condition;
    import core.sync.exception : SyncException;

    import std.stdio : stderr;
    
    version(BraLa) {
        import brala.log : logger = thread_logger;
        import brala.utils.log;
    }
}

public import core.thread;


private enum CATCH_DELEGATE = `
    delegate void() {
        try {
            fun();
        } catch(Throwable t) {
            version(BraLa) {
                logger.log_exception(t, "in Thread: \"%s\"".format(this.name));
            } else {
                stderr.writefln("--- Exception in Thread: \"%s\" ---".format(this.name));
                stderr.writeln(t.toString());
                stderr.writefln("--- End Exception in Thread \"%s\" ---".format(this.name));
            }
            
            throw t;
        }
    }
`;
    
class VerboseThread : Thread {
    this(void function() fun, size_t sz = 0) {
        super(mixin(CATCH_DELEGATE), sz);
    }

    this(void delegate() fun, size_t sz = 0) {
        super(mixin(CATCH_DELEGATE), sz);
    }
}

class TTimer(T...) : VerboseThread {
    static assert(T.length <= 1);
    static if(T.length == 1) {
        static assert(isCallable!(T[0]));
        alias ParameterTypeTuple!(T[0]) Args;
    } else {
        alias T Args;
    }

    Duration interval;
    Args args;
    void delegate(Args) func;

    protected Event _finished;
    @property bool is_finished() { return _finished.is_set; }
    
    this(Duration interval, void delegate(Args) func, Args args) {
        super(&run);

        _finished = new Event();
        
        this.interval = interval;
        this.func = func;

        static if(Args.length) {
            this.args = args;
        }
    }

    void cancel() {
        _finished.set();
    }
    
    private void run() {
        _finished.wait(interval);

        if(!_finished.is_set) {
            func(args);
        }

        _finished.set();
    }
                
}

alias TTimer!() Timer;


class Event {
    protected Mutex _mutex;
    protected Condition _cond;

    protected bool _flag;
    @property bool is_set() { return _flag; }
    
    this() {
        _mutex = new Mutex();
        _cond = new Condition(_mutex);

        _flag = false;
    }

    void set() {
        _mutex.lock();
        scope(exit) _mutex.unlock();

        _flag = true;
        _cond.notifyAll();
    }
    
    void clear() {
        _mutex.lock();
        scope(exit) _mutex.unlock();

        _flag = false;
    }

    bool wait(T...)(T timeout) if(T.length == 0 || (T.length == 1 && is(T[0] : Duration))) {
        _mutex.lock();
        scope(exit) _mutex.unlock();

        bool notified = _flag;
        if(!notified) {
            static if(T.length == 0) {
                _cond.wait();
                notified = true;
            } else {
                notified = _cond.wait(timeout);
            }
        }
        return notified;
    }
}
    