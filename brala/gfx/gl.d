module brala.gfx.gl;

private {
    import glamour.gl;
    import glamour.fbo : FrameBuffer, RenderBuffer;
    import glamour.texture : Texture2D;

    import gl3n.linalg : vec3;
}


void clear(vec3 color = vec3(0.0f, 0.0f, 0.0f)) {
    glClearColor(color.r, color.g, color.b, 1.0f);
    glClearDepth(1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}


Texture2D attach_new_texture(FrameBuffer fbo, GLenum attachment_point, GLint internal_format,
                             int width, int height, GLenum format, GLenum type) {
    auto texture = new Texture2D();
    texture.set_data(cast(void*)null, internal_format, width, height,
                    format, type, true, 0);

    fbo.attach(texture, attachment_point);
    texture.unbind();

    return texture;
}

RenderBuffer attach_new_renderbuffer(FrameBuffer fbo, GLenum attachment_point,
                                     GLenum internal_format, int width, int height) {
    auto rb = new RenderBuffer();
    rb.set_storage(internal_format, width, height);
    fbo.attach(rb, attachment_point);
    return rb;
}