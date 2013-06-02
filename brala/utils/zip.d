module brala.utils.zip;

private {
    import zip = std.zip;
    import file = std.file;
    import std.string : munch;
    import std.array : appender, array;
    import std.algorithm : startsWith, canFind;
}

alias ArchiveMember = zip.ArchiveMember;


class ZipArchive : zip.ZipArchive {
    this() {}

    this(void[] data) {
        super(data);
    }

    this(string path) {
        super(file.read(path));
    }

    string[] list_dir(string path, bool deep=true) {
        auto app = appender!(string[])();

        foreach(zpath; this.directory.keys) {
            if(zpath.startsWith(path)) {
                if(!deep) {
                    string s = zpath[path.length..$];
                    s.munch("/");
                    if(s.canFind("/")) {
                        continue;
                    }
                }

                app.put(zpath);
            }
        }

        return app.data;
    }
}