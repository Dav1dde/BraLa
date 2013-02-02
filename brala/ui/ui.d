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
    protected Window window;
    
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
       input.connect_to_window(window);
       webview.resize(window.width, window.height, true, 500);
    }

    void disconnect() {
        input.disconnect_from_window(window);
    }

    void draw() {
        renderer.display();
    }
}