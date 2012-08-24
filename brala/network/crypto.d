module brala.network.crypto;

private {
    import std.conv : to;
    import core.stdc.time : tm, time;

    import brala.utils.openssl.hash : MD5;
    import brala.utils.openssl.encrypt : DESCBC;
    import brala.utils.openssl.exception : OpenSSLException;
    
    import deimos.openssl.rand;
    import deimos.openssl.rsa;
    import deimos.openssl.x509;
}

RSA* decode_public(const(ubyte)[] public_key)
    out(rsa) { assert(rsa !is null); }
    body {
        auto mem_ptr = public_key.ptr;

        return d2i_RSA_PUBKEY(null, &mem_ptr, public_key.length);
    }


ubyte[] encrypt(RSA* rsa, ubyte[] data) {
    size_t s = RSA_size(rsa);
    ubyte[] buf = new ubyte[s];
    RSA_public_encrypt(cast(uint)data.length, data.ptr, buf.ptr, rsa, RSA_PKCS1_PADDING);
    return buf;
}


void seed_prng() {
    auto t = time(null);
    RAND_seed(cast(void*)&t, t.sizeof);
}

void seed_prng(ubyte[] seed) {
    RAND_seed(seed.ptr, cast(uint)seed.length);
}

ubyte[] get_random(size_t size) {
    ubyte[] rand = new ubyte[size];
    if(!RAND_bytes(rand.ptr, cast(uint)size)) {
        throw new OpenSSLException();
    }
    
    return rand;
}

class PBEWithMD5AndDES {
    protected ubyte[] key;
    protected ubyte[] IV;
    
    this(ubyte[] inp_key) {
        ubyte[] md5_key = generate_md5_key(inp_key, 5);

        this.key = md5_key[0..8];
        this.IV = md5_key[8..16];
    }

    ubyte[] encrypt(ubyte[] plaintext) {
        size_t padding = 8 - (plaintext.length % 8);
        plaintext.length += padding;
        plaintext[$-padding..$] = cast(ubyte)padding;

        auto des = new DESCBC(key, IV);
        ubyte[] encrypted = des.encrypt(plaintext);
        encrypted ~= des.encrypt_finalize();

        return encrypted;
    }

    ubyte[] decrypt(ubyte[] cipher) {
        auto des = new DESCBC(key, IV);
        ubyte[] decrypted = des.decrypt(cipher);
        decrypted ~= des.decrypt_finalize();
        return decrypted[0..$-(decrypted[$-1])];
    }

    ubyte[] generate_md5_key(ubyte[] key, size_t rounds) {
        ubyte[] ret = (new MD5(key)).digest;

        foreach(_; 0..(rounds-1)) {
            ret = (new MD5(ret)).digest;
        }

        return ret.dup;
    }
}