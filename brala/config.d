module brala.config;

private {
    import derelict.glfw3.types;
    
    import brala.resmgr;
}

enum {
    MOVE_FORWARD = GLFW_KEY_W,
    MOVE_BACKWARD = GLFW_KEY_S,
    STRAFE_LEFT = GLFW_KEY_A,
    STRAFE_RIGHT = GLFW_KEY_D,
}

// put texture files to the end, since there is no multithreaded texture-loading yet
immutable Resource[] resources = [Resource("test_input", "./res/shader/test_input.shader", SHADER_TYPE),
                                  Resource("terrain", "./res/shader/terrain.shader", SHADER_TYPE),
                                  Resource("terrain", "./res/texture/terrain.png", TEXTURE2D_TYPE)];

void load_default_resources(ResourceManager rsmg = null) {
    if(rsmg is null) {
        rsmg = resmgr;
    }
    
    // Yeah wait for it, still maybe the faster way, if you load many resources
    resmgr.add_many_wait(resources);
}