module brala.main;


private {
    import derelict.sdl.sdl;
    import glamour.gl;
    
    import std.conv : to, ConvException;
    
    debug {
        import std.stdio;
    }
    
    import brala.engine : BraLaEngine;
    import brala.game : BraLaGame;
}

static this() {
    DerelictSDL.load();
    DerelictGL.load();
}


void init_sdl(int width, int height) {
    if(SDL_Init(SDL_INIT_VIDEO)) {
       throw new Exception("failed to init. SDL-Window");
    } 

    SDL_WM_SetCaption("BraLa - Minecraft on a higher level", "BraLa");
    SDL_GL_SetAttribute(SDL_GL_BUFFER_SIZE, 16); 
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24); 
    SDL_GL_SetAttribute(SDL_GL_STENCIL_SIZE, 0); 
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    //SDL_SetVideoMode(1000, 800, 32, SDL_OPENGL | SDL_RESIZABLE);
    SDL_SetVideoMode(width, height, 32, SDL_OPENGL);
    
    // SDL settings
    SDL_ShowCursor(0);
}

void init_opengl() {
    DerelictGL.loadExtendedVersions(); 
    DerelictGL.loadModernVersions(GLVersion.GL30);
}

int main(string[] args) {
    int width = 1024;
    int height = 800;
    
    if(args.length == 3) {
        try {
            width = to!(int)(args[1]);
        } catch(ConvException) {
            throw new Exception("width is not a number.");
        }
        
        try {
            height = to!(int)(args[2]);
        } catch(ConvException) {
            throw new Exception("height is not a number.");
        }
    }
    
    debug writefln("init: %dx%d", width, height);
    init_sdl(width, height);
    scope(exit) SDL_Quit();
    
    init_opengl();
    debug writefln("OpenGL: %d", DerelictGL.maxVersion());
    
    auto engine = new BraLaEngine(width, height, DerelictGL.maxVersion());
    auto game = new BraLaGame(engine);
    game.start();
    
    return 0;
}