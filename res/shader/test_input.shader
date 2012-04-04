#version 330

vertex:
    in vec3 position;
    in vec3 normal;
    in vec2 texcoord;
    
    out vec3 v_position;
    out vec3 v_normal;
    out vec2 v_texcoord;
    
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
    in vec3 v_normal;
    in vec3 v_position;
    in vec2 v_texcoord;

    uniform vec2 viewport;

    out vec4 color_out;
    
    // https://github.com/pyalot/webgl-template/blob/master/src/shaders/spherical_harmonics.glsl
    struct SHC{
        vec3 L00, L1m1, L10, L11, L2m2, L2m1, L20, L21, L22;
    };

    SHC beach = SHC(
        vec3( 0.6841148,  0.6929004,  0.7069543),
        vec3( 0.3173355,  0.3694407,  0.4406839),
        vec3(-0.1747193, -0.1737154, -0.1657420),
        vec3(-0.4496467, -0.4155184, -0.3416573),
        vec3(-0.1690202, -0.1703022, -0.1525870),
        vec3(-0.0837808, -0.0940454, -0.1027518),
        vec3(-0.0319670, -0.0214051, -0.0147691),
        vec3( 0.1641816,  0.1377558,  0.1010403),
        vec3( 0.3697189,  0.3097930,  0.2029923)
    );

    vec3 shLight(vec3 normal, SHC l){
        float x = normal.x;
        float y = normal.y;
        float z = normal.z;

        const float C1 = 0.429043;
        const float C2 = 0.511664;
        const float C3 = 0.743125;
        const float C4 = 0.886227;
        const float C5 = 0.247708;

        return (
            C1 * l.L22 * (x * x - y * y) +
            C3 * l.L20 * z * z +
            C4 * l.L00 -
            C5 * l.L20 +
            2.0 * C1 * l.L2m2 * x * y +
            2.0 * C1 * l.L21  * x * z +
            2.0 * C1 * l.L2m1 * y * z +
            2.0 * C2 * l.L11  * x +
            2.0 * C2 * l.L1m1 * y +
            2.0 * C2 * l.L10  * z
        );
    }

    void main() {
        vec3 normal = normalize(v_normal);
        vec3 incident = shLight(normal, beach);
        
        color_out = vec4(incident, 1.0);
    }