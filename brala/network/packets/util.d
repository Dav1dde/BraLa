module brala.network.packets.util;

private {
}

public {
    import std.metastrings : toStringNow; 
    import std.typetuple : TypeTuple, staticMap;
    import std.stream : Stream;
    import std.conv : to;
    
    import brala.network.util : read, write;
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
    private template extract_tostring(alias spec) { enum extract_tostring = `"` ~ spec.Type.stringof ~ ` `
                                                                    ~ spec.name ~ ` : \"" ~ to!string(this.` ~ spec.name ~ `) ~ "\""`; }
    private alias parse_vars!Vars pv;
    alias staticMap!(extract_type, pv) Types;
    
    private static string inject_data() {
        alias staticMap!(extract_decl, pv) decl;
        alias staticMap!(extract_name, pv) names;
        alias staticJoin!("\n", staticMap!(extract_ctorbody, pv)) ctor_body;
        
        static if(Vars.length) {
            alias staticJoin!("~\", \"~", staticMap!(extract_tostring, pv)) tostring;
        } else {
            enum tostring = "\"\"";
        }
        
        static if(pv.length == 0) {
            enum newargs = "";
        } else static if(pv.length == 1) {
            enum newargs = "read!Types(s)";
        } else {
            enum newargs = "read!Types(s).field";
        }
        
        alias staticJoin!(";\n", decl) tdecl;
        alias staticJoin!(", ", decl) cdecl;
        alias staticJoin!(", ", names) snames;
        
        return (tdecl~`;
                       
                this(`~cdecl~`) {
                    `~ctor_body~`
                }
                       
                void send(Stream s) {
                    write(s, id, `~snames~`);
                }
                       
                static typeof(this) recv(Stream s) {
                    return new typeof(this)(`~newargs~`);
                }
                
                string toString() {
                    return .stringof[7..$] ~ "." ~ typeof(this).stringof ~ "("~`~tostring~`~")";
                }`);
    }

    /// actual packet-code
    static @property ubyte id() { return id_; }
    
    mixin(inject_data());
}