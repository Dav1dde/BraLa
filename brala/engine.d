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
    private vec2i _viewport = vec2i(0, 0);
    /+private+/ FPSCounter _fpsc;

    @property vec2i viewport() {
        return _viewport;
    }
    
    @property float fps() {
        return _fpsc.fps;
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
    
    private Shader _current = null;
    
    @property Shader current() {
        return _current;
    }
    
    @property void current(Shader shader) {
        _current.unbind();
        _current = shader;
        _current.bind();
    }
    
    this(int width, int height, GLVersion glv) {
        opengl_version = glv;
        _viewport = vec2i(width, height);
        
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LEQUAL);
        glEnable(GL_CULL_FACE);
    }
    
    void mainloop(bool delegate(uint) callback) {        
        bool stop = false;
        _fpsc.start();
        
        TickDuration last;
        debug TickDuration lastfps = TickDuration(0);
        
        while(!stop) {
            uint delta_ticks = (_fpsc.get_time() - last).to!("msecs", uint);
            
            stop = callback(delta_ticks);
                        
            _fpsc.update();
                       
            glfwSwapBuffers();
            glfwPollEvents();
        
            debug {
                TickDuration t = _fpsc.get_time();
                if((t-lastfps).to!("seconds", float) > 0.5) {
                    writefln("%s", (t-last).to!("msecs", float));
                    lastfps = t;
                }
            }
            
            last = _fpsc.get_time();
        }
        
        TickDuration ts = _fpsc.stop();
        debug writefln("Mainloop ran %f seconds", ts.to!("seconds", float));
    }
    
    void use(Shader shader) {
        current = shader;
    }
    
    void flush_uniforms() {
        flush_uniforms(_current, true);
    }
    
    void flush_uniforms(Shader shader, bool bound = false) {
        if(!bound) shader.bind();
        
        shader.uniform("viewport", viewport);
        shader.uniform("model", model);
        shader.uniform("view", view);
        shader.uniform("proj", proj);
    }

}