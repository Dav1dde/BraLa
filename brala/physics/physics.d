module brala.physics.physics;

private {
    import gl3n.linalg : vec3, vec3i;
    import gl3n.math;

    import std.conv : to;
    import std.algorithm : canFind;

    import brala.dine.chunk : Block;
    import brala.dine.world : World;
    import brala.gfx.camera : Camera;
}

public {
    import brala.physics.survival : SurvivalPhysics;
    import brala.physics.creative : CreativePhysics;
}


enum AIR_BLOCK = Block(0);

abstract class Physics {
    protected World _world;
    @property void world(World world) { this._world = world; }
    @property World world() { return _world; }

    enum PLAYER_WIDTH = 0.6f;
    enum PLAYER_WIDTH_HALF = 0.3f;
    enum PLAYER_HEIGHT = 1.8f;

    bool is_valid_position(vec3 position) {
        vec3[4] corners = [
            vec3(position.x+PLAYER_WIDTH_HALF, position.y, position.z+PLAYER_WIDTH_HALF),
            vec3(position.x+PLAYER_WIDTH_HALF, position.y, position.z-PLAYER_WIDTH_HALF),
            vec3(position.x-PLAYER_WIDTH_HALF, position.y, position.z+PLAYER_WIDTH_HALF),
            vec3(position.x-PLAYER_WIDTH_HALF, position.y, position.z-PLAYER_WIDTH_HALF)
        ];
        vec3i[4] blocks;

        foreach(i, fcorner; corners) {
            vec3i corner = vec3i(
                fcorner.x.floor.to!int,
                fcorner.y.floor.to!int,
                fcorner.z.floor.to!int
            );

            if(!blocks[].canFind(corner)) {
                blocks[i] = corner;

                auto foot = world.get_block_safe(corner);
                auto head = world.get_block_safe(corner + vec3i(0, 1, 0));
                auto head2 = AIR_BLOCK;
                if((position.y+PLAYER_HEIGHT).floor > (corner.y+1)) {
                    head2 = world.get_block_safe(corner + vec3i(0, 2, 0));
                }

                // TODO liquids
                if(foot.id != 0 || head.id != 0 || head2.id != 0) return false;
            }
        }

        return true;
    }

    abstract vec3 move(vec3, vec3);
    abstract void apply(Camera);
}