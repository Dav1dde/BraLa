// stb_image d header file
module stb_image;

private import core.stdc.stdio;

enum STBI_VERSION = 1;

enum {
    STBI_default = 0,
    
    STBI_grey = 1,
    STBI_grey_alpha = 2,
    STBI_rgb = 3,
    STBI_rgb_alpha = 4
}


alias ubyte stbi_uc;


// see stb_image.c for comments
extern (C) {
    stbi_uc* stbi_load_from_memory(const stbi_uc* buffer, int len, int* x, int* y, int* comp, int req_comp);

    stbi_uc* stbi_load(const char* filename, int* x, int* y, int* comp, int req_comp);
    stbi_uc* stbi_load_from_file(FILE* f, int* x, int* y, int* comp, int req_comp);

    struct stbi_io_callbacks {
        int function(void*, char*, int) read; 
        void function(void*, uint) skip;
        int function(void*) eof;
    }

    stbi_uc* stbi_load_from_callbacks(const stbi_io_callbacks* clbk, void* user, int* x, int* y, int* comp, int req_comp);

    float* stbi_loadf_from_memory(const stbi_uc* buffer, int len, int* x, int* y, int* comp, int req_comp);

    float* stbi_loadf(const char* filename, int* x, int* y, int* comp, int req_comp);
    float* stbi_loadf_from_file(FILE* f, int* x, int* y, int* comp, int req_comp);

    float* stbi_loadf_from_callbacks(const stbi_io_callbacks* clbk, void* user, int* x, int* y, int* comp, int req_comp);

    void stbi_hdr_to_ldr_gamma(float gamma);
    void stbi_hdr_to_ldr_scale(float scale);

    void stbi_ldr_to_hdr_gamma(float gamma);
    void stbi_ldr_to_hdr_scale(float scale);

    int stbi_is_hdr_from_callbacks(const stbi_io_callbacks* clbk, void* user);
    int stbi_is_hdr_from_memory(const stbi_uc* buffer, int len);

    int stbi_is_hdr(const char* filename);
    int stbi_is_hdr_from_file(FILE* f);


    const(char)* stbi_failure_reason(); 

    void stbi_image_free (void* retval_from_stbi_load);

    int stbi_info_from_memory(const stbi_uc* buffer, int len, int* x, int* y, int* comp);
    int stbi_info_from_callbacks(const stbi_io_callbacks* clbk, void* user, int* x, int* y, int* comp);

    int stbi_info(const char* filename, int* x, int* y, int* comp);
    int stbi_info_from_file(FILE* f, int* x, int* y, int* comp);

    void stbi_set_unpremultiply_on_load(int flag_true_if_should_unpremultiply);

    void stbi_convert_iphone_png_to_rgb(int flag_true_if_should_convert);

    char* stbi_zlib_decode_malloc_guesssize(const char* buffer, int len, int initial_size, int* outlen);
    char* stbi_zlib_decode_malloc(const char* buffer, int len, int* outlen);
    int stbi_zlib_decode_buffer(char* obuffer, int olen, const char* ibuffer, int ilen);

    char* stbi_zlib_decode_noheader_malloc(const char* buffer, int len, int* outlen);
    int stbi_zlib_decode_noheader_buffer(char* obuffer, int olen, const char* ibuffer, int ilen);


    alias void function(stbi_uc*, int, short*, ushort*) stbi_idct_8x8;
    alias void function(stbi_uc*, const stbi_uc*, const stbi_uc*, const stbi_uc*, int, int) stbi_YCbCr_to_RGB_run;

    void stbi_install_idct(stbi_idct_8x8 func);
    void stbi_install_YCbCr_to_RGB(stbi_YCbCr_to_RGB_run func);

    // stb_image_write

    int stbi_write_png(const(char)* filename, int w, int h, int comp, const(void)* data, int stride_in_bytes);
    int stbi_write_bmp(const(char)* filename, int w, int h, int comp, const(void)* data);
    int stbi_write_tga(const(char)* filename, int w, int h, int comp, const(void)* data);
}
