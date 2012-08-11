module brala.dine.util;

private {
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

int py_div(int a, int b) {
    return a < 0 ? (a - (b-1)) / b : a / b;
}

int py_mod(int a, int b) {
    return cast(uint)a % b;
}