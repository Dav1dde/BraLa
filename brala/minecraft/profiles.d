module brala.minecraft.profiles;

private {
    import std.json;
    import std.path : buildPath;
    import std.file : exists, readText;
    import std.exception : enforceEx;
    import std.string : format;

    import brala.exception : MinecraftException;
    import brala.minecraft.folder : minecraft_folder;
}

struct Profile {
    string name;

    string username;
    string minecraft_username;
    string uuid;

    string access_token;

    @property
    string session() {
        return "token:%s:%s".format(access_token, uuid);
    }
}


Profile current_profile(string profile_name = "") {
    string file = minecraft_folder.buildPath("launcher_profiles.json");
    enforceEx!MinecraftException(file.exists, "Unable to find launcher_profiles.json");

    auto s = file.readText();

    auto json = parseJSON(s);
    profile_name = json["selectedProfile"].str;

    Profile profile;
    auto json_profile = json["profiles"][profile_name].object;
    profile.name = json_profile["name"].str;
    profile.uuid = json_profile["playerUUID"].str;

    auto json_auth = json["authenticationDatabase"][profile.uuid];
    profile.username = json_auth["username"].str;
    profile.minecraft_username = json_auth["displayName"].str;
    profile.access_token = json_auth["accessToken"].str;

    return profile;
}