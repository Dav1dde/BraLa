module glad.gl.types;


alias GLvoid = void;
alias GLintptr = ptrdiff_t;
alias GLsizei = int;
alias GLchar = char;
alias GLcharARB = byte;
alias GLushort = ushort;
alias GLint64EXT = long;
alias GLshort = short;
alias GLuint64 = ulong;
alias GLhalfARB = ushort;
alias GLubyte = ubyte;
alias GLdouble = double;
alias GLhandleARB = uint;
alias GLint64 = long;
alias GLenum = uint;
alias GLeglImageOES = void*;
alias GLintptrARB = ptrdiff_t;
alias GLsizeiptr = ptrdiff_t;
alias GLint = int;
alias GLboolean = ubyte;
alias GLbitfield = uint;
alias GLsizeiptrARB = ptrdiff_t;
alias GLfloat = float;
alias GLuint64EXT = ulong;
alias GLclampf = float;
alias GLbyte = byte;
alias GLclampd = double;
alias GLuint = uint;
alias GLvdpauSurfaceNV = ptrdiff_t;
alias GLfixed = int;
alias GLhalf = ushort;
alias GLclampx = int;
alias GLhalfNV = ushort;
struct ___GLsync; alias __GLsync = ___GLsync*;
alias GLsync = __GLsync*;
struct __cl_context; alias _cl_context = __cl_context*;
struct __cl_event; alias _cl_event = __cl_event*;
extern(System) {
alias GLDEBUGPROC = void function(GLenum, GLenum, GLuint, GLenum, GLsizei, in GLchar*, GLvoid*);
alias GLDEBUGPROCARB = GLDEBUGPROC;
alias GLDEBUGPROCKHR = GLDEBUGPROC;
alias GLDEBUGPROCAMD = void function(GLuint, GLenum, GLenum, GLsizei, in GLchar*, GLvoid*);
}
