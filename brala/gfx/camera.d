module brala.gfx.camera;

private {
    import std.conv : to;
    
    import gl3n.linalg;
    import gl3n.math;
    
    import brala.engine : BraLaEngine;
}


interface ICamera {
    @property vec3 position();
    @property void position(vec3 position);

    @property vec3 rotation();
    @property void rotation(vec3 rotation);

    void rotatex(float angle);
    void rotatey(float angle);

    void move_up(float delta);
    void move_down(float delta);
    void move_forward(float delta);
    void move_backward(float delta);
    void strafe_left(float delta);
    void strafe_right(float delta);    

    mat4 camera();
    void apply(BraLaEngine engine);
}

private
string make_property(string name, string pre_code = "", string post_code = "") {
    return `
        @property
        void %1$s(typeof(_%1$s) s) { %2$s _%1$s = s; %3$s }
        @property
        typeof(_%1$s) %1$s() { return _%1$s; }`.format(name, pre_code, post_code);
}

class FirstPersonCamera : ICamera {
    vec3 _position = vec3(0.0f, 0.0f, 0.0f);
    mixin(make_property("position"));
    vec3 _rotation = vec3(0.0f, 0.0f, 0.0f);
    mixin(make_property("rotation"));

    vec3 up = vec3(0.0f, 1.0f, 0.0f);
    vec3 forward = vec3(0.0f, 0.0f, 1.0f);
    vec3 right = vec3(1.0f, 0.0f, 0.0f);

    float _fov = 70.0f;
    mixin(make_property("fov", "_dirty = true;"));
    float _near = 0.001f;
    mixin(make_property("near", "_dirty = true;"));
    float _far = 400.0f;
    mixin(make_property("far", "_dirty = true;"));
    vec2i _viewport;
    mixin(make_property("viewport", "_dirty = true;"));

    mat4 _perspective = mat4.identity;
    bool _dirty = true;

    this() {}
    this(vec3 position) {
        _position = position;
    }

    this(vec3 position, float fov, float near, float far, vec2i viewport) {
        _position = position;
        _fov = fov;
        _near = near;
        _far = far;
        _viewport = viewport;
    }

    void rotatex(float angle) { _rotation.x = clamp(_rotation.x + angle, cradians!(-85), cradians!(89)); }
    void rotatey(float angle) { _rotation.y += angle; }
    void rotatez(float angle) { _rotation.z += angle; }

    void move_up(float delta) {
        _position += up * delta;
    }

    void move_down(float delta) {
        _position -= up * delta;
    }

    void move_forward(float delta) {
        _position -= (mat3.yrotation(rotation.y) * forward).normalized * delta;
    }

    void move_backward(float delta) {
        _position += (mat3.yrotation(rotation.y) * forward).normalized * delta;
    }

    void strafe_left(float delta) {
        _position -= (mat3.yrotation(rotation.y) * right).normalized * delta;
    }

    void strafe_right(float delta) {
        _position += (mat3.yrotation(rotation.y) * right).normalized * delta;
    }

    @property
    mat4 perspective() {
        if(_dirty) {
            _perspective = mat4.perspective(viewport.x, viewport.y, fov, near, far);
            _dirty = false;
        }
        return _perspective;
    }

    @property
    mat4 camera() {
        return mat4.identity.translate(-_position.x, -_position.y, -position.z)
                    .rotatey(-rotation.y)
                    .rotatex(rotation.x);
    }

    void apply(BraLaEngine engine) {
        engine.proj = perspective;
        engine.view = camera;
    }
}

class FreeCamera : ICamera {
    vec3 _position = vec3(0.0f, 0.0f, 0.0f);
    vec3 forward = vec3(0.0f, 0.0f, 1.0f);
    vec3 direction = vec3(0.0f, 0.0f, 1.0f);
    float fov = 70.0f;
    float near = 0.001f;
    float far = 400.0f;
    vec3 up = vec3(0.0f, 1.0f, 0.0f);
    
    @property vec3 position() { return _position; }
    @property void position(vec3 position) { _position = position; }
    
    // TODO
    @property vec3 rotation() { return vec3(0.0f, 0.0f, 0.0f); }
    @property void rotation(vec3 rotation) {}

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
        direction = vec3(forward.x, 0, forward.z).normalized;
    }

    void rotatex(float angle) { // degrees
        vec3 vcross = cross(up, forward);
        mat4 rotmat = mat4.rotation(-angle, vcross);
        forward = vec3(rotmat * vec4(forward, 1.0f)).normalized;
    }
    
    void rotatey(float angle) { // degrees
        mat4 rotmat = mat4.rotation(-angle, up);
        forward = vec3(rotmat * vec4(forward, 1.0f)).normalized;
        direction = vec3(rotmat * vec4(direction, 1.0f)).normalized;
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

    void move_up(float delta) {
        _position += up*delta;
    }

    void move_down(float delta) {
        _position -= up*delta;
    }
    
    void move_forward(float delta) { // W
        _position += direction*delta;
    }
    
    void move_backward(float delta) { // S
        _position -= direction*delta;
    }
    
    void strafe_left(float delta) { // A
        vec3 vcross = cross(up, direction).normalized;
        _position += (vcross*delta);
    }
    
    void strafe_right(float delta) { // D
        vec3 vcross = cross(up, direction).normalized;
        _position -= (vcross*delta);
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