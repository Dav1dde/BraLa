module brala.utils.defaultaa;

private import std.traits : ReturnType, isCallable;

struct DefaultAA(value_type, key_type, alias default__) {
    private value_type[key_type] _store;
    alias _store this;
    alias default__ default_;

    static if(isCallable!default_) {
        static assert(is(ReturnType!(default_) : value_type), "callable returntype doesn't match value_type");
    }

    private value_type _get_default() {
        static if(isCallable!default_) {
            return default_();
        } else {
            return default_;
        }
    }

    value_type opIndex(key_type key) {
        if(value_type* value = key in _store) {
            return *value;
        } else {
            return _get_default();
        }
    }

    void opIndexAssign(value_type value, key_type key) {
        _store[key] = value;
    }

    void opIndexOpAssign(string op)(value_type rhs, key_type key) {
        if(key !in _store) {
            _store[key] = _get_default();
        }

        mixin("_store[key]" ~ op ~"= rhs;");
    }
}

unittest {
    DefaultAA!(int, string, 12) myaa;
    assert(myaa["baz"] == 12);
    assert(myaa["foo"] == 12);
    myaa["baz"] = -12;
    assert(myaa["baz"] == -12);
    assert(myaa["foo"] == 12);
    myaa["baz"] += 12;
    assert(myaa["baz"] == 0);
    myaa["foo"] -= 12;
    assert(myaa["foo"] == 0);
    myaa["lulz"] -= 12;
    assert(myaa["lulz"] == 0);

    int dg() { return 1; }

    DefaultAA!(int, string, dg) mydgaa;
    assert(mydgaa["foo"] == 1);
    mydgaa["lulz"] -= 1;
    assert(mydgaa["lulz"] == 0);
}