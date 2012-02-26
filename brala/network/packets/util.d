module brala.network.packets.util;

private {
    import std.stream : Stream;
    import std.traits : isArray;
}


immutable byte NULL_BYTE = 0;
immutable ubyte NULL_UBYTE = 0;

void write(Args...)(Stream s, Args data) {
    foreach(d; data) {
        write_impl(s, d);
    }
}

private void write_impl(T : const(char)[])(Stream s, T data) {
    s.write(cast(ushort)data.length);
    s.write(data);
}

private void write_impl(T)(Stream s, T data) if(isArray!T &&
                                                !is(T : const(char))) {
    foreach(d; data) {
        s.write(d);
    }
}

private void write_impl(T : bool)(Stream s, T data) {
    s.write(cast(byte)data);
}

private void write_impl(T)(Stream s, T data) if(!isArray!T &&
                                                !is(T : bool)) {
    s.write(data);
}