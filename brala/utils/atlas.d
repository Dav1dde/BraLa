module brala.utils.atlas;

private {
    import glamour.texture : Texture2D;

    import brala.utils.image : Image, RGB, RGBA;
    import brala.utils.exception : AtlasException;
}


struct Rectangle {
    int x;
    int y;
    int width;
    int height;
}

struct Node {
    Rectangle area;

    string name;
    Image image;

    Node* left;
    Node* right;

    Node* insert(Image image, string name) {
        // http://www.blackpawn.com/texts/lightmaps/
        if(left !is null && right !is null) { // it's not a leaf
            Node* node = left.insert(image, name);
            if(node !is null) {
                return node;
            }

            return right.insert(image, name);
        }

        if(this.image !is null) {
            return null; // no space for an image here!
        }

        if(image.width > area.width || image.height > area.height) {
            return null; // image is too big
        }

        if(image.width == area.width && image.height == area.height) {
            return &this; // fits perfectly!
        }

        int delta_width = area.width - image.width;
        int delta_height = area.height - image.height;

        assert(delta_width >= 0 && delta_height >= 0);

        left = new Node();
        right = new Node();

        if(delta_width > delta_height) {
            left.area = Rectangle(area.x, area.y, image.width, area.height);
            right.area = Rectangle(area.x+image.width, area.y,
                                    area.width-image.width, area.height);
        } else {
            left.area = Rectangle(area.x, area.y, area.width, image.height);
            right.area = Rectangle(area.x, area.y+image.height,
                                    area.width, area.height - image.height);
        }

        return left.insert(image, name);
    }
}


class Atlas {
    Image atlas;

    protected Texture2D _texture;
    protected bool _texture_dirty = true;
    @property Texture2D texture() {
        if(_texture_dirty) {
            if(_texture !is null) {
                _texture.remove();
            }

            _texture = atlas.to_texture();
        }

        return texture;
    }

    bool autoresize;

    protected Node root;
    protected Node*[string] map;

    this(int width=512, int height=512, bool autoresize=true) {
        this.atlas = Image.empty(width, height, RGBA);
        this.root.area = Rectangle(0, 0, width, height);
        this.autoresize = autoresize;
    }

    void insert(Image image, string name) {
        Node* result = root.insert(image, name);

        if(result is null) {
            // not enough space in atlas
            if(autoresize) {
                root = Node();
                atlas.clear();
                atlas.resize(atlas.width*2, atlas.height*2);
                root.area = Rectangle(0, 0, atlas.width, atlas.height);

                typeof(map) old_map = map;
                auto keys = map.keys();
                map = map.init;

                foreach(key; keys) {
                    insert(old_map[key].image, name);
                }

                return insert(image, name);
            } else {
                throw new AtlasException("Atlas too small");
            }
        }


        result.name = name;
        result.image = image;

        atlas.replace(result.area.x, result.area.y, result.image);
        map[name] = result;
    }

    Rectangle lookup(string name) {
        return map[name].area;
    }

    void write(string path) {
        atlas.write(path);
    }
}