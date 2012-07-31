module brala.utils.aes;

private {
    import brala.utils.crypto : get_openssl_error;
    
    import deimos.openssl.evp;
}

class AES(alias gen) {
    const(ubyte)[] key;
    const(ubyte)[] iv;

    ENGINE* engine = null;
    
    this(const(ubyte)[] key, const(ubyte)[] iv) {
        this.key = key;
        this.iv = iv;
    }

    ubyte[] encrypt(const(void)* data, size_t size) {
        EVP_CIPHER_CTX ctx;
        EVP_CIPHER_CTX_init(&ctx);
        EVP_EncryptInit_ex(&ctx, gen(), engine, key.ptr, iv.ptr);

        ubyte[] out_ = new ubyte[size + 15 + 16];
        int outlen;
        if(!EVP_EncryptUpdate(&ctx, out_.ptr, &outlen, cast(const(ubyte)*)data, cast(int)size)) {
            throw new Exception(get_openssl_error());
        }

        int templen;
        if(!EVP_EncryptFinal_ex(&ctx, out_.ptr + outlen, &templen)) {
            throw new Exception(get_openssl_error());
        }

        EVP_CIPHER_CTX_cleanup(&ctx);
        
        out_.length = outlen + templen;
        return out_;
    }

    ubyte[] decrypt(const(void)* data, size_t size) {
        EVP_CIPHER_CTX ctx;
        EVP_CIPHER_CTX_init(&ctx);
        EVP_DecryptInit_ex(&ctx, gen(), engine, key.ptr, iv.ptr);

        ubyte[] out_ = new ubyte[size + 16 + 16];
        int outlen;
        if(!EVP_DecryptUpdate(&ctx, out_.ptr, &outlen, cast(const(ubyte)*)data, cast(int)size)) {
            throw new Exception(get_openssl_error());
        }

        int templen;
        if(!EVP_DecryptFinal_ex(&ctx, out_.ptr + outlen, &templen)) {
            throw new Exception(get_openssl_error());
        }

        EVP_CIPHER_CTX_cleanup(&ctx);

        out_.length = outlen + templen;
        return out_;
    }
}

alias AES!(EVP_aes_128_cfb8) AES128CFB8;