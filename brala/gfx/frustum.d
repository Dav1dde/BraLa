module brala.gfx.frustum;

private {
    import gl3n.linalg;
    import gl3n.math : abs, cradians;

    import brala.gfx.aabb : AABB;
}

enum {
    OUTSIDE = 0,
    INSIDE,
    INTERSECT
}

struct Frustum {
    vec4 left;
    vec4 right;
    vec4 bottom;
    vec4 top;
    vec4 near;
    vec4 far;

    @safe pure nothrow:

    this(mat4 mvp) {       
        left = vec4(mvp[0][3] + mvp[0][0],
                    mvp[1][3] + mvp[1][0],
                    mvp[2][3] + mvp[2][0],
                    mvp[3][3] + mvp[3][0]).normalized;
                    
        right = vec4(mvp[0][3] - mvp[0][0],
                     mvp[1][3] - mvp[1][0],
                     mvp[2][3] - mvp[2][0],
                     mvp[3][3] - mvp[3][0]).normalized;

        bottom = vec4(mvp[0][3] + mvp[0][1],
                      mvp[1][3] + mvp[1][1],
                      mvp[2][3] + mvp[2][1],
                      mvp[3][3] + mvp[3][1]).normalized;
                      
        top = vec4(mvp[0][3] - mvp[0][1],
                   mvp[1][3] - mvp[1][1],
                   mvp[2][3] - mvp[2][1],
                   mvp[3][3] - mvp[3][1]).normalized;

        near = vec4(mvp[0][3] + mvp[0][2],
                    mvp[1][3] + mvp[1][2],
                    mvp[2][3] + mvp[2][2],
                    mvp[3][3] + mvp[3][2]).normalized;

        far = vec4(mvp[0][3] - mvp[0][2],
                   mvp[1][3] - mvp[1][2],
                   mvp[2][3] - mvp[2][2],
                   mvp[3][3] - mvp[3][2]).normalized;
    }

    auto intersects(AABB aabb) {
        vec3 hextent = aabb.half_extent;
        vec3 center = aabb.center;

        int result = INSIDE;
        foreach(plane; [left, right, bottom, top, near, far]) {
            float d = dot(center, vec3(plane));
            float r = dot(hextent, abs(vec3(plane)));

            if(d + r < -plane.w) {
                // outside
                return OUTSIDE;
            }
            if(d - r < -plane.w) {
               result = INTERSECT;
            }
        }

        return result;
    }

    bool opBinaryRight(string s : "in")(AABB aabb) {
        return intersects(aabb) > 0;
    }
}