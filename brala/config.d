module brala.config;

private {
    version(DynamicGLFW) { import derelict.glfw3.glfw3; } else { import deimos.glfw.glfw3; }

    import std.algorithm : map;
    import std.path : buildPath;
    import std.range : zip;
    import std.array : join;
    
    import brala.resmgr;
    import brala.utils.dargs : get_options, Alias;
}

enum {
    MOVE_FORWARD = GLFW_KEY_W,
    MOVE_BACKWARD = GLFW_KEY_S,
    STRAFE_LEFT = GLFW_KEY_A,
    STRAFE_RIGHT = GLFW_KEY_D,
}

struct AppArguments {
    string username;
    Alias!("username") u;

    string password;
    Alias!("password") p;

    bool credentials;
    Alias!("credentials") c;

    uint width = 1024;
    uint height = 800;

    string host;
    Alias!("host") h;
    ushort port = 25565;

    string res = "";

    bool no_snoop = false;
    size_t tessellation_threads = 3;

    bool default_tp = false;

    void help(string[] args, string[][] p) {
        string[] help_strings = [
            "specifies the username, which will be used to auth with the login servers,\n" ~
            "\t\t\t\tif this is not possible and the server is in offline mode, it will be used\n" ~
            "\t\t\t\tas playername",

            "the password which is used to authenticate with the login servers, set this\n" ~
            "\t\t\t\tto a random value if you don't want to authenticate with the servers",

            "uses minecrafts lastlogin file for authentication and logging in,\n" ~
            "\t\t\t\t--username and --password are used as fallback",

            "\t\tspecifies the width of the window",

            "\tspecifies the height of the window",

            "\tthe IP/adress of the minecraft server",

            "\t\tthe port of the minecraft server, defaults to 25565",

            "\t\tpath to the resources folder, named \"res\"",

            "\tdisables \"snooping\" (= sending completly anonym information to mojang)",

            "specifies the number of threads used to tessellate the terrain, defaults to 3.\n" ~
            "\t\t\t\tMore threads: more used memory (each thread needs his own tessellation-buffer),\n" ~
            "\t\t\t\tmore CPU usage, but faster terrain tessellation",

            "\ttry to extract the minecraft terrain.png from the installed minecraft.jar"

            "\t\tshows this help"
        ];

        writefln("%s [options]", args[0]);

        foreach(d; zip(p, help_strings)) {
            writefln("\t--%s\t%s", d[0].join("\t-"), d[1]);
        }
    }
}

private AppArguments _app_arguments;
@property AppArguments app_arguments() {
    static bool parsed = false;

    if(!parsed) {
        _app_arguments = get_options!AppArguments();
    }

    return _app_arguments;
}


immutable Resource[] resources;

static this() {
    resources = [Resource("terrain",    buildPath("res", "shader", "terrain.shader"),  SHADER_TYPE),
                 Resource("terrain",    buildPath("res", "texture", "terrain.png"),    IMAGE_TYPE),
                 Resource("grasscolor", buildPath("res", "texture", "grasscolor.png"), IMAGE_TYPE),
                 Resource("leavecolor", buildPath("res", "texture", "leavecolor.png"), IMAGE_TYPE),
                 Resource("watercolor", buildPath("res", "texture", "watercolor.png"), IMAGE_TYPE)];

}

void load_default_resources(ResourceManager rsmg, string prefix = "") {
    rsmg.add_many(resources.map!(x => Resource(x.id, buildPath(prefix, x.filename), x.type)));
}