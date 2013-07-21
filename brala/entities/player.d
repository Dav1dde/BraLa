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
    import brala.gfx.camera : Camera, FirstPersonCamera;
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
    Camera camera;

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
    ConfigBound!int MOVE_FORWARD;
    ConfigBound!int MOVE_BACKWARD;
    ConfigBound!int STRAFE_LEFT;
    ConfigBound!int STRAFE_RIGHT;
    ConfigBound!int MOVE_UP;
    ConfigBound!int MOVE_DOWN;
    ConfigBound!int JUMP;
    ConfigBound!int SNEAK;
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

        this.camera = new FirstPersonCamera(vec3(0.0f, 1.55f, 0.0f));
        this.camera.viewport = engine.viewport;
        this.camera.recalculate();

//         this.physics = new SurvivalPhysics(this, camera, game.current_world);
        this.physics = new CreativePhysics(this, camera, game.current_world);

        engine.on_resize.connect!"on_resize"(this);
        window.on_mouse_pos.connect!"on_mouse_pos"(this);
        game.on_notchian_tick.connect!"on_tick"(this);

        game.config.connect(MOVE_FORWARD, "game.key.movement.forward").emit();
        game.config.connect(MOVE_BACKWARD, "game.key.movement.backward").emit();
        game.config.connect(STRAFE_LEFT, "game.key.movement.left").emit();
        game.config.connect(STRAFE_RIGHT, "game.key.movement.right").emit();
        game.config.connect(JUMP, "game.key.movement.jump").emit();
        game.config.connect(SNEAK, "game.key.movement.sneak").emit();
        game.config.connect(MOVE_UP, "game.key.movement.jump").emit();
        game.config.connect(MOVE_DOWN, "game.key.movement.sneak").emit();
        game.config.connect(SENSITIVITY, "game.mouse.sensitivity").emit();

        assert(MOVE_FORWARD.value != 0);
        assert(MOVE_BACKWARD.value != 0);
        assert(STRAFE_LEFT.value != 0);
        assert(STRAFE_RIGHT.value != 0);
    }

    void on_resize() {
        camera.viewport = engine.viewport;
        camera.recalculate();
    }

    void update(TickDuration delta_t) {
        float s = delta_t.to!("seconds", float);

        float turning_speed = s * SENSITIVITY;
        if(mouse_offset.x != 0) { camera.rotatey((-turning_speed * mouse_offset.x).radians); dirty = true; }
        if(mouse_offset.y != 0) { camera.rotatex((turning_speed * mouse_offset.y).radians); dirty = true; }
        mouse_offset = vec2i(0, 0);

        vec3 delta = vec3(
            window.is_key_down(STRAFE_RIGHT)  - window.is_key_down(STRAFE_LEFT),
            window.is_key_down(MOVE_UP)       - window.is_key_down(MOVE_DOWN),
            window.is_key_down(MOVE_BACKWARD) - window.is_key_down(MOVE_FORWARD)
        );

        physics.move(delta, s);
        physics.apply(s);

        if(dirty) {
            camera.apply(engine);
            dirty = false;
            moved = true;
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
            (180-rotation.y.degrees), rotation.x.degrees,
            physics.on_ground
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