module brala.network.packets.client;

private {
    import std.stream : Stream;
    
    import brala.network.packets.types : IPacket;
    import brala.network.packets.util : write, NULL_BYTE, NULL_UBYTE;
    import server = brala.network.packets.server;
}

class KeepAlive : IPacket {
    final @property ubyte id() { return 0x00; }
    
    this() {}
    
    void send(Stream s) {
        write(s, id, 0); // the client may send packets with id 0
    }
}

class Login : IPacket {
    final @property ubyte id() { return 0x01; }
    
    int protocol_version;
    string username;
       
    this(int protocol_version, string username) {
        this.protocol_version = protocol_version;
        this.username = username;
    }
    
    void send(Stream s) {
        write(s, id, protocol_version, username, 0L, "", 0, NULL_BYTE, NULL_BYTE, NULL_UBYTE, NULL_UBYTE);
    }
}

class Handshake : IPacket {
    final @property ubyte id() { return 0x02; }
    
    string username;
    
    this(string username) {
        this.username = username;
    }
    
    void send(Stream s) {
        write(s, id, username);
    }
}

public alias server.ChatMessage ChatMessage;
public alias server.EntityEquipment EntityEquipment;

class UseEntity : IPacket {
    final @property ubyte id() { return 0x07; }
    
    int user;
    int target;
    bool left_click;
    
    this(int user, int target, bool left_click) {
        this.user = user;
        this.target = target;
        this.left_click = left_click;
    }
    
    void send(Stream s) {
        write(s, id, user, target, left_click);
    }
}

public alias server.Respawn Respawn;

class Player : IPacket {
    final @property ubyte id() { return 0x0A; }
    
    bool on_ground;
    
    this(bool on_ground) {
        this.on_ground = on_ground;
    }
    
    void send(Stream s) {
        write(s, id, on_ground);
    }
}

class PlayerPosition : IPacket {
    final @property ubyte id() { return 0x0B; }
    
    double x;
    double y;
    double stance;
    double z;
    bool on_ground;
    
    this(double x, double y, double stance, double z, bool on_ground) {
        this.x = x;
        this.y = y;
        this.stance = stance;
        this.z = z;
        this.on_ground = on_ground;    
    }
    
    void send(Stream s) {
        write(s, id, x, y, stance, z, on_ground);
    }
}

class PlayerLook : IPacket {
    final @property ubyte id() { return 0x0C; }
    
    float yaw;
    float pitch;
    bool on_ground;
    
    this(float yaw, float pitch, bool on_ground) {
        this.yaw = yaw;
        this.pitch = pitch;
        this.on_ground = on_ground;
    }
    
    void send(Stream s) {
        write(s, id, yaw, pitch, on_ground);
    }
}

class PlayerPositionLook : IPacket {
    final @property ubyte id() { return 0x0D; }
    
    double x;
    double y;
    double stance;
    double z;
    float yaw;
    float pitch;
    bool on_ground;
    
    this(double x, double y, double stance, double z, float yaw, float pitch, bool on_ground) {
        this.x = x;
        this.y = y;
        this.stance = stance;
        this.z = z;
        this.yaw = yaw;
        this.pitch = pitch;
        this.on_ground = on_ground;
    }
    
    void send(Stream s) {
        write(s, id, x, y, stance, z, yaw, pitch, on_ground);
    }
}

