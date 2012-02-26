module brala.network.packets.util;

private {
    import std.stream : Stream;
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

private void write_impl(T)(Stream s, T data) if(!is(T : const(char)[])) {
    s.write(data);
}