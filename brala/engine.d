module brala.engine;

private {
    import glamour.gl;
    import glamour.shader;
    
    import derelict.glfw3.glfw3;
    
    import gl3n.linalg;
    
    import brala.timer;
    
    debug import std.stdio : writefln;
}


class BraLaEngine {
    protected vec2i _viewport = vec2i(0, 0);
    Timer timer;

    @property vec2i viewport() {
        return _viewport;
    }
    
    immutable GLVersion opengl_version;
    
    mat4 model;
    mat4 view;
    mat4 proj;
    
    @property mat4 mvp() {
        return proj * view * model;
    }
    
    @property mat4 mv() {
        return view * model;
    }
    
    protected Shader _current_shader = null;
    
    @property Shader current_shader() {
        return _current_shader;
    }
    
    @property void current_shader(Shader shader) {
        _current_shader.unbind();
        _current_shader = shader;
        _current_shader.bind();
    }
    
    this(int width, int height, GLVersion glv) {
        timer = new Timer();
        
        opengl_version = glv;
        _viewport = vec2i(width, height);
        
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LEQUAL);
        glEnable(GL_CULL_FACE);
    }
    
    void mainloop(bool delegate(uint) callback) {        
        bool stop = false;
        timer.start();
        
        TickDuration last;
        debug TickDuration lastfps = TickDuration(0);
        
        while(!stop) {
            uint delta_ticks = (timer.get_time() - last).to!("msecs", uint);
            
            stop = callback(delta_ticks);

            glfwSwapBuffers();
            glfwPollEvents();
        
            debug {
                TickDuration t = timer.get_time();
                if((t-lastfps).to!("seconds", float) > 0.5) {
                    writefln("%s", (t-last).to!("msecs", float));
                    lastfps = t;
                }
            }
            
            last = timer.get_time();
        }
        
        TickDuration ts = timer.stop();
        debug writefln("Mainloop ran %f seconds", ts.to!("seconds", float));
    }
    
    void use(Shader shader) {
        current_shader = shader;
    }
    
    void flush_uniforms() {
        flush_uniforms(_current_shader, true);
    }
    
    void flush_uniforms(Shader shader, bool bound = false) {
        if(!bound) shader.bind();
        
        shader.uniform("viewport", viewport);
        shader.uniform("model", model);
        shader.uniform("view", view);
        shader.uniform("proj", proj);
    }

}