module brala.gfx.text;

private {
    import std.typecons : Tuple;
    import std.regex : Regex, regex, match;
    import std.array : appender;
    import std.stdio : File;
    
    import c = brala.utils.console;
}


enum Style : char {
    DEFAULT = cast(char)-1,
    BLACK = '0',
    DARK_BLUE = '1',
    DARK_GREEN = '2',
    DARK_CYAN = '3',
    DARK_RED = '4',
    PURPLE = '5',
    GOLD = '6',
    GRAY = '7',
    DARK_GRAY = '8',
    BLUE = '9',
    GREEN = 'a',
    CYAN = 'b',
    RED = 'c',
    PINK = 'd',
    YELLOW = 'e',
    WHITE = 'f',

    RANDOM = 'k',
    BOLD = 'l',
    STRIKETHROUGH = 'm',
    UNDERLINE = 'n',
    ITALIC = 'o',
    PLAIN_WHITE = 'r'
}

int[Style] colorize_mapping;

static this() {
    colorize_mapping = [Style.BLACK: c.Attribute.BLACK,
                        Style.DARK_BLUE: c.Attribute.BLUE,
                        Style.DARK_GREEN: c.Attribute.GREEN,
                        Style.DARK_CYAN: c.Attribute.CYAN,
                        Style.DARK_RED: c.Attribute.RED,
                        Style.PURPLE: c.Attribute.MAGENTA,
                        Style.GOLD: c.Attribute.YELLOW,
                        Style.GRAY: c.Attribute.WHITE,
                        Style.DARK_GRAY: c.Attribute.BLACK | c.Attribute.BOLD,
                        Style.BLUE: c.Attribute.BLUE,
                        Style.GREEN: c.Attribute.GREEN,
                        Style.CYAN: c.Attribute.CYAN,
                        Style.RED: c.Attribute.RED,
                        Style.PINK: c.Attribute.MAGENTA,
                        Style.YELLOW: c.Attribute.YELLOW,
                        Style.WHITE: c.Attribute.WHITE,

                        Style.RANDOM: c.Attribute.NONE,
                        Style.BOLD: c.Attribute.BOLD,
                        Style.STRIKETHROUGH: c.Attribute.NONE,
                        Style.UNDERLINE: c.Attribute.UNDERLINE,
                        Style.ITALIC: c.Attribute.STANDOUT,
                        Style.PLAIN_WHITE: c.Attribute.RESET,

                        Style.DEFAULT: c.Attribute.RESET];
}


alias Tuple!(Style, "attribute", string, "text") ColoredText;

struct ChatMessage {
    string sender;
    
    ColoredText[] text;

    void print_colorized(File f) {
        c.print_colorized(f, text, colorize_mapping);
    }

    void print_colorized() {
        c.print_colorized(text, colorize_mapping);
    }
}

Regex!char SENDER_RE;

static this() {
    SENDER_RE = regex(`^<([\w, _]+)>`, `g`);
}

ChatMessage parse_chat(string chat_line) {
    ChatMessage ret;
    
    auto m = match(chat_line, SENDER_RE);
    if(m) {
        ret.sender = m.captures[1];
        chat_line = chat_line[m.captures[0].length..$];
    }

    size_t index;
    auto app = appender!string();
    Style attribute = Style.DEFAULT;
    while(index < chat_line.length) {
        ubyte c = chat_line[index++];
        
        if((c == 0xc2) && (chat_line[index] == 0xa7)) { // "§".encode("UTF-8") == "\xc2\xa7"
            if(app.data.length) {
                ret.text ~= ColoredText(attribute, app.data);
                app.clear();
            }
    
            attribute = cast(Style)chat_line[++index];
            index += 1;
        } else {
            app.put(c);
        }
    }

    ret.text ~= ColoredText(attribute, app.data);

    return ret;
}