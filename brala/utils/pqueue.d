module brala.utils.pqueue;

private {
    import core.time : Duration, dur;
    import core.sync.mutex : Mutex;
    import core.sync.condition : Condition;

    import std.datetime : Clock;
    import std.exception : enforceEx;

    import brala.utils.exception : QueueException, Full, Empty;
}

private enum DUR_0 = Duration.init;

class PsuedoQueue(type) {
    protected type[] storage;
    protected size_t realloc_interval = 32;
    protected size_t start = 0;
    protected size_t end = 0;

    protected size_t unfinished_taks = 0;

    protected size_t _maxsize = 0;
    @property size_t maxsize() { return _maxsize; }

    protected Mutex mutex;
    protected Condition not_empty;
    protected Condition not_full;
    protected Condition all_done;

    this(size_t maxsize = 0, size_t realloc_interval = 0) {
        _maxsize = maxsize;

        if(realloc_interval == 0) realloc_interval = 32;
        this.realloc_interval = realloc_interval;

        storage.length = realloc_interval < maxsize ? realloc_interval+1 : maxsize;

        this.mutex = new Mutex();
        this.not_empty = new Condition(mutex);
        this.not_full = new Condition(mutex);
        this.all_done = new Condition(mutex);
    }

    void put(type item, bool block=false, Duration timeout=DUR_0) {
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

        if(start == 0 && end == storage.length) {
            storage.length += realloc_interval;
        }

        if(start > 0) {
            storage[start--] = item;
        } else {
            storage[end++] = item;
        }
        unfinished_taks += 1;
        not_empty.notify();
    }

    type get(bool block=false, Duration timeout=DUR_0) {
        mutex.lock();
        scope(exit) mutex.unlock();

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

        scope(success) not_full.notify();
        return storage[start++];
    }

    type[] get_all() {
        mutex.lock();
        scope(exit) mutex.unlock();
        scope(success) {
            end = 0;
            start = 0;
            not_full.notifyAll();
        }

        return storage[start..end].dup;
    }

    void task_done() {
        mutex.lock();
        scope(exit) mutex.unlock();

        size_t u = unfinished_taks - 1;
        enforceEx!QueueException(u >= 0, "task_done called too often");
        if(u == 0) all_done.notifyAll();
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
        return start == end;
    }

    @property bool full() {
        return _maxsize > 0 && _maxsize == end && start == 0;
    }

    @property size_t length() {
        return end-start;
    }
}

unittest {
    import std.exception : assertThrown;

    alias PsuedoQueue!int Q;
    Q q = new Q(10, 5);

    assertThrown!Empty(q.get());

    q.put(0);
    q.put(1);
    assert(q.length == 2);
    assert(q.get() == 0);
    assert(!q.empty);
    assert(!q.full);
    assert(q.length == 1);
    assert(q.get() == 1);
    assert(q.empty);
    assert(!q.full);
    assert(q.length == 0);

    foreach(i; 0..10) {
        q.put(i);
        assert(q.length == i+1);
    }

    //assertThrown!Full(q.put(11, true, dur!("seconds")(1)));
    assert(q.full);
    assert(!q.empty);
    assert(q.length == 10);
    assertThrown!Full(q.put(11));

    auto a = q.get_all();
    assert(a.length == 10);
    assert(q.length == 0);

    alias PsuedoQueue!Object Q2;

    Q2 q2 = new Q2(10, 1);

    foreach(i; 0..9) {
        q2.put(new Object());
    }
    assert(!q2.empty);

    foreach(i; 0..q2.length) {
        assert(q2.get() !is null);
    }
    assert(q2.empty);
}