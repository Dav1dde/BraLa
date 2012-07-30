module brala.network.session;

private {
    import std.net.curl : get, post;
    import std.algorithm : count;
    import std.array : split;
    import std.conv : to;
    import std.string : format;
    import std.datetime : SysTime, Clock;
    import core.time : Duration;

    import brala.network.util : urlencode;
    import brala.exception : SessionError;
    import brala.utils.hash : SHA1;
    
    debug import std.stdio : writefln;
}


class Session {
    static const int launcher_version = 1337;
    static const string login_url = "https://login.minecraft.net";
    static const string join_server_url = "http://session.minecraft.net/game/joinserver.jsp";
    static const string check_session_url = "http://session.minecraft.net/game/checkserver.jsp";
    
    private SysTime _last_login;
    @property last_login() { return _last_login; }
    
    long game_version;
    string cusername;
    string username;
    string password;
    string session_id;
    
    this(string username, string password) {
        this.username = username;
        this.password = password;
    }
    
    void login() {
        auto res = post(login_url,
                        urlencode(["user" : username,
                                   "password" : password,
                                   "version" : to!string(launcher_version)]));
        
        if(res.count(":") == 3) {
            string[] s = res.idup.split(":");
            
            this.game_version = to!long(s[0]);
            this.username = username;
            this.cusername = s[2];
            this.session_id = s[3];
        } else {
            throw new SessionError(`Unable to login as user "` ~ username ~ `".`);
        }
     
        _last_login = Clock.currTime();
    }

    void login_if_needed() {
        if(session_id.length == 0 || (Clock.currTime() - _last_login).total!"seconds" > 50) {
            login();
        }
    }
    
    void join(string server_id, ubyte[] shared_secret, ubyte[] public_key) {
        login_if_needed();
        
        auto res = get(join_server_url ~ "?" ~
                       urlencode(["user" : username,
                                  "sessionId" : session_id,
                                  "serverId" : login_hash(server_id, shared_secret, public_key)]));
        
        if(res != "OK") {
            throw new SessionError(res.idup);
        }
    }
    
    static string login_hash(string server_id, ubyte[] shared_secret, ubyte[] public_key) {
        auto digest = new SHA1();
        digest.update(server_id);
        digest.update(shared_secret);
        digest.update(public_key); // TODO DER encode public key!

        long d = to!long(digest.hexdigest, 16);
        if(d >> (39*4 & 0x8)) {
            return "-%x".format((-d) & (2^^(40*4)-1));
        }        
        return "%x".format(d);
    }
}