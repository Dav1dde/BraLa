module brala.utils.queue;

private {
    import core.time : Duration, dur;
    import core.sync.mutex : Mutex;
    import core.sync.condition : Condition;

    import std.datetime : Clock;
    import std.algorithm : canFind;
    import std.exception : enforceEx;
}

public import brala.utils.exception : QueueException, Full, Empty;

// gdc bug?
private enum DUR_0 = Duration.init;

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

        enforceEx!QueueException(!timeout.isNegative, "negative timeout");
        if(full) {
            enforceEx!Full(block, "full queue");

            if(timeout.total!"msecs" == 0) {
                not_full.wait();
            } else {
                auto cur = Clock.currTime();
                while(full) {
                    auto remaining = Clock.currTime() - cur;
                    enforceEx!Full(remaining.total!"msecs" > 0, "full queue");
                    not_full.wait(remaining);
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

        return get_no_lock(block, timeout);
    }


    protected type get_no_lock(bool block=true, Duration timeout=DUR_0) {
        enforceEx!QueueException(!timeout.isNegative, "negative timeout");
        if(empty) {
            enforceEx!Empty(block, "empty queue");

            if(timeout.total!"msecs" == 0) {
                not_empty.wait();
            } else {
                auto cur = Clock.currTime();
                while(empty) {
                    auto remaining = Clock.currTime() - cur;
                    enforceEx!Empty(remaining.total!"msecs" > 0, "full queue");
                    not_empty.wait(remaining);
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

    // This blocks the queue until you finished processing all items!
    int opApply(int delegate(type item) dg) {
        mutex.lock();
        scope(exit) mutex.unlock();

        int result;

        while(queue.length > 0) {
            type item = get_no_lock(false);
            scope(exit) task_done();

            result = dg(item);
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
