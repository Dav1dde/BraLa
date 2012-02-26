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

class UseBed : IPacket {
    final @property ubyte id() { return 0x11; }
    
    int eid;
    bool in_bed;
    int x;
    byte y;
    int z;
    
    this(int eid, bool in_bed, int x, byte y, int z) {
        this.eid = eid;
        this.in_bed = in_bed;
        this.x = x;
        this.y = y;
        this.z = z;
    }
    
    void send(Stream s) {
        write(s, id, eid, in_bed, x, y, z);
    }
}

class Animation : IPacket {
    final @property ubyte id() { return 0x12; }
    
    int eid;
    byte animation;
    
    this(int eid, byte animation) {
        this.eid = eid;
        this.animation = animation;
    }
    
    void send(Stream s) {
        write(s, id, eid, animation);
    }
}

class NamedEntitySpawn : IPacket {
    final @property ubyte id() { return 0x14; }
    
    int eid;
    string username;
    int x;
    int y;
    int z;
    byte rotation;
    byte pitch;
    short current_item;    
    
    this(int eid, string username, int x, int y, int z, byte rotation, byte pitch, short current_item) {
        this.eid = eid;
        this.username = username;
        this.x = x;
        this.y = y;
        this.z = z;
        this.rotation = rotation;
        this.pitch = pitch;
        this.current_item = current_item;
    }
    
    void send(Stream s) {
        write(s, id, eid, username, x, y, z, rotation, pitch, current_item);
    }
}

class PickupSpawn : IPacket {
    final @property ubyte id() { return 0x15; }
    
    int eid;
    short item_id;
    byte count;
    short damage;
    int x;
    int y;
    int z;
    byte rotation;
    byte pitch;
    byte roll;
    
    this(int eid, short item_id, byte count, short damage, int x, int y, int z, byte rotation, byte pitch, byte roll) {
        this.eid = eid;
        this.item_id = item_id;
        this.count = count;
        this.damage = damage;
        this.x = x;
        this.y = y;
        this.z = z;
        this.rotation = rotation;
        this.pitch = pitch;
        this.roll = roll;
    }
    
    void send(Stream s) {
        write(s, id, eid, item_id, count, damage, x, y, z, rotation, pitch, roll);
    }
}

class CollectItem : IPacket {
    final @property ubyte id() { return 0x16; }
    
    int collected_eid;
    int collector_eid;

    this(int collected_eid, int collector_eid) {
        this.collected_eid = collected_eid;
        this.collector_eid = collector_eid;
    }
    
    void send(Stream s) {
        write(s, id, collected_eid, collector_eid);
    }
}

class AddObject : IPacket {
    final @property ubyte id() { return 0x17; }
    
    int eid;
    byte type;
    int x;
    int y;
    int z;
    int thrower_eid = 0;
    short speed_x;
    short speed_y;
    short speed_z;

    this(int eid, byte type, int x, int y, int z) {
        this.eid = eid;
        this.type = type;
        this.x = x;
        this.y = y;
        this.z = z;
    }
    
    this(int eid, byte type, int x, int y, int z, int thrower_eid, short speed_x, short speed_y, short speed_z) {
        this(eid, type, x, y, z);
        this.thrower_eid = thrower_eid;
        this.speed_x = speed_x;
        this.speed_y = speed_y;
        this.speed_z = speed_z;
    }
    
    void send(Stream s) {
        if(thrower_eid == 0) {
            write(s, id, eid, type, x, y, z);
        else {
            write(s, id, eid, type, x, y, z, thrower_eid, speed_x, speed_y, speed_z);
        }
    }
}

class MobSpawn : IPacket {
    final @property ubyte id() { return 0x18; }
    
    int eid;
    byte type;
    int x;
    int y;
    int z;
    byte yaw;
    byte pitch;
    byte[] metadata;

    this(int eid, byte type, int x, int y, int z, byte yaw, byte pitch, byte[] metadata) {
        this.eid = eid;
        this.type = type;
        this.x = x;
        this.y = y;
        this.z = z;
        this.yaw = yaw;
        this.pitch = pitch;
        this.metadata = metadata;
    }
    
    void send(Stream s) {
        write(s, id, eid, type, x, y, z, yaw, pitch, metadata);
    }
}

class Painting : IPacket {
    final @property ubyte id() { return 0x19; }
    
    int eid;
    string title;
    int x;
    int y;
    int z;
    int direction;

    this(int eid, string title, int x, int y, int z, int direction) {
        this.eid = eid;
        this.title = title;
        this.x = x;
        this.y = y;
        this.z = z;
        this.direction = direction;
    }
    
    void send(Stream s) {
        write(s, id, eid, title, x, y, z, direction);
    }
}

class ExperienceOrb : IPacket {
    final @property ubyte id() { return 0x1A; }
    
