module brala.dine.builder.vertices_.plants;

private {
    import brala.dine.builder.tessellator : Vertex;
    import brala.dine.builder.vertices : CubeSideData;
    import brala.dine.builder.vertices_.util;
}


// TODO: check normals
immutable CubeSideData[4] PLANT_VERTICES = [
    { [[-0.3535533f, -0.5f, -0.3535533f], [0.3535533f, -0.5f, 0.3535533f], [0.3535533f, 0.5f, 0.3535533f], [-0.3535533f, 0.5f, -0.3535533f]],
      [-0.707107f, 0.0f, 0.707107f] },

    { [[-0.3535533f, -0.5f, 0.3535533f], [0.3535533f, -0.5f, -0.3535533f], [0.3535533f, 0.5f, -0.3535533f], [-0.3535533f, 0.5f, 0.3535533f]],
      [0.707107f, 0.0f, 0.707107f] }
];

immutable CubeSideData SIDE_STEM_VERTICES = {
    [[0.0f, -0.5f, 0.5f], [0.0f, -0.5f, -0.5f], [0.0f, 0.5f, -0.5f], [0.0f, 0.5f, 0.5f]],
    [1.0f, 0.0f, 0.0f]
};


Vertex[] simple_plant(byte[2][4] texture_slice, Facing face = cast(Facing)0) pure {
    return simple_plant(texture_slice, nslice, face);
}

Vertex[] simple_plant(byte[2][4] texture_slice, byte[2][4] mask_slice, Facing face = cast(Facing)0) pure {
    Vertex[] ret;

    foreach(CubeSideData cbsd; PLANT_VERTICES) {
        mixin(mk_vertices_adv("to_triangles", true));

        ret ~= data;
    }

    foreach(index, CubeSideData cbsd; PLANT_VERTICES) {
        mixin(mk_vertices_adv("to_triangles_other_winding", true));

        ret ~= data;
    }

    return ret;
}

Vertex[] side_stem(Facing face, byte[2][4] texture_slice) pure {
    return side_stem(face, texture_slice, nslice);
}

Vertex[] side_stem(Facing face, byte[2][4] texture_slice, byte[2][4] mask_slice) pure {
    Vertex[] ret;

    CubeSideData cbsd = SIDE_STEM_VERTICES;

    {
        mixin(mk_vertices_adv("to_triangles", true));
        ret ~= data;
    }

    {
        mixin(mk_vertices_adv("to_triangles_other_winding", false)); // false, since cbsd is already rotated
        ret ~= data;
    }

    return ret;
}