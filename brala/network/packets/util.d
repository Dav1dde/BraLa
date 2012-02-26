module brala.network.packets.util;

private {
    import std.stream : Stream;
    import std.traits : isArray;
    import std.typetuple : TypeTuple, staticMap;
}


immutable byte NULL_BYTE = 0;
immutable ubyte NULL_UBYTE = 0;


mixin template Packet(ubyte id_, Vars...) {
    final @property ubyte id() { return id_; }
    
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
    
    private template extract_type(alias spec) { alias spec.Type extractType; }
    
    private alias parse_vars!Vars pv;
        
    private static string inject_data() {
        string types = "";
        string ctor_d = "this(";
        string ctor_b = "";
        string send_func = "void send(Stream s) { write(s, id, ";
        foreach(fs; pv) {
            enum s = fs.Type.stringof ~ " " ~ fs.name;
            types ~= s ~ ";";
            
            ctor_d ~= s ~ ",";
            ctor_b ~= "this." ~ fs.name ~ " = " ~ fs.name ~ ";";
            
            send_func ~= fs.name ~ ",";
        }
        ctor_d ~= ") {";
        ctor_b ~= "}";
        send_func ~= "); }";
        
        return types ~ ctor_d ~ ctor_b ~ send_func;
    }
    
    mixin(inject_data());
    
    alias staticMap!(extract_type, pv) Types;
}

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