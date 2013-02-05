module brala.ui.api;

private {
    import wonne.all;

    import std.signals;

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
    size_t expects_arguments;
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
                static if(__traits(compiles, __traits(getAttributes, mixin(member))[0].name)) {
                    enum string n = __traits(getAttributes, mixin(member))[0].name;
                    enum size_t expects_arguments = __traits(getAttributes, mixin(member))[0].expects_arguments;

                    static if(n.length) {
                        alias n name;
                    } else {
                        alias member name;
                    }
                } else {
                    alias member name;
                    enum size_t expects_arguments = 0;
                }

                mixin(`callbacks["%s"].connect(&%s);`.xformat(name, member));
                mixin(`callbacks["%s"].expects_arguments = %s;`.xformat(name, expects_arguments));
                brala.ui.set_object_callback(api_name, name);
            }
        }
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


    @Callback(3) void login(JSArray arguments) {
        writefln("login called");
    }
}
