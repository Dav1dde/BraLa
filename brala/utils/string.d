module brala.utils.string;

private {
    import std.array : appender;
    import std.algorithm : countUntil, canFind;
    import std.traits : isSomeString;
}


string expandVars(T)(T str, T[T] lookup) if(isSomeString!T) {
    enum varchars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-.";
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
                    string repl = lookup.get(str[index..index+until], "");

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

                string repl = lookup.get(var, "");
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
    string[string] lookup;
    lookup["fake_key_dlang"] = "test";
    assert(expandVars("${fake_key_dlang}/bar", lookup) == "test/bar");
    assert(expandVars("${test/bar", lookup) == "${test/bar");
    assert(expandVars("$${fake_key_dlang}/bar", lookup) == "${fake_key_dlang}/bar");

    assert(expandVars("$fake_key_dlang/bar", lookup) == "test/bar");
    assert(expandVars("$/bar", lookup) == "$/bar");

    lookup.remove("fake_key_dlang");
    assert(expandVars("${fake_key_dlang}/bar", lookup) == "${fake_key_dlang}/bar");

    assert(expandVars("$fake_key_dlang/bar", lookup) == "$fake_key_dlang/bar");

    assert(expandVars("${", lookup) == "${");
    assert(expandVars("${foo", lookup) == "${foo");
    assert(expandVars("$", lookup) == "$");
}