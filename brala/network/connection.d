module brala.network.connection;


private {
    import core.thread : Thread;    
    import std.socket : SocketException, TcpSocket, Address, getAddress;
    import std.socketstream : SocketStream;
    import std.stream : EndianStream, BOM;
    import std.system : Endian;
    import std.string : format;
    import std.array : join;
        
    import brala.exception : ConnectionException, ServerException;
    import brala.network.session : Session;
    import brala.network.util : FixedEndianStream, TupleRange, read, write;
    import brala.network.packets.types : IPacket;
    import s = brala.network.packets.server;
    import c = brala.network.packets.client;
    
    debug import std.stdio : writefln;
}


class Connection {
    TcpSocket socket;
    SocketStream socketstream;
    EndianStream endianstream;
    private bool _connected;
    private Address connected_to;
    private bool _logged_in;
    
    @property connected() { return _connected; }
    @property logged_in() { return _logged_in; }
    
    package Session session;
    
    void delegate(ubyte, void*) callback;
    
    immutable string username;
    immutable string password;
    
    // sent with servers login packet
    int entity_id;
    string level_type;
    int server_mode;
    int dimension;
    byte difficulty;
    ubyte max_players;
    
    
    this(string username, string password) {
        socket = new TcpSocket();
        socketstream = new SocketStream(socket);
        endianstream = new FixedEndianStream(socketstream, Endian.bigEndian);
        
        session = new Session();
        
        this.username = username;
        this.password = password;
    }
    
    this(string username, string password, Address to) {
        this(username, password);
        
        connect(to);
    }
    
    this(string username, string password, string host, ushort port) {
        this(username, password);
        
        connect(host, port);
    }
    
    void connect(Address to) {
        socket.connect(to);
        _connected = true;
        connected_to = to;
    }
    
    void connect(string host, ushort port) {
        Address[] to = getAddress(host, port);
        
        connect(to[0]);
    }
        
    void login() {
        auto handshake = new c.Handshake(join([username, connected_to.toHostNameString(), connected_to.toPortString()], ";"));
        handshake.send(endianstream);
        
        if(read!ubyte(endianstream) != s.Handshake.id) throw new ServerException("Server didn't respond with a handshake.");
        auto repl_handshake = s.Handshake.recv(endianstream);
        debug writefln("%s", repl_handshake);
        if(repl_handshake.connection_hash != "-") {
            // currently not working, session login etc. works,
            // but server kicks with "Protocol Error"
            if(!session.logged_in) {
                session.login(username, password);
            }
            writefln(repl_handshake.connection_hash);
            session.join(repl_handshake.connection_hash);
//             session.keep_alive();
        }
        
        auto login = new c.Login(28, username);
        login.send(endianstream);
        
        ubyte packet_id = read!ubyte(endianstream);
        s.Login repl_login;
        if(packet_id == s.Login.id) {
            repl_login = s.Login.recv(endianstream);
        } else if(packet_id == s.Disconnect.id) {
            throw new ServerException("Disconnect, " ~ s.Disconnect.recv(endianstream).reason);
        } else {
            throw new ServerException("Expected login or disconnect packet.");
        }
        
        debug writefln("%s", repl_login);
        
        entity_id = repl_login.entity_id;
        level_type = repl_login.level_type;
        server_mode = repl_login.mode;
        dimension = repl_login.dimension;
        difficulty = repl_login.difficulty;
        max_players = repl_login.max_players;
        
        _logged_in = true;
    }
    
    void poll() {
        try {
            _poll();
        } catch(SocketException s) {
            _connected = false;
            throw s;
        }
    }
    
    void _poll() {
        ubyte packet_id = read!ubyte(endianstream);
        
        assert(callback !is null);
        switch(packet_id) {
            foreach(p; s.get_packets!()) { // p.cls = class, p.id = id
                case p.id: p.cls packet = s.parse_packet!(p.id)(endianstream);
                           static if(__traits(compiles, on_packet!(p.cls)))  on_packet(packet);
                           return callback(p.id, cast(void*)packet);
            }
            default: throw new ServerException(format("Invalid packet: 0x%02x.", packet_id));
        }
    }
    

    void run() {
        while(_connected) {
            poll();
        }
    }
    
    private void on_packet(T : s.KeepAlive)(T packet) {
        (new c.KeepAlive(packet.keepalive_id)).send(endianstream);
    }
    
    private void on_packet(T : s.Disconnect)(T packet) {
        socket.close();
        _connected = false;
    }
    
//     void on_packet(T)(T packet) {}
}

class ThreadedConnection : Connection {
    private Thread _thread = null;
    
    this(string username, string password) { super(username, password); }
    this(string username, string password, Address to) { super(username, password, to); }
    this(string username, string password, string host, ushort port) { super(username, password, host, port); }
    
    void run() {
        if(_thread is null) {
            _thread = new Thread(&(super.run));
            _thread.isDaemon = true;
        }
        
        _thread.start();
    }
}