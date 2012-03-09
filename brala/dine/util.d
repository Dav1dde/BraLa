module brala.dine.util;

private {
    import clib = std.c.stdlib;
    import std.string : format;

    import gl3n.linalg : vec3;
    import gl3n.util : is_vector;
    
    import brala.exception : AllocationError;
}

void* malloc(size_t size) {
    void* ptr = clib.malloc(size);
    
    if(ptr is null) {
        throw new AllocationError(format("Unable to allocate memory with malloc(%d) (out of memory?).", size));
    }
    
    return ptr;
}

void* calloc(size_t num, size_t size) {
    void* ptr = clib.calloc(num, size);
    
    if(ptr is null) {
        throw new AllocationError(format("Unable to allocate memory with calloc(%d, %d) (out of memory?).", num, size));
    }
    
    return ptr;
}

alias clib.free free;

uint log2_ub(uint v) { // unrolled bitwise log2
    uint r = 0;
    
    if(v > 0xffff) {
        v >>= 16;
        r = 16;
    }
    if(v > 0x00ff) {
        v >>= 8;
        r += 8;
    }
    if(v > 0x000f) {
        v >>= 4;
        r += 4;
    }
    if(v > 0x0003) {
        v >>= 2;
        r += 2;
    }
    
    return r + (v >> 1);
}

T[6] to_triangles(T)(T[4] quad) if(is_vector!T) {
    return [quad[0], quad[1], quad[2],
            quad[0], quad[2], quad[3]];
}

T.vt[] raw_vectors(T)(T[] vecs) if(is_vector!T) {
    T.vt[] ret;
    foreach(vec; vecs) {
        ret ~= vec.vector;
    }
    return ret;
}