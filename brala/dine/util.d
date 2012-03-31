module brala.dine.util;

private {
    import gl3n.util : is_vector;
}

uint log2_ub(uint v) { // unrolled bitwise log2
    uint r = 0;
    
    if(v > 0xffff) {
        v >>= 16;
        r = 16;
    }
    if(v > 0x00ff) {
        v >>= 8;
        r += 8;
    }
    if(v > 0x000f) {
        v >>= 4;
        r += 4;
    }
    if(v > 0x0003) {
        v >>= 2;
        r += 2;
    }
    
    return r + (v >> 1);
}

T[6] to_triangles(T)(T[4] quad) {
    return [quad[0], quad[1], quad[2],
            quad[0], quad[2], quad[3]];
}

T.vt[] raw_vectors(T)(T[] vecs) if(is_vector!T) {
    T.vt[] ret;
    foreach(vec; vecs) {
        ret ~= vec.vector;
    }
    return ret;
}

package string add_vertices(string block, string name, bool specific_offset = false) {
    string arr_name;
    string x_offset = "x_offset";
    string y_offset = "y_offset";
    string z_offset = "z_offset";

    final switch(name) {
        case "left": arr_name = "BLOCK_VERTICES_LEFT"; if(specific_offset) { x_offset = "x_offset_r"; } break;
        case "bottom": arr_name = "BLOCK_VERTICES_BOTTOM"; if(specific_offset) { y_offset = "y_offset_t"; } break;
        case "far": arr_name = "BLOCK_VERTICES_FAR"; if(specific_offset) { z_offset = "z_offset_n"; } break;
        case "right": arr_name = "BLOCK_VERTICES_RIGHT"; break;
        case "top": arr_name = "BLOCK_VERTICES_TOP"; break;
        case "near": arr_name = "BLOCK_VERTICES_NEAR"; break;
    }

    return `
        float[] vertices = ` ~ arr_name ~ `[` ~ block ~ `.id];
        v[w..(w+(vertices.length))] = vertices;
        for(size_t rw = w; w < (rw+vertices.length); w += 5) {
            v[w++] += ` ~ x_offset ~ `;
            v[w++] += ` ~ y_offset ~ `;
            v[w++] += ` ~ z_offset ~ `;
        }
        `;
}