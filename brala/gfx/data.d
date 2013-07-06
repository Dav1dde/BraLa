module brala.gfx.data;

private {
    import glamour.gl;
    import glamour.shader : Shader;
    import glamour.vbo : Buffer;

    import gl3n.math : sign;

    import std.string : format;

    import brala.engine : BraLaEngine;
}


align(1) struct Vertex {
    align(1):
    float x;
    float y;
    float z;
    ubyte normal;
    ubyte r;
    ubyte g;
    ubyte b;
    short u_terrain;
    short v_terrain;
    short u_mask;
    short v_mask;
    ubyte sky_light;
    ubyte block_light;
    short pad;

    static void bind(Shader shader, Buffer vbo) {
        enum stride = Vertex.sizeof;

        vbo.bind(shader, "position", GL_FLOAT,         3, 0,  stride);
        vbo.bind(shader, "normal",   GL_UNSIGNED_BYTE, 1, 12, stride);
        vbo.bind(shader, "color",    GL_UNSIGNED_BYTE, 3, 13, stride, true); // normalize it
        vbo.bind(shader, "texcoord", GL_SHORT,         2, 16, stride);
        vbo.bind(shader, "mask",     GL_SHORT,         2, 20, stride);
//         vbo.bind(shader, "light",    GL_UNSIGNED_BYTE, 2, 22, stride);
    }
}
static assert(Vertex.sizeof % 4 == 0, "Vertex size must be multiple of 4");

align(1) struct LightVertex {
    align(1):
    float x;
    float y;
    float z;
}


enum float normals[] = [
    // Blocks
    0.0,  0.0,  1.0, 0.0, // z+
   -1.0,  0.0,  0.0, 0.0, // x-
    0.0,  0.0, -1.0, 0.0, // z-
    1.0,  0.0,  0.0, 0.0, // x+
    0.0,  1.0,  0.0, 0.0, // y+
    0.0, -1.0,  0.0, 0.0, // y-

    // Plants
   -1.0,  0.0, -1.0, 0.0, // x- z-
   -1.0,  0.0,  1.0, 0.0, // x- z+
    1.0,  0.0, -1.0, 0.0, // x+ z-
    1.0,  0.0,  1.0, 0.0, // x+ z+
];

enum Normal : ubyte {
    // Blocks
    Z_POSITIVE, // Side.NEAR
    X_NEGATIVE, // Side.LEFT
    Z_NEGATIVE, // Side.FAR
    X_POSITIVE, // Side.RIGHT
    Y_POSITIVE, // Side.TOP
    Y_NEGATIVE, // Side.BOTTOM

    // Plants
    X_NEGATIVE_Z_NEGATIVE,
    X_NEGATIVE_Z_POSITIVE,
    X_POSITIVE_Z_NEGATIVE,
    X_POSITIVE_Z_POSITIVE
}

/// UFCS
Shader set_normals_uniform(Shader shader, string name) {
    shader.uniform4fv(name, normals);
    return shader;
}

Shader set_normals_uniform(BraLaEngine engine, string name) {
    return engine.current_shader.set_normals_uniform(name);
}

Normal get_normal(float x, float y, float z) {
    int sx = cast(int)sign(x);
    int sy = cast(int)sign(y);
    int sz = cast(int)sign(z);

    if(sx == 0 && sy == 0 && sz == 1) {
        return Normal.Z_POSITIVE;
    } else if(sx == 0 && sy == 0 && sz == -1) {
        return Normal.Z_NEGATIVE;
    } else if(sx == 1 && sy == 0 && sz == 0) {
        return Normal.X_POSITIVE;
    } else if(sx == -1 && sy == 0 && sz == 0) {
        return Normal.X_NEGATIVE;
    } else if(sx == 0 && sy == 1 && sz == 0) {
        return Normal.Y_POSITIVE;
    } else if(sx == 0 && sy == -1 && sz == 0) {
        return Normal.Y_NEGATIVE;
    } else if(sx == -1 && sy == 0 && sz == -1) {
        return Normal.X_NEGATIVE_Z_NEGATIVE;
    } else if(sx == -1 && sy == 0 && sz == 1) {
        return Normal.X_NEGATIVE_Z_POSITIVE;
    } else if(sx == 1 && sy == 0 && sz == -1) {
        return Normal.X_POSITIVE_Z_NEGATIVE;
    } else if(sx == 1 && sy == 0 && sz == 1) {
        return Normal.X_POSITIVE_Z_POSITIVE;
    }

    assert(false, "Broken normal! (%s %s %s)".format(x, y, z));
}

