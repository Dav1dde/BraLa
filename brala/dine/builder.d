module brala.dine.builder;

private {
    import glamour.gl : GLenum, GL_FLOAT;
    
    import gl3n.linalg : vec2, vec3;
    
    import brala.dine.util : raw_vectors, to_triangles;
}


enum Side : ubyte {
    LEFT,
    RIGHT,
    FRONT,
    BACK,
    TOP,
    BOTTOM    
}

struct CubeSideData {
    float[3][4] positions; // 3*4, it's a cube!
    float[3] normal;
    float[2][4] texcoords;
}

// TODO texcoords
immutable CubeSideData[6] CUBE_VERTICES = [
    { [[-1.0f, -1.0f, -1.0f], [-1.0f, -1.0f, 1.0f], [-1.0f, 1.0f, 1.0f], [-1.0f, 1.0f, -1.0f]], // left
       [-1.0f, 0.0f, 0.0f],
      [[0.0f, 0.0f], [0.0f, 0.0f], [0.0f, 0.0f], [0.0f, 0.0f]] },

    { [[1.0f, -1.0f, -1.0f], [1.0f, 1.0f, -1.0f], [1.0f, 1.0f, 1.0f], [1.0f, -1.0f, 1.0f]], // right
       [1.0f, 0.0f, 0.0f],
      [[0.0f, 0.0f], [0.0f, 0.0f], [0.0f, 0.0f], [0.0f, 0.0f]] },

    { [[-1.0f, -1.0f, 1.0f], [1.0f, -1.0f, 1.0f], [1.0f, 1.0f, 1.0f], [-1.0f, 1.0f, 1.0f]], // front
       [0.0f, 0.0f, 1.0f],
      [[0.0f, 0.0f], [0.0f, 0.0f], [0.0f, 0.0f], [0.0f, 0.0f]] },

    { [[-1.0f, -1.0f, -1.0f], [-1.0f, 1.0f, -1.0f], [1.0f, 1.0f, -1.0f], [1.0f, -1.0f, -1.0f]], // back
       [0.0f, 0.0f, -1.0f],
      [[0.0f, 0.0f], [0.0f, 0.0f], [0.0f, 0.0f], [0.0f, 0.0f]] },

    { [[-1.0f, 1.0f, -1.0f], [-1.0f, 1.0f, 1.0f], [1.0f, 1.0f, 1.0f], [1.0f, 1.0f, -1.0f]], // top
       [0.0f, 1.0f, 0.0f],
      [[0.0f, 0.0f], [0.0f, 0.0f], [0.0f, 0.0f], [0.0f, 0.0f]] },

    { [[-1.0f, -1.0f, -1.0f], [1.0f, -1.0f, -1.0f], [1.0f, -1.0f, 1.0f], [-1.0f, -1.0f, 1.0f]], // bottom
       [0.0f, -1.0f, 0.0f],
      [[0.0f, 0.0f], [0.0f, 0.0f], [0.0f, 0.0f], [0.0f, 0.0f]]   }
];

float[48][6] make_raw_vertices(CubeSideData[6] csd) {
    float[48][6] ret;
    
    foreach(i; 0..6) {
        float[3][6] positions = to_triangles(csd[i].positions);
        float[2][6] texcoords = to_triangles(csd[i].texcoords);
        
        foreach(ii; 0..6) {
            ret[i][ii*8..ii*8+3] = positions[ii];
            ret[i][ii*8+3..ii*8+6] = csd[i].normal;
            ret[i][ii*8+6..ii*8+8] = texcoords[ii];
        }
    }
    
    return ret;
}

immutable float[48][6] CUBE_VERTICES_RAW = make_raw_vertices(CUBE_VERTICES);


struct BlockBuilder {
    const float factor = 0.5f;
    
    float[] block_data;
    GLenum type = GL_FLOAT;
        
    void add_side(Side side, uint xoff, uint yoff, uint zoff) {
        float[48] s = CUBE_VERTICES_RAW[side].dup;
        
        for(int i = 0; i < 48; i = i+8) {
            s[i  ] = s[i  ]*factor + xoff;
            s[i+1] = s[i+1]*factor + yoff;
            s[i+2] = s[i+2]*factor + zoff;
        }
        
        block_data ~= s;
    }
}