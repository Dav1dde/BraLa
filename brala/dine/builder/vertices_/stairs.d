module brala.dine.builder.vertices_.stairs;

private {
    import std.math : abs;

    import brala.dine.builder.tessellator : Vertex;
    import brala.dine.builder.vertices : CubeSideData;
    import brala.dine.builder.vertices_.util;
}

struct StairTextureSlice {
    byte x;
    byte y;

    byte x2;
    byte y2;

    alias texcoords this;

    this(byte lower_left_x, byte lower_left_y, byte lower_left_x2, byte lower_left_y2)
        in { assert(abs(lower_left_x*2) <= byte.max && abs(lower_left_y*2) <= byte.max);
             assert(abs(lower_left_x2*2) <= byte.max && abs(lower_left_y2*2) <= byte.max); }
        body {
            x = cast(byte)(lower_left_x*2);
            y = cast(byte)(lower_left_y*2);

            x2 = cast(byte)(lower_left_x2*2);
            y2 = cast(byte)(lower_left_y2*2);
        }

    pure:
    @property byte[2][4] texcoords() {
        return [[cast(byte)x,     cast(byte)y],
                [cast(byte)(x+2), cast(byte)y],
                [cast(byte)(x+2), cast(byte)(y-2)],
                [cast(byte)x,     cast(byte)(y-2)]];
    }

    @property byte[2][4] texcoords2() {
        return [[cast(byte)x2,     cast(byte)y2],
                [cast(byte)(x2+2), cast(byte)y2],
                [cast(byte)(x2+2), cast(byte)(y2-2)],
                [cast(byte)x2,     cast(byte)(y2-2)]];
    }

    @property byte[2][4] texcoords_step_lower() {
        return [[cast(byte)x,     cast(byte)y],
                [cast(byte)(x+2), cast(byte)y],
                [cast(byte)(x+2), cast(byte)(y-1)],
                [cast(byte)x,     cast(byte)(y-1)]];
    }

    @property byte[2][4] texcoords_step_upper() {
        return [[cast(byte)x,     cast(byte)(y-1)],
                [cast(byte)(x+2), cast(byte)(y-1)],
                [cast(byte)(x+2), cast(byte)(y-2)],
                [cast(byte)x,     cast(byte)(y-2)]];
    }

    @property byte[2][4] texcoords_step_top_front() {
        return [[cast(byte)x2,     cast(byte)y2],
                [cast(byte)(x2+2), cast(byte)y2],
                [cast(byte)(x2+2), cast(byte)(y2-1)],
                [cast(byte)x2,     cast(byte)(y2-1)]];
    }

    @property byte[2][4] texcoords_step_top_back() {
        return [[cast(byte)x2,     cast(byte)(y2-1)],
                [cast(byte)(x2+2), cast(byte)(y2-1)],
                [cast(byte)(x2+2), cast(byte)(y2-2)],
                [cast(byte)x2,     cast(byte)(y2-2)]];
    }

    @property byte[2][4] texcoords_step_side_front() {
        return [[cast(byte)(x),   cast(byte)y],
                [cast(byte)(x+1), cast(byte)y],
                [cast(byte)(x+1), cast(byte)(y-1)],
                [cast(byte)(x),   cast(byte)(y-1)]];
    }

    @property byte[2][4] texcoords_step_side_back() {
        return [[cast(byte)(x+1), cast(byte)y],
                [cast(byte)(x+2), cast(byte)y],
                [cast(byte)(x+2), cast(byte)(y-2)],
                [cast(byte)(x+1), cast(byte)(y-2)]];
    }



    alias texcoords texcoords2_upsidedown;
    alias texcoords2 texcoords_upsidedown;

    @property byte[2][4] texcoords_step_lower_upsidedown() {
        return [[cast(byte)x,     cast(byte)(y-1)],
                [cast(byte)(x+2), cast(byte)(y-1)],
                [cast(byte)(x+2), cast(byte)y],
                [cast(byte)x,     cast(byte)y]];
    }

    @property byte[2][4] texcoords_step_upper_upsidedown() {
        return [[cast(byte)x,     cast(byte)(y-1)],
                [cast(byte)(x+2), cast(byte)(y-1)],
                [cast(byte)(x+2), cast(byte)(y-2)],
                [cast(byte)x,     cast(byte)(y-2)]];
    }

    @property byte[2][4] texcoords_step_top_front_upsidedown() {
        return [[cast(byte)x,     cast(byte)(y-1)],
                [cast(byte)(x+2), cast(byte)(y-1)],
                [cast(byte)(x+2), cast(byte)y],
                [cast(byte)x,     cast(byte)y]];
    }

    @property byte[2][4] texcoords_step_top_back_upsidedown() {
        return [[cast(byte)x,     cast(byte)y],
                [cast(byte)(x+2), cast(byte)y],
                [cast(byte)(x+2), cast(byte)(y-1)],
                [cast(byte)x,     cast(byte)(y-1)]];
    }

    @property byte[2][4] texcoords_step_side_front_upsidedown() {
        return [[cast(byte)x,     cast(byte)(y-2)],
                [cast(byte)(x+1), cast(byte)(y-2)],
                [cast(byte)(x+1), cast(byte)(y-1)],
                [cast(byte)x,     cast(byte)(y-1)]];
    }

