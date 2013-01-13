module brala.utils.queue;

private {
    import core.time : Duration, dur;
    import core.sync.mutex : Mutex;
    import core.sync.condition : Condition;

    import std.algorithm : canFind;
}

public import brala.utils.exception : QueueException, Full, Empty;


private enum Duration DUR_0 = dur!("seconds")(0);

class Queue(type) {
    protected Mutex mutex;
    protected Condition not_empty;
    protected Condition not_full;
    protected Condition all_done;

    protected type[] queue;
    protected size_t unfinished_taks;
    protected size_t _maxsize = 0;
    @property size_t maxsize() { return _maxsize; }

    this() {
        mutex = new Mutex();
        not_empty = new Condition(mutex);
        not_full = new Condition(mutex);
        all_done = new Condition(mutex);
    
        unfinished_taks = 0;
    }

    this(size_t maxsize) {
        this();
        _maxsize = maxsize;
    }

    void put(type item, bool block=true, Duration timeout=DUR_0) {
        mutex.lock();
        scope(exit) mutex.unlock();

        if(maxsize > 0) {
            if(!block) {
                if(queue.length >= maxsize) {
                    throw new Full("full queue");
                }
            } else if(timeout.isNegative) {
                throw new QueueException("negative timeout");
            } else if(timeout.get!("seconds") == 0) {
                if(full) {
                    not_full.wait();
                }
            } else {
                if(full) {
                    if(!not_full.wait(timeout)) {
                        throw new Full("queue after timeout still full");
                    }
                }
            }
        }

        queue ~= item;
        unfinished_taks += 1;
        not_empty.notify();
    }

    type get(bool block=true, Duration timeout=DUR_0) {
        mutex.lock();
        scope(exit) mutex.unlock();

        if(!block) {
            if(queue.length == 0) {
                throw new Empty("queue is empty");
            }
        } else if(timeout.isNegative) {
            throw new QueueException("negativ timeout");
        } else if(timeout.get!("seconds") == 0) {
            if(queue.length == 0) {
                not_empty.wait();
            }
        } else {
            if(queue.length == 0) {
                if(!not_empty.wait(timeout)) {
                    throw new Empty("queue after timeout still empty");
                }
            }
        }

        type item = queue[0];
        queue = queue[1..$];
        not_full.notify();
        return item;
    }

    void task_done() {
        mutex.lock();
        scope(exit) mutex.unlock();

        size_t u = unfinished_taks - 1;
        if(u < 0) {
            throw new QueueException("task_done called too many times");
        } else if(u == 0) {
            all_done.notifyAll();
        }
        unfinished_taks = u;
    }

    void join() {
        mutex.lock();
        scope(exit) mutex.unlock();

        while(unfinished_taks > 0) {
            all_done.wait();
        }
    }

    @property bool empty() {
        mutex.lock();
        scope(exit) mutex.unlock();

        return queue.length == 0;
    }

    @property full() {
        mutex.lock();
        scope(exit) mutex.unlock();

        return (0 < maxsize) && (maxsize <= queue.length);
    }

    @property qsize() {
        mutex.lock();
        scope(exit) mutex.unlock();

        return queue.length;
    }

    int opApply(int delegate(type item) dg) {
        int result;

        while(!empty) {
            try {
                result = dg(get(false));
            } catch(Empty) { // should not be the case, but it's possible
                return result;
            }
            task_done();
            if(result) break;
        }

        return result;
    }

    bool opBinaryRight(string s : "in")(type item) {
        mutex.lock();
        scope(exit) mutex.unlock();

        return queue.canFind(item);
    }
}

unittest {
    import std.exception : assertThrown;

    alias Queue!int Q;
    Q q = new Q(10);

    assertThrown!Empty(q.get(false));

    q.put(0, true);
    q.put(1, true);
    assert(q.qsize == 2);
    assert(q.get(false) == 0);
    assert(!q.empty);
    assert(!q.full);
    assert(q.qsize == 1);
    assert(q.get(false) == 1);
    assert(q.empty);
    assert(!q.full);
    assert(q.qsize == 0);

    foreach(i; 0..10) {
        q.put(i, true, dur!("seconds")(1));
        assert(q.qsize == i+1);
    }

    //assertThrown!Full(q.put(11, true, dur!("seconds")(1)));
    assert(q.full);
    assert(!q.empty);
    assert(q.qsize == 10);
    assertThrown!Full(q.put(11, false));

}
