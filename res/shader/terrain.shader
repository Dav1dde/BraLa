#version 330

vertex:
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
    smooth in vec3 v_normal;
    smooth in vec3 v_position;
    smooth in vec2 v_texcoord;

    uniform sampler2D terrain;

    out vec4 color_out;

    void main() {
        color_out = texture(terrain, v_texcoord);        
    }