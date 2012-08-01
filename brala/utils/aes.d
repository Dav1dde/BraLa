module brala.utils.aes;

private {
    import brala.utils.crypto : get_openssl_error;
    
    import deimos.openssl.evp;
}

class AES(alias gen) {
    const(ubyte)[] key;
    const(ubyte)[] iv;

    ENGINE* engine = null;
    EVP_CIPHER_CTX ctx_encrypt;
    EVP_CIPHER_CTX ctx_decrypt;
    
    this(const(ubyte)[] key, const(ubyte)[] iv) {
        this.key = key;
        this.iv = iv;

        EVP_CIPHER_CTX_init(&ctx_encrypt);
        EVP_EncryptInit_ex(&ctx_encrypt, gen(), engine, key.ptr, iv.ptr);

        EVP_CIPHER_CTX_init(&ctx_decrypt);
        EVP_DecryptInit_ex(&ctx_decrypt, gen(), engine, key.ptr, iv.ptr);
    }

    // TODO add en/decrypt final
    // TODO uninit EVP

    ubyte[] encrypt(const(void)* data, size_t size) {
        ubyte[] out_ = new ubyte[size + 15 + 16];
        int outlen;
        if(!EVP_EncryptUpdate(&ctx_encrypt, out_.ptr, &outlen, cast(const(ubyte)*)data, cast(int)size)) {
            throw new Exception(get_openssl_error());
        }
        
        out_.length = outlen;
        return out_;
    }

    ubyte[] decrypt(const(void)* data, size_t size) {
        ubyte[] out_ = new ubyte[size + 16 + 16];
        int outlen;
        if(!EVP_DecryptUpdate(&ctx_decrypt, out_.ptr, &outlen, cast(const(ubyte)*)data, cast(int)size)) {
            throw new Exception(get_openssl_error());
        }

        out_.length = outlen;
        return out_;
    }
}

alias AES!(EVP_aes_128_cfb8) AES128CFB8;