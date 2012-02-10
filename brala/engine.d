module brala.engine;

private {
    import glamour.gl;
    import derelict.sdl.sdl;
    
    import gl3n.linalg;
    
    import std.stdio : writefln;
}


class BraLaEngine {
    private vec2i _viewport;
    
    GLVersion opengl_version;
    
    this(int width, int height, GLVersion glv) {
        _viewport = vec2i(width, height);
    }
    
    void mainloop(bool delegate(float) callback) {
        uint frames;
        uint timer = SDL_GetTicks();
        
        bool stop = false;
        while(!stop) {
            uint ticks = SDL_GetTicks();
            uint delta_ticks = ticks - timer;
            
            stop = callback(delta_ticks);
                        
            timer = ticks;
            frames++;
            
        }
    }

}