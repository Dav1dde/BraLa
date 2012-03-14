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
    uniform vec2 viewport;
    
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

    uniform vec2 viewport;

    out vec4 color_out;

    vec3 light_pos = vec3(100, 100, 100);
    float light_attenuation = 1.0;
    vec4 light_intensity = vec4(1.0, 1.0, 1.0, 1.0);
    vec4 ambient_intensity = vec4(0.30, 0.30, 0.30, 1.0);

    void main() {
        vec3 color = vec3(0.5, 0.5, 0.5);
        
        vec3 light_vec = light_pos - v_position;
        vec3 light_normal = normalize(light_vec);
        
        float light_distance = length(light_vec);
        float lambert = clamp(dot(light_normal, v_normal), 0.0, 1.0); // cos: 0-1
        
        float diffuse = lambert/sqrt(1.0 + light_attenuation * light_distance);
        //float diffuse = lambert/pow(light_distance, 2);
        
        color_out = (vec4(color, 1.0) * vec4(vec3(diffuse), 1.0) * lambert) + (vec4(color, 1.0) * ambient_intensity);
    }