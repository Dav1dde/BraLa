module brala.dine.builder.vertices_.misc;

private {
    import brala.dine.builder.tessellator : Vertex;
    import brala.dine.builder.vertices : CubeSideData;
    import brala.dine.builder.vertices_.util;
}


CubeSideData LADDER_VERTEX = {
    [[-0.5f, -0.5f, -0.495f], [0.5f, -0.5f, -0.495f], [0.5f, 0.5f, -0.495f], [-0.5f, 0.5f, -0.495f]],
     [0.0f, 0.0f, 1.0f]
};


Vertex[] simple_ladder(short[2][4] texture_slice, Facing face) {
    return simple_ladder(texture_slice, nslice, face);
}

Vertex[] simple_ladder(short[2][4] texture_slice, short[2][4] mask_slice, Facing face) {
    CubeSideData cbsd = LADDER_VERTEX;

    mixin(mk_vertices_adv("to_triangles", true));

    return data.dup;
}
