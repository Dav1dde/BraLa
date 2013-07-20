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

    this(Player player, Camera camera, World world) {
        this.player = player;
        this.camera = camera;
        this.world = world;

        // Walking speed in m/s
        this.velocity = 4.3f;
    }

    override @property
    bool on_ground() {
        return !falling.running;
    }

    override
    void move(vec3 delta, float s) {
        float moving_speed = velocity * s;

        player.position = Physics.move(
            world,
            player.position,
            camera.move(delta * moving_speed)
        );

        bool og = super.on_ground; // cache it
        if(falling.running && og) {
            falling.stop();
            falling.reset();
        } else if(!falling.running && !og) {
            falling.start();
        }
    }

    override
    void apply(float s) {
        if(!on_ground) {
            float ticks = falling.peek().msecs;

            // not really what minecraft uses
            acceleration.y = -pow(ticks, 1.048) * 2 * s;
        } else {
            acceleration.y = 0;
        }


        player.position = Physics.move(
            world,
            player.position,
            player.position + acceleration*s
        );
    }
}