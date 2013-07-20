module brala.physics.physics;

private {
    import gl3n.linalg : vec3, vec3i;
    import gl3n.math;

    import std.conv : to;
    import std.algorithm : canFind;

    import brala.dine.chunk : Block;
    import brala.dine.world : World;
    // selective import doesn't work, bug!?
    import brala.entities.player;
    import brala.gfx.camera : Camera;
}

public {
    import brala.physics.survival : SurvivalPhysics;
    import brala.physics.creative : CreativePhysics;
}


enum AIR_BLOCK = Block(0);

abstract class Physics {
    protected Player player;
    protected World world;
    protected Camera camera;

    enum PLAYER_WIDTH = 0.6f;
    enum PLAYER_WIDTH_HALF = 0.3f;
    enum PLAYER_HEIGHT = 1.8f;
    enum PLAYER_HEIGHT_HALF = 0.9f;

    vec3 acceleration = vec3(0.0f, 0.0f, 0.0f);
    float velocity = 0.0f;

    static
    bool on_ground(World world, Player player) {
        vec3i position = player.position.vfloor.vto!vec3i;

        // TODO liquids, plants etc.
        if(world.get_block_safe(position) != 0) {
            return true;
        }

        if(almost_equal(player.position.y, position.y, 0.001)) {
            return world.get_block_safe(position - vec3i(0, 1, 0)).id != 0;
        }

        return false;
    }

    static
    vec3 move(World world, vec3 from, vec3 to) {
        if(to == from) {
            return to;
        }

        vec3 delta = to-from;
        vec3 dx = vec3(delta.x, 0, 0);
        vec3 dy = vec3(0, delta.y, 0);
        vec3 dz = vec3(0, 0, delta.z);

        vec3[12] corners = [
            vec3( PLAYER_WIDTH_HALF, 0,  PLAYER_WIDTH_HALF),
            vec3( PLAYER_WIDTH_HALF, 0, -PLAYER_WIDTH_HALF),
            vec3(-PLAYER_WIDTH_HALF, 0,  PLAYER_WIDTH_HALF),
            vec3(-PLAYER_WIDTH_HALF, 0, -PLAYER_WIDTH_HALF),

            // this is needed, because the playerheight is 1.8 blocks, *but*
            // this is actually 3 blocks and not 2, but we need to cover all 3.
            vec3( PLAYER_WIDTH_HALF, PLAYER_HEIGHT_HALF,  PLAYER_WIDTH_HALF),
            vec3( PLAYER_WIDTH_HALF, PLAYER_HEIGHT_HALF, -PLAYER_WIDTH_HALF),
            vec3(-PLAYER_WIDTH_HALF, PLAYER_HEIGHT_HALF,  PLAYER_WIDTH_HALF),
            vec3(-PLAYER_WIDTH_HALF, PLAYER_HEIGHT_HALF, -PLAYER_WIDTH_HALF),

            vec3( PLAYER_WIDTH_HALF, PLAYER_HEIGHT,  PLAYER_WIDTH_HALF),
            vec3( PLAYER_WIDTH_HALF, PLAYER_HEIGHT, -PLAYER_WIDTH_HALF),
            vec3(-PLAYER_WIDTH_HALF, PLAYER_HEIGHT,  PLAYER_WIDTH_HALF),
            vec3(-PLAYER_WIDTH_HALF, PLAYER_HEIGHT, -PLAYER_WIDTH_HALF)
        ];

        foreach(i, dc; corners) {
            vec3 dxc = dx + dc;
            vec3 dyc = dy + dc;
            vec3 dzc = dz + dc;

            auto fdxc = (from + dxc).vfloor.vto!vec3i;
            auto fdyc = (from + dyc).vfloor.vto!vec3i;
            auto fdzc = (from + dzc).vfloor.vto!vec3i;
            auto fb = (from + dxc + dyc + dzc).vfloor.vto!vec3i;

            Block bdxc = AIR_BLOCK;
            Block bdyc = AIR_BLOCK;
            Block bdzc = AIR_BLOCK;
            // TODO integrate "b", to prevent glitching into corners
            // by extending its boundingbox in every direction
            Block b = AIR_BLOCK;

            // TODO liquids, plants etc.
            if(world.get_block_safe(fdxc) != 0) {
                // 0.00001f*dx.x.sign is needed because the math is too accurate ;).
                // Without it this value the boundingbox edge would be exactly on the edge of
                // this block and the adjacent block, which means on next movement, the
                // edge would be considered inside a block, which screws everything up,
                // since this code tries to prevent invalid movement, rather than "fix" it,
                // we rely on the server to do this.
                dx.x = absmin(dx.x, (fdxc.x + step(0, -dx.x)) - (from.x + dc.x) - 0.00001f*dx.x.sign);
            }

            if(world.get_block_safe(fdyc) != 0) {
                dy.y = absmin(dy.y, (fdyc.y + step(0, -dy.y)) - (from.y + dc.y) - 0.00001f*dy.y.sign);
            }

            if(world.get_block_safe(fdzc) != 0) {
                dz.z = absmin(dz.z, (fdzc.z + step(0, -dz.z)) - (from.z + dc.z) - 0.00001f*dz.z.sign);
            }
        }

        return from + dx + dy + dz;
    }

    abstract void move(vec3,float);
    abstract void apply(float);
}

// TODO implement these properly in gl3n.math
vec3i vto(T : vec3i)(vec3 v) {
    return vec3i(
        v.x.to!int,
        v.y.to!int,
        v.z.to!int
    );
}

vec3 vfloor(vec3 inp) {
    return vec3(
        inp.x.floor,
        inp.y.floor,
        inp.z.floor
    );
}

auto absmin(T)(T lhs, T rhs) {
    return abs(rhs) < abs(lhs) ? rhs : lhs;
}