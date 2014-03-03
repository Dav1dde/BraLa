module brala.network.connection;


private {
    import glamour.gl : glGetString, GL_VERSION, GL_VENDOR;
    
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

    import deimos.openssl.rsa : RSA, RSA_free;

    import brala.log : logger = connection_logger;
    import brala.utils.log;
    import brala.exception : ConnectionError, ServerError, SessionError;
    import brala.network.session : Session;
    import brala.network.stream : AESStream, LoggingStream;
    import brala.network.util : read, write;
    import brala.network.packets.types : Array;
    import s = brala.network.packets.server;
    import c = brala.network.packets.client;
    import brala.minecraft.crypto : decode_public, encrypt, seed_prng, get_random, get_random_max;
    import brala.utils.ringbuffer : RingBuffer;
    import brala.utils.openssl.encrypt : AES128CFB8;
    import brala.utils.thread : Thread, VerboseThread, Timer;
}

public import brala.network.packets.types : IPacket;


class Connection {
    TcpSocket socket;
    SocketStream socketstream;
    EndianStream endianstream;
    protected bool _connected = false;
    protected Address connected_to;
    protected bool _logged_in = false;
    
    @property connected() { return _connected; }
    @property logged_in() { return _logged_in; }
    
    package Session session;
    
    void delegate(ubyte, void*) callback;
    
    /+immutable+/ string hostname;

    protected Timer snoop_timer;
    protected bool snoop;

    protected ubyte[] shared_secret;
    
    static immutable byte protocol_version = 74;
    
    this(Session session) {
        this.session = session;        
    }
    
    void connect(Address to, string hostname) {
        socket = new TcpSocket(to.addressFamily);
        socketstream = new SocketStream(socket);
        endianstream = new EndianStream(socketstream, Endian.bigEndian);

        socket.connect(to);
        _connected = true;
        connected_to = to;

        this.hostname = hostname;
    }
    
    void connect(string host, ushort port) {
        Address[] to = getAddress(host, port);

        connect(to[0], host);
    }
    
    void shutdown() {
        try {
            socket.shutdown(SocketShutdown.BOTH);
            socket.close();
        } catch(Exception e) {
            logger.log_exception!Info(e, "during connection-shutdown");
        }
        
        _connected = false;
        _logged_in = false;
    }

    void disconnect(string message = "") {
        if(logged_in) {
            send((new c.Disconnect(message)));
        }

        if(connected) {
            shutdown();
        }
    }
    
    void send(IPacket[] packets...) {
        foreach(packet; packets) {
            packet.send(endianstream);
        }
        endianstream.flush();
    }
    
    void login() {
        auto handshake = new c.Handshake(protocol_version,
                                         session.minecraft_username,
                                         hostname,
                                         to!int(connected_to.toPortString()));
        
        handshake.send(endianstream);
    }
    
    void poll() {
        ubyte packet_id = read!ubyte(endianstream);

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
        RSA* rsa = decode_public(packet.public_key.arr);
        scope(exit) RSA_free(rsa);

        ubyte[] enc_verify_token = rsa.encrypt(packet.verify_token.arr);
        this.shared_secret = get_random(16);
        ubyte[] enc_shared_secret = rsa.encrypt(shared_secret);

        if(packet.server_id != "-") {
            enforceEx!SessionError(session.logged_in, `Unable to login as user "` ~ session.minecraft_username ~ `". `);
            session.join(packet.server_id, shared_secret, packet.public_key.arr);
        }

        auto enc_key = new c.EncryptionKeyResponse(Array!(short, ubyte)(enc_shared_secret),
                                                   Array!(short, ubyte)(enc_verify_token));
        enc_key.send(endianstream);
        endianstream.flush();
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
        logger.log!Info("Got Kicked: `%s`", packet.reason);
        shutdown();
    }
}

struct Packet {
    ubyte id;
    void* ptr;
}

// NOTE writing to this connection from multiple threads
// is not supported, max. 1 reader, 1 writer!
class ThreadedConnection : Connection {
    protected Thread _thread = null;
    @property Thread thread() { return _thread; }    

    public RingBuffer!Packet outbuf;
    
    this(Session session) {
        super(session);

        // NOTE 128 is the critical size, let's hope
        // 512 is enough!
        // We also want the GC to take care of our memory,
        // Packet.ptr contains a GC allocated class!
        outbuf = new RingBuffer!Packet(512, true);
        callback = &add_to_queue;
    }

    protected
    void add_to_queue(ubyte id, void* packet) {
        logger.log_if!Warn(outbuf.write_count == 0,
                "RingBuffer for packets full! Deadlock incoming!?");
        outbuf.write_one(Packet(id, packet));
    }

    override
    void send(IPacket[] packets...) {
        foreach(packet; packets) {
            packet.send(endianstream);
        }
        endianstream.flush();
    }

    override
    void run() {
        if(_thread is null) {
            _thread = new VerboseThread(&super.run);
            _thread.name = "BraLa Connection Thread";
        }

        _thread.start();
    }
}