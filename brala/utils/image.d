module brala.utils.image;

private {
    import stb_image : stbi_load, stbi_image_free;
    import glamour.gl : GL_RGB, GL_RGBA, GL_UNSIGNED_BYTE, GL_TEXTURE0;
    import glamour.texture : Texture2D;

    import std.string : toStringz, format;

    import brala.exception : ImageError;
}

class Image {
    ubyte[] data;
    int width;
    int height;
    int comp;

    @property int dest_format() {
        if(comp == 3) {
            return GL_RGB;
        } else if(comp == 4) {
            return GL_RGBA;
        } else {
            throw new ImageError("Unknown/Unsupported stbi image format");
        }
    }
    
    const int dest_type = GL_UNSIGNED_BYTE;

    this(ubyte[] data, int width, int height, int comp) {
        this.data = data;
        this.width = width;
        this.height = height;
        this.comp = comp;
    }

    static Image from_file(string filename) {
        int x;
        int y;
        int comp;
        ubyte* data = stbi_load(toStringz(filename), &x, &y, &comp, 0);

        if(data is null) {
            throw new ImageError("Unable to load image: " ~ filename);
        }

        scope(exit) stbi_image_free(data);

        if(!(comp == 3 || comp == 4)) {
            throw new ImageError("Unknown/Unsupported stbi image format");
        }
        
        return new Image(data[0..x*y*comp].dup, x, y, comp);
    }

    ubyte[] get_pixel(int x, int y)
        in { assert(x < width && y < height); }
        body {
            return data[x*comp+y*width*comp..comp+x*comp+y*width*comp];
        }

    Image crop(int x1, int y1, int x2, int y2)
        in { assert(x1 < x2 && x2 < width && y1 < y2 && y2 < height); }
        body {
            ubyte[] res;

            foreach(y; y1..y2) {
                res ~= data[x1*comp+y*width*comp..x2*comp+y*width*comp];
            }

            return new Image(res, x2-x1, y2-y1, comp);
        }

    void replace(int x, int y, Image img)
        in { assert(img.width+x <= width && img.height+y <= height && comp == img.comp); }
        body {
            foreach(yc; 0..img.height) {
                int yindex_bigimg = (y+yc)*width*comp;
                int yindex_smallimg = yc*(img.width)*comp;
                
                data[x*comp+yindex_bigimg..(x+img.width)*comp+yindex_bigimg] =
                    img.data[yindex_smallimg..(img.width)*comp+yindex_smallimg];
            }
        }

    void resize(int new_width, int new_height) {
        ubyte[] new_data = new ubyte[new_width*new_height*comp];

        new_data[0..width*height*comp] = data;

        this.data = data;
        this.width = new_width;
        this.height = new_height;
    }

    Texture2D to_texture(int unit = GL_TEXTURE0) {
        Texture2D ret = new Texture2D(unit);
        ret.set_data(data, dest_format, width, height, dest_format, dest_type);
        return ret;
    }
        
}