#!rdmd

private {
    import std.algorithm : max, map, filter, endsWith, canFind;
    import std.path : buildPath, extension, setExtension, dirName, baseName, getcwd, chdir;
    import std.array : join, split, appender, array;
    import std.process : shell, system, environment;
    import std.file : dirEntries, SpanMode, mkdirRecurse, rmdirRecurse, FileException, exists, copy, remove, readText, write;
    import std.stdio : writeln, writefln, File;
    import std.string : format, stripRight;
    import std.parallelism : TaskPool;
    import std.exception : enforce, collectException;
    import std.getopt;
    import std.digest.md;
    import std.digest.digest;
    import core.time : dur;

    version(NoDownload) {
    } else {
        pragma(lib, "curl");
        import std.net.curl : download, HTTP, CurlOption;
    }

    version(linux) {
        import std.path : symlink;
    }
}

version(Windows) {
    enum OBJ = ".obj";
    enum SO = ".dll";
    enum SO_LINK = ".lib";
} else version(linux) {
    enum OBJ = ".o";
    enum SO = ".so";
    enum SO_LINK = "";
} else version(OSX) {
    enum OBJ = ".o";
    enum SO = ".dylib";
    enum SO_LINK = "";
}


alias filter!("a.length > 0") filter0;

bool is32bit() {
    return is(uint == size_t);
}
unittest {
    if(is32bit()) {
        assert(!is(ulong == size_t));
    } else {
        assert(is(ulong == size_t));
    }
}

abstract class Compiler {
    string build_prefix;
    string[] import_paths;
    string[] additional_flags;

    @property string import_flags() {
        return filter0(import_paths).map!(x => "-I" ~ x).join(" ");
    }

    @property string compiling_ext() { throw new Exception("Not Implemented"); }
    void compile(string prefix, string file) { throw new Exception("Not Implemented"); }

    string version_(string ver) { throw new Exception("Not Implemented"); }
    @property string debug_() { throw new Exception("Not Implemented"); }
    @property string debug_info() { throw new Exception("Not Implemented"); }

    @property string compiler() { throw new Exception("Not Implemented"); }

    bool is_available() {
        return system("%s -v".format(compiler)) == 0;
    }
}

class DCompiler : Compiler {
    override @property string compiling_ext() {
        return ".d";
    }
}

class CCompiler : Compiler {
    override @property string compiling_ext() {
        return ".c";
    }
}


interface Linker {
    void link(string, string[], string[], string[]);
}

class DMD : DCompiler, Linker {
    override string version_(string ver) {
        return "-version=" ~ ver;
    }
    override @property string debug_() { return "-debug"; }
    override @property string debug_info() { return "-g -gc"; }
    override @property string compiler() { return "dmd"; }
    
    override void compile(string src, string dest) {
        string cmd = "dmd %s %s -c %s -of%s".format(import_flags, filter0(additional_flags).join(" "), src, dest);
        writeln(cmd);
        shell(cmd);
    }

    void link(string out_path, string[] object_files, string[] libraries, string[] options) {
        enum LF = "-L";
        version(Windows) {
            enum LLF = "";
        } else {
            enum LLF = "-L-l";
        }
        
        string cmd = "dmd %s %s %s -of%s".format(
                        object_files.join(" "),
                        filter0(libraries).map!(x => LLF ~ x).join(" "),
                        filter0(options).map!(x => LF ~ x).join(" "),
                        out_path);

        writeln(cmd);
        shell(cmd);
    }
}

// GDC: "-fdebug -g";
// LDC: "-debug -g -gc";

class GDC : DCompiler {
}

class LDC : DCompiler {
}

class DMC : CCompiler {
    override @property string compiler() { return "dmc"; }
    override void compile(string src, string dest) {
        string cmd = "dmc %s %s -c %s -o%s".format(import_flags, filter0(additional_flags).join(" "), src, dest);
        writeln(cmd);
        shell(cmd);
    }
}

