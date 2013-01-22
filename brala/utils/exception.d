module brala.utils.exception;


class ImageException : Exception {
    this(string s, string f=__FILE__, size_t l=__LINE__) {
        super(s, f, l);
    }
}

class NbtException : Exception {
    this(string s, string f=__FILE__, size_t l=__LINE__) {
        super(s, f, l);
    }
}

class QueueException : Exception {
    this(string s, string f=__FILE__, size_t l=__LINE__) {
        super(s, f, l);
    }
}

class Empty : QueueException {
    this(string s, string f=__FILE__, size_t l=__LINE__) {
        super(s, f, l);
    }
}

class Full : QueueException {
    this(string s, string f=__FILE__, size_t l=__LINE__) {
        super(s, f, l);
    }
}

class ConfigException : Exception {
    this(string s, string f=__FILE__, size_t l=__LINE__) {
        super(s, f, l);
    }
}

class InvalidConfig : ConfigException {
    this(string s, string f=__FILE__, size_t l=__LINE__) {
        super(s, f, l);
    }
}

class NoKey : ConfigException {
    this(string s, string f=__FILE__, size_t l=__LINE__) {
        super(s, f, l);
    }
}

class InvalidKey : ConfigException {
    this(string s, string f=__FILE__, size_t l=__LINE__) {
        super(s, f, l);
    }
}