module glad.loader;


private import glad.glfuncs;
private import glad.glext;
private import glad.glenums;
private import glad.gltypes;


struct GLVersion { int major; int minor; }

version(Windows) {
    private import std.c.windows.windows;
} else {
    private import core.sys.posix.dlfcn;
}

version(Windows) {
    private __gshared HMODULE libGL;
    extern(System) private __gshared void* function(const(char)*) wglGetProcAddress;
} else {
    private __gshared void* libGL;
    extern(System) private __gshared void* function(const(char)*) glXGetProcAddress;
}

bool gladInit() {
    version(Windows) {
        libGL = LoadLibraryA("opengl32.dll\0".ptr);
        if(libGL !is null) {
            wglGetProcAddress = cast(typeof(wglGetProcAddress))GetProcAddress(
                libGL, "wglGetProcAddress\0".ptr);
            return wglGetProcAddress !is null;
        }

        return false;
    } else {
        version(OSX) {
            enum NAMES = [
                "../Frameworks/OpenGL.framework/OpenGL\0".ptr,
                "/Library/Frameworks/OpenGL.framework/OpenGL\0".ptr,
                "/System/Library/Frameworks/OpenGL.framework/OpenGL\0".ptr
            ];
        } else {
            enum NAMES = ["libGL.so.1\0".ptr, "libGL.so\0".ptr];
        }

        foreach(name; NAMES) {
            libGL = dlopen(name, RTLD_NOW | RTLD_GLOBAL);
            if(libGL !is null) {
                version(OSX) {
                    return true;
                } else {
                    glXGetProcAddress = cast(typeof(glXGetProcAddress))dlsym(libGL,
                        "glXGetProcAddressARB\0".ptr);
                    return glXGetProcAddress !is null;
                }
            }
        }

        return false;
    }
}

void gladTerminate() {
    version(Windows) {
        if(libGL !is null) {
            FreeLibrary(libGL);
            libGL = null;
        }
    } else {
        if(libGL !is null) {
            dlclose(libGL);
            libGL = null;
        }
    }
}

void* gladGetProcAddress(const(char)* namez) {
    if(libGL is null) return null;
    void* result;

    version(Windows) {
        if(wglGetProcAddress is null) return null;

        result = wglGetProcAddress(namez);
        if(result is null) {
            result = GetProcAddress(libGL, namez);
        }
    } else {
        if(glXGetProcAddress is null) return null;

        version(OSX) {} else {
            result = glXGetProcAddress(namez);
        }
        if(result is null) {
            result = dlsym(libGL, namez);
        }
    }

    return result;
}

GLVersion gladLoadGL() {
    return gladLoadGL(&gladGetProcAddress);
}


private extern(C) char* strstr(const(char)*, const(char)*);
private extern(C) int strcmp(const(char)*, const(char)*);
private bool has_ext(GLVersion glv, const(char)* extensions, const(char)* ext) {
    if(glv.major < 3) {
        return extensions !is null && ext !is null && strstr(extensions, ext) !is null;
    } else {
        int num;
        glGetIntegerv(GL_NUM_EXTENSIONS, &num);

        for(uint i=0; i < cast(uint)num; i++) {
            if(strcmp(cast(const(char)*)glGetStringi(GL_EXTENSIONS, i), ext) == 0) {
                return true;
            }
        }
    }

    return false;
}
GLVersion gladLoadGL(void* function(const(char)* name) load) {
	glGetString = cast(typeof(glGetString))load("glGetString\0".ptr);
	if(glGetString is null) { GLVersion glv; return glv; }

	GLVersion glv = find_core();
	load_gl_GL_VERSION_1_0(load);
	load_gl_GL_VERSION_1_1(load);
	load_gl_GL_VERSION_1_2(load);
	load_gl_GL_VERSION_1_3(load);
	load_gl_GL_VERSION_1_4(load);
	load_gl_GL_VERSION_1_5(load);
	load_gl_GL_VERSION_2_0(load);
	load_gl_GL_VERSION_2_1(load);
	load_gl_GL_VERSION_3_0(load);
	load_gl_GL_VERSION_3_1(load);
	load_gl_GL_VERSION_3_2(load);
	load_gl_GL_VERSION_3_3(load);
	load_gl_GL_VERSION_4_0(load);
	load_gl_GL_VERSION_4_1(load);
	load_gl_GL_VERSION_4_2(load);
	load_gl_GL_VERSION_4_3(load);
	load_gl_GL_VERSION_4_4(load);

	find_extensions(glv);

	return glv;
}

private:

GLVersion find_core() {
	int major;
	int minor;
	const(char)* v = cast(const(char)*)glGetString(GL_VERSION);
	major = v[0] - '0';
	minor = v[2] - '0';
	GL_VERSION_1_0 = (major == 1 && minor >= 0) || major > 1;
	GL_VERSION_1_1 = (major == 1 && minor >= 1) || major > 1;
	GL_VERSION_1_2 = (major == 1 && minor >= 2) || major > 1;
	GL_VERSION_1_3 = (major == 1 && minor >= 3) || major > 1;
	GL_VERSION_1_4 = (major == 1 && minor >= 4) || major > 1;
	GL_VERSION_1_5 = (major == 1 && minor >= 5) || major > 1;
	GL_VERSION_2_0 = (major == 2 && minor >= 0) || major > 2;
	GL_VERSION_2_1 = (major == 2 && minor >= 1) || major > 2;
	GL_VERSION_3_0 = (major == 3 && minor >= 0) || major > 3;
	GL_VERSION_3_1 = (major == 3 && minor >= 1) || major > 3;
	GL_VERSION_3_2 = (major == 3 && minor >= 2) || major > 3;
	GL_VERSION_3_3 = (major == 3 && minor >= 3) || major > 3;
	GL_VERSION_4_0 = (major == 4 && minor >= 0) || major > 4;
	GL_VERSION_4_1 = (major == 4 && minor >= 1) || major > 4;
	GL_VERSION_4_2 = (major == 4 && minor >= 2) || major > 4;
	GL_VERSION_4_3 = (major == 4 && minor >= 3) || major > 4;
	GL_VERSION_4_4 = (major == 4 && minor >= 4) || major > 4;
	GLVersion glv; glv.major = major; glv.minor = minor; return glv;
}

void find_extensions(GLVersion glv) {
	const(char)* extensions = cast(const(char)*)glGetString(GL_EXTENSIONS);

	GL_EXT_texture_filter_anisotropic = has_ext(glv, extensions, "GL_EXT_texture_filter_anisotropic\0".ptr);
}

void load_gl_GL_VERSION_1_0(void* function(const(char)* name) load) {
	if(!GL_VERSION_1_0) return;
	glCullFace = cast(typeof(glCullFace))load("glCullFace\0".ptr);
	glFrontFace = cast(typeof(glFrontFace))load("glFrontFace\0".ptr);
	glHint = cast(typeof(glHint))load("glHint\0".ptr);
	glLineWidth = cast(typeof(glLineWidth))load("glLineWidth\0".ptr);
	glPointSize = cast(typeof(glPointSize))load("glPointSize\0".ptr);
	glPolygonMode = cast(typeof(glPolygonMode))load("glPolygonMode\0".ptr);
	glScissor = cast(typeof(glScissor))load("glScissor\0".ptr);
	glTexParameterf = cast(typeof(glTexParameterf))load("glTexParameterf\0".ptr);
	glTexParameterfv = cast(typeof(glTexParameterfv))load("glTexParameterfv\0".ptr);
	glTexParameteri = cast(typeof(glTexParameteri))load("glTexParameteri\0".ptr);
	glTexParameteriv = cast(typeof(glTexParameteriv))load("glTexParameteriv\0".ptr);
	glTexImage1D = cast(typeof(glTexImage1D))load("glTexImage1D\0".ptr);
	glTexImage2D = cast(typeof(glTexImage2D))load("glTexImage2D\0".ptr);
	glDrawBuffer = cast(typeof(glDrawBuffer))load("glDrawBuffer\0".ptr);
	glClear = cast(typeof(glClear))load("glClear\0".ptr);
	glClearColor = cast(typeof(glClearColor))load("glClearColor\0".ptr);
	glClearStencil = cast(typeof(glClearStencil))load("glClearStencil\0".ptr);
	glClearDepth = cast(typeof(glClearDepth))load("glClearDepth\0".ptr);
	glStencilMask = cast(typeof(glStencilMask))load("glStencilMask\0".ptr);
	glColorMask = cast(typeof(glColorMask))load("glColorMask\0".ptr);
	glDepthMask = cast(typeof(glDepthMask))load("glDepthMask\0".ptr);
	glDisable = cast(typeof(glDisable))load("glDisable\0".ptr);
	glEnable = cast(typeof(glEnable))load("glEnable\0".ptr);
	glFinish = cast(typeof(glFinish))load("glFinish\0".ptr);
	glFlush = cast(typeof(glFlush))load("glFlush\0".ptr);
	glBlendFunc = cast(typeof(glBlendFunc))load("glBlendFunc\0".ptr);
	glLogicOp = cast(typeof(glLogicOp))load("glLogicOp\0".ptr);
	glStencilFunc = cast(typeof(glStencilFunc))load("glStencilFunc\0".ptr);
	glStencilOp = cast(typeof(glStencilOp))load("glStencilOp\0".ptr);
	glDepthFunc = cast(typeof(glDepthFunc))load("glDepthFunc\0".ptr);
	glPixelStoref = cast(typeof(glPixelStoref))load("glPixelStoref\0".ptr);
	glPixelStorei = cast(typeof(glPixelStorei))load("glPixelStorei\0".ptr);
	glReadBuffer = cast(typeof(glReadBuffer))load("glReadBuffer\0".ptr);
	glReadPixels = cast(typeof(glReadPixels))load("glReadPixels\0".ptr);
	glGetBooleanv = cast(typeof(glGetBooleanv))load("glGetBooleanv\0".ptr);
	glGetDoublev = cast(typeof(glGetDoublev))load("glGetDoublev\0".ptr);
	glGetError = cast(typeof(glGetError))load("glGetError\0".ptr);
	glGetFloatv = cast(typeof(glGetFloatv))load("glGetFloatv\0".ptr);
	glGetIntegerv = cast(typeof(glGetIntegerv))load("glGetIntegerv\0".ptr);
	glGetString = cast(typeof(glGetString))load("glGetString\0".ptr);
	glGetTexImage = cast(typeof(glGetTexImage))load("glGetTexImage\0".ptr);
	glGetTexParameterfv = cast(typeof(glGetTexParameterfv))load("glGetTexParameterfv\0".ptr);
	glGetTexParameteriv = cast(typeof(glGetTexParameteriv))load("glGetTexParameteriv\0".ptr);
	glGetTexLevelParameterfv = cast(typeof(glGetTexLevelParameterfv))load("glGetTexLevelParameterfv\0".ptr);
	glGetTexLevelParameteriv = cast(typeof(glGetTexLevelParameteriv))load("glGetTexLevelParameteriv\0".ptr);
	glIsEnabled = cast(typeof(glIsEnabled))load("glIsEnabled\0".ptr);
	glDepthRange = cast(typeof(glDepthRange))load("glDepthRange\0".ptr);
	glViewport = cast(typeof(glViewport))load("glViewport\0".ptr);
	return;
}

