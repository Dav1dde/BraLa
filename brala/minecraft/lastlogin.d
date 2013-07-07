module brala.minecraft.lastlogin;

private {
    import std.typecons : Tuple;
    import std.path : buildPath;
    import file = std.file;

    import brala.minecraft.folder : minecraft_folder;
    import brala.minecraft.crypto : PBEWithMD5AndDES;
}


alias Tuple!(string, "username", string, "password") Credentials;

Credentials minecraft_credentials() {
    string path = buildPath(minecraft_folder, "lastlogin");

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