module brala.dine.builder.vertices_.blocks;

private {
    import std.math : abs;
    
    import brala.dine.builder.tessellator : Vertex;
    import brala.dine.builder.vertices : CubeSideData;
    import brala.dine.builder.vertices_.util;
}


struct TextureSlice {
    byte x;
    byte y;

    alias texcoords this;

    this(byte lower_left_x, byte lower_left_y)
        in { assert(abs(lower_left_x*2) <= byte.max && abs(lower_left_y*2) <= byte.max); }
        body {
            x = cast(byte)(lower_left_x*2+1);
            y = cast(byte)(lower_left_y*2-1);
        }

    pure:
    @property byte[2][4] texcoords() {
        return [[cast(byte)(x-1), cast(byte)(y+1)],
                [cast(byte)(x+1), cast(byte)(y+1)],
                [cast(byte)(x+1), cast(byte)(y-1)],
                [cast(byte)(x-1), cast(byte)(y-1)]];
    }

    @property byte[2][4] texcoords_90() {
        return [[cast(byte)(x+1), cast(byte)(y+1)],
                [cast(byte)(x+1), cast(byte)(y-1)],
                [cast(byte)(x-1), cast(byte)(y-1)],
                [cast(byte)(x-1), cast(byte)(y+1)]];
    }

    @property byte[2][4] texcoords_180() {
        return [[cast(byte)(x+1), cast(byte)(y-1)],
                [cast(byte)(x-1), cast(byte)(y-1)],
                [cast(byte)(x-1), cast(byte)(y+1)],
                [cast(byte)(x+1), cast(byte)(y+1)]];
    }

    @property byte[2][4] texcoords_270() {
        return [[cast(byte)(x-1), cast(byte)(y-1)],
                [cast(byte)(x-1), cast(byte)(y+1)],
                [cast(byte)(x+1), cast(byte)(y+1)],
                [cast(byte)(x+1), cast(byte)(y-1)]];
    }
}


immutable CubeSideData[6] CUBE_VERTICES = [
    { [[-0.5f, -0.5f, 0.5f], [0.5f, -0.5f, 0.5f], [0.5f, 0.5f, 0.5f], [-0.5f, 0.5f, 0.5f]], // near
       [0.0f, 0.0f, 1.0f] },

    { [[-0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, 0.5f], [-0.5f, 0.5f, 0.5f], [-0.5f, 0.5f, -0.5f]], // left
       [-1.0f, 0.0f, 0.0f] },

    { [[0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, -0.5f], [-0.5f, 0.5f, -0.5f], [0.5f, 0.5f, -0.5f]], // far
       [0.0f, 0.0f, -1.0f] },

    { [[0.5f, -0.5f, 0.5f], [0.5f, -0.5f, -0.5f], [0.5f, 0.5f, -0.5f], [0.5f, 0.5f, 0.5f]], // right
       [1.0f, 0.0f, 0.0f] },

    { [[-0.5f, 0.5f, 0.5f], [0.5f, 0.5f, 0.5f], [0.5f, 0.5f, -0.5f], [-0.5f, 0.5f, -0.5f]], // top
       [0.0f, 1.0f, 0.0f]  },

    { [[-0.5f, -0.5f, -0.5f], [0.5f, -0.5f, -0.5f], [0.5f, -0.5f, 0.5f], [-0.5f, -0.5f, 0.5f]], // bottom
       [0.0f, -1.0f, 0.0f] }
];


Vertex[] simple_block(Side side, byte[2][4] texture_slice) pure {
    return simple_block(side, texture_slice, nslice);
}

Vertex[] simple_block(Side side, byte[2][4] texture_slice, byte[2][4] mask_slice) pure {
    CubeSideData cbsd = CUBE_VERTICES[side];

    mixin(mk_vertices);
    return data.dup;
}