module brala.dine.builder.vertices_.slabs;

private {
    import std.math : abs;

    import brala.dine.builder.tessellator : Vertex;
    import brala.dine.builder.vertices : CubeSideData;
    import brala.dine.builder.vertices_.util;
}


struct SlabTextureSlice {
    byte x;
    byte y;

    alias texcoords this;

    this(byte lower_left_x, byte lower_left_y)
        in { assert(abs(lower_left_x*2) <= byte.max && abs(lower_left_y*2) <= byte.max); }
        body {
            x = cast(byte)(lower_left_x*2);
            y = cast(byte)(lower_left_y*2);
        }

    pure:
    @property byte[2][4] texcoords() {
        return [[cast(byte)x,     cast(byte)y],
                [cast(byte)(x+2), cast(byte)y],
                [cast(byte)(x+2), cast(byte)(y-1)],
                [cast(byte)x,     cast(byte)(y-1)]];
    }
}


immutable CubeSideData[6] SLAB_VERTICES = [
    { [[-0.5f, -0.5f, 0.5f], [0.5f, -0.5f, 0.5f], [0.5f, 0.0f, 0.5f], [-0.5f, 0.0f, 0.5f]], // near
       [0.0f, 0.0f, 1.0f] },

    { [[-0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, 0.5f], [-0.5f, 0.0f, 0.5f], [-0.5f, 0.0f, -0.5f]], // left
       [-1.0f, 0.0f, 0.0f] },

    { [[0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, -0.5f], [-0.5f, 0.0f, -0.5f], [0.5f, 0.0f, -0.5f]], // far
       [0.0f, 0.0f, -1.0f] },

    { [[0.5f, -0.5f, 0.5f], [0.5f, -0.5f, -0.5f], [0.5f, 0.0f, -0.5f], [0.5f, 0.0f, 0.5f]], // right
       [1.0f, 0.0f, 0.0f] },

    { [[-0.5f, 0.0f, 0.5f], [0.5f, 0.0f, 0.5f], [0.5f, 0.0f, -0.5f], [-0.5f, 0.0f, -0.5f]], // top
       [0.0f, 1.0f, 0.0f]  },

    { [[-0.5f, -0.5f, -0.5f], [0.5f, -0.5f, -0.5f], [0.5f, -0.5f, 0.5f], [-0.5f, -0.5f, 0.5f]], // bottom
       [0.0f, -1.0f, 0.0f] }
];

immutable CubeSideData[6] SLAB_VERTICES_UPSIDEDOWN = upside_down_slabs();

private CubeSideData[6] upside_down_slabs() {
    CubeSideData[6] ret = SLAB_VERTICES.dup;

    foreach(ref side; ret) {
        foreach(ref vertex; side.positions) {
            vertex[1] += 0.5f;
        }
    }

    return ret;
}

Vertex[] simple_slab(Side side, bool upside_down, byte[2][4] texture_slice) pure {
    return simple_slab(side, upside_down, texture_slice, nslice);
}

Vertex[] simple_slab(Side side, bool upside_down, byte[2][4] texture_slice, byte[2][4] mask_slice) pure {
    CubeSideData cbsd;
    if(upside_down) {
        cbsd = SLAB_VERTICES_UPSIDEDOWN[side];
    } else {
        cbsd = SLAB_VERTICES[side];
    }

    mixin(mk_vertices);
    return data.dup;
}
