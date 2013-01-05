module brala.network.packets.client;

private {
    import std.stream : Stream;
    
    import brala.network.packets.types : Slot;
    import brala.network.packets.types : IPacket;
    import brala.network.packets.util;
    import server = brala.network.packets.server;
}


mixin get_packets_mixin!(__traits(allMembers, brala.network.packets.client));


alias server.KeepAlive KeepAlive;

class Login : IPacket {
    mixin Packet!(0x01);
}

class Handshake : IPacket {
    mixin Packet!(0x02, byte, "protocol_version", string, "username", string, "host", int, "port");
}

public alias server.ChatMessage ChatMessage;
public alias server.EntityEquipment EntityEquipment;

class UseEntity : IPacket {
    mixin Packet!(0x07, int, "user", int, "target", bool, "left_click");
}

class Respawn : IPacket {
    mixin Packet!(0x09);
}

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
    mixin Packet!(0x0E, byte, "status", int, "x", byte, "y", int, "z", byte, "face");
}

class PlayerBlockPlacement : IPacket {
    mixin Packet!(0x0F, int, "x", ubyte, "y", int, "z", byte, "direction", Slot, "item",
                        byte, "cursor_x", byte, "cursor_y", byte, "cursor_z");
}

class HoldingChange : IPacket {
    mixin Packet!(0x10, short, "slot_id");
}

class EntityAction : IPacket {
    mixin Packet!(0x13, int, "entity_id", byte, "action_id");
}

class WindowClick : IPacket {
    mixin Packet!(0x66, byte, "window_id", short, "slot", byte, "mouse_button", short, "action_number", bool, "shift", Slot, "clicked_item");
}

public alias server.Transaction Transaction;
public alias server.CreativeInventoryAction CreativeInventoryAction;

class EnchantItem : IPacket {
    mixin Packet!(0x6C, byte, "window_id", byte, "enchantment");
}

public alias server.UpdateSign UpdateSign;
public alias server.PlayerAbilities PlayerAbilities;
public alias server.PluginMessage PluginMessage;
public alias server.TabComplete TabComplete;

class ClientSettings : IPacket {
    mixin Packet!(0xCC, string, "locale", byte, "view_distance", byte, "chat_flags", byte, "difficulty", bool, "show_cape");
}

class ClientStatuses : IPacket {
    mixin Packet!(0xCD, byte, "payload");
}

public alias server.EncryptionKeyResponse EncryptionKeyResponse;

class ServerListPing : IPacket {
    mixin Packet!(0xFE);
}

public alias server.Disconnect Disconnect;