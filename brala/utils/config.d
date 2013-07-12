module brala.utils.config;

private {
    import std.stdio : File;
    import std.conv : ConvException, to;
    import std.traits : moduleName, ReturnType, isArray, CommonType, isInstanceOf;
    import std.exception : enforceEx, collectException;
    import std.string : format, strip, splitLines;
    import std.array : split, join, replace;
    import std.algorithm : canFind, startsWith, sort, countUntil;
    import std.path : baseName, buildNormalizedPath;
    import std.regex : regex, reReplace = replace, match;
    import std.range : ElementEncodingType;
    import std.typecons : TypeTuple;
    import core.exception : RangeError;

    import glwtf.signals : Signal;

    import brala.utils.ctfe : matches_overload, hasAttribute;
    import brala.utils.exception : InvalidConfig, NoKey, InvalidKey, InvalidValue, ConfigException;
    import brala.utils.aa : DefaultAA;
    import brala.utils.string : expandVars;
}


private struct ValueSignalPair(Value) {
    Value value;
    alias value this;
    Signal!(Config, string) signal;
    bool set = false;

    this(T)(T handler) if(__traits(compiles, signal.connect(handler))) {
//         signal = new Signal!(string);
        signal.connect(handler);
    }

    this()(Value value) {
        this.value = value;
        this.set = true;
    }
}

class Config {
    protected ValueSignalPair!(string)[string] db;
    protected ValueSignalPair!(string[])[string] db_arrays;

    protected template get_db(T) {
        static if(!isArray!T || is(T == string)) {
            alias get_db = db;
        } else {
            alias get_db = db_arrays;
        }
    }

    string name = "<?Config?>";

    string[] dont_save;
    
    this() {}

    this(string[] dont_save) {
        this.dont_save = dont_save;
    }

    void read(string path) {
        File fp = File(path, "r");
        scope(exit) fp.close();

        readfp(fp, path.baseName);
    }

    static Config from_string(Args...)(const(char)[] contents, Args args) {
        auto config = new Config(args);

        struct FakeFP {
            const(char)[] c;
        
            char[][] byLine() {
                return c.dup.splitLines();
            }
        }

        config.readfp(FakeFP(contents));

        return config;
    }

    void readfp(T)(T file, string name="<?Config?>") if(__traits(hasMember, T, "byLine")) {
        this.name = name;

        auto array_re = regex(`(.+)\[(\d*)\]$`, "g");
        auto comment_re = regex(`[^\\]#.*`, "g");
        
        size_t line_num = 0;
        foreach(line; file.byLine()) {
            line_num++;

            auto sline = line.strip();
            if(!sline.length || sline.startsWith("#")) continue;
            
            char[][] t = sline.split("=");
            enforceEx!InvalidConfig(t.length >= 2, "Config %s: Syntax Error in line: %s".format(name, line_num));
            
            string key = t[0].idup.strip();
            string value = t[1..$].join("=").reReplace!(x => "")(comment_re).idup.strip();

            if(auto m = key.match(array_re)) {                
                key = m.captures[1];
                int index = m.captures[2].length > 0 ? to!int(m.captures[2]) : -1;

                if(auto v = key in db_arrays) {
                    if(index < 0) {
                        (*v).value ~= value;
                    } else {
                        if(index >= v.length) v.length = index+1;

                        (*v).value[index] = value;
                    }
                    v.set = true;
                } else {
                    if(index <= 0) {
                        db_arrays[key] = ValueSignalPair!(string[])([value]);
                    } else {
                        db_arrays[key].value = ValueSignalPair!(string[])(new string[index+1]);
                        db_arrays[key].value[index] = value;
                    }
                }
            } else {
                db[key] = ValueSignalPair!string(value);
            }
        }

        emit_all();
    }

