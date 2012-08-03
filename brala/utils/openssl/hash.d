module brala.utils.openssl.hash;

private {
    import std.traits : isPointer, isArray;
    import std.format : formattedWrite;
    import std.exception : enforceEx;
    import std.array : appender;
    import std.range : ElementEncodingType;
    
    import deimos.openssl.md4;
    import deimos.openssl.md5;
    import deimos.openssl.mdc2;
    import deimos.openssl.sha;

    import brala.utils.openssl.exception : OpenSSLException;
}


class Hash(Handle, alias HASH_Init, alias HASH_Update, alias HASH_Final, size_t hash_size) {
    Handle openssl_handle;
    private bool _is_final = false;
    @property bool is_final() { return _is_final; }
    private ubyte[hash_size] _digest;
    
    this()() {
        HASH_Init(&openssl_handle);
    }

    this(T)(T data) if(isArray!T) {
        HASH_Init(&openssl_handle);
        update(data);
    }

    this(T)(T ptr, size_t size) if(isPointer!T) {
        HASH_Init(&openssl_handle);
        update(ptr, size);
    }

    void update(T)(T data) if(isArray!T) {
        update(data.ptr, (ElementEncodingType!T).sizeof*data.length);
    }

    void update(T)(T ptr, size_t size) if(isPointer!T) {
        enforceEx!OpenSSLException(!_is_final, "Hash already finialized.");
        HASH_Update(&openssl_handle, ptr, size);
    }

    @property string hexdigest() {
        auto app = appender!string();
        app.reserve(hash_size*2);

        foreach(b; digest) {
            formattedWrite(app, "%02x", b);
        }
        
        return app.data;
    }

    @property ubyte[hash_size] digest() {
        if(!is_final) {
            finalize();
        }
        return _digest;
    }

    void finalize() {
        HASH_Final(_digest.ptr, &openssl_handle);
        _is_final = true;
    }
}

alias Hash!(MD4_CTX, MD4_Init, MD4_Update, MD4_Final, MD4_DIGEST_LENGTH) MD4;
alias Hash!(MD5_CTX, MD5_Init, MD5_Update, MD5_Final, MD5_DIGEST_LENGTH) MD5;

alias Hash!(MDC2_CTX, MDC2_Init, MDC2_Update, MDC2_Final, MDC2_DIGEST_LENGTH) MDC2;

alias Hash!(SHA_CTX, SHA_Init, SHA_Update, SHA_Final, SHA_DIGEST_LENGTH) SHA0;
alias Hash!(SHA_CTX, SHA1_Init, SHA1_Update, SHA1_Final, SHA_DIGEST_LENGTH) SHA1;
alias Hash!(SHA256_CTX, SHA224_Init, SHA224_Update, SHA224_Final, SHA224_DIGEST_LENGTH) SHA224;
alias Hash!(SHA256_CTX, SHA256_Init, SHA256_Update, SHA256_Final, SHA256_DIGEST_LENGTH) SHA256;
alias Hash!(SHA512_CTX, SHA384_Init, SHA384_Update, SHA384_Final, SHA384_DIGEST_LENGTH) SHA384;
alias Hash!(SHA512_CTX, SHA512_Init, SHA512_Update, SHA512_Final, SHA512_DIGEST_LENGTH) SHA512;

unittest {
    auto s1 = new SHA1();
    s1.update("testing123");
    s1.update("yay");
    assert(s1.hexdigest == "26c7ac4bc551133bf01887cb0f25127f85a38358");
    assert(s1.hexdigest == (new SHA1("testing123yay")).hexdigest);

    assert((new SHA1("trolol12o")).hexdigest == "3ad89007366442c747017d84985e4b7a86c6f440");

    assert((new MD5("IamAtest")).hexdigest == "80892e42a8023f8435ec2eee97ef6c5e");
}
