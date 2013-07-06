module brala.gfx.world;

private {
    import glamour.gl;
    import glamour.vbo : Buffer;
    import glamour.vao : VAO;

    import core.time : TickDuration;

    import brala.engine : BraLaEngine;
    import brala.gfx.renderer : IRenderer;
    import brala.gfx.data : set_normals_uniform;
    import brala.dine.world : World;
}

void draw(World world, BraLaEngine engine, IRenderer renderer) {
    if(world is null) return;

    renderer.set_shader("terrain");
    world.postprocess_chunks();

    engine.current_shader.set_normals_uniform("normals");
    engine.use_texture("terrain", 0);

    engine.flush_uniforms();
    engine.current_shader.uniform("texture_size", world.atlas.dimensions);

    auto frustum = engine.frustum;

    foreach(chunkc, chunk; world.chunks) {
        world.check_chunk(chunk, chunkc);

        if(chunk.vbo !is null && chunk.vao !is null) {
            if(chunk.aabb in frustum) {
                chunk.vao.bind();
                glDrawArrays(GL_TRIANGLES, 0, cast(uint)chunk.vbo_vcount);
            }
        }
    }
}

void draw_lights(World world) {
    foreach(chunkc, chunk; world.chunks) {

    }
}