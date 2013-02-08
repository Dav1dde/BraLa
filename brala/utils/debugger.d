module brala.utils.debugger;

private {
    version(Posix) {
        import core.stdc.stdio;
    }
}

version(Posix) {
    private __gshared bool _is_debugged = false;

    @property bool is_debugged() {
        static bool init = false;

        if(!init) {
            // detects gdb:
            // gdb opens file descriptors 3, 4 and 5 and doesn't close them
            // so if we have a fd > 5 on startup we are debugged

            FILE *fd = fopen("/tmp", "r");
            if (fileno(fd) > 5) {
                _is_debugged = true;
            }
            fclose(fd);
            
            init = true;
        }

        return _is_debugged;
    }

    shared static this() {
        // call it as soon as possible
        is_debugged();
    }
} else version(Windows) {
    extern(System) bool IsDebuggerPresent();

    @property bool is_debugged() {
        return IsDebuggerPresent();
    }
}