// TODO: check normals
@safe pure nothrow
Normal rotate_90(Normal normal) {
    final switch(normal) with(Normal) {
        case Z_POSITIVE: return X_NEGATIVE;
        case Z_NEGATIVE: return X_POSITIVE;
        case X_POSITIVE: return Z_POSITIVE;
        case X_NEGATIVE: return Z_NEGATIVE;
        case Y_POSITIVE: return Y_POSITIVE;
        case Y_NEGATIVE: return Y_NEGATIVE;
        case X_NEGATIVE_Z_NEGATIVE: return X_POSITIVE_Z_NEGATIVE;
        case X_NEGATIVE_Z_POSITIVE: return X_NEGATIVE_Z_NEGATIVE;
        case X_POSITIVE_Z_NEGATIVE: return X_POSITIVE_Z_POSITIVE;
        case X_POSITIVE_Z_POSITIVE: return X_NEGATIVE_Z_POSITIVE;
    }
}

@safe pure nothrow
Normal rotate_180(Normal normal) {
    final switch(normal) with(Normal) {
        case Z_POSITIVE: return Z_NEGATIVE;
        case Z_NEGATIVE: return Z_POSITIVE;
        case X_POSITIVE: return X_NEGATIVE;
        case X_NEGATIVE: return X_POSITIVE;
        case Y_POSITIVE: return Y_POSITIVE;
        case Y_NEGATIVE: return Y_NEGATIVE;
        case X_NEGATIVE_Z_NEGATIVE: return X_POSITIVE_Z_POSITIVE;
        case X_NEGATIVE_Z_POSITIVE: return X_POSITIVE_Z_NEGATIVE;
        case X_POSITIVE_Z_NEGATIVE: return X_NEGATIVE_Z_POSITIVE;
        case X_POSITIVE_Z_POSITIVE: return X_NEGATIVE_Z_NEGATIVE;
    }
}

@safe pure nothrow
Normal rotate_270(Normal normal) {
    final switch(normal) with(Normal) {
        case Z_POSITIVE: return X_POSITIVE;
        case Z_NEGATIVE: return X_NEGATIVE;
        case X_POSITIVE: return Z_NEGATIVE;
        case X_NEGATIVE: return Z_POSITIVE;
        case Y_POSITIVE: return Y_POSITIVE;
        case Y_NEGATIVE: return Y_NEGATIVE;
        case X_NEGATIVE_Z_NEGATIVE: return X_NEGATIVE_Z_POSITIVE;
        case X_NEGATIVE_Z_POSITIVE: return X_POSITIVE_Z_POSITIVE;
        case X_POSITIVE_Z_NEGATIVE: return X_NEGATIVE_Z_NEGATIVE;
        case X_POSITIVE_Z_POSITIVE: return X_POSITIVE_Z_NEGATIVE;
    }
}

@safe pure nothrow
Normal rotate_y90(Normal normal) {
    final switch(normal) with(Normal) {
        case Z_POSITIVE: return Y_NEGATIVE;
        case Z_NEGATIVE: return Y_POSITIVE;
        case X_POSITIVE: return X_POSITIVE;
        case X_NEGATIVE: return X_NEGATIVE;
        case Y_POSITIVE: return Z_POSITIVE;
        case Y_NEGATIVE: return Z_NEGATIVE;
        case X_NEGATIVE_Z_NEGATIVE: return X_NEGATIVE_Z_POSITIVE;
        case X_NEGATIVE_Z_POSITIVE: return X_NEGATIVE_Z_POSITIVE;
        case X_POSITIVE_Z_NEGATIVE: return X_POSITIVE_Z_NEGATIVE;
        case X_POSITIVE_Z_POSITIVE: return X_POSITIVE_Z_POSITIVE;
    }
}

@safe pure nothrow
Normal rotate_y270(Normal normal) {
    final switch(normal) with(Normal) {
        case Z_POSITIVE: return Y_POSITIVE;
        case Z_NEGATIVE: return Y_NEGATIVE;
        case X_POSITIVE: return X_POSITIVE;
        case X_NEGATIVE: return X_NEGATIVE;
        case Y_POSITIVE: return Z_NEGATIVE;
        case Y_NEGATIVE: return Z_POSITIVE;
        case X_NEGATIVE_Z_NEGATIVE: return X_NEGATIVE_Z_POSITIVE;
        case X_NEGATIVE_Z_POSITIVE: return X_NEGATIVE_Z_POSITIVE;
        case X_POSITIVE_Z_NEGATIVE: return X_POSITIVE_Z_NEGATIVE;
        case X_POSITIVE_Z_POSITIVE: return X_POSITIVE_Z_POSITIVE;
    }
}