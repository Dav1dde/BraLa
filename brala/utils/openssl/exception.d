module brala.utils.openssl.exception;

private {
    import std.conv : to;
    
    import deimos.openssl.err;
}

string get_openssl_error() {
    size_t e = ERR_get_error();
    char[] buf = new char[512];
    ERR_error_string(e, buf.ptr);
    return to!string(buf.ptr); // to!string stops at \0
}


class OpenSSLException : Exception {
    this(string msg, string f=__FILE__, size_t l=__LINE__) {
        super(msg, f, l);
    }

    this(string f=__FILE__, size_t l=__LINE__) {
        super(get_openssl_error(), f, l);
    }
}