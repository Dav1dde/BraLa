module brala.utils.thread;

private {
    import std.traits : ParameterTypeTuple, isCallable;
    import core.time : Duration;
    import core.thread : Thread;
    import core.sync.mutex : Mutex;
    import core.sync.condition : Condition;
    import core.sync.exception : SyncException;
}


class TTimer(T...) : Thread {
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

        try {
            _flag = true;
            _cond.notifyAll();
        } finally {
            _mutex.unlock();
        }
    }
    
    void clear() {
        _mutex.lock();

        try {
            _flag = false;
        } finally {
            _mutex.unlock();
        }
    }

    bool wait(T...)(T timeout) if(T.length == 0 || (T.length == 1 && is(T[0] : Duration))) {
        _mutex.lock();

        try {
            bool notified = _flag;
            if(!notified) {
                notified = _cond.wait(timeout);
            }
            return notified;
        } finally {
            _mutex.unlock();
        }
    }
}
    