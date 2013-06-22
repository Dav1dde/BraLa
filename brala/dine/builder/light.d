module brala.dine.builder.light;

private {
    import std.algorithm : canFind;

    import brala.utils.ctfe : TupleRange;
}



enum LIGHTS = [
//     10, // lava, directional?
//     11, // lava, directional?
    50, // torch
    51, // fire
//     55, // redstone
    62, // burning furnace
    74, // glowing redstone ore
    76, // redstone torch
    94, // redstone repeater on
    124, // lamp
    150, // comparator on
    152, // redstone block
];


@property
bool is_light(uint id) {
    assert(id <= ubyte.max);

    final switch(id) {
        foreach(i; TupleRange!(0, ubyte.max+1)) {
            case i:
                enum is_light = LIGHTS.canFind(i);
                return is_light;
        }
    }

    return false;
}