module brala.network.connection;


private {
    import std.socket : TcpSocket, Address, getAddress;
    import std.socketstream : SocketStream;
    import std.stream : EndianStream, BOM;
    import std.system : Endian;
    import std.string : format;
    
    import brala.exception : ConnectionException, ServerException;
    import brala.network.util : FixedEndianStream, TupleRange, read, write;
    import brala.network.packets.types : IPacket;
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
    
    // sent with servers login packet
    int entity_id;
    long map_seed;
    string level_type;
    int server_mode;
    byte dimension;
    byte difficulty;
    ubyte max_players;
    
    
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
    }
    
    void connect(const(char)[] host, ushort port) {
        Address[] to = getAddress(host, port);
        
        connect(to[0]);
    }
        
    void login() {
        auto handshake = new c.Handshake(username);
        handshake.send(endianstream);
        
        if(read!ubyte(endianstream) != s.Handshake.id) throw new ServerException("Server didn't respond with a handshake.");
        auto repl_handshake = s.Handshake.recv(endianstream);
        if(repl_handshake.connection_hash != "-") throw new ServerException("Unsupported connection hash.");
        debug writefln("%s", repl_handshake);
        
        auto login = new c.Login(23, username);
        login.send(endianstream);
        
        if(read!ubyte(endianstream) != s.Login.id) throw new ServerException("Expected login-packet.");
        auto repl_login = s.Login.recv(endianstream);
        debug writefln("%s", repl_login);
        
        entity_id = repl_login.entity_id;
        map_seed = repl_login.seed;
        level_type = repl_login.level_type;
        server_mode = repl_login.mode;
        dimension = repl_login.dimension;
        difficulty = repl_login.difficulty;
        max_players = repl_login.max_players;
    }
    
    void poll() {
        ubyte packet = read!ubyte(endianstream);
//         debug writefln("Packet: %d", packet);
        
        switch(packet) {
            foreach(p; s.packets) { // p[0] = class-name, p[1] = id
                case p[1]: return on_packet!(p[1])();
            }
            default: throw new ServerException(format("Invalid packet: %s.", packet));
        }
    }
    

    void run() {
        while(_connected) {
            poll();
        }
    }
    
    void on_packet(ubyte id : 0x00)() {
        auto ka = s.KeepAlive.recv(endianstream);
        (new c.KeepAlive(ka.keepalive_id)).send(endianstream);
    }
    
    void on_packet(ubyte id : 0x04)() {
        debug writefln("%s", s.TimeUpdate.recv(endianstream));
    }
    
    void on_packet(ubyte id : 0x06)() {
        debug writefln("%s", s.SpawnPosition.recv(endianstream));
    }
    
//     void on_packet(ubyte id : 0x18)() {
//         debug writefln("%s", s.MobSpawn.recv(endianstream));
//     }
    
    void on_packet(ubyte id : 0xff)() {
        debug writefln("%s", s.Disconnect.recv(endianstream));
        socket.close();
        _connected = false;
    }
    
    void on_packet(ubyte id)() {
        throw new ServerException(format("Unhandled packet with id: 0x%02x", id));
    }
}