#version 330

vertex:
    in vec3 position;
    in vec3 normal;
    in vec2 texcoord;
    in vec2 palettecoord;

    out vec3 v_position;
    out vec3 v_normal;
    out vec2 v_texcoord;
    out vec2 v_palettecoord;

    uniform mat4 model;
    uniform mat4 view;
    uniform mat4 proj;

    void main() {
        vec4 view_pos = view * model * vec4(position, 1.0);

        mat3 v = mat3(transpose(inverse(view))) * mat3(transpose(inverse(model)));
        v_normal = v * normal;
        v_texcoord = texcoord;
        v_palettecoord = palettecoord;
        v_position = view_pos.xyz;

        gl_Position = proj * view_pos;
    }

fragment:
    in vec3 v_normal;
    in vec3 v_position;
    in vec2 v_texcoord;
    in vec2 v_palettecoord;

    uniform sampler2D terrain;
    uniform sampler2D palette;

    out vec4 color_out;

    void main() {
        vec4 terrain_texture = texture(terrain, v_texcoord);
        vec4 palette_texture = texture(palette, v_palettecoord);
        //vec4 palette_texture = vec4(0.3568627450980392, 0.5450980392156862, 0.09019607843137255, 1);
        color_out = terrain_texture * palette_texture;
        //color_out = palette_texture;
    }