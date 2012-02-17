module brala.camera;

private {
    import gl3n.linalg;
    import gl3n.math;
    
    import brala.engine : BraLaEngine;
}


struct Camera {
    BraLaEngine engine;    
    vec3 position = vec3(0.0f, 0.0f, 0.0f);
    vec3d rotation = vec3d(0.0f, 0.0f, 0.0f);
    float fov = 45.0f;
    float near = 1.0f;
    float far = 400.0f;
    
    this(BraLaEngine engine) {
        this.engine = engine;
    }
    
    this(BraLaEngine engine, vec3 position, float fov, float near, float far) {
        this.engine = engine;
        this.position = position;
        this.fov = fov;
        this.near = near;
        this.far = far;
    }
    
    Camera rotatex(double alpha) {
        rotation.x = rotation.x + alpha;
        return this;
    }
    
    Camera rotatey(double alpha) {
        rotation.y = clamp(rotation.y + alpha, cradians!(-70.0f), cradians!(70.0f));
        return this;
    }
    
    Camera rotatez(double alpha) {
        rotation.z = rotation.z + alpha;
        return this;
    }
    
    Camera set_pos(float x, float y, float z) {
        position += vec3(x, y, z);
        return this;
    }
    
    Camera set_pos(vec3 p) {
        position += p;
        return this;
    }
    
    Camera move(float x, float y, float z) {
        position += vec3(x, y, z);
        return this;
    }
    Camera move(vec3 p) {
        position += p;
        return this;
    }
    
    @property camera() {
        return mat4.identity.translate(-position.x, -position.y, -position.z)
                            .rotatex(rotation.x)
                            .rotatey(rotation.y);
    }
    
    void apply() {
        engine.proj = mat4.perspective(engine.viewport.x, engine.viewport.y, fov, near, far);
        engine.view = camera;
    }
}