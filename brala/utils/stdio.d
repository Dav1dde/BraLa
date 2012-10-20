module brala.utils.stdio;

private {
    import brala.utils.console : Attribute, set_attribute;
}

public import std.stdio;


private void stderr_hook(File f, bool pre) {
    if(pre) {
        f.set_attribute(Attribute.RED | Attribute.BOLD);
    } else {
        f.set_attribute(Attribute.RESET);
    }
}

private struct HookedFD(alias hook) {
    File _fd;
    alias _fd this;

    void opDispatch(string s, Args...)(auto ref Args args) if(s.length >= 5 && s[0..5] == "write") {
        hook(_fd, true);
        mixin(`_fd.` ~ s ~ `(args);`);
        hook(_fd, false);
    }
}

__gshared HookedFD!(stderr_hook) stderr;

shared static this() {
    stderr._fd = std.stdio.stderr;
}