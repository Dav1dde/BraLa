module brala.game;

private {
    import glamour.gl;
    import glamour.shader : Shader;
    
    import glwtf.glfw;
    import glwtf.signals;
    
    import std.socket : Address;
    import std.conv : to;
    import std.math : isNaN;
    import core.time : TickDuration;
    import core.thread: thread_isMainThread;
    
    import gl3n.linalg : vec2i, vec3i, vec3;
    import gl3n.math : almost_equal, radians;

    import brala.log : logger = game_logger;
    import brala.utils.log;
    import brala.network.session : Session;
    import brala.network.connection : Packet, Connection, ThreadedConnection;
    import s = brala.network.packets.server;
    import c = brala.network.packets.client;
    import brala.dine.world : World;
    import brala.dine.chunk : Chunk, Block;
    import brala.engine : BraLaEngine;
    import brala.entities.player : Player;
    import brala.gfx.world : draw;
    import brala.gfx.data;
    import brala.gfx.renderer : IRenderer, ForwardRenderer, DeferredRenderer;
    import brala.gfx.terrain : MinecraftAtlas;
    import brala.gfx.text : parse_chat;
    import brala.gfx.gl : clear;
    import brala.utils.aa : DefaultAA;
    import brala.utils.config : Config;
    
    debug import std.stdio;
}

final class BraLaGame {
    BraLaEngine engine;
    Config config;
    Session session;
    MinecraftAtlas atlas;
    ThreadedConnection connection;
    IRenderer renderer;
    
    Player player;
    protected World _current_world;    
    @property current_world() { return _current_world; }
    
    protected bool moved = false;
    protected TickDuration last_notchian_tick;

    Signal!() on_notchian_tick;

    this(BraLaEngine engine, Session session, MinecraftAtlas atlas) {
        this.engine = engine;
        this.config = engine.config;
        this.session = session;
        this.atlas = atlas;
        this.connection = new ThreadedConnection(session);

        if(config.get_option!("forward", "deferred")("game.renderer") == "forward") {
            logger.log!Info("Using forward renderer");
            this.renderer = new ForwardRenderer(engine);
        } else {
            logger.log!Info("Using deferred renderer");
            this.renderer = new DeferredRenderer(engine);
        }

        engine.on_frame.connect!"poll"(this);
        engine.on_shutdown.connect!"shutdown"(this);
    }

    void quit() {
        engine.stop();
    }

    protected void shutdown() {
        if(connection.connected && connection.thread.isRunning) {
            disconnect("Garbage collector went crazy, again");
            logger.log!Info("Waiting for connection thread to shutdown");
            connection.thread.join(false);
            logger.log!Info("Connection is done");
        }
    }

    // rendering
    void start() {
        assert(connection.connected);
        if(!connection.logged_in) {
            login();
        }
        connection.run();

        engine.mainloop();
    }
    
    void start(Address to, string hostname) {
        connect(to, hostname);
        start();
    }
    
    void start(string host, ushort port) {
        connect(host, port);
        start();
    }

    void poll(TickDuration delta_t) {
        logger.log_if!Info(!connection.thread.isRunning,
                           "Connection thread died").ifTrue(&engine.stop);
        logger.log_if!Error_(current_world !is null && !current_world.is_ok,
                             "Tessellation thread died!").ifTrue(&engine.stop);

        foreach(packet; connection.outbuf.read_all()) {
            dispatch_packets(packet.id, packet.ptr);
        }

        if(player !is null) {
            player.update(delta_t);
        }

        display();
        
        TickDuration now = engine.timer.get_time();
        if((now - last_notchian_tick).to!("msecs", int) >= 50) {
            on_notchian_tick.emit();
            last_notchian_tick = now;
        }
    }
    
    void display() {
        renderer.enter();
        scope(success) renderer.exit();

        current_world.draw(engine, renderer);
    }
    
    // Server/Connection
    void connect(Address to, string hostname) {
        connection.connect(to, hostname);
    }
    
