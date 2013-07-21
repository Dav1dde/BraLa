module brala.physics.survival;

private {
    import gl3n.linalg : vec3;

    import std.conv : to;
    import std.math : pow;
    import std.datetime : StopWatch;

    import brala.dine.world : World;
    import brala.entities.player;
    import brala.physics.physics : Physics;
    import brala.gfx.camera : Camera;
}


class SurvivalPhysics : Physics {
    StopWatch falling;

    this(Player player, World world) {
        this.player = player;
        this.camera = player.camera;
        this.world = world;

        player.window.single_key_down[player.JUMP].connect!"jump"(this);

        // Walking speed in m/s
        this.velocity = 4.3f;
    }

    override
    void jump() {
        if(on_ground) {
            acceleration.y = 9.8;
        }
    }

    override
    void move(vec3 delta, float s) {
        float moving_speed = velocity * s;
        delta.y = 0;

        player.position = super.move(
            player.position,
            camera.move(delta * moving_speed)
        );
    }

    override
    void apply(float s) {
        vec3 m = vec3(0.0f, 0.0f, 0.0f);

        // TODO proper gravity
        enum g = -32;
        if(!on_ground || acceleration.y > 0) {
            m.y = acceleration.y * s + 0.5 * g * s*s;
            acceleration.y += g*s;
        } else if(acceleration.y < 0) {
            acceleration.y = 0;
        } else {
            m = acceleration;
        }

        player.position = super.move(
            player.position,
            player.position + m
        );
    }
}