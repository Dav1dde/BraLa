module brala.network.util;

private {
    import std.stream : Endian, Stream, EndianStream;
    import std.typecons : TypeTuple;
    import std.typecons : Tuple;
    import std.traits : isArray, isStaticArray, isDynamicArray;
    import std.algorithm : map;
    import std.array : join;
    import std.range : ElementEncodingType;
    import std.utf : toUTF16, toUTF8;
    import std.uri : encodeComponent;
    
    debug import std.stdio : writefln;
}

void write(Args...)(Stream s, Args data) {
    foreach(d; data) {
        write_impl(s, d);
    }
}

private void write_impl(T : bool)(Stream s, T data) {
    s.write(cast(byte)data);
}

private void write_impl(T : string)(Stream s, T data) {
    s.write(cast(ushort)data.length);
    s.writeStringW(toUTF16(data));
}

private void write_impl(T)(Stream s, T data) if(!(is(T : bool) || is(T : bool) || is(T : EntityMetadataS) ||
                                                  is(T : Slot) || is(T : ChunkS))) {
    static if(isArray!T) {
        static if(isDynamicArray!T) {
            write(s, cast(short)data.length);
        }
        
        foreach(d; data) {
            write(s, d);
        }
    } else static if(__traits(compiles, s.write(data))) {
        s.write(data);
    } else {
        s.writeBlock(&data, T.sizeof); // TODO: implement .send for MapChunkS, EntityMetadataS, Slot
    }
}



T[0] read(T...)(Stream s) if(T.length == 1) {
    return read_impl!(T[0])(s);
}

Tuple!(Types) read(Types...)(Stream s) if(Types.length > 1) {
    Tuple!(Types) ret;
    
    foreach(i, T; Types) {
        ret[i] = read_impl!T(s);
    }
    
    return ret;
}

private bool read_impl(T)(Stream s) if(is(T : bool)) {
    byte ret;
    s.read(ret);
    return ret > 0;
}

private string read_impl(T)(Stream s) if(is(T : string)) {
    ushort length;
    s.read(length);
    
    wchar[] ret_utf16 = s.readStringW(length);
      
    return toUTF8(ret_utf16);
}

private auto read_impl(T)(Stream s) if(__traits(compiles, mixin("T.recv(s)"))) {
    return T.recv(s);
}

private T read_impl(T)(Stream s) if(!(is(T : string) || is(T : bool) || __traits(compiles, mixin("T.recv(s)")))) {
    T ret;
    
    static if(isArray!T) {
        static if(isStaticArray!T) {
            foreach(i; 0..T.length) {
                ret[i] = read!(ElementEncodingType!T)(s);
                static if(__traits(hasMember, ret[i], "array_position")) ret[i].array_position = i;
            }
        } else {
            static if(__traits(hasMember, T, "LenType")) {
                T.LenType len = read!(T.LenType)(s);
            } else {
                short len = read!short(s);
            }
            
            foreach(i; 0..len) {
                ret ~= read!(ElementEncodingType!T)(s);
                static if(!__traits(hasMember, T, "LenType") &&__traits(hasMember, ret[i], "array_position")) ret[i].array_position = i;
            }
        }
    } else {
        s.read(ret);
    }
    
    return ret;
}


string urlencode(string[string] c) {
    string s[];
    
    foreach(k, v; c) {
        s ~= k ~ "=" ~ encodeComponent(v);
    }
    
    return s.join("&");
}