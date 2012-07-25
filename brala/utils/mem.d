module brala.utils.mem;

private {
    import std.traits : isArray;
    import std.range : ElementType;
    import std.stdio : writefln;
}


struct MemCounter {
    string name;
    private size_t _usage = 0;
    private size_t _allocations = 0;

    @property size_t usage() { return _usage; }
    @property size_t allocations() { return _allocations; }

    this(string name) {
        this.name = name;
    }
    
    void add()(size_t size) {
        _usage += size;
        _allocations++;
    }

    void add(T)(const ref T data) if(isArray!T) {
        add((ElementType!T).sizeof*data.length);
    }
    
    void remove(size_t size) {
        _usage -= size;
        _allocations--;
    }

    void adjust(sizediff_t diff) {
        _usage += diff;
    }

    void print() {
        if(name.length) {
            writefln("Memory Usage (%s): %d\tAllocations: %d", name, _usage, _allocations);
        } else {
            writefln("Memory Usage: %d\tAllocations: %d", _usage, _allocations);
        }
    }
}