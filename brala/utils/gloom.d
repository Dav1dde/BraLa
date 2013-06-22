module brala.utils.gloom;

private {
    import std.stdio : File;
    import std.exception : enforce;
    import std.algorithm : map, filter, startsWith, endsWith;
    import std.range : isInputRange, refRange;
    import std.string : split, strip;
    import std.typecons : Tuple;
    import std.array : array;
    import std.conv : to;
}

private auto to_triangles(T)(T quad) {
    return [quad[0], quad[1], quad[2],
            quad[0], quad[2], quad[3]];
}

// Yo D you suck, y u no print tuple without segfault?
// alias Tup = Tuple!(string, "name", size_t, "size");
struct Tup {
    string name;
    size_t size;
}

struct Gloom {
    size_t count;
    size_t stride;
    Tup[] names;
    float[] vertices;
}


Gloom parse_gloom(T)(T data_) if(isInputRange!T) {
    auto dataR = data_.map!(strip).filter!("a.length > 0").filter!(x => !x.startsWith('#'));
    auto data = refRange(&dataR);

    auto vertex = data.front().split();
    enforce(vertex[0] == "vertex:", "Invalid gloom file");

    Gloom ret;

    foreach(info; vertex[1..$].map!(x => x.split(":"))) {
        ret.names ~= Tup(info[0].idup, to!int(info[1]));
        ret.stride += to!int(info[1]);
    }

    data.popFront();

    bool index;
    float[] vertices;
    foreach(line; data) {
        auto sline = line.split();

        if(sline[0].endsWith(":")) {
            index = true;

            data.popFront();
            break;
        }
        ret.count++;

        vertices ~= sline.map!(to!float).array();
    }

    if(index) {
        ret.count = 0;

        float[] vertices_new;

        foreach(line; data) {
            ret.count++;

            auto sline = line.split().map!(to!int);

            auto indices = sline[1..4].array();
            if(sline[0] == 4) {
                ret.count++;
                indices = to_triangles(sline[1..5]);
            }

            foreach(i; indices) {
                vertices_new ~= vertices[i];
            }
        }

        vertices = vertices_new;
    }

    ret.vertices = vertices;

    return ret;
}

auto parse_gloom_file(string path) {
    auto f = File(path);
    scope(exit) f.close();

    return parse_gloom(f.byLine());
}