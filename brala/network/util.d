module brala.network.util;

private {
    import brala.network.packets.types : Array, StaticArray;
    
    import std.stream : Endian, Stream, EndianStream;
    import std.typecons : TypeTuple;
    import std.typecons : Tuple;
    import std.traits : isArray, isStaticArray, isDynamicArray, isInstanceOf;
    import std.algorithm : map;
    import std.format : formattedWrite;
    import std.string : format;
    import std.range : repeat;
    import std.conv : to;
    import std.array : join, appender;
    import std.range : ElementEncodingType;
    import std.utf : toUTF16, toUTF8;
    import std.uri : encodeComponent;
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

private void write_impl(T)(Stream s, T data) if(!(is(T : bool) || is(T : bool))) {  
    static if(is(T Array : EncodingType[], EncodingType)) { // isArray
        static if(!is(T _ : S[n], S, size_t n)) { // !isStaticArray
            static if(__traits(hasMember, T, "LenType")) {
                write(s, cast(T.LenType)data.length);
            } else {
                write(s, cast(short)data.length);
            }
        }

        static if(EncodingType.sizeof == 1) {
            s.writeExact(data.ptr, data.length);
        } else {
            foreach(d; data) {
                write(s, d);
            }
        }
    } else static if(__traits(compiles, s.write(data))) {
        s.write(data);
    } else {
        // TODO: implement .send for MapChunkS, EntityMetadataS, Slot
        assert(false, "write not implemented for %s".format(T.stringof));
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
   
    static if(is(T Array : EncodingType[], EncodingType)) { // isArray
        static if(is(T _ : S[n], S, size_t n)) { // isStaticArray
            foreach(i; 0..T.length) {
                ret[i] = read!(EncodingType)(s);
                static if(__traits(hasMember, ret[i], "array_position")) ret[i].array_position = i;
            }
        } else {
            static if(__traits(hasMember, T, "LenType")) {
                T.LenType len = read!(T.LenType)(s);
            } else {
                short len = read!short(s);
            }

            static if(EncodingType.sizeof == 1 && !__traits(hasMember, T, "array_position")) {
                ret.length = len;
                s.readExact(ret.ptr, ret.length);
            } else {
                foreach(i; 0..len) {
                    ret ~= read!(EncodingType)(s);
                    static if(!__traits(hasMember, T, "LenType") && __traits(hasMember, ret[i], "array_position")) ret[i].array_position = i;
                }
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

ubyte[] twos_compliment(ubyte[] inp) {
    foreach(ref d; inp) {
        d = ~d;
    }

    bool carry = true;
    size_t i = inp.length - 1;
    while(carry) {
        carry = (inp[i] == 0xff);
        inp[i--]++;
    }

    return inp;
}

string to_hexdigest(ubyte[] inp) {
    auto app = appender!string();

    foreach(b; inp) {
        formattedWrite(app, "%02x", b);
    }

    return app.data;
}


string hexdump(ubyte[] src, size_t length=8) {
    size_t N = 0;
    auto app = appender!string();

    size_t length_ = length;
    while(src.length) {
        if(src.length < length_) {
            length_ = src.length;
        }
        
        ubyte[] s = src[0..length_]; // length inside a slice is deprecated...
        src = src[length_..$];

        auto hex = s.map!(x => "%02X".format(x))().join(" ");
        auto dec = s.map!(x => "%03d".format(cast(ubyte)x))().join(" ");
        auto text = s.map!(x => to!string(x > 47 && x < 128 ? cast(char)x : '.'))().join(" ");
        auto filler1 = " ".repeat((length-length_)*2).join("");
        auto filler2 = " ".repeat((length-length_)*3).join("");

        app.put("%04X   %s%s   %s%s   %s\n".format(N, dec, filler2, hex, filler1, text));
        N += length_;
    }

    return app.data;
}
