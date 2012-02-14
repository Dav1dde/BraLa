module brala.engine;

private {
    import glamour.gl;
    import derelict.glfw3.glfw3;
    
    import gl3n.linalg;
    
    import brala.timer;
    
    debug import std.stdio : writefln;
}


class BraLaEngine {
    private vec2i _viewport;
    /+private+/ FPSCounter _fpsc;
    
    GLVersion opengl_version;
    
    @property vec2i viewport() {
        return _viewport;
    }
    
    @property float fps() {
        return _fpsc.fps;
    }
    
    this(int width, int height, GLVersion glv) {
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
                if((t-lastfps).to!("seconds", float) > 1) {
                    writefln("%s", _fpsc.fps);
                    lastfps = t;
                }
            }
            
            last = _fpsc.get_time();
        }
        
        TickDuration ts = _fpsc.stop();
        debug writefln("Mainloop ran %f seconds", ts.to!("seconds", float));
    }

}