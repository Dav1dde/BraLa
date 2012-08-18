#version 330

vertex:
    in vec3 position;
    in vec3 normal;
    in vec2 texcoord;
    in vec2 mask;
    in vec2 palettecoord;

    out vec3 v_position;
    out vec3 v_normal;
    out vec2 v_texcoord;
    out vec2 v_mask;
    out vec2 v_palettecoord;

    uniform mat4 model;
    uniform mat4 view;
    uniform mat4 proj;

    void main() {
        vec4 view_pos = view * model * vec4(position, 1.0);
        v_position = view_pos.xyz;
        
        mat3 v = mat3(transpose(inverse(view))) * mat3(transpose(inverse(model)));
        v_normal = v * normal;
        
        v_texcoord = texcoord/32.0;
        v_mask = mask/32.0;
        v_palettecoord = palettecoord;
        
        gl_Position = proj * view_pos;
    }

fragment:
    in vec3 v_normal;
    in vec3 v_position;
    in vec2 v_texcoord;
    in vec2 v_mask;
    in vec2 v_palettecoord;

    uniform sampler2D terrain;
    uniform sampler2D palette;

    out vec4 color_out;

    void main() {
        vec4 color = texture(terrain, v_texcoord);
        float alpha = texture(terrain, v_mask).a;
        vec4 biome = texture(palette, v_palettecoord);
        //vec4 palette_texture = vec4(0.3568627450980392, 0.5450980392156862, 0.09019607843137255, 1);
        //color.rgb*color.a*biome + color.rgb*(1-color.a)
        
        color_out = color*alpha*biome + color*(1.0-alpha);
        //color_out = vec4(v_texcoord, 0, 0);
    }