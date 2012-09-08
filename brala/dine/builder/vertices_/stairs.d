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

    private int rotation;

    alias texcoords this;

    this(byte lower_left_x, byte lower_left_y, byte lower_left_x2, byte lower_left_y2)
        in { assert(abs(lower_left_x*2) <= byte.max && abs(lower_left_y*2) <= byte.max);
             assert(abs(lower_left_x2*2) <= byte.max && abs(lower_left_y2*2) <= byte.max); }
        body {
            x = cast(byte)(lower_left_x*2+1);
            y = cast(byte)(lower_left_y*2-1);

            x2 = cast(byte)(lower_left_x2*2+1);
            y2 = cast(byte)(lower_left_y2*2-1);
        }

    pure:
    @property byte[2][4] texcoords() {
        return transform([[-1, +1], [+1, +1], [+1, -1], [-1, -1]]);
    }

    @property byte[2][4] texcoords2() {
        return transform([[-1, +1], [+1, +1], [+1, -1], [-1, -1]], true);
    }

    @property byte[2][4] texcoords_step_lower() {
        return transform([[-1, +1], [+1, +1], [+1, 0], [-1, 0]]);
    }

    @property byte[2][4] texcoords_step_upper() {
        return transform([[-1, 0], [+1, 0], [+1, -1], [-1, -1]]);
    }

    @property byte[2][4] texcoords_step_top_back() {
        return transform([[-1, 0], [+1, 0], [+1, -1], [-1, -1]], true);
    }

    @property byte[2][4] texcoords_step_top_front() {
        return transform([[-1, +1], [+1, +1], [+1, 0], [-1, 0]], true);
    }

    @property byte[2][4] texcoords_step_side_front() {
        return transform([[-1, +1], [0, +1], [0, 0], [-1, 0]]);
    }

    @property byte[2][4] texcoords_step_side_back() {
        return transform([[0,  +1], [+1, +1], [+1, -1], [0, -1]]);
    }

    @property byte[2][4] texcoords_step_side_front2() {
        return transform([[0, +1], [+1, +1], [+1, 0], [0, 0]]);
    }

    @property byte[2][4] texcoords_step_side_back2() {
        return transform([[-1,  +1], [0, +1], [0, -1], [-1, -1]]);
    }



    alias texcoords texcoords2_upsidedown;
    alias texcoords2 texcoords_upsidedown;

    @property byte[2][4] texcoords_step_lower_upsidedown() {
        return transform([[-1, 0], [+1, 0], [+1, +1], [-1, +1]]);
    }

    @property byte[2][4] texcoords_step_upper_upsidedown() {
        return transform([[-1, 0], [+1, 0], [+1, -1], [-1, -1]]);
    }

    @property byte[2][4] texcoords_step_top_front_upsidedown() {
        return transform([[-1, 0], [+1, 0], [+1, +1], [-1, +1]]);
    }

    @property byte[2][4] texcoords_step_top_back_upsidedown() {
        return transform([[-1, +1], [+1, +1], [+1, 0], [-1, 0]]);
    }

    @property byte[2][4] texcoords_step_side_front_upsidedown() {
        return transform([[-1, -1], [0,  -1], [0,  0], [-1, 0]]);
    }

    @property byte[2][4] texcoords_step_side_back_upsidedown() {
        return transform([[0,  -1], [+1, -1], [+1, +1], [0,  +1]]);
    }

    @property byte[2][4] texcoords_step_side_front2_upsidedown() {
        return transform([[-1, -1], [0,  -1], [0,  0], [-1, 0]]);
    }

    @property byte[2][4] texcoords_step_side_back2_upsidedown() {
        return transform([[0,  -1], [+1, -1], [+1, +1], [0,  +1]]);
    }

    private byte[2][4] transform(byte[2][4] templ, bool s2 = false) {
        if(rotation == 90) {
            .rotate_90(templ);
        } else if(rotation == 180) {
            .rotate_180(templ);
        } else if(rotation == 270) {
            .rotate_270(templ);
        }

        byte x = this.x;
        byte y = this.y;
        if(s2) {
            x = this.x2;
            y = this.y2;
        }
            
        foreach(ref t; templ) {
            t[0] += x;
            t[1] += y;
        }

        return templ;
    }

    void rotate_90() {
        rotation = 90;
    }

    void rotate_180() {
        rotation = 180;
    }

    void rotate_270() {
        rotation = 270;
    }
}



