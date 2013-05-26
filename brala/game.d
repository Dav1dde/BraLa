module brala.game;

private {
    import glamour.gl;
    import glamour.shader : Shader;
    
    import glwtf.glfw;
    
    import std.socket : Address;
    import std.conv : to;
    import std.math : isNaN;
    import core.time : TickDuration;
    import std.signals;
    
    import gl3n.linalg : vec2i, vec3i, vec3;
    import gl3n.math : almost_equal, radians;

    import brala.log : logger = game_logger;
    import brala.utils.log;
    import brala.network.session : Session;
    import brala.network.connection : Connection, ThreadedConnection;
    import brala.network.packets.types : IPacket;
    import s = brala.network.packets.server;
    import c = brala.network.packets.client;
    import brala.dine.world : World;
    import brala.dine.chunk : Chunk, Block;
    import brala.engine : BraLaEngine;
    import brala.entities.player : Player;
    import brala.gfx.text : parse_chat;
    import brala.gfx.gl : clear;
    import brala.utils.aa : DefaultAA;
    import brala.utils.queue : Queue;
    import brala.utils.config : Config;
    
    debug import std.stdio;
}

class BraLaGame {
    protected Object _world_lock;
    
    BraLaEngine engine;
    Config config;
    Session session;
    ThreadedConnection connection;

    alias void delegate() CallBack;
    protected Queue!CallBack callback_queue;
    
    Player player;
    protected World _current_world;    
    @property current_world() { return _current_world; }
    
    protected bool _quit = false;
    protected bool moved = false;
    protected TickDuration last_notchian_tick;

    mixin Signal!() on_notchian_tick;

    size_t tessellation_threads = 3;
    
    this(BraLaEngine engine, Session session, Config config) {
        this.config = config;
        this.tessellation_threads = config.get!int("brala.tessellation_threads");
    
        _world_lock = new Object();
        callback_queue = new Queue!CallBack();

        this.engine = engine;
        this.session = session;
        connection = new ThreadedConnection(session);
        connection.callback = &dispatch_packets;
    }

    void quit() {
        _quit = true;
    }

    // rendering
    void start() {
        assert(connection.connected);
        if(!connection.logged_in) {
            login();
        }
        connection.run();

        engine.mainloop(&poll);
    }
    
    void start(Address to, string hostname) {
        connect(to, hostname);
        start();
    }
    
    void start(string host, ushort port) {
        connect(host, port);
        start();
    }

    bool poll(TickDuration delta_t) {
        if(!connection.thread.isRunning) {
            logger.log!Info("Connection thread died");
            _quit = true;
        }
        
        if(_quit) {           
            if(connection.connected && connection.thread.isRunning) {
                connection.disconnect("Garbage collector went crazy, again");
                logger.log!Info("Waiting for connection thread to shutdown");
                connection.thread.join(false);
                logger.log!Info("Connection is done");
            }
            
            if(_current_world !is null) _current_world.shutdown();

            return true;
        }

        if(callback_queue.qsize()) synchronized(_world_lock) {
            foreach(cb; callback_queue) {
                cb();
            }
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
        
        return false;
    }
    
    void display() {
        glDisable(GL_BLEND);
        clear(vec3(0.2f, 0.2f, 0.9f));

        synchronized(_world_lock) {
            if(_current_world !is null) {
                engine.use_shader("terrain");

                engine.use_texture("terrain");
                engine.current_shader.uniform1i("terrain", 0);

                current_world.draw(engine);
            }
        }
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
    }
    
    void login() { // this is blocking
        connection.login();
    }
    
    // network events
    void dispatch_packets(ubyte id, void* packet) {
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
        
        synchronized(_world_lock) {
            if(_current_world !is null) {
                callback_queue.put(&_current_world.shutdown);
            }
            
            _current_world = new World(engine.resmgr, tessellation_threads);
        }
        
        player = new Player(this, packet.entity_id);
        player.update_keys(config);
    }
    
    void on_packet(T : s.ChatMessage)(T packet) {
        auto chat = parse_chat(packet.message);
        chat.print_colorized();
    }
    
    void on_packet(T : s.SpawnPosition)(T packet) {
        synchronized(_world_lock) {
            if(_current_world !is null) {
                _current_world.spawn = vec3i(packet.x, packet.y, packet.z);
            }
        }
    }

    enum chunk_removal_cb = "
    delegate void() {
        if(Chunk* chunk = coords in _current_world.chunks) {
            _current_world.remove_chunk(coords);
            debug _current_world.vram.log();
        }
    }";
    
    void on_packet(T : s.MapChunk)(T packet) {
        vec3i coords = vec3i(packet.chunk.x, 0, packet.chunk.z);
        
        if(packet.chunk.chunk.primary_bitmask != 0) {
            synchronized(_world_lock) _current_world.add_chunk(packet.chunk, coords);
        } else if(packet.chunk.chunk.add_bitmask == 0) {
            callback_queue.put(mixin(chunk_removal_cb));
        }
    }

    void on_packet(T : s.MapChunkBulk)(T packet) {
        logger.log!Info("%d chunks incoming", packet.chunk_bulk.chunks.length);

        synchronized(_world_lock) {
            foreach(cc; packet.chunk_bulk.chunks) {
                with(cc) {
                    if(chunk.primary_bitmask != 0) {
                        _current_world.add_chunk(chunk, coords);
                    } else if(chunk.add_bitmask == 0) {
                        callback_queue.put(mixin(chunk_removal_cb));
                    }
                }
            }
        }
    }

    void on_packet(T : s.BlockChange)(T packet) {
        synchronized(_world_lock) _current_world.set_block(vec3i(packet.x, packet.y, packet.z), Block(packet.type, packet.metadata));
    }

    void on_packet(T : s.MultiBlockChange)(T packet) {
        vec3i chunkc = vec3i(packet.x, 0, packet.z);
        
        synchronized(_world_lock) {
            Chunk chunk = _current_world.get_chunk(chunkc);

            if(chunk !is null) {
                packet.data.load_into_chunk(chunk);
                chunk.dirty = true;
            }
        }
    }
    
    void on_packet(T : s.PlayerPositionLook)(T packet)
        in { assert(!isNaN(packet.x) && !isNaN(packet.y) && !isNaN(packet.z)); }
        body {
            packet.yaw = isNaN(packet.yaw) ? 0:radians(packet.yaw);
            packet.pitch = isNaN(packet.pitch) ? 0:radians(packet.pitch);
            
            player.position = vec3(to!float(packet.x), to!float(packet.y), to!float(packet.z)); // TODO: change it to doubles
            player.set_rotation(packet.yaw, packet.pitch);
                    
            auto repl = new c.PlayerPositionLook(packet.x, packet.y, packet.stance, packet.z, packet.yaw, packet.pitch, packet.on_ground);
            connection.send(repl);
        }

    void on_packet(T : s.Disconnect)(T packet) {
        logger.log!Info("%s", packet);
        quit();
    }

    void on_packet(T)(T packet) {
//         logger.log!Debug("Unhandled packet: %s", packet);
    }
}
