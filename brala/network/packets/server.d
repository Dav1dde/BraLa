module brala.network.packets.server;


private {
    import std.stream : Stream;
    import std.string : format;
    
    import brala.network.packets.types : IPacket, EntityMetadataS, Slot;
    import brala.network.packets.util;
}


mixin get_packets_mixin!(brala.network.packets.server);


class KeepAlive : IPacket {
    mixin Packet!(0x00, int, "keepalive_id");
}

class Login : IPacket {
    mixin Packet!(0x01, int, "entity_id", string, "unused", string, "level_type", int, "mode",
                        int, "dimension", byte, "difficulty", byte, "world_height", ubyte, "max_players");
}

class Handshake : IPacket {
    mixin Packet!(0x02, string, "connection_hash");
}

class ChatMessage : IPacket {
    mixin Packet!(0x03, string, "message");
}

class TimeUpdate : IPacket {
    mixin Packet!(0x04, long, "time");
}

class EntityEquipment : IPacket {
    mixin Packet!(0x05, int, "entity_id", short, "slot", short, "item_id", short, "damage");
}

class SpawnPosition : IPacket {
    mixin Packet!(0x06, int, "x", int, "y", int, "z");
}

class UpdateHealth : IPacket {
    mixin Packet!(0x08, short, "health", short, "food", float, "food_saturation");
}

class Respawn : IPacket {
    mixin Packet!(0x09, int, "dimension", byte, "difficulty", byte, "mode", short, "world_height", string, "level_type");
}

class PlayerPositionLook : IPacket {
    mixin Packet!(0x0D, double, "x", double, "stance", double, "y", double, "z", float, "yaw", float, "pitch", bool, "on_ground");
}

class UseBed : IPacket {
    mixin Packet!(0x11, int, "entity_id", bool, "in_bed", int, "x", byte, "y", int, "z");
}

class Animation : IPacket {
    mixin Packet!(0x12, int, "entity_id", byte, "animation");
}

class NamedEntitySpawn : IPacket {
    mixin Packet!(0x14, int, "entity_id", string, "username", int, "x", int, "y", int, "z",
                        byte, "rotation", byte, "pitch", short, "current_item");
}

class PickupSpawn : IPacket {
    mixin Packet!(0x15, int, "entity_id", short, "item_id", byte, "count", short, "damage",
                        int, "x", int, "y", int, "z", byte, "rotation", byte, "pitch", byte, "roll");
}

class CollectItem : IPacket {
    mixin Packet!(0x16, int, "collected_eid", int, "collector_eid");
}

class AddObject : IPacket {
    const ubyte id = 0x17;
    
    int entity_id;
    byte type;
    int x;
    int y;
    int z;
    int thrower_eid = 0;
    short speed_x;
    short speed_y;
    short speed_z;

    this(int entity_id, byte type, int x, int y, int z) {
        this.entity_id = entity_id;
        this.type = type;
        this.x = x;
        this.y = y;
        this.z = z;
    }
    
    this(int entity_id, byte type, int x, int y, int z, int thrower_eid, short speed_x, short speed_y, short speed_z) {
        this(entity_id, type, x, y, z);
        this.thrower_eid = thrower_eid;
        this.speed_x = speed_x;
        this.speed_y = speed_y;
        this.speed_z = speed_z;
    }
    
    void send(Stream s) {
        if(thrower_eid == 0) {
            write(s, id, entity_id, type, x, y, z);
        } else {
            write(s, id, entity_id, type, x, y, z, thrower_eid, speed_x, speed_y, speed_z);
        }
    }
    
    static AddObject recv(Stream s) {
        return new AddObject(read!(int, byte, int, int, int, int, short, short, short)(s).field);
    }
    
    string toString() {
        return .stringof[7..$] ~ format(`.AddObject(int entity_id : "%d", byte type : "%s", int x : "%d", int y : "%d", int z : "%d" ,`
                                        `int thrower_eid : "%d", short speed_x : "%d", short speed_y : "%d", short speed_z : "%d"`,
                                        to!string(entity_id), to!string(type), to!string(x), to!string(y), to!string(z),
                                        to!string(thrower_eid), to!string(speed_x), to!string(speed_y), to!string(speed_z));
                                        
    }
}

class MobSpawn : IPacket {
    mixin Packet!(0x18, int, "entity_id", byte, "type", int, "x", int, "y", int, "z",
                        byte, "yaw", byte, "pitch", byte, "head_yaw", EntityMetadataS, "metadata");
}

class Painting : IPacket {
    mixin Packet!(0x19, int, "entity_id", string, "title", int, "x", int, "y", int, "z", int, "direction");
}

class ExperienceOrb : IPacket {
    mixin Packet!(0x1A, int, "entity_id", int, "x", int, "y", int, "z", short, "count");
}

class EntityVelocity : IPacket {
    mixin Packet!(0x1C, int, "entity_id", short, "velocity_x", short, "velocity_y", short, "velocity_z");
}

class DestroyEntity : IPacket {
    mixin Packet!(0x1D, int, "entity_id");
}

