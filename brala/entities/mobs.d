module brala.entities.mobs;

private {
    import gl3n.linalg : vec3d, quat;
}


abstract class Mob {
    int entity_id;

    this(int entity_id) {
        this.entity_id = entity_id;
    }
}


class NamedEntity : Mob { // aka Player
    string name;
    
    this(int entity_id, string name) {
        super(entity_id);
        
        this.name = name;
    }
}

class Animal : Mob {
    this(int entity_id) {
        super(entity_id);
    }
}