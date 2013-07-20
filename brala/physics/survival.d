module brala.physics.survival;

private {
    import gl3n.linalg : vec3;

    import brala.dine.world : World;
    import brala.entities.player;
    import brala.physics.physics : Physics;
    import brala.gfx.camera : Camera;
}


class SurvivalPhysics : Physics {
    this(Player player, Camera camera, World world) {
        this.player = player;
        this.camera = camera;
        this.world = world;

        // Walking speed in m/s
        this.velocity = 4.3f;
    }

    override
    void move(vec3 delta, float s) {
        float moving_speed = velocity * s;

        player.position = Physics.move(
            world,
            player.position,
            camera.move(delta * moving_speed)
        );
    }

    override
    void apply(float s) {

    }
}