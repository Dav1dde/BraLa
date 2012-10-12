#!rdmd

private {
    import std.algorithm : map, filter, endsWith;
    import std.path : std_buildPath = buildPath, extension, setExtension, dirName;
    import std.array : join, split, appender;
    import std.process : shell, environment;
    import std.file : dirEntries, SpanMode, mkdirRecurse, FileException, exists, copy, remove;
    import std.stdio : writeln;
    import std.string : format;
    import std.parallelism : parallel;
    import std.exception : enforce;
}


// general stuff
version(DigitalMars) {
    enum LINKERFLAG = "-L";
    enum OUTPUT = "-of";
    enum VERSION = "-version=";
    enum DEBUG = "-debug -g -gc";
    enum DC = "dmd";
} else version(GNU) {
    enum LINKERFLAG = "-Xlinker ";
    enum OUTPUT = "-o ";
    enum VERSION = "-fversion=";
    enum DEBUG = "-fdebug -g";
    enum DC = "gdc";
} else version(LDC) {
    enum LINKERFLAG = "-L";
    enum OUTPUT = "-of";
    enum VERSION = "-d-version=";
    enum DEBUG = "-debug -g -gc";
    enum DC="ldc2";
} else version(SDC) {
    static assert(false, "This compiler is too awesome to compile BraLa");
} else {
    static assert(false, "Unsupported compiler");
}

