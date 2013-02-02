module brala.ui.ui;

private {
    import wonne.all;
    import wonne.ext.glfw;
    import wonne.ext.opengl;
    import glwtf.window : Window;

    import brala.utils.config : Config;

    debug import std.stdio : writefln;
}


class WebUI {
    protected bool _is_connected;
    @property bool is_connected() { return _is_connected; }
    protected Window _window;
    @property Window window() { return _window; }
    @property void window(Window window) {
        bool was_connected = _is_connected;
        if(_is_connected) {
            disconnect();
        }

        _window = window;

        if(was_connected) {
            connect();
        }
    }
    
    Webview webview;
    alias webview this;
    GLFWAWEBridge input;
    WebviewRenderer renderer;
    
    this(Config config, Window window) {       
        this.window = window;
        this.webview = new Webview(window.width, window.height, false);
        this.input = new GLFWAWEBridge(webview);
        this.renderer = new WebviewRenderer(webview);

        webview.transparent = true;
    }

    void shutdown() {
        debug writefln("Shutting down WebUI");
        renderer.remove();
        webview.destroy();
    }

    void connect() {
        if(!_is_connected) {
            input.connect_to_window(window);
            webview.resize(window.width, window.height, true, 500);
        }
        _is_connected = true;
    }

    void disconnect() {
        input.disconnect_from_window(window);
        _is_connected = false;
    }

    void draw() {
        renderer.display();
    }

    static void update_uis() {
        webcore.update();
    }
}