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
    enum PLAYER_HEIGHT_HALF = 0.9f;


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
                if((position.y+PLAYER_HEIGHT).floor > (position.y.floor+1)) {
                    head2 = world.get_block_safe(corner + vec3i(0, 2, 0));
                }

                // TODO liquids
                if(foot.id != 0 || head.id != 0 || head2.id != 0) return false;
            }
        }

        return true;
    }

    abstract vec3 move(vec3 from, vec3 to) {
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

            auto fdxc = (from + dxc).vfloor.vto!int;
            auto fdyc = (from + dyc).vfloor.vto!int;
            auto fdzc = (from + dzc).vfloor.vto!int;
            auto fb = (from + dxc + dyc + dzc).vfloor.vto!int;

            Block bdxc = AIR_BLOCK;
            Block bdyc = AIR_BLOCK;
            Block bdzc = AIR_BLOCK;
            // TODO integrate "b", to prevent glitching into corners
            // by extending its boundingbox in every direction
            Block b = AIR_BLOCK;

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

    abstract void apply(Player);
}

// TODO implement these properly in gl3n.math
vec3i vto(T)(vec3 v) if(is(T == vec3i)) {
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