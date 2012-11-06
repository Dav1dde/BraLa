#version 130

vertex:
    in vec3 position;
//     in vec3 normal;
    in vec4 color;
    in vec2 texcoord;
    in vec2 mask;

    in vec2 light;

    out vec3 v_position;
    out vec3 v_normal;
    out vec4 v_color;
    out vec2 v_texcoord;
    out vec2 v_mask;

    out float v_light;

    uniform mat4 model;
    uniform mat4 view;
    uniform mat4 proj;

    void main() {
        vec4 view_pos = view * model * vec4(position, 1.0);
        v_position = view_pos.xyz;
        
//         mat3 v = mat3(transpose(inverse(view))) * mat3(transpose(inverse(model)));
//         v_normal = v * normal;
        
        v_color = color;
        v_texcoord = texcoord/256.0;
        v_mask = mask/256.0;

        //v_light = clamp(light.x+light.y, 0, 15)/15;
        
        gl_Position = proj * view_pos;
    }

fragment:
//     in vec3 v_normal;
    in vec3 v_position;
    in vec4 v_color;
    in vec2 v_texcoord;
    in vec2 v_mask;

    in float v_light;

    uniform sampler2D terrain;

    out vec4 color_out;

    void main() {
        vec4 color = texture(terrain, v_texcoord);

        // ugly:
        if(color.a < 0.15) {
            discard;
        } else {
            if(v_mask == v_texcoord) {
                color_out = color*v_color;
            } else {
                float alpha = texture(terrain, v_mask).a;

                color_out = mix(color, color*v_color, alpha);
            }
        }
    }