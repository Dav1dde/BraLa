module brala.dine.builder.vertices_.util;

private {
    import brala.dine.builder.vertices : CubeSideData;
}

public import brala.dine.builder.constants : Side, Facing;


T[6] to_triangles(T)(T[4] quad) {
    return [quad[0], quad[1], quad[2],
            quad[0], quad[2], quad[3]];
}

T[6] to_triangles_other_winding(T)(T[4] quad) {
    return [quad[1], quad[0], quad[2],
            quad[2], quad[0], quad[3]];
}


// stuipid dmd bug ...
/+package+/ const byte[2][4] nslice = [[cast(byte)-1, cast(byte)-1],
                                       [cast(byte)1, cast(byte)-1],
                                       [cast(byte)1, cast(byte)1],
                                       [cast(byte)-1, cast(byte)1]];

// stuipid dmd bug ...
/+package+/ enum mk_vertices = `
    float[3][6] positions = to_triangles(cbsd.positions);
    byte[2][6] texcoords = to_triangles(texture_slice);
    byte[2][6] mask;
    if(mask_slice == nslice) {
        mask = texcoords;
    } else {
        mask = to_triangles(mask_slice);
    }

    Vertex[6] data;

    foreach(i; 0..6) {
        data[i] = Vertex(positions[i][0], positions[i][1], positions[i][2],
                         cbsd.normal[0], cbsd.normal[1], cbsd.normal[2],
                         0, 0, 0, 0,
                         texcoords[i][0], texcoords[i][1],
                         mask[i][0], mask[i][1]);
    }`;


package string mk_stair_vertex(string v, string m) pure {
    return `
        final switch(face) {
            case Facing.SOUTH: cbsd = ` ~ v ~ `.rotate_90(); break;
            case Facing.WEST:  cbsd = ` ~ v ~ `.rotate_180(); break;
            case Facing.NORTH: cbsd = ` ~ v ~ `.rotate_270(); break;
            case Facing.EAST: cbsd = ` ~ v ~ `; break;
        }
        if(upside_down) {
            cbsd = cbsd.make_upsidedown();
            positions = to_triangles_other_winding(cbsd.positions);
            texcoords = to_triangles_other_winding(texture_slice.` ~ m ~ `_upsidedown);
        } else {
            positions = to_triangles(cbsd.positions);
            texcoords = to_triangles(texture_slice.` ~ m ~ `);
        }


        foreach(i; 0..6) {
            ret ~= Vertex(positions[i][0], positions[i][1], positions[i][2],
                          cbsd.normal[0], cbsd.normal[1], cbsd.normal[2],
                          0, 0, 0, 0,
                          texcoords[i][0], texcoords[i][1],
                          mask[i][0], mask[i][1]);
        }`;
}

// can't make arguments `ref`, because cbsd is most likely immutable
// like this, it will be passed as mutable copy
CubeSideData rotate_90(CubeSideData cbsd) pure {
    foreach(ref vertex; cbsd.positions) {
        auto x = vertex[0];
        vertex[0] = -vertex[2];
        vertex[2] = x;
    }

    return cbsd;
}

CubeSideData rotate_180(CubeSideData cbsd) pure {
    foreach(ref vertex; cbsd.positions) {
        vertex[0] = -vertex[0];
        vertex[2] = -vertex[2];
    }

    return cbsd;
}

CubeSideData rotate_270(CubeSideData cbsd) pure {
    foreach(ref vertex; cbsd.positions) {
        auto x = vertex[0];
        vertex[0] = vertex[2];
        vertex[2] = -x;
    }

    return cbsd;
}

CubeSideData make_upsidedown(CubeSideData cbsd) pure {
//     foreach(ref vertex; cbsd.positions) {
//         vertex[1] = -vertex[1];
//     }

    // Another strange bug, the foreach above, doesn't modify the vertex
    cbsd.positions[0][1] *= -1;
    cbsd.positions[1][1] *= -1;
    cbsd.positions[2][1] *= -1;
    cbsd.positions[3][1] *= -1;
    
    cbsd.normal = -cbsd.normal[];

    return cbsd;
}