module brala.entities.player;

private {
    import gl3n.linalg;
    import gl3n.math;
    import glwtf.window : Window;

    import std.conv : to;
    import core.time : TickDuration;
    
    import brala.game : BraLaGame;
    import brala.engine : BraLaEngine;
    import brala.network.session : Session;
    import brala.network.connection : Connection;
    import c = brala.network.packets.client;
    import brala.gfx.camera : FirstPersonCamera;
    import brala.physics.physics : Physics, CreativePhysics, SurvivalPhysics;
    import brala.entities.mobs : NamedEntity;

    import brala.utils.config : Config, ConfigBound;
}


class Player : NamedEntity {
    static const vec3 YAW_0_DIRECTION = vec3(0.0f, 0.0f, 1.0f);
    
    BraLaGame game;
    BraLaEngine engine;
    Window window;
    Connection connection;

    @property auto world() { return game.current_world; }

    Physics physics;
    FirstPersonCamera camera;

    @property vec3 position() { return camera.position; }
    @property void position(vec3 position) {
        if(camera.position != position) {
            camera.position = position;
            dirty = true;
        }
    }
    @property vec3 rotation() { return camera.rotation; }
    @property void rotation(vec3 rotation) { camera.rotation = rotation; dirty = true; }

    float moving_speed = 4.35f; // creative speed
    ConfigBound!int MOVE_UP;
    ConfigBound!int MOVE_DOWN;
    ConfigBound!int MOVE_FORWARD;
    ConfigBound!int MOVE_BACKWARD;
    ConfigBound!int STRAFE_LEFT;
    ConfigBound!int STRAFE_RIGHT;
    ConfigBound!float SENSITIVITY = 5.0f;

    protected vec2i mouse_offset = vec2i(0, 0);
    protected bool moved;
    protected bool dirty;

    this(BraLaGame game, int entity_id) {
        super(entity_id, game.session.minecraft_username);
        
        this.game = game;
        this.engine = game.engine;
        this.window = engine.window;
        this.connection = game.connection;

        this.physics = new CreativePhysics(game.current_world);

        this.camera = new FirstPersonCamera();
        this.camera.offset = vec3(0.0f, 1.6f, 0.0f);
        this.camera.viewport = engine.viewport;

        engine.on_resize.connect({ camera.viewport = engine.viewport; });
        window.on_mouse_pos.connect(&on_mouse_pos);
        game.on_notchian_tick.connect(&on_tick);

        game.config.connect(MOVE_UP, "game.key.movement.up").emit();
        game.config.connect(MOVE_DOWN, "game.key.movement.down").emit();
        game.config.connect(MOVE_FORWARD, "game.key.movement.forward").emit();
        game.config.connect(MOVE_BACKWARD, "game.key.movement.backward").emit();
        game.config.connect(STRAFE_LEFT, "game.key.movement.left").emit();
        game.config.connect(STRAFE_RIGHT, "game.key.movement.right").emit();
        game.config.connect(SENSITIVITY, "game.mouse.sensitivity").emit();

        assert(MOVE_FORWARD.value != 0);
        assert(MOVE_BACKWARD.value != 0);
        assert(STRAFE_LEFT.value != 0);
        assert(STRAFE_RIGHT.value != 0);
    }

    void update(TickDuration delta_t) {
        bool moved = false;

        float turning_speed = delta_t.to!("seconds", float) * SENSITIVITY;

        if(mouse_offset.x != 0) { camera.rotatey((-turning_speed * mouse_offset.x).radians); moved = true; }
        if(mouse_offset.y != 0) { camera.rotatex((turning_speed * mouse_offset.y).radians); moved = true; }
        mouse_offset = vec2i(0, 0);

        float movement = delta_t.to!("seconds", float) /+0.05+/ * moving_speed;
        vec3 delta = vec3(
            (window.is_key_down(STRAFE_RIGHT)  * movement) - (window.is_key_down(STRAFE_LEFT)  * movement),
            (window.is_key_down(MOVE_UP)       * movement) - (window.is_key_down(MOVE_DOWN)    * movement),
            (window.is_key_down(MOVE_BACKWARD) * movement) - (window.is_key_down(MOVE_FORWARD) * movement)
        );

        position = physics.move(
            position,
            camera.move(delta)
        );

        physics.apply(camera);

        if(moved || dirty) {
            camera.apply(engine);
            dirty = false;
            this.moved = true;
        }
    }

    void on_tick() {        
        if(moved && connection.logged_in) {
            send_packet();
            moved = false;
        }
    }

    void send_packet() {
        connection.send(new c.PlayerPositionLook(
            position.x, position.y, position.y + 1.6, position.z,
            (180-rotation.y.degrees), rotation.x.degrees, true
        ));
    }

    void on_mouse_pos(double x, double y) {
        static int last_x = 0;
        static int last_y = 0;

        mouse_offset.x = cast(int)x - last_x;
        mouse_offset.y = cast(int)y - last_y;

        last_x = cast(int)x;
        last_y = cast(int)y;
    }
}