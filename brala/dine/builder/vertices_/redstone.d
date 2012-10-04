module brala.dine.builder.vertices_.redstone;

private {
    import brala.dine.builder.tessellator : Vertex;
    import brala.dine.builder.vertices : CubeSideData;
    import brala.dine.builder.vertices_.blocks : CUBE_VERTICES;
    import brala.dine.builder.vertices_.util;
}

Vertex[] retracted_piston(Side side, Side face, short[2][4] texture_slice) {
    CubeSideData cbsd = CUBE_VERTICES[side];
    alias texture_slice mask_slice;

    mixin(mk_vertices_adv("to_triangles", true));
    return data.dup;
}

// Vertex[] retracted_piston(Side side, Side face, short[2][4] texture_slice) {
// 
// }