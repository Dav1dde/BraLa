module brala.gfx.tscreen;

private {
    import glamour.gl;
    import glamour.texture : Texture2D;
    import glamour.vbo : Buffer;
    import glamour.vao : VAO;

    import brala.engine : BraLaEngine;
}

enum float[] VERTEX_DATA = [
    1.0f, -1.0f,
    1, 1,
    1.0f, 1.0f,
    1, 0,
    -1.0f, -1.0f,
    0, 1,
    -1.0f, 1.0f,
    0, 0,
    -1.0f, -1.0f,
    0, 1,
    1.0f, 1.0f,
    1, 0,
];

enum float[] VERTEX_DATA_INVERTED_UVY = [
    1.0f, -1.0f,
    1, 0,
    1.0f, 1.0f,
    1, 1,
    -1.0f, -1.0f,
    0, 0,
    -1.0f, 1.0f,
    0, 1,
    -1.0f, -1.0f,
    0, 0,
    1.0f, 1.0f,
    1, 1,
];


class TScreen {
    protected BraLaEngine engine;
    protected Buffer vbo;
    protected VAO vao;

    this(BraLaEngine engine, float[] vertices) {
        this.engine = engine;
        engine.on_shutdown.connect(&shutdown);

        vao = new VAO();
        vbo = new Buffer();

        vao.bind();
        vbo.bind();

        vbo.set_data(vertices);

        auto shader = engine.use_shader("tscreen");
        vbo.bind(shader, "position", GL_FLOAT, 2, 0, 4*float.sizeof);
        vbo.bind(shader, "texcoord", GL_FLOAT, 2, 2*float.sizeof, 4*float.sizeof);

        vao.unbind();
    }

    this(BraLaEngine engine) {
        this(engine, VERTEX_DATA);
    }

    void shutdown() {
        vao.remove();
        vbo.remove();
    }

    void display(Texture2D texture) {
        engine.use_shader("tscreen");
        texture.bind_and_activate(GL_TEXTURE0);
        engine.current_shader.uniform1i("texture", 0);

        vao.bind();
        glDrawArrays(GL_TRIANGLES, 0, 6);
    }

    void display(string id) {
        engine.use_shader("tscreen");
        engine.use_texture(id, 0);

        vao.bind();
        glDrawArrays(GL_TRIANGLES, 0, 6);
    }
}

class TScreenInvertedUVY : TScreen {
    this(BraLaEngine engine) {
        super(engine, VERTEX_DATA_INVERTED_UVY);
    }
}

class SplitTScreen {
    protected BraLaEngine engine;
    protected Buffer[] vbos;
    protected VAO[] vaos;

    this(BraLaEngine engine, int x_tiles, int y_tiles, bool inverted_uvy) {
        this.engine = engine;
        engine.on_shutdown.connect(&shutdown);

        float[] base_vertices;
        if(inverted_uvy) {
            base_vertices = VERTEX_DATA_INVERTED_UVY.dup;
        } else {
            base_vertices = VERTEX_DATA.dup;
        }

        enum stride = 4;

        foreach(i; 0..base_vertices.length/stride) {
            base_vertices[i*stride] = ((base_vertices[i*stride]+1.0f) / 2.0f) / x_tiles;
            base_vertices[i*stride+1] = ((base_vertices[i*stride+1]+1.0f) / 2.0f) / y_tiles;
        }

        float[][] tiles;
        tiles.length = x_tiles * y_tiles;

        float nth_xtile = 1.0f/x_tiles;
        float nth_ytile = 1.0f/y_tiles;

        foreach(y; 0..y_tiles)
        foreach(x; 0..x_tiles) {
            float[] v = base_vertices.dup;

            foreach(i; 0..base_vertices.length/stride) {
                v[i*stride] = ((v[i*stride] + nth_xtile*x) * 2) - 1.0f;
                v[i*stride+1] = ((v[i*stride+1] + nth_ytile*y) * 2) - 1.0f;
            }

            tiles[y*x_tiles+x] = v;
        }

        auto shader = engine.use_shader("tscreen");

        foreach(tile; tiles) {
            auto vbo = new Buffer();
            auto vao = new VAO();

            vbo.bind();
            vao.bind();

            vbo.set_data(tile);

            vbo.bind(shader, "position", GL_FLOAT, 2, 0, 4*float.sizeof);
            vbo.bind(shader, "texcoord", GL_FLOAT, 2, 2*float.sizeof, 4*float.sizeof);

            vao.unbind();

            vbos ~= vbo;
            vaos ~= vao;
        }
    }

    void shutdown() {
        foreach(i; 0..vbos.length) {
            vbos[i].remove();
            vaos[i].remove();
        }
    }

    void display(Texture2D[] textures...) {
        assert(textures.length <= vaos.length, "Not enough tiles generated");

        engine.use_shader("tscreen");

        foreach(i, texture; textures) {
            texture.bind_and_activate(GL_TEXTURE0);
            engine.current_shader.uniform1i("texture", 0);

            vaos[i].bind();
            glDrawArrays(GL_TRIANGLES, 0, 6);
        }
    }

    void display(string[] ids...) {
        assert(ids.length <= vaos.length, "Not enough tiles generated");

        engine.use_shader("tscreen");

        foreach(i, id; ids) {
            engine.use_texture(id, 0);

            vaos[i].bind();
            glDrawArrays(GL_TRIANGLES, 0, 6);
        }
    }
}