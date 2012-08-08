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
    this(string msg) {
        super(msg);
    }

    this() {
        super(get_openssl_error());
    }
}