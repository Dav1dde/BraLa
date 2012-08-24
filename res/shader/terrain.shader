#version 330

vertex:
    in vec3 position;
    in vec3 normal;
    in vec4 color;
    in vec2 texcoord;
    in vec2 mask;

    out vec3 v_position;
    out vec3 v_normal;
    out vec4 v_color;
    out vec2 v_texcoord;
    out vec2 v_mask;

    uniform mat4 model;
    uniform mat4 view;
    uniform mat4 proj;

    void main() {
        vec4 view_pos = view * model * vec4(position, 1.0);
        v_position = view_pos.xyz;
        
        mat3 v = mat3(transpose(inverse(view))) * mat3(transpose(inverse(model)));
        v_normal = v * normal;
        
        v_color = color;
        v_texcoord = texcoord/32.0;
        v_mask = mask/32.0;
        
        gl_Position = proj * view_pos;
    }

fragment:
    in vec3 v_normal;
    in vec3 v_position;
    in vec4 v_color;
    in vec2 v_texcoord;
    in vec2 v_mask;

    uniform sampler2D terrain;

    out vec4 color_out;

    void main() {
        vec4 color = texture(terrain, v_texcoord);
        float alpha = texture(terrain, v_mask).a;

        color_out = color*alpha*v_color + color*(1.0-alpha);
    }