module gfx.render;

private {
    import glamour.gl;
    import glamour.texture;
    import glamour.fbo;

    import brala.engine : BraLaEngine;
    import brala.gfx.tscreen : TScreen, TScreenInvertedUVY;
}


interface IRenderer {
    void shutdown();
    void enter();
    void exit();
    void set_shader(string);
}


class ForwardRenderer : IRenderer {
    BraLaEngine engine;

    this(BraLaEngine engine) {
        this.engine = engine;
    }

    void shutdown() {}

    void enter() {
        glClearColor(0.2f, 0.2f, 0.9f, 1.0f);
        glClearDepth(1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LEQUAL);
        glEnable(GL_CULL_FACE);

        // wireframe mode, for debugging
        //glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    }

    void exit() {}

    void set_shader(string name) {
        engine.use_shader(name);
    }
}


class DeferredRenderer : IRenderer {
    protected BraLaEngine engine;

    protected FrameBuffer fbo;
    protected Texture2D[] textures;
    protected RenderBuffer depth;
    protected uint[] draw_buffers;

    protected TScreen tscreen;

    this(BraLaEngine engine) {
        this.engine = engine;
        this.tscreen = new TScreenInvertedUVY(engine);
        this.fbo = new FrameBuffer();

        update();
        engine.on_resize.connect(&update);
        engine.on_shutdown.connect(&shutdown);
    }

    void update() {
        fbo.bind();

        foreach(tex; textures) {
            if(tex !is null) tex.remove();
        }
        if(depth !is null) depth.remove();

        foreach(i; 0..4) {
            auto tex = new Texture2D();
            tex.set_data(cast(void*)null, GL_RGBA, engine.viewport.x, engine.viewport.y,
                         GL_RGBA, GL_UNSIGNED_BYTE, true, 0);
            tex.set_parameter(GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            tex.set_parameter(GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            tex.set_parameter(GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            tex.set_parameter(GL_TEXTURE_MIN_FILTER, GL_LINEAR);

            draw_buffers ~= GL_COLOR_ATTACHMENT0+i;
            fbo.attach(tex, GL_COLOR_ATTACHMENT0+i);
            tex.unbind();

            textures ~= tex;
        }

        depth = new RenderBuffer();
        depth.set_storage(GL_DEPTH_COMPONENT, engine.viewport.x, engine.viewport.y);
        fbo.attach(depth, GL_DEPTH_ATTACHMENT);

        depth.unbind();
        fbo.unbind();
    }

    void shutdown() {
        foreach(tex; textures) {
            tex.remove();
        }

        depth.remove();
        fbo.remove();
    }

    void enter() {
        fbo.bind();

        glClearColor(0.2f, 0.2f, 0.9f, 1.0f);
        glClearDepth(1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LEQUAL);
        glEnable(GL_CULL_FACE);

//         wireframe mode, for debugging
//         glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

        glDrawBuffers(cast(int)draw_buffers.length, draw_buffers.ptr);
    }

    void exit() {
        fbo.unbind();

        tscreen.display(textures[0]);
//         tscreen.display("terrain");
    }

    void set_shader(string name) {
        engine.use_shader(name ~ "Def");
    }
}