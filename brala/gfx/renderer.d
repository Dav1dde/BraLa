module gfx.render;

private {
    import glamour.gl;
    import glamour.texture;
    import glamour.fbo;

    import brala.engine : BraLaEngine;
}


interface IRenderer {
    void enter();
    void exit();
}


class ForwardRenderer : IRenderer {
    BraLaEngine engine;

    this(BraLaEngine engine) {
        this.engine = engine;
    }

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

    void enter() {}
    void exit() {}

}