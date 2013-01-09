#!rdmd

private {
    import std.algorithm : map, filter, endsWith, canFind;
    import std.path : buildPath, extension, setExtension, dirName, baseName;
    import std.array : join, split, appender, array;
    import std.process : shell, environment;
    import std.file : dirEntries, SpanMode, mkdirRecurse, FileException, exists, copy, remove, readText, write;
    import std.stdio : writeln, File;
    import std.string : format, stripRight;
    import std.parallelism : parallel;
    import std.exception : enforce;
    import std.md5;
}

version(Windows) {
    enum OBJ = ".obj";
} else {
    enum OBJ = ".o";
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
    string compile(string prefix, string file) { throw new Exception("Not Implemented"); }

    string version_(string ver) { throw new Exception("Not Implemented"); }
    @property string debug_() { throw new Exception("Not Implemented"); }
    @property string debug_info() { throw new Exception("Not Implemented"); }
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
    
    override string compile(string prefix, string file) {
        string out_path = buildPath(prefix, file).setExtension(OBJ);
        
        string cmd = "dmd %s %s -c %s -of%s".format(import_flags, filter0(additional_flags).join(" "), file, out_path);
        writeln(cmd);
        shell(cmd);

        return out_path;
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
    override string compile(string prefix, string file) {
        string out_path = buildPath(prefix, file).setExtension(OBJ);

        string cmd = "dmc %s %s -c %s -o%s".format(import_flags, filter0(additional_flags).join(" "), file, out_path);
        writeln(cmd);
        shell(cmd);

        return out_path;
    }
}

class GCC : CCompiler {
    override string compile(string prefix, string file) {
        string out_path = buildPath(prefix, file).setExtension(OBJ);

        string cmd = "gcc %s %s -c %s -o %s".format(import_flags, filter0(additional_flags).join(" "), file, out_path);
        writeln(cmd);
        shell(cmd);

        return out_path;
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
    
    @property string lib_path() {
        version(Windows) {
            return lib_path_windows;
        } else version(linux) {
            return lib_path_linux;
        } else version(OSX) {
            return lib_path_osx;
        }
    }

    @property string lib_path_windows() {
        return buildPath("lib", "win32");
    }

    @property string lib_path_linux() {
        return buildPath("lib", "linux%s".format(is32bit() ? "32" : "64"));
    }

    @property string lib_path_osx() {
        return buildPath("lib", "osx32");
    }

    string out_path;

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
    string[] linker_options_linux;
    string[] linker_options_osx;

    @property string[] linker_options() {
        version(Windows) {
            return linker_options_win;
        } else version(linux) {
            return linker_options_linux;
        } else version(OSX) {
            return linker_options_osx;
        }
    }

    string build_prefix;

    this() {
        // TODO: implement find_compiler
        version(Windows) {
            auto dc = new DMD();
            auto cc = new DMC();
            this(dc, dc, cc);
        } else {
            auto dc = new DMD();
            auto cc = new GCC();
            this(dc, dc, cc);
        }
    }

    this(Linker linker, Compiler[] compiler...) {
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

    void compile() {
        foreach(path; scan_paths) {
            auto files = map!(x => x.name)(filter!(e => compiler.keys.canFind(e.name.extension))(dirEntries(path, path.mode)));
            foreach(file; files) {
                try {
                    mkdirRecurse(buildPath(build_prefix, file.dirName()));
                } catch(FileException e) {}
                
                Compiler compiler = this.compiler[file.extension];

                _object_files ~= compiler.compile(build_prefix, file);
            }
        }
    }

    void link() {
        linker.link(out_path, _object_files, libraries, linker_options);
    }
}


string[] glfw_libraries() {
    version(Windows) {
        return [];
    } else {
        string pkg_cfg_path = environment.get("PKG_CONFIG_PATH", "");
        environment["PKG_CONFIG_PATH"] = buildPath("build", "glfw", "src");
        scope(exit) environment["PKG_CONFIG_PATH"] = pkg_cfg_path;

        return shell(`pkg-config --static --libs glfw3`).split();
    }
}


void main() {
    version(Windows) {
        auto cc = new DMC();
    } else {
        auto cc = new GCC();
    }
    auto dc = new DMD();

    dc.additional_flags = [dc.version_("Derelict3"), dc.version_("gl3n"), dc.version_("stb"),
                           dc.debug_, dc.debug_info];
    
    dc.import_paths = [buildPath("brala"),
                       buildPath("src", "d", "derelict3", "import"),
                       buildPath("src", "d", "glamour"),
                       buildPath("src", "d", "gl3n"),
                       buildPath("src", "d"),
                       buildPath("src", "d", "openssl"),
                       buildPath("src", "d", "glfw"),
                       buildPath("src", "d", "nbd"),
                       buildPath("src", "d", "glwtf")];

    auto builder = new Builder(dc, dc, cc);

    builder.out_path = buildPath("bin", "brala");
    builder.build_prefix = buildPath("build");
    
    builder.add_scan_path(buildPath("brala"));
    builder.add_scan_path(buildPath("src", "d", "arsd"));
    builder.add_scan_path(buildPath("src", "d", "derelict3", "import", "derelict", "opengl3"));
    builder.add_scan_path(buildPath("src", "d", "derelict3", "import", "derelict", "glfw3"));
    builder.add_scan_path(buildPath("src", "d", "derelict3", "import", "derelict", "util"));
    builder.add_scan_path(buildPath("src", "d", "gl3n", "gl3n"));
    builder.add_scan_path(buildPath("src", "d", "glamour", "glamour"));
    builder.add_scan_path(buildPath("src", "d", "openssl"));
    builder.add_scan_path(buildPath("src", "d", "std"));
    builder.add_scan_path(buildPath("src", "d", "nbd"), SpanMode.shallow);
    builder.add_scan_path(buildPath("src", "d", "glwtf", "glwtf"));
    builder.add_scan_path(buildPath("src", "c"), SpanMode.shallow);

    builder.libraries_win = [buildPath("lib", "windows", "libssl32.lib"),
                             buildPath("lib", "windows", "libeay32.lib"),
                             buildPath("lib", "windows", "glfw3.lib")];
    builder.linker_options_win = [];

    builder.libraries_linux = ["ssl", "crypto"];
    builder.linker_options_linux = ["-Lbuild/glfw/src"];
    builder.linker_options_linux ~= glfw_libraries();

    builder.libraries_osx = builder.libraries_linux;
    builder.linker_options_osx = builder.linker_options_linux;

    builder.compile();
    builder.link();
}