void load_gl_GL_VERSION_1_1(void* function(const(char)* name) load) {
	if(!GL_VERSION_1_1) return;
	glDrawArrays = cast(typeof(glDrawArrays))load("glDrawArrays\0".ptr);
	glDrawElements = cast(typeof(glDrawElements))load("glDrawElements\0".ptr);
	glPolygonOffset = cast(typeof(glPolygonOffset))load("glPolygonOffset\0".ptr);
	glCopyTexImage1D = cast(typeof(glCopyTexImage1D))load("glCopyTexImage1D\0".ptr);
	glCopyTexImage2D = cast(typeof(glCopyTexImage2D))load("glCopyTexImage2D\0".ptr);
	glCopyTexSubImage1D = cast(typeof(glCopyTexSubImage1D))load("glCopyTexSubImage1D\0".ptr);
	glCopyTexSubImage2D = cast(typeof(glCopyTexSubImage2D))load("glCopyTexSubImage2D\0".ptr);
	glTexSubImage1D = cast(typeof(glTexSubImage1D))load("glTexSubImage1D\0".ptr);
	glTexSubImage2D = cast(typeof(glTexSubImage2D))load("glTexSubImage2D\0".ptr);
	glBindTexture = cast(typeof(glBindTexture))load("glBindTexture\0".ptr);
	glDeleteTextures = cast(typeof(glDeleteTextures))load("glDeleteTextures\0".ptr);
	glGenTextures = cast(typeof(glGenTextures))load("glGenTextures\0".ptr);
	glIsTexture = cast(typeof(glIsTexture))load("glIsTexture\0".ptr);
	return;
}

void load_gl_GL_VERSION_1_2(void* function(const(char)* name) load) {
	if(!GL_VERSION_1_2) return;
	glBlendColor = cast(typeof(glBlendColor))load("glBlendColor\0".ptr);
	glBlendEquation = cast(typeof(glBlendEquation))load("glBlendEquation\0".ptr);
	glDrawRangeElements = cast(typeof(glDrawRangeElements))load("glDrawRangeElements\0".ptr);
	glTexImage3D = cast(typeof(glTexImage3D))load("glTexImage3D\0".ptr);
	glTexSubImage3D = cast(typeof(glTexSubImage3D))load("glTexSubImage3D\0".ptr);
	glCopyTexSubImage3D = cast(typeof(glCopyTexSubImage3D))load("glCopyTexSubImage3D\0".ptr);
	return;
}

void load_gl_GL_VERSION_1_3(void* function(const(char)* name) load) {
	if(!GL_VERSION_1_3) return;
	glActiveTexture = cast(typeof(glActiveTexture))load("glActiveTexture\0".ptr);
	glSampleCoverage = cast(typeof(glSampleCoverage))load("glSampleCoverage\0".ptr);
	glCompressedTexImage3D = cast(typeof(glCompressedTexImage3D))load("glCompressedTexImage3D\0".ptr);
	glCompressedTexImage2D = cast(typeof(glCompressedTexImage2D))load("glCompressedTexImage2D\0".ptr);
	glCompressedTexImage1D = cast(typeof(glCompressedTexImage1D))load("glCompressedTexImage1D\0".ptr);
	glCompressedTexSubImage3D = cast(typeof(glCompressedTexSubImage3D))load("glCompressedTexSubImage3D\0".ptr);
	glCompressedTexSubImage2D = cast(typeof(glCompressedTexSubImage2D))load("glCompressedTexSubImage2D\0".ptr);
	glCompressedTexSubImage1D = cast(typeof(glCompressedTexSubImage1D))load("glCompressedTexSubImage1D\0".ptr);
	glGetCompressedTexImage = cast(typeof(glGetCompressedTexImage))load("glGetCompressedTexImage\0".ptr);
	return;
}

void load_gl_GL_VERSION_1_4(void* function(const(char)* name) load) {
	if(!GL_VERSION_1_4) return;
	glBlendFuncSeparate = cast(typeof(glBlendFuncSeparate))load("glBlendFuncSeparate\0".ptr);
	glMultiDrawArrays = cast(typeof(glMultiDrawArrays))load("glMultiDrawArrays\0".ptr);
	glMultiDrawElements = cast(typeof(glMultiDrawElements))load("glMultiDrawElements\0".ptr);
	glPointParameterf = cast(typeof(glPointParameterf))load("glPointParameterf\0".ptr);
	glPointParameterfv = cast(typeof(glPointParameterfv))load("glPointParameterfv\0".ptr);
	glPointParameteri = cast(typeof(glPointParameteri))load("glPointParameteri\0".ptr);
	glPointParameteriv = cast(typeof(glPointParameteriv))load("glPointParameteriv\0".ptr);
	glBlendColor = cast(typeof(glBlendColor))load("glBlendColor\0".ptr);
	glBlendEquation = cast(typeof(glBlendEquation))load("glBlendEquation\0".ptr);
	return;
}

void load_gl_GL_VERSION_1_5(void* function(const(char)* name) load) {
	if(!GL_VERSION_1_5) return;
	glGenQueries = cast(typeof(glGenQueries))load("glGenQueries\0".ptr);
	glDeleteQueries = cast(typeof(glDeleteQueries))load("glDeleteQueries\0".ptr);
	glIsQuery = cast(typeof(glIsQuery))load("glIsQuery\0".ptr);
	glBeginQuery = cast(typeof(glBeginQuery))load("glBeginQuery\0".ptr);
	glEndQuery = cast(typeof(glEndQuery))load("glEndQuery\0".ptr);
	glGetQueryiv = cast(typeof(glGetQueryiv))load("glGetQueryiv\0".ptr);
	glGetQueryObjectiv = cast(typeof(glGetQueryObjectiv))load("glGetQueryObjectiv\0".ptr);
	glGetQueryObjectuiv = cast(typeof(glGetQueryObjectuiv))load("glGetQueryObjectuiv\0".ptr);
	glBindBuffer = cast(typeof(glBindBuffer))load("glBindBuffer\0".ptr);
	glDeleteBuffers = cast(typeof(glDeleteBuffers))load("glDeleteBuffers\0".ptr);
	glGenBuffers = cast(typeof(glGenBuffers))load("glGenBuffers\0".ptr);
	glIsBuffer = cast(typeof(glIsBuffer))load("glIsBuffer\0".ptr);
	glBufferData = cast(typeof(glBufferData))load("glBufferData\0".ptr);
	glBufferSubData = cast(typeof(glBufferSubData))load("glBufferSubData\0".ptr);
	glGetBufferSubData = cast(typeof(glGetBufferSubData))load("glGetBufferSubData\0".ptr);
	glMapBuffer = cast(typeof(glMapBuffer))load("glMapBuffer\0".ptr);
	glUnmapBuffer = cast(typeof(glUnmapBuffer))load("glUnmapBuffer\0".ptr);
	glGetBufferParameteriv = cast(typeof(glGetBufferParameteriv))load("glGetBufferParameteriv\0".ptr);
	glGetBufferPointerv = cast(typeof(glGetBufferPointerv))load("glGetBufferPointerv\0".ptr);
	return;
}

