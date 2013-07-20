module brala.physics.survival;

private {
    import gl3n.linalg : vec3;

    import brala.entities.player : Player;
    import brala.physics.physics : Physics;
}


class SurvivalPhysics : Physics {
    override vec3 move(vec3 from, vec3 to) { return to; }
    override void apply(Player player) {}
}