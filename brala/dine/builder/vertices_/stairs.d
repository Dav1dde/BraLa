module brala.dine.builder.vertices_.stairs;

private {
    import brala.gfx.data : Normal;
    import brala.gfx.terrain : ProjectionTextureCoordinates;
    import brala.dine.builder.tessellator : Vertex;
    import brala.dine.builder.vertices : CubeSideData;
    import brala.dine.builder.vertices_.util;
}


immutable CubeSideData[2] STAIR_VERTICES_NEAR = [
    { [[-0.5f, 0.0f, 0.0f], [0.5f, 0.0f, 0.0f], [0.5f, 0.5f, 0.0f], [-0.5f, 0.5f, 0.0f]], // upper
      Normal.Z_POSITIVE },

    { [[-0.5f, -0.5f, 0.5f], [0.5f, -0.5f, 0.5f], [0.5f, 0.0f, 0.5f], [-0.5f, 0.0f, 0.5f]], // lower
      Normal.Z_POSITIVE }
];

immutable CubeSideData[1] STAIR_VERTICES_FAR = [
    { [[-0.5f, 0.5f, -0.5f], [0.5f, 0.5f, -0.5f], [0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, -0.5f]],
      Normal.Z_NEGATIVE }
];

immutable CubeSideData[2] STAIR_VERTICES_LEFT = [
    { [[-0.5f, -0.5f, 0.0f], [-0.5f, -0.5f, 0.5f], [-0.5f, 0.0f, 0.5f], [-0.5f, 0.0f, 0.0f]], // small, front
      Normal.X_NEGATIVE },

    { [[-0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, 0.0f], [-0.5f, 0.5f, 0.0f], [-0.5f, 0.5f, -0.5f]],
      Normal.X_NEGATIVE }
];

immutable CubeSideData[2] STAIR_VERTICES_RIGHT = [
    { [[0.5f, -0.5f, 0.5f], [0.5f, -0.5f, 0.0f], [0.5f, 0.0f, 0.0f], [0.5f, 0.0f, 0.5f]], // small, front
      Normal.X_POSITIVE },

    { [[0.5f, -0.5f, 0.0f], [0.5f, -0.5f, -0.5f], [0.5f, 0.5f, -0.5f], [0.5f, 0.5f, 0.0f]],
      Normal.X_POSITIVE }
];

immutable CubeSideData[2] STAIR_VERTICES_TOP = [
    { [[-0.5f, 0.5f, 0.0f], [0.5f, 0.5f, 0.0f], [0.5f, 0.5f, -0.5f], [-0.5f, 0.5f, -0.5f]],
      Normal.Y_POSITIVE },
      
    { [[-0.5f, 0.0f, 0.5f], [0.5f, 0.0f, 0.5f], [0.5f, 0.0f, 0.0f], [-0.5f, 0.0f, 0.0f]], // near
      Normal.Y_POSITIVE }
];

immutable CubeSideData[2] STAIR_VERTICES_BOTTOM = [
    { [[-0.5f, -0.5f, -0.5f], [0.5f, -0.5f, -0.5f], [0.5f, -0.5f, 0.5f], [-0.5f, -0.5f, 0.5f]],
      Normal.Y_NEGATIVE }
];

// Vertex[] simple_stair(Side s, Facing face, bool upside_down, StairTextureSlice texture_slice) pure {
//     return simple_stair(s, face, upside_down, texture_slice, nslice);
// }

Vertex[] simple_stair(Side s, Facing face, bool upside_down, ProjectionTextureCoordinates texture_slice) { // well not so simple
    Vertex[] ret;

    CubeSideData cbsd;
    float[3][6] positions;
    short[2][6] texcoords;

    final switch(s) {
        case Side.NEAR: {
            mixin(mk_stair_vertex("STAIR_VERTICES_NEAR[0]"));
            mixin(mk_stair_vertex("STAIR_VERTICES_NEAR[1]"));
            break;
        }
        case Side.LEFT: {
            mixin(mk_stair_vertex("STAIR_VERTICES_LEFT[0]"));
            mixin(mk_stair_vertex("STAIR_VERTICES_LEFT[1]"));

            break;
        }
        case Side.FAR: {
            mixin(mk_stair_vertex("STAIR_VERTICES_FAR[0]"));
            break;
        }
        case Side.RIGHT: {
            mixin(mk_stair_vertex("STAIR_VERTICES_RIGHT[0]"));
            mixin(mk_stair_vertex("STAIR_VERTICES_RIGHT[1]"));

            break;
        }
        case Side.TOP: {
            mixin(mk_stair_vertex("STAIR_VERTICES_TOP[0]"));
            mixin(mk_stair_vertex("STAIR_VERTICES_TOP[1]"));

            break;
        }
        case Side.BOTTOM: {
            mixin(mk_stair_vertex("STAIR_VERTICES_BOTTOM[0]"));

            break;
        }
        case Side.ALL: assert(false);
    }

    return ret;
}
