module brala.ui.ui;

private {
    import wonne.all;
    import wonne.ext.glfw;
    import wonne.ext.opengl;
    import glwtf.window : Window;

    import brala.utils.config : Config;
}


class WebUI {
    Webview webview;
    GLFWAWEBridge input;
    WebviewRenderer renderer;
    
    this(Config config, Window window) {
        webview = new Webview(window.width, window.height, false);
        input = new GLFWAWEBridge(webview);
        renderer = new WebviewRenderer(webview);

        webview.transparent = true;
    }
}