module brala.dine.builder.vertices_.rails;

private {
    import brala.dine.builder.tessellator : Vertex;
    import brala.dine.builder.vertices : CubeSideData;
    import brala.dine.builder.vertices_.util;
}


immutable CubeSideData RAIL_VERTEX = {
    [[-0.5f, -0.485f, 0.5f], [0.5f, -0.485f, 0.5f], [0.5f, -0.485f, -0.5f], [-0.5f, -0.485f, -0.5f]],
     [0.0f, 1.0f, 0.0f]
};


Vertex[] simple_rail(short[2][4] texture_slice, Facing face) pure {
    Vertex[] ret;
    CubeSideData cbsd = RAIL_VERTEX;

    alias texture_slice mask_slice;

    {
        mixin(mk_vertices_adv("to_triangles", true));
        ret ~= data;
    }

//     {
//         mixin(mk_vertices_adv("to_triangles_other_winding", false));
//         ret ~= data;
//     }

    return ret;
}

immutable CubeSideData RAIL_ASCENDING_VERTEX = {
    [[-0.5f, 0.515f, 0.5f], [0.5f, 0.515f, 0.5f], [0.5f, -0.485f, -0.5f], [-0.5f, -0.485f, -0.5f]],
     [0.0f, 1.0f, 0.0f]
};

Vertex[] simple_ascending_rail(short[2][4] texture_slice, Facing face) pure {
    Vertex[] ret;
    CubeSideData cbsd = RAIL_ASCENDING_VERTEX;

    alias texture_slice mask_slice;

    {
        mixin(mk_vertices_adv("to_triangles", true));
        ret ~= data;
    }

    {
        mixin(mk_vertices_adv("to_triangles_other_winding", false));
        ret ~= data;
    }

    return ret;
}