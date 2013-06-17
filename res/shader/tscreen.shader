vertex:
    in vec2 position;
    in vec2 texcoord;
    out vec2 v_texcoord;

    void main() {
        v_texcoord = texcoord;
        //v_texcoord = (position+1.0)/2.0;
        gl_Position = vec4(position, 0.0, 1.0);
    };

fragment:
    in vec2 v_texcoord;
    out vec4 color_out;

    uniform sampler2D texture;

    void main() {
        color_out = texture2D(texture, v_texcoord);
    }