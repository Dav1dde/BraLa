module brala.exception;

private {
}


class BraLaException : Exception {
    this(string s, string f=__FILE__, size_t l=__LINE__) {
        super(s, f, l);
    }
}

class ResmgrError : BraLaException {
    this(string s, string f=__FILE__, size_t l=__LINE__) {
        super(s, f, l);
    }
}

class InitError : BraLaException {
    this(string s, string f=__FILE__, size_t l=__LINE__) {
        super(s, f, l);
    }
}

class ConnectionError : BraLaException {
    this(string s, string f=__FILE__, size_t l=__LINE__) {
        super(s, f, l);
    }
}

class ServerError : ConnectionError {
    this(string s, string f=__FILE__, size_t l=__LINE__) {
        super(s, f, l);
    }
}

class SessionError : BraLaException {
    this(string s, string f=__FILE__, size_t l=__LINE__) {
        super(s, f, l);
    }
}

class MinecraftException : BraLaException {
    this(string s, string f=__FILE__, size_t l=__LINE__) {
        super(s, f, l);
    }
}

class WorldError : BraLaException {
    this(string s, string f=__FILE__, size_t l=__LINE__) {
        super(s, f, l);
    }
}

class FatalException : Exception {
    this(string s, string f=__FILE__, size_t l=__LINE__) {
        super(s, f, l);
    }
}

class AllocationError : FatalException {
    this(string s, string f=__FILE__, size_t l=__LINE__) {
        super(s, f, l);
    }
}

class YggdrasilException : Exception {
    string error;
    string error_message;
    string cause;

    this(string s, string f=__FILE__, size_t l=__LINE__) {
        super(s, f, l);
    }
}