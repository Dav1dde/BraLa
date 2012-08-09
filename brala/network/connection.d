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

    import brala.exception : ConnectionError, ServerError, SessionError;
    import brala.network.session : Session;
    import brala.network.stream : AESStream;
    import brala.network.util : read, write;
    import brala.network.packets.types : IPacket, Array;
    import s = brala.network.packets.server;
    import c = brala.network.packets.client;
    import brala.utils.queue : PacketQueue;
    import brala.utils.openssl.encrypt : AES128CFB8;
    import brala.utils.crypto : decode_public, encrypt, seed_prng, get_random;
    import brala.utils.thread : Timer;
    
    debug import std.stdio : writefln;
}


class Connection {
    TcpSocket socket;
    SocketStream socketstream;
    EndianStream endianstream;
    protected PacketQueue queue;
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
    
    immutable byte protocol_version = 39;
    
    this(string username, string password, bool snoop) {
        socket = new TcpSocket();
        socketstream = new SocketStream(socket);
        endianstream = new EndianStream(socketstream, Endian.bigEndian);
        queue = new PacketQueue();
        
        session = new Session(username, password);

        try {
            session.login();
            this.minecraft_username = session.minecraft_username;
        } catch(SessionError e) {
            debug writefln("%s", e.message);
            this.minecraft_username = username;
        }

        if(snoop) {
            auto snoop_args = tuple("BraLa", os.to!string(), "undetectable", isX86_64 ? "64 bit":"32 bit",
                                    "-1", "-1", "D Compiler: " ~ to!string(__VERSION__),
                                    to!string(glGetString(GL_VERSION)), to!string(glGetString(GL_VENDOR)));

            void snoop_timer() {
                if(_connected) {
                    auto timer = new Timer(dur!"minutes"(11),
                         delegate void() { Session.snoop(snoop_args.expand); snoop_timer(); });
                    timer.isDaemon = true;
                    timer.start();
                }
            }

            snoop_timer();
        }
   
        this.username = username;
        this.password = password;
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
    
    void disconnect() {
        socket.shutdown(SocketShutdown.BOTH);
        socket.close();
        _connected = false;
        _logged_in = false;
    }
    
    void send(T : IPacket)(T packet) {
        queue.add(packet);
    }
    
    void login() {
        assert(callback !is null);
        
        auto handshake = new c.Handshake(protocol_version, minecraft_username,
                                         connected_to.toHostNameString(),
                                         to!int(connected_to.toPortString()));
        handshake.send(endianstream);

        ubyte repl_byte = read!ubyte(endianstream);
        if(repl_byte == s.Disconnect.id) {
            throw new ServerError(s.Disconnect.recv(endianstream).reason);
        } else if(repl_byte != s.EncryptionKeyRequest.id) {
            throw new ServerError("Server didn't respond with a EncryptionKeyRequest.");
        }
        
        auto enc_request = s.EncryptionKeyRequest.recv(endianstream);
        callback(enc_request.id, cast(void*)enc_request);
        
        auto rsa = decode_public(enc_request.public_key.arr);

        ubyte[] enc_verify_token = rsa.encrypt(enc_request.verify_token.arr);
        seed_prng();
        ubyte[] shared_secret = get_random(16);
        ubyte[] enc_shared_secret = rsa.encrypt(shared_secret);

        if(enc_request.server_id != "-") {
            enforceEx!SessionError(session.logged_in, `Unable to login as user "` ~ username ~ `". `);
            session.join(enc_request.server_id, shared_secret, enc_request.public_key.arr);
        }

        auto enc_key = new c.EncryptionKeyResponse(Array!(short, ubyte)(enc_shared_secret),
                                                   Array!(short, ubyte)(enc_verify_token));
        enc_key.send(endianstream);

        repl_byte = read!ubyte(endianstream);
        enforceEx!ServerError(repl_byte == s.EncryptionKeyResponse.id, "Server didn't respond with a EncryptionKeyResponse.");
        auto enc_response = s.EncryptionKeyResponse.recv(endianstream);
        enforceEx!ServerError(enc_response.verify_token.length == 0 && enc_response.shared_secret.length == 0,
                              "Expected empty payload in EncryptionKeyResponse.");
        callback(enc_response.id, cast(void*)enc_response);

        auto aes_stream = new AESStream!AES128CFB8(socketstream, new AES128CFB8(shared_secret, shared_secret));
        endianstream = new EndianStream(aes_stream, Endian.bigEndian);

        (new c.ClientStatuses(cast(byte)0)).send(endianstream);
        endianstream.flush();
    }

    
    void poll() {
        try {
            _poll();
        } catch(Exception e) {
            _connected = false;
            errored = true;
            throw e;
        }
    }
    
    void _poll() {
        ubyte packet_id = read!ubyte(endianstream);

        foreach(packet; queue) {
            packet.send(endianstream);
        }
        endianstream.flush();

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