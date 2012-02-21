module brala.types;

private {
    version(stb) {
        import stb_image : stbi_load, stbi_image_free;
        import glamour.gl : GL_RGB, GL_RGBA, GL_UNSIGNED_BYTE;
    } else {
        import derelict.devil.il;
    }
    import std.string : toStringz, format;
    import std.traits : ReturnType, isCallable;
    
    import brala.exception : ImageException;
}

version(stb) {
    // stb is threadsafe :)
    struct Image {
        ubyte* data;
        int width;
        int height;
        
        int dest_format;
        int dest_type;
        
        this(ubyte* d, int w, int h, int df, int dt) {
            data = d;
            width = w;
            height = h;
            dest_format = df;
            dest_type = dt;
        }
        
        static Image from_file(string filename) {
            int x;
            int y;
            int comp;
            ubyte* data = stbi_load(toStringz(filename), &x, &y, &comp, 0);

            if(data is null) {
                throw new ImageException("Unable to load image: " ~ filename);
            }
            
            scope(exit) stbi_image_free(data);
            scope(failure) stbi_image_free(data);
            
            ubyte d[] = new ubyte[x*y];
            d = data[0..x*y];          
            
            uint image_format;
            switch(comp) {
                case 3: image_format = GL_RGB; break;
                case 4: image_format = GL_RGBA; break;
                default: throw new ImageException("Unknown/Unsupported stbi image format");
            }

            return Image(d.ptr, x, y, image_format, GL_UNSIGNED_BYTE);
        }
    }
} else {
    // DevIL is not thread-safe :/
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
                throw new ImageException(format("loading the image \"%s\" failed!", filename));
            }

            ilConvertImage(IL_RGB, IL_UNSIGNED_BYTE);
            
            return Image(id);
        }
    }
}

struct DefaultAA(value_type, key_type, alias default__) {
    private value_type[key_type] _store;
    alias _store this;
    alias default__ default_;
    
    static if(isCallable!default_) {
        static assert(is(ReturnType!(default_) : value_type), "callable returntype doesn't match value_type");
    }

    private value_type _get_default() {
        static if(isCallable!default_) {
            return default_();
        } else {
            return default_;
        }
    }
    
    value_type opIndex(key_type key) {
        if(key !in _store) {
            _store[key] = _get_default();
        }
        
        return _store[key];
    }
     
    void opIndexAssign(value_type value, key_type key) {
        _store[key] = value;
    }
       
    void opIndexOpAssign(string op)(value_type rhs, key_type key) {
        if(key !in _store) {
            _store[key] = _get_default();
        }
        
        mixin("_store[key]" ~ op ~"= rhs;");
    }
}

unittest {
    DefaultAA!(int, string, 12) myaa;
    assert(myaa["baz"] == 12);
    assert(myaa["foo"] == 12);
    myaa["baz"] = -12;
    assert(myaa["baz"] == -12);
    assert(myaa["foo"] == 12);
    myaa["baz"] += 12;
    assert(myaa["baz"] == 0);
    myaa["foo"] -= 12;
    assert(myaa["foo"] == 0);
    myaa["lulz"] -= 12;
    assert(myaa["lulz"] == 0);
    
    int dg() { return 1; }
        
    DefaultAA!(int, string, dg) mydgaa;
    assert(mydgaa["foo"] == 1);
    mydgaa["lulz"] -= 1;
    assert(mydgaa["lulz"] == 0);
}