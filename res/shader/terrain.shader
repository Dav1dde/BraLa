vertex:
    #version 330

    in vec3 position;
    in vec3 normal;
    in vec2 texcoord;

    smooth out vec3 v_position;
    smooth out vec3 v_normal;
    smooth out vec2 v_texcoord;

    uniform mat4 model;
    uniform mat4 view;
    uniform mat4 proj;

    void main() {
        vec4 view_pos = view * model * vec4(position, 1.0);

        mat3 v = mat3(transpose(inverse(view))) * mat3(transpose(inverse(model)));
        v_normal = v * normal;
        v_texcoord = texcoord;
        v_position = view_pos.xyz;

        gl_Position = proj * view_pos;
    }

fragment:
    #version 330

    in vec3 v_normal;
    in vec3 v_position;
    in vec2 v_texcoord;

    uniform sampler2D terrain;

    out vec4 color_out;

    void main() {
        color_out = texture(terrain, v_texcoord);
//         color_out = vec4(v_texcoord, 1.0, 0.0);
    }