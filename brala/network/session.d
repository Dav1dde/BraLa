module brala.network.session;

private {
    import std.net.curl : get, post;
    import std.algorithm : count;
    import std.array : split;
    import std.conv : to;
    
    import brala.exception : SessionException;
    
    debug import std.stdio : writefln;
}


class Session {
    static const string launcher_version = "12";
    static const string login_url = "https://login.minecraft.net";
    static const string keep_alive_url = "https://login.minecraft.net/session";
    static const string join_server_url = "http://session.minecraft.net/game/joinserver.jsp";
    
    private bool _logged_in = false;
    @property logged_in() { return _logged_in; }
    
    long game_version;
    string username;
    string session_id;
    
    this() {
    }
    
    void login(string username, string password) {
        debug writefln("(SESSION) Logging in as: \"%s\"", username);
        auto res = post(login_url, "user=" ~ username ~ "&password=" ~ password ~ "&version=" ~ launcher_version);
        debug writefln("(SESSION) Server returned: \"%s\"", res);
    
        if(res.count(":") == 3) {
            string[] s = res.idup.split(":");
            
            this.game_version = to!long(s[0]);
            this.username = s[2];
            this.session_id = s[3];
        } else {
            throw new SessionException("Unable to login as user \"" ~ username ~ "\".");
        }
        
        _logged_in = true;
    }
    
    void join(string server_hash) {
        debug writefln("(SESSION) Sending join request, server hash: \"%s\", user: \"%s\", session_id: \"%s\"", server_hash, username, session_id);
        auto res = get(join_server_url ~ "?user=" ~ username ~ "&sessionId=" ~ session_id ~ "&serverId=" ~ server_hash);
        debug writefln("(SESSION) Server returned: \"%s\"", res);
        
        if(res != "OK") {
            throw new SessionException(res.idup);
        }
    }
    
    void keep_alive() {
        debug writefln("(SESSION) Sending keep alive, username: \"%s\", session_id: \"%s\"", username, session_id);
        auto res = get(keep_alive_url ~ "?name=" ~ username ~ "&session=" ~ session_id);
        debug writefln("(SESSION) Server returned: \"%s\"", res);
    }
}