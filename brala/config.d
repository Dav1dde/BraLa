module brala.config;

private {
    version(DynamicGLFW) { import derelict.glfw3.glfw3; } else { import deimos.glfw.glfw3; }

    import std.algorithm : map;
    import std.path : buildPath;
    
    import brala.resmgr;
}

enum {
    MOVE_FORWARD = GLFW_KEY_W,
    MOVE_BACKWARD = GLFW_KEY_S,
    STRAFE_LEFT = GLFW_KEY_A,
    STRAFE_RIGHT = GLFW_KEY_D,
}

immutable Resource[] resources;

static this() {
    resources = [Resource("terrain",    buildPath("res", "shader", "terrain.shader"),  SHADER_TYPE),
                 Resource("terrain",    buildPath("res", "texture", "terrain.png"),    IMAGE_TYPE),
                 Resource("grasscolor", buildPath("res", "texture", "grasscolor.png"), IMAGE_TYPE),
                 Resource("leavecolor", buildPath("res", "texture", "leavecolor.png"), IMAGE_TYPE),
                 Resource("watercolor", buildPath("res", "texture", "watercolor.png"), IMAGE_TYPE)];

}

void load_default_resources(ResourceManager rsmg, string prefix = "") {
    rsmg.add_many(resources.map!(x => Resource(x.id, buildPath(prefix, x.filename), x.type)));
}