module brala.network.packets.types;

private {
    import std.stream : Stream;
}

interface IPacket {
    @property ubyte id();
    void send(Stream s);    
}