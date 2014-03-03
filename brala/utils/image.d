module brala.utils.image;

private {
    import stb_image : stbi_load, stbi_image_free, stbi_load_from_memory, stbi_write_png;
    import glamour.gl : GL_RGB, GL_RGBA, GL_UNSIGNED_BYTE, GL_TEXTURE0;
    import glamour.texture : Texture2D;

    import std.string : toStringz, format;
    import std.range : chunks;
    import std.array : array;
    import std.algorithm : min;
    import std.exception : enforceEx;

    import brala.utils.exception : ImageException;
}


enum {
    RGB = 3,
    RGBA = 4
}

class Image {
    ubyte[] data;
    int width;
    int height;
    int comp;

    @property int dest_format() {
        if(comp == RGB) {
            return GL_RGB;
        } else if(comp == RGBA) {
            return GL_RGBA;
        } else {
            throw new ImageException("Unknown/Unsupported stbi image format");
        }
    }
    
    static const int dest_type = GL_UNSIGNED_BYTE;

    this(ubyte[] data, int width, int height, int comp) {
        this.data = data;
        this.width = width;
        this.height = height;
        this.comp = comp;
    }

    static Image empty(int width, int height, int comp) {
        return new Image(new ubyte[width*height*comp], width, height, comp);
    }
    
    static Image from_file(string filename) {
        int x;
        int y;
        int comp;
        ubyte* data = stbi_load(toStringz(filename), &x, &y, &comp, 0);

        enforceEx!ImageException(data !is null, "Unable to load image: " ~ filename);
        scope(exit) stbi_image_free(data);
        enforceEx!ImageException(comp == RGB || comp == RGBA, "Unknown/Unsupported stbi image format: " ~ filename);
        
        return new Image(data[0..x*y*comp].dup, x, y, comp);
    }

    static Image from_memory(void[] content, string name="<unknown>") {
        int x;
        int y;
        int comp;
        ubyte* data = stbi_load_from_memory(cast(ubyte*)content.ptr, cast(uint)content.length, &x, &y, &comp, 0);

        enforceEx!ImageException(data !is null, "Unable to load image from data: " ~ name);
        scope(exit) stbi_image_free(data);
        enforceEx!ImageException(comp == RGB || comp == RGBA, "Unknown/Unsupported stbi image format: " ~ name);

        return new Image(data[0..x*y*comp].dup, x, y, comp);
    }

    ubyte[] get_pixel(int x, int y)
        in { assert(x < width && y < height); }
        body {
            return data[x*comp+y*width*comp..comp+x*comp+y*width*comp];
        }

    Image crop(int x1, int y1, int x2, int y2)
        in { assert(x1 < x2 && x2 <= width && y1 < y2 && y2 <= height); }
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

    void blend(int x, int y, Image img, ubyte[] function(ubyte[], ubyte[]) blend_func)
        in { assert(img.width+x <= width && img.height+y <= height && comp == img.comp); }
        body {
            foreach(yc; 0..img.height) {
                foreach(xc; 0..img.width) {
                    int yindex_bigimg = (y+yc)*width*comp;
                    int yindex_smallimg = yc*(img.width)*comp;
                    
                    int xindex_bigimg = (x+xc)*comp;
                    int xindex_smallimg = xc*comp;

                    data[xindex_bigimg+yindex_bigimg..xindex_bigimg+yindex_bigimg+comp] =
                        blend_func(data[xindex_bigimg+yindex_bigimg..xindex_bigimg+yindex_bigimg+comp],
                               img.data[xindex_smallimg+yindex_smallimg..xindex_smallimg+yindex_smallimg+comp]);
                }
            }
        }
        
    void resize(int new_width, int new_height) {
        ubyte[] new_data = new ubyte[new_width*new_height*comp];

        int width = min(this.width, new_width);
        int height = min(this.height, new_height);

        foreach(y; 0..height) {
            new_data[y*width*comp..y*width*comp+width*comp] = data[y*width*comp..y*width*comp+width*comp];
        }

        this.data = new_data;
        this.width = new_width;
        this.height = new_height;
    }

    void fill_empty_with_average() {
        if(comp != RGBA) {
            return;
        }

        size_t num;
        double r = 0, g = 0, b = 0;

        foreach(x; 0..width) {
            foreach(y; 0..height) {
                auto pixel = get_pixel(x, y);
                if(pixel[3] == 0) { // empty
                    continue;
                }

                r += pixel[0];
                g += pixel[1];
                b += pixel[2];
                num++;
            }
        }

        ubyte[] avrg = [0, 0, 0, 0];

        if(num) {
            avrg[0] = cast(ubyte)(r / num);
            avrg[1] = cast(ubyte)(g / num);
            avrg[2] = cast(ubyte)(b / num);
        }

        foreach(x; 0..width) {
            foreach(y; 0..height) {
                auto pixel = get_pixel(x, y);
                if(pixel[3] != 0) { // not empty
                    continue;
                }

                data[x*comp+y*width*comp..comp+x*comp+y*width*comp] = avrg;
            }
        }
    }

    void clear() {
        data[] = 0;
    }

    Image copy() {
        return new Image(data.dup, width, height, comp);
    }

    Image convert(int to_comp) {
        if(to_comp == comp) {
            return copy();
        }

        ubyte[] result;

        if(to_comp == RGBA) {
            foreach(chunk; chunks(data, comp)) {
                result ~= chunk;
                result ~= 255;
            }
        } else {
            foreach(chunk; chunks(data, comp)) {
                result ~= chunk[0..3];
            }
        }

        return new Image(result, width, height, to_comp);
    }

    Texture2D to_texture(int unit = GL_TEXTURE0) {
        Texture2D ret = new Texture2D(unit);
        ret.set_data(data, dest_format, width, height, dest_format, dest_type);
        return ret;
    }

    void write(string path) {
        int result = stbi_write_png(path.toStringz(), width, height, comp, data.ptr, 0);
        enforceEx!ImageException(result == 1, "Failed to write to disc");
    }
}