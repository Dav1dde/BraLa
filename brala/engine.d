module brala.engine;

private {
    import glamour.gl;
    import derelict.glfw3.glfw3;
    
    import gl3n.linalg;
    
    import std.stdio : writefln;
}


class BraLaEngine {
    private vec2i _viewport;
    
    GLVersion opengl_version;
    
    @property vec2i viewport() {
        return _viewport;
    }
    
    this(int width, int height, GLVersion glv) {
        _viewport = vec2i(width, height);
        
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LEQUAL);
        glEnable(GL_CULL_FACE);
    }
    
    void mainloop(bool delegate(float) callback) {
        uint frames;
        uint timer = 0; // TODO: get a timer.
        
        bool stop = false;
        while(!stop) {
            uint ticks = 0;
            uint delta_ticks = ticks - timer;
            
            stop = callback(delta_ticks);
                        
            timer = ticks;
            frames++;
            
            glfwSwapBuffers();
            glfwPollEvents();
        }
    }

}