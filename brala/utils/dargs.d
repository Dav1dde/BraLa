module brala.utils.dargs;

private {
    import core.runtime : Runtime;
    import core.stdc.stdlib : exit;

    import std.getopt : getopt;
    import std.algorithm : canFind, any;
    import std.string : join;
    import std.array : replace, split;
    import std.stdio : writef, write;
    import std.typetuple : TypeTuple, NoDuplicates;
}

// Based on Robiks idea and code: https://gist.github.com/2622791

T get_options(T)() {
    return get_options!T(Runtime.args);
}

T get_options(T)(string[] app_args) {
    T args = T();

    enum param_list = build_param_list!T();

    void help() { // TODO: improve, this is ugly and prints no header and description
        string[][] h;

        foreach(param; param_list) {
            auto p = param.split(`"`)[1];
            auto s = p.split("|");

            h ~= s;
        }

        static if(__traits(hasMember, T, "help")) {
            static if(__traits(compiles, args.help(h))) {
                args.help(h);
            } else {
                args.help();
            }
        }

        Runtime.terminate();
        exit(0);
    }

    mixin(`getopt(app_args, `~ param_list.join(", ") ~`);`);

    return args;
}

private template get_alias(alias T) {
    alias NoDuplicates!(get_alias_impl!(T, __traits(allMembers, T))) get_alias;
}

private template get_alias_impl(S, T...) {
    static if(T.length == 0) {
        alias TypeTuple!() get_alias_impl;
    } else static if(__traits(compiles, mixin(`S.` ~ T[0] ~ `.alias_to`))) {
        alias TypeTuple!(AliasTuple!(T[0], mixin(`S.` ~ T[0] ~ `.alias_to`)), get_alias_impl!(S, T[1..$])) get_alias_impl;
    } else {
        alias get_alias_impl!(S, T[1..$]) get_alias_impl;
    }
}

private template AliasTuple(string n, string t) {
    alias n name;
    alias t long_name;
}

private static string[] build_param_list(T)() {
    string[] res;
    bool has_help;
    bool has_help_short;

    alias get_alias!(T) aliasses;

    foreach(member; __traits(allMembers, T)) {
        static if(!__traits(compiles, mixin(`T.` ~ member ~ `.alias_to`))) {    
            string temp = member;

            if(temp == "help") {
                continue;
            }

            foreach(A; aliasses) {
                static if(A.long_name == member) {
                    temp ~= "|" ~ A.name;
                    if(A.name == "h") {
                        has_help_short = true;
                    }
                }
            }

            res ~= `"`~temp.replace("_", "-")~`", &args.`~member;
        }
    }

    string temp = "help";
    if(!has_help_short) {
        temp ~= "|h";
    }
    res ~= `"` ~ temp ~ `", &help`;
    
    return res;
}

struct Alias(string s) {
    alias s alias_to;
}