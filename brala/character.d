module brala.character;

private {
    import std.conv : to;
    
    import gl3n.linalg : vec3, dot, cross, quat;
    import gl3n.math : asin, degrees;
    
    import brala.engine : BraLaEngine;
    import brala.camera : ICamera, BraLaCamera;
    import brala.network.connection : Connection;
    import c = brala.network.packets.client;import std.stdio;
}


class Character { // the one you're playing
    static const vec3 YAW_0_DIRECTION = vec3(0.0f, 0.0f, 1.0f);

    ICamera cam;
    @property vec3 position() { return cam.position; }
    @property void position(vec3 position) { cam.position = position; }
    
    int entity_id;
    bool activated;
    
    this(int entity_id) {
        cam = new BraLaCamera();
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
    
    quat get_rotation() {
        return cam.get_rotation(YAW_0_DIRECTION);
    }
    
    void set_rotation(float yaw, float pitch) {
        cam.set_rotation(YAW_0_DIRECTION, yaw, pitch, 0);
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
    
    void send_packet(Connection connection) {
        quat rotation = cam.get_rotation(YAW_0_DIRECTION);
        auto packet = new c.PlayerPositionLook(position.x, position.y, position.y + 0.15, position.z, // TODO: proper stance
                                               degrees(to!float(rotation.yaw)), degrees(to!float(rotation.pitch)), true); // TODO: verify bool
       
        connection.send(packet);
/+        
        auto packet1 = new c.PlayerPosition(position.x, position.y, position.y + 0.15, position.z, false);
        connection.send(packet1);
        auto packet2 = new c.PlayerLook(degrees(to!float(rotation.yaw)), degrees(to!float(rotation.pitch)), false);
        connection.send(packet2);
        writefln("%s\n%s", packet1, packet2);+/
    }
}