void load_gl_GL_VERSION_2_0(void* function(const(char)* name) load) {
	if(!GL_VERSION_2_0) return;
	glBlendEquationSeparate = cast(typeof(glBlendEquationSeparate))load("glBlendEquationSeparate\0".ptr);
	glDrawBuffers = cast(typeof(glDrawBuffers))load("glDrawBuffers\0".ptr);
	glStencilOpSeparate = cast(typeof(glStencilOpSeparate))load("glStencilOpSeparate\0".ptr);
	glStencilFuncSeparate = cast(typeof(glStencilFuncSeparate))load("glStencilFuncSeparate\0".ptr);
	glStencilMaskSeparate = cast(typeof(glStencilMaskSeparate))load("glStencilMaskSeparate\0".ptr);
	glAttachShader = cast(typeof(glAttachShader))load("glAttachShader\0".ptr);
	glBindAttribLocation = cast(typeof(glBindAttribLocation))load("glBindAttribLocation\0".ptr);
	glCompileShader = cast(typeof(glCompileShader))load("glCompileShader\0".ptr);
	glCreateProgram = cast(typeof(glCreateProgram))load("glCreateProgram\0".ptr);
	glCreateShader = cast(typeof(glCreateShader))load("glCreateShader\0".ptr);
	glDeleteProgram = cast(typeof(glDeleteProgram))load("glDeleteProgram\0".ptr);
	glDeleteShader = cast(typeof(glDeleteShader))load("glDeleteShader\0".ptr);
	glDetachShader = cast(typeof(glDetachShader))load("glDetachShader\0".ptr);
	glDisableVertexAttribArray = cast(typeof(glDisableVertexAttribArray))load("glDisableVertexAttribArray\0".ptr);
	glEnableVertexAttribArray = cast(typeof(glEnableVertexAttribArray))load("glEnableVertexAttribArray\0".ptr);
	glGetActiveAttrib = cast(typeof(glGetActiveAttrib))load("glGetActiveAttrib\0".ptr);
	glGetActiveUniform = cast(typeof(glGetActiveUniform))load("glGetActiveUniform\0".ptr);
	glGetAttachedShaders = cast(typeof(glGetAttachedShaders))load("glGetAttachedShaders\0".ptr);
	glGetAttribLocation = cast(typeof(glGetAttribLocation))load("glGetAttribLocation\0".ptr);
	glGetProgramiv = cast(typeof(glGetProgramiv))load("glGetProgramiv\0".ptr);
	glGetProgramInfoLog = cast(typeof(glGetProgramInfoLog))load("glGetProgramInfoLog\0".ptr);
	glGetShaderiv = cast(typeof(glGetShaderiv))load("glGetShaderiv\0".ptr);
	glGetShaderInfoLog = cast(typeof(glGetShaderInfoLog))load("glGetShaderInfoLog\0".ptr);
	glGetShaderSource = cast(typeof(glGetShaderSource))load("glGetShaderSource\0".ptr);
	glGetUniformLocation = cast(typeof(glGetUniformLocation))load("glGetUniformLocation\0".ptr);
	glGetUniformfv = cast(typeof(glGetUniformfv))load("glGetUniformfv\0".ptr);
	glGetUniformiv = cast(typeof(glGetUniformiv))load("glGetUniformiv\0".ptr);
	glGetVertexAttribdv = cast(typeof(glGetVertexAttribdv))load("glGetVertexAttribdv\0".ptr);
	glGetVertexAttribfv = cast(typeof(glGetVertexAttribfv))load("glGetVertexAttribfv\0".ptr);
	glGetVertexAttribiv = cast(typeof(glGetVertexAttribiv))load("glGetVertexAttribiv\0".ptr);
	glGetVertexAttribPointerv = cast(typeof(glGetVertexAttribPointerv))load("glGetVertexAttribPointerv\0".ptr);
	glIsProgram = cast(typeof(glIsProgram))load("glIsProgram\0".ptr);
	glIsShader = cast(typeof(glIsShader))load("glIsShader\0".ptr);
	glLinkProgram = cast(typeof(glLinkProgram))load("glLinkProgram\0".ptr);
	glShaderSource = cast(typeof(glShaderSource))load("glShaderSource\0".ptr);
	glUseProgram = cast(typeof(glUseProgram))load("glUseProgram\0".ptr);
	glUniform1f = cast(typeof(glUniform1f))load("glUniform1f\0".ptr);
	glUniform2f = cast(typeof(glUniform2f))load("glUniform2f\0".ptr);
	glUniform3f = cast(typeof(glUniform3f))load("glUniform3f\0".ptr);
	glUniform4f = cast(typeof(glUniform4f))load("glUniform4f\0".ptr);
	glUniform1i = cast(typeof(glUniform1i))load("glUniform1i\0".ptr);
	glUniform2i = cast(typeof(glUniform2i))load("glUniform2i\0".ptr);
	glUniform3i = cast(typeof(glUniform3i))load("glUniform3i\0".ptr);
	glUniform4i = cast(typeof(glUniform4i))load("glUniform4i\0".ptr);
	glUniform1fv = cast(typeof(glUniform1fv))load("glUniform1fv\0".ptr);
	glUniform2fv = cast(typeof(glUniform2fv))load("glUniform2fv\0".ptr);
	glUniform3fv = cast(typeof(glUniform3fv))load("glUniform3fv\0".ptr);
	glUniform4fv = cast(typeof(glUniform4fv))load("glUniform4fv\0".ptr);
	glUniform1iv = cast(typeof(glUniform1iv))load("glUniform1iv\0".ptr);
	glUniform2iv = cast(typeof(glUniform2iv))load("glUniform2iv\0".ptr);
	glUniform3iv = cast(typeof(glUniform3iv))load("glUniform3iv\0".ptr);
	glUniform4iv = cast(typeof(glUniform4iv))load("glUniform4iv\0".ptr);
	glUniformMatrix2fv = cast(typeof(glUniformMatrix2fv))load("glUniformMatrix2fv\0".ptr);
	glUniformMatrix3fv = cast(typeof(glUniformMatrix3fv))load("glUniformMatrix3fv\0".ptr);
	glUniformMatrix4fv = cast(typeof(glUniformMatrix4fv))load("glUniformMatrix4fv\0".ptr);
	glValidateProgram = cast(typeof(glValidateProgram))load("glValidateProgram\0".ptr);
	glVertexAttrib1d = cast(typeof(glVertexAttrib1d))load("glVertexAttrib1d\0".ptr);
	glVertexAttrib1dv = cast(typeof(glVertexAttrib1dv))load("glVertexAttrib1dv\0".ptr);
	glVertexAttrib1f = cast(typeof(glVertexAttrib1f))load("glVertexAttrib1f\0".ptr);
	glVertexAttrib1fv = cast(typeof(glVertexAttrib1fv))load("glVertexAttrib1fv\0".ptr);
	glVertexAttrib1s = cast(typeof(glVertexAttrib1s))load("glVertexAttrib1s\0".ptr);
	glVertexAttrib1sv = cast(typeof(glVertexAttrib1sv))load("glVertexAttrib1sv\0".ptr);
	glVertexAttrib2d = cast(typeof(glVertexAttrib2d))load("glVertexAttrib2d\0".ptr);
	glVertexAttrib2dv = cast(typeof(glVertexAttrib2dv))load("glVertexAttrib2dv\0".ptr);
	glVertexAttrib2f = cast(typeof(glVertexAttrib2f))load("glVertexAttrib2f\0".ptr);
	glVertexAttrib2fv = cast(typeof(glVertexAttrib2fv))load("glVertexAttrib2fv\0".ptr);
	glVertexAttrib2s = cast(typeof(glVertexAttrib2s))load("glVertexAttrib2s\0".ptr);
	glVertexAttrib2sv = cast(typeof(glVertexAttrib2sv))load("glVertexAttrib2sv\0".ptr);
	glVertexAttrib3d = cast(typeof(glVertexAttrib3d))load("glVertexAttrib3d\0".ptr);
	glVertexAttrib3dv = cast(typeof(glVertexAttrib3dv))load("glVertexAttrib3dv\0".ptr);
	glVertexAttrib3f = cast(typeof(glVertexAttrib3f))load("glVertexAttrib3f\0".ptr);
	glVertexAttrib3fv = cast(typeof(glVertexAttrib3fv))load("glVertexAttrib3fv\0".ptr);
	glVertexAttrib3s = cast(typeof(glVertexAttrib3s))load("glVertexAttrib3s\0".ptr);
	glVertexAttrib3sv = cast(typeof(glVertexAttrib3sv))load("glVertexAttrib3sv\0".ptr);
	glVertexAttrib4Nbv = cast(typeof(glVertexAttrib4Nbv))load("glVertexAttrib4Nbv\0".ptr);
	glVertexAttrib4Niv = cast(typeof(glVertexAttrib4Niv))load("glVertexAttrib4Niv\0".ptr);
	glVertexAttrib4Nsv = cast(typeof(glVertexAttrib4Nsv))load("glVertexAttrib4Nsv\0".ptr);
	glVertexAttrib4Nub = cast(typeof(glVertexAttrib4Nub))load("glVertexAttrib4Nub\0".ptr);
	glVertexAttrib4Nubv = cast(typeof(glVertexAttrib4Nubv))load("glVertexAttrib4Nubv\0".ptr);
	glVertexAttrib4Nuiv = cast(typeof(glVertexAttrib4Nuiv))load("glVertexAttrib4Nuiv\0".ptr);
	glVertexAttrib4Nusv = cast(typeof(glVertexAttrib4Nusv))load("glVertexAttrib4Nusv\0".ptr);
	glVertexAttrib4bv = cast(typeof(glVertexAttrib4bv))load("glVertexAttrib4bv\0".ptr);
	glVertexAttrib4d = cast(typeof(glVertexAttrib4d))load("glVertexAttrib4d\0".ptr);
	glVertexAttrib4dv = cast(typeof(glVertexAttrib4dv))load("glVertexAttrib4dv\0".ptr);
	glVertexAttrib4f = cast(typeof(glVertexAttrib4f))load("glVertexAttrib4f\0".ptr);
	glVertexAttrib4fv = cast(typeof(glVertexAttrib4fv))load("glVertexAttrib4fv\0".ptr);
	glVertexAttrib4iv = cast(typeof(glVertexAttrib4iv))load("glVertexAttrib4iv\0".ptr);
	glVertexAttrib4s = cast(typeof(glVertexAttrib4s))load("glVertexAttrib4s\0".ptr);
	glVertexAttrib4sv = cast(typeof(glVertexAttrib4sv))load("glVertexAttrib4sv\0".ptr);
	glVertexAttrib4ubv = cast(typeof(glVertexAttrib4ubv))load("glVertexAttrib4ubv\0".ptr);
	glVertexAttrib4uiv = cast(typeof(glVertexAttrib4uiv))load("glVertexAttrib4uiv\0".ptr);
	glVertexAttrib4usv = cast(typeof(glVertexAttrib4usv))load("glVertexAttrib4usv\0".ptr);
	glVertexAttribPointer = cast(typeof(glVertexAttribPointer))load("glVertexAttribPointer\0".ptr);
	return;
}

