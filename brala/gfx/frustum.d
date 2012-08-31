module brala.gfx.frustum;

private {
    import gl3n.linalg;
    import gl3n.math : abs, cradians;

    import brala.gfx.aabb : AABB;
    import brala.gfx.plane : Plane;
}

enum {
    OUTSIDE = 0,
    INSIDE,
    INTERSECT
}

struct Frustum {
    enum {
        LEFT,
        RIGHT,
        BOTTOM,
        TOP,
        NEAR,
        FAR
    }

    Plane[6] planes;

    @safe pure nothrow:

    @property ref Plane left() { return planes[LEFT]; }
    @property ref Plane right() { return planes[RIGHT]; }
    @property ref Plane bottom() { return planes[BOTTOM]; }
    @property ref Plane top() { return planes[TOP]; }
    @property ref Plane near() { return planes[NEAR]; }
    @property ref Plane far() { return planes[FAR]; }

    this(mat4 mvp) {
        planes = [
            // left
            Plane(mvp[0][3] + mvp[0][0],
                  mvp[1][3] + mvp[1][0],
                  mvp[2][3] + mvp[2][0],
                  mvp[3][3] + mvp[3][0]),

            // right
            Plane(mvp[0][3] - mvp[0][0],
                  mvp[1][3] - mvp[1][0],
                  mvp[2][3] - mvp[2][0],
                  mvp[3][3] - mvp[3][0]),

            // bottom
            Plane(mvp[0][3] + mvp[0][1],
                  mvp[1][3] + mvp[1][1],
                  mvp[2][3] + mvp[2][1],
                  mvp[3][3] + mvp[3][1]),
            // top
            Plane(mvp[0][3] - mvp[0][1],
                  mvp[1][3] - mvp[1][1],
                  mvp[2][3] - mvp[2][1],
                  mvp[3][3] - mvp[3][1]),
            // near
            Plane(mvp[0][3] + mvp[0][2],
                  mvp[1][3] + mvp[1][2],
                  mvp[2][3] + mvp[2][2],
                  mvp[3][3] + mvp[3][2]),
            // far
            Plane(mvp[0][3] - mvp[0][2],
                  mvp[1][3] - mvp[1][2],
                  mvp[2][3] - mvp[2][2],
                  mvp[3][3] - mvp[3][2])
        ];

        foreach(ref e; planes) {
            e.normalize();
        }
    }

    auto intersects(AABB aabb) {
        vec3 hextent = aabb.half_extent;
        vec3 center = aabb.center;

        int result = INSIDE;
        foreach(plane; planes) {
            float d = dot(center, plane.normal);
            float r = dot(hextent, abs(plane.normal));

            if(d + r < -plane.d) {
                // outside
                return OUTSIDE;
            }
            if(d - r < -plane.d) {
               result = INTERSECT;
            }
        }

        return result;
    }

    bool opBinaryRight(string s : "in")(AABB aabb) {
        return intersects(aabb) > 0;
    }
}