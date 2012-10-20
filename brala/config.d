module brala.config;

private {
    version(DynamicGLFW) { import derelict.glfw3.glfw3; } else { import deimos.glfw.glfw3; }
    
    import brala.resmgr;
}

enum {
    MOVE_FORWARD = GLFW_KEY_W,
    MOVE_BACKWARD = GLFW_KEY_S,
    STRAFE_LEFT = GLFW_KEY_A,
    STRAFE_RIGHT = GLFW_KEY_D,
}

immutable Resource[] resources = [Resource("terrain", "./res/shader/terrain.shader", SHADER_TYPE),
                                  Resource("terrain", "./res/texture/terrain.png", IMAGE_TYPE),
                                  Resource("grasscolor", "./res/texture/grasscolor.png", IMAGE_TYPE),
                                  Resource("leavecolor", "./res/texture/leavecolor.png", IMAGE_TYPE),
                                  Resource("watercolor", "./res/texture/watercolor.png", IMAGE_TYPE)];

void load_default_resources(ResourceManager rsmg) {
    rsmg.add_many(resources);
}