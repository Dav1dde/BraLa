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

immutable CubeSideData[6] PISTON_EXTENDED_VERTICES = [
    { [[-0.5f, -0.5f, 0.25f], [0.5f, -0.5f, 0.25f], [0.5f, 0.5f, 0.25f], [-0.5f, 0.5f, 0.25f]], // near
       [0.0f, 0.0f, 1.0f] },

    { [[-0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, 0.25f], [-0.5f, 0.5f, 0.25f], [-0.5f, 0.5f, -0.5f]], // left
       [-1.0f, 0.0f, 0.0f] },

    { [[0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, -0.5f], [-0.5f, 0.5f, -0.5f], [0.5f, 0.5f, -0.5f]], // far
       [0.0f, 0.0f, -1.0f] },

    { [[0.5f, -0.5f, 0.25f], [0.5f, -0.5f, -0.5f], [0.5f, 0.5f, -0.5f], [0.5f, 0.5f, 0.25f]], // right
       [1.0f, 0.0f, 0.0f] },

    { [[-0.5f, 0.5f, 0.25f], [0.5f, 0.5f, 0.25f], [0.5f, 0.5f, -0.5f], [-0.5f, 0.5f, -0.5f]], // top
       [0.0f, 1.0f, 0.0f]  },

    { [[-0.5f, -0.5f, -0.5f], [0.5f, -0.5f, -0.5f], [0.5f, -0.5f, 0.25f], [-0.5f, -0.5f, 0.25f]], // bottom
       [0.0f, -1.0f, 0.0f] }
];

Vertex[] extended_piston(Side side, Side face, short[2][4] texture_slice) {
    CubeSideData cbsd = PISTON_EXTENDED_VERTICES[side];
    alias texture_slice mask_slice;

    mixin(mk_vertices_adv("to_triangles", true));
    return data.dup;
}