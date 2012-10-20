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

private void stdout_hook(File f, bool pre) {}

private struct HookedFD(alias hook) {
    File _fd;
    alias _fd this;

    void opDispatch(string s, Args...)(auto ref Args args) if(s.length >= 5 && s[0..5] == "write") {
        hook(_fd, true);
        mixin(`_fd.` ~ s ~ `(args);`);
        hook(_fd, false);
    }
}

__gshared HookedFD!(stdout_hook) stdout;
__gshared HookedFD!(stderr_hook) stderr;

shared static this() {
    stdout._fd = std.stdio.stdout;
    stderr._fd = std.stdio.stderr;
}

private string inject(string hook_name) {
    string res;

    foreach(m; __traits(allMembers, std.stdio)) {
        static if(m.length >= 5 && m[0..5] == "write") {
            res ~= `void ` ~ m ~ `(Args...)(auto ref Args args) {
                        ` ~ hook_name ~ `(std.stdio.stdout, true);
                        std.stdio.stdout.` ~ m ~ `(args);
                        ` ~ hook_name ~ `(std.stdio.stdout, false);
                    }`;
        }
    }

    return res;
}

mixin(inject("stdout_hook"));