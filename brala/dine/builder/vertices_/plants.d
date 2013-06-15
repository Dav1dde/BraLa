module brala.dine.builder.vertices_.plants;

private {
    import brala.gfx.data : Normal;
    import brala.dine.builder.tessellator : Vertex;
    import brala.dine.builder.vertices : CubeSideData;
    import brala.dine.builder.vertices_.util;
}


// TODO: check normals
immutable CubeSideData[4] PLANT_VERTICES = [
    { [[-0.3535533f, -0.5f, -0.3535533f], [0.3535533f, -0.5f, 0.3535533f], [0.3535533f, 0.5f, 0.3535533f], [-0.3535533f, 0.5f, -0.3535533f]],
      Normal.X_NEGATIVE_Z_POSITIVE },

    { [[-0.3535533f, -0.5f, 0.3535533f], [0.3535533f, -0.5f, -0.3535533f], [0.3535533f, 0.5f, -0.3535533f], [-0.3535533f, 0.5f, 0.3535533f]],
      Normal.X_POSITIVE_Z_POSITIVE }
];

Vertex[] simple_plant(short[2][4] texture_slice, Facing face = cast(Facing)0) pure {
    return simple_plant(texture_slice, nslice, face);
}

Vertex[] simple_plant(short[2][4] texture_slice, short[2][4] mask_slice, Facing face = cast(Facing)0) pure {
    Vertex[] ret;

    foreach(CubeSideData cbsd; PLANT_VERTICES) {
        mixin(mk_vertices_adv("to_triangles", true));

        ret ~= data;
    }

    foreach(index, CubeSideData cbsd; PLANT_VERTICES) {
        mixin(mk_vertices_adv("to_triangles_other_winding", false));

        ret ~= data;
    }

    return ret;
}


immutable CubeSideData SIDE_STEM_VERTICES = {
    [[0.0f, -0.5f, 0.5f], [0.0f, -0.5f, -0.5f], [0.0f, 0.5f, -0.5f], [0.0f, 0.5f, 0.5f]],
    Normal.X_POSITIVE
};

Vertex[] side_stem(Facing face, short[2][4] texture_slice) pure {
    return side_stem(face, texture_slice, nslice);
}

Vertex[] side_stem(Facing face, short[2][4] texture_slice, short[2][4] mask_slice) pure {
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

// TODO: check normals
immutable CubeSideData[] FOOD_PLANT_VERTICES = [
    { [[-0.3f, -0.5f, 0.5f], [-0.3f, -0.5f, -0.5f], [-0.3f, 0.5f, -0.5f], [-0.3f, 0.5f, 0.5f]],
      Normal.X_POSITIVE_Z_POSITIVE },

    { [[0.3f, -0.5f, 0.5f], [0.3f, -0.5f, -0.5f], [0.3f, 0.5f, -0.5f], [0.3f, 0.5f, 0.5f]],
      Normal.X_POSITIVE_Z_POSITIVE },
    
    { [[-0.5f, -0.5f, -0.3f], [0.5f, -0.5f, -0.3f], [0.5f, 0.5f, -0.3f], [-0.5f, 0.5f, -0.3f]],
      Normal.X_POSITIVE_Z_POSITIVE },

    { [[-0.5f, -0.5f, 0.3f], [0.5f, -0.5f, 0.3f], [0.5f, 0.5f, 0.3f], [-0.5f, 0.5f, 0.3f]],
      Normal.X_POSITIVE_Z_POSITIVE }
];

Vertex[] simple_food_plant(short[2][4] texture_slice) pure {
    return simple_food_plant(texture_slice, nslice);
}

Vertex[] simple_food_plant(short[2][4] texture_slice, short[2][4] mask_slice) pure {
    Vertex[] ret;

    foreach(CubeSideData cbsd; FOOD_PLANT_VERTICES) {
        mixin(mk_vertices_adv("to_triangles", false));

        ret ~= data;
    }

    foreach(index, CubeSideData cbsd; FOOD_PLANT_VERTICES) {
        mixin(mk_vertices_adv("to_triangles_other_winding", false));

        ret ~= data;
    }


    return ret;
}