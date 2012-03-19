module brala.dine.util;

private {
    import clib = std.c.stdlib;
    import std.string : format;

    import gl3n.linalg : vec3;
    import gl3n.util : is_vector;
    
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

T[6] to_triangles(T)(T[4] quad) {
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

// this is made for tessellate function
template apply_offset(string data) {
    enum apply_offset = 
           "size_t data_length = " ~ data ~ ".length;" ~
           "float* data_ptr = " ~ data ~ ".ptr;" ~
           "memcpy(v+w, data_ptr, data_length*float.sizeof);" ~
       q{
            for(; w < w+data_length; w = w+5) {
                v[w++] += x_offset;
                v[w++] += y_offset;
                v[w++] += z_offset;
            }
        };
}