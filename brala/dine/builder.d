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

struct CubdeSideData {
    vec3[4] positions; // 3*4, it's a cube
    vec3 normal;
    vec2[4] texcoords;
}

// TODO texcoords
CubdeSideData[6] CUBE_VERTICES = [
    { [vec3(-1.0f, -1.0f, -1.0f), vec3(-1.0f, -1.0f, 1.0f), vec3(-1.0f, 1.0f, 1.0f), vec3(-1.0f, 1.0f, -1.0f)], // left
       vec3(-1.0f, 0.0f, 0.0f),
      [vec2(0.0f), vec2(0.0f), vec2(0.0f), vec2(0.0f)] },

    { [vec3(1.0f, -1.0f, -1.0f), vec3(1.0f, 1.0f, -1.0f), vec3(1.0f, 1.0f, 1.0f), vec3(1.0f, -1.0f, 1.0f)], // right
       vec3(1.0f, 0.0f, 0.0f),
      [vec2(0.0f), vec2(0.0f), vec2(0.0f), vec2(0.0f)] },

    { [vec3(-1.0f, -1.0f, 1.0f), vec3(1.0f, -1.0f, 1.0f), vec3(1.0f, 1.0f, 1.0f), vec3(-1.0f, 1.0f, 1.0f)], // front
       vec3(0.0f, 0.0f, 1.0f),
      [vec2(0.0f), vec2(0.0f), vec2(0.0f), vec2(0.0f)] },

    { [vec3(-1.0f, -1.0f, -1.0f), vec3(-1.0f, 1.0f, -1.0f), vec3(1.0f, 1.0f, -1.0f), vec3(1.0f, -1.0f, -1.0f)], // back
       vec3(0.0f, 0.0f, -1.0f),
      [vec2(0.0f), vec2(0.0f), vec2(0.0f), vec2(0.0f)] },

    { [vec3(-1.0f, 1.0f, -1.0f), vec3(-1.0f, 1.0f, 1.0f), vec3(1.0f, 1.0f, 1.0f), vec3(1.0f, 1.0f, -1.0f)], // top
       vec3(0.0f, 1.0f, 0.0f),
      [vec2(0.0f), vec2(0.0f), vec2(0.0f), vec2(0.0f)] },

    { [vec3(-1.0f, -1.0f, -1.0f), vec3(1.0f, -1.0f, -1.0f), vec3(1.0f, -1.0f, 1.0f), vec3(-1.0f, -1.0f, 1.0f)], // bottom
       vec3(0.0f, -1.0f, 0.0f),
      [vec2(0.0f), vec2(0.0f), vec2(0.0f), vec2(0.0f)] }
];
      

struct BlockBuilder {
    const float factor = 0.5f;
    
    float[] block_data;
    GLenum type = GL_FLOAT;
        
    void add_side(Side side, uint xoff, uint yoff, uint zoff) {
        CubdeSideData s = CUBE_VERTICES[side];
        
        foreach(i; 0..s.positions.length) { s.positions[i] *= factor; }
        
        block_data ~= raw_vectors(to_triangles(s.positions));
        block_data ~= s.normal.vector;
        block_data ~= raw_vectors(s.texcoords);
    }
}