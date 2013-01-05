module brala.network.packets.types;

private {
    import std.stream : Stream;
    import std.typetuple : TypeTuple, staticIndexOf, staticMap;
    import std.typecons : Tuple;
    import std.metastrings : toStringNow;
    import std.algorithm : canFind;
    import std.string : format;
    import std.array : join, appender, replace;
    import std.conv : to;
    import std.zlib : uncompress;
    import std.exception : enforceEx;
    import core.stdc.errno;
    
    import gl3n.linalg : vec3i;
    import nbt : NBTFile;
    
    import brala.dine.chunk : Chunk, Block;
    import brala.network.packets.util : staticJoin, coords_from_j;
    import brala.network.util : read, write;
    import brala.exception : ServerError;
}


abstract class IPacket {
    const ubyte id;
    void send(Stream s);
    static typeof(this) recv(Stream s);
}


alias Tuple!(short, "id", byte, "count", short, "damage") Tup5;
alias Tuple!(int, int, int) Tup6;

struct Metadata {
    private template Pair(T, int n) {
        alias T type;
        alias n name;
    }

    private template extract_type(alias T) { alias T.type extract_type; }
    private template extract_name(alias T) { alias T.name extract_name; }
    private template make_decl(alias T) { enum make_decl = T.type.stringof ~ " _" ~ toStringNow!(T.name) ~ ";"; }

    alias TypeTuple!(Pair!(byte, 0), Pair!(short, 1), Pair!(int, 2), Pair!(float, 3),
                     Pair!(string, 4), Pair!(Slot, 5), Pair!(Tup6, 6)) members;

    private static string make_union() {
        alias staticJoin!("\n", staticMap!(make_decl, members)) s;
        return "union {" ~ s ~ "}";
    }

    byte type;

    mixin(make_union());

    auto get(T)() {
        alias staticIndexOf!(T, staticMap!(extract_type, members)) type_index;
        static if(type_index < 0) {
            static assert(false);
        } else {
            return mixin("_" ~ toStringNow!(members[type_index].name));
        }
    }
    
    string toString() {
        assert(type >= 0 && type <= 6);

        string s;
        final switch(type) {
            foreach(m; members) {
                case m.name: s = to!string(mixin("_" ~ toStringNow!(m.name)));
            }
        }

        return s;
    }
}

struct EntityMetadataS {   
    Metadata[byte] metadata;
    
    static EntityMetadataS recv(Stream s) {
        EntityMetadataS ret;
        
        ubyte x = read!ubyte(s);

        while(x != 127) {
            Metadata m;

            byte index = x & 0x1f;
            m.type = x >> 5;

            switch(m.type) {
                case 0: m._0 = read!byte(s); break;
                case 1: m._1 = read!short(s); break;
                case 2: m._2 = read!int(s); break;
                case 3: m._3 = read!float(s); break;
                case 4: m._4 = read!string(s); break;
                case 5: m._5 = read!(Slot)(s); break;
                case 6: m._6 = read!(int, int, int)(s); break;
                default: throw new ServerError(`Invalid type in entity metadata "%s".`.format(m.type));
            }

            ret.metadata[index] = m;

            x = read!ubyte(s);
        }
        
        return ret;
    }
    
    string toString() {
        string[] s;
        foreach(byte key, Metadata value; metadata) {
            s ~= format("%d : %s", key, value.toString());
        }

        return format("EntityMetadataS(%s)", s.join(", "));
    }
}

struct Slot {
    short item;
    byte item_count = 0;
    short metadata = 0;
    NBTFile nbt;

    private size_t _slot;
    private bool has_array_position;
    @property void array_position(size_t n) {
        if(!has_array_position) {
            _slot = n;
            has_array_position = true;
        }
    }
    @property size_t slot() { return _slot; }


    static Slot recv(Stream s) {
        Slot ret;

        ret.item = read!short(s);

        if(ret.item != -1) {
            ret.item_count = read!byte(s);
            ret.metadata = read!short(s);

            int len = read!short(s);

            if(len != -1) {
                debug assert(len >= 0);
                ubyte[] compressed_data = new ubyte[len];
                s.readExact(compressed_data.ptr, len);
                ret.nbt = new NBTFile(compressed_data, NBTFile.Compression.AUTO);
            }
        }

        if(ret.nbt is null) {
            ret.nbt = new NBTFile(); // having ret.nbt null makes things only harder
        }

        return ret;
    }

    string toString() {
        string s = "Slot" ~ (has_array_position ? "_" ~ to!string(_slot) : "");

        string pnbt = nbt.toString().replace("}\n", "}").replace("{\n", "{").replace("\n", ";").replace("  ", "");

        return format(`%s(short block : "%s", byte item_count : "%s", short metadata : "%s", NBTFile nbt : "%s"`,
                       s, item, item_count, metadata, pnbt);
    }
}

struct ObjectData {
    int data;
    short speed_x;
    short speed_y;
    short speed_z;

    static ObjectData recv(Stream s) {
        ObjectData ret;

        ret.data = read!int(s);

        if(ret.data) {
            ret.speed_x = read!short(s);
            ret.speed_y = read!short(s);
            ret.speed_z = read!short(s);
        }

        return ret;
    }

    void send(Stream s) {
        write(s, data);

        if(data) {
            write(s, speed_x, speed_y, speed_z);
        }
    }
}

        

struct Array(T, S) {
    alias T LenType;
    S[] arr;
    alias arr this;
}

struct StaticArray(T, size_t length) {
    T[length] arr;
    alias arr this;
}


// Chunk stuff
struct MapChunkS { // TODO: implement send
    int x;
    int z;
    bool contiguous;
    ushort primary_bitmask;
    ushort add_bitmask;
    Chunk chunk;
    alias chunk this;
    
