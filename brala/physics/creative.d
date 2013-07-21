module brala.physics.creative;

private {
    import gl3n.linalg : vec3;

    import std.datetime : Clock;
    import core.time : TickDuration;

    import brala.dine.world : World;
    import brala.entities.player: Player;
    import brala.gfx.camera : Camera;
    import brala.physics.physics : Physics;
    import brala.physics.survival: SurvivalPhysics;
}


class CreativePhysics : SurvivalPhysics {
    bool flying;
    TickDuration last_jump;

    this(Player player, World world) {
        super(player, world);

        // Flying speed in m/s
        this.velocity = 10.8;
        this.flying = true;
    }

    override
    void jump() {
        auto now = Clock.currSystemTick();
        if((now - last_jump).msecs < 350) {
            flying = !flying;
        }
        last_jump = Clock.currSystemTick();

        if(flying) {
            falling.stop();
            falling.reset();
        } else {
            super.jump();
        }
    }

    override
    void move(vec3 delta, float s) {
        if(flying) {
            float moving_speed = velocity * s;

            player.position = (cast(Physics)this).move(
                player.position,
                camera.move(delta * moving_speed)
            );
        } else {
            super.move(delta, s);
        }
    }

    override
    void apply(float s) {
        if(!flying) {
            super.apply(s);
        }
    }
}