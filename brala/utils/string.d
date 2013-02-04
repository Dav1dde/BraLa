module brala.utils.string;

private {
    import std.string : format;
    import std.array : appender;
    import std.algorithm : countUntil, canFind;
    import std.traits : isAssociativeArray, isCallable;
    import core.exception : RangeError;

    import brala.utils.exception;
}


string expandVars(bool lax = false, bool recursive = true, T...)(string str, T t)
if((t.length == 1 || (t.length == 2 || is(T[1] == string[]))) && isCallable!(T[0]) || __traits(compiles, mixin(`t[0][""]`))) {
    alias t[0] Getter;

    static if(recursive) {
        static if(T.length == 2) {
            alias t[1] recursion_buster;
        } else {
            string[] recursion_buster;
        }
    }

    static string gg_code(string arg) {
        string recursion_code = `
            static if(recursive) {
                if(recursion_buster.canFind(` ~ arg ~ `)) {
                        throw new InvalidKey("Recursion with keys %s \"%s\"".format(recursion_buster, ` ~ arg ~ `));
                }

                recursion_buster ~= ` ~ arg ~ `;
                repl = expandVars!(lax, recursive)(repl, Getter, recursion_buster);
            }`;

        
        if(isCallable!(T[0])) {
            return `
            string repl = Getter(` ~ arg ~ `);
            
            ` ~ recursion_code;
        } else {
            return `
            string repl;
            try {
                repl = Getter[` ~ arg ~ `];

                ` ~ recursion_code ~ `
            } catch(RangeError) {
                static if(lax) {} else {
                    throw new NoKey("Key \"%s\" does not exist".format(` ~ arg ~ `));
                }
            }`;
        }
    }
    
    
    enum varchars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-.[]";
    size_t index = 0;
    size_t strlen = str.length;
    auto result = appender!string();

    while(index < strlen) {
        char c = str[index++];

        if(c == '$' && index < strlen) {
            char c1 = str[index];

            if(c1 == '$') {
                result.put('$');
                ++index;
            } else if(c1 == '{') {
                auto temp = str[++index..$];
                auto until = temp.countUntil('}');

                if(until >= 0) {
                    mixin(gg_code("str[index..index+until]"));

                    if(repl.length) {
                        result.put(repl);
                        index += until+1;
                    } else {
                        result.put("${");
                    }
                } else {
                    result.put("${");
                }
            } else {
                string var;

                c = c1;
                while(c && varchars.canFind(c)) {
                    var ~= c;
                    ++index;
                    if(index < strlen) {
                        c = str[index];
                    } else {
                        break;
                    }
                }

                mixin(gg_code("var"));
                if(repl.length) {
                    result.put(repl);
                } else {
                    result.put("$");
                    result.put(var);
                }
            }
        } else {
            result.put(c);
        }
    }

    return result.data;
}

unittest {
//     import std.exception : assertThrown;
//     
//     string[string] lookup;
//     lookup["fake_key_dlang"] = "test";
//     assert(expandVars("${fake_key_dlang}/bar", lookup) == "test/bar");
//     assert(expandVars("${test/bar", lookup) == "${test/bar");
//     assert(expandVars("$${fake_key_dlang}/bar", lookup) == "${fake_key_dlang}/bar");
//     assert(expandVars("$fake_key_dlang/bar", lookup) == "test/bar");
//     
//     lookup.remove("fake_key_dlang");
//     assertThrown!NoKey(expandVars("$/bar", lookup));
//     assertThrown!NoKey(expandVars("${fake_key_dlang}/bar", lookup));
//     assertThrown!NoKey(expandVars("$fake_key_dlang/bar", lookup));
// 
//     assert(expandVars!true("$/bar", lookup) == "$/bar");
//     assert(expandVars!true("${fake_key_dlang}/bar", lookup) == "${fake_key_dlang}/bar");
//     assert(expandVars!true("$fake_key_dlang/bar", lookup) == "$fake_key_dlang/bar");
// 
//     assert(expandVars("${", lookup) == "${");
//     assert(expandVars("${foo", lookup) == "${foo");
//     assert(expandVars("$", lookup) == "$");
// 
//     string getter(string arg) {
//         return arg ~ "foo";
//     }
// 
//     assert(expandVars("${foo}", &getter) == "foofoo");
}