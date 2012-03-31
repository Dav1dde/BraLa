module brala.utils.alloc;

private {
    import clib = std.c.stdlib;
    import std.string : format;

    import brala.exception : AllocationError;

    debug import std.stdio : writef, writefln;
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