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
    string[string] fields;
    alias fields this;
    string[string] authentication;

    @property
    string session() {
        return "token:%s:%s".format(authentication["accessToken"], authentication["uuid"]);
    }
}


Profile current_profile(string profile_name = "") {
    string file = minecraft_folder.buildPath("launcher_profiles.json");
    enforceEx!MinecraftException(file.exists, "Unable to find launcher_profiles.json");

    auto s = file.readText();

    auto json = parseJSON(s);
    profile_name = profile_name.length == 0 ? json["selectedProfile"].str : profile_name;

    Profile profile;
    auto json_profile = json["profiles"][profile_name].object;
    enforceEx!MinecraftException(json_profile !is null, "malformed profile");
    foreach(key, value; json_profile) {
        if(value.type == JSON_TYPE.STRING) {
            profile[key] = value.str;
        }
    }

    auto json_auth = json_profile["authentication"].object;
    enforceEx!MinecraftException(json_auth !is null, "malformed profile");
    foreach(key, value; json_auth) {
        enforceEx!MinecraftException(value.type == JSON_TYPE.STRING, "malformed profile");
        profile.authentication[key] = value.str;
    }

    return profile;
}