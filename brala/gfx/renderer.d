module gfx.render;

private {
    import glamour.gl;
    import glamour.texture;
    import glamour.fbo;

    import brala.engine : BraLaEngine;
    import brala.gfx.tscreen : TScreen, SplitTScreen, TScreenInvertedUVY;
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
    protected SplitTScreen debug_screen;
    protected void delegate() display;

    this(BraLaEngine engine) {
        this.engine = engine;
        this.tscreen = new TScreenInvertedUVY(engine);
        this.debug_screen = new SplitTScreen(engine, 2, 2, true);
        this.fbo = new FrameBuffer();

        display = &display_scene;
//         display = &display_debug;

        update();
        // TODO investigate why this makes glDrawArrays segfault
//         engine.on_resize.connect(&update);
        engine.on_shutdown.connect!"shutdown"(this);
    }

    void update() {
        fbo.bind();
        scope(exit) fbo.unbind();

        remove_attachments();

        auto width = engine.viewport.x;
        auto height = engine.viewport.y;

        // color
        textures ~= fbo.attach_new_texture(GL_COLOR_ATTACHMENT0, GL_RGBA, width, height,
                                           GL_RGBA, GL_UNSIGNED_BYTE);
        // position
        textures ~= fbo.attach_new_texture(GL_COLOR_ATTACHMENT1, GL_RGBA, width, height,
                                           GL_RGBA, GL_FLOAT);
        // normal
        textures ~= fbo.attach_new_texture(GL_COLOR_ATTACHMENT2, GL_RGBA, width, height,
                                             GL_RGBA, GL_UNSIGNED_BYTE);
        // texcoords
        textures ~= fbo.attach_new_texture(GL_COLOR_ATTACHMENT3, GL_RGBA, width, height,
                                           GL_RGBA, GL_UNSIGNED_BYTE);


        draw_buffers = [GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1,
                        GL_COLOR_ATTACHMENT2, GL_COLOR_ATTACHMENT3];

        depth = fbo.attach_new_renderbuffer(GL_DEPTH_ATTACHMENT,
                                            GL_DEPTH_COMPONENT, width, height);
    }

    protected void remove_attachments() {
        foreach(texture; textures) {
            if(texture !is null) {
                texture.remove();
            }
        }

        if(depth !is null) {
            depth.remove();
        }
    }

    void shutdown() {
        remove_attachments();
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

        display();
    }

    protected void display_debug() {
        foreach(texture; textures) {
            texture.generate_mipmaps();
        }

        debug_screen.display(textures[3], textures[1], textures[0], textures[2]);
    }

    protected void display_scene() {
        tscreen.display(textures[0]);
    }

    void set_shader(string name) {
        engine.use_shader(name ~ "Def");
    }
}