    static MapChunkS recv(Stream s) {
        MapChunkS ret;
        ret.chunk = new Chunk();

        ret.x = read!int(s);
        ret.z = read!int(s);
        ret.contiguous = read!bool(s);

        ret.chunk.primary_bitmask = read!ushort(s);
        ret.chunk.add_bitmask = read!ushort(s);

        int len = read!int(s);
        ubyte[] compressed_data = new ubyte[len];
        s.readExact(compressed_data.ptr, len);
        ubyte[] unc_data = cast(ubyte[])uncompress(compressed_data);

        ret.chunk.fill_chunk_with_nothing();

        // if ret.contiguous, there is biome data
        parse_raw_chunk(ret.chunk, unc_data, ret.contiguous);

        return ret;
    }

    static size_t parse_raw_chunk(Chunk chunk, const ref ubyte[] unc_data, bool biome_data) {
        size_t offset = 0;
        foreach(i; 0..16) {
            if(chunk.primary_bitmask & 1 << i) {
                const(ubyte)[] temp = unc_data[offset..offset+4096];

                foreach(j, block_id; temp) {
                    vec3i coords = coords_from_j(cast(uint)j, i);

                    chunk.blocks[chunk.to_flat(coords)].id = block_id;
                }

                offset += 4096;
            }
        }

        foreach(f; TypeTuple!("metadata", "block_light", "sky_light")) {
            foreach(i; 0..16) {
                if(chunk.primary_bitmask & 1 << i) {
                    const(ubyte)[] temp = unc_data[offset..offset+2048];

                    uint j = 0;
                    foreach(dj; temp) {
                        vec3i coords_m1 = coords_from_j(j++, i);
                        vec3i coords_m2 = coords_from_j(j++, i);

                        mixin("chunk.blocks[chunk.to_flat(coords_m1)]." ~ f ~ " = dj & 0x0F;");
                        mixin("chunk.blocks[chunk.to_flat(coords_m2)]." ~ f ~ " = dj >> 4;");
                    }

                    offset += 2048;
                }
            }
        }

        if(biome_data) {
            chunk.biome_data = unc_data[offset..(offset+256)];
            offset += 256;
        }

        return offset;
    }

    string toString() {
        return format(`ChunkS(int x : "%d", int z : "%d", bool contiguous : "%s", ushort primary_bitmask : "%016b", `
                             `ushort add_bitmask : "%016b", Chunk chunk : "%s")`,
                              x, z, contiguous, primary_bitmask, add_bitmask, chunk);
    } 
}

struct MapChunkBulkS {
    alias Tuple!(vec3i, "coords", Chunk, "chunk") CoordChunkTuple;
    
    short chunk_count;
    CoordChunkTuple[] chunks;

    struct MetaInformation {
        int x;
        int z;
        short primary_bitmask;
        short add_bitmask;

        this(int x, int z, short primary_bitmask, short add_bitmask) {
            this.x = x;
            this.z = z;
            this.primary_bitmask = primary_bitmask;
            this.add_bitmask = add_bitmask;
        }

        static MetaInformation recv(Stream s) {
            return MetaInformation(read!(int, int, short, short)(s).field);
        }

        void send(Stream s) {
            write!(int, int, short, short)(s, x, z, primary_bitmask, add_bitmask);
        }
    }

    static MapChunkBulkS recv(Stream s) {
        MapChunkBulkS ret;

        ret.chunk_count = read!short(s);

        uint len = read!uint(s);
        read!bool(s); // unknown
        ubyte[] compressed_data = new ubyte[len];
        s.readExact(compressed_data.ptr, len);
        ubyte[] unc_data = cast(ubyte[])uncompress(compressed_data);

        auto app = appender!(CoordChunkTuple[])();
        app.reserve(ret.chunk_count);
        foreach(i; 0..ret.chunk_count) {
            auto m = MetaInformation.recv(s);

            vec3i coords = vec3i(m.x, 0, m.z);
            Chunk chunk = new Chunk();
            chunk.primary_bitmask = m.primary_bitmask;
            chunk.add_bitmask = m.add_bitmask;

            app.put(CoordChunkTuple(coords, chunk));
        }
        ret.chunks = app.data;

        size_t offset = 0;
        foreach(cc; ret.chunks) {
            cc.chunk.fill_chunk_with_nothing();

            offset += MapChunkS.parse_raw_chunk(cc.chunk, unc_data[offset..$], true);
        }

        return ret;
    }

    string toString() {
        auto app = appender!string();
        foreach(i, cc; chunks) {
            app.put("\n\t");
            app.put(`%d: CoordChunkTuple : [vec3i coords : %s, Chunk chunk : "%s"]`.format(i+1, cc.coords, cc.chunk));
        }
        app.put("\n");

        return `MapChunkBulkS(short chunk_count : "%s", CoordChunkTuple[] chunks : [%s]`.format(chunk_count, app.data);
    }
}

struct MultiBlockChangeData {
    uint[] data;
    alias data this;

    static MultiBlockChangeData recv(Stream s) {
        MultiBlockChangeData ret;

        int length = read!int(s);

        auto app = appender!(uint[])();
        app.reserve(length/4);

        foreach(_; 0..length/4) {
            app.put(read!uint(s));
        }

        ret.data = app.data;

        return ret;
    }

    void load_into_chunk(Chunk chunk) {
        foreach(block_data; data) {
            Block block;

            block.metadata = block_data & 0x0000000f;
            block.id = (block_data & 0x0000fff0) >> 4;

            int y = (block_data & 0x00ff0000) >> 16;
            int z = (block_data & 0x0f000000) >> 24;
            int x = (block_data & 0xf0000000) >> 28;

            chunk.blocks[chunk.to_flat(x, y, z)] = block;
        }
    }
}