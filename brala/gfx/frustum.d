module brala.gfx.frustum;

private {
    import gl3n.linalg;

}

struct Frustum {
    vec4 left;
    vec4 right;
    vec4 bottom;
    vec4 top;
    vec4 near;
    vec4 far;

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

        far = vec4(mvp[0][3] + mvp[0][2],
                   mvp[1][3] + mvp[1][2],
                   mvp[2][3] + mvp[2][2],
                   mvp[3][3] + mvp[3][2]).normalized;

        near = vec4(mvp[0][3] - mvp[0][2],
                    mvp[1][3] - mvp[1][2],
                    mvp[2][3] - mvp[2][2],
                    mvp[3][3] - mvp[3][2]).normalized;
    }

    // TODO: contains chunk / contains AABB - maybe contains sphere

}