module brala.utils.dargs;

private {
    import core.runtime : Runtime;

    import std.getopt : getopt;
    import std.string : join;
    import std.typetuple : TypeTuple, NoDuplicates, staticIndexOf;
}


T get_options(T)() {
    return get_options!T(Runtime.args);
}

T get_options(T)(string[] app_args) {
    T args = T();

    mixin(`getopt(app_args, `~ join(build_param_list!T(), ", ") ~`);`);

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

    alias get_alias!(T) aliasses;
    
    foreach(member; __traits(allMembers, T)) {
        static if(!__traits(compiles, mixin(`T.` ~ member ~ `.alias_to`))) {    
            string temp = member;

            foreach(A; aliasses) {
                static if(A.long_name == member) {
                    temp ~= "|" ~ A.name;
                }
            }

            res ~= `"`~temp~`", &args.`~member~``;
        }
    }
    
    return res;
}

struct Alias(string s) {
    alias s alias_to;
}