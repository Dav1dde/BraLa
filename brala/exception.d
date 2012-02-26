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

class FatalException : BraLaException {
    this(string msg) {
        super(msg);
    }
}

class ConnectionException : BraLaException {
    this(string msg) {
        super(msg);
    }
}