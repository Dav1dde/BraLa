module brala.utils.queue;

private {
    import std.array : empty, front, back, popFront, popBack, save;
}

class Queue(type) {
    protected Object _lock;

    type[] data;

    this() {
        _lock = new Object();
    }

    this(type[] data) {
        _lock = new Object();
        this.data = data;
    }

    void put(type d) {
        synchronized(_lock) data ~= d;
    }

    @property bool empty() {
        return data.empty;
    }

    void popFront() {
        synchronized(_lock) {
            data.popFront();
        }
    }

    void popBack() {
        synchronized(_lock) {
            data.popBack();
        }
    }
    type front() {
        return data.front;
    }

    type back() {
        return data.back;
    }

    @property Queue save() {
        synchronized(_lock) {
             return new Queue(data.save);
        }
    }
}