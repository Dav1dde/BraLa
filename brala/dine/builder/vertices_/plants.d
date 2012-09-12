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


Vertex[] simple_plant(byte[2][4] texture_slice) pure {
    return simple_plant(texture_slice, nslice);
}

Vertex[] simple_plant(byte[2][4] texture_slice, byte[2][4] mask_slice) pure {
    Vertex[] ret;

    foreach(index, CubeSideData cbsd; PLANT_VERTICES) {
        mixin(mk_vertices);

        ret ~= data;
    }

    foreach(index, CubeSideData cbsd; PLANT_VERTICES) {
        mixin(mk_vertices_adv("to_triangles_other_winding"));

        ret ~= data;
    }

    return ret;
}