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

immutable Resource[] resources = [];

void load_default_resources(ResourceManager rsmg = null) {
    if(rsmg is null) {
        rsmg = resmgr;
    }
    
    resmgr.add_many(resources);
}