// TODO: check normals
immutable CubeSideData[3] STAIR_VERTICES_NEAR = [
    { [[-0.5f, 0.0f, 0.5f], [0.5f, 0.0f, 0.5f], [0.5f, 0.0f, 0.0f], [-0.5f, 0.0f, 0.0f]], // y+
      [0.0f, 1.0f, 0.0f] },

    { [[-0.5f, 0.0f, 0.0f], [0.5f, 0.0f, 0.0f], [0.5f, 0.5f, 0.0f], [-0.5f, 0.5f, 0.0f]], // upper
      [0.0f, 0.0f, 1.0f] },

    { [[-0.5f, -0.5f, 0.5f], [0.5f, -0.5f, 0.5f], [0.5f, 0.0f, 0.5f], [-0.5f, 0.0f, 0.5f]], // lower
      [0.0f, 0.0f, 1.0f] }
];

immutable CubeSideData[1] STAIR_VERTICES_FAR = [
    { [[0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, -0.5f], [-0.5f, 0.5f, -0.5f], [0.5f, 0.5f, -0.5f]],
      [0.0f, -1.0f, 0.0f] }
];

immutable CubeSideData[2] STAIR_VERTICES_LEFT = [
    { [[-0.5f, -0.5f, 0.0f], [-0.5f, -0.5f, 0.5f], [-0.5f, 0.0f, 0.5f], [-0.5f, 0.0f, 0.0f]], // small, front
      [-1.0f, 0.0f, 0.0f] },

    { [[-0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, 0.0f], [-0.5f, 0.5f, 0.0f], [-0.5f, 0.5f, -0.5f]],
      [-1.0f, 0.0f, 0.0f] }
];

immutable CubeSideData[2] STAIR_VERTICES_RIGHT = [
    { [[0.5f, -0.5f, 0.5f], [0.5f, -0.5f, 0.0f], [0.5f, 0.0f, 0.0f], [0.5f, 0.0f, 0.5f]], // small, front
      [1.0f, 0.0f, 0.0f] },

    { [[0.5f, -0.5f, 0.0f], [0.5f, -0.5f, -0.5f], [0.5f, 0.5f, -0.5f], [0.5f, 0.5f, 0.0f]],
      [1.0f, 0.0f, 0.0f] }
];

immutable CubeSideData[1] STAIR_VERTICES_TOP = [
    { [[-0.5f, 0.5f, 0.0f], [0.5f, 0.5f, 0.0f], [0.5f, 0.5f, -0.5f], [-0.5f, 0.5f, -0.5f]],
      [0.0f, 1.0f, 0.0f] }
];

immutable CubeSideData[2] STAIR_VERTICES_BOTTOM = [
    { [[-0.5f, -0.5f, -0.5f], [0.5f, -0.5f, -0.5f], [0.5f, -0.5f, 0.5f], [-0.5f, -0.5f, 0.5f]],
      [0.0f, -1.0f, 0.0f] }
];

// Vertex[] simple_stair(Side s, Facing face, bool upside_down, StairTextureSlice texture_slice) pure {
//     return simple_stair(s, face, upside_down, texture_slice, nslice);
// }

Vertex[] simple_stair(Side s, Facing face, bool upside_down, StairTextureSlice texture_slice) { // well not so simple
    Vertex[] ret;

    CubeSideData cbsd;
    float[3][6] positions;
    byte[2][4] t;
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
            mixin(mk_stair_vertex("STAIR_VERTICES_LEFT[0]", "texcoords_step_side_front2"));
            mixin(mk_stair_vertex("STAIR_VERTICES_LEFT[1]", "texcoords_step_side_back2"));

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