    void connect(string host, ushort port) {
        connection.connect(host, port);
    }
    
    void disconnect(string message = "") {
        connection.disconnect(message);
        connection.shutdown();
    }
    
    void login() { // this is blocking
        connection.login();
    }
    
    // network events
    void dispatch_packets(ubyte id, void* packet)
        in { assert(thread_isMainThread(), "dispatch packets not called from the main thread!");
             assert(packet !is null, "packet is null"); }
        body {
            final switch(id) {
                foreach(p; s.get_packets!()) {
                    case p.id: p.cls cpacket = cast(p.cls)packet;
                            return on_packet!(p.cls)(cpacket);
                }
            }
        }
    
    void on_packet(T : s.Handshake)(T packet) {
        logger.log!Info("%s", packet);
    }
    
    void on_packet(T : s.Login)(T packet) {
        logger.log!Info("%s", packet);

        if(_current_world !is null) _current_world.shutdown();
        _current_world = new World(engine, atlas);
        
        player = new Player(this, packet.entity_id);
    }
    
    void on_packet(T : s.ChatMessage)(T packet) {
        auto chat = parse_chat(packet.message);
        chat.print_colorized();
    }
    
    void on_packet(T : s.SpawnPosition)(T packet) {
        if(_current_world !is null) {
            _current_world.spawn = vec3i(packet.x, packet.y, packet.z);
        }
    }

    void on_packet(T : s.MapChunk)(T packet) {
        vec3i coords = vec3i(packet.chunk.x, 0, packet.chunk.z);
        
        if(packet.chunk.chunk.primary_bitmask != 0) {
            _current_world.add_chunk(packet.chunk, coords);
        } else if(packet.chunk.chunk.add_bitmask == 0) {
            if(Chunk* chunk = coords in _current_world.chunks) {
                _current_world.remove_chunk(coords);
                //debug _current_world.vram.log();
            }
        }
    }

    void on_packet(T : s.MapChunkBulk)(T packet) {
        logger.log!Info("%d chunks incoming", packet.chunk_bulk.chunks.length);

        foreach(cc; packet.chunk_bulk.chunks) with(cc) {
            if(chunk.primary_bitmask != 0) {
                _current_world.add_chunk(chunk, coords);
            } else if(chunk.add_bitmask == 0) {
                if(Chunk* chunk = coords in _current_world.chunks) {
                    _current_world.remove_chunk(coords);
                    //debug _current_world.vram.log();
                }
            }
        }
    }

    void on_packet(T : s.BlockChange)(T packet) {
        _current_world.set_block(vec3i(packet.x, packet.y, packet.z), Block(packet.type, packet.metadata));
    }

    void on_packet(T : s.MultiBlockChange)(T packet) {
        vec3i chunkc = vec3i(packet.x, 0, packet.z);
        
        Chunk chunk = _current_world.get_chunk(chunkc);

        if(chunk !is null) {
            packet.data.load_into_chunk(chunk);
            chunk.dirty = true;
        }
    }
    
    void on_packet(T : s.PlayerPositionLook)(T packet)
        in { assert(!isNaN(packet.x) && !isNaN(packet.y) && !isNaN(packet.z)); }
        body {
            player.position = vec3(
                packet.x.to!float,
                packet.y.to!float,
                packet.z.to!float
            );

            packet.yaw = isNaN(packet.yaw) ? 0 : packet.yaw;
            packet.pitch = isNaN(packet.pitch) ? 0 : packet.pitch;
            player.rotation = vec3(
                packet.pitch.radians,
                (180 - packet.yaw).radians,
                0
            );

            connection.send(new c.PlayerPositionLook(
                packet.x, packet.y, packet.stance, packet.z,
                packet.yaw, packet.pitch, packet.on_ground
            ));
        }

    void on_packet(T : s.Disconnect)(T packet) {
        logger.log!Info("%s", packet);
        quit();
    }

    void on_packet(T)(T packet) {
//         logger.log!Debug("Unhandled packet: %s", packet);
    }
}
