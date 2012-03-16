module brala.camera;

private {
    import std.conv : to;
    
    import gl3n.linalg;
    import gl3n.math;
    
    import brala.engine : BraLaEngine;
}


interface ICamera {
    @property vec3 position();
    @property void position(vec3 position);
    void look_at(vec3 position);
    void rotatex(float angle);
    void rotatey(float angle);
    quat get_rotation(vec3 comparison);
    void set_rotation(vec3 forward, float yaw, float pitch, float roll);
    void move_forward(float delta);
    void move_backward(float delta);
    void strafe_left(float delta);
    void strafe_right(float delta);    
    mat4 camera();
    void apply(BraLaEngine engine);
}


// Refering to https://github.com/mitsuhiko/webgl-meincraft/blob/master/src/camera.coffee
class BraLaCamera : ICamera {
    BraLaEngine engine;    
    vec3 _position = vec3(0.0f, 0.0f, 0.0f);
    vec3 forward = vec3(0.0f, 0.0f, 1.0f);
    float fov = 65.0f;
    float near = 1.0f;
    float far = 400.0f;
    vec3 up = vec3(0.0f, 1.0f, 0.0f);
    
    @property vec3 position() { return _position; }
    @property void position(vec3 position) { _position = position; }
    
    this() {}
    
    this(vec3 position) {
        _position = position;
    }
    
    this(vec3 position, float fov, float near, float far) {
        this._position = position;
        this.fov = fov;
        this.near = near;
        this.far = far;
    }
     
    void look_at(vec3 position) {
        forward = (position - _position).normalized;
    }
    
    void rotatex(float angle) { // degrees
        mat4 rotmat = mat4.rotation(radians(-angle), up);
        forward = vec3(rotmat * vec4(forward, 1.0f)).normalized;
    }

    void rotatey(float angle) { // degrees
        vec3 vcross = cross(up, forward);
        mat4 rotmat = mat4.rotation(radians(-angle), vcross);
        forward = vec3(rotmat * vec4(forward, 1.0f)).normalized;
    }
    
    quat get_rotation(vec3 comparison) {
        vec3 axis = cross(forward, comparison).normalized;
        float angle = to!float(asin(dot(forward, comparison)));
        return quat(angle, axis);
    }
    
    void set_rotation(vec3 forward, float yaw, float pitch, float roll) {
        quat rotation = quat.euler_rotation(yaw, pitch, 0);
        forward = vec3(rotation.to_matrix!(3, 3) * forward).normalized;
        look_at(position + forward);
    }
    
    void move_forward(float delta) { // W
        _position = _position + forward*delta;
    }
    
    void move_backward(float delta) { // S
        _position = _position - forward*delta;
    }
    
    void strafe_left(float delta) { // A
        vec3 vcross = cross(up, forward).normalized;
        _position = _position + (vcross*delta);
    }
    
    void strafe_right(float delta) { // D
        vec3 vcross = cross(up, forward).normalized;
        _position = _position - (vcross*delta);
    }
    
    @property mat4 camera() {
        vec3 target = _position + forward;
        return mat4.look_at(_position, target, up);
    }
    
    void apply(BraLaEngine engine) {
        engine.proj = mat4.perspective(engine.viewport.x, engine.viewport.y, fov, near, far);
        engine.view = camera;
    }
}