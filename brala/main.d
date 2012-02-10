module brala.main;


private {
    import derelict.sdl.sdl;
    import glamour.gl;
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
    DerelictGL.loadModernVersions(GLVersion.GL30);
    DerelictGL.loadExtendedVersions(); 
}

void main() {
}