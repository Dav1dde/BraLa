module brala.game;

private {
    import glamour.gl;
    import glwtf.glfw;
    
    import std.socket : Address;
    import std.conv : to;
    import std.math : isNaN;
    import core.time : TickDuration;
    
    import gl3n.linalg : vec2i, vec3i, vec3;
    import gl3n.math : almost_equal, radians;

    import brala.config : AppArguments;
    import brala.network.connection : Connection, ThreadedConnection;
    import brala.network.packets.types : IPacket;
    import s = brala.network.packets.server;
    import c = brala.network.packets.client;
    import brala.dine.world : World;
    import brala.dine.chunk : Chunk, Block;
    import brala.character : Character;
    import brala.engine : BraLaEngine;
    import brala.gfx.text : parse_chat;
    import brala.gfx.gl : clear;
    import brala.utils.defaultaa : DefaultAA;
    import brala.utils.queue : Queue;
    import brala.config;
    
    debug import brala.utils.stdio;
}


class BraLaGame {
    protected Object _world_lock;
    
    BraLaEngine engine;
    ThreadedConnection connection;
    
    protected Queue!vec3i chunk_removal_queue;
    
    Character character;
    protected World _current_world;    
    @property current_world() { return _current_world; }
    
    protected vec2i mouse_offset = vec2i(0, 0);
    
    bool quit = false;
    protected bool moved = false;
    protected TickDuration last_notchian_tick;

    size_t tessellation_threads = 3;
    
    this(BraLaEngine engine, string username, string password, AppArguments app_args) {
        this.tessellation_threads = app_args.tessellation_threads;
    
        _world_lock = new Object();
        chunk_removal_queue = new Queue!vec3i();

        this.engine = engine;
        connection = new ThreadedConnection(username, password, !app_args.no_snoop);
        connection.callback = &dispatch_packets;

        character = new Character(0);

        engine.window.on_mouse_pos.connect(&on_mouse_pos);
        engine.window.on_close = &on_window_close;
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
        if(connection.errored) {
            connection.thread.join(); // let's rethrow the exception for now!
        }

        foreach(chunkc; chunk_removal_queue) {
            synchronized(_world_lock) {
                if(Chunk* chunk = chunkc in _current_world.chunks) {
                    _current_world.remove_chunk(chunkc);
                    debug _current_world.vram.print();
                }
            }
        }
        
        moved = move(delta_t) || moved;
        
        display();
        
        TickDuration now = engine.timer.get_time();
        if((now - last_notchian_tick).to!("msecs", int) >= 50) {
            on_notchian_tick();
            last_notchian_tick = now;
        }
        
        if(quit || engine.window.is_key_down(GLFW_KEY_ESCAPE)) {
            if(connection.connected) disconnect("Goodboy from BraLa.");
            return true;
        } else {
            return false;
        }
    }
    
    bool move(TickDuration delta_t) {
        float movement = delta_t.to!("seconds", float) * character.moving_speed;

        bool moved = false;

        if(engine.window.is_key_down(MOVE_FORWARD))  character.move_forward(movement); moved = true;
        if(engine.window.is_key_down(MOVE_BACKWARD)) character.move_backward(movement); moved = true;
        if(engine.window.is_key_down(STRAFE_LEFT))  character.strafe_left(movement); moved = true;
        if(engine.window.is_key_down(STRAFE_RIGHT)) character.strafe_right(movement); moved = true;
        if(mouse_offset.x != 0) character.rotatex(-movement * mouse_offset.x); moved = true;
        if(mouse_offset.y != 0) character.rotatey(movement * mouse_offset.y); moved = true;
        mouse_offset.x = 0;
        mouse_offset.y = 0;
        
        if(moved) character.apply(engine);
        
        return moved;
    }
    
    void display() {
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
    
    void on_notchian_tick() {
        if(moved && connection.logged_in && character.activated) {
            character.send_packet(connection);
            moved = false;
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
        if(connection.logged_in) {
            connection.send((new c.Disconnect(message)));
            connection.disconnect();
        }
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
        debug writefln("%s", packet);
    }
    
    void on_packet(T : s.Login)(T packet) {
        debug writefln("%s", packet);
        
        synchronized(_world_lock) {
            if(_current_world !is null) {
                _current_world.remove_all_chunks();
            }
            
            _current_world = new World(engine.resmgr, tessellation_threads);
        }
        
        character = new Character(packet.entity_id);
    }
    
    void on_packet(T : s.ChatMessage)(T packet) {
        auto chat = parse_chat(packet.message);
        chat.print_colorized();
    }
    
    void on_packet(T : s.SpawnPosition)(T packet) {
        debug writefln("%s", packet);
        
        synchronized(_world_lock) {
            if(_current_world !is null) {
                _current_world.spawn = vec3i(packet.x, packet.y, packet.z);
            }
        }
    }
    
    void on_packet(T : s.MapChunk)(T packet) {
        if(packet.chunk.chunk.primary_bitmask != 0) {
            debug writefln("adding chunk: %s", packet);
            synchronized(_world_lock) _current_world.add_chunk(packet.chunk, vec3i(packet.chunk.x, 0, packet.chunk.z));
            debug _current_world.vram.print();
        } else if(packet.chunk.chunk.add_bitmask == 0) {
            chunk_removal_queue.put(vec3i(packet.chunk.x, 0, packet.chunk.z));
        }
    }

    void on_packet(T : s.MapChunkBulk)(T packet) {
        debug writefln("%s", packet);

        synchronized(_world_lock) {
            foreach(cc; packet.chunk_bulk.chunks) {
                if(cc.chunk.primary_bitmask != 0) {
                    _current_world.add_chunk(cc.chunk, cc.coords);
                } else if(cc.chunk.add_bitmask == 0) {
                    chunk_removal_queue.put(cc.coords);
                }
            }
        }
    }

    void on_packet(T : s.BlockChange)(T packet) {
        debug writefln("%s", packet);
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
            debug writefln("%s", packet);
            
            packet.yaw = isNaN(packet.yaw) ? 0:radians(packet.yaw);
            packet.pitch = isNaN(packet.pitch) ? 0:radians(packet.pitch);
            
            character.activated = true;
            character.position = vec3(to!float(packet.x), to!float(packet.y), to!float(packet.z)); // TODO: change it to doubles
            character.set_rotation(packet.yaw, packet.pitch);
                    
            auto repl = new c.PlayerPositionLook(packet.x, packet.y, packet.stance, packet.z, packet.yaw, packet.pitch, packet.on_ground);
            connection.send(repl);
        }

    void on_packet(T : s.Disconnect)(T packet) {
        debug writefln("%s", packet);
        quit = true;
    }

    void on_packet(T)(T packet) {
//         debug writefln("Unhandled packet: %s", packet);
    }
    
    // UI-Events   
    void on_mouse_pos(int x, int y) {
        static int last_x = 0;
        static int last_y = 0;
        
        mouse_offset.x = x - last_x;
        mouse_offset.y = y - last_y;
                
        last_x = x;
        last_y = y;
    }
    
    bool on_window_close() {
        quit = true;
        return true;
    }
}
