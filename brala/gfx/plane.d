module brala.gfx.plane;

private {
    import gl3n.linalg;
}


struct PlaneT(T) {
    alias Vector!(T, 3) vec3;

    union {
        struct {
            T a;
            T b;
            T c;
        }

        vec3 normal;
    }

    T d;

    @safe pure nothrow:

    this(T a, T b, T c, T d) {
        this.a = a;
        this.b = b;
        this.c = c;
        this.d = d;
    }

    this(vec3 normal, T d) {
        this.normal = normal;
        this.d = d;
    }

    void normalize() {
        T det = 1.0 / normal.length;
        normal *= det;
    }

    @property PlaneT normalized() const {
        PlaneT ret = PlaneT(a, b, c, d);
        ret.normalize();
        return ret;
    }

    T distance(vec3 point) const {
        return dot(point, normal) + d;
    }
    
}

alias PlaneT!(float) Plane;

unittest {
    Plane p = Plane(0.0f, 1.0f, 2.0f, 3.0f);
    assert(p.normal == vec3(0.0f, 1.0f, 2.0f));
    assert(p.d == 3.0f);

    p.normal.x = 4.0f;
    assert(p.normal == vec3(4.0f, 1.0f, 2.0f));
    assert(p.a == 4.0f);
    assert(p.b == 1.0f);
    assert(p.c == 2.0f);
    assert(p.d == 3.0f);
}