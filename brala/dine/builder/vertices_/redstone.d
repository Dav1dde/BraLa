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


Vertex[] simple_torch(Side side, Facing face, bool on_ground, short[2][4] texture_slice) {
    CubeSideData cbsd;

    if(on_ground) {
        cbsd = TORCH_VERTICES[side];
    } else {
        cbsd = TORCH_VERTICES_WALL[side];
    }


    alias texture_slice mask_slice;

    mixin(mk_vertices_adv("to_triangles", true));
    return data.dup;
}