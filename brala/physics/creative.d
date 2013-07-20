module brala.physics.creative;

private {
    import gl3n.linalg : vec3;

    import brala.dine.world : World;
    import brala.entities.player: Player;
    import brala.physics.physics : Physics;
}


class CreativePhysics : Physics {
    this(World world) {
        this._world = world;
    }

    override
    vec3 move(vec3 from, vec3 to) {
        return super.move(from, to);
    }

    override
    void apply(Player player) {}
}


