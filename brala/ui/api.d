module brala.ui.api;

private {
    import wonne.all;

    import std.signals;
    import std.string : format;
    import std.array : join;
    import std.range : repeat;
    import std.conv : to;

    import brala.main : BraLa;
    import brala.utils.ctfe : hasAttribute;
    import brala.utils.defaultaa : DefaultAA;

    debug import std.stdio : stderr, writefln;
}


private struct SignalWrapper(Args...) {
    size_t expects_arguments;
    mixin Signal!(Args);
}

private struct Callback {
    string name;
}

class UIApi {
    immutable string api_name;
    protected BraLa brala;
    protected DefaultAA!(SignalWrapper!(JSArray), string) callbacks;

    this(string api_name, BraLa brala) {
        this.api_name = api_name;
        this.brala = brala;

        brala.ui.create_object(api_name);
        brala.ui.on_js_callback.connect(&dispatch_callback);

        init_callbacks();
    }

    void init_callbacks() {
        foreach(member; __traits(allMembers, typeof(this))) {
            static if(__traits(compiles, hasAttribute!(mixin(member), Callback)) && hasAttribute!(mixin(member), Callback)) {
                alias ParameterTypeTuple!(mixin(member)) Args;

                static if(__traits(compiles, __traits(getAttributes, mixin(member))[0].name)) {
                    enum string n = __traits(getAttributes, mixin(member))[0].name;

                    static if(n.length) {
                        alias n name;
                    } else {
                        alias member name;
                    }
                } else {
                    alias member name;
                }

                callbacks[name].connect(&(_wrapper!(mixin(member), member, Args)));
                callbacks[name].expects_arguments = Args.length;

                brala.ui.set_object_callback(api_name, name);
            }
        }
    }

    private auto _wrapper(alias fun, string name, Args...)(JSArray array) {
        Args new_args;

        foreach(i, arg; new_args) {
            new_args[i] = array[i].opCast!(typeof(arg))();
        }

        try {
            return fun(new_args);
        } catch(Exception e) {
            string f = format("%s".repeat(Args.length).join(", "), new_args);
            
            debug stderr.writefln(`--- Exception during JS callback: "%s(%s)" ---`, name, f);
            debug stderr.writeln(e.toString());
            debug stderr.writefln(`--- End Exception during JS callback: "%s(%s)" ---`, name, f);
        }
    }

    void set_property(T)(string name, T value) {
        JSValue js_value = JSValue(value);
        scope(exit) js_value.destroy();

        brala.ui.set_object_property(api_name, name, js_value);
    }

    void dispatch_callback(Webview webview, string object_name, string callback_name, JSArray arguments) {
        debug writefln("Got JS callback: %s.%s with %s arguments", object_name, callback_name, arguments.size);

        if(object_name == api_name) {
            if(callbacks[callback_name].expects_arguments == arguments.size) {
                callbacks[callback_name].emit(arguments);
            } else {
                debug stderr.writefln("Invalid api call: %s.%s, %s arguments expected, got %s",
                                       object_name, callback_name, callbacks[callback_name].expects_arguments,
                                       arguments.size);
            }
        }
    }


    @Callback void login(string username, string password, bool offline) {
        if(offline) {
            brala.session.username = username;
            brala.session.minecraft_username = username;
            set_property("logged_in", true);
        } else {
            brala.session.login(username, password);
            set_property("logged_in", brala.session.logged_in);
        }
    }
}