void load_gl_GL_VERSION_2_1(void* function(const(char)* name) load) {
	if(!GL_VERSION_2_1) return;
	glUniformMatrix2x3fv = cast(typeof(glUniformMatrix2x3fv))load("glUniformMatrix2x3fv\0".ptr);
	glUniformMatrix3x2fv = cast(typeof(glUniformMatrix3x2fv))load("glUniformMatrix3x2fv\0".ptr);
	glUniformMatrix2x4fv = cast(typeof(glUniformMatrix2x4fv))load("glUniformMatrix2x4fv\0".ptr);
	glUniformMatrix4x2fv = cast(typeof(glUniformMatrix4x2fv))load("glUniformMatrix4x2fv\0".ptr);
	glUniformMatrix3x4fv = cast(typeof(glUniformMatrix3x4fv))load("glUniformMatrix3x4fv\0".ptr);
	glUniformMatrix4x3fv = cast(typeof(glUniformMatrix4x3fv))load("glUniformMatrix4x3fv\0".ptr);
	return;
}

void load_gl_GL_VERSION_3_0(void* function(const(char)* name) load) {
	if(!GL_VERSION_3_0) return;
	glColorMaski = cast(typeof(glColorMaski))load("glColorMaski\0".ptr);
	glGetBooleani_v = cast(typeof(glGetBooleani_v))load("glGetBooleani_v\0".ptr);
	glGetIntegeri_v = cast(typeof(glGetIntegeri_v))load("glGetIntegeri_v\0".ptr);
	glEnablei = cast(typeof(glEnablei))load("glEnablei\0".ptr);
	glDisablei = cast(typeof(glDisablei))load("glDisablei\0".ptr);
	glIsEnabledi = cast(typeof(glIsEnabledi))load("glIsEnabledi\0".ptr);
	glBeginTransformFeedback = cast(typeof(glBeginTransformFeedback))load("glBeginTransformFeedback\0".ptr);
	glEndTransformFeedback = cast(typeof(glEndTransformFeedback))load("glEndTransformFeedback\0".ptr);
	glBindBufferRange = cast(typeof(glBindBufferRange))load("glBindBufferRange\0".ptr);
	glBindBufferBase = cast(typeof(glBindBufferBase))load("glBindBufferBase\0".ptr);
	glTransformFeedbackVaryings = cast(typeof(glTransformFeedbackVaryings))load("glTransformFeedbackVaryings\0".ptr);
	glGetTransformFeedbackVarying = cast(typeof(glGetTransformFeedbackVarying))load("glGetTransformFeedbackVarying\0".ptr);
	glClampColor = cast(typeof(glClampColor))load("glClampColor\0".ptr);
	glBeginConditionalRender = cast(typeof(glBeginConditionalRender))load("glBeginConditionalRender\0".ptr);
	glEndConditionalRender = cast(typeof(glEndConditionalRender))load("glEndConditionalRender\0".ptr);
	glVertexAttribIPointer = cast(typeof(glVertexAttribIPointer))load("glVertexAttribIPointer\0".ptr);
	glGetVertexAttribIiv = cast(typeof(glGetVertexAttribIiv))load("glGetVertexAttribIiv\0".ptr);
	glGetVertexAttribIuiv = cast(typeof(glGetVertexAttribIuiv))load("glGetVertexAttribIuiv\0".ptr);
	glVertexAttribI1i = cast(typeof(glVertexAttribI1i))load("glVertexAttribI1i\0".ptr);
	glVertexAttribI2i = cast(typeof(glVertexAttribI2i))load("glVertexAttribI2i\0".ptr);
	glVertexAttribI3i = cast(typeof(glVertexAttribI3i))load("glVertexAttribI3i\0".ptr);
	glVertexAttribI4i = cast(typeof(glVertexAttribI4i))load("glVertexAttribI4i\0".ptr);
	glVertexAttribI1ui = cast(typeof(glVertexAttribI1ui))load("glVertexAttribI1ui\0".ptr);
	glVertexAttribI2ui = cast(typeof(glVertexAttribI2ui))load("glVertexAttribI2ui\0".ptr);
	glVertexAttribI3ui = cast(typeof(glVertexAttribI3ui))load("glVertexAttribI3ui\0".ptr);
	glVertexAttribI4ui = cast(typeof(glVertexAttribI4ui))load("glVertexAttribI4ui\0".ptr);
	glVertexAttribI1iv = cast(typeof(glVertexAttribI1iv))load("glVertexAttribI1iv\0".ptr);
	glVertexAttribI2iv = cast(typeof(glVertexAttribI2iv))load("glVertexAttribI2iv\0".ptr);
	glVertexAttribI3iv = cast(typeof(glVertexAttribI3iv))load("glVertexAttribI3iv\0".ptr);
	glVertexAttribI4iv = cast(typeof(glVertexAttribI4iv))load("glVertexAttribI4iv\0".ptr);
	glVertexAttribI1uiv = cast(typeof(glVertexAttribI1uiv))load("glVertexAttribI1uiv\0".ptr);
	glVertexAttribI2uiv = cast(typeof(glVertexAttribI2uiv))load("glVertexAttribI2uiv\0".ptr);
	glVertexAttribI3uiv = cast(typeof(glVertexAttribI3uiv))load("glVertexAttribI3uiv\0".ptr);
	glVertexAttribI4uiv = cast(typeof(glVertexAttribI4uiv))load("glVertexAttribI4uiv\0".ptr);
	glVertexAttribI4bv = cast(typeof(glVertexAttribI4bv))load("glVertexAttribI4bv\0".ptr);
	glVertexAttribI4sv = cast(typeof(glVertexAttribI4sv))load("glVertexAttribI4sv\0".ptr);
	glVertexAttribI4ubv = cast(typeof(glVertexAttribI4ubv))load("glVertexAttribI4ubv\0".ptr);
	glVertexAttribI4usv = cast(typeof(glVertexAttribI4usv))load("glVertexAttribI4usv\0".ptr);
	glGetUniformuiv = cast(typeof(glGetUniformuiv))load("glGetUniformuiv\0".ptr);
	glBindFragDataLocation = cast(typeof(glBindFragDataLocation))load("glBindFragDataLocation\0".ptr);
	glGetFragDataLocation = cast(typeof(glGetFragDataLocation))load("glGetFragDataLocation\0".ptr);
	glUniform1ui = cast(typeof(glUniform1ui))load("glUniform1ui\0".ptr);
	glUniform2ui = cast(typeof(glUniform2ui))load("glUniform2ui\0".ptr);
	glUniform3ui = cast(typeof(glUniform3ui))load("glUniform3ui\0".ptr);
	glUniform4ui = cast(typeof(glUniform4ui))load("glUniform4ui\0".ptr);
	glUniform1uiv = cast(typeof(glUniform1uiv))load("glUniform1uiv\0".ptr);
	glUniform2uiv = cast(typeof(glUniform2uiv))load("glUniform2uiv\0".ptr);
	glUniform3uiv = cast(typeof(glUniform3uiv))load("glUniform3uiv\0".ptr);
	glUniform4uiv = cast(typeof(glUniform4uiv))load("glUniform4uiv\0".ptr);
	glTexParameterIiv = cast(typeof(glTexParameterIiv))load("glTexParameterIiv\0".ptr);
	glTexParameterIuiv = cast(typeof(glTexParameterIuiv))load("glTexParameterIuiv\0".ptr);
	glGetTexParameterIiv = cast(typeof(glGetTexParameterIiv))load("glGetTexParameterIiv\0".ptr);
	glGetTexParameterIuiv = cast(typeof(glGetTexParameterIuiv))load("glGetTexParameterIuiv\0".ptr);
	glClearBufferiv = cast(typeof(glClearBufferiv))load("glClearBufferiv\0".ptr);
	glClearBufferuiv = cast(typeof(glClearBufferuiv))load("glClearBufferuiv\0".ptr);
	glClearBufferfv = cast(typeof(glClearBufferfv))load("glClearBufferfv\0".ptr);
	glClearBufferfi = cast(typeof(glClearBufferfi))load("glClearBufferfi\0".ptr);
	glGetStringi = cast(typeof(glGetStringi))load("glGetStringi\0".ptr);
	glIsRenderbuffer = cast(typeof(glIsRenderbuffer))load("glIsRenderbuffer\0".ptr);
	glBindRenderbuffer = cast(typeof(glBindRenderbuffer))load("glBindRenderbuffer\0".ptr);
	glDeleteRenderbuffers = cast(typeof(glDeleteRenderbuffers))load("glDeleteRenderbuffers\0".ptr);
	glGenRenderbuffers = cast(typeof(glGenRenderbuffers))load("glGenRenderbuffers\0".ptr);
	glRenderbufferStorage = cast(typeof(glRenderbufferStorage))load("glRenderbufferStorage\0".ptr);
	glGetRenderbufferParameteriv = cast(typeof(glGetRenderbufferParameteriv))load("glGetRenderbufferParameteriv\0".ptr);
	glIsFramebuffer = cast(typeof(glIsFramebuffer))load("glIsFramebuffer\0".ptr);
	glBindFramebuffer = cast(typeof(glBindFramebuffer))load("glBindFramebuffer\0".ptr);
	glDeleteFramebuffers = cast(typeof(glDeleteFramebuffers))load("glDeleteFramebuffers\0".ptr);
	glGenFramebuffers = cast(typeof(glGenFramebuffers))load("glGenFramebuffers\0".ptr);
	glCheckFramebufferStatus = cast(typeof(glCheckFramebufferStatus))load("glCheckFramebufferStatus\0".ptr);
	glFramebufferTexture1D = cast(typeof(glFramebufferTexture1D))load("glFramebufferTexture1D\0".ptr);
	glFramebufferTexture2D = cast(typeof(glFramebufferTexture2D))load("glFramebufferTexture2D\0".ptr);
	glFramebufferTexture3D = cast(typeof(glFramebufferTexture3D))load("glFramebufferTexture3D\0".ptr);
	glFramebufferRenderbuffer = cast(typeof(glFramebufferRenderbuffer))load("glFramebufferRenderbuffer\0".ptr);
	glGetFramebufferAttachmentParameteriv = cast(typeof(glGetFramebufferAttachmentParameteriv))load("glGetFramebufferAttachmentParameteriv\0".ptr);
	glGenerateMipmap = cast(typeof(glGenerateMipmap))load("glGenerateMipmap\0".ptr);
	glBlitFramebuffer = cast(typeof(glBlitFramebuffer))load("glBlitFramebuffer\0".ptr);
	glRenderbufferStorageMultisample = cast(typeof(glRenderbufferStorageMultisample))load("glRenderbufferStorageMultisample\0".ptr);
	glFramebufferTextureLayer = cast(typeof(glFramebufferTextureLayer))load("glFramebufferTextureLayer\0".ptr);
	glMapBufferRange = cast(typeof(glMapBufferRange))load("glMapBufferRange\0".ptr);
	glFlushMappedBufferRange = cast(typeof(glFlushMappedBufferRange))load("glFlushMappedBufferRange\0".ptr);
	glBindVertexArray = cast(typeof(glBindVertexArray))load("glBindVertexArray\0".ptr);
	glDeleteVertexArrays = cast(typeof(glDeleteVertexArrays))load("glDeleteVertexArrays\0".ptr);
	glGenVertexArrays = cast(typeof(glGenVertexArrays))load("glGenVertexArrays\0".ptr);
	glIsVertexArray = cast(typeof(glIsVertexArray))load("glIsVertexArray\0".ptr);
	return;
}

