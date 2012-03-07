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
    short block;
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
        
        ret.block = read!short(s);
        
        if(ret.block != -1) {
            ret.item_count = read!byte(s);
            ret.metadata = read!short(s);
        }
        
        if([0x103, 0x105, 0x15a, 0x167, // Flint&Steel, bow, fishing rod, shears
            // Tools:
            // sword, shovel, pickaxe, axe, hoe
            0x10C, 0x10D, 0x10E, 0x10F, 0x122, // wood
            0x110, 0x111, 0x112, 0x113, 0x123, // stone
            0x10B, 0x100, 0x101, 0x102, 0x124, // iron
            0x114, 0x115, 0x116, 0x117, 0x125, // diamond
            0x11B, 0x11C, 0x11D, 0x11E, 0x126, // gold
            // Armour:
            // helmet, chestplate, leggings, boots
            0x12A, 0x12B, 0x12C, 0x12D, // leather
            0x12E, 0x12F, 0x130, 0x131, // chain
            0x132, 0x133, 0x134, 0x135, // iron
            0x136, 0x137, 0x138, 0x139, // diamond 
            0x13A, 0x13B, 0x13C, 0x13D  // gold
            ].canFind(ret.block)) {
            int len = read!short(s);
                        
            if(len != -1) {
                ret.nbt_data = new byte[len];
                s.readExact(ret.nbt_data.ptr, len); // TODO: this could be still big endian
            }
        }
        
        return ret;
    }
    
    string toString() {
        string s = "Slot" ~ (has_array_position ? "_" ~ to!string(_slot) : "");
        
        return format(`%s(short block : "%s", byte item_count : "%s", short metadata : "%s", byte[] nbt_data : "%s"`,
                       s, block, item_count, metadata, nbt_data);
    }
}

struct Array(T, S) {
    alias T LenType;
    S[] arr;
    alias arr this;
}


struct ChunkS {
    int x;
    int z;
    bool contiguous;
    ushort primary_bitmask;
    ushort add_bitmask;
    Chunk chunk;
    ubyte[] biome_data;
    
    static ChunkS recv(Stream s) { // TODO: store data
        ChunkS ret;
        
        ret.x = read!int(s);
        ret.z = read!int(s);
        ret.contiguous = read!bool(s);
        ret.primary_bitmask = read!ushort(s);
        ret.add_bitmask = read!ushort(s);
        
        int len = read!int(s);
        read!int(s); // unused data
        
        ubyte[] compressed_data = new ubyte[len];
        s.readExact(compressed_data.ptr, len);
        ubyte[] unc_data = cast(ubyte[])uncompress(compressed_data);
        
        Chunk chunk = new Chunk(ret.x, ret.z);
        chunk.fill_chunk_with_nothing();
        
        size_t offset = 0;
        foreach(i; 0..16) {
            if(ret.primary_bitmask & 1 << i) {
                ubyte[] temp = unc_data[offset..offset+4096];
                
                foreach(j, block_id; temp) {
                    auto coords = coords_from_j(j, i);
                    
                    chunk.blocks[chunk.flat(coords.field)].id = block_id;
                }
                
                offset += 4096;
            }
        }
        
        foreach(f; TypeTuple!("metadata", "block_light", "sky_light")) {;
            foreach(i; 0..16) {
                if(ret.primary_bitmask & 1 << i) { 
                    ubyte[] temp = unc_data[offset..offset+2048];
                    
                    for(size_t j = 0; j < temp.length; j++) {
                        ubyte dj = temp[j];
                        auto coords_m1 = coords_from_j(j, i);
                        auto coords_m2 = coords_from_j(++j, i);
                        
                        mixin("chunk.blocks[chunk.flat(coords_m1.field)]." ~ f ~ " = dj & 0x0F;");
                        mixin("chunk.blocks[chunk.flat(coords_m2.field)]." ~ f ~ " = dj >> 4;");
                    }
                    
                    offset += 2048;
                }
            }
        }
        
        ret.chunk = chunk;
        
        // skip add => last 256 bytes = biome_data
        if(ret.contiguous) {
            ret.biome_data = unc_data[$-256..$];
        }
        
        return ret;
    }
    
//     string toString() { return ""; } 
}

