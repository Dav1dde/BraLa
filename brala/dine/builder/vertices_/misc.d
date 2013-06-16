module brala.dine.builder.vertices_.misc;

private {
    import brala.gfx.data : Normal;
    import brala.dine.builder.tessellator : Vertex;
    import brala.dine.builder.vertices : CubeSideData;
    import brala.dine.builder.vertices_.util;
}


CubeSideData LADDER_VERTEX = {
    [[-0.5f, -0.5f, -0.45f], [0.5f, -0.5f, -0.45f], [0.5f, 0.5f, -0.45f], [-0.5f, 0.5f, -0.45f]],
     Normal.Z_POSITIVE
};


// Vertex[] simple_ladder(short[2][4] texture_slice, Facing face) {
//     return simple_ladder(texture_slice, nslice, face);
// }

Vertex[] simple_ladder(short[2][4] texture_slice, /+short[2][4] mask_slice,+/ Facing face) {
    CubeSideData cbsd = LADDER_VERTEX;

    alias texture_slice mask_slice;

    mixin(mk_vertices_adv("to_triangles", true));

    return data.dup;
}

Vertex[] simple_vine(short[2][4] texture_slice, /+short[2][4] mask_slice,+/ Facing face) {
    Vertex[] ret;

    CubeSideData cbsd = LADDER_VERTEX;

    alias texture_slice mask_slice;

    {
        mixin(mk_vertices_adv("to_triangles", true));
        ret ~= data;
    }

    {
        mixin(mk_vertices_adv("to_triangles_other_winding", false));
        ret ~= data;
    }

    return ret;
}

CubeSideData TOP_VINE_VERTEX = {
    [[-0.5f, 0.45f, 0.5f], [0.5f, 0.45f, 0.5f], [0.5f, 0.45f, -0.5f], [-0.5f, 0.45f, -0.5f]],
     Normal.Y_POSITIVE
};


Vertex[] top_vine(short[2][4] texture_slice) {
    CubeSideData cbsd = TOP_VINE_VERTEX;

    alias texture_slice mask_slice;

    mixin(mk_vertices_adv("to_triangles_other_winding", false));

    return data.dup;
}