void load_gl_GL_VERSION_3_1(void* function(const(char)* name) load) {
	if(!GL_VERSION_3_1) return;
	glDrawArraysInstanced = cast(typeof(glDrawArraysInstanced))load("glDrawArraysInstanced\0".ptr);
	glDrawElementsInstanced = cast(typeof(glDrawElementsInstanced))load("glDrawElementsInstanced\0".ptr);
	glTexBuffer = cast(typeof(glTexBuffer))load("glTexBuffer\0".ptr);
	glPrimitiveRestartIndex = cast(typeof(glPrimitiveRestartIndex))load("glPrimitiveRestartIndex\0".ptr);
	glCopyBufferSubData = cast(typeof(glCopyBufferSubData))load("glCopyBufferSubData\0".ptr);
	glGetUniformIndices = cast(typeof(glGetUniformIndices))load("glGetUniformIndices\0".ptr);
	glGetActiveUniformsiv = cast(typeof(glGetActiveUniformsiv))load("glGetActiveUniformsiv\0".ptr);
	glGetActiveUniformName = cast(typeof(glGetActiveUniformName))load("glGetActiveUniformName\0".ptr);
	glGetUniformBlockIndex = cast(typeof(glGetUniformBlockIndex))load("glGetUniformBlockIndex\0".ptr);
	glGetActiveUniformBlockiv = cast(typeof(glGetActiveUniformBlockiv))load("glGetActiveUniformBlockiv\0".ptr);
	glGetActiveUniformBlockName = cast(typeof(glGetActiveUniformBlockName))load("glGetActiveUniformBlockName\0".ptr);
	glUniformBlockBinding = cast(typeof(glUniformBlockBinding))load("glUniformBlockBinding\0".ptr);
	return;
}

void load_gl_GL_VERSION_3_2(void* function(const(char)* name) load) {
	if(!GL_VERSION_3_2) return;
	glDrawElementsBaseVertex = cast(typeof(glDrawElementsBaseVertex))load("glDrawElementsBaseVertex\0".ptr);
	glDrawRangeElementsBaseVertex = cast(typeof(glDrawRangeElementsBaseVertex))load("glDrawRangeElementsBaseVertex\0".ptr);
	glDrawElementsInstancedBaseVertex = cast(typeof(glDrawElementsInstancedBaseVertex))load("glDrawElementsInstancedBaseVertex\0".ptr);
	glMultiDrawElementsBaseVertex = cast(typeof(glMultiDrawElementsBaseVertex))load("glMultiDrawElementsBaseVertex\0".ptr);
	glProvokingVertex = cast(typeof(glProvokingVertex))load("glProvokingVertex\0".ptr);
	glFenceSync = cast(typeof(glFenceSync))load("glFenceSync\0".ptr);
	glIsSync = cast(typeof(glIsSync))load("glIsSync\0".ptr);
	glDeleteSync = cast(typeof(glDeleteSync))load("glDeleteSync\0".ptr);
	glClientWaitSync = cast(typeof(glClientWaitSync))load("glClientWaitSync\0".ptr);
	glWaitSync = cast(typeof(glWaitSync))load("glWaitSync\0".ptr);
	glGetInteger64v = cast(typeof(glGetInteger64v))load("glGetInteger64v\0".ptr);
	glGetSynciv = cast(typeof(glGetSynciv))load("glGetSynciv\0".ptr);
	glGetInteger64i_v = cast(typeof(glGetInteger64i_v))load("glGetInteger64i_v\0".ptr);
	glGetBufferParameteri64v = cast(typeof(glGetBufferParameteri64v))load("glGetBufferParameteri64v\0".ptr);
	glFramebufferTexture = cast(typeof(glFramebufferTexture))load("glFramebufferTexture\0".ptr);
	glTexImage2DMultisample = cast(typeof(glTexImage2DMultisample))load("glTexImage2DMultisample\0".ptr);
	glTexImage3DMultisample = cast(typeof(glTexImage3DMultisample))load("glTexImage3DMultisample\0".ptr);
	glGetMultisamplefv = cast(typeof(glGetMultisamplefv))load("glGetMultisamplefv\0".ptr);
	glSampleMaski = cast(typeof(glSampleMaski))load("glSampleMaski\0".ptr);
	return;
}

void load_gl_GL_VERSION_3_3(void* function(const(char)* name) load) {
	if(!GL_VERSION_3_3) return;
	glBindFragDataLocationIndexed = cast(typeof(glBindFragDataLocationIndexed))load("glBindFragDataLocationIndexed\0".ptr);
	glGetFragDataIndex = cast(typeof(glGetFragDataIndex))load("glGetFragDataIndex\0".ptr);
	glGenSamplers = cast(typeof(glGenSamplers))load("glGenSamplers\0".ptr);
	glDeleteSamplers = cast(typeof(glDeleteSamplers))load("glDeleteSamplers\0".ptr);
	glIsSampler = cast(typeof(glIsSampler))load("glIsSampler\0".ptr);
	glBindSampler = cast(typeof(glBindSampler))load("glBindSampler\0".ptr);
	glSamplerParameteri = cast(typeof(glSamplerParameteri))load("glSamplerParameteri\0".ptr);
	glSamplerParameteriv = cast(typeof(glSamplerParameteriv))load("glSamplerParameteriv\0".ptr);
	glSamplerParameterf = cast(typeof(glSamplerParameterf))load("glSamplerParameterf\0".ptr);
	glSamplerParameterfv = cast(typeof(glSamplerParameterfv))load("glSamplerParameterfv\0".ptr);
	glSamplerParameterIiv = cast(typeof(glSamplerParameterIiv))load("glSamplerParameterIiv\0".ptr);
	glSamplerParameterIuiv = cast(typeof(glSamplerParameterIuiv))load("glSamplerParameterIuiv\0".ptr);
	glGetSamplerParameteriv = cast(typeof(glGetSamplerParameteriv))load("glGetSamplerParameteriv\0".ptr);
	glGetSamplerParameterIiv = cast(typeof(glGetSamplerParameterIiv))load("glGetSamplerParameterIiv\0".ptr);
	glGetSamplerParameterfv = cast(typeof(glGetSamplerParameterfv))load("glGetSamplerParameterfv\0".ptr);
	glGetSamplerParameterIuiv = cast(typeof(glGetSamplerParameterIuiv))load("glGetSamplerParameterIuiv\0".ptr);
	glQueryCounter = cast(typeof(glQueryCounter))load("glQueryCounter\0".ptr);
	glGetQueryObjecti64v = cast(typeof(glGetQueryObjecti64v))load("glGetQueryObjecti64v\0".ptr);
	glGetQueryObjectui64v = cast(typeof(glGetQueryObjectui64v))load("glGetQueryObjectui64v\0".ptr);
	glVertexAttribDivisor = cast(typeof(glVertexAttribDivisor))load("glVertexAttribDivisor\0".ptr);
	glVertexAttribP1ui = cast(typeof(glVertexAttribP1ui))load("glVertexAttribP1ui\0".ptr);
	glVertexAttribP1uiv = cast(typeof(glVertexAttribP1uiv))load("glVertexAttribP1uiv\0".ptr);
	glVertexAttribP2ui = cast(typeof(glVertexAttribP2ui))load("glVertexAttribP2ui\0".ptr);
	glVertexAttribP2uiv = cast(typeof(glVertexAttribP2uiv))load("glVertexAttribP2uiv\0".ptr);
	glVertexAttribP3ui = cast(typeof(glVertexAttribP3ui))load("glVertexAttribP3ui\0".ptr);
	glVertexAttribP3uiv = cast(typeof(glVertexAttribP3uiv))load("glVertexAttribP3uiv\0".ptr);
	glVertexAttribP4ui = cast(typeof(glVertexAttribP4ui))load("glVertexAttribP4ui\0".ptr);
	glVertexAttribP4uiv = cast(typeof(glVertexAttribP4uiv))load("glVertexAttribP4uiv\0".ptr);
	glVertexP2ui = cast(typeof(glVertexP2ui))load("glVertexP2ui\0".ptr);
	glVertexP2uiv = cast(typeof(glVertexP2uiv))load("glVertexP2uiv\0".ptr);
	glVertexP3ui = cast(typeof(glVertexP3ui))load("glVertexP3ui\0".ptr);
	glVertexP3uiv = cast(typeof(glVertexP3uiv))load("glVertexP3uiv\0".ptr);
	glVertexP4ui = cast(typeof(glVertexP4ui))load("glVertexP4ui\0".ptr);
	glVertexP4uiv = cast(typeof(glVertexP4uiv))load("glVertexP4uiv\0".ptr);
	glTexCoordP1ui = cast(typeof(glTexCoordP1ui))load("glTexCoordP1ui\0".ptr);
	glTexCoordP1uiv = cast(typeof(glTexCoordP1uiv))load("glTexCoordP1uiv\0".ptr);
	glTexCoordP2ui = cast(typeof(glTexCoordP2ui))load("glTexCoordP2ui\0".ptr);
	glTexCoordP2uiv = cast(typeof(glTexCoordP2uiv))load("glTexCoordP2uiv\0".ptr);
	glTexCoordP3ui = cast(typeof(glTexCoordP3ui))load("glTexCoordP3ui\0".ptr);
	glTexCoordP3uiv = cast(typeof(glTexCoordP3uiv))load("glTexCoordP3uiv\0".ptr);
	glTexCoordP4ui = cast(typeof(glTexCoordP4ui))load("glTexCoordP4ui\0".ptr);
	glTexCoordP4uiv = cast(typeof(glTexCoordP4uiv))load("glTexCoordP4uiv\0".ptr);
	glMultiTexCoordP1ui = cast(typeof(glMultiTexCoordP1ui))load("glMultiTexCoordP1ui\0".ptr);
	glMultiTexCoordP1uiv = cast(typeof(glMultiTexCoordP1uiv))load("glMultiTexCoordP1uiv\0".ptr);
	glMultiTexCoordP2ui = cast(typeof(glMultiTexCoordP2ui))load("glMultiTexCoordP2ui\0".ptr);
	glMultiTexCoordP2uiv = cast(typeof(glMultiTexCoordP2uiv))load("glMultiTexCoordP2uiv\0".ptr);
	glMultiTexCoordP3ui = cast(typeof(glMultiTexCoordP3ui))load("glMultiTexCoordP3ui\0".ptr);
	glMultiTexCoordP3uiv = cast(typeof(glMultiTexCoordP3uiv))load("glMultiTexCoordP3uiv\0".ptr);
	glMultiTexCoordP4ui = cast(typeof(glMultiTexCoordP4ui))load("glMultiTexCoordP4ui\0".ptr);
	glMultiTexCoordP4uiv = cast(typeof(glMultiTexCoordP4uiv))load("glMultiTexCoordP4uiv\0".ptr);
	glNormalP3ui = cast(typeof(glNormalP3ui))load("glNormalP3ui\0".ptr);
	glNormalP3uiv = cast(typeof(glNormalP3uiv))load("glNormalP3uiv\0".ptr);
	glColorP3ui = cast(typeof(glColorP3ui))load("glColorP3ui\0".ptr);
	glColorP3uiv = cast(typeof(glColorP3uiv))load("glColorP3uiv\0".ptr);
	glColorP4ui = cast(typeof(glColorP4ui))load("glColorP4ui\0".ptr);
	glColorP4uiv = cast(typeof(glColorP4uiv))load("glColorP4uiv\0".ptr);
	glSecondaryColorP3ui = cast(typeof(glSecondaryColorP3ui))load("glSecondaryColorP3ui\0".ptr);
	glSecondaryColorP3uiv = cast(typeof(glSecondaryColorP3uiv))load("glSecondaryColorP3uiv\0".ptr);
	return;
}

