module brala.gfx.camera;

private {
    import std.conv : to;
    
    import gl3n.linalg;
    import gl3n.math;
    
    import brala.engine : BraLaEngine;
}


abstract
class Camera {
    vec3 position = vec3(0.0f, 0.0f, 0.0f);
    vec3 rotation = vec3(0.0f, 0.0f, 0.0f);

    float fov = 70.0f;
    float near = 0.001f;
    float far = 400.0f;
    vec2i viewport;

    mat4 perspective = mat4.identity;

    abstract void rotatex(float angle);
    abstract void rotatey(float angle);

    abstract vec3 move(vec3 delta);

    abstract void move_up(float delta);
    abstract void move_down(float delta);
    abstract void move_forward(float delta);
    abstract void move_backward(float delta);
    abstract void strafe_left(float delta);
    abstract void strafe_right(float delta);

    abstract void recalculate();

    abstract mat4 camera();
    abstract void apply(BraLaEngine engine);
}

private
string make_property(string name, string pre_code = "", string post_code = "") {
    return `
        @property
        void %1$s(typeof(_%1$s) s) { %2$s _%1$s = s; %3$s }
        @property
        typeof(_%1$s) %1$s() { return _%1$s; }`.format(name, pre_code, post_code);
}

class FirstPersonCamera : Camera {
    vec3 up = vec3(0.0f, 1.0f, 0.0f);
    vec3 forward = vec3(0.0f, 0.0f, 1.0f);
    vec3 right = vec3(1.0f, 0.0f, 0.0f);

    vec3 offset = vec3(0.0f, 0.0f, 0.0f);

    this(vec3 offset = vec3(0.0f, 0.0f, 0.0f)) {
        this.offset = offset;
    }

    this(vec3 position, vec3 offset = vec3(0.0f, 0.0f, 0.0f)) {
        this.position = position;
    }

    this(vec3 position, float fov, float near, float far, vec2i viewport, vec3 offset = vec3(0.0f, 0.0f, 0.0f)) {
        this.position = position;
        this.fov = fov;
        this.near = near;
        this.far = far;
        this.viewport = viewport;
        this.offset = offset;
    }

    override void rotatex(float angle) { rotation.x = clamp(rotation.x + angle, cradians!(-85), cradians!(89)); }
    override void rotatey(float angle) { rotation.y += angle; }
    void rotatez(float angle) { rotation.z += angle; }

    override
    vec3 move(vec3 delta) {
        return position + (mat3.yrotation(rotation.y) * right  ).normalized * delta.x
                        + (up * delta.y)
                        + (mat3.yrotation(rotation.y) * forward).normalized * delta.z;
    }

    override
    void move_up(float delta) {
        position += up * delta;
    }

    override
    void move_down(float delta) {
        position -= up * delta;
    }

    override
    void move_forward(float delta) {
        position -= (mat3.yrotation(rotation.y) * forward).normalized * delta;
    }

    override
    void move_backward(float delta) {
        position += (mat3.yrotation(rotation.y) * forward).normalized * delta;
    }

    override
    void strafe_left(float delta) {
        position -= (mat3.yrotation(rotation.y) * right).normalized * delta;
    }

    override
    void strafe_right(float delta) {
        position += (mat3.yrotation(rotation.y) * right).normalized * delta;
    }

    override
    void recalculate() {
        perspective = mat4.perspective(viewport.x, viewport.y, fov, near, far);
    }

    @property override
    mat4 camera() {
        vec3 pos = -(position + offset);
        return mat4.identity.translate(pos.x, pos.y, pos.z)
                    .rotatey(-rotation.y)
                    .rotatex(rotation.x);
    }

    override
    void apply(BraLaEngine engine) {
        engine.proj = perspective;
        engine.view = camera;
    }
}

/+
class FreeCamera : Camera {
    vec3 position = vec3(0.0f, 0.0f, 0.0f);
    vec3 forward = vec3(0.0f, 0.0f, 1.0f);
    vec3 direction = vec3(0.0f, 0.0f, 1.0f);
    float fov = 70.0f;
    float near = 0.001f;
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
     
    void look_at(vec3 position) {
        forward = (position - this.position).normalized;
        direction = vec3(forward.x, 0, forward.z).normalized;
    }

    override
    void rotatex(float angle) { // degrees
        vec3 vcross = cross(up, forward);
        mat4 rotmat = mat4.rotation(-angle, vcross);
        forward = vec3(rotmat * vec4(forward, 1.0f)).normalized;
    }
    
    override
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

    override
    void move_up(float delta) {
        position += up*delta;
    }

    override
    void move_down(float delta) {
        position -= up*delta;
    }
    
    override
    void move_forward(float delta) { // W
        position += direction*delta;
    }
    
    override
    void move_backward(float delta) { // S
        position -= direction*delta;
    }
    
    override
    void strafe_left(float delta) { // A
        vec3 vcross = cross(up, direction).normalized;
        position += (vcross*delta);
    }
    
    override
    void strafe_right(float delta) { // D
        vec3 vcross = cross(up, direction).normalized;
        position -= (vcross*delta);
    }
    
    @property override
    mat4 camera() {
        vec3 target = position + forward;
        return mat4.look_at(position, target, up);
    }
    
    override
    void apply(BraLaEngine engine) {
        engine.proj = mat4.perspective(engine.viewport.x, engine.viewport.y, fov, near, far);
        engine.view = camera;
    }
}
+/