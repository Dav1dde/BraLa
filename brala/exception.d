module brala.exception;

private {
}


class BraLaException : Exception {
    this(string msg) {
        super(msg);
    }
}

class ResmgrException : BraLaException {
    this(string msg) {
        super(msg);
    }
}

class ImageException : BraLaException {
    this(string msg) {
        super(msg);
    }
}

class InitException : BraLaException {
    this(string msg) {
        super(msg);
    }
}

class ConnectionException : BraLaException {
    this(string msg) {
        super(msg);
    }
}

class ServerException : ConnectionException {
    this(string msg) {
        super(msg);
    }
}

class SessionException : BraLaException {
    this(string msg) {
        super(msg);
    }
}

class FatalException : Exception {
    this(string msg) {
        super(msg);
    }
}

class AllocationException : FatalException {
    this(string msg) {
        super(msg);
    }
}