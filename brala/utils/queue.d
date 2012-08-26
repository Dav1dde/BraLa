module brala.utils.queue;

private {
    import core.time : Duration, dur;
    import core.sync.mutex : Mutex;
    import core.sync.condition : Condition;
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
    protected size_t maxsize = 0;

    this() {
        mutex = new Mutex();
        not_empty = new Condition(mutex);
        not_full = new Condition(mutex);
        all_done = new Condition(mutex);
    
        unfinished_taks = 0;
    }

    this(size_t maxsize) {
        this();
        maxsize = maxsize;
    }

    void put(type item, bool block=false, Duration timeout=DUR_0) {
        mutex.lock();
        scope(exit) mutex.unlock();

        if(maxsize > 0) {
            if(!block) {
                if(queue.length >= maxsize) {
                    throw new Full("full queue");
                }
            } else if(timeout.get!("seconds") < 0) {
                throw new QueueException("negativ timeout");
            } else if(timeout.get!("seconds") == 0) {
                not_full.wait();
            } else {
                not_full.wait(timeout);
            }
        }

        queue ~= item;
        unfinished_taks += 1;
        not_empty.notify();
    }

    type get(bool block=false, Duration timeout=DUR_0) {
        mutex.lock();
        scope(exit) mutex.unlock();

        if(!block) {
            if(queue.length == 0) {
                throw new Empty("queue is empty");
            }
        } else if(timeout.get!("seconds") < 0) {
            throw new QueueException("negativ timeout");
        } else if(timeout.get!("seconds") == 0) {
            not_empty.wait();
        } else {
            not_empty.wait(timeout);
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
            throw new QueueException("task_done called to many times");
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

        return (0 < maxsize) && (maxsize > queue.length);
    }

    int opApply(int delegate(type item) dg) {
        int result;

        while(!empty) {
            result = dg(get(false));
            task_done();
            if(result) break;
        }

        return result;
    }
}