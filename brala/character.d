module brala.character;

private {
    import gl3n.linalg : vec3, quat;
    
    import brala.engine : BraLaEngine;
    import brala.camera : ICamera, FreeCamera;
}

class Character { // the one you're playing
    static const vec3 YAW_0_DIRECTION = vec3(0.0f, 0.0f, 1.0f);

    ICamera cam;
    @property vec3 position() { return cam.position; }
    @property void position(vec3 position) { cam.position = position; }
    
    int entity_id;
    
    this(int entity_id) {
        cam = new FreeCamera();
        this.entity_id = entity_id;
    }
    
    // forward
    void look_at(vec3 pos) {
        cam.look_at(pos);
    }
    
    void rotatex(float angle) { // degrees
        cam.rotatex(angle);
    }

    void rotatey(float angle) { // degrees
        cam.rotatey(angle);
    }
    
    void set_rotation(float yaw, float pitch, float roll = 0) {
        quat rotation = quat.euler_rotation(yaw, pitch, 0);
        vec3 forward = vec3(rotation.to_matrix!(3, 3) * YAW_0_DIRECTION).normalized;
        look_at(cam.position + forward);
    }
    
    void move_forward(float delta) { // W
        cam.move_forward(delta);
    }
    
    void move_backward(float delta) { // S
        cam.move_backward(delta);
    }
       
    void strafe_left(float delta) { // A
        cam.strafe_left(delta);
    }
    
    void strafe_right(float delta) { // D
        cam.strafe_right(delta);
    }
    
    void apply(BraLaEngine engine) {
        cam.apply(engine);
    }
}