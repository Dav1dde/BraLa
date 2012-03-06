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