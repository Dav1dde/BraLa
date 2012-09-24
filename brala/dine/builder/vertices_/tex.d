module brala.dine.builder.vertices_.tex;

private {
    import gl3n.math : abs, sign;
    
    import brala.dine.builder.vertices : CubeSideData;
}

struct TextureSlice {
    enum short FB = 16;
    enum short HB = 8;

    short x;
    short y;

    alias texcoords this;

    this(short lower_left_x, short lower_left_y)
        in { assert(abs(lower_left_x*FB) <= short.max && abs(lower_left_y*FB) <= short.max); }
        body {
            x = cast(short)(lower_left_x*FB+HB);
            y = cast(short)(lower_left_y*FB-HB);
        }

    pure:
    @property short[2][4] texcoords() {
        return [[cast(short)(x-HB), cast(short)(y+HB)],
                [cast(short)(x+HB), cast(short)(y+HB)],
                [cast(short)(x+HB), cast(short)(y-HB)],
                [cast(short)(x-HB), cast(short)(y-HB)]];
    }

    @property short[2][4] texcoords_90() {
        return [[cast(short)(x+HB), cast(short)(y+HB)],
                [cast(short)(x+HB), cast(short)(y-HB)],
                [cast(short)(x-HB), cast(short)(y-HB)],
                [cast(short)(x-HB), cast(short)(y+HB)]];
    }

    @property short[2][4] texcoords_180() {
        return [[cast(short)(x+HB), cast(short)(y-HB)],
                [cast(short)(x-HB), cast(short)(y-HB)],
                [cast(short)(x-HB), cast(short)(y+HB)],
                [cast(short)(x+HB), cast(short)(y+HB)]];
    }

    @property short[2][4] texcoords_270() {
        return [[cast(short)(x-HB), cast(short)(y-HB)],
                [cast(short)(x-HB), cast(short)(y+HB)],
                [cast(short)(x+HB), cast(short)(y+HB)],
                [cast(short)(x+HB), cast(short)(y-HB)]];
    }
}


struct SlabTextureSlice {
    enum short FB = 16;
    enum short HB = 8;

    short x;
    short y;

    alias texcoords this;

    this(short lower_left_x, short lower_left_y)
        in { assert(abs(lower_left_x*FB) <= short.max && abs(lower_left_y*FB) <= short.max); }
        body {
            x = cast(byte)(lower_left_x*FB+HB);
            y = cast(byte)(lower_left_y*FB-HB);
        }

    pure:
    @property short[2][4] texcoords() {
        return [[cast(short)(x-HB), cast(short)(y+HB)],
                [cast(short)(x+HB), cast(short)(y+HB)],
                [cast(short)(x+HB), cast(short)(y)],
                [cast(short)(x-HB), cast(short)(y)]];
    }
}


struct ProjTextureSlice {
    enum short FB = 16;
    enum short HB = 8;

    short x;
    short y;

    short x2; // normal y+
    short y2;

    short x3; // normal y-
    short y3;

    private int rotation;

    this(short lower_left_x, short lower_left_y)
        in { assert(abs(lower_left_x*FB) <= short.max && abs(lower_left_y*FB) <= short.max); }
        body {
            x = cast(short)(lower_left_x*FB+HB);
            y = cast(short)(lower_left_y*FB-HB);

            x2 = x;
            y2 = y;

            x3 = x;
            y3 = y;
        }

    this(short lower_left_x, short lower_left_y, short lower_left_x2, short lower_left_y2)
        in { assert(abs(lower_left_x*FB) <= short.max && abs(lower_left_y*FB) <= short.max);
             assert(abs(lower_left_x2*FB) <= short.max && abs(lower_left_y2*FB) <= short.max); }
        body {
            x = cast(short)(lower_left_x*FB+HB);
            y = cast(short)(lower_left_y*FB-HB);

            x2 = cast(short)(lower_left_x2*FB+HB);
            y2 = cast(short)(lower_left_y2*FB-HB);

            x3 = x;
            y3 = y;
        }

    this(short lower_left_x, short lower_left_y, short lower_left_x2, short lower_left_y2,
         short lower_left_x3, short lower_left_y3)
        in { assert(abs(lower_left_x3*FB) <= short.max && abs(lower_left_y3*FB) <= short.max); }
        body {
            this(lower_left_x, lower_left_y, lower_left_x2, lower_left_y2);

            x3 = cast(short)(lower_left_x3*FB+HB);
            y3 = cast(short)(lower_left_y3*FB-HB);
        }

    pure:
    short[2][4] project_on_cbsd(CubeSideData cbsd) {
        // an normale erkennbar welche koordinate fix ist
        // die koodinaten zu UVs umformen? cast(short)(foo*2)?

        short x = this.x;
        short y = this.y;

        size_t index_1;
        size_t index_2;

        // n is the counterpart to s, it allows to midify the x coordinates
        float n = 1.0f;
        // used to flip the signs if normal doesn't point toward +y
        // since in OpenGL +y goes up but in the texture atlas +y goes down
        float s = 1.0f;

        if(cbsd.normal[1] == 0.0f && cbsd.normal[2] == 0.0f) {
            // x
            index_1 = 2;
            index_2 = 1;
            s = -1.0f; // flip here

            //n = sign(cbsd.normal[0]);
            n = sign(-cbsd.normal[0]);
        } else if(cbsd.normal[0] == 0.0f && cbsd.normal[2] == 0.0f) {
            // y
            index_1 = 0;
            index_2 = 2;
            n = sign(cbsd.normal[1]);

            if(n > 0) { // y+
                x = x2;
                y = y2;
            } else if(n < 0) { // y-
                x = x3;
                y = y3;
            }
        } else if(cbsd.normal[0] == 0.0f && cbsd.normal[1] == 0.0f) {
            // z
            index_1 = 0;
            index_2 = 1;
            s = -1.0f; // flip here
            n = sign(cbsd.normal[2]);
        } else {
            assert(false, "normal not supported");
        }

        short[2][4] ret;

        foreach(i, ref vertex; cbsd.positions) {
            ret[i][0] = cast(short)(x + vertex[index_1]*FB*n);
            ret[i][1] = cast(short)(y + vertex[index_2]*FB*s);
        }

        return ret;
    }
}
