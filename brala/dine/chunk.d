module brala.dine.chunk;

private {
    import std.bitmanip;
}


struct Block {
    ubyte id;
    
    mixin(bitfields!(uint, "metadata", 4,
                     uint, "block_light", 4,
                     uint, "sky_light", 4,
                     uint, "", 4)); 
}