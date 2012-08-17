module brala.utils.console;

private {
    import std.stdio : File, stdout, stderr;
    import std.array : appender, join;
    import std.string : format;
    import std.algorithm : canFind, map;
    import std.process : environment;
    import std.typecons : TypeTuple;
}


enum Attribute : int {
    NONE       = 0b000000000000000000000000,
    RESET      = 0b100000000000000000000000,
    
    BOLD       = 0b000000000000000000000001,
    FAINT      = 0b000000000000000000000010,
    STANDOUT   = 0b000000000000000000000100,
    UNDERLINE  = 0b000000000000000000001000,
    BLINK      = 0b000000000000000000010000,

    BLACK      = 0b000000000000000000100000,
    RED        = 0b000000000000000001000000,
    GREEN      = 0b000000000000000010000000,
    YELLOW     = 0b000000000000000100000000,
    BLUE       = 0b000000000000001000000000,
    MAGENTA    = 0b000000000000010000000000,
    CYAN       = 0b000000000000100000000000,
    WHITE      = 0b000000000001000000000000,

    BG_BLACK   = 0b000000000010000000000000,
    BG_RED     = 0b000000000100000000000000,
    BG_GREEN   = 0b000000001000000000000000,
    BG_YELLOW  = 0b000000010000000000000000,
    BG_BLUE    = 0b000000100000000000000000,
    BG_MAGENTA = 0b000001000000000000000000,
    BG_CYAN    = 0b000010000000000000000000,
    BG_WHITE   = 0b000100000000000000000000
}

version(Posix) {
    private extern(C) int isatty(int);

    bool color_terminal(File f=stdout) {
        if(!isatty(f.fileno())) {
            return false;
        }

        if(environment.get("COLORTERM")) {
            return true;
        }

        auto term = environment.get("TERM", "nope");
        if(["xterm", "linux"].canFind(term) || term.canFind("color")) {
            return true;
        }
        
        return false;
    }

    private string[int] _attrs;
    private string[int] _fg_colors;
    private string[int] _bg_colors;
    private string _reset = "39;49;00";

    private string[int] _styles;
    
    static this() {
        _attrs = [Attribute.BOLD: "01",
                  Attribute.FAINT: "02",
                  Attribute.STANDOUT: "03",
                  Attribute.UNDERLINE: "04",
                  Attribute.BLINK: "05"];

        _fg_colors = [Attribute.BLACK: "30",
                      Attribute.RED: "31",
                      Attribute.GREEN: "32",
                      Attribute.YELLOW: "33",
                      Attribute.BLUE: "34",
                      Attribute.MAGENTA: "35",
                      Attribute.CYAN: "36",
                      Attribute.WHITE: "37"];
                      
        _bg_colors = [Attribute.BG_BLACK: "40",
                      Attribute.BG_RED: "41",
                      Attribute.BG_GREEN: "42",
                      Attribute.BG_YELLOW: "43",
                      Attribute.BG_BLUE: "44",
                      Attribute.BG_MAGENTA: "45",
                      Attribute.BG_CYAN: "46",
                      Attribute.WHITE: "47"];
                      
        _styles[Attribute.NONE] = "";
        _styles[Attribute.RESET] = _reset;
        
        foreach(aa; TypeTuple!("_attrs", "_fg_colors", "_bg_colors")) {
            foreach(key, value; mixin(aa)) {
                _styles[key] = value;
            }
        }
        
    }
    
    string colorize(T, S)(T[] input, int[S] mapping, bool reset_color=true)
        if(__traits(hasMember, T, "attribute") && __traits(hasMember, T, "text")) {
        auto app = appender!string();
        auto temp_app = appender!(string[])();

        foreach(fragment; input) {
            auto mapped = mapping[fragment.attribute];
            
            if(mapped & Attribute.RESET) {
                app.put("\033[%sm%s".format(_styles[Attribute.RESET], fragment.text));
            } else if(mapped & Attribute.NONE) {
                app.put(fragment.text);
            } else {
                temp_app.clear();
                
                foreach(key, value; _styles) {
                    if(mapped & key) {
                        temp_app.put(value);
                    }
                }

                app.put("\033[%sm%s".format(temp_app.data.join(";"), fragment.text));
            }
        }

        if(reset_color) {
            app.put("\033[");
            app.put(_reset);
            app.put("m");
        }
        
        return app.data;
    }

    void print_colorized(T, S)(T[] input, int[S] mapping, bool reset_color=true)
        if(__traits(hasMember, T, "attribute") && __traits(hasMember, T, "text")) {
        stdout.print_colorized(input, mapping, reset_color);
    }
    
    void print_colorized(T, S)(File f, T[] input, int[S] mapping, bool reset_color=true)
        if(__traits(hasMember, T, "attribute") && __traits(hasMember, T, "text")) {
        string c;

        if(color_terminal(f)) {
            c = colorize(input, mapping, reset_color);
        } else {
            c = input.map!(x => x.text).join("");
        }

        f.writeln(c);
    }
} else { // VERSION not POSIX
    bool color_terminal(File f=stdout) {
        return false;
    }

    string colorize(T, S)(T[] input, int[S] mapping, bool reset_color=true)
        if(__traits(hasMember, T, "attribute") && __traits(hasMember, T, "text")) {

        return input.map!(x => x.text).join("");
    }

    void print_colorized(T, S)(T[] input, int[S] mapping, bool reset_color=true)
        if(__traits(hasMember, T, "attribute") && __traits(hasMember, T, "text")) {
        stdout.print_colorized(input, mapping, reset_color);
    }

    void print_colorized(T, S)(File f, T[] input, int[S] mapping, bool reset_color=true)
        if(__traits(hasMember, T, "attribute") && __traits(hasMember, T, "text")) {
        f.writeln(colorize(input, mapping, reset_color));
    }
}