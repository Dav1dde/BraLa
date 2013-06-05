module brala.dine.builder.vertices_.redstone;

private {
    import std.typetuple : TypeTuple;

    import gl3n.math : sign;
    
    import brala.dine.builder.tessellator : Vertex;
    import brala.dine.builder.vertices : CubeSideData;
    import brala.dine.builder.vertices_.blocks : CUBE_VERTICES;
    import brala.dine.builder.vertices_.tex : TextureSlice;
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

immutable CubeSideData[6] PISTON_ARM_VERTICES = [
    { [[-0.5f, -0.5f, 0.5f], [0.5f, -0.5f, 0.5f], [0.5f, 0.5f, 0.5f], [-0.5f, 0.5f, 0.5f]], // near
       [0.0f, 0.0f, 1.0f] },

    { [[-0.5f, -0.5f, 0.25f], [-0.5f, -0.5f, 0.5f], [-0.5f, 0.5f, 0.5f], [-0.5f, 0.5f, 0.25f]], // left
       [-1.0f, 0.0f, 0.0f] },

    { [[0.5f, -0.5f, 0.25f], [-0.5f, -0.5f, 0.25f], [-0.5f, 0.5f, 0.25f], [0.5f, 0.5f, 0.25f]], // far
       [0.0f, 0.0f, -1.0f] },

    { [[0.5f, -0.5f, 0.5f], [0.5f, -0.5f, 0.25f], [0.5f, 0.5f, 0.25f], [0.5f, 0.5f, 0.5f]], // right
       [1.0f, 0.0f, 0.0f] },

    { [[-0.5f, 0.5f, 0.5f], [0.5f, 0.5f, 0.5f], [0.5f, 0.5f, 0.25f], [-0.5f, 0.5f, 0.25f]], // top
       [0.0f, 1.0f, 0.0f]  },

    { [[-0.5f, -0.5f, 0.25f], [0.5f, -0.5f, 0.25f], [0.5f, -0.5f, 0.5f], [-0.5f, -0.5f, 0.5f]], // bottom
       [0.0f, -1.0f, 0.0f] }
];

immutable CubeSideData[6] PISTON_ARM_VERTICES_ARM = [
    { [[-0.5f, -0.5f, 0.5f], [0.5f, -0.5f, 0.5f], [0.5f, 0.5f, 0.5f], [-0.5f, 0.5f, 0.5f]], // near
       [0.0f, 0.0f, 1.0f] },

    { [[-0.125f, -0.125f, -0.75f], [-0.125f, -0.125f, 0.25f], [-0.125f, 0.125f, 0.25f], [-0.125f, 0.125f, -0.75f]], // left
       [-1.0f, 0.0f, 0.0f] },

    { [[0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, -0.5f], [-0.5f, 0.5f, -0.5f], [0.5f, 0.5f, -0.5f]], // far
       [0.0f, 0.0f, -1.0f] },

    { [[0.125f, -0.125f, 0.25f], [0.125f, -0.125f, -0.75f], [0.125f, 0.125f, -0.75f], [0.125f, 0.125f, 0.25f]], // right
       [1.0f, 0.0f, 0.0f] },

    { [[-0.125f, 0.125f, 0.25f], [0.125f, 0.125f, 0.25f], [0.125f, 0.125f, -0.75f], [-0.125f, 0.125f, -0.75f]], // top
       [0.0f, 1.0f, 0.0f]  },

    { [[-0.125f, -0.125f, -0.75f], [0.125f, -0.125f, -0.75f], [0.125f, -0.125f, 0.25f], [-0.125f, -0.125f, 0.25f]], // bottom
       [0.0f, -1.0f, 0.0f] }
];

Vertex[] piston_arm(Side side, Side face, short[2][4] texture_slice, short[2][4] arm_texture_slice) {
    Vertex[] ret;
    alias texture_slice mask_slice;

    {
        CubeSideData cbsd = PISTON_ARM_VERTICES[side];
    
        mixin(mk_vertices_adv("to_triangles", true));
        ret ~= data;
    }

    if(side != Side.NEAR && side != Side.FAR) {
        CubeSideData cbsd = PISTON_ARM_VERTICES_ARM[side];
        texture_slice = arm_texture_slice;

        mixin(mk_vertices_adv("to_triangles", true));
        ret ~= data;
    }

    return ret;    
}


immutable CubeSideData[6] TORCH_VERTICES = [
    { [[-0.125f, -0.5, 0.0625f], [0.125f, -0.5f, 0.0625f], [0.125f, 0.125f, 0.0625f], [-0.125f, 0.125f, 0.0625f]], // near
       [0.0f, 0.0f, 1.0f] },

    { [[-0.0625f, -0.5f, -0.125f], [-0.0625f, -0.5f, 0.125f], [-0.0625f, 0.125f, 0.125f], [-0.0625f, 0.125f, -0.125f]], // left
       [-1.0f, 0.0f, 0.0f] },

    { [[0.125f, -0.5f, -0.0625f], [-0.125f, -0.5f, -0.0625f], [-0.125f, 0.125f, -0.0625f], [0.125f, 0.125f, -0.0625f]], // far
       [0.0f, 0.0f, -1.0f] },

    { [[0.0625f, -0.5f, 0.125f], [0.0625f, -0.5f, -0.125f], [0.0625f, 0.125f, -0.125f], [0.0625f, 0.125f, 0.125f]], // right
       [1.0f, 0.0f, 0.0f] },

    { [[-0.0625f, 0.125f, 0.0625f], [0.0625f, 0.125f, 0.0625f], [0.0625f, 0.125f, -0.0625f], [-0.0625f, 0.125f, -0.0625f]], // top
       [0.0f, 1.0f, 0.0f]  },

    { [[-0.0625f, -0.5f, -0.0625f], [0.0625f, -0.5f, -0.0625f], [0.0625f, -0.5f, 0.0625f], [-0.0625f, -0.5f, 0.0625f]], // bottom
       [0.0f, -1.0f, 0.0f] }
];

private CubeSideData[6] cut_torch_vertices() {
    CubeSideData[6] ret;

    foreach(i, cbsd; TORCH_VERTICES) {
        foreach(ii, vertex; cbsd.positions) {
            ret[i].positions[ii] = vertex;
            if(ret[i].positions[ii][1] == 0.125f) {
                ret[i].positions[ii][1] -= 0.3125f;
            }
        }
    }

    return ret;
}

immutable CubeSideData[6] TORCH_VERTICES_CUT = cut_torch_vertices();


immutable CubeSideData[6] TORCH_VERTICES_WALL = [
    { [[-0.125f, -0.3125f, -0.4375f], [0.125f, -0.3125f, -0.4375f], [0.125f, 0.4375f, 0.0625f], [-0.125f, 0.4375f, 0.0625f]], // near
       [0.0f, 0.0f, 1.0f] },

    { [[-0.0625f, -0.3125f, -0.625f], [-0.0625f, -0.3125f, -0.375f], [-0.0625f, 0.4375f, 0.125f], [-0.0625f, 0.4375f, -0.125f]], // left
       [-1.0f, 0.0f, 0.0f] },

    { [[0.125f, -0.3125f, -0.5625f], [-0.125f, -0.3125f, -0.5625f], [-0.125f, 0.4375f, -0.0625f], [0.125f, 0.4375f, -0.0625f]], // far
       [0.0f, 0.0f, -1.0f] },

    { [[0.0625f, -0.3125f, -0.375f], [0.0625f, -0.3125f, -0.625f], [0.0625f, 0.4375f, -0.125f], [0.0625f, 0.4375f, 0.125f]], // right
       [1.0f, 0.0f, 0.0f] },

    { [[-0.0625f, 0.4375f, 0.0625f], [0.0625f, 0.4375f, 0.0625f], [0.0625f, 0.4375f, -0.0625f], [-0.0625f, 0.4375f, -0.0625f]], // top
       [0.0f, 1.0f, 0.0f]  },

    { [[-0.0625f, -0.3125f, -0.5625f], [0.0625f, -0.3125f, -0.5625f], [0.0625f, -0.3125f, -0.4375f], [-0.0625f, -0.3125f, -0.4375f]], // bottom
       [0.0f, -1.0f, 0.0f] }
];


Vertex[] simple_torch(Side side, Facing face, bool on_ground, short[2][4] texture_slice, bool adjust_height) {
    CubeSideData cbsd;

    if(on_ground) {
        cbsd = TORCH_VERTICES[side];
    } else {
        cbsd = TORCH_VERTICES_WALL[side];
    }

    if(adjust_height && side < 4) {
        foreach(i, vertex; cbsd.positions) {
            cbsd.positions[i] = vertex;
            if(cbsd.positions[i][1] == 0.125f) {
                cbsd.positions[i][1] = 0.1875f;
            }
        }
    }


    alias texture_slice mask_slice;

    mixin(mk_vertices_adv("to_triangles", true));
    return data.dup;
}

Vertex[] cut_torch(Side side, Facing face, float y_offset, float z_offset, short[2][4] texture_slice, bool adjust_height) {
    CubeSideData cbsd = TORCH_VERTICES_CUT[side];
    alias texture_slice mask_slice;

    foreach(ref v; cbsd.positions) {
        if(adjust_height && side < 4 && v[1] == 0.125f) {
            v[1] = 0.1875f;
        }

        v[1] += y_offset;
        v[2] += z_offset;
    }

    mixin(mk_vertices_adv("to_triangles", true));
    return data.dup;
}


immutable CubeSideData[6] REPEATER_VERTICES = [
    { [[-0.5f, -0.5f, 0.5f], [0.5f, -0.5f, 0.5f], [0.5f, -0.375f, 0.5f], [-0.5f, -0.375f, 0.5f]], // near
       [0.0f, 0.0f, 1.0f] },

    { [[-0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, 0.5f], [-0.5f, -0.375f, 0.5f], [-0.5f, -0.375f, -0.5f]], // left
       [-1.0f, 0.0f, 0.0f] },

    { [[0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, -0.5f], [-0.5f, -0.375f, -0.5f], [0.5f, -0.375f, -0.5f]], // far
       [0.0f, 0.0f, -1.0f] },

    { [[0.5f, -0.5f, 0.5f], [0.5f, -0.5f, -0.5f], [0.5f, -0.375f, -0.5f], [0.5f, -0.375f, 0.5f]], // right
       [1.0f, 0.0f, 0.0f] },

    { [[-0.5f, -0.375f, 0.5f], [0.5f, -0.375f, 0.5f], [0.5f, -0.375f, -0.5f], [-0.5f, -0.375f, -0.5f]], // top
       [0.0f, 1.0f, 0.0f]  },

    { [[-0.5f, -0.5f, -0.5f], [0.5f, -0.5f, -0.5f], [0.5f, -0.5f, 0.5f], [-0.5f, -0.5f, 0.5f]], // bottom
       [0.0f, -1.0f, 0.0f] }
];

Vertex[] redstone_repeater(Side side, Facing face, float offset, short[2][4] texture_slice, short[2][4] torch_tex, bool adjust_height) {
    CubeSideData cbsd = REPEATER_VERTICES[side];
    alias texture_slice mask_slice;

    mixin(mk_vertices_adv("to_triangles", true));
    return data ~ cut_torch(side, face, 0.125f, offset, torch_tex, adjust_height);
}


Vertex[] redstone_wire(Facing face, short[2][4] texture_slice, short left=8, short right=8, short top=8, short bottom=8) {
    CubeSideData cbsd;
    alias texture_slice mask_slice;

    cbsd.positions = [[left*0.0625f, -0.49f, -bottom*0.0625f],
                      [-right*0.0625f, -0.49f, -bottom*0.0625f],
                      [-right*0.0625f, -0.49f, top*0.0625f],
                      [left*0.0625f, -0.49f, top*0.0625f]];
    cbsd.normal = [0.0f, 1.0f, 0.0f];
    
    mixin(mk_vertices_adv("to_triangles", true));
    return data.dup;
}

immutable CubeSideData REDSTONE_WIRE_SIDE_VERTEX = {
    [[-0.5f, -0.5f, 0.49f], [0.5f, -0.5f, 0.49f], [0.5f, 0.5f, 0.49f], [-0.5f, 0.5f, 0.49f]],
     [0.0f, 0.0f, 1.0f]
};

Vertex[] redstone_wire_side(Facing face, short[2][4] texture_slice) {
    CubeSideData cbsd = REDSTONE_WIRE_SIDE_VERTEX;
    alias texture_slice mask_slice;

    mixin(mk_vertices_adv("to_triangles_other_winding", true));
    return data.dup;
}