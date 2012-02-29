module brala.network.connection;


private {
    import std.socket : TcpSocket, Address, getAddress;
    import std.socketstream : SocketStream;
    import std.stream : EndianStream, BOM;
    import std.system : Endian;
    import std.string : format;
    
    import brala.exception : ConnectionException, ServerException;
    import brala.network.util : FixedEndianStream, TupleRange, read, write;
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
        
        if(read!ubyte(endianstream) != s.Handshake.id) throw new ServerException("Server didn't respond with a handshake");
        auto repl_handshake = s.Handshake.recv(endianstream);
        if(repl_handshake.connection_hash != "-") throw new ServerException("Unsupported connection hash");
        debug writefln("%s", repl_handshake);
        
        auto login = new c.Login(23, username);
        login.send(endianstream);
        
        if(read!ubyte(endianstream) != s.Login.id) throw new ServerException("Expected login-packet");
        auto repl_login = s.Login.recv(endianstream);
        debug writefln("%s", repl_login);
    }
    
    void poll() {
        ubyte packet = read!ubyte(endianstream);
        debug writefln("Packet: %d", packet);
        
        switch(packet) {
            foreach(b; TupleRange!(0x00, 0xff)) { // let's assume the server just seends valid packets ...
                case b: on_packet!b();
            }
            default: throw new ServerException("invalid packet");
        }
    }
    
    void run() {
        while(true) {
            poll();
        }
    }
    
    void on_packet(ubyte id)() {
    }
}