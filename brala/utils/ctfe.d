module brala.utils.ctfe;

private {
    import std.typetuple : TypeTuple;
    import std.traits : ParameterTypeTuple;
}

template TupleRange(int from, int to) {
    alias TupleRangeImpl!(to-1, from) TupleRange;
}

private template TupleRangeImpl(int to, int now) {
    static if(now == to) {
        alias TypeTuple!(now) TupleRangeImpl;
    } else {
        alias TypeTuple!(now, TupleRangeImpl!(to, now+1)) TupleRangeImpl;
    }
}

template staticJoin(string delimiter, T...) {
    static if(T.length == 0) {
        enum staticJoin = "";
    } else static if(T.length == 1) {
        enum staticJoin = T[0];
    } else {
        enum staticJoin = T[0] ~ delimiter ~ staticJoin!(delimiter, T[1..$]);
    }
}

template matches_overload(alias mod, string name, T) {
    alias matches_overload_impl!(T, __traits(getOverloads, mod, name)) matches_overload;
}

private template matches_overload_impl(T, Funny...) {
    static if(Funny.length == 0) {
        enum matches_overload_impl = false;
    } else {
        static if(ParameterTypeTuple!(Funny[0]).length != 1) {
            alias matches_overload_impl!(T, Funny[1..$]) matches_overload_impl;
        } else static if(is(ParameterTypeTuple!(Funny[0])[0] == T)) {
            enum matches_overload_impl = true;
        } else {
            alias matches_overload_impl!(T, Funny[1..$]) matches_overload_impl;
        }
    }
}

template hasAttribute(alias T, AttributeInQuestion)
{
    bool does_have()
    {
        foreach (t; __traits(getAttributes, T)) {
            if (typeid(t) is typeid(AttributeInQuestion)) {
                return true;
            }
        }

        return false;
    }

    enum hasAttribute = does_have();
}