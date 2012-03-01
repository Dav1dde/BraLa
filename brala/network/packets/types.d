module brala.network.packets.types;

private {
    import std.stream : Stream;
}

abstract class IPacket {
    const ubyte id;
    void send(Stream s);
    static typeof(this) recv(Stream s);
    string toString();
}
