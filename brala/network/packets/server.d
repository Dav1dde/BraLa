module brala.network.packets.server;


private {
    import std.stream : Stream;
    
    import brala.network.packets.types : IPacket;
    import brala.network.packets.util : write, NULL_BYTE, NULL_UBYTE;
}

class KeepAlive : IPacket {
    final @property ubyte id() { return 0x00; }
    
    int kid;
    
    this(int id) {
        kid = id;
    }
    
    void send(Stream s) {
        write(s, id, kid);
    }
}


class Login : IPacket {
    final @property ubyte id() { return 0x01; }
    
    int eid;
    long seed;
    string level_type;
    int mode;
    byte dimension;
    byte difficulty;
    ubyte world_height;
    ubyte max_players;

    this(int eid, long seed, string level_type, int mode,
         byte dimension, byte difficulty, ubyte world_height, ubyte max_players) {
        this.eid = eid;
        this.seed = seed;
        this.level_type = level_type;
        this.mode = mode;
        this.dimension = dimension;
        this.difficulty = difficulty;
        this.world_height = world_height;
        this.max_players = max_players;
    }
       
    void send(Stream s) {
        write(s, id, eid, "",  seed, level_type, mode, dimension, difficulty, world_height, max_players);
    }
}


class Handshake : IPacket {
    final @property ubyte id() { return 0x02; }
    
    string connection_hash;
    
    this(string connection_hash) {
        this.connection_hash = connection_hash;
    }
    
    void send(Stream s) {
        write(s, id, connection_hash);
    }
}

class ChatMessage : IPacket {
    final @property ubyte id() { return 0x03; }
    
    string message;
    
    this(string message) {
        this.message = message;
    }
    
    void send(Stream s) {
        write(s, id, message);
    }
}

class TimeUpdate : IPacket {
    final @property ubyte id() { return 0x04; }
    
    long time;
    
    this(long time) {
        this.time = time;
    }
    
    void send(Stream s) {
        write(s, id, time);
    }
}

class EntityEquipment : IPacket {
    final @property ubyte id() { return 0x05; }
    
    int eid;
    short slot;
    short item_id;
    short damage;
    
    this(int eid, short slot, short item_id, short damage) {
        this.eid = eid;
        this.slot = slot;
        this.item_id = item_id;
        this.damage = damage;
    }
    
    void send(Stream s) {
        write(s, id, eid, slot, item_id, damage);
    }
}

class SpawnPosition : IPacket {
    final @property ubyte id() { return 0x06; }
    
    int x;
    int y;
    int z;
    
    this(int x, int y, int z) {
        this.x = x;
        this.y = y;
        this.z = z;
    }
    
    void send(Stream s) {
        write(s, id, x, y, z);
    }
}

class UpdateHealth : IPacket {
    final @property ubyte id() { return 0x08; }
    
    short health;
    short food;
    float food_saturation;
    
    this(short health, short food, float food_saturation) {
        this.health = health;
        this.food = food;
        this.food_saturation = food_saturation;
    }
    
    void send(Stream s) {
        write(s, id, health, food, food_saturation);
    }
}

class Respawn : IPacket {
    final @property ubyte id() { return 0x09; }
    
    byte dimension;
    byte difficulty;
    byte mode;
    short world_height;
    long seed;
    string level_type;
    
    this(byte dimension, byte difficulty, byte mode, short world_height, long seed, string level_type) {
        this.dimension = dimension;
        this.difficulty = difficulty;
        this.mode = mode;
        this.world_height = world_height;
        this.seed = seed;
        this.level_type = level_type;
    }
    
    void send(Stream s) {
        write(s, id, dimension, difficulty, mode, world_height, seed, level_type);
    }
}

class PlayerPositionLook : IPacket {
    final @property ubyte id() { return 0x0D; }
    
    double x;
    double stance; // different in the client packet
    double y;
    double z;
    float yaw;
    float pitch;
    bool on_ground;
    
    this(double x, double stance, double y, double z, float yaw, float pitch, bool on_ground) {
        this.x = x;
        this.stance = stance;
        this.y = y;
        this.z = z;
        this.yaw = yaw;
        this.pitch = pitch;
        this.on_ground = on_ground;
    }
    
    void send(Stream s) {
        write(s, id, x, stance, y, z, yaw, pitch, on_ground);
    }
}