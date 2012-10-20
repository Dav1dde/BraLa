module brala.utils.memory;

private {
    import clib = std.c.stdlib;
    import std.string : format;

    import std.traits : isArray;
    import std.range : ElementType;
    import std.stdio : writefln;

    import brala.exception : AllocationError;

    debug import brala.utils.stdio : writef;
}


struct MemoryCounter {
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


void* malloc(size_t size) {
    debug writef("(m)allocating %d bytes. ", size);

    void* ptr = clib.malloc(size);

    debug writefln("Pointer: 0x%08x.", ptr);

    if(ptr is null) {
        throw new AllocationError(format("Unable to allocate memory with malloc(%d) (out of memory?).", size));
    }

    return ptr;
}

void* calloc(size_t num, size_t size) {
    debug writef("(c)allocating %d times %d bytes. ", num, size);

    void* ptr = clib.calloc(num, size);

    debug writefln("Pointer: 0x%08x.", ptr);

    if(ptr is null) {
        throw new AllocationError(format("Unable to allocate memory with calloc(%d, %d) (out of memory?).", num, size));
    }

    return ptr;
}

void* realloc(void* ptr, size_t size) {
    debug writef("(re)allocating pointer 0x%08x to %d bytes. ", ptr, size);

    void* ret_ptr = clib.realloc(ptr, size);

    debug writefln("Pointer: 0x%08x.", ret_ptr);

    if(ptr is null) {
        throw new AllocationError(format("Unable to reallocate memory (realloc(ptr, %d)) (out of memory?).", size));
    }

    return ret_ptr;
}

void free(void* ptr) {
    debug writefln("Freeing 0x%08x.", ptr);

    clib.free(ptr);
}