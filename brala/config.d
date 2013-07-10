module brala.config;

private {
    import glwtf.glfw;

    import std.algorithm : map;
    import std.path : buildPath, absolutePath, buildNormalizedPath, isAbsolute;
    import std.range : zip;
    import std.array : join;
    
    import brala.minecraft.lastlogin : minecraft_credentials;
    import brala.minecraft.profiles : current_profile;
    import brala.utils.dargs : get_options, Alias;
    import brala.utils.config : Config, Path;
    
    import std.stdio : writefln;
}

struct AppArguments {
    version(Windows) {
        string brala_conf = `brala.conf`;
    } else {
        string brala_conf = `brala.conf`;
    }

    string username;
    Alias!("username") u;

    string password;
    Alias!("password") p;

    bool credentials;
    Alias!("credentials") c;

    string session;

    bool auto_session;
    Alias!("auto_session") a;

    bool offline;

    uint width = 0;
    uint height = 0;

    bool not_resizable = false;

    string renderer;

    string host;
    Alias!("host") h;
    ushort port = 0;

    string res = "./res";

    bool no_snoop = false;
    size_t tessellation_threads = 0;

    string texture_pack;

    void help(string[] args, string[][] p) {
        string[] help_strings = [
            "\tthe path to brala.conf, relativ to \"res\" or absolute",
            
            "specifies the username, which will be used to auth with the login servers,\n" ~
            "\t\t\t\tif this is not possible and the server is in offline mode, it will be used\n" ~
            "\t\t\t\tas playername",

            "the password which is used to authenticate with the login servers, set this\n" ~
            "\t\t\t\tto a random value if you don't want to authenticate with the servers",

            "uses minecrafts lastlogin file for authentication and logging in,\n" ~
            "\t\t\t\t--username and --password are used as fallback",

            "\tuses the supplied session to login to minecraft, this requires --username",

            "tries to use launcher_profiles.json to extract session key",

            "\tstart in offline mode",

            "\t\tspecifies the width of the window",

            "\tspecifies the height of the window",

            "\twindow should not be resizable",

            "\tSpecify default renderer for BraLa, either deferred or forward",

            "\tthe IP/adress of the minecraft server",

            "\t\tthe port of the minecraft server, defaults to 25565",

            "\t\tpath to the resources folder, named \"res\"",

            "\tdisables \"snooping\" (= sending completly anonym information to mojang)",

            "specifies the number of threads used to tessellate the terrain, defaults to 3.\n" ~
            "\t\t\t\tMore threads: more used memory (each thread needs his own tessellation-buffer),\n" ~
            "\t\t\t\tmore CPU usage, but faster terrain tessellation",

            "\tPath to texture pack, if none specified defaults to config or tries to find minecraft.jar",

            "\t\tshows this help"
        ];

        writefln("%s [options]", args[0]);

        foreach(d; zip(p, help_strings)) {
            writefln("\t--%s\t%s", d[0].join("\t-"), d[1]);
        }
    }
}

private static AppArguments _app_arguments;
@property AppArguments app_arguments() {
    static bool parsed = false;

    if(!parsed) {
        _app_arguments = get_options!AppArguments();
    }

    return _app_arguments;
}

Config initialize_config() {
    auto config = new Config();
    config.dont_save = ["account.password"];

    string config_path;
    if(app_arguments.brala_conf.isAbsolute()) {
        config_path = app_arguments.brala_conf;
    } else {
        config_path = buildPath(app_arguments.res, app_arguments.brala_conf);
    }
    config.read(config_path);

    config.set_if("path.res", app_arguments.res.absolutePath().buildNormalizedPath());

    config.set_default("account.credentials", false);
    config.set_if("account.credentials", app_arguments.credentials);
    config.set_if("account.username", app_arguments.username);
    config.set_if("account.password", app_arguments.password);

    if(config.get!bool("account.credentials")) {
        auto credentials = minecraft_credentials();

        config.set_if("account.username", credentials.username);
        config.set_if("account.password", credentials.password);
    }

    config.set_if("account.session", app_arguments.session);

    if(!config.has_key!string("account.session") && app_arguments.auto_session) {
        auto profile = current_profile();

        config.set_if("account.session", profile.session);
        config.set_if("account.username", profile.authentication["displayName"]);
        config.set_if("account.realusername", profile.authentication["username"]);
    }

    config.set("connection.offline", app_arguments.offline);

    config.set_default("window.width", 1024);
    config.set_default("window.height", 800);
    config.set_if("window.width", app_arguments.width);
    config.set_if("window.height", app_arguments.height);

    config.set_default("window.resizable", true);
    config.set("window.resizable", !app_arguments.not_resizable);

    config.set_if("game.renderer", app_arguments.renderer);

    config.set_if("connection.host", app_arguments.host);

    config.set_default("connection.port", 25565);
    config.set_if("connection.port", app_arguments.port);

    config.set_default("brala.no_snoop", false);
    config.set_if("brala.no_snoop", app_arguments.no_snoop);

    config.set_default("brala.tessellation_threads", 3);
    config.set_if("brala.tessellation_threads", app_arguments.tessellation_threads);

    config.set_if("game.texture.pack", app_arguments.texture_pack);

    return config;
}