void load_gl_GL_VERSION_4_0(void* function(const(char)* name) load) {
	if(!GL_VERSION_4_0) return;
	glMinSampleShading = cast(typeof(glMinSampleShading))load("glMinSampleShading\0".ptr);
	glBlendEquationi = cast(typeof(glBlendEquationi))load("glBlendEquationi\0".ptr);
	glBlendEquationSeparatei = cast(typeof(glBlendEquationSeparatei))load("glBlendEquationSeparatei\0".ptr);
	glBlendFunci = cast(typeof(glBlendFunci))load("glBlendFunci\0".ptr);
	glBlendFuncSeparatei = cast(typeof(glBlendFuncSeparatei))load("glBlendFuncSeparatei\0".ptr);
	glDrawArraysIndirect = cast(typeof(glDrawArraysIndirect))load("glDrawArraysIndirect\0".ptr);
	glDrawElementsIndirect = cast(typeof(glDrawElementsIndirect))load("glDrawElementsIndirect\0".ptr);
	glUniform1d = cast(typeof(glUniform1d))load("glUniform1d\0".ptr);
	glUniform2d = cast(typeof(glUniform2d))load("glUniform2d\0".ptr);
	glUniform3d = cast(typeof(glUniform3d))load("glUniform3d\0".ptr);
	glUniform4d = cast(typeof(glUniform4d))load("glUniform4d\0".ptr);
	glUniform1dv = cast(typeof(glUniform1dv))load("glUniform1dv\0".ptr);
	glUniform2dv = cast(typeof(glUniform2dv))load("glUniform2dv\0".ptr);
	glUniform3dv = cast(typeof(glUniform3dv))load("glUniform3dv\0".ptr);
	glUniform4dv = cast(typeof(glUniform4dv))load("glUniform4dv\0".ptr);
	glUniformMatrix2dv = cast(typeof(glUniformMatrix2dv))load("glUniformMatrix2dv\0".ptr);
	glUniformMatrix3dv = cast(typeof(glUniformMatrix3dv))load("glUniformMatrix3dv\0".ptr);
	glUniformMatrix4dv = cast(typeof(glUniformMatrix4dv))load("glUniformMatrix4dv\0".ptr);
	glUniformMatrix2x3dv = cast(typeof(glUniformMatrix2x3dv))load("glUniformMatrix2x3dv\0".ptr);
	glUniformMatrix2x4dv = cast(typeof(glUniformMatrix2x4dv))load("glUniformMatrix2x4dv\0".ptr);
	glUniformMatrix3x2dv = cast(typeof(glUniformMatrix3x2dv))load("glUniformMatrix3x2dv\0".ptr);
	glUniformMatrix3x4dv = cast(typeof(glUniformMatrix3x4dv))load("glUniformMatrix3x4dv\0".ptr);
	glUniformMatrix4x2dv = cast(typeof(glUniformMatrix4x2dv))load("glUniformMatrix4x2dv\0".ptr);
	glUniformMatrix4x3dv = cast(typeof(glUniformMatrix4x3dv))load("glUniformMatrix4x3dv\0".ptr);
	glGetUniformdv = cast(typeof(glGetUniformdv))load("glGetUniformdv\0".ptr);
	glGetSubroutineUniformLocation = cast(typeof(glGetSubroutineUniformLocation))load("glGetSubroutineUniformLocation\0".ptr);
	glGetSubroutineIndex = cast(typeof(glGetSubroutineIndex))load("glGetSubroutineIndex\0".ptr);
	glGetActiveSubroutineUniformiv = cast(typeof(glGetActiveSubroutineUniformiv))load("glGetActiveSubroutineUniformiv\0".ptr);
	glGetActiveSubroutineUniformName = cast(typeof(glGetActiveSubroutineUniformName))load("glGetActiveSubroutineUniformName\0".ptr);
	glGetActiveSubroutineName = cast(typeof(glGetActiveSubroutineName))load("glGetActiveSubroutineName\0".ptr);
	glUniformSubroutinesuiv = cast(typeof(glUniformSubroutinesuiv))load("glUniformSubroutinesuiv\0".ptr);
	glGetUniformSubroutineuiv = cast(typeof(glGetUniformSubroutineuiv))load("glGetUniformSubroutineuiv\0".ptr);
	glGetProgramStageiv = cast(typeof(glGetProgramStageiv))load("glGetProgramStageiv\0".ptr);
	glPatchParameteri = cast(typeof(glPatchParameteri))load("glPatchParameteri\0".ptr);
	glPatchParameterfv = cast(typeof(glPatchParameterfv))load("glPatchParameterfv\0".ptr);
	glBindTransformFeedback = cast(typeof(glBindTransformFeedback))load("glBindTransformFeedback\0".ptr);
	glDeleteTransformFeedbacks = cast(typeof(glDeleteTransformFeedbacks))load("glDeleteTransformFeedbacks\0".ptr);
	glGenTransformFeedbacks = cast(typeof(glGenTransformFeedbacks))load("glGenTransformFeedbacks\0".ptr);
	glIsTransformFeedback = cast(typeof(glIsTransformFeedback))load("glIsTransformFeedback\0".ptr);
	glPauseTransformFeedback = cast(typeof(glPauseTransformFeedback))load("glPauseTransformFeedback\0".ptr);
	glResumeTransformFeedback = cast(typeof(glResumeTransformFeedback))load("glResumeTransformFeedback\0".ptr);
	glDrawTransformFeedback = cast(typeof(glDrawTransformFeedback))load("glDrawTransformFeedback\0".ptr);
	glDrawTransformFeedbackStream = cast(typeof(glDrawTransformFeedbackStream))load("glDrawTransformFeedbackStream\0".ptr);
	glBeginQueryIndexed = cast(typeof(glBeginQueryIndexed))load("glBeginQueryIndexed\0".ptr);
	glEndQueryIndexed = cast(typeof(glEndQueryIndexed))load("glEndQueryIndexed\0".ptr);
	glGetQueryIndexediv = cast(typeof(glGetQueryIndexediv))load("glGetQueryIndexediv\0".ptr);
	return;
}

