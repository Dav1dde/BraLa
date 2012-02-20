module brala.util;

private {
    import derelict.opengl3.gl3;
    
    import gl3n.linalg : vec3;
}

void clear(vec3 color = vec3(0.0f, 0.0f, 0.0f)) {
    glClearColor(color.r, color.g, color.b, 1.0f);
    glClearDepth(1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}