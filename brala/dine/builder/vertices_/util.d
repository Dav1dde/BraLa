module brala.dine.builder.vertices_.util;

private {
    import brala.dine.builder.vertices : CubeSideData;
}

public import brala.dine.builder.constants;

T[6] to_triangles(T)(T[4] quad) {
    return [quad[0], quad[1], quad[2],
            quad[0], quad[2], quad[3]];
}

T[6] to_triangles_other_winding(T)(T[4] quad) {
    return [quad[1], quad[0], quad[2],
            quad[2], quad[0], quad[3]];
}


// stuipid dmd bug ...
/+package+/ enum short[2][4] nslice = [[cast(short)-1, cast(short)-1],
                                       [cast(short)-1, cast(short)-1],
                                       [cast(short)-1, cast(short)-1],
                                       [cast(short)-1, cast(short)-1]];

// stuipid dmd bug ...
/+package+/ enum mk_vertices = mk_vertices_adv(`to_triangles`);

package string mk_vertices_adv(string tri_func, bool rotate = false) pure {
    string r = "";

    if(rotate) {
        r = `static if(is(typeof(face) == Facing)) {
                final switch(face) {
                    case Facing.WEST:  cbsd = cbsd.rotate_90();  break;
                    case Facing.NORTH: cbsd = cbsd.rotate_180(); break;
                    case Facing.EAST:  cbsd = cbsd.rotate_270(); break;
                    case Facing.SOUTH: break;
                }
            } else {
                final switch(face) {
                    case Side.NEAR:   break; // south
                    case Side.LEFT:   cbsd = cbsd.rotate_90(); break;
                    case Side.FAR:    cbsd = cbsd.rotate_180(); break;
                    case Side.RIGHT:  cbsd = cbsd.rotate_270(); break;
                    case Side.TOP:    cbsd = cbsd.rotate_y270(); break;
                    case Side.BOTTOM: cbsd = cbsd.rotate_y90(); break;
                    case Side.ALL: assert(false, "Side.ALL not supported"); break;
                }
            }`;
    }
    
    return r ~ `
    float[3][6] positions = ` ~ tri_func ~ `(cbsd.positions);
    short[2][6] texcoords = ` ~ tri_func ~ `(texture_slice);
    short[2][6] mask;
    if(mask_slice == nslice) {
        mask = texcoords;
    } else {
        mask = ` ~ tri_func ~ `(mask_slice);
    }

    Vertex[6] data;

    foreach(i; 0..6) {
        data[i] = Vertex(positions[i][0], positions[i][1], positions[i][2],
//                          cbsd.normal[0], cbsd.normal[1], cbsd.normal[2],
                         0, 0, 0, 0,
                         texcoords[i][0], texcoords[i][1],
                         mask[i][0], mask[i][1]);
    }`;
}


package string mk_stair_vertex(string v) pure {
    return `
        cbsd = ` ~ v ~ `;

        final switch(face) {
            case Facing.WEST:  cbsd = cbsd.rotate_90();  break;
            case Facing.NORTH: cbsd = cbsd.rotate_180(); break;
            case Facing.EAST:  cbsd = cbsd.rotate_270(); break;
            case Facing.SOUTH: break;
        }
        
        if(upside_down) {
            cbsd = cbsd.make_upsidedown();
            positions = to_triangles_other_winding(cbsd.positions);
            texcoords = to_triangles_other_winding(texture_slice.project_on_cbsd(cbsd));
        } else {
            positions = to_triangles(cbsd.positions);
            texcoords = to_triangles(texture_slice.project_on_cbsd(cbsd));
        }

        foreach(i; 0..6) {
            ret ~= Vertex(positions[i][0], positions[i][1], positions[i][2],
//                           cbsd.normal[0], cbsd.normal[1], cbsd.normal[2],
                          0, 0, 0, 0,
                          texcoords[i][0], texcoords[i][1],
                          texcoords[i][0], texcoords[i][1]);
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
    
    auto x = cbsd.normal[0];
    cbsd.normal[0] = -cbsd.normal[2];
    cbsd.normal[2] = x;

    return cbsd;
}

CubeSideData rotate_180(CubeSideData cbsd) pure {
//     foreach(ref vertex; cbsd.positions) {
//         vertex[0] = -vertex[0];
//         vertex[2] = -vertex[2];
//     }

    // same bug as with make_upsidedown
    cbsd.positions[0][0] *= -1;
    cbsd.positions[0][2] *= -1;

    cbsd.positions[1][0] *= -1;
    cbsd.positions[1][2] *= -1;

    cbsd.positions[2][0] *= -1;
    cbsd.positions[2][2] *= -1;

    cbsd.positions[3][0] *= -1;
    cbsd.positions[3][2] *= -1;

    cbsd.normal[0] *= -1;
    cbsd.normal[2] *= -1;

    return cbsd;
}

CubeSideData rotate_270(CubeSideData cbsd) pure {
    foreach(ref vertex; cbsd.positions) {
        auto x = vertex[0];
        vertex[0] = vertex[2];
        vertex[2] = -x;
    }

    auto x = cbsd.normal[0];
    cbsd.normal[0] = cbsd.normal[2];
    cbsd.normal[2] = -x;

    return cbsd;
}


CubeSideData rotate_y90(CubeSideData cbsd) pure {
    float x;

    for(size_t i = 0; i < 4; i++) {
        x = cbsd.positions[i][1];
        cbsd.positions[i][1] = -cbsd.positions[i][2];
        cbsd.positions[i][2] = x;
    }

    x = cbsd.normal[1];
    cbsd.normal[1] = -cbsd.normal[2];
    cbsd.normal[2] = x;

    return cbsd;
}

CubeSideData rotate_y270(CubeSideData cbsd) pure {
    float x;

    for(size_t i = 0; i < 4; i++) {
        x = cbsd.positions[i][1];
        cbsd.positions[i][1] = cbsd.positions[i][2];
        cbsd.positions[i][2] = -x;
    }

    x = cbsd.normal[1];
    cbsd.normal[1] = cbsd.normal[2];
    cbsd.normal[2] = -x;

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

    cbsd.normal[1] *= -1;

    return cbsd;
}

void rotate_90(ref short[2][4] inp) pure {
    foreach(ref t; inp) {
        short x = t[0];
        t[0] = -t[1];
        t[1] = x;
    }
}

void rotate_180(ref short[2][4] inp) pure {
    foreach(ref t; inp) {
        t[0] = -t[0];
        t[1] = -t[1];
    }
}

void rotate_270(ref short[2][4] inp) pure {
    foreach(ref t; inp) {
        short x = t[0];
        t[0] = t[1];
        t[1] = -x;
    }
}