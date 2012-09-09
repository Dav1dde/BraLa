module brala.dine.builder.vertices_.stairs;

private {
    import gl3n.math : abs, sign;

    import brala.dine.builder.tessellator : Vertex;
    import brala.dine.builder.vertices : CubeSideData;
    import brala.dine.builder.vertices_.util;
}

enum UVSet {
    FIRST,
    SECOND,
    THIRD
}


struct StairTextureSlice {
    byte x;
    byte y;

    byte x2; // normal y+
    byte y2;
    
    byte x3; // normal y-
    byte y3;

    private int rotation;

    this(byte lower_left_x, byte lower_left_y, byte lower_left_x2, byte lower_left_y2)
        in { assert(abs(lower_left_x*2) <= byte.max && abs(lower_left_y*2) <= byte.max);
             assert(abs(lower_left_x2*2) <= byte.max && abs(lower_left_y2*2) <= byte.max); }
        body {
            x = cast(byte)(lower_left_x*2+1);
            y = cast(byte)(lower_left_y*2-1);

            x2 = cast(byte)(lower_left_x2*2+1);
            y2 = cast(byte)(lower_left_y2*2-1);
            
            x3 = x;
            y3 = y;
        }
        
    this(byte lower_left_x, byte lower_left_y, byte lower_left_x2, byte lower_left_y2,
         byte lower_left_x3, byte lower_left_y3)
        in { assert(abs(lower_left_x3*2) <= byte.max && abs(lower_left_y3*2) <= byte.max); }
        body {
            this(lower_left_x, lower_left_y, lower_left_x2, lower_left_y2);
            
            x3 = cast(byte)(lower_left_x3*2+1);
            y3 = cast(byte)(lower_left_y3*2-1);
        }

    pure:
    byte[2][4] project_on_cbsd(CubeSideData cbsd) {
        // an normale erkennbar welche koordinate fix ist
        // die koodinaten zu UVs umformen? cast(byte)(foo*2)?
        
        byte x = this.x;
        byte y = this.y;
        
        size_t index_1;
        size_t index_2;
        
        // n is the counterpart to s, it allows to midify the x coordinates
        float n = 1.0f;
        // used to flip the signs if normal doesn't point toward +y
        // since in OpenGL +y goes up but in the texture atlas +y goes down
        float s = 1.0f;
        
        if(cbsd.normal[1] == 0.0f && cbsd.normal[2] == 0.0f) {
            // x
            index_1 = 2;
            index_2 = 1;
            s = -1.0f; // flip here
            
            n = sign(cbsd.normal[0]);
            
            // this is strange, the above works fine, except for stairs with no rotation
            // TODO: fix this
            // n = sign(-cbsd.normal[0]);
        } else if(cbsd.normal[0] == 0.0f && cbsd.normal[2] == 0.0f) {
            // y
            index_1 = 0;
            index_2 = 2;
            n = sign(cbsd.normal[1]);
            
            if(n > 0) { // y+
                x = x2;
                y = y2;
            } else if(n < 0) { // y-
                x = x3;
                y = y3;
            }
        } else if(cbsd.normal[0] == 0.0f && cbsd.normal[1] == 0.0f) {
            // z
            index_1 = 0;
            index_2 = 1;
            s = -1.0f; // flip here
            n = sign(cbsd.normal[2]);
        } else {
            assert(false, "normal not supported");
        }
        
        byte[2][4] ret;
        
        foreach(i, ref vertex; cbsd.positions) {
            ret[i][0] = cast(byte)(x + vertex[index_1]*2*n);
            ret[i][1] = cast(byte)(y + vertex[index_2]*2*s);
        }
        
        return ret;
    }
}


immutable CubeSideData[2] STAIR_VERTICES_NEAR = [
    { [[-0.5f, 0.0f, 0.0f], [0.5f, 0.0f, 0.0f], [0.5f, 0.5f, 0.0f], [-0.5f, 0.5f, 0.0f]], // upper
      [0.0f, 0.0f, 1.0f] },

    { [[-0.5f, -0.5f, 0.5f], [0.5f, -0.5f, 0.5f], [0.5f, 0.0f, 0.5f], [-0.5f, 0.0f, 0.5f]], // lower
      [0.0f, 0.0f, 1.0f] }
];

immutable CubeSideData[1] STAIR_VERTICES_FAR = [
    { [[-0.5f, 0.5f, -0.5f], [0.5f, 0.5f, -0.5f], [0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, -0.5f]],
      [0.0f, 0.0f, -1.0f] }
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

immutable CubeSideData[2] STAIR_VERTICES_TOP = [
    { [[-0.5f, 0.5f, 0.0f], [0.5f, 0.5f, 0.0f], [0.5f, 0.5f, -0.5f], [-0.5f, 0.5f, -0.5f]],
      [0.0f, 1.0f, 0.0f] },
      
    { [[-0.5f, 0.0f, 0.5f], [0.5f, 0.0f, 0.5f], [0.5f, 0.0f, 0.0f], [-0.5f, 0.0f, 0.0f]], // near
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
    byte[2][6] texcoords;
    byte[2][6] mask;

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
