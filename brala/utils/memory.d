module brala.utils.memory;

private {
    import clib = std.c.stdlib;
    import std.string : format;

    import std.traits : isArray;
    import std.range : ElementType;
    import std.stdio : writefln;

    import brala.log : logger = memory_logger;
    import brala.utils.log;
    import brala.exception : AllocationError;

    debug import std.stdio : writef;
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


void* malloc(size_t size, string file=__FILE__, uint line=__LINE__) {
    void* ptr = clib.malloc(size);
    
    logger.log!Debug("(m)allocated %d bytes. Pointer: 0x%08x. %s:%s", size, ptr, file, line);

    if(ptr is null) {
        throw new AllocationError(format("Unable to allocate memory with malloc(%d) (out of memory?).", size));
    }

    return ptr;
}

void* calloc(size_t num, size_t size, string file=__FILE__, uint line=__LINE__) {
    void* ptr = clib.calloc(num, size);

    logger.log!Debug("(c)allocated %d times %d bytes. Pointer: 0x%08x. %s:%s", num, size, ptr, file, line);

    if(ptr is null) {
        throw new AllocationError(format("Unable to allocate memory with calloc(%d, %d) (out of memory?).", num, size));
    }

    return ptr;
}

void* realloc(void* ptr, size_t size, string file=__FILE__, uint line=__LINE__) {
    void* ret_ptr = clib.realloc(ptr, size);

    logger.log!Debug("(re)allocated pointer 0x%08x to %d bytes. Pointer: 0x%08x. %s:%s", ptr, size, ret_ptr, file, line);

    if(ptr is null) {
        throw new AllocationError(format("Unable to reallocate memory (realloc(ptr, %d)) (out of memory?).", size));
    }

    return ret_ptr;
}

void free(void* ptr, string file=__FILE__, uint line=__LINE__) {
    logger.log!Debug("Freeing 0x%08x. %s:%s", ptr, file, line);

    clib.free(ptr);
}