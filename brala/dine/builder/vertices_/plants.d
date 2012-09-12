module brala.dine.builder.vertices_.plants;

private {
    import brala.dine.builder.tessellator : Vertex;
    import brala.dine.builder.vertices : CubeSideData;
    import brala.dine.builder.vertices_.util;
}


// TODO: check normals
immutable CubeSideData[2] PLANT_VERTICES = [
    { [[-0.353553f, 0.0f, -0.353553f], [0.353553, 0.0f, 0.353553f], [0.353553f, 1.0f, 0.353553f], [-0.353553f, 1.0f, -0.353553f]],
      [-0.707107f, 0.0f, 0.707107f] },

    { [[0.353553f, 1.0f, -0.353553f], [-0.353553f, 1.0f, 0.353553f], [-0.353553f, 0.0f, 0.353553f], [0.353553f, 0.0f, -0.353553f]],
      [0.707107f, 0.0f, 0.707107f] }
];


Vertex[] simple_plant(Side s, byte[2][4] texture_slice) pure {
    return simple_plant(s, texture_slice, nslice);
}

Vertex[] simple_plant(Side s, byte[2][4] texture_slice, byte[2][4] mask_slice) pure {
    Vertex[12] ret;

    foreach(index, CubeSideData cbsd; PLANT_VERTICES) {
        mixin(mk_vertices);

        data[index..index+6] = data;
    }

    return ret.dup;
}