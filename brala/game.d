module brala.game;

private {
    import derelict.sdl.sdl;
    
    import brala.engine : BraLaEngine;
    
    import std.stdio;
}

class BraLaGame {
    BraLaEngine engine;
    
    this(BraLaEngine engine_) {
        engine = engine_;
    }
    
    void start() {
        engine.mainloop(&poll);
    }
    
    
    bool poll(float delta_t) {
        bool close = handle_sdl_events(delta_t);
        display();
        
        return close;
        
    }
    
    void display() {
    }

    bool handle_sdl_events(float delta_t) {
        SDL_Event event;
        
        while(SDL_PollEvent(&event)) {
            switch(event.type) {
                case SDL_KEYDOWN:
                    switch(event.key.keysym.sym) {
                        case SDLK_ESCAPE: return true;
                        default: break;
                    }
                default: break;
            }
        }
        
        return false;
    }
}