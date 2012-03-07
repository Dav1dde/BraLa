module brala.exception;

private {
}


class BraLaException : Exception {
    this(string msg) {
        super(msg);
    }
}

class ResmgrError : BraLaException {
    this(string msg) {
        super(msg);
    }
}

class ImageError : BraLaException {
    this(string msg) {
        super(msg);
    }
}

class InitError : BraLaException {
    this(string msg) {
        super(msg);
    }
}

class ConnectionError : BraLaException {
    this(string msg) {
        super(msg);
    }
}

class ServerError : ConnectionError {
    this(string msg) {
        super(msg);
    }
}

class SessionError : BraLaException {
    this(string msg) {
        super(msg);
    }
}

class FatalException : Exception {
    this(string msg) {
        super(msg);
    }
}

class AllocationError : FatalException {
    this(string msg) {
        super(msg);
    }
}