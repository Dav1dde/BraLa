module brala.utils.debugger;

private {
    version(Posix) {
        import core.stdc.stdio;
    }
}

private __gshared bool _is_debugged = false;

@property bool is_debugged() {
    return _is_debugged;
}

version(Posix) {
    shared static this() {
        // detects gdb:
        // gdb opens file descriptors 3, 4 and 5 and doesn't close them
        // so if we have a fd > 5 on startup we are debugged
        FILE *fd = fopen("/tmp", "r");

        if (fileno(fd) > 5) {
            _is_debugged = true;
        }
        
        fclose(fd);
    }
} else version(Windows) {
    extern(System) bool IsDebuggerPresent();

    shared static this() {
        _is_debugged = IsDebuggerPresent();
    }
}
