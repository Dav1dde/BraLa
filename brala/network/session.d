module brala.network.session;

private {
    import glamour.gl : glGetString, GL_VERSION, GL_VENDOR;

    import core.cpuid : isX86_64;
    import core.time : Duration;
    import core.thread : thread_isMainThread;
    import std.algorithm : count;
    import std.array : split;
    import std.conv : to;
    import std.string : format, munch;
    import std.datetime : SysTime, Clock;
    import std.path : buildPath, expandTilde;
    import file = std.file;
    import std.traits : ReturnType;
    import std.typecons : Tuple, tuple;
    import std.system : os;

    import brala.exception : SessionError;
    import brala.utils.openssl.hash : SHA1;
    import brala.network.crypto : decode_public, PBEWithMD5AndDES;
    import brala.network.util : urlencode, twos_compliment, to_hexdigest;

    import arsd.http : HttpException, post, get;
    
    debug import std.stdio : stderr, writefln;

    version(Windows) {
        import std.process : getenv;
    }
}


class Session {
    static const int LAUNCHER_VERSION = 1337;
    static const string LOGIN_URL = "https://login.minecraft.net";
    static const string JOIN_SERVER_URL = "http://session.minecraft.net/game/joinserver.jsp";
    static const string CHECK_SESSION_URL = "http://session.minecraft.net/game/checkserver.jsp";
    static const string SNOOP_URL = "http://snoop.minecraft.net/client";
    
    protected SysTime _last_login;
    @property last_login() { return _last_login; }
    
    long game_version;
    string minecraft_username;
    string username;
    string password;
    string session_id;

    protected ReturnType!(Session.snoop_args) _snoop_args_cache;
    protected bool _snoop_is_cached = false;
    
    this(string username, string password) {
        this.username = username;
        this.password = password;

        if(thread_isMainThread()) {
            _snoop_args_cache = Session.snoop_args;
            _snoop_is_cached = true;
        }
    }
    
    void login() {
        auto res = LOGIN_URL.post(["user" : username,
                                   "password" : password,
                                   "version" : to!string(LAUNCHER_VERSION)]);

        if(res.count(":") == 4) {
            string[] s = res.idup.split(":");
            
            this.game_version = to!long(s[0]);
            this.username = username;
            this.minecraft_username = s[2];
            this.session_id = s[3];
        } else {
            throw new SessionError(`Unable to login as user "` ~ username ~ `". ` ~ res.idup);
        }
     
        _last_login = Clock.currTime();
    }

    @property bool logged_in() {
        return cast(bool)session_id.length;
    }

    void login_if_needed() {
        if(session_id.length == 0 || (Clock.currTime() - _last_login).total!"seconds" > 50) {
            login();
        }
    }
    
    void join(string server_id, ubyte[] shared_secret, ubyte[] public_key) {
        login_if_needed();

        auto res = get(JOIN_SERVER_URL ~ "?" ~
                       urlencode(["user" : minecraft_username,
                                  "sessionId" : session_id,
                                  "serverId" : login_hash(server_id, shared_secret, public_key)]));
        
        if(res != "OK") {
            throw new SessionError("Failed to join server: " ~ res.idup);
        }
    }
    
    static string login_hash(string server_id, ubyte[] shared_secret, ubyte[] public_key) {
        auto digest = new SHA1();
        digest.update(server_id);
        digest.update(shared_secret);
        digest.update(public_key);
        
        string hexdigest = digest.hexdigest;
        bool negativ = (digest.digest[0] & 0x80) == 0x80;
        if(negativ) {
            hexdigest = to_hexdigest(twos_compliment(digest.digest));
        }

        hexdigest.munch("0");

        if(negativ) return "-" ~ hexdigest;
        return hexdigest;
    }

    void snoop() {
        if(!_snoop_is_cached) {
            debug assert(thread_isMainThread(), "need to call snoop from main-thread");
            _snoop_args_cache = Session.snoop_args;
            _snoop_is_cached = true;
        }
        
        Session.snoop(_snoop_args_cache.expand);
    }

    static void snoop(string version_, string os_name, string os_version, string os_arch,
                      string memory_total, string memory_max, string java_version,
                      string opengl_version, string opengl_vendor) {
        debug {
            writefln(`Snooping: version: "%s", os_name: "%s", os_version: "%s", `
                     `os_architecture: "%s", memory_total: "%s", memory_max: "%s", `
                     `java_version: "%s", opengl_version: "%s", opengl_vendor: "%s"`,
                     version_, os_name, os_version,
                     os_arch, memory_total, memory_max,
                     java_version, opengl_version, opengl_vendor);
        }

        try {
            SNOOP_URL.post(["version": version_,
                            "os_name": os_name,
                            "os_version": os_version,
                            "os_architecture": os_arch,
                            "memory_total": memory_total,
                            "memory_max": memory_max,
                            "java_version": java_version,
                            "opengl_version": opengl_version,
                            "opengl_vendor": opengl_vendor]);
        } catch(HttpException e) {
            debug stderr.writefln(`Unable to snoop: "%s"`, e.msg);
        }
    }

    @property static auto snoop_args()
        in { assert(thread_isMainThread(), "snoop_args not called from main thread!"); }
        body {
            return tuple("BraLa", os.to!string(), "undetectable", isX86_64 ? "64 bit":"32 bit", "-1", "-1",
                        "D Compiler: " ~ to!string(__VERSION__),
                        to!string(glGetString(GL_VERSION)), to!string(glGetString(GL_VENDOR)));
        }

    static void snoop_default() {
        Session.snoop(Session.snoop_args.expand);
    }
       
}


string minecraft_folder() {
    version(Windows) {
        return buildPath(getenv("appdata"), ".minecraft");
    } else version(OSX) {
        return expandTilde("~/Library/Application Support/minecraft");
    } else {
        return expandTilde("~/.minecraft/");
    }
}

alias Tuple!(string, "username", string, "password") Credentials;

Credentials minecraft_credentials() {
    string path = buildPath(minecraft_folder(), "lastlogin");

    if(file.exists(path)) {
        ubyte[] cipher = cast(ubyte[])file.read(path);

        auto p = new PBEWithMD5AndDES(['p', 'a', 's', 's', 'w', 'o', 'r', 'd', 'f', 'i', 'l', 'e',
                                       0x0c, 0x9d, 0x4a, 0xe4, 0x1e, 0x83, 0x15, 0xfc]);
        ubyte[] decrypted = p.decrypt(cipher);

        short username_len = decrypted[0] << 8 | decrypted[1];
        char[] username = (cast(char[])decrypted)[2..2+username_len];

        short password_len = decrypted[username_len+2] << 8 | decrypted[username_len+3];
        char[] password = (cast(char[])decrypted)[4+username_len..4+username_len+password_len];

        return Credentials(username.idup, password.idup);
    } else {
        return Credentials("", "");
    }
}