module brala.network.packets.client;

private {
    import std.stream : Stream;
    import std.typetuple : TypeTuple;
    
    import brala.network.packets.types : IPacket;
    import brala.network.packets.util;
    import server = brala.network.packets.server;
}


mixin get_packets_mixin;
alias get_packets!(brala.network.packets.client) packets;


alias server.KeepAlive KeepAlive;

class Login : IPacket {
    static @property ubyte id() { return 0x01; }
    
    int protocol_version;
    string username;
       
    this(int protocol_version, string username) {
        this.protocol_version = protocol_version;
        this.username = username;
    }
    
    void send(Stream s) {
        write(s, id, protocol_version, username, 0L, "", 0, NULL_BYTE, NULL_BYTE, NULL_UBYTE, NULL_UBYTE);
    }
    
    static Login recv(Stream s) {
        return new Login(read!(int, string)(s).field);
    }
    
    string toString() {
        return .stringof[7..$] ~ `.Login(int protocol_version : "` ~ to!string(protocol_version) ~
                                                        `", string username : "` ~ to!string(username) ~ `")`;
    }
}

class Handshake : IPacket {
    mixin Packet!(0x02, string, "username");
}

public alias server.ChatMessage ChatMessage;
public alias server.EntityEquipment EntityEquipment;

class UseEntity : IPacket {
    mixin Packet!(0x07, int, "user", int, "target", bool, "left_click");
}

public alias server.Respawn Respawn;

class Player : IPacket {
    mixin Packet!(0x0A, bool, "on_ground");
}

class PlayerPosition : IPacket {
    mixin Packet!(0x0B, double, "x", double, "y", double, "stance", double, "z", bool, "on_ground");
}

class PlayerLook : IPacket {
    mixin Packet!(0x0C, float, "yaw", float, "pitch", bool, "on_ground");
}

class PlayerPositionLook : IPacket {
    mixin Packet!(0x0D, double, "x", double, "y", double, "stance", double, "z", float, "yaw", float, "pitch", bool, "on_ground");
}

class PlayerDigging : IPacket {
    mixin Packet!(0x0E, byte, "status", int, "x", int, "y", int, "z", byte, "face");
}

class PlayerBlockPlacement : IPacket {
    mixin Packet!(0x0F, int, "x", byte, "y", int, "z", byte, "direction", byte[], "slot");
}

class HoldingChange : IPacket {
    mixin Packet!(0x10, short, "slot_id");
}

class EntityAction : IPacket {
    mixin Packet!(0x13, int, "entity_id", byte, "action_id");
}

public alias server.PickupSpawn PickupSpawn;

class WindowClick : IPacket {
    mixin Packet!(0x66, byte, "window_id", short, "slot", bool, "right_click", short, "action_number", bool, "shift", byte[], "clicked_item");
}

public alias server.Transaction Transaction;
public alias server.CreativeInventoryAction CreativeInventoryAction;

class EnchantItem : IPacket {
    mixin Packet!(0x6C, byte, "window_id", byte, "enchantment");
}

public alias server.UpdateSign UpdateSign;
public alias server.PluginMessage PluginMessage;

class ServerListPing : IPacket {
    mixin Packet!(0xFE);
}