    void write(string path) {
        File fp = File(path, "w");
        scope(exit) fp.close();

        foreach(key; sort(db.keys)) {
            if(dont_save.canFind(key)) continue;
            
            string value = db[key];

            fp.writef("%s = %s\n", key, value);
        }

        fp.writef("\n");

        foreach(key; sort(db_arrays.keys)) {
            if(dont_save.canFind(key)) continue;
            
            string[] value = db_arrays[key];

            foreach(i, v; value) {
                fp.writef("%s[%s] = %s\n", key, i, v);
            }
            fp.writef("\n\n");
        }
    }

    T get(T, bool expand = true)(string key, T default_) {
        try {
            return get!(T, expand)(key);
        } catch(NoKey e) {}

        return default_;
    }

    T get(T, bool expand = true)(string key) if(!isArray!T || is(T == string)) {
        auto value = key in db;
        if(value !is null && value.set) {
            static if(expand) {
                T ret = deserializer!T((*value).expandVars(&get_string));
            } else {
                T ret = deserializer!T(*value);
            }
            
            return ret;
        }

        throw new NoKey(`Config %s: Key "%s" not in config"`.format(name, key));
    }

    T get(T, bool expand = true)(string key) if(isArray!T && !is(T == string)) {
        auto value = key in db_arrays;
        if(value && value.set) {
            T ret;
            ret.length = value.length;

            foreach(i, v; (*value)) {
                try {
                    static if(expand) {
                        ret[i] = deserializer!(ElementEncodingType!T)(v.expandVars(&get_string));
                    } else {
                        ret[i] = deserializer!(ElementEncodingType!T)(v);
                    }
                } catch(ConvException e) {
                    ret[i] = (ElementEncodingType!T).init;
                }
            }

            return ret;
        }

        throw new NoKey(`Config %s: Key "%s" not in config"`.format(name, key));
    }

    CommonType!(Args) get_option(Args...)(string key) {
        alias T = typeof(return);

        T value = get!T(key);

        if([Args].canFind(value)) {
            return value;
        }

        throw new InvalidValue(`Config %s: Value "%s" is not allowed for key %s, must be in "[%s]"`
                               .format(name, value, key, [Args].join(", ")));
    }

    /// special method for expandVars call, only returns serialized, but expanded strings
    /// and supports array[index] syntax
    string get_string(string s) {
        auto start = s.countUntil("[");
        
        if(start > 0) { // > 0 is intended
            string key = s[0..start];

            size_t index;
            try {
                index = to!size_t(s[start+1..$-1]);
            } catch(ConvException) {
                throw new InvalidKey(`Invalid Key "%s"`.format(s));
            }

            try {
                return db_arrays[key][index];
            } catch(RangeError) {}
        } else {
            try {
                return db[s];
            } catch(RangeError) {}
        }

        throw new NoKey(`Config %s: Key "%s" not in config"`.format(name, s));
    }
    

    void set(T)(string key, T value) if(!isArray!T || is(T == string)) {
        enforceEx!InvalidKey(!key.canFind("="), `Config %s: Invalid Key: "=" not allowed in keyname`.format(name));

        if(auto v = key in db) {
            v.value = serializer!(T)(value);
            v.signal.emit(this, key);
        } else {
            // .value is important! Segfault pls
            db[key] = ValueSignalPair!string(serializer!(T)(value));
            db[key].signal.emit(this, key);
        }
    }

    void set(T)(string key, T value) if(isArray!T && !is(T == string)) {
        enforceEx!InvalidKey(!key.canFind("="), `Config %s: Invalid Key: "=" not allowed in keyname`.format(name));

        string[] t;
        t.length = value.length;

        foreach(i, v; value) {
            t[i] = serializer!(ElementEncodingType!T)(v);
        }

        if(auto v = key in db) {
            v.value = t;
            v.signal.emit(this, key);
        } else {
            // same with .value here...
            db_arrays[key] = ValueSignalPair!(string[])(t);
            db_arrays[key].signal.emit(this, key);
        }
    }

    bool set_if(T)(string key, T value) {
        static if(__traits(hasMember, T, "length")) {
            bool s = cast(bool)value.length;
        } else {
            bool s = cast(bool)value;
        }

        if(s) {
            set(key, value);
            return true;
        }

        return false;
    }