    int eid;
    int x;
    int y;
    int z;
    short count;

    this(int eid, int x, int y, int z, short count) {
        this.eid = eid;
        this.x = x;
        this.y = y;
        this.z = z;
        this.count = count;        
    }
    
    void send(Stream s) {
        write(s, id, eid, x, y, z, count);
    }
}

class EntityVelocity : IPacket {
    final @property ubyte id() { return 0x1C; }
    
    int eid;
    short velocity_x;
    short velocity_y;
    short velocity_z;

    this(int eid, short velocity_x, short velocity_y, short velocity_z) {
        this.eid = eid;
        this.velocity_x = velocity_x;
        this.velocity_y = velocity_y;
        this.velocity_z = velocity_z;
    }
    
    void send(Stream s) {
        write(s, id, eid, velocity_x, velocity_y, velocity_z);
    }
}

class DestroyEntity : IPacket {
    final @property ubyte id() { return 0x1D; }
    
    int eid;

    this(int eid) {
        this.eid = eid;
    }
    
    void send(Stream s) {
        write(s, id, eid);
    }
}

class Entity : IPacket {
    final @property ubyte id() { return 0x1E; }
        
    int eid;

    this(int eid) {
        this.eid;
    }
    
    void send(Stream s) {
        write(s, id, eid);
    }
}

class EntityRelativeMove : IPacket {
    final @property ubyte id() { return 0x1F; }
    
    int eid;
    byte delta_x;
    byte delta_y;
    byte delta_z;
    
    this(int eid, byte delta_x, byte delta_y, byte delta_z) {
        this.eid = eid;
        this.delta_x = delta_x;
        this.delta_y = delta_y;
        this.delta_z = delta_z;
    }
    
    void send(Stream s) {
        write(s, id, eid, delta_x, delta_y, delta_z);
    }
}

class EntityLook : IPacket {
    final @property ubyte id() { return 0x20; }
    
    int eid;
    byte yaw;
    byte pitch;
    
    this(int eid, byte yaw, byte pitch) {
        this.eid = eid;
        this.yaw = yaw;
        this.pitch = pitch;
    }
    
    void send(Stream s) {
        write(s, id, eid, yaw, pitch);
    }
}

class EntityLookRelativeMove : IPacket {
    final @property ubyte id() { return 0x21; }
    
    int eid;
    byte delta_x;
    byte delta_y;
    byte delta_z;
    byte yaw;
    byte pitch;
    
    this(int eid, byte delta_x, byte delta_y, byte delta_z, byte yaw, byte pitch) {
        this.eid = eid;
        this.delta_x = delta_x;
        this.delta_y = delta_y;
        this.delta_z = delta_z;
        this.yaw = yaw;
        this.pitch = pitch;
    }
    
    void send(Stream s) {
        write(s, id, eid, delta_x, delta_y, delta_z, yaw, pitch);
    }
}

class EntityTeleport : IPacket {
    final @property ubyte id() { return 0x22; }
    
    int eid;
    int x;
    int y;
    int z;
    byte yaw;
    byte pitch;
    
    this(int eid, int x, int y, int z, byte yaw, byte pitch) {
        this.eid = eid;
        this.x = x;
        this.y = y;
        this.z = z;
        this.yaw = yaw;
        this.pitch = pitch;
    }
    
    void send(Stream s) {
        write(s, id, eid, x, y, z, yaw, pitch);
    }
}

class EntityStatus : IPacket {
    final @property ubyte id() { return 0x26; }
    
    int eid;
    byte status;
    
    this(int eid, byte status) {
        this.eid = eid;
        this.status = status;
    }
    
    void send(Stream s) {
        write(s, id, eid, status);
    }
}

class AttachEntity : IPacket {
    final @property ubyte id() { return 0x27; }
    
    int eid; // entity ID = player
    int vid; // vehicle ID
    
    this(int eid, int vid) {
        this.eid = eid;
        this.vid = vid;
    }
    
    void send(Stream s) {
        write(s, id, eid, vid);
    }
}

class EntityMetadata : IPacket {
    final @property ubyte id() { return 0x28; }
    
    int eid;
    byte[] metadata;
    
    this(int eid, byte[] metadata) {
        this.eid = eid;
        this.metadata = metadata;
    }
    
    void send(Stream s) {
        write(s, id, eid, metadata);
    }
}

class EntityEffect : IPacket {
    final @property ubyte id() { return 0x29; }
    
    int eid;
    byte effect_id;
    byte amplifier;
    short duration;
    
    this(int eid, byte effect_id, byte amplifier, short duration) {
        this.eid = eid;
        this.effect_id = effect_id;
        this.amplifier = amplifier;
        this.duration = duration;
    }
    
