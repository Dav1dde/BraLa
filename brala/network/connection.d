module brala.network.connection;


private {
    import glamour.gl : glGetString, GL_VERSION, GL_VENDOR;
    
    import core.thread : Thread;
    import core.time : dur;
    import core.cpuid : isX86_64;
    import std.socket : SocketException, SocketShutdown, TcpSocket, Address, getAddress;
    import std.socketstream : SocketStream;
    import std.stream : EndianStream, BOM;
    import std.system : Endian;
    import std.exception : enforceEx;
    import std.string : format;
    import std.array : join;
    import std.conv : to;
    import std.typecons : tuple;
    import std.system : os;
    import std.stdio : stderr;

    import brala.exception : ConnectionError, ServerError, SessionError;
    import brala.network.session : Session;
    import brala.network.stream : AESStream, LoggingStream;
    import brala.network.util : read, write;
    import brala.network.packets.types : IPacket, Array;
    import s = brala.network.packets.server;
    import c = brala.network.packets.client;
    import brala.network.crypto : decode_public, encrypt, seed_prng, get_random, get_random_max;
    import brala.utils.queue : Queue;
    import brala.utils.openssl.encrypt : AES128CFB8;
    import brala.utils.thread : Timer;
    
    debug import std.stdio : writefln;
}


class Connection {
    TcpSocket socket;
    SocketStream socketstream;
    EndianStream endianstream;
    protected Queue!IPacket queue;
    protected bool _connected = false;
    protected Address connected_to;
    protected bool _logged_in = false;
    bool errored = false;
    
    @property connected() { return _connected; }
    @property logged_in() { return _logged_in; }
    
    package Session session;
    
    void delegate(ubyte, void*) callback;
    
    /+immutable+/ string username;
    /+immutable+/ string password;
    /+immutable+/ string minecraft_username;
    /+immutable+/ string hostname;

    protected ubyte[] shared_secret;
    
    immutable byte protocol_version = 39;
    
    this(string username, string password, bool snoop) {
        socket = new TcpSocket();
        socketstream = new SocketStream(socket);
        endianstream = new EndianStream(socketstream, Endian.bigEndian);
//         endianstream = new EndianStream(new LoggingStream(socketstream, stderr), Endian.bigEndian);
        queue = new Queue!IPacket();
        
        session = new Session(username, password);

        try {
            session.login();
            this.minecraft_username = session.minecraft_username;
        } catch(SessionError e) {
            debug writefln("%s", e.msg);
            this.minecraft_username = username;
        }

        if(snoop) {
            auto snoop_args = tuple("BraLa", os.to!string(), "undetectable", isX86_64 ? "64 bit":"32 bit",
                                    "-1", "-1", "D Compiler: " ~ to!string(__VERSION__),
                                    to!string(glGetString(GL_VERSION)), to!string(glGetString(GL_VENDOR)));

            void snoop_timer() {
                auto timer = new Timer(dur!"minutes"(11), delegate void() {
                    if(_connected) {
                        Session.snoop(snoop_args.expand);
                    }

                    snoop_timer();
                });
                timer.isDaemon = true;
                timer.start();
            }

            snoop_timer();
            session.snoop();
        }
   
        this.username = username;
        this.password = password;
    }
    
    void connect(Address to, string hostname) {
        socket.connect(to);
        _connected = true;
        connected_to = to;

        this.hostname = hostname;
    }
    
    void connect(string host, ushort port) {
        Address[] to = getAddress(host, port);

        connect(to[0], host);
    }
    
    void disconnect() {
        socket.shutdown(SocketShutdown.BOTH);
        socket.close();
        _connected = false;
        _logged_in = false;
    }
    
    void send(T : IPacket)(T packet) {
        queue.put(packet);
    }
    
    void login() {
        auto handshake = new c.Handshake(protocol_version,
                                         minecraft_username,
                                         hostname,
                                         to!int(connected_to.toPortString()));
                                
        handshake.send(endianstream);
    }
    
    void poll() {
        try {
            ubyte packet_id = read!ubyte(endianstream);

            foreach(packet; queue) {
                packet.send(endianstream);
            }
            endianstream.flush();

            dispatch_packet(packet_id);
        } catch(Exception e) {
            _connected = false;
            errored = true;
            throw e;
        }
    }
    
    void dispatch_packet(ubyte packet_id) {
        assert(callback !is null);
        switch(packet_id) {
            foreach(p; s.get_packets!()) { // p.cls = class, p.id = id
                case p.id: p.cls packet = s.parse_packet!(p.id)(endianstream);
                           static if(__traits(compiles, on_packet!(p.cls)))  on_packet(packet);
                           return callback(p.id, cast(void*)packet);
            }
            default: throw new ServerError(format("Invalid packet: 0x%02x.", packet_id));
        }
    }
    
    void run() {
        while(_connected) {
            poll();
        }
    }

    protected void on_packet(T : s.EncryptionKeyRequest)(T packet) {
        auto rsa = decode_public(packet.public_key.arr);

        ubyte[] enc_verify_token = rsa.encrypt(packet.verify_token.arr);
        seed_prng();
        
        this.shared_secret = get_random(16);
//         this.shared_secret = [cast(ubyte)0, cast(ubyte)0, cast(ubyte)0, cast(ubyte)0,
//                               cast(ubyte)0, cast(ubyte)0, cast(ubyte)0, cast(ubyte)0,
//                               cast(ubyte)0, cast(ubyte)0, cast(ubyte)0, cast(ubyte)0,
//                               cast(ubyte)0, cast(ubyte)0, cast(ubyte)0, cast(ubyte)0];
//         this.shared_secret = get_random_max(16, 12);

        ubyte[] enc_shared_secret = rsa.encrypt(shared_secret);

        if(packet.server_id != "-") {
            enforceEx!SessionError(session.logged_in, `Unable to login as user "` ~ username ~ `". `);
            session.join(packet.server_id, shared_secret, packet.public_key.arr);
        }

        auto enc_key = new c.EncryptionKeyResponse(Array!(short, ubyte)(enc_shared_secret),
                                                   Array!(short, ubyte)(enc_verify_token));
        enc_key.send(endianstream);

        assert(false);
    }

    protected void on_packet(T : s.EncryptionKeyResponse)(T packet) {        
        enforceEx!ServerError(packet.verify_token.length == 0 && packet.shared_secret.length == 0,
                              "Expected empty payload in EncryptionKeyResponse.");

        auto aes_stream = new AESStream!AES128CFB8(socketstream, new AES128CFB8(shared_secret, shared_secret));
        endianstream = new EndianStream(aes_stream, Endian.bigEndian);

        (new c.ClientStatuses(cast(byte)0)).send(endianstream);
        endianstream.flush();
    }
    
    protected void on_packet(T : s.KeepAlive)(T packet) {
        (new c.KeepAlive(packet.keepalive_id)).send(endianstream);
    }

    protected void on_packet(T : s.Login)(T packet) {
        _logged_in = true;
    }
    
    protected void on_packet(T : s.Disconnect)(T packet) {
        socket.close();
        _connected = false;
    }
}

class ThreadedConnection : Connection {
    protected Thread _thread = null;
    @property Thread thread() { return _thread; }    
    
    this(string username, string password, bool snoop) { super(username, password, snoop); }
    
    void run() {
        if(_thread is null) {
            _thread = new Thread(&(super.run));
            _thread.isDaemon = true;
        }

        _thread.start();
    }
}