    void set_assert(T, Ex = InvalidValue)(string key, T value, string message="No value specified") {
        enforceEx!Ex(set_if(key, value), message);
    }

    void set_default(T)(string key, T value) {
        if(!has_key!(T)(key)) {
            set(key, value);
        }
    }

    bool remove(string key, bool is_array=false) {
        if(!is_array) {
            return db.remove(key);
        }

        return false;
    }

    bool has_key(T)(string key) {
        alias cdb = get_db!T;

        auto value = key in cdb;
        return value && value.set;
    }

    auto connect(T, S)(string key, auto ref S handler) {
        alias cdb = get_db!T;

        if(auto v = key in cdb) {
            v.signal.connect(handler);
        } else {
            cdb[key] = typeof(cdb[key])(handler);
        }

        static struct FakeEmitter {
            Config config;
            string key;
            typeof(cdb[key].signal) signal;

            void emit() {
                signal.emit(config, key);
            }
        }

        return FakeEmitter(this, key, cdb[key].signal);
    }

    auto connect(T)(ref T cb, string key) if(isInstanceOf!(ConfigBound, T)) {
        return cb.connect(this, key);
    }

    void disconnect(T, S)(string key, auto ref S handler) {
        alias cdb = get_db!T;

        if(auto v = key in cdb) {
            v.signal.disconnect(handler);
        }
    }

    void disconnect(T)(string key, ref T cb) if(isInstanceOf!(ConfigBound, T)) {
        cb.disconnect(this, key);
    }

    void emit(T)(string[] keys...) {
        alias cdb = get_db!T;
        foreach(key; keys) {
            cdb[key].signal.emit(this, key);
        }
    }

    void emit_all() {
        foreach(cdb; TypeTuple!(db, db_arrays))
        foreach(key, value; db) {
            value.signal.emit(this, key);
        }
    }
}

struct ConfigBound(T, S = void) {
    T value;
    alias value this;

    static if(is(S == void)) {
        alias GetType = T;
    } else {
        alias GetType = S;
    }

    private string key;
    private Config config;

    this(T rhs) {
        // TODO sync with config once connected?
        value = rhs;
    }

    auto connect(Config config, string key) {
        enforceEx!ConfigException(this.config !is config, "ConfigBound already bound to config, key: " ~ this.key);
        enforceEx!ConfigException(this.key != key, "ConfigBound already bound to key: " ~ this.key);

        struct FakeEmitter {
            private void delegate(Config, string) handler;
            void emit() {
                handler(config, key);
            }
        }

        if(this.config !is null) return FakeEmitter(&handler);

        this.key = key;
        this.config = config;
        config.connect!GetType(key, &handler);

        return FakeEmitter(&handler);
    }

    void handler(Config config, string key) {
        value = to!T(config.get!GetType(key));
    }

    void disconnect(Config config, string key) {
        config.disconnect!GetType(key, &handler);
    }

    void opAssign(T value) {
        enforceEx!ConfigException(this.config !is null,
                                  "You need to connect this ConfigBound to a Config first");
        static if(is(T == GetType)) {
            config.set(key, value);
        } else {
            config.set(key, to!GetType(value));
        }
    }
}



struct Serializer {}
struct Deserializer {}

mixin std_serializer!(char);
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

struct Path {
    string path;
    alias path this;

    static string serialize(Path inp) {
        return inp.path.replace(`\`, `/`);
    }

    static Path deserialize(string inp) {
        return Path(inp.buildNormalizedPath()); // this replaces / with \ on Windows
    }
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
    static if(is(Attrib == Serializer) && __traits(hasMember, Type, "serialize")) {
        alias Type.serialize get_serializer_impl;
    } else static if(is(Attrib == Deserializer) && __traits(hasMember, Type, "deserialize")) {
        alias Type.deserialize get_serializer_impl;
    } else static if(T.length == 0) {
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