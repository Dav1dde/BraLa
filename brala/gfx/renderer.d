module gfx.render;

private {
    import glamour.gl;
    import glamour.texture;
    import glamour.fbo;

    import brala.engine : BraLaEngine;
}


interface IRenderer {
    void shutdown();
    void enter();
    void exit();
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

        engine.use_shader("terrain");
        engine.use_texture("terrain", 0);
    }

    void exit() {}
}


class DeferredRenderer : IRenderer {
    BraLaEngine engine;
    FrameBuffer fbo;
    Texture2D[] textures;
    Texture2D depth;


    this(BraLaEngine engine) {
        this.engine = engine;
        this.fbo = new FrameBuffer();

        update();
        engine.on_resize.connect(&update);
        engine.on_shutdown.connect(&shutdown);
    }

    void update() {
        fbo.bind();

        foreach(i; 0..4) {
            auto tex = new Texture2D();
            tex.set_data(cast(void*)null, GL_RGB32F, engine.viewport.x, engine.viewport.y,
                         GL_RGB, GL_FLOAT, false, 0);
            fbo.attach(tex, GL_COLOR_ATTACHMENT0+i);

            textures ~= tex;
        }

        depth = new Texture2D();
        depth.set_data(cast(void*)null, GL_DEPTH_COMPONENT32F, engine.viewport.x, engine.viewport.y,
                       GL_DEPTH_COMPONENT, GL_FLOAT, false, 0);
        fbo.attach(depth, GL_DEPTH_ATTACHMENT);

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
        glClearColor(0.2f, 0.2f, 0.9f, 1.0f);
        glClearDepth(1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LEQUAL);
        glEnable(GL_CULL_FACE);

//         wireframe mode, for debugging
//         glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

        fbo.bind();

        auto draw_buffers = [GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1, GL_COLOR_ATTACHMENT2, GL_COLOR_ATTACHMENT3];
        glDrawBuffers(cast(int)draw_buffers.length, draw_buffers.ptr);

        engine.use_shader("terrain");
        engine.use_texture("terrain", 0);
    }

    void exit() {
        fbo.unbind();
    }

}