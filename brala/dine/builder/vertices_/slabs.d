module brala.dine.builder.vertices_.slabs;

private {
    import brala.gfx.data : Normal;
    import brala.dine.builder.tessellator : Vertex;
    import brala.dine.builder.vertices : CubeSideData;
    import brala.dine.builder.vertices_.util;
}

immutable CubeSideData[6] SLAB_VERTICES = [
    { [[-0.5f, -0.5f, 0.5f], [0.5f, -0.5f, 0.5f], [0.5f, 0.0f, 0.5f], [-0.5f, 0.0f, 0.5f]], // near
       Normal.Z_POSITIVE },

    { [[-0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, 0.5f], [-0.5f, 0.0f, 0.5f], [-0.5f, 0.0f, -0.5f]], // left
       Normal.X_NEGATIVE },

    { [[0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, -0.5f], [-0.5f, 0.0f, -0.5f], [0.5f, 0.0f, -0.5f]], // far
       Normal.Z_NEGATIVE },

    { [[0.5f, -0.5f, 0.5f], [0.5f, -0.5f, -0.5f], [0.5f, 0.0f, -0.5f], [0.5f, 0.0f, 0.5f]], // right
       Normal.X_POSITIVE },

    { [[-0.5f, 0.0f, 0.5f], [0.5f, 0.0f, 0.5f], [0.5f, 0.0f, -0.5f], [-0.5f, 0.0f, -0.5f]], // top
       Normal.Y_POSITIVE  },

    { [[-0.5f, -0.5f, -0.5f], [0.5f, -0.5f, -0.5f], [0.5f, -0.5f, 0.5f], [-0.5f, -0.5f, 0.5f]], // bottom
       Normal.Y_NEGATIVE }
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

Vertex[] simple_slab(Side side, bool upside_down, short[2][4] texture_slice) pure {
    return simple_slab(side, upside_down, texture_slice, nslice);
}

Vertex[] simple_slab(Side side, bool upside_down, short[2][4] texture_slice, short[2][4] mask_slice) pure {
    CubeSideData cbsd;
    if(upside_down) {
        cbsd = SLAB_VERTICES_UPSIDEDOWN[side];

        if(side == Side.BOTTOM) {
            
        }

    } else {
        cbsd = SLAB_VERTICES[side];
    }

    mixin(mk_vertices);
    return data.dup;
}
