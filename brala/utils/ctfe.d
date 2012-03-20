module brala.utils.ctfe;

private {
    import std.typetuple : TypeTuple;
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