module brala.network.connection;


private {
    import std.socket : TcpSocket, Address, getAddress;
    import std.string : format;
    
    import brala.exception : ConnectionException;
}


class Connection {
    private TcpSocket socket;

    this() {
        socket = new TcpSocket();
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
        
        if(to.length) {
            connect(to[0]);
        } else {
            throw new ConnectionException(format("Unable to resolve address %s:%d.", host, port));
        }
    }
}