void load_gl_GL_VERSION_4_1(void* function(const(char)* name) load) {
	if(!GL_VERSION_4_1) return;
	glReleaseShaderCompiler = cast(typeof(glReleaseShaderCompiler))load("glReleaseShaderCompiler\0".ptr);
	glShaderBinary = cast(typeof(glShaderBinary))load("glShaderBinary\0".ptr);
	glGetShaderPrecisionFormat = cast(typeof(glGetShaderPrecisionFormat))load("glGetShaderPrecisionFormat\0".ptr);
	glDepthRangef = cast(typeof(glDepthRangef))load("glDepthRangef\0".ptr);
	glClearDepthf = cast(typeof(glClearDepthf))load("glClearDepthf\0".ptr);
	glGetProgramBinary = cast(typeof(glGetProgramBinary))load("glGetProgramBinary\0".ptr);
	glProgramBinary = cast(typeof(glProgramBinary))load("glProgramBinary\0".ptr);
	glProgramParameteri = cast(typeof(glProgramParameteri))load("glProgramParameteri\0".ptr);
	glUseProgramStages = cast(typeof(glUseProgramStages))load("glUseProgramStages\0".ptr);
	glActiveShaderProgram = cast(typeof(glActiveShaderProgram))load("glActiveShaderProgram\0".ptr);
	glCreateShaderProgramv = cast(typeof(glCreateShaderProgramv))load("glCreateShaderProgramv\0".ptr);
	glBindProgramPipeline = cast(typeof(glBindProgramPipeline))load("glBindProgramPipeline\0".ptr);
	glDeleteProgramPipelines = cast(typeof(glDeleteProgramPipelines))load("glDeleteProgramPipelines\0".ptr);
	glGenProgramPipelines = cast(typeof(glGenProgramPipelines))load("glGenProgramPipelines\0".ptr);
	glIsProgramPipeline = cast(typeof(glIsProgramPipeline))load("glIsProgramPipeline\0".ptr);
	glGetProgramPipelineiv = cast(typeof(glGetProgramPipelineiv))load("glGetProgramPipelineiv\0".ptr);
	glProgramUniform1i = cast(typeof(glProgramUniform1i))load("glProgramUniform1i\0".ptr);
	glProgramUniform1iv = cast(typeof(glProgramUniform1iv))load("glProgramUniform1iv\0".ptr);
	glProgramUniform1f = cast(typeof(glProgramUniform1f))load("glProgramUniform1f\0".ptr);
	glProgramUniform1fv = cast(typeof(glProgramUniform1fv))load("glProgramUniform1fv\0".ptr);
	glProgramUniform1d = cast(typeof(glProgramUniform1d))load("glProgramUniform1d\0".ptr);
	glProgramUniform1dv = cast(typeof(glProgramUniform1dv))load("glProgramUniform1dv\0".ptr);
	glProgramUniform1ui = cast(typeof(glProgramUniform1ui))load("glProgramUniform1ui\0".ptr);
	glProgramUniform1uiv = cast(typeof(glProgramUniform1uiv))load("glProgramUniform1uiv\0".ptr);
	glProgramUniform2i = cast(typeof(glProgramUniform2i))load("glProgramUniform2i\0".ptr);
	glProgramUniform2iv = cast(typeof(glProgramUniform2iv))load("glProgramUniform2iv\0".ptr);
	glProgramUniform2f = cast(typeof(glProgramUniform2f))load("glProgramUniform2f\0".ptr);
	glProgramUniform2fv = cast(typeof(glProgramUniform2fv))load("glProgramUniform2fv\0".ptr);
	glProgramUniform2d = cast(typeof(glProgramUniform2d))load("glProgramUniform2d\0".ptr);
	glProgramUniform2dv = cast(typeof(glProgramUniform2dv))load("glProgramUniform2dv\0".ptr);
	glProgramUniform2ui = cast(typeof(glProgramUniform2ui))load("glProgramUniform2ui\0".ptr);
	glProgramUniform2uiv = cast(typeof(glProgramUniform2uiv))load("glProgramUniform2uiv\0".ptr);
	glProgramUniform3i = cast(typeof(glProgramUniform3i))load("glProgramUniform3i\0".ptr);
	glProgramUniform3iv = cast(typeof(glProgramUniform3iv))load("glProgramUniform3iv\0".ptr);
	glProgramUniform3f = cast(typeof(glProgramUniform3f))load("glProgramUniform3f\0".ptr);
	glProgramUniform3fv = cast(typeof(glProgramUniform3fv))load("glProgramUniform3fv\0".ptr);
	glProgramUniform3d = cast(typeof(glProgramUniform3d))load("glProgramUniform3d\0".ptr);
	glProgramUniform3dv = cast(typeof(glProgramUniform3dv))load("glProgramUniform3dv\0".ptr);
	glProgramUniform3ui = cast(typeof(glProgramUniform3ui))load("glProgramUniform3ui\0".ptr);
	glProgramUniform3uiv = cast(typeof(glProgramUniform3uiv))load("glProgramUniform3uiv\0".ptr);
	glProgramUniform4i = cast(typeof(glProgramUniform4i))load("glProgramUniform4i\0".ptr);
	glProgramUniform4iv = cast(typeof(glProgramUniform4iv))load("glProgramUniform4iv\0".ptr);
	glProgramUniform4f = cast(typeof(glProgramUniform4f))load("glProgramUniform4f\0".ptr);
	glProgramUniform4fv = cast(typeof(glProgramUniform4fv))load("glProgramUniform4fv\0".ptr);
	glProgramUniform4d = cast(typeof(glProgramUniform4d))load("glProgramUniform4d\0".ptr);
	glProgramUniform4dv = cast(typeof(glProgramUniform4dv))load("glProgramUniform4dv\0".ptr);
	glProgramUniform4ui = cast(typeof(glProgramUniform4ui))load("glProgramUniform4ui\0".ptr);
	glProgramUniform4uiv = cast(typeof(glProgramUniform4uiv))load("glProgramUniform4uiv\0".ptr);
	glProgramUniformMatrix2fv = cast(typeof(glProgramUniformMatrix2fv))load("glProgramUniformMatrix2fv\0".ptr);
	glProgramUniformMatrix3fv = cast(typeof(glProgramUniformMatrix3fv))load("glProgramUniformMatrix3fv\0".ptr);
	glProgramUniformMatrix4fv = cast(typeof(glProgramUniformMatrix4fv))load("glProgramUniformMatrix4fv\0".ptr);
	glProgramUniformMatrix2dv = cast(typeof(glProgramUniformMatrix2dv))load("glProgramUniformMatrix2dv\0".ptr);
	glProgramUniformMatrix3dv = cast(typeof(glProgramUniformMatrix3dv))load("glProgramUniformMatrix3dv\0".ptr);
	glProgramUniformMatrix4dv = cast(typeof(glProgramUniformMatrix4dv))load("glProgramUniformMatrix4dv\0".ptr);
	glProgramUniformMatrix2x3fv = cast(typeof(glProgramUniformMatrix2x3fv))load("glProgramUniformMatrix2x3fv\0".ptr);
	glProgramUniformMatrix3x2fv = cast(typeof(glProgramUniformMatrix3x2fv))load("glProgramUniformMatrix3x2fv\0".ptr);
	glProgramUniformMatrix2x4fv = cast(typeof(glProgramUniformMatrix2x4fv))load("glProgramUniformMatrix2x4fv\0".ptr);
	glProgramUniformMatrix4x2fv = cast(typeof(glProgramUniformMatrix4x2fv))load("glProgramUniformMatrix4x2fv\0".ptr);
	glProgramUniformMatrix3x4fv = cast(typeof(glProgramUniformMatrix3x4fv))load("glProgramUniformMatrix3x4fv\0".ptr);
	glProgramUniformMatrix4x3fv = cast(typeof(glProgramUniformMatrix4x3fv))load("glProgramUniformMatrix4x3fv\0".ptr);
	glProgramUniformMatrix2x3dv = cast(typeof(glProgramUniformMatrix2x3dv))load("glProgramUniformMatrix2x3dv\0".ptr);
	glProgramUniformMatrix3x2dv = cast(typeof(glProgramUniformMatrix3x2dv))load("glProgramUniformMatrix3x2dv\0".ptr);
	glProgramUniformMatrix2x4dv = cast(typeof(glProgramUniformMatrix2x4dv))load("glProgramUniformMatrix2x4dv\0".ptr);
	glProgramUniformMatrix4x2dv = cast(typeof(glProgramUniformMatrix4x2dv))load("glProgramUniformMatrix4x2dv\0".ptr);
	glProgramUniformMatrix3x4dv = cast(typeof(glProgramUniformMatrix3x4dv))load("glProgramUniformMatrix3x4dv\0".ptr);
	glProgramUniformMatrix4x3dv = cast(typeof(glProgramUniformMatrix4x3dv))load("glProgramUniformMatrix4x3dv\0".ptr);
	glValidateProgramPipeline = cast(typeof(glValidateProgramPipeline))load("glValidateProgramPipeline\0".ptr);
	glGetProgramPipelineInfoLog = cast(typeof(glGetProgramPipelineInfoLog))load("glGetProgramPipelineInfoLog\0".ptr);
	glVertexAttribL1d = cast(typeof(glVertexAttribL1d))load("glVertexAttribL1d\0".ptr);
	glVertexAttribL2d = cast(typeof(glVertexAttribL2d))load("glVertexAttribL2d\0".ptr);
	glVertexAttribL3d = cast(typeof(glVertexAttribL3d))load("glVertexAttribL3d\0".ptr);
	glVertexAttribL4d = cast(typeof(glVertexAttribL4d))load("glVertexAttribL4d\0".ptr);
	glVertexAttribL1dv = cast(typeof(glVertexAttribL1dv))load("glVertexAttribL1dv\0".ptr);
	glVertexAttribL2dv = cast(typeof(glVertexAttribL2dv))load("glVertexAttribL2dv\0".ptr);
	glVertexAttribL3dv = cast(typeof(glVertexAttribL3dv))load("glVertexAttribL3dv\0".ptr);
	glVertexAttribL4dv = cast(typeof(glVertexAttribL4dv))load("glVertexAttribL4dv\0".ptr);
	glVertexAttribLPointer = cast(typeof(glVertexAttribLPointer))load("glVertexAttribLPointer\0".ptr);
	glGetVertexAttribLdv = cast(typeof(glGetVertexAttribLdv))load("glGetVertexAttribLdv\0".ptr);
	glViewportArrayv = cast(typeof(glViewportArrayv))load("glViewportArrayv\0".ptr);
	glViewportIndexedf = cast(typeof(glViewportIndexedf))load("glViewportIndexedf\0".ptr);
	glViewportIndexedfv = cast(typeof(glViewportIndexedfv))load("glViewportIndexedfv\0".ptr);
	glScissorArrayv = cast(typeof(glScissorArrayv))load("glScissorArrayv\0".ptr);
	glScissorIndexed = cast(typeof(glScissorIndexed))load("glScissorIndexed\0".ptr);
	glScissorIndexedv = cast(typeof(glScissorIndexedv))load("glScissorIndexedv\0".ptr);
	glDepthRangeArrayv = cast(typeof(glDepthRangeArrayv))load("glDepthRangeArrayv\0".ptr);
	glDepthRangeIndexed = cast(typeof(glDepthRangeIndexed))load("glDepthRangeIndexed\0".ptr);
	glGetFloati_v = cast(typeof(glGetFloati_v))load("glGetFloati_v\0".ptr);
	glGetDoublei_v = cast(typeof(glGetDoublei_v))load("glGetDoublei_v\0".ptr);
	return;
}

