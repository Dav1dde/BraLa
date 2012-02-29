module brala.network.packets.util;

private {
    import std.traits : isArray;
    import std.typecons : Tuple;
    import std.utf : toUTF16, toUTF8;
    
    debug import std.stdio : writefln;
}

public {
    import std.metastrings : toStringNow;
    import std.typetuple : TypeTuple, staticMap;
    import std.stream : Stream;
}
    

immutable byte NULL_BYTE = 0;
immutable ubyte NULL_UBYTE = 0;


template staticJoin(string delimiter, T...) {
    static if(T.length == 0) {
        enum staticJoin = "";
    } else static if(T.length == 1) {
        enum staticJoin = T[0];
    } else {
        enum staticJoin = T[0] ~ delimiter ~ staticJoin!(delimiter, T[1..$]);
    }
}

version(none) {
    mixin template get_packets_mixin() {
        private template get_packets(alias T) {
            alias get_packets_impl!(__traits(allMembers, T)) get_packets;
        }

        private template get_packets_impl(T...) {
            static if(T.length == 0) {
                alias TypeTuple!() get_packets_impl;
            } else static if(__traits(compiles, mixin(T[0]).id)) {
                alias TypeTuple!(TypeTuple!(T[0], mixin(T[0]).id), get_packets_impl!(T[1..$])) get_packets_impl;
            } else {
                alias TypeTuple!(get_packets_impl!(T[1..$])) get_packets_impl;
            }
        }
    }

    template make_case(alias T) { pragma(msg, typeof(T).stringof); enum make_case = "case " ~ toStringNow!(T[1]) ~ ": return mixin("~ T[0] ~").recv(s);"; }

    template make_parser(T...) {
        string make_parser() {
            alias staticJoin!("\n", staticMap!(make_case, T)) cases;
            
            return "IPacket parse_packet(ubyte id, Stream s) {
                        switch(id) {
                            "~cases~"
                        }
                    }";
        }
    }
}

mixin template Packet(ubyte id_, Vars...) {    
    static assert(Vars.length % 2 == 0);
    
    private template parse_vars(Vars...) {
        static if(Vars.length == 0) {
            alias TypeTuple!() parse_vars;
        } else static if(is(Vars[0])) {
            static assert(is(typeof(Vars[1]) : string));
            alias TypeTuple!(FieldSpec!(Vars[0..2]), parse_vars!(Vars[2..$])) parse_vars;
        } else {
            static assert(false);
        }
    }

    private template FieldSpec(T, string s) {
        alias T Type;
        alias s name;
    }
    
    private template extract_type(alias spec) { alias spec.Type extract_type; }
    private template extract_name(alias spec) { alias spec.name extract_name; }
    private template extract_decl(alias spec) { enum extract_decl = spec.Type.stringof ~ " " ~ spec.name; }
    private template extract_ctorbody(alias spec) { enum extract_ctorbody = "this." ~ spec.name ~ " = " ~ spec.name ~ ";"; }
    
    private alias parse_vars!Vars pv;
    alias staticMap!(extract_type, pv) Types;
    
    private static string inject_data() {
        alias staticMap!(extract_decl, pv) decl;
        alias staticMap!(extract_name, pv) names;
        alias staticJoin!("\n", staticMap!(extract_ctorbody, pv)) ctor_body;
        
        alias staticJoin!(";\n", decl) tdecl;
        alias staticJoin!(", ", decl) cdecl;
        alias staticJoin!(", ", names) snames;
        
        return (tdecl~";
                       
                this("~cdecl~") {
                    "~ctor_body~"
                }
                       
                void send(Stream s) {
                    write(s, id, "~snames~");
                }
                       
                static typeof(this) recv(Stream s) {
                    return new typeof(this)(read!Types(s).field);
                }");
    }
    
    /// actual packet-code
    static @property ubyte id() { return id_; }
    
    mixin(inject_data());
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

private void write_impl(T)(Stream s, T data) if(isArray!T && !is(T : string)) {
    foreach(d; data) {
        s.write(d);
    }
}

private void write_impl(T)(Stream s, T data) if(!isArray!T && !is(T : bool)) {
    s.write(data);
}


Tuple!(Types) read(Types...)(Stream s) {
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


private T read_impl(T)(Stream s) if(isArray!T && !is(T : string)) {
    T ret; // TODO
    return ret;
}


private T read_impl(T)(Stream s) if(!isArray!T && !is(T : bool)){
    T ret;
    s.read(ret);
    return ret;
}