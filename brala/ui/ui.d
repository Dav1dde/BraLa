module brala.ui.ui;

private {
    import wonne.all;
    import wonne.ext.glfw;
    import wonne.ext.opengl;
    import glamour.gl;
    import glwtf.glfw;
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

    protected bool _running;
    
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

    void display() {
        renderer.display();
    }

    void run(string file, bool is_url=false) {
        connect();
        scope(success) disconnect();
        
        if(is_url) {
            webview.load_url(file);
        } else {
            webview.load_file(file);
        }

        _running = true;
        while(_running) {
            WebUI.update_uis();

            glClearColor(0.117f, 0.490f, 0.745f, 0.0f);
            glClear(GL_COLOR_BUFFER_BIT);

            display();

            window.swap_buffers();
            glfwPollEvents();
        }
    }

    void stop() {
        _running = false;
    }

    static void update_uis() {
        webcore.update();
    }
}