module brala.network.packets.types;

private {
    import nbt.nbt;
    
    import std.stream : Stream;
    import std.typetuple : TypeTuple, staticIndexOf, staticMap;
    import std.typecons : Tuple;
    import std.metastrings : toStringNow;
    import std.algorithm : canFind;
    import std.string : format;
    import std.array : join;
    import std.conv : to;
    import std.zlib : uncompress;
    
    import gl3n.linalg : vec3i;
    
    import brala.dine.chunk : Chunk, Block;
    import brala.network.packets.util : staticJoin, coords_from_j;
    import brala.network.util : read;
    import brala.exception : ServerError;
}


abstract class IPacket {
    const ubyte id;
    void send(Stream s);
    static typeof(this) recv(Stream s);
    string toString();
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
                     Pair!(string, 4), Pair!(Tup5, 5), Pair!(Tup6, 6)) members;
    
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
        switch(type) {
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
                case 5: m._5 = read!(short, byte, short)(s); break;
                case 6: m._6 = read!(int, int, int)(s); break;
                default: throw new ServerError("Invalid type in entity metadata.");
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
    byte[] nbt_data;
    
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
                ret.nbt_data = new byte[len];
                s.readExact(ret.nbt_data.ptr, len); // TODO: parsing into nbt
            }
        }
            
        return ret;
    }
    
    string toString() {
        string s = "Slot" ~ (has_array_position ? "_" ~ to!string(_slot) : "");
        
        return format(`%s(short block : "%s", byte item_count : "%s", short metadata : "%s", byte[] nbt_data : "%s"`,
                       s, item, item_count, metadata, nbt_data);
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
        
        size_t offset = 0;
        foreach(i; 0..16) {
            if(ret.chunk.primary_bitmask & 1 << i) {
                ubyte[] temp = unc_data[offset..offset+4096];
                
                foreach(j, block_id; temp) {
                    vec3i coords = coords_from_j(cast(uint)j, i);

                    ret.chunk.blocks[chunk.to_flat(coords)].id = block_id;
                }
                
                offset += 4096;
            }
        }
        
        foreach(f; TypeTuple!("metadata", "block_light", "sky_light")) {
            foreach(i; 0..16) {
                if(ret.chunk.primary_bitmask & 1 << i) { 
                    ubyte[] temp = unc_data[offset..offset+2048];
                    
                    for(uint j = 0; j < cast(uint)(temp.length); j++) {
                        ubyte dj = temp[j];
                        vec3i coords_m1 = coords_from_j(j, i);
                        vec3i coords_m2 = coords_from_j(++j, i);
                        
                        // NOTE: the data is maybe extracted in the wrong order, still big endian ...
                        mixin("ret.chunk.blocks[ret.chunk.to_flat(coords_m1)]." ~ f ~ " = dj & 0x0F;");
                        mixin("ret.chunk.blocks[ret.chunk.to_flat(coords_m2)]." ~ f ~ " = dj >> 4;");
                    }
                    
                    offset += 2048;
                }
            }
        }
                
        // skip add => last 256 bytes = biome_data
        if(ret.contiguous) {
            ret.chunk.biome_data = unc_data[$-256..$];
        }
                
        return ret;
    }
    
    string toString() {
        return format(`ChunkS(int x : "%d", int z : "%d", bool contiguous : "%s", ushort primary_bitmask : "%016b", `
                             `ushort add_bitmask : "%016b", Chunk chunk : "%s")`,
                              x, z, contiguous, primary_bitmask, add_bitmask, chunk);
    } 
}

struct MapChunkBulkS {
    static MapChunkBulkS recv(Stream s) {
        return MapChunkBulkS();
    }
}