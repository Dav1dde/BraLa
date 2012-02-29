module brala.network.connection;


private {
    import std.socket : TcpSocket, Address, getAddress;
    import std.socketstream : SocketStream;
    import std.stream : EndianStream, BOM;
    import std.system : Endian;
    import std.string : format;
    
    import brala.exception : ConnectionException, ServerException;
    import brala.network.util : FixedEndianStream;
    import s = brala.network.packets.server;
    import c = brala.network.packets.client;
    
    debug import std.stdio : writefln;
}


class Connection {
    private TcpSocket socket;
    private SocketStream socketstream;
    private EndianStream endianstream;
    private bool _connected;

    immutable string username;
    
    this(string username) {
        socket = new TcpSocket();
        socketstream = new SocketStream(socket);
        endianstream = new FixedEndianStream(socketstream, Endian.bigEndian);
        
        this.username = username;
    }
    
    this(string username, Address to) {
        this(username);
        
        connect(to);
    }
    
    this(string username, const(char)[] host, ushort port) {
        this(username);
        
        connect(host, port);
    }
    
    void connect(Address to) {
        socket.connect(to);
        _connected = true;
        login();
    }
    
    void connect(const(char)[] host, ushort port) {
        Address[] to = getAddress(host, port);
        
        connect(to[0]);
    }
    
    void login() {
        auto handshake = new c.Handshake(username);
        handshake.send(endianstream);
        
        ubyte repl;
        endianstream.read(repl);
        if(repl != 0x02) throw new ServerException("Server didn't respond with a handshake");
        
        auto repl_handshake = s.Handshake.recv(endianstream);
        if(repl_handshake.connection_hash != "-") throw new ServerException("unsupported connection hash");
        
        auto login = new c.Login(23, username);
        login.send(endianstream);
        
        endianstream.read(repl);
        writefln("%s", repl);
                
        auto repl_login = s.Login.recv(endianstream);
        writefln("%s", repl_login);
    }
    
    void poll() {
    }
    
    void run() {
        while(true) {
            poll();
        }
    }
}