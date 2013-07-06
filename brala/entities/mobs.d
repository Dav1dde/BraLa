module brala.entities.mobs;

private {
    import gl3n.linalg : vec3d, quat;
}


abstract class Mob {
    int entity_id;
    vec3d position;
    quat rotation;

    this(int entity_id, vec3d position = vec3d(0, 0, 0), quat rotation = quat.identity) {
        this.entity_id = entity_id;
        this.position = position;
        this.rotation = rotation;
    }
    
    void set_rotation(float yaw, float pitch, float roll = 0) {
        this.rotation = quat.euler_rotation(yaw, pitch, roll);
    }
}


class NamedEntity : Mob { // aka Player
    string name;
    
    this(int entity_id, string name, vec3d position = vec3d(0, 0, 0), quat rotation = quat.identity) {
        super(entity_id, position, rotation);
        
        this.name = name;
    }
}

class Animal : Mob {
    this(int entity_id, vec3d position = vec3d(0, 0, 0), quat rotation = quat.identity) {
        super(entity_id, position, rotation);
    }
}