void load_gl_GL_VERSION_4_2(void* function(const(char)* name) load) {
	if(!GL_VERSION_4_2) return;
	glDrawArraysInstancedBaseInstance = cast(typeof(glDrawArraysInstancedBaseInstance))load("glDrawArraysInstancedBaseInstance\0".ptr);
	glDrawElementsInstancedBaseInstance = cast(typeof(glDrawElementsInstancedBaseInstance))load("glDrawElementsInstancedBaseInstance\0".ptr);
	glDrawElementsInstancedBaseVertexBaseInstance = cast(typeof(glDrawElementsInstancedBaseVertexBaseInstance))load("glDrawElementsInstancedBaseVertexBaseInstance\0".ptr);
	glGetInternalformati64v = cast(typeof(glGetInternalformati64v))load("glGetInternalformati64v\0".ptr);
	glGetActiveAtomicCounterBufferiv = cast(typeof(glGetActiveAtomicCounterBufferiv))load("glGetActiveAtomicCounterBufferiv\0".ptr);
	glBindImageTexture = cast(typeof(glBindImageTexture))load("glBindImageTexture\0".ptr);
	glMemoryBarrier = cast(typeof(glMemoryBarrier))load("glMemoryBarrier\0".ptr);
	glTexStorage1D = cast(typeof(glTexStorage1D))load("glTexStorage1D\0".ptr);
	glTexStorage2D = cast(typeof(glTexStorage2D))load("glTexStorage2D\0".ptr);
	glTexStorage3D = cast(typeof(glTexStorage3D))load("glTexStorage3D\0".ptr);
	glDrawTransformFeedbackInstanced = cast(typeof(glDrawTransformFeedbackInstanced))load("glDrawTransformFeedbackInstanced\0".ptr);
	glDrawTransformFeedbackStreamInstanced = cast(typeof(glDrawTransformFeedbackStreamInstanced))load("glDrawTransformFeedbackStreamInstanced\0".ptr);
	return;
}

void load_gl_GL_VERSION_4_3(void* function(const(char)* name) load) {
	if(!GL_VERSION_4_3) return;
	glClearBufferData = cast(typeof(glClearBufferData))load("glClearBufferData\0".ptr);
	glClearBufferSubData = cast(typeof(glClearBufferSubData))load("glClearBufferSubData\0".ptr);
	glDispatchCompute = cast(typeof(glDispatchCompute))load("glDispatchCompute\0".ptr);
	glDispatchComputeIndirect = cast(typeof(glDispatchComputeIndirect))load("glDispatchComputeIndirect\0".ptr);
	glCopyImageSubData = cast(typeof(glCopyImageSubData))load("glCopyImageSubData\0".ptr);
	glFramebufferParameteri = cast(typeof(glFramebufferParameteri))load("glFramebufferParameteri\0".ptr);
	glGetFramebufferParameteriv = cast(typeof(glGetFramebufferParameteriv))load("glGetFramebufferParameteriv\0".ptr);
	glGetInternalformati64v = cast(typeof(glGetInternalformati64v))load("glGetInternalformati64v\0".ptr);
	glInvalidateTexSubImage = cast(typeof(glInvalidateTexSubImage))load("glInvalidateTexSubImage\0".ptr);
	glInvalidateTexImage = cast(typeof(glInvalidateTexImage))load("glInvalidateTexImage\0".ptr);
	glInvalidateBufferSubData = cast(typeof(glInvalidateBufferSubData))load("glInvalidateBufferSubData\0".ptr);
	glInvalidateBufferData = cast(typeof(glInvalidateBufferData))load("glInvalidateBufferData\0".ptr);
	glInvalidateFramebuffer = cast(typeof(glInvalidateFramebuffer))load("glInvalidateFramebuffer\0".ptr);
	glInvalidateSubFramebuffer = cast(typeof(glInvalidateSubFramebuffer))load("glInvalidateSubFramebuffer\0".ptr);
	glMultiDrawArraysIndirect = cast(typeof(glMultiDrawArraysIndirect))load("glMultiDrawArraysIndirect\0".ptr);
	glMultiDrawElementsIndirect = cast(typeof(glMultiDrawElementsIndirect))load("glMultiDrawElementsIndirect\0".ptr);
	glGetProgramInterfaceiv = cast(typeof(glGetProgramInterfaceiv))load("glGetProgramInterfaceiv\0".ptr);
	glGetProgramResourceIndex = cast(typeof(glGetProgramResourceIndex))load("glGetProgramResourceIndex\0".ptr);
	glGetProgramResourceName = cast(typeof(glGetProgramResourceName))load("glGetProgramResourceName\0".ptr);
	glGetProgramResourceiv = cast(typeof(glGetProgramResourceiv))load("glGetProgramResourceiv\0".ptr);
	glGetProgramResourceLocation = cast(typeof(glGetProgramResourceLocation))load("glGetProgramResourceLocation\0".ptr);
	glGetProgramResourceLocationIndex = cast(typeof(glGetProgramResourceLocationIndex))load("glGetProgramResourceLocationIndex\0".ptr);
	glShaderStorageBlockBinding = cast(typeof(glShaderStorageBlockBinding))load("glShaderStorageBlockBinding\0".ptr);
	glTexBufferRange = cast(typeof(glTexBufferRange))load("glTexBufferRange\0".ptr);
	glTexStorage2DMultisample = cast(typeof(glTexStorage2DMultisample))load("glTexStorage2DMultisample\0".ptr);
	glTexStorage3DMultisample = cast(typeof(glTexStorage3DMultisample))load("glTexStorage3DMultisample\0".ptr);
	glTextureView = cast(typeof(glTextureView))load("glTextureView\0".ptr);
	glBindVertexBuffer = cast(typeof(glBindVertexBuffer))load("glBindVertexBuffer\0".ptr);
	glVertexAttribFormat = cast(typeof(glVertexAttribFormat))load("glVertexAttribFormat\0".ptr);
	glVertexAttribIFormat = cast(typeof(glVertexAttribIFormat))load("glVertexAttribIFormat\0".ptr);
	glVertexAttribLFormat = cast(typeof(glVertexAttribLFormat))load("glVertexAttribLFormat\0".ptr);
	glVertexAttribBinding = cast(typeof(glVertexAttribBinding))load("glVertexAttribBinding\0".ptr);
	glVertexBindingDivisor = cast(typeof(glVertexBindingDivisor))load("glVertexBindingDivisor\0".ptr);
	glDebugMessageControl = cast(typeof(glDebugMessageControl))load("glDebugMessageControl\0".ptr);
	glDebugMessageInsert = cast(typeof(glDebugMessageInsert))load("glDebugMessageInsert\0".ptr);
	glDebugMessageCallback = cast(typeof(glDebugMessageCallback))load("glDebugMessageCallback\0".ptr);
	glGetDebugMessageLog = cast(typeof(glGetDebugMessageLog))load("glGetDebugMessageLog\0".ptr);
	glPushDebugGroup = cast(typeof(glPushDebugGroup))load("glPushDebugGroup\0".ptr);
	glPopDebugGroup = cast(typeof(glPopDebugGroup))load("glPopDebugGroup\0".ptr);
	glObjectLabel = cast(typeof(glObjectLabel))load("glObjectLabel\0".ptr);
	glGetObjectLabel = cast(typeof(glGetObjectLabel))load("glGetObjectLabel\0".ptr);
	glObjectPtrLabel = cast(typeof(glObjectPtrLabel))load("glObjectPtrLabel\0".ptr);
	glGetObjectPtrLabel = cast(typeof(glGetObjectPtrLabel))load("glGetObjectPtrLabel\0".ptr);
	return;
}

void load_gl_GL_VERSION_4_4(void* function(const(char)* name) load) {
	if(!GL_VERSION_4_4) return;
	glBufferStorage = cast(typeof(glBufferStorage))load("glBufferStorage\0".ptr);
	glClearTexImage = cast(typeof(glClearTexImage))load("glClearTexImage\0".ptr);
	glClearTexSubImage = cast(typeof(glClearTexSubImage))load("glClearTexSubImage\0".ptr);
	glBindBuffersBase = cast(typeof(glBindBuffersBase))load("glBindBuffersBase\0".ptr);
	glBindBuffersRange = cast(typeof(glBindBuffersRange))load("glBindBuffersRange\0".ptr);
	glBindTextures = cast(typeof(glBindTextures))load("glBindTextures\0".ptr);
	glBindSamplers = cast(typeof(glBindSamplers))load("glBindSamplers\0".ptr);
	glBindImageTextures = cast(typeof(glBindImageTextures))load("glBindImageTextures\0".ptr);
	glBindVertexBuffers = cast(typeof(glBindVertexBuffers))load("glBindVertexBuffers\0".ptr);
	return;
}

