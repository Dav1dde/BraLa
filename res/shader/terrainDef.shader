#version 150

vertex:
    in vec3 position;
    in float normal;
    in vec3 color;
    in vec2 texcoord;
    in vec2 mask;

    out vec3 v_position;
    out vec3 v_normal;
    out vec4 v_color;
    out vec2 v_texcoord;
    out vec2 v_mask;

    uniform vec4 normals[10];
    uniform vec2 texture_size;
    uniform mat4 model;
    uniform mat4 view;
    uniform mat4 proj;

    void main() {
        vec4 view_pos = view * model * vec4(position, 1.0);
        v_position = view_pos.xyz;

        mat3 v = mat3(transpose(inverse(view))) * mat3(transpose(inverse(model)));
        v_normal = normalize(normals[int(normal)].xyz);

        v_color = vec4(color, 1.0);
        v_texcoord = texcoord/texture_size.x;
        v_mask = mask/texture_size.y;

        gl_Position = proj * view_pos;
    }

fragment:
    in vec3 v_normal;
    in vec3 v_position;
    in vec4 v_color;
    in vec2 v_texcoord;
    in vec2 v_mask;

    uniform sampler2D terrain;

    void main() {
        vec4 color = texture(terrain, v_texcoord);
        vec4 mask_color = texture(terrain, v_mask);

        if(color.a < 0.15) {
            discard;
        } else {
            if(v_mask == v_texcoord) {
                gl_FragData[0] = color*v_color;
            } else {
                float alpha = mask_color.a;

                if(alpha < 0.15)
                    gl_FragData[0] = color;
                else
                    gl_FragData[0] = mask_color*v_color;
            }
        }

        gl_FragData[1] = vec4(v_position, 0.0);
        gl_FragData[2] = vec4(v_texcoord, v_mask);
        gl_FragData[3] = vec4(v_normal, 0.0);
    }