class GCC : CCompiler {
    override @property string compiler() { return "gcc"; }
    override void compile(string src, string dest) {
        string cmd = "gcc %s %s -c %s -o %s".format(import_flags, filter0(additional_flags).join(" "), src, dest);
        writeln(cmd);
        shell(cmd);
    }
}

interface Cache {
    bool is_cached(string src, string dest);
    void add_file_to_cache(string file);
}

class NoCache : Cache {
    bool is_cached(string src, string dest) { return false; }
    void add_file_to_cache(string file) {}
}

class MD5Cache : Cache {
    string[string] cache;

    this()() {}

    this(T)(T c) if(is(T : string) || is(T : File) || is(T : string[])) {
        load(c);
    }

    void load(string cache_file) {
        if(cache_file.exists()) {
            File f = File(cache_file, "r");
            scope(exit) f.close();

            load(f);
        }
    }

    void load(File cache_file) {
        _add_to_cache(cache_file.byLine());
    }

    void load(string[] cache_file) {
        _add_to_cache(cache_file);
    }

    private void _add_to_cache(T)(T iter) {
        foreach(raw_line; iter) {
            if(!raw_line.length) {
                continue;
            }

            static if(!is(typeof(line) : string)) {
                string line = raw_line.idup;
            } else {
                alias raw_line line;
            }
            
            string hash = line.split()[$-1];
            string file = line[0..$-hash.length].stripRight();

            cache[file] = hash;
        }
    }

    void add_file_to_cache(string file) {
        cache[file] = MD5Cache.hexdigest_from_file(file);
    }

    bool is_cached(string src, string dest) {
        if(src in cache && dest.exists()) {
            string hexdigest = MD5Cache.hexdigest_from_file(src);

            return cache[src] == hexdigest;
        }

        return false;
    }

    void save(string file) {
        File f = File(file, "w");
        scope(exit) f.close();

        save(f);
    }

    void save(File file) {
        foreach(k, v; cache) {
            file.writefln("%s %s", k, v);
        }
    }

    static string hexdigest_from_file(Hash = MD5)(string file) {
        File f = File(file, "r");
        scope(exit) f.close();

        return hexdigest_from_file!(Hash)(f);
    }

    static string hexdigest_from_file(Hash = MD5)(File file) {
        auto b = file.byChunk(4096 * 1024);
        return hexDigest!Hash(b).idup;
    }
}


struct ScanPath {
    string path;
    alias path this;
    SpanMode mode;
}

class Builder {
    ScanPath[] scan_paths;
    protected string[] _object_files;
    @property string[] object_files() { return _object_files; }

    protected Compiler[string] compiler;
    Linker linker;
    Cache cache;
    
    string out_path;
    string out_file;

    @property string[] library_paths() {
        version(Windows) {
            return [buildPath("lib", "win"), buildPath("lib", "win%s".format(is32bit() ? "32" : "64"))];
        } else version(linux) {
            return [buildPath("lib", "linux"), buildPath("lib", "linux%s".format(is32bit() ? "32" : "64"))];
        } else version(OSX) {
            return [buildPath("lib", "osx"), buildPath("lib", "osx%s".format(is32bit() ? "32" : "64"))];
        }
    }

    string[] libraries_win;
    string[] libraries_win32;
    string[] libraries_win64;
    string[] libraries_linux;
    string[] libraries_linux32;
    string[] libraries_linux64;
    string[] libraries_osx;
    string[] libraries_osx32;
    string[] libraries_osx64;

    @property string[] libraries() {
        version(Windows) {
            static if(is32bit()) {
                return libraries_win ~ libraries_win32;
            } else {
                return libraries_win ~ libraries_win64;
            }
        } else version(linux) {
            static if(is32bit()) {
                return libraries_linux ~ libraries_linux32;
            } else {
                return libraries_linux ~ libraries_linux64;
            }
        } else version(OSX) {
            static if(is32bit()) {
                return libraries_osx ~ libraries_osx32;
            } else {
                return libraries_osx ~ libraries_osx64;
            }
        }
    }

