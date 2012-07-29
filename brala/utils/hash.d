module brala.utils.hash;

private {
    import std.traits : isPointer, isArray;
    import std.exception : enforce;
    import std.algorithm : map;
    import std.string : format;
    import std.array : join, array;
    import std.conv : to;
    
    import deimos.openssl.sha;
}


class SHA1 {
    SHA_CTX openssl_sha1;
    private bool _is_final = false;
    @property bool is_final() { return _is_final; }
    private ubyte[20] _digest;
    
    this()() {
        SHA1_Init(&openssl_sha1);
    }

    this(T)(T data) {
        SHA1_Init(&openssl_sha1);
        update(data);
    }

    void update(T)(T data) if(isArray!T) {
        enforce(!_is_final, "SHA1 already finialized.");
        SHA1_Update(&openssl_sha1, data.ptr, data.length);
    }

    void update(T)(T ptr, size_t size) if(isPointer!T) {
        enforce(!_is_final, "SHA1 already finialized.");
        SHA1_Update(&openssl_sha1, ptr, size);
    }

    @property string hexdigest() {
        ubyte[] d = digest[];
        return d.map!(x => "%02x".format(x)).join().to!string();
    }

    @property ubyte[20] digest() {
        if(!is_final) {
            finalize();
        }
        return _digest;
    }

    void finalize() {
        SHA1_Final(_digest.ptr, &openssl_sha1);
        _is_final = true;
    }
}

unittest {
    auto s1 = new SHA1();
    s1.update("testing123");
    s1.update("yay");
    assert(s1.hexdigest == "26c7ac4bc551133bf01887cb0f25127f85a38358");
    assert(s1.hexdigest == (new SHA1("testing123yay")).hexdigest);

    assert((new SHA1("trolol12o")).hexdigest == "3ad89007366442c747017d84985e4b7a86c6f440");
}
