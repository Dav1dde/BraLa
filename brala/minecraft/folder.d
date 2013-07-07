module brala.minecraft.folder;

private {
    import std.path : buildPath, expandTilde, setExtension, baseName, stripExtension;
    import std.exception : enforceEx;
    import std.array : array;
    import std.file : exists, dirEntries, SpanMode;
    import std.algorithm : endsWith, sort, filter;
    import std.string : format;

    import brala.exception : MinecraftException;
}

@property
string minecraft_folder() {
    version(Windows) {
        return buildPath(getenv("appdata"), ".minecraft");
    } else version(OSX) {
        return expandTilde("~/Library/Application Support/minecraft");
    } else {
        return expandTilde("~/.minecraft/");
    }
}


@property
string[string] minecraft_jars() {
    string[string] versions;

    auto jars = dirEntries(minecraft_folder.buildPath("versions"), SpanMode.depth).filter!(x => x.name.endsWith(".jar"));
    foreach(jar; jars) {
        versions[jar.name.baseName.stripExtension] = jar.name;
    }

    string old = minecraft_folder.buildPath("bin", "minecraft.jar");
    if(old.exists) {
        versions["0.0.0"] = old;
    }

    return versions;
}

@property
string minecraft_jar() {
    auto versions = minecraft_jars;
    enforceEx!MinecraftException(versions.length > 0, "Unable to locate any minecraft.jar");
    return versions[versions.keys.sort().array[$-1]];
}

@property
string minecraft_jar(string version_) {
    string folder = minecraft_folder;
    string path = folder.buildPath("versions", version_, version_.setExtension("jar"));
    enforceEx!MinecraftException(path.exists, "Unable to locate minecraft.jar with version %s".format(version_));
    return path;
}