    string[] linker_options_win;
    string[] linker_options_win32;
    string[] linker_options_win64;
    string[] linker_options_linux;
    string[] linker_options_linux32;
    string[] linker_options_linux64;
    string[] linker_options_osx;
    string[] linker_options_osx32;
    string[] linker_options_osx64;

    @property string[] linker_options() {
        version(Windows) {
            static if(is32bit()) {
                return linker_options_win ~ linker_options_win32;
            } else {
                return linker_options_win ~ linker_options_win64;
            }
        } else version(linux) {
            static if(is32bit()) {
                return linker_options_linux ~ linker_options_linux32;
            } else {
                return linker_options_linux ~ linker_options_linux64;
            }
        } else version(OSX) {
            static if(is32bit()) {
                return linker_options_osx ~ linker_options_osx32;
            } else {
                return linker_options_osx ~ linker_options_osx64;
            }
        }
    }

    string build_prefix;

    this() {
        // TODO: implement find_compiler
        version(Windows) {
            auto dc = new DMD();
            auto cc = new DMC();
            this(new NoCache(), dc, dc, cc);
        } else {
            auto dc = new DMD();
            auto cc = new GCC();
            this(new NoCache(), dc, dc, cc);
        }
    }

    this(Cache cache, Linker linker, Compiler[] compiler...) {
        this.cache = cache;
        this.linker = linker;

        foreach(c; compiler) {
            this.compiler[c.compiling_ext] = c;
        }
    }

    void add_scan_path(string path, SpanMode mode = SpanMode.breadth) {
        scan_paths ~= ScanPath(path, mode);
    }
    void add_scan_path(ScanPath scan_path) {
        scan_paths ~= scan_path;
    }

    void compile(TaskPool task_pool=null) {
        foreach(path; scan_paths) {
            auto files = map!(x => x.name)(filter!(e => compiler.keys.canFind(e.name.extension))(dirEntries(path, path.mode))).array();

            enum foreach_body = "collectException(mkdirRecurse(buildPath(build_prefix, file.dirName())));
                                 Compiler compiler = this.compiler[file.extension];
                                 string dest = buildPath(build_prefix, file).setExtension(OBJ);
                                 if(!cache.is_cached(file, dest)) {
                                     compiler.compile(file, dest);
                                     cache.add_file_to_cache(file);
                                 }
                                 _object_files ~= dest;";

            if(task_pool is null) {
                foreach(file; files) {
                    mixin(foreach_body);
                }
            } else {
                size_t work_units = max(files.length / task_pool.size, 1);
                
                foreach(file; task_pool.parallel(files, work_units)) {
                    mixin(foreach_body);
                }
            }
        }
    }

    void link() {
        linker.link(buildPath(out_path, out_file), _object_files, libraries, linker_options);
    }
}


string[] glfw_libraries() {
    version(Windows) {
        return [];
    } else {
        string pkg_cfg_path = environment.get("PKG_CONFIG_PATH", "");
        environment["PKG_CONFIG_PATH"] = buildPath("build", "glfw", "src");

        string[] result;
        try {
            result = shell(`pkg-config --static --libs glfw3`).split();
        } finally {
            environment["PKG_CONFIG_PATH"] = pkg_cfg_path;
        }

        return result;
    }
}

