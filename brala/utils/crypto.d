module brala.utils.crypto;

private {
    import std.conv : to;
    import core.stdc.time : tm, time;
    
    import deimos.openssl.rand;
    import deimos.openssl.rsa;
    import deimos.openssl.x509;
    import deimos.openssl.err;
}


ubyte[] der_encode(RSA* rsa) {
    auto len = i2d_RSAPublicKey(rsa, null);
    ubyte[] buf = new ubyte[len];
    auto mem_ptr = buf.ptr;
    i2d_RSAPublicKey(rsa, &mem_ptr);
    return buf;
}

RSA* decode_public(const(ubyte)[] public_key)
    out(rsa) { assert(rsa !is null, get_openssl_error()); }
    body {
        auto mem_ptr = public_key.ptr;

        return d2i_RSA_PUBKEY(null, &mem_ptr, public_key.length);
    }


ubyte[] encrypt(RSA* rsa, ubyte[] data) {
    size_t s = RSA_size(rsa);
    ubyte[] buf = new ubyte[s];
    RSA_public_encrypt(data.length, data.ptr, buf.ptr, rsa, RSA_PKCS1_PADDING);
    return buf;
}


void seed_prng() {
    auto t = time(null);
    RAND_seed(cast(void*)&t, t.sizeof);
}

void seed_prng(ubyte[] seed) {
    RAND_seed(seed.ptr, seed.length);
}

ubyte[] get_random(size_t size) {
    ubyte[] rand = new ubyte[size];
    if(!RAND_bytes(rand.ptr, size)) {
        throw new Exception(get_openssl_error());
    }
    
    return rand;
}


string get_openssl_error() {
     uint e = ERR_get_error();
     char[] buf = new char[512];
     ERR_error_string(e, buf.ptr);
     return to!string(buf.ptr);
 }