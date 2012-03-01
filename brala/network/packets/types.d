module brala.network.packets.types;

private {
    import nbt.nbt;
    
    import std.stream : Stream;
    import std.algorithm : countUntil;

    import brala.network.util : read;
    import brala.exception : ServerException;
}

abstract class IPacket {
    const ubyte id;
    void send(Stream s);
    static typeof(this) recv(Stream s);
    string toString();
}

struct EntityMetadataS {
    ubyte[] metadata;
    
    static EntityMetadataS recv(Stream s) { // TODO: store the data
        EntityMetadataS ret;
        
        ubyte x = read!ubyte(s);
    
        while(x != 127) {
            byte index = x & 0x1f;
            byte ty = x >> 5;
            
            switch(ty) {
                case 0: read!byte(s); break;
                case 1: read!short(s); break;
                case 2: read!int(s); break;
                case 3: read!float(s); break;
                case 4: read!string(s); break;
                case 5: read!(short, byte, short)(s); break;
                case 6: read!(int, int, int)(s); break;
                default: throw new ServerException("Invalid type in entity metadata.");
            }
            
            x = read!ubyte(s);
        }
        
        return ret;
    }
}

struct Slot {
    static Slot recv(Stream s) { // TODO: store the data
        Slot ret;
        
        short block = read!short(s);
        byte item_count = 0;
        short metadata = 0;
        
        if(block == -1) {
            item_count = read!byte(s);
            metadata = read!short(s);
        }
        
        if([0x103, 0x105, 0x15a, 0x167, // Flint&Steel, bow, fishing rod, shears
            // Tools:
            // sword, shovel, pickaxe, axe, hoe
            0x10C, 0x10D, 0x10E, 0x10F, 0x122, // wood
            0x110, 0x111, 0x112, 0x113, 0x123, // stone
            0x10B, 0x100, 0x101, 0x102, 0x124, // iron
            0x114, 0x115, 0x116, 0x117, 0x125, // diamond
            0x11B, 0x11C, 0x11D, 0x11E, 0x126, // gold
            // Armour:
            // helmet, chestplate, leggings, boots
            0x12A, 0x12B, 0x12C, 0x12D, // leather
            0x12E, 0x12F, 0x130, 0x131, // chain
            0x132, 0x133, 0x134, 0x135, // iron
            0x136, 0x137, 0x138, 0x139, // diamond 
            0x13A, 0x13B, 0x13C, 0x13D  // gold
            ].countUntil(block)) {
            short len = read!short(s);
            
            if(len != -1) {
                ubyte[] buf = new ubyte[len];
                s.readExact(buf.ptr, len);
            }
        }
        
        return ret;
    }
}