module brala.utils.queue;

private {
    import std.array : empty, front, back, popFront, popBack, save;
    import std.range /+: RefRange, refRange+/;
    
    import brala.network.packets.types : IPacket;
}

struct Queue(type) {
    protected Object _lock;

    type[] data;

    @disable this();

    static Queue opCall() {
        return Queue([]);
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
             return Queue(data.save);
        }
    }
}

struct RefQueue(type) {
    alias Queue!type Q;
    private Q* _queue;

    @disable this();

    static RefQueue opCall() {
        return RefQueue([]);
    }

    this(type[] data) {
        auto q = Q(data);
        _queue = &q;
    }

    this(Q* q) {
        _queue = q;
    }

    void put(type d) { return (*_queue).put(d); }
    @property bool empty() { return (*_queue).empty; }
    void popFront() { return (*_queue).popFront(); }
    void popBack() { return (*_queue).popBack(); }
    type front() { return (*_queue).front; }
    type back() { return (*_queue).back; }
}

alias RefQueue!(IPacket) PacketQueue;
