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

    protected Duration interval;
    protected Args args;
    protected void delegate(Args) func;

    protected Event finished;
    @property bool is_finished() { return finished.is_set; }
    
    this(Duration interval, void delegate(Args) func, Args args) {
        super(&run);

        finished = new Event();
        
        this.interval = interval;
        this.func = func;

        static if(Args.length) {
            this.args = args;
        }
    }

    final
    void cancel() {
        finished.set();
    }
    
    protected
    void run() {
        finished.wait(interval);

        if(!finished.is_set) {
            func(args);
        }

        finished.set();
    }
                
}

alias TTimer!() Timer;


class Event {
    protected Mutex mutex;
    protected Condition cond;

    protected bool flag;
    @property bool is_set() { return flag; }
    
    this() {
        mutex = new Mutex();
        cond = new Condition(mutex);

        flag = false;
    }

    void set() {
        mutex.lock();
        scope(exit) mutex.unlock();

        flag = true;
        cond.notifyAll();
    }
    
    void clear() {
        mutex.lock();
        scope(exit) mutex.unlock();

        flag = false;
    }

    bool wait(T...)(T timeout) if(T.length == 0 || (T.length == 1 && is(T[0] : Duration))) {
        mutex.lock();
        scope(exit) mutex.unlock();

        bool notified = flag;
        if(!notified) {
            static if(T.length == 0) {
                cond.wait();
                notified = true;
            } else {
                notified = cond.wait(timeout);
            }
        }
        return notified;
    }
}