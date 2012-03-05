module brala.camera;

private {
    import gl3n.linalg;
    import gl3n.math;
    
    import brala.engine : BraLaEngine;
}


interface ICamera {
    void look_at(vec3 pos);
    void rotatex(float angle);
    void rotatey(float angle);
    void move_forward(float delta);
    void move_backward(float delta);
    void strafe_left(float delta);
    void strafe_right(float delta);    
    mat4 camera();
    void apply(BraLaEngine engine);
}


// Refering to https://github.com/mitsuhiko/webgl-meincraft/blob/master/src/camera.coffee
class FreeCamera : ICamera {
    BraLaEngine engine;    
    vec3 position = vec3(0.0f, 0.0f, 0.0f);
    vec3 forward = vec3(0.0f, 0.0f, -1.0f);
    float fov = 45.0f;
    float near = 1.0f;
    float far = 400.0f;
    vec3 up = vec3(0.0f, 1.0f, 0.0f);
    
    this() {}
    
    this(vec3 position) {
        this.position = position;
    }
    
    this(vec3 position, float fov, float near, float far) {
        this.position = position;
        this.fov = fov;
        this.near = near;
        this.far = far;
    }
     
    void look_at(vec3 pos) {
        forward = (pos - position).normalized;
    }
    
    void rotatex(float angle) { // degrees
        mat4 rotmat = mat4.rotation(radians(-angle), up);
        forward = vec3(rotmat * vec4(forward, 1.0f)).normalized;
    }

    void rotatey(float angle) { // degrees
        vec3 vcross = cross(up, forward);
        mat4 rotmat = mat4.rotation(radians(-angle), up);
        forward = vec3(rotmat * vec4(forward, 1.0f)).normalized;
    }
    
    void move_forward(float delta) { // W
        position = position + forward*delta;
    }
    
    void move_backward(float delta) { // S
        position = position - forward*delta;
    }
    
    void strafe_left(float delta) { // A
        vec3 vcross = cross(up, forward).normalized;
        position = position + (vcross*delta);
    }
    
    void strafe_right(float delta) { // D
        vec3 vcross = cross(up, forward).normalized;
        position = position - (vcross*delta);
    }
    
    @property mat4 camera() {
        vec3 target = position + forward;
        return mat4.look_at(position, target, up);
    }
    
    void apply(BraLaEngine engine) {
        engine.proj = mat4.perspective(engine.viewport.x, engine.viewport.y, fov, near, far);
        engine.view = camera;
    }
}