    @property byte[2][4] texcoords_step_side_back_upsidedown() {
        return [[cast(byte)(x+1), cast(byte)(y-2)],
                [cast(byte)(x+2), cast(byte)(y-2)],
                [cast(byte)(x+2), cast(byte)y],
                [cast(byte)(x+1), cast(byte)y]];
    }
}



// TODO: check normals
immutable CubeSideData[3] STAIR_VERTICES_NEAR = [
    { [[0.0f, 0.0f, -0.5f], [0.0f, 0.0f, 0.5f], [0.5f, 0.0f, 0.5f], [0.5f, 0.0f, -0.5f]], // y+
      [0.0f, 1.0f, 0.0f] },

    { [[0.0f, 0.0f, 0.5f], [0.0f, 0.0f, -0.5f], [0.0f, 0.5f, -0.5f], [0.0f, 0.5f, 0.5f]], // upper
      [0.0f, 0.0f, 1.0f] },

    { [[0.5f, -0.5f, 0.5f], [0.5f, -0.5f, -0.5f], [0.5f, 0.0f, -0.5f], [0.5f, 0.0f, 0.5f]], // lower
      [0.0f, 0.0f, 1.0f] }
];

immutable CubeSideData[1] STAIR_VERTICES_FAR = [
    { [[-0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, 0.5f], [-0.5f, 0.5f, 0.5f], [-0.5f, 0.5f, -0.5f]],
      [0.0f, -1.0f, 0.0f] }
];

immutable CubeSideData[2] STAIR_VERTICES_LEFT = [
    { [[0.5f, 0.0f, 0.5f], [0.0f, 0.0f, 0.5f], [0.0f, -0.5f, 0.5f], [0.5f, -0.5f, 0.5f]], // small, front
      [-1.0f, 0.0f, 0.0f] },

    { [[-0.5f, -0.5f, 0.5f], [0.0f, -0.5f, 0.5f], [0.0f, 0.5f, 0.5f], [-0.5f, 0.5f, 0.5f]],
      [-1.0f, 0.0f, 0.0f] }
];

immutable CubeSideData[2] STAIR_VERTICES_RIGHT = [
    { [[0.5f, -0.5f, -0.5f], [0.0f, -0.5f, -0.5f], [0.0f, 0.0f, -0.5f], [0.5f, 0.0f, -0.5f]], // small, front
      [1.0f, 0.0f, 0.0f] },

    { [[0.0f, -0.5f, -0.5f], [-0.5f, -0.5f, -0.5f], [-0.5f, 0.5f, -0.5f], [0.0f, 0.5f, -0.5f]],
      [1.0f, 0.0f, 0.0f] }
];

immutable CubeSideData[1] STAIR_VERTICES_TOP = [
    { [[-0.5f, 0.5f, -0.5f], [-0.5f, 0.5f, 0.5f], [0.0f, 0.5f, 0.5f], [0.0f, 0.5f, -0.5f]],
      [0.0f, 1.0f, 0.0f] }
];

immutable CubeSideData[2] STAIR_VERTICES_BOTTOM = [
    { [[-0.5f, -0.5f, 0.5f], [-0.5f, -0.5f, -0.5f], [0.5f, -0.5f, -0.5f], [0.5f, -0.5f, 0.5f]],
      [0.0f, -1.0f, 0.0f] }
];

// Vertex[] simple_stair(Side s, Facing face, bool upside_down, StairTextureSlice texture_slice) pure {
//     return simple_stair(s, face, upside_down, texture_slice, nslice);
// }

Vertex[] simple_stair(Side s, Facing face, bool upside_down, StairTextureSlice texture_slice) pure { // well not so simple
    Vertex[] ret;

    CubeSideData cbsd;
    float[3][6] positions;
    byte[2][6] texcoords;
    byte[2][6] mask;

    final switch(s) {
        case Side.NEAR: {
            mixin(mk_stair_vertex("STAIR_VERTICES_NEAR[0]", "texcoords_step_top_front"));
            mixin(mk_stair_vertex("STAIR_VERTICES_NEAR[1]", "texcoords_step_upper"));
            mixin(mk_stair_vertex("STAIR_VERTICES_NEAR[2]", "texcoords_step_lower"));
            break;
        }
        case Side.LEFT: {
            mixin(mk_stair_vertex("STAIR_VERTICES_LEFT[0]", "texcoords_step_side_front"));
            mixin(mk_stair_vertex("STAIR_VERTICES_LEFT[1]", "texcoords_step_side_back"));

            break;
        }
        case Side.FAR: {
            mixin(mk_stair_vertex("STAIR_VERTICES_FAR[0]", "texcoords"));
            break;
        }
        case Side.RIGHT: {
            mixin(mk_stair_vertex("STAIR_VERTICES_RIGHT[0]", "texcoords_step_side_front"));
            mixin(mk_stair_vertex("STAIR_VERTICES_RIGHT[1]", "texcoords_step_side_back"));

            break;
        }
        case Side.TOP: {
            mixin(mk_stair_vertex("STAIR_VERTICES_TOP[0]", "texcoords_step_top_back"));

            break;
        }
        case Side.BOTTOM: {
            mixin(mk_stair_vertex("STAIR_VERTICES_BOTTOM[0]", "texcoords"));

            break;
        }
        case Side.ALL: assert(false);
    }

    return ret;
}
