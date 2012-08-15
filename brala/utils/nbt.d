module brala.utils.nbt;

private {
    import core.stdc.errno : errno;
    import std.string : toStringz;
    import std.traits : ReturnType;
    import std.conv : to;
    
    import nbt.nbt;
}


class NbtException : Exception {
    this(string msg) {
        super(msg);
    }
}

class NbtTree {
    nbt_node* root;

    this(nbt_node* root) {
        this.root = root;
    }

    ~this() {
        if(root !is null) {
            nbt_free(root);
        }
    }

    NbtTree clone() {
        return new NbtTree(nbt_clone(root));
    }
    
    static NbtTree parse_file(in char[] filename) {
        return new NbtTree(check_nbt!nbt_parse_path(filename.toStringz()));
    }

    static NbtTree parse(const(void)* ptr, size_t length) {
        return new NbtTree(check_nbt!nbt_parse(ptr, length));
    }

    static NbtTree parse(const ref void[] data) {
        return new NbtTree(check_nbt!nbt_parse(data.ptr, data.length));
    }
    
    static NbtTree parse_compressed(const(void)* ptr, size_t length) {
        return new NbtTree(check_nbt!nbt_parse_compressed(ptr, length));
    }

    static NbtTree parse_compressed(const ref void[] data) {
        return new NbtTree(check_nbt!nbt_parse_compressed(data.ptr, data.length));
    }

    bool map(bool delegate(nbt_node*) cb) {
        extern(C) static bool callback(nbt_node* node, void* aux) {
            auto dg = *cast(typeof(cb)*)aux;
            return dg(node);
        }

        return nbt_map(root, &callback, cast(void*)&cb);
    }

    nbt_node* filter(bool delegate(const(nbt_node)*) cb) {
        extern(C) static bool callback(const(nbt_node)* node, void* aux) {
            auto dg = *cast(typeof(cb)*)aux;
            return dg(node);
        }

        return nbt_filter(root, &callback, cast(void*)&cb);
    }

    nbt_node* filter_inplace(bool delegate(const(nbt_node)*) cb) {
        extern(C) static bool callback(const(nbt_node)* node, void* aux) {
            auto dg = *cast(typeof(cb)*)aux;
            return dg(node);
        }

        return nbt_filter_inplace(root, &callback, cast(void*)&cb);
    }

    nbt_node* find(bool delegate(const(nbt_node)*) cb) {
        extern(C) static bool callback(const(nbt_node)* node, void* aux) {
            auto dg = *cast(typeof(cb)*)aux;
            return dg(node);
        }

        return check_nbt!nbt_filter(root, &callback, cast(void*)&cb);
    }

    nbt_node* find_by_name(in char[] name) {
        return check_nbt!nbt_find_by_name(root, name.toStringz());
    }

    nbt_node* find_by_path(in char[] name) {
        return check_nbt!nbt_find_by_path(root, name.toStringz());
    }

    string dump_ascii() {
        return to!string(nbt_dump_ascii(root));
    }

    bool opEquals(NbtTree other) const {
        return nbt_eq(root, other.root);
    }
}

ReturnType!func check_nbt(alias func, Args...)(Args args) {
    auto ret = func(args);

    if(ret is null) {
        throw new NbtException(nbt_error_to_string(cast(nbt_status)errno).to!string());
    }

    return ret;
}