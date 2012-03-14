module brala.game;

private {
    import glamour.gl;
    import derelict.glfw3.glfw3;
    
    import std.socket : Address;
    import std.conv : to;
    
    import gl3n.linalg : vec2i, vec3i, vec3;
    import gl3n.math : almost_equal;
        
    import brala.network.connection : Connection, ThreadedConnection;
    import brala.network.packets.types : IPacket;
    import s = brala.network.packets.server;
    import c = brala.network.packets.client;
    import brala.dine.world : World;
    import brala.dine.chunk : Chunk;
    import brala.character : Character;
    import brala.engine : BraLaEngine;
    import brala.event : BaseGLFWEventHandler;
    import brala.types : DefaultAA;
    import brala.util : clear;
    import brala.config;
    
    debug import std.stdio;
}


class BraLaGame : BaseGLFWEventHandler {
    BraLaEngine engine;
    ThreadedConnection connection;
    
    Character character;
    World[int] worlds;
    protected World _current_world;    
    @property current_world() { return _current_world; }
    
    DefaultAA!(bool, int, false) keymap;
    vec2i mouse_offset = vec2i(0, 0);
    
    bool quit = false;
    
    this(BraLaEngine engine, void* window, string username, string password) {
        this.engine = engine;
        connection = new ThreadedConnection(username, password);
        connection.callback = &dispatch_packets;

        super(window); // call this at the end or have a life with segfaults!
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
    
    void start(Address to) {
        connect(to);
        start();
    }
    
    void start(string host, ushort port) {
        connect(host, port);
        start();
    }

    bool poll(float delta_t) {
        if(connection.errored) {
            connection.thread.join(); // let's rethrow the exception for now!
        }
        
        if(keymap[MOVE_FORWARD])  character.move_forward( delta_t * 15);
        if(keymap[MOVE_BACKWARD]) character.move_backward(delta_t * 15);
        if(keymap[STRAFE_LEFT])  character.strafe_left( delta_t * 15);
        if(keymap[STRAFE_RIGHT]) character.strafe_right(delta_t * 15);
        if(mouse_offset.x != 0) character.rotatex(delta_t * mouse_offset.x * 175);
        if(mouse_offset.y != 0) character.rotatey(delta_t * mouse_offset.y * 175);
        mouse_offset.x = 0;
        mouse_offset.y = 0;
        
        character.apply(engine);

        display();
        
        if(quit || keymap[GLFW_KEY_ESCAPE]) {
            disconnect("Goodboy from BraLa.");
            return true;
        } else {
            return false;
        }
    }
    
    void display() {
        clear();

        if(_current_world !is null) {
            engine.use_shader("test_input");
            _current_world.draw(engine);
        }
    }
    
    // Server/Connection
    void connect(Address to) {
        connection.connect(to);
    }
    
    void connect(string host, ushort port) {
        connection.connect(host, port);
    }
    
    void disconnect(string message = "") {
        if(connection.connected) {
            connection.send((new c.Disconnect(message)));
            connection.disconnect();
        }
    }
    
    void login() { // this is blocking
        connection.login();
    }
    
    void dispatch_packets(ubyte id, void* packet) {
        switch(id) {
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
        
        if(_current_world !is null) {
            _current_world.remove_all_chunks();
        }
        
        if(World* w = packet.dimension in worlds) {
            _current_world = *w;
        } else {
            _current_world = new World();
            worlds[packet.dimension] = _current_world;
        }
        
        character = new Character(packet.entity_id);
    }
    
    void on_packet(T : s.ChatMessage)(T packet) {
        debug writefln("%s", packet);
    }
    
    void on_packet(T : s.SpawnPosition)(T packet) {
        debug writefln("%s", packet);
        
        if(_current_world !is null) {
            _current_world.spawn = vec3i(packet.x, packet.y, packet.z);
        }
    }
    
    void on_packet(T : s.MapChunk)(T packet) {
        debug writefln("adding chunk: %s", packet);
        _current_world.add_chunk(packet.chunk, vec3i(packet.chunk.x, 0, packet.chunk.z));
    }
    
    void on_packet(T : s.PlayerPositionLook)(T packet) {
        debug writefln("%s", packet);
        
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
    override void on_key_down(int key) {
        keymap[key] = true;
    }
    
    override void on_key_up(int key) {
        keymap[key] = false;
    }
    
    override void on_mouse_pos(int x, int y) {
        static int last_x = 0;
        static int last_y = 0;
        
        mouse_offset.x = x - last_x;
        mouse_offset.y = y - last_y;
                
        last_x = x;
        last_y = y;
    }
    
    override bool on_window_close() {
        quit = true;
        return true;
    }
}