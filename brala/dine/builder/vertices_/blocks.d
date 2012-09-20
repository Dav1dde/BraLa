module brala.dine.builder.vertices_.blocks;

private {
    import std.math : abs;
    
    import brala.dine.builder.tessellator : Vertex;
    import brala.dine.builder.vertices : CubeSideData;
    import brala.dine.builder.vertices_.util;
}


struct TextureSlice {
    enum ubyte FB = 16;
    enum ubyte HB = 8;
    
    ubyte x;
    ubyte y;

    alias texcoords this;

    this(ubyte lower_left_x, ubyte lower_left_y)
        in { assert(abs(lower_left_x*FB) <= ubyte.max && abs(lower_left_y*FB) <= ubyte.max); }
        body {
            x = cast(ubyte)(lower_left_x*FB+HB);
            y = cast(ubyte)(lower_left_y*FB-HB);
        }

    pure:
    @property ubyte[2][4] texcoords() {
        return [[cast(ubyte)(x-HB),   cast(ubyte)(y+HB-1)],
                [cast(ubyte)(x+HB-1), cast(ubyte)(y+HB-1)],
                [cast(ubyte)(x+HB-1), cast(ubyte)(y-HB)],
                [cast(ubyte)(x-HB),   cast(ubyte)(y-HB)]];
    }

    @property ubyte[2][4] texcoords_90() {
        return [[cast(ubyte)(x+HB-1), cast(ubyte)(y+HB-1)],
                [cast(ubyte)(x+HB-1), cast(ubyte)(y-HB)],
                [cast(ubyte)(x-HB),   cast(ubyte)(y-HB)],
                [cast(ubyte)(x-HB),   cast(ubyte)(y+HB-1)]];
    }

    @property ubyte[2][4] texcoords_180() {
        return [[cast(ubyte)(x+HB-1), cast(ubyte)(y-HB)],
                [cast(ubyte)(x-HB),   cast(ubyte)(y-HB)],
                [cast(ubyte)(x-HB),   cast(ubyte)(y+HB-1)],
                [cast(ubyte)(x+HB-1), cast(ubyte)(y+HB-1)]];
    }

    @property ubyte[2][4] texcoords_270() {
        return [[cast(ubyte)(x-HB),   cast(ubyte)(y-HB)],
                [cast(ubyte)(x-HB),   cast(ubyte)(y+HB-1)],
                [cast(ubyte)(x+HB-1), cast(ubyte)(y+HB-1)],
                [cast(ubyte)(x+HB-1), cast(ubyte)(y-HB)]];
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


Vertex[] simple_block(Side side, ubyte[2][4] texture_slice) pure {
    return simple_block(side, texture_slice, nslice, Facing.SOUTH);
}

Vertex[] simple_block(Side side, ubyte[2][4] texture_slice, Facing face) pure {
    return simple_block(side, texture_slice, nslice, face);
}

Vertex[] simple_block(Side side, ubyte[2][4] texture_slice, ubyte[2][4] mask_slice, Facing face) pure {
    CubeSideData cbsd = CUBE_VERTICES[side];

    mixin(mk_vertices_adv("to_triangles", true));
    return data.dup;
}