version(Windows) {
    enum PATH_SEP = `\`;
    enum LDCFLAGS = "";
    enum OBJ = ".obj";
    enum DEFAULT_CC = "dmc";
    
} else {
    enum PATH_SEP = `/`;
    enum LDCFLAGS = "-ldl";
    enum OBJ = ".o";
    enum DEFAULT_CC = "gcc";
}

string ver(string[] names...) {
    return names.map!(x => VERSION ~ x).join(" ");
}

string buildPath(string[] paths...) {
    if(__ctfe) {
        return paths.join(PATH_SEP);
    } else {
        return std_buildPath(paths);
    }
}

// BraLa specific stuff


string CC;
string CFLAGS;
string C_OUTPUT;

string DFLAGS;
string DCFLAGS_LINK;
string DCFLAGS_IMPORT;

static this() {
    CC = environment.get("CC", DEFAULT_CC);
    CFLAGS = environment.get("CFLAGS", "");
    C_OUTPUT = CC == "dmc" ? "-o" : "-o ";
    
    DFLAGS = make_d_flags();
    DCFLAGS_LINK = make_dcflags_link();
    DCFLAGS_IMPORT = make_dcflags_import();
}


enum DBUILD_PATH = buildPath("build");
enum CBUILD_PATH = buildPath("build");

struct BuildPath {
    string path;
    alias path this;
    SpanMode mode;
}

enum BuildPath[] D_PATHS = [{buildPath("brala"),                                                  SpanMode.breadth},
                            {buildPath("src", "d", "arsd"),                                       SpanMode.breadth},
                            {buildPath("src", "d", "derelict3", "import", "derelict", "opengl3"), SpanMode.breadth},
                            {buildPath("src", "d", "derelict3", "import", "derelict", "glfw3"),   SpanMode.breadth},
                            {buildPath("src", "d", "derelict3", "import", "derelict", "util"),    SpanMode.breadth},
                            {buildPath("src", "d", "gl3n", "gl3n"),                               SpanMode.breadth},
                            {buildPath("src", "d", "glamour", "glamour"),                         SpanMode.breadth},
                            {buildPath("src", "d", "openssl"),                                    SpanMode.breadth},
                            {buildPath("src", "d", "std"),                                        SpanMode.breadth},
                            {buildPath("src", "d", "nbd"),                                        SpanMode.shallow}];

enum BuildPath[] C_PATHS = [{buildPath(".", "src", "c"), SpanMode.shallow}];


string make_d_flags() {
    version(Windows) {
        enum DFLAGS = [ver("Derelict3", "DynamicGLFW", "gl3n", "stb"), DEBUG].join(" ");
    } else {
        enum DFLAGS = [ver("Derelict3", "gl3n", "stb"), DEBUG].join(" ");
    }
    return DFLAGS;
}

string make_dcflags_link() {
    version(Windows) {
        setup_openssl();
        
        return ["libssl32.lib", "libeay32.lib"].join(" ");
    } else {
        string pkg_cfg_path = environment.get("PKG_CONFIG_PATH", "");
        environment["PKG_CONFIG_PATH"] = buildPath(".", "build", "glfw", "src");

        string[] glfw_link = shell(`pkg-config --static --libs glfw3`).split();

        environment["PKG_CONFIG_PATH"] = pkg_cfg_path;

        string[] DCFLAGS_LINK_RAW = [LDCFLAGS, "-lssl", "-lcrypto", "-Lbuild/glfw/src"] ~ glfw_link;
        return DCFLAGS_LINK_RAW.map!(x => LINKERFLAG ~ x).join(" ");
    }

    
}

void setup_openssl() {
    string drive = environment["SystemDrive"];
    string system_root = environment["SystemRoot"];

    string openssl_path = buildPath(drive, "OpenSSL-Win32");
    if(!openssl_path.exists()) {
        openssl_path = buildPath(system_root, "system32");
    }

    string libssl = buildPath(openssl_path, "libssl32.dll");
    string libeay = buildPath(openssl_path, "libeay32.dll");

    enforce(libssl.exists(), "can't find libssl, install openssl");
    enforce(libeay.exists(), "can't find libeay, install openssl");

    // access denied: LOL
//     copy(libssl, "."); 
//     copy(libeay, ".");

    // crazy windows
    shell("copy %s .".format(libssl));
    shell("copy %s .".format(libeay));

    shell("implib /s libssl32.lib libssl32.dll");
    shell("implib /s libeay32.lib libeay32.dll");

    //remove("libssl32.dll");
    //remove("libeay32.dll");    
}

string make_dcflags_import() {
    immutable string[] paths = [buildPath("brala"),
                                buildPath("src", "d", "derelict3", "import"),
                                buildPath("src", "d", "glamour"),
                                buildPath("src", "d", "gl3n"),
                                buildPath("src", "d"),
                                buildPath("src", "d", "openssl"),
                                buildPath("src", "d", "glfw"),
                                buildPath("src", "d", "nbd")];

    return paths.map!(x => "-I" ~ x).join(" ");
}


string[] find_files(BuildPath[] paths, string ext) {
    auto app = appender!(string[])();

    foreach(path; paths) {
        app.put(dirEntries(path, path.mode).filter!(e => e.name.extension == ext));
    }

    return app.data;
}

void make_folders(string prefix, string[] paths) {
    foreach(path; paths) {
        try {
            mkdirRecurse(buildPath(prefix, path.dirName()));
        } catch(FileException e) {
            //assert(e.msg.endsWith("File exists"), e.msg);
        }
    }
}


string[] d_compile(string prefix, string[] files) {
    auto app = appender!(string[])();
    
    foreach(file; parallel(files)) {
//     foreach(file; files) {
        string build_path = buildPath(prefix, file).setExtension(OBJ);

        string cmd = "%s %s %s -c %s %s%s".format(DC, DFLAGS, DCFLAGS_IMPORT, file, OUTPUT, build_path);
        writeln(cmd);
        shell(cmd);

        app.put(build_path);
    }

    return app.data;
}


string[] c_compile(string prefix, string[] files) {
    auto app = appender!(string[])();

    foreach(file; parallel(files)) {
//     foreach(file; files) {
        string build_path = buildPath(prefix, file).setExtension(OBJ);

        string cmd = "%s %s -c %s %s%s".format(CC, CFLAGS, file, C_OUTPUT, build_path);
        writeln(cmd);
        shell(cmd);

        app.put(build_path);
    }

    return app.data;
}

void link(string[] d_files, string[] c_files, string exe) {
    string[] all_files = d_files ~ c_files;

    string cmd = "%s %s %s %s%s".format(DC, DCFLAGS_LINK, all_files.join(" "), OUTPUT, exe);
    writeln(cmd);
    shell(cmd);
}


void main() {
    string[] d_files = find_files(D_PATHS, ".d");
    string[] c_files = find_files(C_PATHS, ".c");
    
    make_folders(DBUILD_PATH, d_files);
    make_folders(CBUILD_PATH, c_files);

    string[] d_obj = d_compile(DBUILD_PATH, d_files);
    string[] c_obj = c_compile(CBUILD_PATH, c_files);

    link(d_obj, c_obj, "bralad");
}