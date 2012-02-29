module brala.network.packets.types;

private {
    import std.stream : Stream;
}

interface IPacket {
    static @property ubyte id();
    void send(Stream s);
    static typeof(this) recv(Stream s);
}