int main(string[] args) {
    size_t jobs = 1;
    string cache_file = ".build_cache";
    bool no_cache = false;
    bool override_cache = false;
    getopt(args, "jobs|j", &jobs,
                 "cache|c", &cache_file,
                 "no-cache", &no_cache,
                 "override-cache|o", &override_cache);
    enforce(jobs >= 1, "Jobs can't be 0 or negative");

    TaskPool task_pool;
    if(jobs > 1) {
        task_pool = new TaskPool(jobs);
    }
    scope(exit) { if(task_pool !is null) task_pool.finish(); }

    MD5Cache md5_cache = new MD5Cache();
    if(!override_cache) {
        md5_cache.load(cache_file);
    }
    
    Cache cache;
    if(no_cache) {
        cache = new NoCache();
    } else {
        cache = md5_cache;
    }

    version(Windows) {
        auto cc = new DMC();
    } else {
        auto cc = new GCC();
    }

    version(DigitalMars) {
        auto dc = new DMD();
    } else version(GNU) {
        auto dc = new GDC();
    } else version(LDC) {
        auto dc = new LDC();
    } else version(SDC) {
        static assert(false, "This compiler is too awesome to compile BraLa at the moment");
    } else {
        static assert(false, "Unsupported compiler");
    }

    dc.additional_flags = [dc.version_("Derelict3"), dc.version_("gl3n"), dc.version_("stb"),
                           dc.version_("glamour"), dc.debug_, dc.debug_info];
    
    dc.import_paths = [buildPath("brala"),
                       buildPath("src", "d", "derelict3", "import"),
                       buildPath("src", "d", "glamour"),
                       buildPath("src", "d", "gl3n"),
                       buildPath("src", "d"),
                       buildPath("src", "d", "openssl"),
                       buildPath("src", "d", "glfw"),
                       buildPath("src", "d", "nbd"),
                       buildPath("src", "d", "glwtf")];

    auto builder = new Builder(cache, dc, dc, cc);

    builder.out_path = buildPath("bin");
    builder.out_file = "bralad";
    builder.build_prefix = buildPath("build");
    
    builder.add_scan_path(buildPath("brala"));
    builder.add_scan_path(buildPath("src", "d", "arsd"));
    builder.add_scan_path(buildPath("src", "d", "derelict3", "import", "derelict", "opengl3"));
    builder.add_scan_path(buildPath("src", "d", "derelict3", "import", "derelict", "glfw3"));
    builder.add_scan_path(buildPath("src", "d", "derelict3", "import", "derelict", "util"));
    builder.add_scan_path(buildPath("src", "d", "gl3n", "gl3n"));
    builder.add_scan_path(buildPath("src", "d", "glamour", "glamour"));
    builder.add_scan_path(buildPath("src", "d", "glwtf", "glwtf"));
    builder.add_scan_path(buildPath("src", "d", "nbd"), SpanMode.shallow);
    builder.add_scan_path(buildPath("src", "d", "openssl"));
    builder.add_scan_path(buildPath("src", "c"), SpanMode.shallow);

    builder.libraries_win = [buildPath("lib", "win", "libssl32.lib"),
                             buildPath("lib", "win", "libeay32.lib"),
                             buildPath("lib", "win", "glfw3.lib")];
    builder.linker_options_win = [];

    builder.libraries_linux = ["ssl", "crypto", "dl"];
    builder.linker_options_linux = ["-Lbuild/glfw/src"];
    builder.linker_options_linux ~= glfw_libraries();
    builder.linker_options_linux32 ~= ["-Llib/linux32"];
    builder.linker_options_linux64 ~= ["-Llib/linux64"];

    builder.libraries_osx = builder.libraries_linux;
    builder.linker_options_osx = builder.linker_options_linux;
    builder.linker_options_osx ~= ["-Llib/osx"];

    collectException(rmdirRecurse(builder.out_file));

    builder.compile(task_pool);
    builder.link();

    md5_cache.save(cache_file);

    // executable is linked, now copy the .dll/.so over to the executable
    // using -rpath on linux/osx, no need for copying
    version(Windows) {
        foreach(path; builder.library_paths) {
            if(!path.exists) continue;

            foreach(file; filter!(x => x.extension == SO)(dirEntries(path, SpanMode.depth))) {
                copy(file, buildPath("bin", file.baseName));
            }
        }
    }

    return 0;
}