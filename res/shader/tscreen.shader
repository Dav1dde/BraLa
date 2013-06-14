vertex:
    in vec2 texcoord;
    in vec2 position;

    out vec2 v_texcoord;

    void main() {
        v_texcoord = texcoord;
        gl_Position = vec4(position, 0.0, 1.0);
    };

fragment:
    in vec2 v_texcoord;

    out vec4 color_out;

    uniform sampler2D texture;

    void main() {
        color_out = texture2D(texture, v_texcoord);
    }