    void send(Stream s) {
        write(s, id, eid, effect_id, amplifier, duration);
    }
}

class RemoveEntityEffect : IPacket {
    final @property ubyte id() { return 0x2A; }
    
    int eid;
    int effect_id;
    
    this(int eid, int effect_id) {
        this.eid = eid;
        this.effect_id = effect_id;
    }
    
    void send(Stream s) {
        write(s, id, eid, effect_id);
    }
}

class Experience : IPacket {
    final @property ubyte id() { return 0x2B; }
    
    float experience_bar;
    short level;
    short total_experience;
    
    this(float experience_bar, short level, short total_experience) {
        this.experience_bar = experience_bar;
        this.level = level;
        this.total_experience = total_experience;
    }
    
    void send(Stream s) {
        write(s, id, experience_bar, level, total_experience);
    }
}

class PreChunk : IPacket {
    final @property ubyte id() { return 0x32; }
    
    int x;
    int z;
    bool mode;
    
    this(int x, int y, bool mode) {
        this.x = x;
        this.y = y;
        this.mode = mode;
    }
    
    void send(Stream s) {
        write(s, id, x, y, mode);
    }
}

class MapChunk : IPacket {
    final @property ubyte id() { return 0x33; }
    
    int x;
    short y;
    int z;
    byte size_x;
    byte size_y;
    byte size_z;
    int compressed_size;
    ubyte[] compressed_data;
    
    this(int x, int y, int z, byte size_x, byte size_y, byte size_z, int compressed_size, ubyte[] compressed_data) {
        this.x = x;
        this.y = y;
        this.z = z;
        this.size_x = size_x;
        this.size_y = size_y;
        this.size_z = size_z;
        this.compressed_size = compressed_size;
        this.compressed_data = compressed_data;
    }
    
    void send(Stream s) {
        write(s, id, x, y, z, size_x, size_y, size_z, compressed_size, compressed_data);
    }
}

class MultiBlockChange : IPacket {
    final @property ubyte id() { return 0x34; }
    
    int x;
    int z;
    short array_size;
    short[] coordinates;
    byte[] types;
    byte[] metadata;    
    
    this(int x, int z, short array_size, short[] coordinates, byte[] types, byte[] metadata) {
        this.x = x;
        this.z = z;
        this.array_size = array_size;
        this.coordinates = coordinates;
        this.types = types;
        this.metadata = metadata;
    }
    
    void send(Stream s) {
        write(s, id, x, z, array_size, coordinates, types, metadata);
    }
}

class BlockChange : IPacket {
    final @property ubyte id() { return 0x35; }
    
    int x;
    byte y;
    int z;
    byte type;
    byte metadata;
    
    this(int x, byte y, int z, byte type, byte metadata) {
        this.x = x;
        this.y = y;
        this.z = z;
        this.type = type;
        this.metadata = metadata;
    }
    
    void send(Stream s) {
        write(s, id, x, y, z, type, metadata);
    }
}

class BlockAction : IPacket {
    final @property ubyte id() { return 0x36; }
    
    int x;
    short y;
    int z;
    byte byte1;
    byte byte2;
    
    this(int x, short y, int z, byte byte1, byte byte2) {
        this.x = x;
        this.y = y;
        this.z = z;
        this.byte1 = byte1;
        this.byte2 = byte2;
    }
    
    void send(Stream s) {
        write(s, id, x, y, z, byte1, byte2);
    }
}

class Explosion : IPacket {
    final @property ubyte id() { return 0x3C; }
    
    double x;
    double y;
    double z;
    float radius;
    int record_count;
    byte[] records;
    
    this(double x, double y, double z, float radius, int record_count, byte[] records) {
        this.x = x;
        this.y = y;
        this.z = z;
        this.radius = radius;
        this.record_count = record_count;
        this.records = records;
    }
    
    void send(Stream s) {
        write(s, id, x, y, z, radius, record_count, records);
    }
}

class SoundParticleEffect : IPacket {
    final @property ubyte id() { return 0x3D; }
    
    int effect_id;
    int x;
    byte y;
    int z;
    int data;
    
    this(int effect_id, int x, byte y, int z, int data) {
        this.effect_id = effect_id;
        this.x = x;
        this.y = y;
        this.z = z;
        this.data = data;
    }
    
    void send(Stream s) {
        write(s, id, effect_id, x, y, z, data);
    }
}

class NewInvalidState : IPacket {
    final @property ubyte id() { return 0x46; }
    
    byte reason;
    byte gamemode;
    
    this(byte reason, byte gamemode) {
        this.reason = reason;
        this.gamemode = gamemode;
    }
    
    void send(Stream s) {
        write(s, id, reason, gamemode);
    }
}

