module brala.dine.builder.vertices_.blocks;

private {
    import brala.gfx.data : Normal;
    import brala.gfx.terrain : ProjectionTextureCoordinates;
    import brala.dine.builder.tessellator : Vertex;
    import brala.dine.builder.vertices : CubeSideData;
    import brala.dine.builder.vertices_.util;
}

immutable CubeSideData[6] CUBE_VERTICES = [
    { [[-0.5f, -0.5f, 0.5f], [0.5f, -0.5f, 0.5f], [0.5f, 0.5f, 0.5f], [-0.5f, 0.5f, 0.5f]], // near
       Normal.Z_POSITIVE },

    { [[-0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, 0.5f], [-0.5f, 0.5f, 0.5f], [-0.5f, 0.5f, -0.5f]], // left
       Normal.X_NEGATIVE },

    { [[0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, -0.5f], [-0.5f, 0.5f, -0.5f], [0.5f, 0.5f, -0.5f]], // far
       Normal.Z_NEGATIVE },

    { [[0.5f, -0.5f, 0.5f], [0.5f, -0.5f, -0.5f], [0.5f, 0.5f, -0.5f], [0.5f, 0.5f, 0.5f]], // right
       Normal.X_POSITIVE },

    { [[-0.5f, 0.5f, 0.5f], [0.5f, 0.5f, 0.5f], [0.5f, 0.5f, -0.5f], [-0.5f, 0.5f, -0.5f]], // top
       Normal.Y_POSITIVE  },

    { [[-0.5f, -0.5f, -0.5f], [0.5f, -0.5f, -0.5f], [0.5f, -0.5f, 0.5f], [-0.5f, -0.5f, 0.5f]], // bottom
       Normal.Y_NEGATIVE }
];


Vertex[] simple_block(Side side, short[2][4] texture_slice) pure {
    return simple_block(side, texture_slice, nslice, Facing.SOUTH);
}

Vertex[] simple_block(Side side, short[2][4] texture_slice, Facing face) pure {
    return simple_block(side, texture_slice, nslice, face);
}

Vertex[] simple_block(Side side, short[2][4] texture_slice, short[2][4] mask_slice) pure {
    CubeSideData cbsd = CUBE_VERTICES[side];

    mixin(mk_vertices);
    return data.dup;
}

Vertex[] simple_block(Side side, short[2][4] texture_slice, short[2][4] mask_slice, Facing face) pure {
    CubeSideData cbsd = CUBE_VERTICES[side];

    mixin(mk_vertices_adv("to_triangles", true));
    return data.dup;
}


immutable CubeSideData[6] CUBE_VERTICES_FARMLAND = [
    { [[-0.5f, -0.5f, 0.5f], [0.5f, -0.5f, 0.5f], [0.5f, 0.4375f, 0.5f], [-0.5f, 0.4375f, 0.5f]], // near
       Normal.Z_POSITIVE },

    { [[-0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, 0.5f], [-0.5f, 0.4375f, 0.5f], [-0.5f, 0.4375f, -0.5f]], // left
       Normal.X_NEGATIVE },

    { [[0.5f, -0.5f, -0.5f], [-0.5f, -0.5f, -0.5f], [-0.5f, 0.4375f, -0.5f], [0.5f, 0.4375f, -0.5f]], // far
       Normal.Z_NEGATIVE },

    { [[0.5f, -0.5f, 0.5f], [0.5f, -0.5f, -0.5f], [0.5f, 0.4375f, -0.5f], [0.5f, 0.4375f, 0.5f]], // right
       Normal.X_POSITIVE },

    { [[-0.5f, 0.4375f, 0.5f], [0.5f, 0.4375f, 0.5f], [0.5f, 0.4375f, -0.5f], [-0.5f, 0.4375f, -0.5f]], // top
       Normal.Y_POSITIVE  },

    { [[-0.5f, -0.5f, -0.5f], [0.5f, -0.5f, -0.5f], [0.5f, -0.5f, 0.5f], [-0.5f, -0.5f, 0.5f]], // bottom
       Normal.Y_NEGATIVE }
];

Vertex[] farmland_block(Side side, ProjectionTextureCoordinates texture_slice) pure {
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

immutable CubeSideData[6] CUBE_VERTICES_CACTUS = [
    { [[-0.5f, -0.5f, 0.4375f], [0.5f, -0.5f, 0.4375f], [0.5f, 0.5f, 0.4375f], [-0.5f, 0.5f, 0.4375f]], // near
       Normal.Z_POSITIVE },

    { [[-0.4375f, -0.5f, -0.5f], [-0.4375f, -0.5f, 0.5f], [-0.4375f, 0.5f, 0.5f], [-0.4375f, 0.5f, -0.5f]], // left
       Normal.X_NEGATIVE },

    { [[0.5f, -0.5f, -0.4375f], [-0.5f, -0.5f, -0.4375f], [-0.5f, 0.5f, -0.4375f], [0.5f, 0.5f, -0.4375f]], // far
       Normal.Z_NEGATIVE },

    { [[0.4375f, -0.5f, 0.5f], [0.4375f, -0.5f, -0.5f], [0.4375f, 0.5f, -0.5f], [0.4375f, 0.5f, 0.5f]], // right
       Normal.X_POSITIVE },

    { [[-0.5f, 0.5f, 0.5f], [0.5f, 0.5f, 0.5f], [0.5f, 0.5f, -0.5f], [-0.5f, 0.5f, -0.5f]], // top
       Normal.Y_POSITIVE  },

    { [[-0.5f, -0.5f, -0.5f], [0.5f, -0.5f, -0.5f], [0.5f, -0.5f, 0.5f], [-0.5f, -0.5f, 0.5f]], // bottom
       Normal.Y_NEGATIVE }
];


Vertex[] cactus_block(Side side, short[2][4] texture_slice) pure {
    CubeSideData cbsd = CUBE_VERTICES_CACTUS[side];
    short[2][4] mask_slice = texture_slice;

    mixin(mk_vertices_adv("to_triangles", false));
    return data.dup;
}