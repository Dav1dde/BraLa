module brala.minecraft.yggdrasil;

private {
    import std.json;

    import brala.minecraft.util : post, get_exception;
}

// use like: import yggdrasil = brala.minecraft.yggdrasil;

struct Profile {
    string id;
    string name;
}

enum URL = "https://authserver.mojang.com";


struct Authentication {
    string access_token;
    string client_token;

    Profile[] profiles;
    Profile selected_profile;
}

Authentication authenticate(string username, string password, string client_token = "") {
    enum ENDPOINT = URL ~ "/authenticate";

    auto payload = [
        "agent" : JSONValue([
            "name" : JSONValue("Minecraft"),
            "version" : JSONValue(1)
        ]),

        "username" : JSONValue(username),
        "password" : JSONValue(password)
    ];

    if(client_token.length > 0) {
        payload["clientToken"] = JSONValue(client_token);
    }

    auto response = ENDPOINT.post(JSONValue(payload));
    if(response.code != 200) throw response.get_exception();

    Authentication auth;

    auto json = parseJSON(response.content);
    auth.access_token = json["accessToken"].str;
    auth.client_token = json["clientToken"].str;
    auth.selected_profile = Profile(
        json["selectedProfile"]["id"].str,
        json["selectedProfile"]["name"].str
    );

    foreach(jprofile; json["availableProfiles"].array) {
        auth.profiles ~= Profile(
            jprofile["id"].str,
            jprofile["name"].str
        );
    }

    return auth;
}


struct Refresh {
    string access_token;
    string client_token;

    Profile selected_profile;
}

Refresh refresh(string access_token, string client_token, Profile profile) {
    return refresh(access_token, client_token, profile.id, profile.name);
}

Refresh refresh(string access_token, string client_token, string id, string name) {
    enum ENDPOINT = URL ~ "/refresh";

    auto payload = [
        "accessToken" : JSONValue(access_token),
        "clientToken" : JSONValue(client_token),

        "selectedProfile" : JSONValue([
            "id" : id,
            "name" : name
        ])
    ];

    auto response = ENDPOINT.post(JSONValue(payload));
    if(response.code != 200) throw response.get_exception();

    Refresh refresh;

    auto json = parseJSON(response.content);
    refresh.access_token = json["accessToken"].str;
    refresh.client_token = json["clientToken"].str;
    refresh.selected_profile = Profile(
        json["selectedProfile"]["id"].str,
        json["selectedProfile"]["name"].str
    );

    return refresh;
}


bool is_valid(string access_token) {
    enum ENDPOINT = URL ~ "/validate";

    auto response = ENDPOINT.post(JSONValue([
        "accessToken" : access_token
    ]));

    return response.code == 200 && response.content.length == 0;
}