module brala.types;

private {
    import derelict.devil.il;
    import std.string : toStringz, format;
}

struct Image {
    ILuint id;
    ILubyte* data;
    ILint width;
    ILint height;
    ILenum dest_format;
    ILenum dest_type;
    
    this(ILuint id_) {
        id = id_;
    
        data = ilGetData();
        width = ilGetInteger(IL_IMAGE_WIDTH);
        height = ilGetInteger(IL_IMAGE_HEIGHT);
        
        dest_format = ilGetInteger(IL_IMAGE_FORMAT);
        dest_type = ilGetInteger(IL_IMAGE_TYPE);
    }
    
    this(ILuint id_, ILubyte* d, ILint w, ILint h, ILenum df, ILenum dt) {
        data = d;
        id = id_;
        width = w;
        height = h;
        dest_format = df;
        dest_type = dt;
    }
    
    static Image from_file(string filename) {
        ILuint id;
        ilGenImages(1, &id);
        ilBindImage(id);
       
        if(!ilLoadImage(toStringz(filename.dup))) {
            throw new Exception(format("loading the image \"%s\" failed!", filename));
        }

        ilConvertImage(IL_RGB, IL_UNSIGNED_BYTE);
        
        return Image(id);
    }
}