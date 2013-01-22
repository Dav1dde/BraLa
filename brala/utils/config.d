module brala.utils.config;

private {
    import brala.utils.ctfe : matches_overload, hasAttribute;
    import brala.utils.exception : InvalidConfig, NoKey, InvalidKey;
    import brala.utils.defaultaa : DefaultAA;
    
    import std.stdio : File;
    import std.conv : ConvException, to;
    import std.traits : moduleName, ReturnType, isArray;
    import std.exception : enforceEx;
    import std.string : format, strip;
    import std.array : split, join;
    import std.algorithm : canFind;
    import std.path : baseName;
    import std.regex : regex, match;
    import std.range : ElementEncodingType;
}


class Config {
    protected string[string] db;
    protected string[][string] db_arrays;

    string name = "<?Config?>";
    
    this() {
    }

    void read(string path) {
        File fp = File(path, "r");
        scope(exit) fp.close();

        readfp(fp, path.baseName);
    }

    void readfp(File file, string name="<?Config?>") {
        this.name = name;

        auto array_re = regex(`(.+)\[(\d*)\]$`, "g");
        
        size_t line_num = 0;
        foreach(line; file.byLine()) {
            line_num++;

            auto sline = line.strip();
            if(!sline.length) continue;
            
            char[][] t = sline.split("=");
            enforceEx!InvalidConfig(t.length >= 2, "Config %s: Syntax Error in line: %s".format(name, line_num));
            
            string key = t[0].idup.strip();
            string value = t[1..$].join("=").idup.strip();

            if(auto m = key.match(array_re)) {                
                key = m.captures[1];
                int index = m.captures[2].length > 0 ? to!int(m.captures[2]) : -1;

                if(auto v = key in db_arrays) {
                    if(index < 0) {
                        (*v) ~= value;
                    } else {
                        if(index >= v.length) v.length = index+1;

                        (*v)[index] = value;
                    }
                } else {
                    if(index <= 0) {
                        db_arrays[key] = [value];
                    } else {
                        db_arrays[key] = [];
                        db_arrays[key].length = index+1;
                        db_arrays[key][index] = value;
                    }
                }
            } else {
                db[key] = value;
            }
        }
    }

    void write(string path) {
        File fp = File(path, "w");
        scope(exit) fp.close();

        foreach(key; db.byKey()) {
            string value = db[key];

            fp.writef("%s = %s", key, value);
        }
    }

    T get(T)(string key, T default_) {
        try {
            return get!(T)(key);
        } catch(NoKey e) {}

        return default_;
    }

    T get(T)(string key) if(!isArray!T) {
        if(auto value = key in db) {
            return deserializer!T(*value);
        }

        throw new NoKey(`Config %s: Key "%s" not in config"`.format(name, key));
    }

    T get(T)(string key) if(isArray!T) {
        if(auto value = key in db_arrays) {
            T ret;
            ret.length = value.length;

            foreach(i, v; (*value)) {
                try {
                    ret[i] = deserializer!(ElementEncodingType!T)(v);
                } catch(ConvException e) {
                    ret[i] = (ElementEncodingType!T).init;
                }
            }

            return ret;
        }

        throw new NoKey(`Config %s: Key "%s" not in config"`.format(name, key));
    }

    void set(T)(string key, T value) if(!isArray!T) {
        enforceEx!InvalidKey(!key.canFind("="), `Config %s: Invalid Key: "=" not allowed in keyname`.format(name));
        
        db[key] = serializer!(T)(value);
    }

    void set(T)(string key, T value) if(isArray!T) {
        enforceEx!InvalidKey(!key.canFind("="), `Config %s: Invalid Key: "=" not allowed in keyname`.format(name));

        string[] t;
        t.length = value.length;

        foreach(i, v; value) {
            t[i] = serializer!(ElementEncodingType!T)(v);
        }

        db_arrays[key] = t;
    }

    bool remove(string key, bool is_array=false) {
        if(!is_array) {
            return db.remove(key);
        }

        return false;
    }
}

struct Serializer {}
struct Deserializer {}

mixin std_serializer!(bool);
mixin std_serializer!(byte);
mixin std_serializer!(ubyte);
mixin std_serializer!(short);
mixin std_serializer!(ushort);
mixin std_serializer!(int);
mixin std_serializer!(uint);
mixin std_serializer!(long);
mixin std_serializer!(ulong);
mixin std_serializer!(float);
mixin std_serializer!(double);
mixin std_serializer!(string);

private mixin template std_serializer(T) {
    mixin(
    "@Serializer string serialize_" ~ T.stringof ~ "(T inp) {
        return to!string(inp);
    }

    @Deserializer T deserialize_" ~ T.stringof ~"(string inp) {
        return to!T(inp);
    }");
}

template serializer(T) {
    alias get_serializer!(Serializer, T) serializer;
}

template deserializer(T) {
    alias get_serializer!(Deserializer, T) deserializer;
}

private template get_serializer(Attrib, Type) {
    alias get_serializer_impl!(Attrib, Type, __traits(allMembers, mixin(moduleName!Attrib))) get_serializer;
}

private template resolve(alias T) { alias T resolve; }

private template get_serializer_impl(Attrib, Type, T...) {
    static if(T.length == 0) {
        static assert(false, "No serializer for type " ~ Type.stringof);
    } else {
        static if(__traits(compiles, hasAttribute!(mixin(T[0]), Attrib)) && hasAttribute!(mixin(T[0]), Attrib)) {
            static if(is(Attrib == Deserializer)) {
                static if(is(ReturnType!(mixin(T[0])) == Type)) {
                    alias resolve!(mixin(T[0])) get_serializer_impl;
                } else {
                    alias get_serializer_impl!(Attrib, Type, T[1..$]) get_serializer_impl;
                }
            } else static if(is(Attrib == Serializer)) {
                static if(matches_overload!(mixin(moduleName!Attrib), T[0], Type)) {
                    alias resolve!(mixin(T[0])) get_serializer_impl;
                } else {
                    alias get_serializer_impl!(Attrib, Type, T[1..$]) get_serializer_impl;
                }
            } else {
                static assert(false, "Unsupported attribute");
            }
        } else {
            alias get_serializer_impl!(Attrib, Type, T[1..$]) get_serializer_impl;
        }
    }
}