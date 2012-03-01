module brala.network.packets.types;

private {
    import std.stream : Stream;

    import brala.network.util : read;
    import brala.exception : ServerException;
}

abstract class IPacket {
    const ubyte id;
    void send(Stream s);
    static typeof(this) recv(Stream s);
    string toString();
}
import std.stdio;

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