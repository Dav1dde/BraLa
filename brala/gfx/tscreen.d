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

        engine.use_shader("tscreen");
        GLuint position = engine.current_shader.get_attrib_location("position");
        GLuint texcoord = engine.current_shader.get_attrib_location("texcoord");

        vbo.bind(position, GL_FLOAT, 2,    0,              4*float.sizeof);
        vbo.bind(texcoord, GL_FLOAT, 2,    2*float.sizeof, 4*float.sizeof);

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