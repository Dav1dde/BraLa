module brala.physics.creative;

private {
    import gl3n.linalg : vec3;

    import brala.dine.world : World;
    import brala.entities.player: Player;
    import brala.gfx.camera : Camera;
    import brala.physics.survival: SurvivalPhysics;
}


class CreativePhysics : SurvivalPhysics {
    bool flying;

    this(Player player, Camera camera, World world) {
        super(player, camera, world);

        // Flying speed in m/s
        this.velocity = 10.8;
        this.flying = true;
    }

    override
    void move(vec3 delta, float s) {
        return super.move(delta, s);
    }

    override
    void apply(float s) {
        return super.apply(s);
    }

    override @property
    bool on_ground() {
        if(flying) {
            return false;
        }

        return super.on_ground;
    }
}


