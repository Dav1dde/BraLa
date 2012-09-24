module brala.dine.builder.vertices_.blocks;

private {
    import brala.dine.builder.tessellator : Vertex;
    import brala.dine.builder.vertices : CubeSideData;
    import brala.dine.builder.vertices_.tex : ProjTextureSlice;
    import brala.dine.builder.vertices_.util;
}

immutable CubeSideData[6] CUBE_VERTICES = [
    { [[-0.5f, -0.5f, 0.5f], [0.5f, -0.5f, 0.5f], [0.5f, 0.5f, 0.5f], [-0.5f, 0.5f, 0.5f]], // near
       [0.0f, 0.0f, 1.0f] },

    { [[-0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, 0.5f], [-0.5f, 0.5f, 0.5f], [-0.5f, 0.5f, -0.5f]], // left
       [-1.0f, 0.0f, 0.0f] },

    { [[0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, -0.5f], [-0.5f, 0.5f, -0.5f], [0.5f, 0.5f, -0.5f]], // far
       [0.0f, 0.0f, -1.0f] },

    { [[0.5f, -0.5f, 0.5f], [0.5f, -0.5f, -0.5f], [0.5f, 0.5f, -0.5f], [0.5f, 0.5f, 0.5f]], // right
       [1.0f, 0.0f, 0.0f] },

    { [[-0.5f, 0.5f, 0.5f], [0.5f, 0.5f, 0.5f], [0.5f, 0.5f, -0.5f], [-0.5f, 0.5f, -0.5f]], // top
       [0.0f, 1.0f, 0.0f]  },

    { [[-0.5f, -0.5f, -0.5f], [0.5f, -0.5f, -0.5f], [0.5f, -0.5f, 0.5f], [-0.5f, -0.5f, 0.5f]], // bottom
       [0.0f, -1.0f, 0.0f] }
];


Vertex[] simple_block(Side side, short[2][4] texture_slice) pure {
    return simple_block(side, texture_slice, nslice, Facing.SOUTH);
}

Vertex[] simple_block(Side side, short[2][4] texture_slice, Facing face) pure {
    return simple_block(side, texture_slice, nslice, face);
}

Vertex[] simple_block(Side side, short[2][4] texture_slice, short[2][4] mask_slice, Facing face) pure {
    CubeSideData cbsd = CUBE_VERTICES[side];

    mixin(mk_vertices_adv("to_triangles", true));
    return data.dup;
}


immutable CubeSideData[6] CUBE_VERTICES_FARMLAND = [
    { [[-0.5f, -0.5f, 0.5f], [0.5f, -0.5f, 0.5f], [0.5f, 0.4375f, 0.5f], [-0.5f, 0.4375f, 0.5f]], // near
       [0.0f, 0.0f, 1.0f] },

    { [[-0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, 0.5f], [-0.5f, 0.4375f, 0.5f], [-0.5f, 0.4375f, -0.5f]], // left
       [-1.0f, 0.0f, 0.0f] },

    { [[0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, -0.5f], [-0.5f, 0.4375f, -0.5f], [0.5f, 0.4375f, -0.5f]], // far
       [0.0f, 0.0f, -1.0f] },

    { [[0.5f, -0.5f, 0.5f], [0.5f, -0.5f, -0.5f], [0.5f, 0.4375f, -0.5f], [0.5f, 0.4375f, 0.5f]], // right
       [1.0f, 0.0f, 0.0f] },

    { [[-0.5f, 0.4375f, 0.5f], [0.5f, 0.4375f, 0.5f], [0.5f, 0.4375f, -0.5f], [-0.5f, 0.4375f, -0.5f]], // top
       [0.0f, 1.0f, 0.0f]  },

    { [[-0.5f, -0.5f, -0.5f], [0.5f, -0.5f, -0.5f], [0.5f, -0.5f, 0.5f], [-0.5f, -0.5f, 0.5f]], // bottom
       [0.0f, -1.0f, 0.0f] }
];

Vertex[] farmland_block(Side side, ProjTextureSlice texture_slice) pure {
    CubeSideData cbsd = CUBE_VERTICES_FARMLAND[side];
    
    float[3][6] positions = to_triangles(cbsd.positions);
    short[2][6] texcoords = to_triangles(texture_slice.project_on_cbsd(cbsd));

    Vertex[6] data;

    foreach(i; 0..6) {
        data[i] = Vertex(positions[i][0], positions[i][1], positions[i][2],
//                          cbsd.normal[0], cbsd.normal[1], cbsd.normal[2],
                         0, 0, 0, 0,
                         texcoords[i][0], texcoords[i][1],
                         texcoords[i][0], texcoords[i][1]);
    }

    return data.dup;
}