class Entity : IPacket {
    mixin Packet!(0x1E, int, "entity_id");
}

class EntityRelativeMove : IPacket {
    mixin Packet!(0x1F, int, "entity_id", byte, "delta_x", byte, "delta_y", byte, "delta_z");
}

class EntityLook : IPacket {
    mixin Packet!(0x20, int, "entity_id", byte, "yaw", byte, "pitch");
}

class EntityLookRelativeMove : IPacket {
    mixin Packet!(0x21, int, "entity_id", byte, "delta_x", byte, "delta_y", byte, "delta_z", byte, "yaw", byte, "pitch");
}

class EntityTeleport : IPacket {
    mixin Packet!(0x22, int, "entity_id", int, "x", int, "y", int, "z", byte, "yaw", byte, "pitch");
}

class EntityHeadLook : IPacket {
    mixin Packet!(0x23, int, "entity_id", byte, "head_yaw");
}
    
class EntityStatus : IPacket {
    mixin Packet!(0x26, int, "entity_id", byte, "status");
}

class AttachEntity : IPacket {
    mixin Packet!(0x27, int, "entity_id", int, "vehicle_id");
}

class EntityMetadata : IPacket {
    mixin Packet!(0x28, int, "entity_id", EntityMetadataS, "metadata");
}

class EntityEffect : IPacket {
    mixin Packet!(0x29, int, "entity_id", byte, "effect_id", byte, "amplifier", short, "duration");
}

class RemoveEntityEffect : IPacket {
    mixin Packet!(0x2A, int, "entity_id", int, "effect_id");
}

class Experience : IPacket {
    mixin Packet!(0x2B, float, "experience_bar", short, "level", short, "total_experience");
}

class PreChunk : IPacket {
    mixin Packet!(0x32, int, "x", int, "z", bool, "mode");
}

class MapChunk : IPacket {
    mixin Packet!(0x33, int, "x", int, "z", bool, "contiguous", short, "primary_bitmap", byte, "add_bitmap",
                        int, "compressed_size", int, "unused", ubyte[], "compressed_data");
}

class MultiBlockChange : IPacket {
    mixin Packet!(0x34, int, "x", int, "z", short, "record_count", int, "data_size", byte[], "data");
}

class BlockChange : IPacket {
    mixin Packet!(0x35, int, "x", byte, "y", int, "z", byte, "type", byte, "metadata");
}

class BlockAction : IPacket {
    mixin Packet!(0x36, int, "x", short, "y", int, "z", byte, "byte1", byte, "byte2");
}

class Explosion : IPacket {
    mixin Packet!(0x3C, double, "x", double, "y", double, "z", float, "radius", int, "record_count", byte[], "records");
}

class SoundParticleEffect : IPacket {
    mixin Packet!(0x3D, int, "effect_id", int, "x", byte, "y", int, "z", int, "data");
}

class NewInvalidState : IPacket {
    mixin Packet!(0x46, byte, "reason", byte, "gamemode");
}

class ThunderBolt : IPacket {
    mixin Packet!(0x47, int, "entity_id", bool, "unknown", int, "x", int, "y", int, "z");
}

class OpenWindow : IPacket {
    mixin Packet!(0x64, byte, "window_id", byte, "inventory_type", string, "window_title", byte, "slots");
}

class CloseWindow : IPacket {
    mixin Packet!(0x65, byte, "window_id");
}

class SetSlot : IPacket {
    mixin Packet!(0x67, byte, "window_id", short, "slot", Slot, "slot_data");
}

class WindowItems : IPacket {
    mixin Packet!(0x68, byte, "window_id", Slot[], "slots");
}

class UpdateWindowProperty : IPacket {
    mixin Packet!(0x69, byte, "window_id", short, "property", short, "value");
}

class Transaction : IPacket {
    mixin Packet!(0x6A, byte, "window_id", short, "action_number", bool, "accepted");
}

class CreativeInventoryAction : IPacket {
    mixin Packet!(0x6B, short, "slot", byte[], "clicked_item");
}

class UpdateSign : IPacket {
    mixin Packet!(0x82, int, "x", short, "y", int, "z", string, "text1", string, "text2", string, "text3", string, "text4");
}

class ItemData : IPacket {
    mixin Packet!(0x83, short, "item_type", short, "item_id", ubyte, "text_length", byte[], "text");
}

class UpdateTileEntity : IPacket {
    mixin Packet!(0x84, int, "x", short, "y", int, "z", byte, "action", int, "custom1", int, "custom2", int, "custom3");
}

class IncrementStatistic : IPacket {
    mixin Packet!(0xC8, int, "statistic_id", byte, "amount");
}

class PlayerListItem : IPacket {
    mixin Packet!(0xC9, string, "username", bool, "online", short, "ping");
}

class PluginMessage : IPacket {
    mixin Packet!(0xFA, string, "channel", short, "length", byte[], "data");
}

class Disconnect : IPacket {
    mixin Packet!(0xFF, string, "reason");
}

alias Disconnect Kick;