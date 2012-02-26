module brala.network.connection;


private {
    import std.socket : TcpSocket, Address, getAddress;
    import std.socketstream : SocketStream;
    import std.stream : EndianStream;
    import std.system : Endian;
    import std.string : format;
    
    import brala.exception : ConnectionException;
}


class Connection {
    private TcpSocket socket;
    private SocketStream socketstream;
    private EndianStream endianstream;

    this() {
        socket = new TcpSocket();
        socketstream = new SocketStream(socket);
        endianstream = new EndianStream(socketstream, Endian.bigEndian); // Hope this works ...
    }
    
    this(Address to) {
        this();
        
        connect(to);
    }
    
    this(const(char)[] host, ushort port) {
        this();
        
        connect(host, port);
    }
    
    void connect(Address to) {
        socket.connect(to);
    }
    
    void connect(const(char)[] host, ushort port) {
        Address[] to = getAddress(host, port);
        
        connect(to[0]);
    }
}