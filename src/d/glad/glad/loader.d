module glad.loader;


private import std.conv;
private import std.string;
private import std.algorithm;
private import glad.glfuncs;
private import glad.glext;
private import glad.glenums;
private import glad.gltypes;


struct GLVersion { int major; int minor; }
GLVersion gladLoadGL() {
	return gladLoadGL(&gladGetProcAddress);
}

version(Windows) {
    private import std.c.windows.windows;
} else {
    private import core.sys.posix.dlfcn;
}

version(Windows) {
    private __gshared HMODULE libGL;
    extern(System) private __gshared void* function(const(char)*) wglGetProcAddress;
} else {
    private __gshared void* libGL;
    extern(System) private __gshared void* function(const(char)*) glXGetProcAddress;
}

bool gladInit() {
    version(Windows) {
        libGL = LoadLibraryA("opengl32.dll\0".ptr);
        if(libGL !is null) {
            wglGetProcAddress = cast(typeof(wglGetProcAddress))GetProcAddress(
                libGL, "wglGetProcAddress\0".ptr);
            return wglGetProcAddress !is null;
        }

        return false;
    } else {
        version(OSX) {
            enum NAMES = [
                "../Frameworks/OpenGL.framework/OpenGL\0".ptr,
                "/Library/Frameworks/OpenGL.framework/OpenGL\0".ptr,
                "/System/Library/Frameworks/OpenGL.framework/OpenGL\0".ptr
            ];
        } else {
            enum NAMES = ["libGL.so.1\0".ptr, "libGL.so\0".ptr];
        }

        foreach(name; NAMES) {
            libGL = dlopen(name, RTLD_NOW | RTLD_GLOBAL);
            if(libGL !is null) {
                glXGetProcAddress = cast(typeof(glXGetProcAddress))dlsym(libGL,
                    "glXGetProcAddressARB\0".ptr);
                return glXGetProcAddress !is null;
            }
        }

        return false;
    }
}

void gladTerminate() {
    version(Windows) {
        if(libGL !is null) {
            FreeLibrary(libGL);
            libGL = null;
        }
    } else {
        if(libGL !is null) {
            dlclose(libGL);
            libGL = null;
        }
    }
}

void* gladGetProcAddress(string name) {
    if(libGL is null) return null;
    const(char)* namez = toStringz(name);
    void* result;

    version(Windows) {
        if(wglGetProcAddress is null) return null;

        result = wglGetProcAddress(namez);
        if(result is null) {
            result = GetProcAddress(libGL, namez);
        }
    } else {
        if(glXGetProcAddress is null) return null;

        result = glXGetProcAddress(namez);
        if(result is null) {
            result = dlsym(libGL, namez);
        }
    }

    return result;
}
GLVersion gladLoadGL(void* function(string name) load) {
	glGetString = cast(typeof(glGetString))load("glGetString");
	glGetIntegerv = cast(typeof(glGetIntegerv))load("glGetIntegerv");
	if(glGetString is null || glGetIntegerv is null) return GLVersion(0, 0);

	GLVersion glv = find_core();
	load_gl_GL_VERSION_1_0(load);
	load_gl_GL_VERSION_1_1(load);
	load_gl_GL_VERSION_1_2(load);
	load_gl_GL_VERSION_1_3(load);
	load_gl_GL_VERSION_1_4(load);
	load_gl_GL_VERSION_1_5(load);
	load_gl_GL_VERSION_2_0(load);
	load_gl_GL_VERSION_2_1(load);
	load_gl_GL_VERSION_3_0(load);
	load_gl_GL_VERSION_3_1(load);
	load_gl_GL_VERSION_3_2(load);
	load_gl_GL_VERSION_3_3(load);
	load_gl_GL_VERSION_4_0(load);
	load_gl_GL_VERSION_4_1(load);
	load_gl_GL_VERSION_4_2(load);
	load_gl_GL_VERSION_4_3(load);

	find_extensions();
	load_gl_GL_SGIX_pixel_tiles(load);
	load_gl_GL_NV_point_sprite(load);
	load_gl_GL_APPLE_element_array(load);
	load_gl_GL_AMD_multi_draw_indirect(load);
	load_gl_GL_EXT_blend_subtract(load);
	load_gl_GL_SGIX_tag_sample_buffer(load);
	load_gl_GL_IBM_texture_mirrored_repeat(load);
	load_gl_GL_APPLE_transform_hint(load);
	load_gl_GL_ATI_separate_stencil(load);
	load_gl_GL_NV_vertex_program2_option(load);
	load_gl_GL_EXT_texture_buffer_object(load);
	load_gl_GL_ARB_vertex_blend(load);
	load_gl_GL_NV_vertex_program2(load);
	load_gl_GL_ARB_program_interface_query(load);
	load_gl_GL_EXT_misc_attribute(load);
	load_gl_GL_NV_multisample_coverage(load);
	load_gl_GL_ARB_shading_language_packing(load);
	load_gl_GL_EXT_texture_cube_map(load);
	load_gl_GL_ARB_texture_stencil8(load);
	load_gl_GL_EXT_index_func(load);
	load_gl_GL_OES_compressed_paletted_texture(load);
	load_gl_GL_NV_depth_clamp(load);
	load_gl_GL_NV_shader_buffer_load(load);
	load_gl_GL_EXT_color_subtable(load);
	load_gl_GL_SUNX_constant_data(load);
	load_gl_GL_EXT_multi_draw_arrays(load);
	load_gl_GL_ARB_shader_atomic_counters(load);
	load_gl_GL_ARB_arrays_of_arrays(load);
	load_gl_GL_NV_conditional_render(load);
	load_gl_GL_EXT_texture_env_combine(load);
	load_gl_GL_NV_fog_distance(load);
	load_gl_GL_SGIX_async_histogram(load);
	load_gl_GL_MESA_resize_buffers(load);
	load_gl_GL_NV_light_max_exponent(load);
	load_gl_GL_NV_texture_env_combine4(load);
	load_gl_GL_ARB_texture_view(load);
	load_gl_GL_ARB_texture_env_combine(load);
	load_gl_GL_ARB_map_buffer_range(load);
	load_gl_GL_EXT_convolution(load);
	load_gl_GL_NV_compute_program5(load);
	load_gl_GL_NV_vertex_attrib_integer_64bit(load);
	load_gl_GL_EXT_paletted_texture(load);
	load_gl_GL_ARB_texture_buffer_object(load);
	load_gl_GL_ATI_pn_triangles(load);
	load_gl_GL_SGIX_resample(load);
	load_gl_GL_SGIX_flush_raster(load);
	load_gl_GL_EXT_light_texture(load);
	load_gl_GL_ARB_point_sprite(load);
	load_gl_GL_ARB_half_float_pixel(load);
	load_gl_GL_NV_tessellation_program5(load);
	load_gl_GL_REND_screen_coordinates(load);
	load_gl_GL_EXT_shared_texture_palette(load);
	load_gl_GL_EXT_packed_float(load);
	load_gl_GL_OML_subsample(load);
	load_gl_GL_SGIX_vertex_preclip(load);
	load_gl_GL_SGIX_texture_scale_bias(load);
	load_gl_GL_AMD_draw_buffers_blend(load);
	load_gl_GL_MESA_window_pos(load);
	load_gl_GL_EXT_texture_array(load);
	load_gl_GL_NV_texture_barrier(load);
	load_gl_GL_ARB_texture_query_levels(load);
	load_gl_GL_NV_texgen_emboss(load);
	load_gl_GL_EXT_texture_swizzle(load);
	load_gl_GL_ARB_texture_rg(load);
	load_gl_GL_ARB_vertex_type_2_10_10_10_rev(load);
	load_gl_GL_ARB_fragment_shader(load);
	load_gl_GL_3DFX_tbuffer(load);
	load_gl_GL_GREMEDY_frame_terminator(load);
	load_gl_GL_ARB_blend_func_extended(load);
	load_gl_GL_EXT_separate_shader_objects(load);
	load_gl_GL_NV_texture_multisample(load);
	load_gl_GL_ARB_shader_objects(load);
	load_gl_GL_ARB_framebuffer_object(load);
	load_gl_GL_ATI_envmap_bumpmap(load);
	load_gl_GL_ARB_robust_buffer_access_behavior(load);
	load_gl_GL_ARB_shader_stencil_export(load);
	load_gl_GL_NV_texture_rectangle(load);
	load_gl_GL_ARB_enhanced_layouts(load);
	load_gl_GL_ARB_texture_rectangle(load);
	load_gl_GL_SGI_texture_color_table(load);
	load_gl_GL_ATI_map_object_buffer(load);
	load_gl_GL_ARB_robustness(load);
	load_gl_GL_NV_pixel_data_range(load);
	load_gl_GL_EXT_framebuffer_blit(load);
	load_gl_GL_ARB_gpu_shader_fp64(load);
	load_gl_GL_SGIX_depth_texture(load);
	load_gl_GL_EXT_vertex_weighting(load);
	load_gl_GL_GREMEDY_string_marker(load);
	load_gl_GL_ARB_texture_compression_bptc(load);
	load_gl_GL_EXT_subtexture(load);
	load_gl_GL_EXT_pixel_transform_color_table(load);
	load_gl_GL_EXT_texture_compression_rgtc(load);
	load_gl_GL_SGIX_depth_pass_instrument(load);
	load_gl_GL_ARB_shader_precision(load);
	load_gl_GL_NV_evaluators(load);
	load_gl_GL_SGIS_texture_filter4(load);
	load_gl_GL_AMD_performance_monitor(load);
	load_gl_GL_NV_geometry_shader4(load);
	load_gl_GL_EXT_stencil_clear_tag(load);
	load_gl_GL_NV_vertex_program1_1(load);
	load_gl_GL_NV_present_video(load);
	load_gl_GL_ARB_texture_compression_rgtc(load);
	load_gl_GL_HP_convolution_border_modes(load);
	load_gl_GL_EXT_gpu_program_parameters(load);
	load_gl_GL_SGIX_list_priority(load);
	load_gl_GL_ARB_stencil_texturing(load);
	load_gl_GL_SGIX_fog_offset(load);
	load_gl_GL_ARB_draw_elements_base_vertex(load);
	load_gl_GL_INGR_interlace_read(load);
	load_gl_GL_NV_transform_feedback(load);
	load_gl_GL_NV_fragment_program(load);
	load_gl_GL_AMD_stencil_operation_extended(load);
	load_gl_GL_ARB_seamless_cubemap_per_texture(load);
	load_gl_GL_ARB_instanced_arrays(load);
	load_gl_GL_EXT_polygon_offset(load);
	load_gl_GL_NV_vertex_array_range2(load);
	load_gl_GL_AMD_sparse_texture(load);
	load_gl_GL_NV_fence(load);
	load_gl_GL_ARB_texture_buffer_range(load);
	load_gl_GL_SUN_mesh_array(load);
	load_gl_GL_ARB_vertex_attrib_binding(load);
	load_gl_GL_ARB_framebuffer_no_attachments(load);
	load_gl_GL_ARB_cl_event(load);
	load_gl_GL_NV_packed_depth_stencil(load);
	load_gl_GL_OES_single_precision(load);
	load_gl_GL_NV_primitive_restart(load);
	load_gl_GL_SUN_global_alpha(load);
	load_gl_GL_EXT_texture_object(load);
	load_gl_GL_AMD_name_gen_delete(load);
	load_gl_GL_NV_texture_compression_vtc(load);
	load_gl_GL_SGIX_ycrcb_subsample(load);
	load_gl_GL_NV_texture_shader3(load);
	load_gl_GL_NV_texture_shader2(load);
	load_gl_GL_EXT_texture(load);
	load_gl_GL_ARB_buffer_storage(load);
	load_gl_GL_AMD_shader_atomic_counter_ops(load);
	load_gl_GL_APPLE_vertex_program_evaluators(load);
	load_gl_GL_ARB_multi_bind(load);
	load_gl_GL_ARB_explicit_uniform_location(load);
	load_gl_GL_ARB_depth_buffer_float(load);
	load_gl_GL_SGIX_shadow_ambient(load);
	load_gl_GL_ARB_texture_cube_map(load);
	load_gl_GL_AMD_vertex_shader_viewport_index(load);
	load_gl_GL_NV_vertex_buffer_unified_memory(load);
	load_gl_GL_EXT_texture_env_dot3(load);
	load_gl_GL_ATI_texture_env_combine3(load);
	load_gl_GL_ARB_map_buffer_alignment(load);
	load_gl_GL_NV_blend_equation_advanced(load);
	load_gl_GL_SGIS_sharpen_texture(load);
	load_gl_GL_ARB_vertex_program(load);
	load_gl_GL_ARB_texture_rgb10_a2ui(load);
	load_gl_GL_OML_interlace(load);
	load_gl_GL_ATI_pixel_format_float(load);
	load_gl_GL_ARB_vertex_buffer_object(load);
	load_gl_GL_EXT_shadow_funcs(load);
	load_gl_GL_ATI_text_fragment_shader(load);
	load_gl_GL_NV_vertex_array_range(load);
	load_gl_GL_SGIX_fragment_lighting(load);
	load_gl_GL_NV_texture_expand_normal(load);
	load_gl_GL_NV_framebuffer_multisample_coverage(load);
	load_gl_GL_EXT_timer_query(load);
	load_gl_GL_EXT_vertex_array_bgra(load);
	load_gl_GL_NV_bindless_texture(load);
	load_gl_GL_KHR_debug(load);
	load_gl_GL_SGIS_texture_border_clamp(load);
	load_gl_GL_ATI_vertex_attrib_array_object(load);
	load_gl_GL_SGIX_clipmap(load);
	load_gl_GL_EXT_geometry_shader4(load);
	load_gl_GL_MESA_ycbcr_texture(load);
	load_gl_GL_MESAX_texture_stack(load);
	load_gl_GL_AMD_seamless_cubemap_per_texture(load);
	load_gl_GL_EXT_bindable_uniform(load);
	load_gl_GL_ARB_fragment_program_shadow(load);
	load_gl_GL_ATI_element_array(load);
	load_gl_GL_AMD_texture_texture4(load);
	load_gl_GL_SGIX_reference_plane(load);
	load_gl_GL_EXT_stencil_two_side(load);
	load_gl_GL_SGIX_texture_lod_bias(load);
	load_gl_GL_NV_explicit_multisample(load);
	load_gl_GL_IBM_static_data(load);
	load_gl_GL_EXT_clip_volume_hint(load);
	load_gl_GL_EXT_texture_perturb_normal(load);
	load_gl_GL_NV_fragment_program2(load);
	load_gl_GL_NV_fragment_program4(load);
	load_gl_GL_EXT_point_parameters(load);
	load_gl_GL_PGI_misc_hints(load);
	load_gl_GL_SGIX_subsample(load);
	load_gl_GL_AMD_shader_stencil_export(load);
	load_gl_GL_ARB_shader_texture_lod(load);
	load_gl_GL_ARB_vertex_shader(load);
	load_gl_GL_ARB_depth_clamp(load);
	load_gl_GL_SGIS_texture_select(load);
	load_gl_GL_NV_texture_shader(load);
	load_gl_GL_ARB_tessellation_shader(load);
	load_gl_GL_EXT_draw_buffers2(load);
	load_gl_GL_ARB_vertex_attrib_64bit(load);
	load_gl_GL_WIN_specular_fog(load);
	load_gl_GL_AMD_interleaved_elements(load);
	load_gl_GL_ARB_fragment_program(load);
	load_gl_GL_OML_resample(load);
	load_gl_GL_APPLE_ycbcr_422(load);
	load_gl_GL_SGIX_texture_add_env(load);
	load_gl_GL_ARB_shadow_ambient(load);
	load_gl_GL_ARB_texture_storage(load);
	load_gl_GL_EXT_pixel_buffer_object(load);
	load_gl_GL_ARB_copy_image(load);
	load_gl_GL_SGIS_pixel_texture(load);
	load_gl_GL_SGIS_generate_mipmap(load);
	load_gl_GL_SGIX_instruments(load);
	load_gl_GL_HP_texture_lighting(load);
	load_gl_GL_ARB_shader_storage_buffer_object(load);
	load_gl_GL_EXT_blend_minmax(load);
	load_gl_GL_MESA_pack_invert(load);
	load_gl_GL_ARB_base_instance(load);
	load_gl_GL_SGIX_convolution_accuracy(load);
	load_gl_GL_PGI_vertex_hints(load);
	load_gl_GL_EXT_texture_integer(load);
	load_gl_GL_ARB_texture_multisample(load);
	load_gl_GL_S3_s3tc(load);
	load_gl_GL_ARB_query_buffer_object(load);
	load_gl_GL_AMD_vertex_shader_tessellator(load);
	load_gl_GL_ARB_invalidate_subdata(load);
	load_gl_GL_EXT_index_material(load);
	load_gl_GL_NV_blend_equation_advanced_coherent(load);
	load_gl_GL_INTEL_parallel_arrays(load);
	load_gl_GL_ATI_draw_buffers(load);
	load_gl_GL_EXT_cmyka(load);
	load_gl_GL_SGIX_pixel_texture(load);
	load_gl_GL_APPLE_specular_vector(load);
	load_gl_GL_ARB_compatibility(load);
	load_gl_GL_ARB_timer_query(load);
	load_gl_GL_SGIX_interlace(load);
	load_gl_GL_NV_parameter_buffer_object(load);
	load_gl_GL_AMD_shader_trinary_minmax(load);
	load_gl_GL_EXT_rescale_normal(load);
	load_gl_GL_ARB_pixel_buffer_object(load);
	load_gl_GL_ARB_uniform_buffer_object(load);
	load_gl_GL_ARB_vertex_type_10f_11f_11f_rev(load);
	load_gl_GL_ARB_texture_swizzle(load);
	load_gl_GL_NV_transform_feedback2(load);
	load_gl_GL_SGIX_async_pixel(load);
	load_gl_GL_NV_fragment_program_option(load);
	load_gl_GL_ARB_explicit_attrib_location(load);
	load_gl_GL_EXT_blend_color(load);
	load_gl_GL_EXT_stencil_wrap(load);
	load_gl_GL_EXT_index_array_formats(load);
	load_gl_GL_EXT_histogram(load);
	load_gl_GL_SGIS_point_parameters(load);
	load_gl_GL_EXT_direct_state_access(load);
	load_gl_GL_AMD_sample_positions(load);
	load_gl_GL_NV_vertex_program(load);
	load_gl_GL_NVX_conditional_render(load);
	load_gl_GL_EXT_vertex_shader(load);
	load_gl_GL_EXT_blend_func_separate(load);
	load_gl_GL_APPLE_fence(load);
	load_gl_GL_OES_byte_coordinates(load);
	load_gl_GL_ARB_transpose_matrix(load);
	load_gl_GL_ARB_provoking_vertex(load);
	load_gl_GL_EXT_fog_coord(load);
	load_gl_GL_EXT_vertex_array(load);
	load_gl_GL_ARB_half_float_vertex(load);
	load_gl_GL_EXT_blend_equation_separate(load);
	load_gl_GL_ARB_multi_draw_indirect(load);
	load_gl_GL_NV_copy_image(load);
	load_gl_GL_ARB_fragment_layer_viewport(load);
	load_gl_GL_ARB_transform_feedback2(load);
	load_gl_GL_ARB_transform_feedback3(load);
	load_gl_GL_SGIX_ycrcba(load);
	load_gl_GL_EXT_bgra(load);
	load_gl_GL_EXT_texture_compression_s3tc(load);
	load_gl_GL_EXT_pixel_transform(load);
	load_gl_GL_ARB_conservative_depth(load);
	load_gl_GL_ATI_fragment_shader(load);
	load_gl_GL_ARB_vertex_array_object(load);
	load_gl_GL_SUN_triangle_list(load);
	load_gl_GL_EXT_texture_env_add(load);
	load_gl_GL_EXT_packed_depth_stencil(load);
	load_gl_GL_EXT_texture_mirror_clamp(load);
	load_gl_GL_NV_multisample_filter_hint(load);
	load_gl_GL_APPLE_float_pixels(load);
	load_gl_GL_ARB_transform_feedback_instanced(load);
	load_gl_GL_SGIX_async(load);
	load_gl_GL_EXT_texture_compression_latc(load);
	load_gl_GL_NV_shader_atomic_float(load);
	load_gl_GL_ARB_shading_language_100(load);
	load_gl_GL_ARB_texture_mirror_clamp_to_edge(load);
	load_gl_GL_NV_gpu_shader5(load);
	load_gl_GL_ARB_ES2_compatibility(load);
	load_gl_GL_ARB_indirect_parameters(load);
	load_gl_GL_NV_half_float(load);
	load_gl_GL_EXT_coordinate_frame(load);
	load_gl_GL_ATI_texture_mirror_once(load);
	load_gl_GL_IBM_rasterpos_clip(load);
	load_gl_GL_SGIX_shadow(load);
	load_gl_GL_NV_deep_texture3D(load);
	load_gl_GL_ARB_shader_draw_parameters(load);
	load_gl_GL_SGIX_calligraphic_fragment(load);
	load_gl_GL_ARB_shader_bit_encoding(load);
	load_gl_GL_EXT_compiled_vertex_array(load);
	load_gl_GL_NV_depth_buffer_float(load);
	load_gl_GL_NV_occlusion_query(load);
	load_gl_GL_APPLE_flush_buffer_range(load);
	load_gl_GL_ARB_imaging(load);
	load_gl_GL_ARB_draw_buffers_blend(load);
	load_gl_GL_NV_blend_square(load);
	load_gl_GL_AMD_blend_minmax_factor(load);
	load_gl_GL_EXT_texture_sRGB_decode(load);
	load_gl_GL_ARB_shading_language_420pack(load);
	load_gl_GL_ATI_meminfo(load);
	load_gl_GL_EXT_abgr(load);
	load_gl_GL_AMD_pinned_memory(load);
	load_gl_GL_EXT_texture_snorm(load);
	load_gl_GL_SGIX_texture_coordinate_clamp(load);
	load_gl_GL_ARB_clear_buffer_object(load);
	load_gl_GL_ARB_multisample(load);
	load_gl_GL_ARB_sample_shading(load);
	load_gl_GL_INTEL_map_texture(load);
	load_gl_GL_ARB_texture_env_crossbar(load);
	load_gl_GL_EXT_422_pixels(load);
	load_gl_GL_ARB_compute_shader(load);
	load_gl_GL_EXT_blend_logic_op(load);
	load_gl_GL_IBM_cull_vertex(load);
	load_gl_GL_IBM_vertex_array_lists(load);
	load_gl_GL_ARB_color_buffer_float(load);
	load_gl_GL_ARB_bindless_texture(load);
	load_gl_GL_ARB_window_pos(load);
	load_gl_GL_ARB_internalformat_query(load);
	load_gl_GL_ARB_shadow(load);
	load_gl_GL_ARB_texture_mirrored_repeat(load);
	load_gl_GL_EXT_shader_image_load_store(load);
	load_gl_GL_EXT_copy_texture(load);
	load_gl_GL_NV_register_combiners2(load);
	load_gl_GL_SGIX_ir_instrument1(load);
	load_gl_GL_NV_draw_texture(load);
	load_gl_GL_EXT_texture_shared_exponent(load);
	load_gl_GL_EXT_draw_instanced(load);
	load_gl_GL_NV_copy_depth_to_color(load);
	load_gl_GL_ARB_viewport_array(load);
	load_gl_GL_ARB_separate_shader_objects(load);
	load_gl_GL_EXT_depth_bounds_test(load);
	load_gl_GL_HP_image_transform(load);
	load_gl_GL_ARB_texture_env_add(load);
	load_gl_GL_NV_video_capture(load);
	load_gl_GL_ARB_sampler_objects(load);
	load_gl_GL_ARB_matrix_palette(load);
	load_gl_GL_SGIS_texture_color_mask(load);
	load_gl_GL_EXT_packed_pixels(load);
	load_gl_GL_ARB_texture_compression(load);
	load_gl_GL_APPLE_aux_depth_stencil(load);
	load_gl_GL_ARB_shader_subroutine(load);
	load_gl_GL_EXT_framebuffer_sRGB(load);
	load_gl_GL_ARB_texture_storage_multisample(load);
	load_gl_GL_EXT_vertex_attrib_64bit(load);
	load_gl_GL_ARB_depth_texture(load);
	load_gl_GL_NV_shader_buffer_store(load);
	load_gl_GL_OES_query_matrix(load);
	load_gl_GL_APPLE_texture_range(load);
	load_gl_GL_NV_shader_storage_buffer_object(load);
	load_gl_GL_ARB_texture_query_lod(load);
	load_gl_GL_ARB_copy_buffer(load);
	load_gl_GL_ARB_shader_image_size(load);
	load_gl_GL_NV_shader_atomic_counters(load);
	load_gl_GL_APPLE_object_purgeable(load);
	load_gl_GL_ARB_occlusion_query(load);
	load_gl_GL_INGR_color_clamp(load);
	load_gl_GL_SGI_color_table(load);
	load_gl_GL_NV_gpu_program5_mem_extended(load);
	load_gl_GL_ARB_texture_cube_map_array(load);
	load_gl_GL_SGIX_scalebias_hint(load);
	load_gl_GL_EXT_gpu_shader4(load);
	load_gl_GL_NV_geometry_program4(load);
	load_gl_GL_EXT_framebuffer_multisample_blit_scaled(load);
	load_gl_GL_AMD_debug_output(load);
	load_gl_GL_ARB_texture_border_clamp(load);
	load_gl_GL_ARB_fragment_coord_conventions(load);
	load_gl_GL_ARB_multitexture(load);
	load_gl_GL_SGIX_polynomial_ffd(load);
	load_gl_GL_EXT_provoking_vertex(load);
	load_gl_GL_ARB_point_parameters(load);
	load_gl_GL_ARB_shader_image_load_store(load);
	load_gl_GL_HP_occlusion_test(load);
	load_gl_GL_ARB_ES3_compatibility(load);
	load_gl_GL_SGIX_framezoom(load);
	load_gl_GL_ARB_texture_buffer_object_rgb32(load);
	load_gl_GL_NV_bindless_multi_draw_indirect(load);
	load_gl_GL_SGIX_texture_multi_buffer(load);
	load_gl_GL_EXT_transform_feedback(load);
	load_gl_GL_KHR_texture_compression_astc_ldr(load);
	load_gl_GL_3DFX_multisample(load);
	load_gl_GL_ARB_texture_env_dot3(load);
	load_gl_GL_NV_gpu_program4(load);
	load_gl_GL_NV_gpu_program5(load);
	load_gl_GL_NV_float_buffer(load);
	load_gl_GL_SGIS_texture_edge_clamp(load);
	load_gl_GL_ARB_framebuffer_sRGB(load);
	load_gl_GL_SUN_slice_accum(load);
	load_gl_GL_EXT_index_texture(load);
	load_gl_GL_ARB_geometry_shader4(load);
	load_gl_GL_EXT_separate_specular_color(load);
	load_gl_GL_AMD_depth_clamp_separate(load);
	load_gl_GL_SUN_convolution_border_modes(load);
	load_gl_GL_SGIX_sprite(load);
	load_gl_GL_ARB_get_program_binary(load);
	load_gl_GL_SGIS_multisample(load);
	load_gl_GL_EXT_framebuffer_object(load);
	load_gl_GL_ARB_robustness_isolation(load);
	load_gl_GL_ARB_vertex_array_bgra(load);
	load_gl_GL_APPLE_vertex_array_range(load);
	load_gl_GL_AMD_query_buffer_object(load);
	load_gl_GL_NV_register_combiners(load);
	load_gl_GL_ARB_draw_buffers(load);
	load_gl_GL_ARB_clear_texture(load);
	load_gl_GL_ARB_debug_output(load);
	load_gl_GL_SGI_color_matrix(load);
	load_gl_GL_EXT_cull_vertex(load);
	load_gl_GL_EXT_texture_sRGB(load);
	load_gl_GL_APPLE_row_bytes(load);
	load_gl_GL_NV_texgen_reflection(load);
	load_gl_GL_IBM_multimode_draw_arrays(load);
	load_gl_GL_APPLE_vertex_array_object(load);
	load_gl_GL_3DFX_texture_compression_FXT1(load);
	load_gl_GL_SGIX_ycrcb(load);
	load_gl_GL_AMD_conservative_depth(load);
	load_gl_GL_ARB_texture_float(load);
	load_gl_GL_ARB_compressed_texture_pixel_storage(load);
	load_gl_GL_SGIS_detail_texture(load);
	load_gl_GL_ARB_draw_instanced(load);
	load_gl_GL_OES_read_format(load);
	load_gl_GL_ATI_texture_float(load);
	load_gl_GL_ARB_texture_gather(load);
	load_gl_GL_AMD_vertex_shader_layer(load);
	load_gl_GL_ARB_shading_language_include(load);
	load_gl_GL_APPLE_client_storage(load);
	load_gl_GL_WIN_phong_shading(load);
	load_gl_GL_INGR_blend_func_separate(load);
	load_gl_GL_NV_path_rendering(load);
	load_gl_GL_ATI_vertex_streams(load);
	load_gl_GL_ARB_texture_non_power_of_two(load);
	load_gl_GL_APPLE_rgb_422(load);
	load_gl_GL_EXT_texture_lod_bias(load);
	load_gl_GL_ARB_seamless_cube_map(load);
	load_gl_GL_ARB_shader_group_vote(load);
	load_gl_GL_NV_vdpau_interop(load);
	load_gl_GL_ARB_occlusion_query2(load);
	load_gl_GL_ARB_internalformat_query2(load);
	load_gl_GL_EXT_texture_filter_anisotropic(load);
	load_gl_GL_SUN_vertex(load);
	load_gl_GL_SGIX_igloo_interface(load);
	load_gl_GL_SGIS_texture_lod(load);
	load_gl_GL_NV_vertex_program3(load);
	load_gl_GL_ARB_draw_indirect(load);
	load_gl_GL_NV_vertex_program4(load);
	load_gl_GL_AMD_transform_feedback3_lines_triangles(load);
	load_gl_GL_SGIS_fog_function(load);
	load_gl_GL_EXT_x11_sync_object(load);
	load_gl_GL_ARB_sync(load);
	load_gl_GL_ARB_compute_variable_group_size(load);
	load_gl_GL_OES_fixed_point(load);
	load_gl_GL_EXT_framebuffer_multisample(load);
	load_gl_GL_ARB_gpu_shader5(load);
	load_gl_GL_SGIS_texture4D(load);
	load_gl_GL_EXT_texture3D(load);
	load_gl_GL_EXT_multisample(load);
	load_gl_GL_EXT_secondary_color(load);
	load_gl_GL_NV_parameter_buffer_object2(load);
	load_gl_GL_ATI_vertex_array_object(load);
	load_gl_GL_ARB_sparse_texture(load);
	load_gl_GL_SGIS_point_line_texgen(load);
	load_gl_GL_EXT_draw_range_elements(load);
	load_gl_GL_SGIX_blend_alpha_minmax(load);

	return glv;
}

private:

GLVersion find_core() {
	int major;
	int minor;
	glGetIntegerv(GL_MAJOR_VERSION, &major);
	glGetIntegerv(GL_MINOR_VERSION, &minor);
	GL_VERSION_1_0 = (major == 1 && minor >= 0) || major > 1;
	GL_VERSION_1_1 = (major == 1 && minor >= 1) || major > 1;
	GL_VERSION_1_2 = (major == 1 && minor >= 2) || major > 1;
	GL_VERSION_1_3 = (major == 1 && minor >= 3) || major > 1;
	GL_VERSION_1_4 = (major == 1 && minor >= 4) || major > 1;
	GL_VERSION_1_5 = (major == 1 && minor >= 5) || major > 1;
	GL_VERSION_2_0 = (major == 2 && minor >= 0) || major > 2;
	GL_VERSION_2_1 = (major == 2 && minor >= 1) || major > 2;
	GL_VERSION_3_0 = (major == 3 && minor >= 0) || major > 3;
	GL_VERSION_3_1 = (major == 3 && minor >= 1) || major > 3;
	GL_VERSION_3_2 = (major == 3 && minor >= 2) || major > 3;
	GL_VERSION_3_3 = (major == 3 && minor >= 3) || major > 3;
	GL_VERSION_4_0 = (major == 4 && minor >= 0) || major > 4;
	GL_VERSION_4_1 = (major == 4 && minor >= 1) || major > 4;
	GL_VERSION_4_2 = (major == 4 && minor >= 2) || major > 4;
	GL_VERSION_4_3 = (major == 4 && minor >= 3) || major > 4;
	return GLVersion(major, minor);
}

void find_extensions() {
	string extensions = to!string(glGetString(GL_EXTENSIONS));

	GL_SGIX_pixel_tiles = canFind(extensions, "GL_SGIX_pixel_tiles");
	GL_NV_point_sprite = canFind(extensions, "GL_NV_point_sprite");
	GL_APPLE_element_array = canFind(extensions, "GL_APPLE_element_array");
	GL_AMD_multi_draw_indirect = canFind(extensions, "GL_AMD_multi_draw_indirect");
	GL_EXT_blend_subtract = canFind(extensions, "GL_EXT_blend_subtract");
	GL_SGIX_tag_sample_buffer = canFind(extensions, "GL_SGIX_tag_sample_buffer");
	GL_IBM_texture_mirrored_repeat = canFind(extensions, "GL_IBM_texture_mirrored_repeat");
	GL_APPLE_transform_hint = canFind(extensions, "GL_APPLE_transform_hint");
	GL_ATI_separate_stencil = canFind(extensions, "GL_ATI_separate_stencil");
	GL_NV_vertex_program2_option = canFind(extensions, "GL_NV_vertex_program2_option");
	GL_EXT_texture_buffer_object = canFind(extensions, "GL_EXT_texture_buffer_object");
	GL_ARB_vertex_blend = canFind(extensions, "GL_ARB_vertex_blend");
	GL_NV_vertex_program2 = canFind(extensions, "GL_NV_vertex_program2");
	GL_ARB_program_interface_query = canFind(extensions, "GL_ARB_program_interface_query");
	GL_EXT_misc_attribute = canFind(extensions, "GL_EXT_misc_attribute");
	GL_NV_multisample_coverage = canFind(extensions, "GL_NV_multisample_coverage");
	GL_ARB_shading_language_packing = canFind(extensions, "GL_ARB_shading_language_packing");
	GL_EXT_texture_cube_map = canFind(extensions, "GL_EXT_texture_cube_map");
	GL_ARB_texture_stencil8 = canFind(extensions, "GL_ARB_texture_stencil8");
	GL_EXT_index_func = canFind(extensions, "GL_EXT_index_func");
	GL_OES_compressed_paletted_texture = canFind(extensions, "GL_OES_compressed_paletted_texture");
	GL_NV_depth_clamp = canFind(extensions, "GL_NV_depth_clamp");
	GL_NV_shader_buffer_load = canFind(extensions, "GL_NV_shader_buffer_load");
	GL_EXT_color_subtable = canFind(extensions, "GL_EXT_color_subtable");
	GL_SUNX_constant_data = canFind(extensions, "GL_SUNX_constant_data");
	GL_EXT_multi_draw_arrays = canFind(extensions, "GL_EXT_multi_draw_arrays");
	GL_ARB_shader_atomic_counters = canFind(extensions, "GL_ARB_shader_atomic_counters");
	GL_ARB_arrays_of_arrays = canFind(extensions, "GL_ARB_arrays_of_arrays");
	GL_NV_conditional_render = canFind(extensions, "GL_NV_conditional_render");
	GL_EXT_texture_env_combine = canFind(extensions, "GL_EXT_texture_env_combine");
	GL_NV_fog_distance = canFind(extensions, "GL_NV_fog_distance");
	GL_SGIX_async_histogram = canFind(extensions, "GL_SGIX_async_histogram");
	GL_MESA_resize_buffers = canFind(extensions, "GL_MESA_resize_buffers");
	GL_NV_light_max_exponent = canFind(extensions, "GL_NV_light_max_exponent");
	GL_NV_texture_env_combine4 = canFind(extensions, "GL_NV_texture_env_combine4");
	GL_ARB_texture_view = canFind(extensions, "GL_ARB_texture_view");
	GL_ARB_texture_env_combine = canFind(extensions, "GL_ARB_texture_env_combine");
	GL_ARB_map_buffer_range = canFind(extensions, "GL_ARB_map_buffer_range");
	GL_EXT_convolution = canFind(extensions, "GL_EXT_convolution");
	GL_NV_compute_program5 = canFind(extensions, "GL_NV_compute_program5");
	GL_NV_vertex_attrib_integer_64bit = canFind(extensions, "GL_NV_vertex_attrib_integer_64bit");
	GL_EXT_paletted_texture = canFind(extensions, "GL_EXT_paletted_texture");
	GL_ARB_texture_buffer_object = canFind(extensions, "GL_ARB_texture_buffer_object");
	GL_ATI_pn_triangles = canFind(extensions, "GL_ATI_pn_triangles");
	GL_SGIX_resample = canFind(extensions, "GL_SGIX_resample");
	GL_SGIX_flush_raster = canFind(extensions, "GL_SGIX_flush_raster");
	GL_EXT_light_texture = canFind(extensions, "GL_EXT_light_texture");
	GL_ARB_point_sprite = canFind(extensions, "GL_ARB_point_sprite");
	GL_ARB_half_float_pixel = canFind(extensions, "GL_ARB_half_float_pixel");
	GL_NV_tessellation_program5 = canFind(extensions, "GL_NV_tessellation_program5");
	GL_REND_screen_coordinates = canFind(extensions, "GL_REND_screen_coordinates");
	GL_EXT_shared_texture_palette = canFind(extensions, "GL_EXT_shared_texture_palette");
	GL_EXT_packed_float = canFind(extensions, "GL_EXT_packed_float");
	GL_OML_subsample = canFind(extensions, "GL_OML_subsample");
	GL_SGIX_vertex_preclip = canFind(extensions, "GL_SGIX_vertex_preclip");
	GL_SGIX_texture_scale_bias = canFind(extensions, "GL_SGIX_texture_scale_bias");
	GL_AMD_draw_buffers_blend = canFind(extensions, "GL_AMD_draw_buffers_blend");
	GL_MESA_window_pos = canFind(extensions, "GL_MESA_window_pos");
	GL_EXT_texture_array = canFind(extensions, "GL_EXT_texture_array");
	GL_NV_texture_barrier = canFind(extensions, "GL_NV_texture_barrier");
	GL_ARB_texture_query_levels = canFind(extensions, "GL_ARB_texture_query_levels");
	GL_NV_texgen_emboss = canFind(extensions, "GL_NV_texgen_emboss");
	GL_EXT_texture_swizzle = canFind(extensions, "GL_EXT_texture_swizzle");
	GL_ARB_texture_rg = canFind(extensions, "GL_ARB_texture_rg");
	GL_ARB_vertex_type_2_10_10_10_rev = canFind(extensions, "GL_ARB_vertex_type_2_10_10_10_rev");
	GL_ARB_fragment_shader = canFind(extensions, "GL_ARB_fragment_shader");
	GL_3DFX_tbuffer = canFind(extensions, "GL_3DFX_tbuffer");
	GL_GREMEDY_frame_terminator = canFind(extensions, "GL_GREMEDY_frame_terminator");
	GL_ARB_blend_func_extended = canFind(extensions, "GL_ARB_blend_func_extended");
	GL_EXT_separate_shader_objects = canFind(extensions, "GL_EXT_separate_shader_objects");
	GL_NV_texture_multisample = canFind(extensions, "GL_NV_texture_multisample");
	GL_ARB_shader_objects = canFind(extensions, "GL_ARB_shader_objects");
	GL_ARB_framebuffer_object = canFind(extensions, "GL_ARB_framebuffer_object");
	GL_ATI_envmap_bumpmap = canFind(extensions, "GL_ATI_envmap_bumpmap");
	GL_ARB_robust_buffer_access_behavior = canFind(extensions, "GL_ARB_robust_buffer_access_behavior");
	GL_ARB_shader_stencil_export = canFind(extensions, "GL_ARB_shader_stencil_export");
	GL_NV_texture_rectangle = canFind(extensions, "GL_NV_texture_rectangle");
	GL_ARB_enhanced_layouts = canFind(extensions, "GL_ARB_enhanced_layouts");
	GL_ARB_texture_rectangle = canFind(extensions, "GL_ARB_texture_rectangle");
	GL_SGI_texture_color_table = canFind(extensions, "GL_SGI_texture_color_table");
	GL_ATI_map_object_buffer = canFind(extensions, "GL_ATI_map_object_buffer");
	GL_ARB_robustness = canFind(extensions, "GL_ARB_robustness");
	GL_NV_pixel_data_range = canFind(extensions, "GL_NV_pixel_data_range");
	GL_EXT_framebuffer_blit = canFind(extensions, "GL_EXT_framebuffer_blit");
	GL_ARB_gpu_shader_fp64 = canFind(extensions, "GL_ARB_gpu_shader_fp64");
	GL_SGIX_depth_texture = canFind(extensions, "GL_SGIX_depth_texture");
	GL_EXT_vertex_weighting = canFind(extensions, "GL_EXT_vertex_weighting");
	GL_GREMEDY_string_marker = canFind(extensions, "GL_GREMEDY_string_marker");
	GL_ARB_texture_compression_bptc = canFind(extensions, "GL_ARB_texture_compression_bptc");
	GL_EXT_subtexture = canFind(extensions, "GL_EXT_subtexture");
	GL_EXT_pixel_transform_color_table = canFind(extensions, "GL_EXT_pixel_transform_color_table");
	GL_EXT_texture_compression_rgtc = canFind(extensions, "GL_EXT_texture_compression_rgtc");
	GL_SGIX_depth_pass_instrument = canFind(extensions, "GL_SGIX_depth_pass_instrument");
	GL_ARB_shader_precision = canFind(extensions, "GL_ARB_shader_precision");
	GL_NV_evaluators = canFind(extensions, "GL_NV_evaluators");
	GL_SGIS_texture_filter4 = canFind(extensions, "GL_SGIS_texture_filter4");
	GL_AMD_performance_monitor = canFind(extensions, "GL_AMD_performance_monitor");
	GL_NV_geometry_shader4 = canFind(extensions, "GL_NV_geometry_shader4");
	GL_EXT_stencil_clear_tag = canFind(extensions, "GL_EXT_stencil_clear_tag");
	GL_NV_vertex_program1_1 = canFind(extensions, "GL_NV_vertex_program1_1");
	GL_NV_present_video = canFind(extensions, "GL_NV_present_video");
	GL_ARB_texture_compression_rgtc = canFind(extensions, "GL_ARB_texture_compression_rgtc");
	GL_HP_convolution_border_modes = canFind(extensions, "GL_HP_convolution_border_modes");
	GL_EXT_gpu_program_parameters = canFind(extensions, "GL_EXT_gpu_program_parameters");
	GL_SGIX_list_priority = canFind(extensions, "GL_SGIX_list_priority");
	GL_ARB_stencil_texturing = canFind(extensions, "GL_ARB_stencil_texturing");
	GL_SGIX_fog_offset = canFind(extensions, "GL_SGIX_fog_offset");
	GL_ARB_draw_elements_base_vertex = canFind(extensions, "GL_ARB_draw_elements_base_vertex");
	GL_INGR_interlace_read = canFind(extensions, "GL_INGR_interlace_read");
	GL_NV_transform_feedback = canFind(extensions, "GL_NV_transform_feedback");
	GL_NV_fragment_program = canFind(extensions, "GL_NV_fragment_program");
	GL_AMD_stencil_operation_extended = canFind(extensions, "GL_AMD_stencil_operation_extended");
	GL_ARB_seamless_cubemap_per_texture = canFind(extensions, "GL_ARB_seamless_cubemap_per_texture");
	GL_ARB_instanced_arrays = canFind(extensions, "GL_ARB_instanced_arrays");
	GL_EXT_polygon_offset = canFind(extensions, "GL_EXT_polygon_offset");
	GL_NV_vertex_array_range2 = canFind(extensions, "GL_NV_vertex_array_range2");
	GL_AMD_sparse_texture = canFind(extensions, "GL_AMD_sparse_texture");
	GL_NV_fence = canFind(extensions, "GL_NV_fence");
	GL_ARB_texture_buffer_range = canFind(extensions, "GL_ARB_texture_buffer_range");
	GL_SUN_mesh_array = canFind(extensions, "GL_SUN_mesh_array");
	GL_ARB_vertex_attrib_binding = canFind(extensions, "GL_ARB_vertex_attrib_binding");
	GL_ARB_framebuffer_no_attachments = canFind(extensions, "GL_ARB_framebuffer_no_attachments");
	GL_ARB_cl_event = canFind(extensions, "GL_ARB_cl_event");
	GL_NV_packed_depth_stencil = canFind(extensions, "GL_NV_packed_depth_stencil");
	GL_OES_single_precision = canFind(extensions, "GL_OES_single_precision");
	GL_NV_primitive_restart = canFind(extensions, "GL_NV_primitive_restart");
	GL_SUN_global_alpha = canFind(extensions, "GL_SUN_global_alpha");
	GL_EXT_texture_object = canFind(extensions, "GL_EXT_texture_object");
	GL_AMD_name_gen_delete = canFind(extensions, "GL_AMD_name_gen_delete");
	GL_NV_texture_compression_vtc = canFind(extensions, "GL_NV_texture_compression_vtc");
	GL_SGIX_ycrcb_subsample = canFind(extensions, "GL_SGIX_ycrcb_subsample");
	GL_NV_texture_shader3 = canFind(extensions, "GL_NV_texture_shader3");
	GL_NV_texture_shader2 = canFind(extensions, "GL_NV_texture_shader2");
	GL_EXT_texture = canFind(extensions, "GL_EXT_texture");
	GL_ARB_buffer_storage = canFind(extensions, "GL_ARB_buffer_storage");
	GL_AMD_shader_atomic_counter_ops = canFind(extensions, "GL_AMD_shader_atomic_counter_ops");
	GL_APPLE_vertex_program_evaluators = canFind(extensions, "GL_APPLE_vertex_program_evaluators");
	GL_ARB_multi_bind = canFind(extensions, "GL_ARB_multi_bind");
	GL_ARB_explicit_uniform_location = canFind(extensions, "GL_ARB_explicit_uniform_location");
	GL_ARB_depth_buffer_float = canFind(extensions, "GL_ARB_depth_buffer_float");
	GL_SGIX_shadow_ambient = canFind(extensions, "GL_SGIX_shadow_ambient");
	GL_ARB_texture_cube_map = canFind(extensions, "GL_ARB_texture_cube_map");
	GL_AMD_vertex_shader_viewport_index = canFind(extensions, "GL_AMD_vertex_shader_viewport_index");
	GL_NV_vertex_buffer_unified_memory = canFind(extensions, "GL_NV_vertex_buffer_unified_memory");
	GL_EXT_texture_env_dot3 = canFind(extensions, "GL_EXT_texture_env_dot3");
	GL_ATI_texture_env_combine3 = canFind(extensions, "GL_ATI_texture_env_combine3");
	GL_ARB_map_buffer_alignment = canFind(extensions, "GL_ARB_map_buffer_alignment");
	GL_NV_blend_equation_advanced = canFind(extensions, "GL_NV_blend_equation_advanced");
	GL_SGIS_sharpen_texture = canFind(extensions, "GL_SGIS_sharpen_texture");
	GL_ARB_vertex_program = canFind(extensions, "GL_ARB_vertex_program");
	GL_ARB_texture_rgb10_a2ui = canFind(extensions, "GL_ARB_texture_rgb10_a2ui");
	GL_OML_interlace = canFind(extensions, "GL_OML_interlace");
	GL_ATI_pixel_format_float = canFind(extensions, "GL_ATI_pixel_format_float");
	GL_ARB_vertex_buffer_object = canFind(extensions, "GL_ARB_vertex_buffer_object");
	GL_EXT_shadow_funcs = canFind(extensions, "GL_EXT_shadow_funcs");
	GL_ATI_text_fragment_shader = canFind(extensions, "GL_ATI_text_fragment_shader");
	GL_NV_vertex_array_range = canFind(extensions, "GL_NV_vertex_array_range");
	GL_SGIX_fragment_lighting = canFind(extensions, "GL_SGIX_fragment_lighting");
	GL_NV_texture_expand_normal = canFind(extensions, "GL_NV_texture_expand_normal");
	GL_NV_framebuffer_multisample_coverage = canFind(extensions, "GL_NV_framebuffer_multisample_coverage");
	GL_EXT_timer_query = canFind(extensions, "GL_EXT_timer_query");
	GL_EXT_vertex_array_bgra = canFind(extensions, "GL_EXT_vertex_array_bgra");
	GL_NV_bindless_texture = canFind(extensions, "GL_NV_bindless_texture");
	GL_KHR_debug = canFind(extensions, "GL_KHR_debug");
	GL_SGIS_texture_border_clamp = canFind(extensions, "GL_SGIS_texture_border_clamp");
	GL_ATI_vertex_attrib_array_object = canFind(extensions, "GL_ATI_vertex_attrib_array_object");
	GL_SGIX_clipmap = canFind(extensions, "GL_SGIX_clipmap");
	GL_EXT_geometry_shader4 = canFind(extensions, "GL_EXT_geometry_shader4");
	GL_MESA_ycbcr_texture = canFind(extensions, "GL_MESA_ycbcr_texture");
	GL_MESAX_texture_stack = canFind(extensions, "GL_MESAX_texture_stack");
	GL_AMD_seamless_cubemap_per_texture = canFind(extensions, "GL_AMD_seamless_cubemap_per_texture");
	GL_EXT_bindable_uniform = canFind(extensions, "GL_EXT_bindable_uniform");
	GL_ARB_fragment_program_shadow = canFind(extensions, "GL_ARB_fragment_program_shadow");
	GL_ATI_element_array = canFind(extensions, "GL_ATI_element_array");
	GL_AMD_texture_texture4 = canFind(extensions, "GL_AMD_texture_texture4");
	GL_SGIX_reference_plane = canFind(extensions, "GL_SGIX_reference_plane");
	GL_EXT_stencil_two_side = canFind(extensions, "GL_EXT_stencil_two_side");
	GL_SGIX_texture_lod_bias = canFind(extensions, "GL_SGIX_texture_lod_bias");
	GL_NV_explicit_multisample = canFind(extensions, "GL_NV_explicit_multisample");
	GL_IBM_static_data = canFind(extensions, "GL_IBM_static_data");
	GL_EXT_clip_volume_hint = canFind(extensions, "GL_EXT_clip_volume_hint");
	GL_EXT_texture_perturb_normal = canFind(extensions, "GL_EXT_texture_perturb_normal");
	GL_NV_fragment_program2 = canFind(extensions, "GL_NV_fragment_program2");
	GL_NV_fragment_program4 = canFind(extensions, "GL_NV_fragment_program4");
	GL_EXT_point_parameters = canFind(extensions, "GL_EXT_point_parameters");
	GL_PGI_misc_hints = canFind(extensions, "GL_PGI_misc_hints");
	GL_SGIX_subsample = canFind(extensions, "GL_SGIX_subsample");
	GL_AMD_shader_stencil_export = canFind(extensions, "GL_AMD_shader_stencil_export");
	GL_ARB_shader_texture_lod = canFind(extensions, "GL_ARB_shader_texture_lod");
	GL_ARB_vertex_shader = canFind(extensions, "GL_ARB_vertex_shader");
	GL_ARB_depth_clamp = canFind(extensions, "GL_ARB_depth_clamp");
	GL_SGIS_texture_select = canFind(extensions, "GL_SGIS_texture_select");
	GL_NV_texture_shader = canFind(extensions, "GL_NV_texture_shader");
	GL_ARB_tessellation_shader = canFind(extensions, "GL_ARB_tessellation_shader");
	GL_EXT_draw_buffers2 = canFind(extensions, "GL_EXT_draw_buffers2");
	GL_ARB_vertex_attrib_64bit = canFind(extensions, "GL_ARB_vertex_attrib_64bit");
	GL_WIN_specular_fog = canFind(extensions, "GL_WIN_specular_fog");
	GL_AMD_interleaved_elements = canFind(extensions, "GL_AMD_interleaved_elements");
	GL_ARB_fragment_program = canFind(extensions, "GL_ARB_fragment_program");
	GL_OML_resample = canFind(extensions, "GL_OML_resample");
	GL_APPLE_ycbcr_422 = canFind(extensions, "GL_APPLE_ycbcr_422");
	GL_SGIX_texture_add_env = canFind(extensions, "GL_SGIX_texture_add_env");
	GL_ARB_shadow_ambient = canFind(extensions, "GL_ARB_shadow_ambient");
	GL_ARB_texture_storage = canFind(extensions, "GL_ARB_texture_storage");
	GL_EXT_pixel_buffer_object = canFind(extensions, "GL_EXT_pixel_buffer_object");
	GL_ARB_copy_image = canFind(extensions, "GL_ARB_copy_image");
	GL_SGIS_pixel_texture = canFind(extensions, "GL_SGIS_pixel_texture");
	GL_SGIS_generate_mipmap = canFind(extensions, "GL_SGIS_generate_mipmap");
	GL_SGIX_instruments = canFind(extensions, "GL_SGIX_instruments");
	GL_HP_texture_lighting = canFind(extensions, "GL_HP_texture_lighting");
	GL_ARB_shader_storage_buffer_object = canFind(extensions, "GL_ARB_shader_storage_buffer_object");
	GL_EXT_blend_minmax = canFind(extensions, "GL_EXT_blend_minmax");
	GL_MESA_pack_invert = canFind(extensions, "GL_MESA_pack_invert");
	GL_ARB_base_instance = canFind(extensions, "GL_ARB_base_instance");
	GL_SGIX_convolution_accuracy = canFind(extensions, "GL_SGIX_convolution_accuracy");
	GL_PGI_vertex_hints = canFind(extensions, "GL_PGI_vertex_hints");
	GL_EXT_texture_integer = canFind(extensions, "GL_EXT_texture_integer");
	GL_ARB_texture_multisample = canFind(extensions, "GL_ARB_texture_multisample");
	GL_S3_s3tc = canFind(extensions, "GL_S3_s3tc");
	GL_ARB_query_buffer_object = canFind(extensions, "GL_ARB_query_buffer_object");
	GL_AMD_vertex_shader_tessellator = canFind(extensions, "GL_AMD_vertex_shader_tessellator");
	GL_ARB_invalidate_subdata = canFind(extensions, "GL_ARB_invalidate_subdata");
	GL_EXT_index_material = canFind(extensions, "GL_EXT_index_material");
	GL_NV_blend_equation_advanced_coherent = canFind(extensions, "GL_NV_blend_equation_advanced_coherent");
	GL_INTEL_parallel_arrays = canFind(extensions, "GL_INTEL_parallel_arrays");
	GL_ATI_draw_buffers = canFind(extensions, "GL_ATI_draw_buffers");
	GL_EXT_cmyka = canFind(extensions, "GL_EXT_cmyka");
	GL_SGIX_pixel_texture = canFind(extensions, "GL_SGIX_pixel_texture");
	GL_APPLE_specular_vector = canFind(extensions, "GL_APPLE_specular_vector");
	GL_ARB_compatibility = canFind(extensions, "GL_ARB_compatibility");
	GL_ARB_timer_query = canFind(extensions, "GL_ARB_timer_query");
	GL_SGIX_interlace = canFind(extensions, "GL_SGIX_interlace");
	GL_NV_parameter_buffer_object = canFind(extensions, "GL_NV_parameter_buffer_object");
	GL_AMD_shader_trinary_minmax = canFind(extensions, "GL_AMD_shader_trinary_minmax");
	GL_EXT_rescale_normal = canFind(extensions, "GL_EXT_rescale_normal");
	GL_ARB_pixel_buffer_object = canFind(extensions, "GL_ARB_pixel_buffer_object");
	GL_ARB_uniform_buffer_object = canFind(extensions, "GL_ARB_uniform_buffer_object");
	GL_ARB_vertex_type_10f_11f_11f_rev = canFind(extensions, "GL_ARB_vertex_type_10f_11f_11f_rev");
	GL_ARB_texture_swizzle = canFind(extensions, "GL_ARB_texture_swizzle");
	GL_NV_transform_feedback2 = canFind(extensions, "GL_NV_transform_feedback2");
	GL_SGIX_async_pixel = canFind(extensions, "GL_SGIX_async_pixel");
	GL_NV_fragment_program_option = canFind(extensions, "GL_NV_fragment_program_option");
	GL_ARB_explicit_attrib_location = canFind(extensions, "GL_ARB_explicit_attrib_location");
	GL_EXT_blend_color = canFind(extensions, "GL_EXT_blend_color");
	GL_EXT_stencil_wrap = canFind(extensions, "GL_EXT_stencil_wrap");
	GL_EXT_index_array_formats = canFind(extensions, "GL_EXT_index_array_formats");
	GL_EXT_histogram = canFind(extensions, "GL_EXT_histogram");
	GL_SGIS_point_parameters = canFind(extensions, "GL_SGIS_point_parameters");
	GL_EXT_direct_state_access = canFind(extensions, "GL_EXT_direct_state_access");
	GL_AMD_sample_positions = canFind(extensions, "GL_AMD_sample_positions");
	GL_NV_vertex_program = canFind(extensions, "GL_NV_vertex_program");
	GL_NVX_conditional_render = canFind(extensions, "GL_NVX_conditional_render");
	GL_EXT_vertex_shader = canFind(extensions, "GL_EXT_vertex_shader");
	GL_EXT_blend_func_separate = canFind(extensions, "GL_EXT_blend_func_separate");
	GL_APPLE_fence = canFind(extensions, "GL_APPLE_fence");
	GL_OES_byte_coordinates = canFind(extensions, "GL_OES_byte_coordinates");
	GL_ARB_transpose_matrix = canFind(extensions, "GL_ARB_transpose_matrix");
	GL_ARB_provoking_vertex = canFind(extensions, "GL_ARB_provoking_vertex");
	GL_EXT_fog_coord = canFind(extensions, "GL_EXT_fog_coord");
	GL_EXT_vertex_array = canFind(extensions, "GL_EXT_vertex_array");
	GL_ARB_half_float_vertex = canFind(extensions, "GL_ARB_half_float_vertex");
	GL_EXT_blend_equation_separate = canFind(extensions, "GL_EXT_blend_equation_separate");
	GL_ARB_multi_draw_indirect = canFind(extensions, "GL_ARB_multi_draw_indirect");
	GL_NV_copy_image = canFind(extensions, "GL_NV_copy_image");
	GL_ARB_fragment_layer_viewport = canFind(extensions, "GL_ARB_fragment_layer_viewport");
	GL_ARB_transform_feedback2 = canFind(extensions, "GL_ARB_transform_feedback2");
	GL_ARB_transform_feedback3 = canFind(extensions, "GL_ARB_transform_feedback3");
	GL_SGIX_ycrcba = canFind(extensions, "GL_SGIX_ycrcba");
	GL_EXT_bgra = canFind(extensions, "GL_EXT_bgra");
	GL_EXT_texture_compression_s3tc = canFind(extensions, "GL_EXT_texture_compression_s3tc");
	GL_EXT_pixel_transform = canFind(extensions, "GL_EXT_pixel_transform");
	GL_ARB_conservative_depth = canFind(extensions, "GL_ARB_conservative_depth");
	GL_ATI_fragment_shader = canFind(extensions, "GL_ATI_fragment_shader");
	GL_ARB_vertex_array_object = canFind(extensions, "GL_ARB_vertex_array_object");
	GL_SUN_triangle_list = canFind(extensions, "GL_SUN_triangle_list");
	GL_EXT_texture_env_add = canFind(extensions, "GL_EXT_texture_env_add");
	GL_EXT_packed_depth_stencil = canFind(extensions, "GL_EXT_packed_depth_stencil");
	GL_EXT_texture_mirror_clamp = canFind(extensions, "GL_EXT_texture_mirror_clamp");
	GL_NV_multisample_filter_hint = canFind(extensions, "GL_NV_multisample_filter_hint");
	GL_APPLE_float_pixels = canFind(extensions, "GL_APPLE_float_pixels");
	GL_ARB_transform_feedback_instanced = canFind(extensions, "GL_ARB_transform_feedback_instanced");
	GL_SGIX_async = canFind(extensions, "GL_SGIX_async");
	GL_EXT_texture_compression_latc = canFind(extensions, "GL_EXT_texture_compression_latc");
	GL_NV_shader_atomic_float = canFind(extensions, "GL_NV_shader_atomic_float");
	GL_ARB_shading_language_100 = canFind(extensions, "GL_ARB_shading_language_100");
	GL_ARB_texture_mirror_clamp_to_edge = canFind(extensions, "GL_ARB_texture_mirror_clamp_to_edge");
	GL_NV_gpu_shader5 = canFind(extensions, "GL_NV_gpu_shader5");
	GL_ARB_ES2_compatibility = canFind(extensions, "GL_ARB_ES2_compatibility");
	GL_ARB_indirect_parameters = canFind(extensions, "GL_ARB_indirect_parameters");
	GL_NV_half_float = canFind(extensions, "GL_NV_half_float");
	GL_EXT_coordinate_frame = canFind(extensions, "GL_EXT_coordinate_frame");
	GL_ATI_texture_mirror_once = canFind(extensions, "GL_ATI_texture_mirror_once");
	GL_IBM_rasterpos_clip = canFind(extensions, "GL_IBM_rasterpos_clip");
	GL_SGIX_shadow = canFind(extensions, "GL_SGIX_shadow");
	GL_NV_deep_texture3D = canFind(extensions, "GL_NV_deep_texture3D");
	GL_ARB_shader_draw_parameters = canFind(extensions, "GL_ARB_shader_draw_parameters");
	GL_SGIX_calligraphic_fragment = canFind(extensions, "GL_SGIX_calligraphic_fragment");
	GL_ARB_shader_bit_encoding = canFind(extensions, "GL_ARB_shader_bit_encoding");
	GL_EXT_compiled_vertex_array = canFind(extensions, "GL_EXT_compiled_vertex_array");
	GL_NV_depth_buffer_float = canFind(extensions, "GL_NV_depth_buffer_float");
	GL_NV_occlusion_query = canFind(extensions, "GL_NV_occlusion_query");
	GL_APPLE_flush_buffer_range = canFind(extensions, "GL_APPLE_flush_buffer_range");
	GL_ARB_imaging = canFind(extensions, "GL_ARB_imaging");
	GL_ARB_draw_buffers_blend = canFind(extensions, "GL_ARB_draw_buffers_blend");
	GL_NV_blend_square = canFind(extensions, "GL_NV_blend_square");
	GL_AMD_blend_minmax_factor = canFind(extensions, "GL_AMD_blend_minmax_factor");
	GL_EXT_texture_sRGB_decode = canFind(extensions, "GL_EXT_texture_sRGB_decode");
	GL_ARB_shading_language_420pack = canFind(extensions, "GL_ARB_shading_language_420pack");
	GL_ATI_meminfo = canFind(extensions, "GL_ATI_meminfo");
	GL_EXT_abgr = canFind(extensions, "GL_EXT_abgr");
	GL_AMD_pinned_memory = canFind(extensions, "GL_AMD_pinned_memory");
	GL_EXT_texture_snorm = canFind(extensions, "GL_EXT_texture_snorm");
	GL_SGIX_texture_coordinate_clamp = canFind(extensions, "GL_SGIX_texture_coordinate_clamp");
	GL_ARB_clear_buffer_object = canFind(extensions, "GL_ARB_clear_buffer_object");
	GL_ARB_multisample = canFind(extensions, "GL_ARB_multisample");
	GL_ARB_sample_shading = canFind(extensions, "GL_ARB_sample_shading");
	GL_INTEL_map_texture = canFind(extensions, "GL_INTEL_map_texture");
	GL_ARB_texture_env_crossbar = canFind(extensions, "GL_ARB_texture_env_crossbar");
	GL_EXT_422_pixels = canFind(extensions, "GL_EXT_422_pixels");
	GL_ARB_compute_shader = canFind(extensions, "GL_ARB_compute_shader");
	GL_EXT_blend_logic_op = canFind(extensions, "GL_EXT_blend_logic_op");
	GL_IBM_cull_vertex = canFind(extensions, "GL_IBM_cull_vertex");
	GL_IBM_vertex_array_lists = canFind(extensions, "GL_IBM_vertex_array_lists");
	GL_ARB_color_buffer_float = canFind(extensions, "GL_ARB_color_buffer_float");
	GL_ARB_bindless_texture = canFind(extensions, "GL_ARB_bindless_texture");
	GL_ARB_window_pos = canFind(extensions, "GL_ARB_window_pos");
	GL_ARB_internalformat_query = canFind(extensions, "GL_ARB_internalformat_query");
	GL_ARB_shadow = canFind(extensions, "GL_ARB_shadow");
	GL_ARB_texture_mirrored_repeat = canFind(extensions, "GL_ARB_texture_mirrored_repeat");
	GL_EXT_shader_image_load_store = canFind(extensions, "GL_EXT_shader_image_load_store");
	GL_EXT_copy_texture = canFind(extensions, "GL_EXT_copy_texture");
	GL_NV_register_combiners2 = canFind(extensions, "GL_NV_register_combiners2");
	GL_SGIX_ir_instrument1 = canFind(extensions, "GL_SGIX_ir_instrument1");
	GL_NV_draw_texture = canFind(extensions, "GL_NV_draw_texture");
	GL_EXT_texture_shared_exponent = canFind(extensions, "GL_EXT_texture_shared_exponent");
	GL_EXT_draw_instanced = canFind(extensions, "GL_EXT_draw_instanced");
	GL_NV_copy_depth_to_color = canFind(extensions, "GL_NV_copy_depth_to_color");
	GL_ARB_viewport_array = canFind(extensions, "GL_ARB_viewport_array");
	GL_ARB_separate_shader_objects = canFind(extensions, "GL_ARB_separate_shader_objects");
	GL_EXT_depth_bounds_test = canFind(extensions, "GL_EXT_depth_bounds_test");
	GL_HP_image_transform = canFind(extensions, "GL_HP_image_transform");
	GL_ARB_texture_env_add = canFind(extensions, "GL_ARB_texture_env_add");
	GL_NV_video_capture = canFind(extensions, "GL_NV_video_capture");
	GL_ARB_sampler_objects = canFind(extensions, "GL_ARB_sampler_objects");
	GL_ARB_matrix_palette = canFind(extensions, "GL_ARB_matrix_palette");
	GL_SGIS_texture_color_mask = canFind(extensions, "GL_SGIS_texture_color_mask");
	GL_EXT_packed_pixels = canFind(extensions, "GL_EXT_packed_pixels");
	GL_ARB_texture_compression = canFind(extensions, "GL_ARB_texture_compression");
	GL_APPLE_aux_depth_stencil = canFind(extensions, "GL_APPLE_aux_depth_stencil");
	GL_ARB_shader_subroutine = canFind(extensions, "GL_ARB_shader_subroutine");
	GL_EXT_framebuffer_sRGB = canFind(extensions, "GL_EXT_framebuffer_sRGB");
	GL_ARB_texture_storage_multisample = canFind(extensions, "GL_ARB_texture_storage_multisample");
	GL_EXT_vertex_attrib_64bit = canFind(extensions, "GL_EXT_vertex_attrib_64bit");
	GL_ARB_depth_texture = canFind(extensions, "GL_ARB_depth_texture");
	GL_NV_shader_buffer_store = canFind(extensions, "GL_NV_shader_buffer_store");
	GL_OES_query_matrix = canFind(extensions, "GL_OES_query_matrix");
	GL_APPLE_texture_range = canFind(extensions, "GL_APPLE_texture_range");
	GL_NV_shader_storage_buffer_object = canFind(extensions, "GL_NV_shader_storage_buffer_object");
	GL_ARB_texture_query_lod = canFind(extensions, "GL_ARB_texture_query_lod");
	GL_ARB_copy_buffer = canFind(extensions, "GL_ARB_copy_buffer");
	GL_ARB_shader_image_size = canFind(extensions, "GL_ARB_shader_image_size");
	GL_NV_shader_atomic_counters = canFind(extensions, "GL_NV_shader_atomic_counters");
	GL_APPLE_object_purgeable = canFind(extensions, "GL_APPLE_object_purgeable");
	GL_ARB_occlusion_query = canFind(extensions, "GL_ARB_occlusion_query");
	GL_INGR_color_clamp = canFind(extensions, "GL_INGR_color_clamp");
	GL_SGI_color_table = canFind(extensions, "GL_SGI_color_table");
	GL_NV_gpu_program5_mem_extended = canFind(extensions, "GL_NV_gpu_program5_mem_extended");
	GL_ARB_texture_cube_map_array = canFind(extensions, "GL_ARB_texture_cube_map_array");
	GL_SGIX_scalebias_hint = canFind(extensions, "GL_SGIX_scalebias_hint");
	GL_EXT_gpu_shader4 = canFind(extensions, "GL_EXT_gpu_shader4");
	GL_NV_geometry_program4 = canFind(extensions, "GL_NV_geometry_program4");
	GL_EXT_framebuffer_multisample_blit_scaled = canFind(extensions, "GL_EXT_framebuffer_multisample_blit_scaled");
	GL_AMD_debug_output = canFind(extensions, "GL_AMD_debug_output");
	GL_ARB_texture_border_clamp = canFind(extensions, "GL_ARB_texture_border_clamp");
	GL_ARB_fragment_coord_conventions = canFind(extensions, "GL_ARB_fragment_coord_conventions");
	GL_ARB_multitexture = canFind(extensions, "GL_ARB_multitexture");
	GL_SGIX_polynomial_ffd = canFind(extensions, "GL_SGIX_polynomial_ffd");
	GL_EXT_provoking_vertex = canFind(extensions, "GL_EXT_provoking_vertex");
	GL_ARB_point_parameters = canFind(extensions, "GL_ARB_point_parameters");
	GL_ARB_shader_image_load_store = canFind(extensions, "GL_ARB_shader_image_load_store");
	GL_HP_occlusion_test = canFind(extensions, "GL_HP_occlusion_test");
	GL_ARB_ES3_compatibility = canFind(extensions, "GL_ARB_ES3_compatibility");
	GL_SGIX_framezoom = canFind(extensions, "GL_SGIX_framezoom");
	GL_ARB_texture_buffer_object_rgb32 = canFind(extensions, "GL_ARB_texture_buffer_object_rgb32");
	GL_NV_bindless_multi_draw_indirect = canFind(extensions, "GL_NV_bindless_multi_draw_indirect");
	GL_SGIX_texture_multi_buffer = canFind(extensions, "GL_SGIX_texture_multi_buffer");
	GL_EXT_transform_feedback = canFind(extensions, "GL_EXT_transform_feedback");
	GL_KHR_texture_compression_astc_ldr = canFind(extensions, "GL_KHR_texture_compression_astc_ldr");
	GL_3DFX_multisample = canFind(extensions, "GL_3DFX_multisample");
	GL_ARB_texture_env_dot3 = canFind(extensions, "GL_ARB_texture_env_dot3");
	GL_NV_gpu_program4 = canFind(extensions, "GL_NV_gpu_program4");
	GL_NV_gpu_program5 = canFind(extensions, "GL_NV_gpu_program5");
	GL_NV_float_buffer = canFind(extensions, "GL_NV_float_buffer");
	GL_SGIS_texture_edge_clamp = canFind(extensions, "GL_SGIS_texture_edge_clamp");
	GL_ARB_framebuffer_sRGB = canFind(extensions, "GL_ARB_framebuffer_sRGB");
	GL_SUN_slice_accum = canFind(extensions, "GL_SUN_slice_accum");
	GL_EXT_index_texture = canFind(extensions, "GL_EXT_index_texture");
	GL_ARB_geometry_shader4 = canFind(extensions, "GL_ARB_geometry_shader4");
	GL_EXT_separate_specular_color = canFind(extensions, "GL_EXT_separate_specular_color");
	GL_AMD_depth_clamp_separate = canFind(extensions, "GL_AMD_depth_clamp_separate");
	GL_SUN_convolution_border_modes = canFind(extensions, "GL_SUN_convolution_border_modes");
	GL_SGIX_sprite = canFind(extensions, "GL_SGIX_sprite");
	GL_ARB_get_program_binary = canFind(extensions, "GL_ARB_get_program_binary");
	GL_SGIS_multisample = canFind(extensions, "GL_SGIS_multisample");
	GL_EXT_framebuffer_object = canFind(extensions, "GL_EXT_framebuffer_object");
	GL_ARB_robustness_isolation = canFind(extensions, "GL_ARB_robustness_isolation");
	GL_ARB_vertex_array_bgra = canFind(extensions, "GL_ARB_vertex_array_bgra");
	GL_APPLE_vertex_array_range = canFind(extensions, "GL_APPLE_vertex_array_range");
	GL_AMD_query_buffer_object = canFind(extensions, "GL_AMD_query_buffer_object");
	GL_NV_register_combiners = canFind(extensions, "GL_NV_register_combiners");
	GL_ARB_draw_buffers = canFind(extensions, "GL_ARB_draw_buffers");
	GL_ARB_clear_texture = canFind(extensions, "GL_ARB_clear_texture");
	GL_ARB_debug_output = canFind(extensions, "GL_ARB_debug_output");
	GL_SGI_color_matrix = canFind(extensions, "GL_SGI_color_matrix");
	GL_EXT_cull_vertex = canFind(extensions, "GL_EXT_cull_vertex");
	GL_EXT_texture_sRGB = canFind(extensions, "GL_EXT_texture_sRGB");
	GL_APPLE_row_bytes = canFind(extensions, "GL_APPLE_row_bytes");
	GL_NV_texgen_reflection = canFind(extensions, "GL_NV_texgen_reflection");
	GL_IBM_multimode_draw_arrays = canFind(extensions, "GL_IBM_multimode_draw_arrays");
	GL_APPLE_vertex_array_object = canFind(extensions, "GL_APPLE_vertex_array_object");
	GL_3DFX_texture_compression_FXT1 = canFind(extensions, "GL_3DFX_texture_compression_FXT1");
	GL_SGIX_ycrcb = canFind(extensions, "GL_SGIX_ycrcb");
	GL_AMD_conservative_depth = canFind(extensions, "GL_AMD_conservative_depth");
	GL_ARB_texture_float = canFind(extensions, "GL_ARB_texture_float");
	GL_ARB_compressed_texture_pixel_storage = canFind(extensions, "GL_ARB_compressed_texture_pixel_storage");
	GL_SGIS_detail_texture = canFind(extensions, "GL_SGIS_detail_texture");
	GL_ARB_draw_instanced = canFind(extensions, "GL_ARB_draw_instanced");
	GL_OES_read_format = canFind(extensions, "GL_OES_read_format");
	GL_ATI_texture_float = canFind(extensions, "GL_ATI_texture_float");
	GL_ARB_texture_gather = canFind(extensions, "GL_ARB_texture_gather");
	GL_AMD_vertex_shader_layer = canFind(extensions, "GL_AMD_vertex_shader_layer");
	GL_ARB_shading_language_include = canFind(extensions, "GL_ARB_shading_language_include");
	GL_APPLE_client_storage = canFind(extensions, "GL_APPLE_client_storage");
	GL_WIN_phong_shading = canFind(extensions, "GL_WIN_phong_shading");
	GL_INGR_blend_func_separate = canFind(extensions, "GL_INGR_blend_func_separate");
	GL_NV_path_rendering = canFind(extensions, "GL_NV_path_rendering");
	GL_ATI_vertex_streams = canFind(extensions, "GL_ATI_vertex_streams");
	GL_ARB_texture_non_power_of_two = canFind(extensions, "GL_ARB_texture_non_power_of_two");
	GL_APPLE_rgb_422 = canFind(extensions, "GL_APPLE_rgb_422");
	GL_EXT_texture_lod_bias = canFind(extensions, "GL_EXT_texture_lod_bias");
	GL_ARB_seamless_cube_map = canFind(extensions, "GL_ARB_seamless_cube_map");
	GL_ARB_shader_group_vote = canFind(extensions, "GL_ARB_shader_group_vote");
	GL_NV_vdpau_interop = canFind(extensions, "GL_NV_vdpau_interop");
	GL_ARB_occlusion_query2 = canFind(extensions, "GL_ARB_occlusion_query2");
	GL_ARB_internalformat_query2 = canFind(extensions, "GL_ARB_internalformat_query2");
	GL_EXT_texture_filter_anisotropic = canFind(extensions, "GL_EXT_texture_filter_anisotropic");
	GL_SUN_vertex = canFind(extensions, "GL_SUN_vertex");
	GL_SGIX_igloo_interface = canFind(extensions, "GL_SGIX_igloo_interface");
	GL_SGIS_texture_lod = canFind(extensions, "GL_SGIS_texture_lod");
	GL_NV_vertex_program3 = canFind(extensions, "GL_NV_vertex_program3");
	GL_ARB_draw_indirect = canFind(extensions, "GL_ARB_draw_indirect");
	GL_NV_vertex_program4 = canFind(extensions, "GL_NV_vertex_program4");
	GL_AMD_transform_feedback3_lines_triangles = canFind(extensions, "GL_AMD_transform_feedback3_lines_triangles");
	GL_SGIS_fog_function = canFind(extensions, "GL_SGIS_fog_function");
	GL_EXT_x11_sync_object = canFind(extensions, "GL_EXT_x11_sync_object");
	GL_ARB_sync = canFind(extensions, "GL_ARB_sync");
	GL_ARB_compute_variable_group_size = canFind(extensions, "GL_ARB_compute_variable_group_size");
	GL_OES_fixed_point = canFind(extensions, "GL_OES_fixed_point");
	GL_EXT_framebuffer_multisample = canFind(extensions, "GL_EXT_framebuffer_multisample");
	GL_ARB_gpu_shader5 = canFind(extensions, "GL_ARB_gpu_shader5");
	GL_SGIS_texture4D = canFind(extensions, "GL_SGIS_texture4D");
	GL_EXT_texture3D = canFind(extensions, "GL_EXT_texture3D");
	GL_EXT_multisample = canFind(extensions, "GL_EXT_multisample");
	GL_EXT_secondary_color = canFind(extensions, "GL_EXT_secondary_color");
	GL_NV_parameter_buffer_object2 = canFind(extensions, "GL_NV_parameter_buffer_object2");
	GL_ATI_vertex_array_object = canFind(extensions, "GL_ATI_vertex_array_object");
	GL_ARB_sparse_texture = canFind(extensions, "GL_ARB_sparse_texture");
	GL_SGIS_point_line_texgen = canFind(extensions, "GL_SGIS_point_line_texgen");
	GL_EXT_draw_range_elements = canFind(extensions, "GL_EXT_draw_range_elements");
	GL_SGIX_blend_alpha_minmax = canFind(extensions, "GL_SGIX_blend_alpha_minmax");
}

bool load_gl_GL_SGIX_pixel_tiles(void* function(string name) load) {
	if(!GL_SGIX_pixel_tiles) return GL_SGIX_pixel_tiles;

	return GL_SGIX_pixel_tiles;
}


bool load_gl_GL_NV_point_sprite(void* function(string name) load) {
	if(!GL_NV_point_sprite) return GL_NV_point_sprite;

	glPointParameteriNV = cast(typeof(glPointParameteriNV))load("glPointParameteriNV");
	glPointParameterivNV = cast(typeof(glPointParameterivNV))load("glPointParameterivNV");
	return GL_NV_point_sprite;
}


bool load_gl_GL_APPLE_element_array(void* function(string name) load) {
	if(!GL_APPLE_element_array) return GL_APPLE_element_array;

	glElementPointerAPPLE = cast(typeof(glElementPointerAPPLE))load("glElementPointerAPPLE");
	glDrawElementArrayAPPLE = cast(typeof(glDrawElementArrayAPPLE))load("glDrawElementArrayAPPLE");
	glDrawRangeElementArrayAPPLE = cast(typeof(glDrawRangeElementArrayAPPLE))load("glDrawRangeElementArrayAPPLE");
	glMultiDrawElementArrayAPPLE = cast(typeof(glMultiDrawElementArrayAPPLE))load("glMultiDrawElementArrayAPPLE");
	glMultiDrawRangeElementArrayAPPLE = cast(typeof(glMultiDrawRangeElementArrayAPPLE))load("glMultiDrawRangeElementArrayAPPLE");
	return GL_APPLE_element_array;
}


bool load_gl_GL_AMD_multi_draw_indirect(void* function(string name) load) {
	if(!GL_AMD_multi_draw_indirect) return GL_AMD_multi_draw_indirect;

	glMultiDrawArraysIndirectAMD = cast(typeof(glMultiDrawArraysIndirectAMD))load("glMultiDrawArraysIndirectAMD");
	glMultiDrawElementsIndirectAMD = cast(typeof(glMultiDrawElementsIndirectAMD))load("glMultiDrawElementsIndirectAMD");
	return GL_AMD_multi_draw_indirect;
}


bool load_gl_GL_EXT_blend_subtract(void* function(string name) load) {
	if(!GL_EXT_blend_subtract) return GL_EXT_blend_subtract;

	return GL_EXT_blend_subtract;
}


bool load_gl_GL_SGIX_tag_sample_buffer(void* function(string name) load) {
	if(!GL_SGIX_tag_sample_buffer) return GL_SGIX_tag_sample_buffer;

	glTagSampleBufferSGIX = cast(typeof(glTagSampleBufferSGIX))load("glTagSampleBufferSGIX");
	return GL_SGIX_tag_sample_buffer;
}


bool load_gl_GL_IBM_texture_mirrored_repeat(void* function(string name) load) {
	if(!GL_IBM_texture_mirrored_repeat) return GL_IBM_texture_mirrored_repeat;

	return GL_IBM_texture_mirrored_repeat;
}


bool load_gl_GL_ARB_texture_view(void* function(string name) load) {
	if(!GL_ARB_texture_view) return GL_ARB_texture_view;

	glTextureView = cast(typeof(glTextureView))load("glTextureView");
	return GL_ARB_texture_view;
}


bool load_gl_GL_ATI_separate_stencil(void* function(string name) load) {
	if(!GL_ATI_separate_stencil) return GL_ATI_separate_stencil;

	glStencilOpSeparateATI = cast(typeof(glStencilOpSeparateATI))load("glStencilOpSeparateATI");
	glStencilFuncSeparateATI = cast(typeof(glStencilFuncSeparateATI))load("glStencilFuncSeparateATI");
	return GL_ATI_separate_stencil;
}


bool load_gl_GL_NV_vertex_program2_option(void* function(string name) load) {
	if(!GL_NV_vertex_program2_option) return GL_NV_vertex_program2_option;

	return GL_NV_vertex_program2_option;
}


bool load_gl_GL_EXT_texture_buffer_object(void* function(string name) load) {
	if(!GL_EXT_texture_buffer_object) return GL_EXT_texture_buffer_object;

	glTexBufferEXT = cast(typeof(glTexBufferEXT))load("glTexBufferEXT");
	return GL_EXT_texture_buffer_object;
}


bool load_gl_GL_ARB_vertex_blend(void* function(string name) load) {
	if(!GL_ARB_vertex_blend) return GL_ARB_vertex_blend;

	glWeightbvARB = cast(typeof(glWeightbvARB))load("glWeightbvARB");
	glWeightsvARB = cast(typeof(glWeightsvARB))load("glWeightsvARB");
	glWeightivARB = cast(typeof(glWeightivARB))load("glWeightivARB");
	glWeightfvARB = cast(typeof(glWeightfvARB))load("glWeightfvARB");
	glWeightdvARB = cast(typeof(glWeightdvARB))load("glWeightdvARB");
	glWeightubvARB = cast(typeof(glWeightubvARB))load("glWeightubvARB");
	glWeightusvARB = cast(typeof(glWeightusvARB))load("glWeightusvARB");
	glWeightuivARB = cast(typeof(glWeightuivARB))load("glWeightuivARB");
	glWeightPointerARB = cast(typeof(glWeightPointerARB))load("glWeightPointerARB");
	glVertexBlendARB = cast(typeof(glVertexBlendARB))load("glVertexBlendARB");
	return GL_ARB_vertex_blend;
}


bool load_gl_GL_ARB_program_interface_query(void* function(string name) load) {
	if(!GL_ARB_program_interface_query) return GL_ARB_program_interface_query;

	glGetProgramInterfaceiv = cast(typeof(glGetProgramInterfaceiv))load("glGetProgramInterfaceiv");
	glGetProgramResourceIndex = cast(typeof(glGetProgramResourceIndex))load("glGetProgramResourceIndex");
	glGetProgramResourceName = cast(typeof(glGetProgramResourceName))load("glGetProgramResourceName");
	glGetProgramResourceiv = cast(typeof(glGetProgramResourceiv))load("glGetProgramResourceiv");
	glGetProgramResourceLocation = cast(typeof(glGetProgramResourceLocation))load("glGetProgramResourceLocation");
	glGetProgramResourceLocationIndex = cast(typeof(glGetProgramResourceLocationIndex))load("glGetProgramResourceLocationIndex");
	return GL_ARB_program_interface_query;
}


bool load_gl_GL_EXT_misc_attribute(void* function(string name) load) {
	if(!GL_EXT_misc_attribute) return GL_EXT_misc_attribute;

	return GL_EXT_misc_attribute;
}


bool load_gl_GL_NV_multisample_coverage(void* function(string name) load) {
	if(!GL_NV_multisample_coverage) return GL_NV_multisample_coverage;

	return GL_NV_multisample_coverage;
}


bool load_gl_GL_ARB_shading_language_packing(void* function(string name) load) {
	if(!GL_ARB_shading_language_packing) return GL_ARB_shading_language_packing;

	return GL_ARB_shading_language_packing;
}


bool load_gl_GL_EXT_texture_cube_map(void* function(string name) load) {
	if(!GL_EXT_texture_cube_map) return GL_EXT_texture_cube_map;

	return GL_EXT_texture_cube_map;
}


bool load_gl_GL_ARB_texture_stencil8(void* function(string name) load) {
	if(!GL_ARB_texture_stencil8) return GL_ARB_texture_stencil8;

	return GL_ARB_texture_stencil8;
}


bool load_gl_GL_EXT_index_func(void* function(string name) load) {
	if(!GL_EXT_index_func) return GL_EXT_index_func;

	glIndexFuncEXT = cast(typeof(glIndexFuncEXT))load("glIndexFuncEXT");
	return GL_EXT_index_func;
}


bool load_gl_GL_OES_compressed_paletted_texture(void* function(string name) load) {
	if(!GL_OES_compressed_paletted_texture) return GL_OES_compressed_paletted_texture;

	return GL_OES_compressed_paletted_texture;
}


bool load_gl_GL_NV_depth_clamp(void* function(string name) load) {
	if(!GL_NV_depth_clamp) return GL_NV_depth_clamp;

	return GL_NV_depth_clamp;
}


bool load_gl_GL_NV_shader_buffer_load(void* function(string name) load) {
	if(!GL_NV_shader_buffer_load) return GL_NV_shader_buffer_load;

	glMakeBufferResidentNV = cast(typeof(glMakeBufferResidentNV))load("glMakeBufferResidentNV");
	glMakeBufferNonResidentNV = cast(typeof(glMakeBufferNonResidentNV))load("glMakeBufferNonResidentNV");
	glIsBufferResidentNV = cast(typeof(glIsBufferResidentNV))load("glIsBufferResidentNV");
	glMakeNamedBufferResidentNV = cast(typeof(glMakeNamedBufferResidentNV))load("glMakeNamedBufferResidentNV");
	glMakeNamedBufferNonResidentNV = cast(typeof(glMakeNamedBufferNonResidentNV))load("glMakeNamedBufferNonResidentNV");
	glIsNamedBufferResidentNV = cast(typeof(glIsNamedBufferResidentNV))load("glIsNamedBufferResidentNV");
	glGetBufferParameterui64vNV = cast(typeof(glGetBufferParameterui64vNV))load("glGetBufferParameterui64vNV");
	glGetNamedBufferParameterui64vNV = cast(typeof(glGetNamedBufferParameterui64vNV))load("glGetNamedBufferParameterui64vNV");
	glGetIntegerui64vNV = cast(typeof(glGetIntegerui64vNV))load("glGetIntegerui64vNV");
	glUniformui64NV = cast(typeof(glUniformui64NV))load("glUniformui64NV");
	glUniformui64vNV = cast(typeof(glUniformui64vNV))load("glUniformui64vNV");
	glGetUniformui64vNV = cast(typeof(glGetUniformui64vNV))load("glGetUniformui64vNV");
	glProgramUniformui64NV = cast(typeof(glProgramUniformui64NV))load("glProgramUniformui64NV");
	glProgramUniformui64vNV = cast(typeof(glProgramUniformui64vNV))load("glProgramUniformui64vNV");
	return GL_NV_shader_buffer_load;
}


bool load_gl_GL_EXT_color_subtable(void* function(string name) load) {
	if(!GL_EXT_color_subtable) return GL_EXT_color_subtable;

	glColorSubTableEXT = cast(typeof(glColorSubTableEXT))load("glColorSubTableEXT");
	glCopyColorSubTableEXT = cast(typeof(glCopyColorSubTableEXT))load("glCopyColorSubTableEXT");
	return GL_EXT_color_subtable;
}


bool load_gl_GL_SUNX_constant_data(void* function(string name) load) {
	if(!GL_SUNX_constant_data) return GL_SUNX_constant_data;

	glFinishTextureSUNX = cast(typeof(glFinishTextureSUNX))load("glFinishTextureSUNX");
	return GL_SUNX_constant_data;
}


bool load_gl_GL_EXT_texture_compression_s3tc(void* function(string name) load) {
	if(!GL_EXT_texture_compression_s3tc) return GL_EXT_texture_compression_s3tc;

	return GL_EXT_texture_compression_s3tc;
}


bool load_gl_GL_EXT_multi_draw_arrays(void* function(string name) load) {
	if(!GL_EXT_multi_draw_arrays) return GL_EXT_multi_draw_arrays;

	glMultiDrawArraysEXT = cast(typeof(glMultiDrawArraysEXT))load("glMultiDrawArraysEXT");
	glMultiDrawElementsEXT = cast(typeof(glMultiDrawElementsEXT))load("glMultiDrawElementsEXT");
	return GL_EXT_multi_draw_arrays;
}


bool load_gl_GL_ARB_shader_atomic_counters(void* function(string name) load) {
	if(!GL_ARB_shader_atomic_counters) return GL_ARB_shader_atomic_counters;

	glGetActiveAtomicCounterBufferiv = cast(typeof(glGetActiveAtomicCounterBufferiv))load("glGetActiveAtomicCounterBufferiv");
	return GL_ARB_shader_atomic_counters;
}


bool load_gl_GL_ARB_arrays_of_arrays(void* function(string name) load) {
	if(!GL_ARB_arrays_of_arrays) return GL_ARB_arrays_of_arrays;

	return GL_ARB_arrays_of_arrays;
}


bool load_gl_GL_NV_conditional_render(void* function(string name) load) {
	if(!GL_NV_conditional_render) return GL_NV_conditional_render;

	glBeginConditionalRenderNV = cast(typeof(glBeginConditionalRenderNV))load("glBeginConditionalRenderNV");
	glEndConditionalRenderNV = cast(typeof(glEndConditionalRenderNV))load("glEndConditionalRenderNV");
	return GL_NV_conditional_render;
}


bool load_gl_GL_EXT_texture_env_combine(void* function(string name) load) {
	if(!GL_EXT_texture_env_combine) return GL_EXT_texture_env_combine;

	return GL_EXT_texture_env_combine;
}


bool load_gl_GL_AMD_depth_clamp_separate(void* function(string name) load) {
	if(!GL_AMD_depth_clamp_separate) return GL_AMD_depth_clamp_separate;

	return GL_AMD_depth_clamp_separate;
}


bool load_gl_GL_SGIX_async_histogram(void* function(string name) load) {
	if(!GL_SGIX_async_histogram) return GL_SGIX_async_histogram;

	return GL_SGIX_async_histogram;
}


bool load_gl_GL_MESA_resize_buffers(void* function(string name) load) {
	if(!GL_MESA_resize_buffers) return GL_MESA_resize_buffers;

	glResizeBuffersMESA = cast(typeof(glResizeBuffersMESA))load("glResizeBuffersMESA");
	return GL_MESA_resize_buffers;
}


bool load_gl_GL_NV_light_max_exponent(void* function(string name) load) {
	if(!GL_NV_light_max_exponent) return GL_NV_light_max_exponent;

	return GL_NV_light_max_exponent;
}


bool load_gl_GL_NV_texture_env_combine4(void* function(string name) load) {
	if(!GL_NV_texture_env_combine4) return GL_NV_texture_env_combine4;

	return GL_NV_texture_env_combine4;
}


bool load_gl_GL_APPLE_transform_hint(void* function(string name) load) {
	if(!GL_APPLE_transform_hint) return GL_APPLE_transform_hint;

	return GL_APPLE_transform_hint;
}


bool load_gl_GL_ARB_texture_env_combine(void* function(string name) load) {
	if(!GL_ARB_texture_env_combine) return GL_ARB_texture_env_combine;

	return GL_ARB_texture_env_combine;
}


bool load_gl_GL_ARB_map_buffer_range(void* function(string name) load) {
	if(!GL_ARB_map_buffer_range) return GL_ARB_map_buffer_range;

	glMapBufferRange = cast(typeof(glMapBufferRange))load("glMapBufferRange");
	glFlushMappedBufferRange = cast(typeof(glFlushMappedBufferRange))load("glFlushMappedBufferRange");
	return GL_ARB_map_buffer_range;
}


bool load_gl_GL_EXT_convolution(void* function(string name) load) {
	if(!GL_EXT_convolution) return GL_EXT_convolution;

	glConvolutionFilter1DEXT = cast(typeof(glConvolutionFilter1DEXT))load("glConvolutionFilter1DEXT");
	glConvolutionFilter2DEXT = cast(typeof(glConvolutionFilter2DEXT))load("glConvolutionFilter2DEXT");
	glConvolutionParameterfEXT = cast(typeof(glConvolutionParameterfEXT))load("glConvolutionParameterfEXT");
	glConvolutionParameterfvEXT = cast(typeof(glConvolutionParameterfvEXT))load("glConvolutionParameterfvEXT");
	glConvolutionParameteriEXT = cast(typeof(glConvolutionParameteriEXT))load("glConvolutionParameteriEXT");
	glConvolutionParameterivEXT = cast(typeof(glConvolutionParameterivEXT))load("glConvolutionParameterivEXT");
	glCopyConvolutionFilter1DEXT = cast(typeof(glCopyConvolutionFilter1DEXT))load("glCopyConvolutionFilter1DEXT");
	glCopyConvolutionFilter2DEXT = cast(typeof(glCopyConvolutionFilter2DEXT))load("glCopyConvolutionFilter2DEXT");
	glGetConvolutionFilterEXT = cast(typeof(glGetConvolutionFilterEXT))load("glGetConvolutionFilterEXT");
	glGetConvolutionParameterfvEXT = cast(typeof(glGetConvolutionParameterfvEXT))load("glGetConvolutionParameterfvEXT");
	glGetConvolutionParameterivEXT = cast(typeof(glGetConvolutionParameterivEXT))load("glGetConvolutionParameterivEXT");
	glGetSeparableFilterEXT = cast(typeof(glGetSeparableFilterEXT))load("glGetSeparableFilterEXT");
	glSeparableFilter2DEXT = cast(typeof(glSeparableFilter2DEXT))load("glSeparableFilter2DEXT");
	return GL_EXT_convolution;
}


bool load_gl_GL_NV_compute_program5(void* function(string name) load) {
	if(!GL_NV_compute_program5) return GL_NV_compute_program5;

	return GL_NV_compute_program5;
}


bool load_gl_GL_EXT_paletted_texture(void* function(string name) load) {
	if(!GL_EXT_paletted_texture) return GL_EXT_paletted_texture;

	glColorTableEXT = cast(typeof(glColorTableEXT))load("glColorTableEXT");
	glGetColorTableEXT = cast(typeof(glGetColorTableEXT))load("glGetColorTableEXT");
	glGetColorTableParameterivEXT = cast(typeof(glGetColorTableParameterivEXT))load("glGetColorTableParameterivEXT");
	glGetColorTableParameterfvEXT = cast(typeof(glGetColorTableParameterfvEXT))load("glGetColorTableParameterfvEXT");
	return GL_EXT_paletted_texture;
}


bool load_gl_GL_ARB_texture_buffer_object(void* function(string name) load) {
	if(!GL_ARB_texture_buffer_object) return GL_ARB_texture_buffer_object;

	glTexBufferARB = cast(typeof(glTexBufferARB))load("glTexBufferARB");
	return GL_ARB_texture_buffer_object;
}


bool load_gl_GL_SUN_triangle_list(void* function(string name) load) {
	if(!GL_SUN_triangle_list) return GL_SUN_triangle_list;

	glReplacementCodeuiSUN = cast(typeof(glReplacementCodeuiSUN))load("glReplacementCodeuiSUN");
	glReplacementCodeusSUN = cast(typeof(glReplacementCodeusSUN))load("glReplacementCodeusSUN");
	glReplacementCodeubSUN = cast(typeof(glReplacementCodeubSUN))load("glReplacementCodeubSUN");
	glReplacementCodeuivSUN = cast(typeof(glReplacementCodeuivSUN))load("glReplacementCodeuivSUN");
	glReplacementCodeusvSUN = cast(typeof(glReplacementCodeusvSUN))load("glReplacementCodeusvSUN");
	glReplacementCodeubvSUN = cast(typeof(glReplacementCodeubvSUN))load("glReplacementCodeubvSUN");
	glReplacementCodePointerSUN = cast(typeof(glReplacementCodePointerSUN))load("glReplacementCodePointerSUN");
	return GL_SUN_triangle_list;
}


bool load_gl_GL_SGIX_resample(void* function(string name) load) {
	if(!GL_SGIX_resample) return GL_SGIX_resample;

	return GL_SGIX_resample;
}


bool load_gl_GL_SGIX_flush_raster(void* function(string name) load) {
	if(!GL_SGIX_flush_raster) return GL_SGIX_flush_raster;

	glFlushRasterSGIX = cast(typeof(glFlushRasterSGIX))load("glFlushRasterSGIX");
	return GL_SGIX_flush_raster;
}


bool load_gl_GL_EXT_light_texture(void* function(string name) load) {
	if(!GL_EXT_light_texture) return GL_EXT_light_texture;

	glApplyTextureEXT = cast(typeof(glApplyTextureEXT))load("glApplyTextureEXT");
	glTextureLightEXT = cast(typeof(glTextureLightEXT))load("glTextureLightEXT");
	glTextureMaterialEXT = cast(typeof(glTextureMaterialEXT))load("glTextureMaterialEXT");
	return GL_EXT_light_texture;
}


bool load_gl_GL_ARB_point_sprite(void* function(string name) load) {
	if(!GL_ARB_point_sprite) return GL_ARB_point_sprite;

	return GL_ARB_point_sprite;
}


bool load_gl_GL_ARB_half_float_pixel(void* function(string name) load) {
	if(!GL_ARB_half_float_pixel) return GL_ARB_half_float_pixel;

	return GL_ARB_half_float_pixel;
}


bool load_gl_GL_NV_tessellation_program5(void* function(string name) load) {
	if(!GL_NV_tessellation_program5) return GL_NV_tessellation_program5;

	return GL_NV_tessellation_program5;
}


bool load_gl_GL_REND_screen_coordinates(void* function(string name) load) {
	if(!GL_REND_screen_coordinates) return GL_REND_screen_coordinates;

	return GL_REND_screen_coordinates;
}


bool load_gl_GL_EXT_shared_texture_palette(void* function(string name) load) {
	if(!GL_EXT_shared_texture_palette) return GL_EXT_shared_texture_palette;

	return GL_EXT_shared_texture_palette;
}


bool load_gl_GL_EXT_packed_float(void* function(string name) load) {
	if(!GL_EXT_packed_float) return GL_EXT_packed_float;

	return GL_EXT_packed_float;
}


bool load_gl_GL_ATI_vertex_attrib_array_object(void* function(string name) load) {
	if(!GL_ATI_vertex_attrib_array_object) return GL_ATI_vertex_attrib_array_object;

	glVertexAttribArrayObjectATI = cast(typeof(glVertexAttribArrayObjectATI))load("glVertexAttribArrayObjectATI");
	glGetVertexAttribArrayObjectfvATI = cast(typeof(glGetVertexAttribArrayObjectfvATI))load("glGetVertexAttribArrayObjectfvATI");
	glGetVertexAttribArrayObjectivATI = cast(typeof(glGetVertexAttribArrayObjectivATI))load("glGetVertexAttribArrayObjectivATI");
	return GL_ATI_vertex_attrib_array_object;
}


bool load_gl_GL_SGIX_vertex_preclip(void* function(string name) load) {
	if(!GL_SGIX_vertex_preclip) return GL_SGIX_vertex_preclip;

	return GL_SGIX_vertex_preclip;
}


bool load_gl_GL_SGIX_texture_scale_bias(void* function(string name) load) {
	if(!GL_SGIX_texture_scale_bias) return GL_SGIX_texture_scale_bias;

	return GL_SGIX_texture_scale_bias;
}


bool load_gl_GL_AMD_draw_buffers_blend(void* function(string name) load) {
	if(!GL_AMD_draw_buffers_blend) return GL_AMD_draw_buffers_blend;

	glBlendFuncIndexedAMD = cast(typeof(glBlendFuncIndexedAMD))load("glBlendFuncIndexedAMD");
	glBlendFuncSeparateIndexedAMD = cast(typeof(glBlendFuncSeparateIndexedAMD))load("glBlendFuncSeparateIndexedAMD");
	glBlendEquationIndexedAMD = cast(typeof(glBlendEquationIndexedAMD))load("glBlendEquationIndexedAMD");
	glBlendEquationSeparateIndexedAMD = cast(typeof(glBlendEquationSeparateIndexedAMD))load("glBlendEquationSeparateIndexedAMD");
	return GL_AMD_draw_buffers_blend;
}


bool load_gl_GL_MESA_window_pos(void* function(string name) load) {
	if(!GL_MESA_window_pos) return GL_MESA_window_pos;

	glWindowPos2dMESA = cast(typeof(glWindowPos2dMESA))load("glWindowPos2dMESA");
	glWindowPos2dvMESA = cast(typeof(glWindowPos2dvMESA))load("glWindowPos2dvMESA");
	glWindowPos2fMESA = cast(typeof(glWindowPos2fMESA))load("glWindowPos2fMESA");
	glWindowPos2fvMESA = cast(typeof(glWindowPos2fvMESA))load("glWindowPos2fvMESA");
	glWindowPos2iMESA = cast(typeof(glWindowPos2iMESA))load("glWindowPos2iMESA");
	glWindowPos2ivMESA = cast(typeof(glWindowPos2ivMESA))load("glWindowPos2ivMESA");
	glWindowPos2sMESA = cast(typeof(glWindowPos2sMESA))load("glWindowPos2sMESA");
	glWindowPos2svMESA = cast(typeof(glWindowPos2svMESA))load("glWindowPos2svMESA");
	glWindowPos3dMESA = cast(typeof(glWindowPos3dMESA))load("glWindowPos3dMESA");
	glWindowPos3dvMESA = cast(typeof(glWindowPos3dvMESA))load("glWindowPos3dvMESA");
	glWindowPos3fMESA = cast(typeof(glWindowPos3fMESA))load("glWindowPos3fMESA");
	glWindowPos3fvMESA = cast(typeof(glWindowPos3fvMESA))load("glWindowPos3fvMESA");
	glWindowPos3iMESA = cast(typeof(glWindowPos3iMESA))load("glWindowPos3iMESA");
	glWindowPos3ivMESA = cast(typeof(glWindowPos3ivMESA))load("glWindowPos3ivMESA");
	glWindowPos3sMESA = cast(typeof(glWindowPos3sMESA))load("glWindowPos3sMESA");
	glWindowPos3svMESA = cast(typeof(glWindowPos3svMESA))load("glWindowPos3svMESA");
	glWindowPos4dMESA = cast(typeof(glWindowPos4dMESA))load("glWindowPos4dMESA");
	glWindowPos4dvMESA = cast(typeof(glWindowPos4dvMESA))load("glWindowPos4dvMESA");
	glWindowPos4fMESA = cast(typeof(glWindowPos4fMESA))load("glWindowPos4fMESA");
	glWindowPos4fvMESA = cast(typeof(glWindowPos4fvMESA))load("glWindowPos4fvMESA");
	glWindowPos4iMESA = cast(typeof(glWindowPos4iMESA))load("glWindowPos4iMESA");
	glWindowPos4ivMESA = cast(typeof(glWindowPos4ivMESA))load("glWindowPos4ivMESA");
	glWindowPos4sMESA = cast(typeof(glWindowPos4sMESA))load("glWindowPos4sMESA");
	glWindowPos4svMESA = cast(typeof(glWindowPos4svMESA))load("glWindowPos4svMESA");
	return GL_MESA_window_pos;
}


bool load_gl_GL_EXT_texture_array(void* function(string name) load) {
	if(!GL_EXT_texture_array) return GL_EXT_texture_array;

	return GL_EXT_texture_array;
}


bool load_gl_GL_NV_texture_barrier(void* function(string name) load) {
	if(!GL_NV_texture_barrier) return GL_NV_texture_barrier;

	glTextureBarrierNV = cast(typeof(glTextureBarrierNV))load("glTextureBarrierNV");
	return GL_NV_texture_barrier;
}


bool load_gl_GL_ARB_texture_query_levels(void* function(string name) load) {
	if(!GL_ARB_texture_query_levels) return GL_ARB_texture_query_levels;

	return GL_ARB_texture_query_levels;
}


bool load_gl_GL_NV_texgen_emboss(void* function(string name) load) {
	if(!GL_NV_texgen_emboss) return GL_NV_texgen_emboss;

	return GL_NV_texgen_emboss;
}


bool load_gl_GL_EXT_texture_swizzle(void* function(string name) load) {
	if(!GL_EXT_texture_swizzle) return GL_EXT_texture_swizzle;

	return GL_EXT_texture_swizzle;
}


bool load_gl_GL_ARB_texture_rg(void* function(string name) load) {
	if(!GL_ARB_texture_rg) return GL_ARB_texture_rg;

	return GL_ARB_texture_rg;
}


bool load_gl_GL_ARB_vertex_type_2_10_10_10_rev(void* function(string name) load) {
	if(!GL_ARB_vertex_type_2_10_10_10_rev) return GL_ARB_vertex_type_2_10_10_10_rev;

	glVertexAttribP1ui = cast(typeof(glVertexAttribP1ui))load("glVertexAttribP1ui");
	glVertexAttribP1uiv = cast(typeof(glVertexAttribP1uiv))load("glVertexAttribP1uiv");
	glVertexAttribP2ui = cast(typeof(glVertexAttribP2ui))load("glVertexAttribP2ui");
	glVertexAttribP2uiv = cast(typeof(glVertexAttribP2uiv))load("glVertexAttribP2uiv");
	glVertexAttribP3ui = cast(typeof(glVertexAttribP3ui))load("glVertexAttribP3ui");
	glVertexAttribP3uiv = cast(typeof(glVertexAttribP3uiv))load("glVertexAttribP3uiv");
	glVertexAttribP4ui = cast(typeof(glVertexAttribP4ui))load("glVertexAttribP4ui");
	glVertexAttribP4uiv = cast(typeof(glVertexAttribP4uiv))load("glVertexAttribP4uiv");
	glVertexP2ui = cast(typeof(glVertexP2ui))load("glVertexP2ui");
	glVertexP2uiv = cast(typeof(glVertexP2uiv))load("glVertexP2uiv");
	glVertexP3ui = cast(typeof(glVertexP3ui))load("glVertexP3ui");
	glVertexP3uiv = cast(typeof(glVertexP3uiv))load("glVertexP3uiv");
	glVertexP4ui = cast(typeof(glVertexP4ui))load("glVertexP4ui");
	glVertexP4uiv = cast(typeof(glVertexP4uiv))load("glVertexP4uiv");
	glTexCoordP1ui = cast(typeof(glTexCoordP1ui))load("glTexCoordP1ui");
	glTexCoordP1uiv = cast(typeof(glTexCoordP1uiv))load("glTexCoordP1uiv");
	glTexCoordP2ui = cast(typeof(glTexCoordP2ui))load("glTexCoordP2ui");
	glTexCoordP2uiv = cast(typeof(glTexCoordP2uiv))load("glTexCoordP2uiv");
	glTexCoordP3ui = cast(typeof(glTexCoordP3ui))load("glTexCoordP3ui");
	glTexCoordP3uiv = cast(typeof(glTexCoordP3uiv))load("glTexCoordP3uiv");
	glTexCoordP4ui = cast(typeof(glTexCoordP4ui))load("glTexCoordP4ui");
	glTexCoordP4uiv = cast(typeof(glTexCoordP4uiv))load("glTexCoordP4uiv");
	glMultiTexCoordP1ui = cast(typeof(glMultiTexCoordP1ui))load("glMultiTexCoordP1ui");
	glMultiTexCoordP1uiv = cast(typeof(glMultiTexCoordP1uiv))load("glMultiTexCoordP1uiv");
	glMultiTexCoordP2ui = cast(typeof(glMultiTexCoordP2ui))load("glMultiTexCoordP2ui");
	glMultiTexCoordP2uiv = cast(typeof(glMultiTexCoordP2uiv))load("glMultiTexCoordP2uiv");
	glMultiTexCoordP3ui = cast(typeof(glMultiTexCoordP3ui))load("glMultiTexCoordP3ui");
	glMultiTexCoordP3uiv = cast(typeof(glMultiTexCoordP3uiv))load("glMultiTexCoordP3uiv");
	glMultiTexCoordP4ui = cast(typeof(glMultiTexCoordP4ui))load("glMultiTexCoordP4ui");
	glMultiTexCoordP4uiv = cast(typeof(glMultiTexCoordP4uiv))load("glMultiTexCoordP4uiv");
	glNormalP3ui = cast(typeof(glNormalP3ui))load("glNormalP3ui");
	glNormalP3uiv = cast(typeof(glNormalP3uiv))load("glNormalP3uiv");
	glColorP3ui = cast(typeof(glColorP3ui))load("glColorP3ui");
	glColorP3uiv = cast(typeof(glColorP3uiv))load("glColorP3uiv");
	glColorP4ui = cast(typeof(glColorP4ui))load("glColorP4ui");
	glColorP4uiv = cast(typeof(glColorP4uiv))load("glColorP4uiv");
	glSecondaryColorP3ui = cast(typeof(glSecondaryColorP3ui))load("glSecondaryColorP3ui");
	glSecondaryColorP3uiv = cast(typeof(glSecondaryColorP3uiv))load("glSecondaryColorP3uiv");
	return GL_ARB_vertex_type_2_10_10_10_rev;
}


bool load_gl_GL_ARB_fragment_shader(void* function(string name) load) {
	if(!GL_ARB_fragment_shader) return GL_ARB_fragment_shader;

	return GL_ARB_fragment_shader;
}


bool load_gl_GL_3DFX_tbuffer(void* function(string name) load) {
	if(!GL_3DFX_tbuffer) return GL_3DFX_tbuffer;

	glTbufferMask3DFX = cast(typeof(glTbufferMask3DFX))load("glTbufferMask3DFX");
	return GL_3DFX_tbuffer;
}


bool load_gl_GL_GREMEDY_frame_terminator(void* function(string name) load) {
	if(!GL_GREMEDY_frame_terminator) return GL_GREMEDY_frame_terminator;

	glFrameTerminatorGREMEDY = cast(typeof(glFrameTerminatorGREMEDY))load("glFrameTerminatorGREMEDY");
	return GL_GREMEDY_frame_terminator;
}


bool load_gl_GL_ARB_blend_func_extended(void* function(string name) load) {
	if(!GL_ARB_blend_func_extended) return GL_ARB_blend_func_extended;

	glBindFragDataLocationIndexed = cast(typeof(glBindFragDataLocationIndexed))load("glBindFragDataLocationIndexed");
	glGetFragDataIndex = cast(typeof(glGetFragDataIndex))load("glGetFragDataIndex");
	return GL_ARB_blend_func_extended;
}


bool load_gl_GL_EXT_separate_shader_objects(void* function(string name) load) {
	if(!GL_EXT_separate_shader_objects) return GL_EXT_separate_shader_objects;

	glUseShaderProgramEXT = cast(typeof(glUseShaderProgramEXT))load("glUseShaderProgramEXT");
	glActiveProgramEXT = cast(typeof(glActiveProgramEXT))load("glActiveProgramEXT");
	glCreateShaderProgramEXT = cast(typeof(glCreateShaderProgramEXT))load("glCreateShaderProgramEXT");
	glActiveShaderProgramEXT = cast(typeof(glActiveShaderProgramEXT))load("glActiveShaderProgramEXT");
	glBindProgramPipelineEXT = cast(typeof(glBindProgramPipelineEXT))load("glBindProgramPipelineEXT");
	glCreateShaderProgramvEXT = cast(typeof(glCreateShaderProgramvEXT))load("glCreateShaderProgramvEXT");
	glDeleteProgramPipelinesEXT = cast(typeof(glDeleteProgramPipelinesEXT))load("glDeleteProgramPipelinesEXT");
	glGenProgramPipelinesEXT = cast(typeof(glGenProgramPipelinesEXT))load("glGenProgramPipelinesEXT");
	glGetProgramPipelineInfoLogEXT = cast(typeof(glGetProgramPipelineInfoLogEXT))load("glGetProgramPipelineInfoLogEXT");
	glGetProgramPipelineivEXT = cast(typeof(glGetProgramPipelineivEXT))load("glGetProgramPipelineivEXT");
	glIsProgramPipelineEXT = cast(typeof(glIsProgramPipelineEXT))load("glIsProgramPipelineEXT");
	glProgramParameteriEXT = cast(typeof(glProgramParameteriEXT))load("glProgramParameteriEXT");
	glProgramUniform1fEXT = cast(typeof(glProgramUniform1fEXT))load("glProgramUniform1fEXT");
	glProgramUniform1fvEXT = cast(typeof(glProgramUniform1fvEXT))load("glProgramUniform1fvEXT");
	glProgramUniform1iEXT = cast(typeof(glProgramUniform1iEXT))load("glProgramUniform1iEXT");
	glProgramUniform1ivEXT = cast(typeof(glProgramUniform1ivEXT))load("glProgramUniform1ivEXT");
	glProgramUniform2fEXT = cast(typeof(glProgramUniform2fEXT))load("glProgramUniform2fEXT");
	glProgramUniform2fvEXT = cast(typeof(glProgramUniform2fvEXT))load("glProgramUniform2fvEXT");
	glProgramUniform2iEXT = cast(typeof(glProgramUniform2iEXT))load("glProgramUniform2iEXT");
	glProgramUniform2ivEXT = cast(typeof(glProgramUniform2ivEXT))load("glProgramUniform2ivEXT");
	glProgramUniform3fEXT = cast(typeof(glProgramUniform3fEXT))load("glProgramUniform3fEXT");
	glProgramUniform3fvEXT = cast(typeof(glProgramUniform3fvEXT))load("glProgramUniform3fvEXT");
	glProgramUniform3iEXT = cast(typeof(glProgramUniform3iEXT))load("glProgramUniform3iEXT");
	glProgramUniform3ivEXT = cast(typeof(glProgramUniform3ivEXT))load("glProgramUniform3ivEXT");
	glProgramUniform4fEXT = cast(typeof(glProgramUniform4fEXT))load("glProgramUniform4fEXT");
	glProgramUniform4fvEXT = cast(typeof(glProgramUniform4fvEXT))load("glProgramUniform4fvEXT");
	glProgramUniform4iEXT = cast(typeof(glProgramUniform4iEXT))load("glProgramUniform4iEXT");
	glProgramUniform4ivEXT = cast(typeof(glProgramUniform4ivEXT))load("glProgramUniform4ivEXT");
	glProgramUniformMatrix2fvEXT = cast(typeof(glProgramUniformMatrix2fvEXT))load("glProgramUniformMatrix2fvEXT");
	glProgramUniformMatrix3fvEXT = cast(typeof(glProgramUniformMatrix3fvEXT))load("glProgramUniformMatrix3fvEXT");
	glProgramUniformMatrix4fvEXT = cast(typeof(glProgramUniformMatrix4fvEXT))load("glProgramUniformMatrix4fvEXT");
	glUseProgramStagesEXT = cast(typeof(glUseProgramStagesEXT))load("glUseProgramStagesEXT");
	glValidateProgramPipelineEXT = cast(typeof(glValidateProgramPipelineEXT))load("glValidateProgramPipelineEXT");
	return GL_EXT_separate_shader_objects;
}


bool load_gl_GL_NV_texture_multisample(void* function(string name) load) {
	if(!GL_NV_texture_multisample) return GL_NV_texture_multisample;

	glTexImage2DMultisampleCoverageNV = cast(typeof(glTexImage2DMultisampleCoverageNV))load("glTexImage2DMultisampleCoverageNV");
	glTexImage3DMultisampleCoverageNV = cast(typeof(glTexImage3DMultisampleCoverageNV))load("glTexImage3DMultisampleCoverageNV");
	glTextureImage2DMultisampleNV = cast(typeof(glTextureImage2DMultisampleNV))load("glTextureImage2DMultisampleNV");
	glTextureImage3DMultisampleNV = cast(typeof(glTextureImage3DMultisampleNV))load("glTextureImage3DMultisampleNV");
	glTextureImage2DMultisampleCoverageNV = cast(typeof(glTextureImage2DMultisampleCoverageNV))load("glTextureImage2DMultisampleCoverageNV");
	glTextureImage3DMultisampleCoverageNV = cast(typeof(glTextureImage3DMultisampleCoverageNV))load("glTextureImage3DMultisampleCoverageNV");
	return GL_NV_texture_multisample;
}


bool load_gl_GL_ARB_shader_objects(void* function(string name) load) {
	if(!GL_ARB_shader_objects) return GL_ARB_shader_objects;

	glDeleteObjectARB = cast(typeof(glDeleteObjectARB))load("glDeleteObjectARB");
	glGetHandleARB = cast(typeof(glGetHandleARB))load("glGetHandleARB");
	glDetachObjectARB = cast(typeof(glDetachObjectARB))load("glDetachObjectARB");
	glCreateShaderObjectARB = cast(typeof(glCreateShaderObjectARB))load("glCreateShaderObjectARB");
	glShaderSourceARB = cast(typeof(glShaderSourceARB))load("glShaderSourceARB");
	glCompileShaderARB = cast(typeof(glCompileShaderARB))load("glCompileShaderARB");
	glCreateProgramObjectARB = cast(typeof(glCreateProgramObjectARB))load("glCreateProgramObjectARB");
	glAttachObjectARB = cast(typeof(glAttachObjectARB))load("glAttachObjectARB");
	glLinkProgramARB = cast(typeof(glLinkProgramARB))load("glLinkProgramARB");
	glUseProgramObjectARB = cast(typeof(glUseProgramObjectARB))load("glUseProgramObjectARB");
	glValidateProgramARB = cast(typeof(glValidateProgramARB))load("glValidateProgramARB");
	glUniform1fARB = cast(typeof(glUniform1fARB))load("glUniform1fARB");
	glUniform2fARB = cast(typeof(glUniform2fARB))load("glUniform2fARB");
	glUniform3fARB = cast(typeof(glUniform3fARB))load("glUniform3fARB");
	glUniform4fARB = cast(typeof(glUniform4fARB))load("glUniform4fARB");
	glUniform1iARB = cast(typeof(glUniform1iARB))load("glUniform1iARB");
	glUniform2iARB = cast(typeof(glUniform2iARB))load("glUniform2iARB");
	glUniform3iARB = cast(typeof(glUniform3iARB))load("glUniform3iARB");
	glUniform4iARB = cast(typeof(glUniform4iARB))load("glUniform4iARB");
	glUniform1fvARB = cast(typeof(glUniform1fvARB))load("glUniform1fvARB");
	glUniform2fvARB = cast(typeof(glUniform2fvARB))load("glUniform2fvARB");
	glUniform3fvARB = cast(typeof(glUniform3fvARB))load("glUniform3fvARB");
	glUniform4fvARB = cast(typeof(glUniform4fvARB))load("glUniform4fvARB");
	glUniform1ivARB = cast(typeof(glUniform1ivARB))load("glUniform1ivARB");
	glUniform2ivARB = cast(typeof(glUniform2ivARB))load("glUniform2ivARB");
	glUniform3ivARB = cast(typeof(glUniform3ivARB))load("glUniform3ivARB");
	glUniform4ivARB = cast(typeof(glUniform4ivARB))load("glUniform4ivARB");
	glUniformMatrix2fvARB = cast(typeof(glUniformMatrix2fvARB))load("glUniformMatrix2fvARB");
	glUniformMatrix3fvARB = cast(typeof(glUniformMatrix3fvARB))load("glUniformMatrix3fvARB");
	glUniformMatrix4fvARB = cast(typeof(glUniformMatrix4fvARB))load("glUniformMatrix4fvARB");
	glGetObjectParameterfvARB = cast(typeof(glGetObjectParameterfvARB))load("glGetObjectParameterfvARB");
	glGetObjectParameterivARB = cast(typeof(glGetObjectParameterivARB))load("glGetObjectParameterivARB");
	glGetInfoLogARB = cast(typeof(glGetInfoLogARB))load("glGetInfoLogARB");
	glGetAttachedObjectsARB = cast(typeof(glGetAttachedObjectsARB))load("glGetAttachedObjectsARB");
	glGetUniformLocationARB = cast(typeof(glGetUniformLocationARB))load("glGetUniformLocationARB");
	glGetActiveUniformARB = cast(typeof(glGetActiveUniformARB))load("glGetActiveUniformARB");
	glGetUniformfvARB = cast(typeof(glGetUniformfvARB))load("glGetUniformfvARB");
	glGetUniformivARB = cast(typeof(glGetUniformivARB))load("glGetUniformivARB");
	glGetShaderSourceARB = cast(typeof(glGetShaderSourceARB))load("glGetShaderSourceARB");
	return GL_ARB_shader_objects;
}


bool load_gl_GL_ARB_framebuffer_object(void* function(string name) load) {
	if(!GL_ARB_framebuffer_object) return GL_ARB_framebuffer_object;

	glIsRenderbuffer = cast(typeof(glIsRenderbuffer))load("glIsRenderbuffer");
	glBindRenderbuffer = cast(typeof(glBindRenderbuffer))load("glBindRenderbuffer");
	glDeleteRenderbuffers = cast(typeof(glDeleteRenderbuffers))load("glDeleteRenderbuffers");
	glGenRenderbuffers = cast(typeof(glGenRenderbuffers))load("glGenRenderbuffers");
	glRenderbufferStorage = cast(typeof(glRenderbufferStorage))load("glRenderbufferStorage");
	glGetRenderbufferParameteriv = cast(typeof(glGetRenderbufferParameteriv))load("glGetRenderbufferParameteriv");
	glIsFramebuffer = cast(typeof(glIsFramebuffer))load("glIsFramebuffer");
	glBindFramebuffer = cast(typeof(glBindFramebuffer))load("glBindFramebuffer");
	glDeleteFramebuffers = cast(typeof(glDeleteFramebuffers))load("glDeleteFramebuffers");
	glGenFramebuffers = cast(typeof(glGenFramebuffers))load("glGenFramebuffers");
	glCheckFramebufferStatus = cast(typeof(glCheckFramebufferStatus))load("glCheckFramebufferStatus");
	glFramebufferTexture1D = cast(typeof(glFramebufferTexture1D))load("glFramebufferTexture1D");
	glFramebufferTexture2D = cast(typeof(glFramebufferTexture2D))load("glFramebufferTexture2D");
	glFramebufferTexture3D = cast(typeof(glFramebufferTexture3D))load("glFramebufferTexture3D");
	glFramebufferRenderbuffer = cast(typeof(glFramebufferRenderbuffer))load("glFramebufferRenderbuffer");
	glGetFramebufferAttachmentParameteriv = cast(typeof(glGetFramebufferAttachmentParameteriv))load("glGetFramebufferAttachmentParameteriv");
	glGenerateMipmap = cast(typeof(glGenerateMipmap))load("glGenerateMipmap");
	glBlitFramebuffer = cast(typeof(glBlitFramebuffer))load("glBlitFramebuffer");
	glRenderbufferStorageMultisample = cast(typeof(glRenderbufferStorageMultisample))load("glRenderbufferStorageMultisample");
	glFramebufferTextureLayer = cast(typeof(glFramebufferTextureLayer))load("glFramebufferTextureLayer");
	return GL_ARB_framebuffer_object;
}


bool load_gl_GL_ATI_envmap_bumpmap(void* function(string name) load) {
	if(!GL_ATI_envmap_bumpmap) return GL_ATI_envmap_bumpmap;

	glTexBumpParameterivATI = cast(typeof(glTexBumpParameterivATI))load("glTexBumpParameterivATI");
	glTexBumpParameterfvATI = cast(typeof(glTexBumpParameterfvATI))load("glTexBumpParameterfvATI");
	glGetTexBumpParameterivATI = cast(typeof(glGetTexBumpParameterivATI))load("glGetTexBumpParameterivATI");
	glGetTexBumpParameterfvATI = cast(typeof(glGetTexBumpParameterfvATI))load("glGetTexBumpParameterfvATI");
	return GL_ATI_envmap_bumpmap;
}


bool load_gl_GL_ARB_robust_buffer_access_behavior(void* function(string name) load) {
	if(!GL_ARB_robust_buffer_access_behavior) return GL_ARB_robust_buffer_access_behavior;

	return GL_ARB_robust_buffer_access_behavior;
}


bool load_gl_GL_ARB_shader_stencil_export(void* function(string name) load) {
	if(!GL_ARB_shader_stencil_export) return GL_ARB_shader_stencil_export;

	return GL_ARB_shader_stencil_export;
}


bool load_gl_GL_AMD_sample_positions(void* function(string name) load) {
	if(!GL_AMD_sample_positions) return GL_AMD_sample_positions;

	glSetMultisamplefvAMD = cast(typeof(glSetMultisamplefvAMD))load("glSetMultisamplefvAMD");
	return GL_AMD_sample_positions;
}


bool load_gl_GL_ARB_enhanced_layouts(void* function(string name) load) {
	if(!GL_ARB_enhanced_layouts) return GL_ARB_enhanced_layouts;

	return GL_ARB_enhanced_layouts;
}


bool load_gl_GL_ARB_texture_rectangle(void* function(string name) load) {
	if(!GL_ARB_texture_rectangle) return GL_ARB_texture_rectangle;

	return GL_ARB_texture_rectangle;
}


bool load_gl_GL_SGI_texture_color_table(void* function(string name) load) {
	if(!GL_SGI_texture_color_table) return GL_SGI_texture_color_table;

	return GL_SGI_texture_color_table;
}


bool load_gl_GL_ATI_map_object_buffer(void* function(string name) load) {
	if(!GL_ATI_map_object_buffer) return GL_ATI_map_object_buffer;

	glMapObjectBufferATI = cast(typeof(glMapObjectBufferATI))load("glMapObjectBufferATI");
	glUnmapObjectBufferATI = cast(typeof(glUnmapObjectBufferATI))load("glUnmapObjectBufferATI");
	return GL_ATI_map_object_buffer;
}


bool load_gl_GL_ARB_robustness(void* function(string name) load) {
	if(!GL_ARB_robustness) return GL_ARB_robustness;

	glGetGraphicsResetStatusARB = cast(typeof(glGetGraphicsResetStatusARB))load("glGetGraphicsResetStatusARB");
	glGetnTexImageARB = cast(typeof(glGetnTexImageARB))load("glGetnTexImageARB");
	glReadnPixelsARB = cast(typeof(glReadnPixelsARB))load("glReadnPixelsARB");
	glGetnCompressedTexImageARB = cast(typeof(glGetnCompressedTexImageARB))load("glGetnCompressedTexImageARB");
	glGetnUniformfvARB = cast(typeof(glGetnUniformfvARB))load("glGetnUniformfvARB");
	glGetnUniformivARB = cast(typeof(glGetnUniformivARB))load("glGetnUniformivARB");
	glGetnUniformuivARB = cast(typeof(glGetnUniformuivARB))load("glGetnUniformuivARB");
	glGetnUniformdvARB = cast(typeof(glGetnUniformdvARB))load("glGetnUniformdvARB");
	glGetnMapdvARB = cast(typeof(glGetnMapdvARB))load("glGetnMapdvARB");
	glGetnMapfvARB = cast(typeof(glGetnMapfvARB))load("glGetnMapfvARB");
	glGetnMapivARB = cast(typeof(glGetnMapivARB))load("glGetnMapivARB");
	glGetnPixelMapfvARB = cast(typeof(glGetnPixelMapfvARB))load("glGetnPixelMapfvARB");
	glGetnPixelMapuivARB = cast(typeof(glGetnPixelMapuivARB))load("glGetnPixelMapuivARB");
	glGetnPixelMapusvARB = cast(typeof(glGetnPixelMapusvARB))load("glGetnPixelMapusvARB");
	glGetnPolygonStippleARB = cast(typeof(glGetnPolygonStippleARB))load("glGetnPolygonStippleARB");
	glGetnColorTableARB = cast(typeof(glGetnColorTableARB))load("glGetnColorTableARB");
	glGetnConvolutionFilterARB = cast(typeof(glGetnConvolutionFilterARB))load("glGetnConvolutionFilterARB");
	glGetnSeparableFilterARB = cast(typeof(glGetnSeparableFilterARB))load("glGetnSeparableFilterARB");
	glGetnHistogramARB = cast(typeof(glGetnHistogramARB))load("glGetnHistogramARB");
	glGetnMinmaxARB = cast(typeof(glGetnMinmaxARB))load("glGetnMinmaxARB");
	return GL_ARB_robustness;
}


bool load_gl_GL_NV_pixel_data_range(void* function(string name) load) {
	if(!GL_NV_pixel_data_range) return GL_NV_pixel_data_range;

	glPixelDataRangeNV = cast(typeof(glPixelDataRangeNV))load("glPixelDataRangeNV");
	glFlushPixelDataRangeNV = cast(typeof(glFlushPixelDataRangeNV))load("glFlushPixelDataRangeNV");
	return GL_NV_pixel_data_range;
}


bool load_gl_GL_EXT_framebuffer_blit(void* function(string name) load) {
	if(!GL_EXT_framebuffer_blit) return GL_EXT_framebuffer_blit;

	glBlitFramebufferEXT = cast(typeof(glBlitFramebufferEXT))load("glBlitFramebufferEXT");
	return GL_EXT_framebuffer_blit;
}


bool load_gl_GL_ARB_gpu_shader_fp64(void* function(string name) load) {
	if(!GL_ARB_gpu_shader_fp64) return GL_ARB_gpu_shader_fp64;

	glUniform1d = cast(typeof(glUniform1d))load("glUniform1d");
	glUniform2d = cast(typeof(glUniform2d))load("glUniform2d");
	glUniform3d = cast(typeof(glUniform3d))load("glUniform3d");
	glUniform4d = cast(typeof(glUniform4d))load("glUniform4d");
	glUniform1dv = cast(typeof(glUniform1dv))load("glUniform1dv");
	glUniform2dv = cast(typeof(glUniform2dv))load("glUniform2dv");
	glUniform3dv = cast(typeof(glUniform3dv))load("glUniform3dv");
	glUniform4dv = cast(typeof(glUniform4dv))load("glUniform4dv");
	glUniformMatrix2dv = cast(typeof(glUniformMatrix2dv))load("glUniformMatrix2dv");
	glUniformMatrix3dv = cast(typeof(glUniformMatrix3dv))load("glUniformMatrix3dv");
	glUniformMatrix4dv = cast(typeof(glUniformMatrix4dv))load("glUniformMatrix4dv");
	glUniformMatrix2x3dv = cast(typeof(glUniformMatrix2x3dv))load("glUniformMatrix2x3dv");
	glUniformMatrix2x4dv = cast(typeof(glUniformMatrix2x4dv))load("glUniformMatrix2x4dv");
	glUniformMatrix3x2dv = cast(typeof(glUniformMatrix3x2dv))load("glUniformMatrix3x2dv");
	glUniformMatrix3x4dv = cast(typeof(glUniformMatrix3x4dv))load("glUniformMatrix3x4dv");
	glUniformMatrix4x2dv = cast(typeof(glUniformMatrix4x2dv))load("glUniformMatrix4x2dv");
	glUniformMatrix4x3dv = cast(typeof(glUniformMatrix4x3dv))load("glUniformMatrix4x3dv");
	glGetUniformdv = cast(typeof(glGetUniformdv))load("glGetUniformdv");
	return GL_ARB_gpu_shader_fp64;
}


bool load_gl_GL_SGIX_depth_texture(void* function(string name) load) {
	if(!GL_SGIX_depth_texture) return GL_SGIX_depth_texture;

	return GL_SGIX_depth_texture;
}


bool load_gl_GL_ARB_robustness_isolation(void* function(string name) load) {
	if(!GL_ARB_robustness_isolation) return GL_ARB_robustness_isolation;

	return GL_ARB_robustness_isolation;
}


bool load_gl_GL_GREMEDY_string_marker(void* function(string name) load) {
	if(!GL_GREMEDY_string_marker) return GL_GREMEDY_string_marker;

	glStringMarkerGREMEDY = cast(typeof(glStringMarkerGREMEDY))load("glStringMarkerGREMEDY");
	return GL_GREMEDY_string_marker;
}


bool load_gl_GL_ARB_texture_compression_bptc(void* function(string name) load) {
	if(!GL_ARB_texture_compression_bptc) return GL_ARB_texture_compression_bptc;

	return GL_ARB_texture_compression_bptc;
}


bool load_gl_GL_EXT_subtexture(void* function(string name) load) {
	if(!GL_EXT_subtexture) return GL_EXT_subtexture;

	glTexSubImage1DEXT = cast(typeof(glTexSubImage1DEXT))load("glTexSubImage1DEXT");
	glTexSubImage2DEXT = cast(typeof(glTexSubImage2DEXT))load("glTexSubImage2DEXT");
	return GL_EXT_subtexture;
}


bool load_gl_GL_EXT_pixel_transform_color_table(void* function(string name) load) {
	if(!GL_EXT_pixel_transform_color_table) return GL_EXT_pixel_transform_color_table;

	return GL_EXT_pixel_transform_color_table;
}


bool load_gl_GL_EXT_texture_compression_rgtc(void* function(string name) load) {
	if(!GL_EXT_texture_compression_rgtc) return GL_EXT_texture_compression_rgtc;

	return GL_EXT_texture_compression_rgtc;
}


bool load_gl_GL_SGIX_depth_pass_instrument(void* function(string name) load) {
	if(!GL_SGIX_depth_pass_instrument) return GL_SGIX_depth_pass_instrument;

	return GL_SGIX_depth_pass_instrument;
}


bool load_gl_GL_NVX_conditional_render(void* function(string name) load) {
	if(!GL_NVX_conditional_render) return GL_NVX_conditional_render;

	glBeginConditionalRenderNVX = cast(typeof(glBeginConditionalRenderNVX))load("glBeginConditionalRenderNVX");
	glEndConditionalRenderNVX = cast(typeof(glEndConditionalRenderNVX))load("glEndConditionalRenderNVX");
	return GL_NVX_conditional_render;
}


bool load_gl_GL_NV_evaluators(void* function(string name) load) {
	if(!GL_NV_evaluators) return GL_NV_evaluators;

	glMapControlPointsNV = cast(typeof(glMapControlPointsNV))load("glMapControlPointsNV");
	glMapParameterivNV = cast(typeof(glMapParameterivNV))load("glMapParameterivNV");
	glMapParameterfvNV = cast(typeof(glMapParameterfvNV))load("glMapParameterfvNV");
	glGetMapControlPointsNV = cast(typeof(glGetMapControlPointsNV))load("glGetMapControlPointsNV");
	glGetMapParameterivNV = cast(typeof(glGetMapParameterivNV))load("glGetMapParameterivNV");
	glGetMapParameterfvNV = cast(typeof(glGetMapParameterfvNV))load("glGetMapParameterfvNV");
	glGetMapAttribParameterivNV = cast(typeof(glGetMapAttribParameterivNV))load("glGetMapAttribParameterivNV");
	glGetMapAttribParameterfvNV = cast(typeof(glGetMapAttribParameterfvNV))load("glGetMapAttribParameterfvNV");
	glEvalMapsNV = cast(typeof(glEvalMapsNV))load("glEvalMapsNV");
	return GL_NV_evaluators;
}


bool load_gl_GL_SGIS_texture_filter4(void* function(string name) load) {
	if(!GL_SGIS_texture_filter4) return GL_SGIS_texture_filter4;

	glGetTexFilterFuncSGIS = cast(typeof(glGetTexFilterFuncSGIS))load("glGetTexFilterFuncSGIS");
	glTexFilterFuncSGIS = cast(typeof(glTexFilterFuncSGIS))load("glTexFilterFuncSGIS");
	return GL_SGIS_texture_filter4;
}


bool load_gl_GL_AMD_performance_monitor(void* function(string name) load) {
	if(!GL_AMD_performance_monitor) return GL_AMD_performance_monitor;

	glGetPerfMonitorGroupsAMD = cast(typeof(glGetPerfMonitorGroupsAMD))load("glGetPerfMonitorGroupsAMD");
	glGetPerfMonitorCountersAMD = cast(typeof(glGetPerfMonitorCountersAMD))load("glGetPerfMonitorCountersAMD");
	glGetPerfMonitorGroupStringAMD = cast(typeof(glGetPerfMonitorGroupStringAMD))load("glGetPerfMonitorGroupStringAMD");
	glGetPerfMonitorCounterStringAMD = cast(typeof(glGetPerfMonitorCounterStringAMD))load("glGetPerfMonitorCounterStringAMD");
	glGetPerfMonitorCounterInfoAMD = cast(typeof(glGetPerfMonitorCounterInfoAMD))load("glGetPerfMonitorCounterInfoAMD");
	glGenPerfMonitorsAMD = cast(typeof(glGenPerfMonitorsAMD))load("glGenPerfMonitorsAMD");
	glDeletePerfMonitorsAMD = cast(typeof(glDeletePerfMonitorsAMD))load("glDeletePerfMonitorsAMD");
	glSelectPerfMonitorCountersAMD = cast(typeof(glSelectPerfMonitorCountersAMD))load("glSelectPerfMonitorCountersAMD");
	glBeginPerfMonitorAMD = cast(typeof(glBeginPerfMonitorAMD))load("glBeginPerfMonitorAMD");
	glEndPerfMonitorAMD = cast(typeof(glEndPerfMonitorAMD))load("glEndPerfMonitorAMD");
	glGetPerfMonitorCounterDataAMD = cast(typeof(glGetPerfMonitorCounterDataAMD))load("glGetPerfMonitorCounterDataAMD");
	return GL_AMD_performance_monitor;
}


bool load_gl_GL_NV_geometry_shader4(void* function(string name) load) {
	if(!GL_NV_geometry_shader4) return GL_NV_geometry_shader4;

	return GL_NV_geometry_shader4;
}


bool load_gl_GL_EXT_stencil_clear_tag(void* function(string name) load) {
	if(!GL_EXT_stencil_clear_tag) return GL_EXT_stencil_clear_tag;

	glStencilClearTagEXT = cast(typeof(glStencilClearTagEXT))load("glStencilClearTagEXT");
	return GL_EXT_stencil_clear_tag;
}


bool load_gl_GL_NV_vertex_program1_1(void* function(string name) load) {
	if(!GL_NV_vertex_program1_1) return GL_NV_vertex_program1_1;

	return GL_NV_vertex_program1_1;
}


bool load_gl_GL_NV_present_video(void* function(string name) load) {
	if(!GL_NV_present_video) return GL_NV_present_video;

	glPresentFrameKeyedNV = cast(typeof(glPresentFrameKeyedNV))load("glPresentFrameKeyedNV");
	glPresentFrameDualFillNV = cast(typeof(glPresentFrameDualFillNV))load("glPresentFrameDualFillNV");
	glGetVideoivNV = cast(typeof(glGetVideoivNV))load("glGetVideoivNV");
	glGetVideouivNV = cast(typeof(glGetVideouivNV))load("glGetVideouivNV");
	glGetVideoi64vNV = cast(typeof(glGetVideoi64vNV))load("glGetVideoi64vNV");
	glGetVideoui64vNV = cast(typeof(glGetVideoui64vNV))load("glGetVideoui64vNV");
	return GL_NV_present_video;
}


bool load_gl_GL_ARB_texture_compression_rgtc(void* function(string name) load) {
	if(!GL_ARB_texture_compression_rgtc) return GL_ARB_texture_compression_rgtc;

	return GL_ARB_texture_compression_rgtc;
}


bool load_gl_GL_HP_convolution_border_modes(void* function(string name) load) {
	if(!GL_HP_convolution_border_modes) return GL_HP_convolution_border_modes;

	return GL_HP_convolution_border_modes;
}


bool load_gl_GL_EXT_gpu_program_parameters(void* function(string name) load) {
	if(!GL_EXT_gpu_program_parameters) return GL_EXT_gpu_program_parameters;

	glProgramEnvParameters4fvEXT = cast(typeof(glProgramEnvParameters4fvEXT))load("glProgramEnvParameters4fvEXT");
	glProgramLocalParameters4fvEXT = cast(typeof(glProgramLocalParameters4fvEXT))load("glProgramLocalParameters4fvEXT");
	return GL_EXT_gpu_program_parameters;
}


bool load_gl_GL_SGIX_list_priority(void* function(string name) load) {
	if(!GL_SGIX_list_priority) return GL_SGIX_list_priority;

	glGetListParameterfvSGIX = cast(typeof(glGetListParameterfvSGIX))load("glGetListParameterfvSGIX");
	glGetListParameterivSGIX = cast(typeof(glGetListParameterivSGIX))load("glGetListParameterivSGIX");
	glListParameterfSGIX = cast(typeof(glListParameterfSGIX))load("glListParameterfSGIX");
	glListParameterfvSGIX = cast(typeof(glListParameterfvSGIX))load("glListParameterfvSGIX");
	glListParameteriSGIX = cast(typeof(glListParameteriSGIX))load("glListParameteriSGIX");
	glListParameterivSGIX = cast(typeof(glListParameterivSGIX))load("glListParameterivSGIX");
	return GL_SGIX_list_priority;
}


bool load_gl_GL_ARB_stencil_texturing(void* function(string name) load) {
	if(!GL_ARB_stencil_texturing) return GL_ARB_stencil_texturing;

	return GL_ARB_stencil_texturing;
}


bool load_gl_GL_SGIX_fog_offset(void* function(string name) load) {
	if(!GL_SGIX_fog_offset) return GL_SGIX_fog_offset;

	return GL_SGIX_fog_offset;
}


bool load_gl_GL_ARB_draw_elements_base_vertex(void* function(string name) load) {
	if(!GL_ARB_draw_elements_base_vertex) return GL_ARB_draw_elements_base_vertex;

	glDrawElementsBaseVertex = cast(typeof(glDrawElementsBaseVertex))load("glDrawElementsBaseVertex");
	glDrawRangeElementsBaseVertex = cast(typeof(glDrawRangeElementsBaseVertex))load("glDrawRangeElementsBaseVertex");
	glDrawElementsInstancedBaseVertex = cast(typeof(glDrawElementsInstancedBaseVertex))load("glDrawElementsInstancedBaseVertex");
	glMultiDrawElementsBaseVertex = cast(typeof(glMultiDrawElementsBaseVertex))load("glMultiDrawElementsBaseVertex");
	return GL_ARB_draw_elements_base_vertex;
}


bool load_gl_GL_INGR_interlace_read(void* function(string name) load) {
	if(!GL_INGR_interlace_read) return GL_INGR_interlace_read;

	return GL_INGR_interlace_read;
}


bool load_gl_GL_NV_transform_feedback(void* function(string name) load) {
	if(!GL_NV_transform_feedback) return GL_NV_transform_feedback;

	glBeginTransformFeedbackNV = cast(typeof(glBeginTransformFeedbackNV))load("glBeginTransformFeedbackNV");
	glEndTransformFeedbackNV = cast(typeof(glEndTransformFeedbackNV))load("glEndTransformFeedbackNV");
	glTransformFeedbackAttribsNV = cast(typeof(glTransformFeedbackAttribsNV))load("glTransformFeedbackAttribsNV");
	glBindBufferRangeNV = cast(typeof(glBindBufferRangeNV))load("glBindBufferRangeNV");
	glBindBufferOffsetNV = cast(typeof(glBindBufferOffsetNV))load("glBindBufferOffsetNV");
	glBindBufferBaseNV = cast(typeof(glBindBufferBaseNV))load("glBindBufferBaseNV");
	glTransformFeedbackVaryingsNV = cast(typeof(glTransformFeedbackVaryingsNV))load("glTransformFeedbackVaryingsNV");
	glActiveVaryingNV = cast(typeof(glActiveVaryingNV))load("glActiveVaryingNV");
	glGetVaryingLocationNV = cast(typeof(glGetVaryingLocationNV))load("glGetVaryingLocationNV");
	glGetActiveVaryingNV = cast(typeof(glGetActiveVaryingNV))load("glGetActiveVaryingNV");
	glGetTransformFeedbackVaryingNV = cast(typeof(glGetTransformFeedbackVaryingNV))load("glGetTransformFeedbackVaryingNV");
	glTransformFeedbackStreamAttribsNV = cast(typeof(glTransformFeedbackStreamAttribsNV))load("glTransformFeedbackStreamAttribsNV");
	return GL_NV_transform_feedback;
}


bool load_gl_GL_ARB_debug_output(void* function(string name) load) {
	if(!GL_ARB_debug_output) return GL_ARB_debug_output;

	glDebugMessageControlARB = cast(typeof(glDebugMessageControlARB))load("glDebugMessageControlARB");
	glDebugMessageInsertARB = cast(typeof(glDebugMessageInsertARB))load("glDebugMessageInsertARB");
	glDebugMessageCallbackARB = cast(typeof(glDebugMessageCallbackARB))load("glDebugMessageCallbackARB");
	glGetDebugMessageLogARB = cast(typeof(glGetDebugMessageLogARB))load("glGetDebugMessageLogARB");
	return GL_ARB_debug_output;
}


bool load_gl_GL_AMD_stencil_operation_extended(void* function(string name) load) {
	if(!GL_AMD_stencil_operation_extended) return GL_AMD_stencil_operation_extended;

	glStencilOpValueAMD = cast(typeof(glStencilOpValueAMD))load("glStencilOpValueAMD");
	return GL_AMD_stencil_operation_extended;
}


bool load_gl_GL_ARB_compatibility(void* function(string name) load) {
	if(!GL_ARB_compatibility) return GL_ARB_compatibility;

	return GL_ARB_compatibility;
}


bool load_gl_GL_ARB_instanced_arrays(void* function(string name) load) {
	if(!GL_ARB_instanced_arrays) return GL_ARB_instanced_arrays;

	glVertexAttribDivisorARB = cast(typeof(glVertexAttribDivisorARB))load("glVertexAttribDivisorARB");
	return GL_ARB_instanced_arrays;
}


bool load_gl_GL_EXT_polygon_offset(void* function(string name) load) {
	if(!GL_EXT_polygon_offset) return GL_EXT_polygon_offset;

	glPolygonOffsetEXT = cast(typeof(glPolygonOffsetEXT))load("glPolygonOffsetEXT");
	return GL_EXT_polygon_offset;
}


bool load_gl_GL_NV_vertex_array_range2(void* function(string name) load) {
	if(!GL_NV_vertex_array_range2) return GL_NV_vertex_array_range2;

	return GL_NV_vertex_array_range2;
}


bool load_gl_GL_AMD_sparse_texture(void* function(string name) load) {
	if(!GL_AMD_sparse_texture) return GL_AMD_sparse_texture;

	glTexStorageSparseAMD = cast(typeof(glTexStorageSparseAMD))load("glTexStorageSparseAMD");
	glTextureStorageSparseAMD = cast(typeof(glTextureStorageSparseAMD))load("glTextureStorageSparseAMD");
	return GL_AMD_sparse_texture;
}


bool load_gl_GL_NV_fence(void* function(string name) load) {
	if(!GL_NV_fence) return GL_NV_fence;

	glDeleteFencesNV = cast(typeof(glDeleteFencesNV))load("glDeleteFencesNV");
	glGenFencesNV = cast(typeof(glGenFencesNV))load("glGenFencesNV");
	glIsFenceNV = cast(typeof(glIsFenceNV))load("glIsFenceNV");
	glTestFenceNV = cast(typeof(glTestFenceNV))load("glTestFenceNV");
	glGetFenceivNV = cast(typeof(glGetFenceivNV))load("glGetFenceivNV");
	glFinishFenceNV = cast(typeof(glFinishFenceNV))load("glFinishFenceNV");
	glSetFenceNV = cast(typeof(glSetFenceNV))load("glSetFenceNV");
	return GL_NV_fence;
}


bool load_gl_GL_ARB_texture_buffer_range(void* function(string name) load) {
	if(!GL_ARB_texture_buffer_range) return GL_ARB_texture_buffer_range;

	glTexBufferRange = cast(typeof(glTexBufferRange))load("glTexBufferRange");
	return GL_ARB_texture_buffer_range;
}


bool load_gl_GL_SUN_mesh_array(void* function(string name) load) {
	if(!GL_SUN_mesh_array) return GL_SUN_mesh_array;

	glDrawMeshArraysSUN = cast(typeof(glDrawMeshArraysSUN))load("glDrawMeshArraysSUN");
	return GL_SUN_mesh_array;
}


bool load_gl_GL_ARB_vertex_attrib_binding(void* function(string name) load) {
	if(!GL_ARB_vertex_attrib_binding) return GL_ARB_vertex_attrib_binding;

	glBindVertexBuffer = cast(typeof(glBindVertexBuffer))load("glBindVertexBuffer");
	glVertexAttribFormat = cast(typeof(glVertexAttribFormat))load("glVertexAttribFormat");
	glVertexAttribIFormat = cast(typeof(glVertexAttribIFormat))load("glVertexAttribIFormat");
	glVertexAttribLFormat = cast(typeof(glVertexAttribLFormat))load("glVertexAttribLFormat");
	glVertexAttribBinding = cast(typeof(glVertexAttribBinding))load("glVertexAttribBinding");
	glVertexBindingDivisor = cast(typeof(glVertexBindingDivisor))load("glVertexBindingDivisor");
	return GL_ARB_vertex_attrib_binding;
}


bool load_gl_GL_ARB_framebuffer_no_attachments(void* function(string name) load) {
	if(!GL_ARB_framebuffer_no_attachments) return GL_ARB_framebuffer_no_attachments;

	glFramebufferParameteri = cast(typeof(glFramebufferParameteri))load("glFramebufferParameteri");
	glGetFramebufferParameteriv = cast(typeof(glGetFramebufferParameteriv))load("glGetFramebufferParameteriv");
	return GL_ARB_framebuffer_no_attachments;
}


bool load_gl_GL_ARB_cl_event(void* function(string name) load) {
	if(!GL_ARB_cl_event) return GL_ARB_cl_event;

	glCreateSyncFromCLeventARB = cast(typeof(glCreateSyncFromCLeventARB))load("glCreateSyncFromCLeventARB");
	return GL_ARB_cl_event;
}


bool load_gl_GL_NV_packed_depth_stencil(void* function(string name) load) {
	if(!GL_NV_packed_depth_stencil) return GL_NV_packed_depth_stencil;

	return GL_NV_packed_depth_stencil;
}


bool load_gl_GL_OES_single_precision(void* function(string name) load) {
	if(!GL_OES_single_precision) return GL_OES_single_precision;

	glClearDepthfOES = cast(typeof(glClearDepthfOES))load("glClearDepthfOES");
	glClipPlanefOES = cast(typeof(glClipPlanefOES))load("glClipPlanefOES");
	glDepthRangefOES = cast(typeof(glDepthRangefOES))load("glDepthRangefOES");
	glFrustumfOES = cast(typeof(glFrustumfOES))load("glFrustumfOES");
	glGetClipPlanefOES = cast(typeof(glGetClipPlanefOES))load("glGetClipPlanefOES");
	glOrthofOES = cast(typeof(glOrthofOES))load("glOrthofOES");
	return GL_OES_single_precision;
}


bool load_gl_GL_NV_primitive_restart(void* function(string name) load) {
	if(!GL_NV_primitive_restart) return GL_NV_primitive_restart;

	glPrimitiveRestartNV = cast(typeof(glPrimitiveRestartNV))load("glPrimitiveRestartNV");
	glPrimitiveRestartIndexNV = cast(typeof(glPrimitiveRestartIndexNV))load("glPrimitiveRestartIndexNV");
	return GL_NV_primitive_restart;
}


bool load_gl_GL_EXT_texture_object(void* function(string name) load) {
	if(!GL_EXT_texture_object) return GL_EXT_texture_object;

	glAreTexturesResidentEXT = cast(typeof(glAreTexturesResidentEXT))load("glAreTexturesResidentEXT");
	glBindTextureEXT = cast(typeof(glBindTextureEXT))load("glBindTextureEXT");
	glDeleteTexturesEXT = cast(typeof(glDeleteTexturesEXT))load("glDeleteTexturesEXT");
	glGenTexturesEXT = cast(typeof(glGenTexturesEXT))load("glGenTexturesEXT");
	glIsTextureEXT = cast(typeof(glIsTextureEXT))load("glIsTextureEXT");
	glPrioritizeTexturesEXT = cast(typeof(glPrioritizeTexturesEXT))load("glPrioritizeTexturesEXT");
	return GL_EXT_texture_object;
}


bool load_gl_GL_AMD_name_gen_delete(void* function(string name) load) {
	if(!GL_AMD_name_gen_delete) return GL_AMD_name_gen_delete;

	glGenNamesAMD = cast(typeof(glGenNamesAMD))load("glGenNamesAMD");
	glDeleteNamesAMD = cast(typeof(glDeleteNamesAMD))load("glDeleteNamesAMD");
	glIsNameAMD = cast(typeof(glIsNameAMD))load("glIsNameAMD");
	return GL_AMD_name_gen_delete;
}


bool load_gl_GL_NV_texture_compression_vtc(void* function(string name) load) {
	if(!GL_NV_texture_compression_vtc) return GL_NV_texture_compression_vtc;

	return GL_NV_texture_compression_vtc;
}


bool load_gl_GL_SGIX_ycrcb_subsample(void* function(string name) load) {
	if(!GL_SGIX_ycrcb_subsample) return GL_SGIX_ycrcb_subsample;

	return GL_SGIX_ycrcb_subsample;
}


bool load_gl_GL_NV_texture_shader3(void* function(string name) load) {
	if(!GL_NV_texture_shader3) return GL_NV_texture_shader3;

	return GL_NV_texture_shader3;
}


bool load_gl_GL_NV_texture_shader2(void* function(string name) load) {
	if(!GL_NV_texture_shader2) return GL_NV_texture_shader2;

	return GL_NV_texture_shader2;
}


bool load_gl_GL_EXT_texture(void* function(string name) load) {
	if(!GL_EXT_texture) return GL_EXT_texture;

	return GL_EXT_texture;
}


bool load_gl_GL_ARB_buffer_storage(void* function(string name) load) {
	if(!GL_ARB_buffer_storage) return GL_ARB_buffer_storage;

	glBufferStorage = cast(typeof(glBufferStorage))load("glBufferStorage");
	return GL_ARB_buffer_storage;
}


bool load_gl_GL_AMD_shader_atomic_counter_ops(void* function(string name) load) {
	if(!GL_AMD_shader_atomic_counter_ops) return GL_AMD_shader_atomic_counter_ops;

	return GL_AMD_shader_atomic_counter_ops;
}


bool load_gl_GL_APPLE_vertex_program_evaluators(void* function(string name) load) {
	if(!GL_APPLE_vertex_program_evaluators) return GL_APPLE_vertex_program_evaluators;

	glEnableVertexAttribAPPLE = cast(typeof(glEnableVertexAttribAPPLE))load("glEnableVertexAttribAPPLE");
	glDisableVertexAttribAPPLE = cast(typeof(glDisableVertexAttribAPPLE))load("glDisableVertexAttribAPPLE");
	glIsVertexAttribEnabledAPPLE = cast(typeof(glIsVertexAttribEnabledAPPLE))load("glIsVertexAttribEnabledAPPLE");
	glMapVertexAttrib1dAPPLE = cast(typeof(glMapVertexAttrib1dAPPLE))load("glMapVertexAttrib1dAPPLE");
	glMapVertexAttrib1fAPPLE = cast(typeof(glMapVertexAttrib1fAPPLE))load("glMapVertexAttrib1fAPPLE");
	glMapVertexAttrib2dAPPLE = cast(typeof(glMapVertexAttrib2dAPPLE))load("glMapVertexAttrib2dAPPLE");
	glMapVertexAttrib2fAPPLE = cast(typeof(glMapVertexAttrib2fAPPLE))load("glMapVertexAttrib2fAPPLE");
	return GL_APPLE_vertex_program_evaluators;
}


bool load_gl_GL_ARB_multi_bind(void* function(string name) load) {
	if(!GL_ARB_multi_bind) return GL_ARB_multi_bind;

	glBindBuffersBase = cast(typeof(glBindBuffersBase))load("glBindBuffersBase");
	glBindBuffersRange = cast(typeof(glBindBuffersRange))load("glBindBuffersRange");
	glBindTextures = cast(typeof(glBindTextures))load("glBindTextures");
	glBindSamplers = cast(typeof(glBindSamplers))load("glBindSamplers");
	glBindImageTextures = cast(typeof(glBindImageTextures))load("glBindImageTextures");
	glBindVertexBuffers = cast(typeof(glBindVertexBuffers))load("glBindVertexBuffers");
	return GL_ARB_multi_bind;
}


bool load_gl_GL_ARB_explicit_uniform_location(void* function(string name) load) {
	if(!GL_ARB_explicit_uniform_location) return GL_ARB_explicit_uniform_location;

	return GL_ARB_explicit_uniform_location;
}


bool load_gl_GL_ARB_depth_buffer_float(void* function(string name) load) {
	if(!GL_ARB_depth_buffer_float) return GL_ARB_depth_buffer_float;

	return GL_ARB_depth_buffer_float;
}


bool load_gl_GL_SGIX_shadow_ambient(void* function(string name) load) {
	if(!GL_SGIX_shadow_ambient) return GL_SGIX_shadow_ambient;

	return GL_SGIX_shadow_ambient;
}


bool load_gl_GL_ARB_texture_cube_map(void* function(string name) load) {
	if(!GL_ARB_texture_cube_map) return GL_ARB_texture_cube_map;

	return GL_ARB_texture_cube_map;
}


bool load_gl_GL_AMD_vertex_shader_viewport_index(void* function(string name) load) {
	if(!GL_AMD_vertex_shader_viewport_index) return GL_AMD_vertex_shader_viewport_index;

	return GL_AMD_vertex_shader_viewport_index;
}


bool load_gl_GL_NV_vertex_buffer_unified_memory(void* function(string name) load) {
	if(!GL_NV_vertex_buffer_unified_memory) return GL_NV_vertex_buffer_unified_memory;

	glBufferAddressRangeNV = cast(typeof(glBufferAddressRangeNV))load("glBufferAddressRangeNV");
	glVertexFormatNV = cast(typeof(glVertexFormatNV))load("glVertexFormatNV");
	glNormalFormatNV = cast(typeof(glNormalFormatNV))load("glNormalFormatNV");
	glColorFormatNV = cast(typeof(glColorFormatNV))load("glColorFormatNV");
	glIndexFormatNV = cast(typeof(glIndexFormatNV))load("glIndexFormatNV");
	glTexCoordFormatNV = cast(typeof(glTexCoordFormatNV))load("glTexCoordFormatNV");
	glEdgeFlagFormatNV = cast(typeof(glEdgeFlagFormatNV))load("glEdgeFlagFormatNV");
	glSecondaryColorFormatNV = cast(typeof(glSecondaryColorFormatNV))load("glSecondaryColorFormatNV");
	glFogCoordFormatNV = cast(typeof(glFogCoordFormatNV))load("glFogCoordFormatNV");
	glVertexAttribFormatNV = cast(typeof(glVertexAttribFormatNV))load("glVertexAttribFormatNV");
	glVertexAttribIFormatNV = cast(typeof(glVertexAttribIFormatNV))load("glVertexAttribIFormatNV");
	glGetIntegerui64i_vNV = cast(typeof(glGetIntegerui64i_vNV))load("glGetIntegerui64i_vNV");
	return GL_NV_vertex_buffer_unified_memory;
}


bool load_gl_GL_EXT_texture_env_dot3(void* function(string name) load) {
	if(!GL_EXT_texture_env_dot3) return GL_EXT_texture_env_dot3;

	return GL_EXT_texture_env_dot3;
}


bool load_gl_GL_ATI_texture_env_combine3(void* function(string name) load) {
	if(!GL_ATI_texture_env_combine3) return GL_ATI_texture_env_combine3;

	return GL_ATI_texture_env_combine3;
}


bool load_gl_GL_ARB_map_buffer_alignment(void* function(string name) load) {
	if(!GL_ARB_map_buffer_alignment) return GL_ARB_map_buffer_alignment;

	return GL_ARB_map_buffer_alignment;
}


bool load_gl_GL_NV_blend_equation_advanced(void* function(string name) load) {
	if(!GL_NV_blend_equation_advanced) return GL_NV_blend_equation_advanced;

	glBlendParameteriNV = cast(typeof(glBlendParameteriNV))load("glBlendParameteriNV");
	glBlendBarrierNV = cast(typeof(glBlendBarrierNV))load("glBlendBarrierNV");
	return GL_NV_blend_equation_advanced;
}


bool load_gl_GL_SGIS_sharpen_texture(void* function(string name) load) {
	if(!GL_SGIS_sharpen_texture) return GL_SGIS_sharpen_texture;

	glSharpenTexFuncSGIS = cast(typeof(glSharpenTexFuncSGIS))load("glSharpenTexFuncSGIS");
	glGetSharpenTexFuncSGIS = cast(typeof(glGetSharpenTexFuncSGIS))load("glGetSharpenTexFuncSGIS");
	return GL_SGIS_sharpen_texture;
}


bool load_gl_GL_ARB_vertex_program(void* function(string name) load) {
	if(!GL_ARB_vertex_program) return GL_ARB_vertex_program;

	glVertexAttrib1dARB = cast(typeof(glVertexAttrib1dARB))load("glVertexAttrib1dARB");
	glVertexAttrib1dvARB = cast(typeof(glVertexAttrib1dvARB))load("glVertexAttrib1dvARB");
	glVertexAttrib1fARB = cast(typeof(glVertexAttrib1fARB))load("glVertexAttrib1fARB");
	glVertexAttrib1fvARB = cast(typeof(glVertexAttrib1fvARB))load("glVertexAttrib1fvARB");
	glVertexAttrib1sARB = cast(typeof(glVertexAttrib1sARB))load("glVertexAttrib1sARB");
	glVertexAttrib1svARB = cast(typeof(glVertexAttrib1svARB))load("glVertexAttrib1svARB");
	glVertexAttrib2dARB = cast(typeof(glVertexAttrib2dARB))load("glVertexAttrib2dARB");
	glVertexAttrib2dvARB = cast(typeof(glVertexAttrib2dvARB))load("glVertexAttrib2dvARB");
	glVertexAttrib2fARB = cast(typeof(glVertexAttrib2fARB))load("glVertexAttrib2fARB");
	glVertexAttrib2fvARB = cast(typeof(glVertexAttrib2fvARB))load("glVertexAttrib2fvARB");
	glVertexAttrib2sARB = cast(typeof(glVertexAttrib2sARB))load("glVertexAttrib2sARB");
	glVertexAttrib2svARB = cast(typeof(glVertexAttrib2svARB))load("glVertexAttrib2svARB");
	glVertexAttrib3dARB = cast(typeof(glVertexAttrib3dARB))load("glVertexAttrib3dARB");
	glVertexAttrib3dvARB = cast(typeof(glVertexAttrib3dvARB))load("glVertexAttrib3dvARB");
	glVertexAttrib3fARB = cast(typeof(glVertexAttrib3fARB))load("glVertexAttrib3fARB");
	glVertexAttrib3fvARB = cast(typeof(glVertexAttrib3fvARB))load("glVertexAttrib3fvARB");
	glVertexAttrib3sARB = cast(typeof(glVertexAttrib3sARB))load("glVertexAttrib3sARB");
	glVertexAttrib3svARB = cast(typeof(glVertexAttrib3svARB))load("glVertexAttrib3svARB");
	glVertexAttrib4NbvARB = cast(typeof(glVertexAttrib4NbvARB))load("glVertexAttrib4NbvARB");
	glVertexAttrib4NivARB = cast(typeof(glVertexAttrib4NivARB))load("glVertexAttrib4NivARB");
	glVertexAttrib4NsvARB = cast(typeof(glVertexAttrib4NsvARB))load("glVertexAttrib4NsvARB");
	glVertexAttrib4NubARB = cast(typeof(glVertexAttrib4NubARB))load("glVertexAttrib4NubARB");
	glVertexAttrib4NubvARB = cast(typeof(glVertexAttrib4NubvARB))load("glVertexAttrib4NubvARB");
	glVertexAttrib4NuivARB = cast(typeof(glVertexAttrib4NuivARB))load("glVertexAttrib4NuivARB");
	glVertexAttrib4NusvARB = cast(typeof(glVertexAttrib4NusvARB))load("glVertexAttrib4NusvARB");
	glVertexAttrib4bvARB = cast(typeof(glVertexAttrib4bvARB))load("glVertexAttrib4bvARB");
	glVertexAttrib4dARB = cast(typeof(glVertexAttrib4dARB))load("glVertexAttrib4dARB");
	glVertexAttrib4dvARB = cast(typeof(glVertexAttrib4dvARB))load("glVertexAttrib4dvARB");
	glVertexAttrib4fARB = cast(typeof(glVertexAttrib4fARB))load("glVertexAttrib4fARB");
	glVertexAttrib4fvARB = cast(typeof(glVertexAttrib4fvARB))load("glVertexAttrib4fvARB");
	glVertexAttrib4ivARB = cast(typeof(glVertexAttrib4ivARB))load("glVertexAttrib4ivARB");
	glVertexAttrib4sARB = cast(typeof(glVertexAttrib4sARB))load("glVertexAttrib4sARB");
	glVertexAttrib4svARB = cast(typeof(glVertexAttrib4svARB))load("glVertexAttrib4svARB");
	glVertexAttrib4ubvARB = cast(typeof(glVertexAttrib4ubvARB))load("glVertexAttrib4ubvARB");
	glVertexAttrib4uivARB = cast(typeof(glVertexAttrib4uivARB))load("glVertexAttrib4uivARB");
	glVertexAttrib4usvARB = cast(typeof(glVertexAttrib4usvARB))load("glVertexAttrib4usvARB");
	glVertexAttribPointerARB = cast(typeof(glVertexAttribPointerARB))load("glVertexAttribPointerARB");
	glEnableVertexAttribArrayARB = cast(typeof(glEnableVertexAttribArrayARB))load("glEnableVertexAttribArrayARB");
	glDisableVertexAttribArrayARB = cast(typeof(glDisableVertexAttribArrayARB))load("glDisableVertexAttribArrayARB");
	glProgramStringARB = cast(typeof(glProgramStringARB))load("glProgramStringARB");
	glBindProgramARB = cast(typeof(glBindProgramARB))load("glBindProgramARB");
	glDeleteProgramsARB = cast(typeof(glDeleteProgramsARB))load("glDeleteProgramsARB");
	glGenProgramsARB = cast(typeof(glGenProgramsARB))load("glGenProgramsARB");
	glProgramEnvParameter4dARB = cast(typeof(glProgramEnvParameter4dARB))load("glProgramEnvParameter4dARB");
	glProgramEnvParameter4dvARB = cast(typeof(glProgramEnvParameter4dvARB))load("glProgramEnvParameter4dvARB");
	glProgramEnvParameter4fARB = cast(typeof(glProgramEnvParameter4fARB))load("glProgramEnvParameter4fARB");
	glProgramEnvParameter4fvARB = cast(typeof(glProgramEnvParameter4fvARB))load("glProgramEnvParameter4fvARB");
	glProgramLocalParameter4dARB = cast(typeof(glProgramLocalParameter4dARB))load("glProgramLocalParameter4dARB");
	glProgramLocalParameter4dvARB = cast(typeof(glProgramLocalParameter4dvARB))load("glProgramLocalParameter4dvARB");
	glProgramLocalParameter4fARB = cast(typeof(glProgramLocalParameter4fARB))load("glProgramLocalParameter4fARB");
	glProgramLocalParameter4fvARB = cast(typeof(glProgramLocalParameter4fvARB))load("glProgramLocalParameter4fvARB");
	glGetProgramEnvParameterdvARB = cast(typeof(glGetProgramEnvParameterdvARB))load("glGetProgramEnvParameterdvARB");
	glGetProgramEnvParameterfvARB = cast(typeof(glGetProgramEnvParameterfvARB))load("glGetProgramEnvParameterfvARB");
	glGetProgramLocalParameterdvARB = cast(typeof(glGetProgramLocalParameterdvARB))load("glGetProgramLocalParameterdvARB");
	glGetProgramLocalParameterfvARB = cast(typeof(glGetProgramLocalParameterfvARB))load("glGetProgramLocalParameterfvARB");
	glGetProgramivARB = cast(typeof(glGetProgramivARB))load("glGetProgramivARB");
	glGetProgramStringARB = cast(typeof(glGetProgramStringARB))load("glGetProgramStringARB");
	glGetVertexAttribdvARB = cast(typeof(glGetVertexAttribdvARB))load("glGetVertexAttribdvARB");
	glGetVertexAttribfvARB = cast(typeof(glGetVertexAttribfvARB))load("glGetVertexAttribfvARB");
	glGetVertexAttribivARB = cast(typeof(glGetVertexAttribivARB))load("glGetVertexAttribivARB");
	glGetVertexAttribPointervARB = cast(typeof(glGetVertexAttribPointervARB))load("glGetVertexAttribPointervARB");
	glIsProgramARB = cast(typeof(glIsProgramARB))load("glIsProgramARB");
	return GL_ARB_vertex_program;
}


bool load_gl_GL_ARB_texture_rgb10_a2ui(void* function(string name) load) {
	if(!GL_ARB_texture_rgb10_a2ui) return GL_ARB_texture_rgb10_a2ui;

	return GL_ARB_texture_rgb10_a2ui;
}


bool load_gl_GL_OML_interlace(void* function(string name) load) {
	if(!GL_OML_interlace) return GL_OML_interlace;

	return GL_OML_interlace;
}


bool load_gl_GL_ATI_pixel_format_float(void* function(string name) load) {
	if(!GL_ATI_pixel_format_float) return GL_ATI_pixel_format_float;

	return GL_ATI_pixel_format_float;
}


bool load_gl_GL_ARB_vertex_buffer_object(void* function(string name) load) {
	if(!GL_ARB_vertex_buffer_object) return GL_ARB_vertex_buffer_object;

	glBindBufferARB = cast(typeof(glBindBufferARB))load("glBindBufferARB");
	glDeleteBuffersARB = cast(typeof(glDeleteBuffersARB))load("glDeleteBuffersARB");
	glGenBuffersARB = cast(typeof(glGenBuffersARB))load("glGenBuffersARB");
	glIsBufferARB = cast(typeof(glIsBufferARB))load("glIsBufferARB");
	glBufferDataARB = cast(typeof(glBufferDataARB))load("glBufferDataARB");
	glBufferSubDataARB = cast(typeof(glBufferSubDataARB))load("glBufferSubDataARB");
	glGetBufferSubDataARB = cast(typeof(glGetBufferSubDataARB))load("glGetBufferSubDataARB");
	glMapBufferARB = cast(typeof(glMapBufferARB))load("glMapBufferARB");
	glUnmapBufferARB = cast(typeof(glUnmapBufferARB))load("glUnmapBufferARB");
	glGetBufferParameterivARB = cast(typeof(glGetBufferParameterivARB))load("glGetBufferParameterivARB");
	glGetBufferPointervARB = cast(typeof(glGetBufferPointervARB))load("glGetBufferPointervARB");
	return GL_ARB_vertex_buffer_object;
}


bool load_gl_GL_EXT_shadow_funcs(void* function(string name) load) {
	if(!GL_EXT_shadow_funcs) return GL_EXT_shadow_funcs;

	return GL_EXT_shadow_funcs;
}


bool load_gl_GL_ATI_text_fragment_shader(void* function(string name) load) {
	if(!GL_ATI_text_fragment_shader) return GL_ATI_text_fragment_shader;

	return GL_ATI_text_fragment_shader;
}


bool load_gl_GL_NV_vertex_array_range(void* function(string name) load) {
	if(!GL_NV_vertex_array_range) return GL_NV_vertex_array_range;

	glFlushVertexArrayRangeNV = cast(typeof(glFlushVertexArrayRangeNV))load("glFlushVertexArrayRangeNV");
	glVertexArrayRangeNV = cast(typeof(glVertexArrayRangeNV))load("glVertexArrayRangeNV");
	return GL_NV_vertex_array_range;
}


bool load_gl_GL_SGIX_fragment_lighting(void* function(string name) load) {
	if(!GL_SGIX_fragment_lighting) return GL_SGIX_fragment_lighting;

	glFragmentColorMaterialSGIX = cast(typeof(glFragmentColorMaterialSGIX))load("glFragmentColorMaterialSGIX");
	glFragmentLightfSGIX = cast(typeof(glFragmentLightfSGIX))load("glFragmentLightfSGIX");
	glFragmentLightfvSGIX = cast(typeof(glFragmentLightfvSGIX))load("glFragmentLightfvSGIX");
	glFragmentLightiSGIX = cast(typeof(glFragmentLightiSGIX))load("glFragmentLightiSGIX");
	glFragmentLightivSGIX = cast(typeof(glFragmentLightivSGIX))load("glFragmentLightivSGIX");
	glFragmentLightModelfSGIX = cast(typeof(glFragmentLightModelfSGIX))load("glFragmentLightModelfSGIX");
	glFragmentLightModelfvSGIX = cast(typeof(glFragmentLightModelfvSGIX))load("glFragmentLightModelfvSGIX");
	glFragmentLightModeliSGIX = cast(typeof(glFragmentLightModeliSGIX))load("glFragmentLightModeliSGIX");
	glFragmentLightModelivSGIX = cast(typeof(glFragmentLightModelivSGIX))load("glFragmentLightModelivSGIX");
	glFragmentMaterialfSGIX = cast(typeof(glFragmentMaterialfSGIX))load("glFragmentMaterialfSGIX");
	glFragmentMaterialfvSGIX = cast(typeof(glFragmentMaterialfvSGIX))load("glFragmentMaterialfvSGIX");
	glFragmentMaterialiSGIX = cast(typeof(glFragmentMaterialiSGIX))load("glFragmentMaterialiSGIX");
	glFragmentMaterialivSGIX = cast(typeof(glFragmentMaterialivSGIX))load("glFragmentMaterialivSGIX");
	glGetFragmentLightfvSGIX = cast(typeof(glGetFragmentLightfvSGIX))load("glGetFragmentLightfvSGIX");
	glGetFragmentLightivSGIX = cast(typeof(glGetFragmentLightivSGIX))load("glGetFragmentLightivSGIX");
	glGetFragmentMaterialfvSGIX = cast(typeof(glGetFragmentMaterialfvSGIX))load("glGetFragmentMaterialfvSGIX");
	glGetFragmentMaterialivSGIX = cast(typeof(glGetFragmentMaterialivSGIX))load("glGetFragmentMaterialivSGIX");
	glLightEnviSGIX = cast(typeof(glLightEnviSGIX))load("glLightEnviSGIX");
	return GL_SGIX_fragment_lighting;
}


bool load_gl_GL_NV_texture_expand_normal(void* function(string name) load) {
	if(!GL_NV_texture_expand_normal) return GL_NV_texture_expand_normal;

	return GL_NV_texture_expand_normal;
}


bool load_gl_GL_NV_framebuffer_multisample_coverage(void* function(string name) load) {
	if(!GL_NV_framebuffer_multisample_coverage) return GL_NV_framebuffer_multisample_coverage;

	glRenderbufferStorageMultisampleCoverageNV = cast(typeof(glRenderbufferStorageMultisampleCoverageNV))load("glRenderbufferStorageMultisampleCoverageNV");
	return GL_NV_framebuffer_multisample_coverage;
}


bool load_gl_GL_EXT_timer_query(void* function(string name) load) {
	if(!GL_EXT_timer_query) return GL_EXT_timer_query;

	glGetQueryObjecti64vEXT = cast(typeof(glGetQueryObjecti64vEXT))load("glGetQueryObjecti64vEXT");
	glGetQueryObjectui64vEXT = cast(typeof(glGetQueryObjectui64vEXT))load("glGetQueryObjectui64vEXT");
	return GL_EXT_timer_query;
}


bool load_gl_GL_EXT_vertex_array_bgra(void* function(string name) load) {
	if(!GL_EXT_vertex_array_bgra) return GL_EXT_vertex_array_bgra;

	return GL_EXT_vertex_array_bgra;
}


bool load_gl_GL_NV_bindless_texture(void* function(string name) load) {
	if(!GL_NV_bindless_texture) return GL_NV_bindless_texture;

	glGetTextureHandleNV = cast(typeof(glGetTextureHandleNV))load("glGetTextureHandleNV");
	glGetTextureSamplerHandleNV = cast(typeof(glGetTextureSamplerHandleNV))load("glGetTextureSamplerHandleNV");
	glMakeTextureHandleResidentNV = cast(typeof(glMakeTextureHandleResidentNV))load("glMakeTextureHandleResidentNV");
	glMakeTextureHandleNonResidentNV = cast(typeof(glMakeTextureHandleNonResidentNV))load("glMakeTextureHandleNonResidentNV");
	glGetImageHandleNV = cast(typeof(glGetImageHandleNV))load("glGetImageHandleNV");
	glMakeImageHandleResidentNV = cast(typeof(glMakeImageHandleResidentNV))load("glMakeImageHandleResidentNV");
	glMakeImageHandleNonResidentNV = cast(typeof(glMakeImageHandleNonResidentNV))load("glMakeImageHandleNonResidentNV");
	glUniformHandleui64NV = cast(typeof(glUniformHandleui64NV))load("glUniformHandleui64NV");
	glUniformHandleui64vNV = cast(typeof(glUniformHandleui64vNV))load("glUniformHandleui64vNV");
	glProgramUniformHandleui64NV = cast(typeof(glProgramUniformHandleui64NV))load("glProgramUniformHandleui64NV");
	glProgramUniformHandleui64vNV = cast(typeof(glProgramUniformHandleui64vNV))load("glProgramUniformHandleui64vNV");
	glIsTextureHandleResidentNV = cast(typeof(glIsTextureHandleResidentNV))load("glIsTextureHandleResidentNV");
	glIsImageHandleResidentNV = cast(typeof(glIsImageHandleResidentNV))load("glIsImageHandleResidentNV");
	return GL_NV_bindless_texture;
}


bool load_gl_GL_KHR_debug(void* function(string name) load) {
	if(!GL_KHR_debug) return GL_KHR_debug;

	glDebugMessageControl = cast(typeof(glDebugMessageControl))load("glDebugMessageControl");
	glDebugMessageInsert = cast(typeof(glDebugMessageInsert))load("glDebugMessageInsert");
	glDebugMessageCallback = cast(typeof(glDebugMessageCallback))load("glDebugMessageCallback");
	glGetDebugMessageLog = cast(typeof(glGetDebugMessageLog))load("glGetDebugMessageLog");
	glPushDebugGroup = cast(typeof(glPushDebugGroup))load("glPushDebugGroup");
	glPopDebugGroup = cast(typeof(glPopDebugGroup))load("glPopDebugGroup");
	glObjectLabel = cast(typeof(glObjectLabel))load("glObjectLabel");
	glGetObjectLabel = cast(typeof(glGetObjectLabel))load("glGetObjectLabel");
	glObjectPtrLabel = cast(typeof(glObjectPtrLabel))load("glObjectPtrLabel");
	glGetObjectPtrLabel = cast(typeof(glGetObjectPtrLabel))load("glGetObjectPtrLabel");
	glGetPointerv = cast(typeof(glGetPointerv))load("glGetPointerv");
	glDebugMessageControlKHR = cast(typeof(glDebugMessageControlKHR))load("glDebugMessageControlKHR");
	glDebugMessageInsertKHR = cast(typeof(glDebugMessageInsertKHR))load("glDebugMessageInsertKHR");
	glDebugMessageCallbackKHR = cast(typeof(glDebugMessageCallbackKHR))load("glDebugMessageCallbackKHR");
	glGetDebugMessageLogKHR = cast(typeof(glGetDebugMessageLogKHR))load("glGetDebugMessageLogKHR");
	glPushDebugGroupKHR = cast(typeof(glPushDebugGroupKHR))load("glPushDebugGroupKHR");
	glPopDebugGroupKHR = cast(typeof(glPopDebugGroupKHR))load("glPopDebugGroupKHR");
	glObjectLabelKHR = cast(typeof(glObjectLabelKHR))load("glObjectLabelKHR");
	glGetObjectLabelKHR = cast(typeof(glGetObjectLabelKHR))load("glGetObjectLabelKHR");
	glObjectPtrLabelKHR = cast(typeof(glObjectPtrLabelKHR))load("glObjectPtrLabelKHR");
	glGetObjectPtrLabelKHR = cast(typeof(glGetObjectPtrLabelKHR))load("glGetObjectPtrLabelKHR");
	glGetPointervKHR = cast(typeof(glGetPointervKHR))load("glGetPointervKHR");
	return GL_KHR_debug;
}


bool load_gl_GL_SGIS_texture_border_clamp(void* function(string name) load) {
	if(!GL_SGIS_texture_border_clamp) return GL_SGIS_texture_border_clamp;

	return GL_SGIS_texture_border_clamp;
}


bool load_gl_GL_OML_subsample(void* function(string name) load) {
	if(!GL_OML_subsample) return GL_OML_subsample;

	return GL_OML_subsample;
}


bool load_gl_GL_SGIX_clipmap(void* function(string name) load) {
	if(!GL_SGIX_clipmap) return GL_SGIX_clipmap;

	return GL_SGIX_clipmap;
}


bool load_gl_GL_EXT_geometry_shader4(void* function(string name) load) {
	if(!GL_EXT_geometry_shader4) return GL_EXT_geometry_shader4;

	glProgramParameteriEXT = cast(typeof(glProgramParameteriEXT))load("glProgramParameteriEXT");
	return GL_EXT_geometry_shader4;
}


bool load_gl_GL_MESA_ycbcr_texture(void* function(string name) load) {
	if(!GL_MESA_ycbcr_texture) return GL_MESA_ycbcr_texture;

	return GL_MESA_ycbcr_texture;
}


bool load_gl_GL_MESAX_texture_stack(void* function(string name) load) {
	if(!GL_MESAX_texture_stack) return GL_MESAX_texture_stack;

	return GL_MESAX_texture_stack;
}


bool load_gl_GL_AMD_seamless_cubemap_per_texture(void* function(string name) load) {
	if(!GL_AMD_seamless_cubemap_per_texture) return GL_AMD_seamless_cubemap_per_texture;

	return GL_AMD_seamless_cubemap_per_texture;
}


bool load_gl_GL_EXT_bindable_uniform(void* function(string name) load) {
	if(!GL_EXT_bindable_uniform) return GL_EXT_bindable_uniform;

	glUniformBufferEXT = cast(typeof(glUniformBufferEXT))load("glUniformBufferEXT");
	glGetUniformBufferSizeEXT = cast(typeof(glGetUniformBufferSizeEXT))load("glGetUniformBufferSizeEXT");
	glGetUniformOffsetEXT = cast(typeof(glGetUniformOffsetEXT))load("glGetUniformOffsetEXT");
	return GL_EXT_bindable_uniform;
}


bool load_gl_GL_ARB_fragment_program_shadow(void* function(string name) load) {
	if(!GL_ARB_fragment_program_shadow) return GL_ARB_fragment_program_shadow;

	return GL_ARB_fragment_program_shadow;
}


bool load_gl_GL_ATI_element_array(void* function(string name) load) {
	if(!GL_ATI_element_array) return GL_ATI_element_array;

	glElementPointerATI = cast(typeof(glElementPointerATI))load("glElementPointerATI");
	glDrawElementArrayATI = cast(typeof(glDrawElementArrayATI))load("glDrawElementArrayATI");
	glDrawRangeElementArrayATI = cast(typeof(glDrawRangeElementArrayATI))load("glDrawRangeElementArrayATI");
	return GL_ATI_element_array;
}


bool load_gl_GL_AMD_texture_texture4(void* function(string name) load) {
	if(!GL_AMD_texture_texture4) return GL_AMD_texture_texture4;

	return GL_AMD_texture_texture4;
}


bool load_gl_GL_SGIX_reference_plane(void* function(string name) load) {
	if(!GL_SGIX_reference_plane) return GL_SGIX_reference_plane;

	glReferencePlaneSGIX = cast(typeof(glReferencePlaneSGIX))load("glReferencePlaneSGIX");
	return GL_SGIX_reference_plane;
}


bool load_gl_GL_EXT_stencil_two_side(void* function(string name) load) {
	if(!GL_EXT_stencil_two_side) return GL_EXT_stencil_two_side;

	glActiveStencilFaceEXT = cast(typeof(glActiveStencilFaceEXT))load("glActiveStencilFaceEXT");
	return GL_EXT_stencil_two_side;
}


bool load_gl_GL_SGIX_texture_lod_bias(void* function(string name) load) {
	if(!GL_SGIX_texture_lod_bias) return GL_SGIX_texture_lod_bias;

	return GL_SGIX_texture_lod_bias;
}


bool load_gl_GL_NV_explicit_multisample(void* function(string name) load) {
	if(!GL_NV_explicit_multisample) return GL_NV_explicit_multisample;

	glGetMultisamplefvNV = cast(typeof(glGetMultisamplefvNV))load("glGetMultisamplefvNV");
	glSampleMaskIndexedNV = cast(typeof(glSampleMaskIndexedNV))load("glSampleMaskIndexedNV");
	glTexRenderbufferNV = cast(typeof(glTexRenderbufferNV))load("glTexRenderbufferNV");
	return GL_NV_explicit_multisample;
}


bool load_gl_GL_IBM_static_data(void* function(string name) load) {
	if(!GL_IBM_static_data) return GL_IBM_static_data;

	glFlushStaticDataIBM = cast(typeof(glFlushStaticDataIBM))load("glFlushStaticDataIBM");
	return GL_IBM_static_data;
}


bool load_gl_GL_EXT_clip_volume_hint(void* function(string name) load) {
	if(!GL_EXT_clip_volume_hint) return GL_EXT_clip_volume_hint;

	return GL_EXT_clip_volume_hint;
}


bool load_gl_GL_EXT_texture_perturb_normal(void* function(string name) load) {
	if(!GL_EXT_texture_perturb_normal) return GL_EXT_texture_perturb_normal;

	glTextureNormalEXT = cast(typeof(glTextureNormalEXT))load("glTextureNormalEXT");
	return GL_EXT_texture_perturb_normal;
}


bool load_gl_GL_NV_fragment_program2(void* function(string name) load) {
	if(!GL_NV_fragment_program2) return GL_NV_fragment_program2;

	return GL_NV_fragment_program2;
}


bool load_gl_GL_NV_fragment_program4(void* function(string name) load) {
	if(!GL_NV_fragment_program4) return GL_NV_fragment_program4;

	return GL_NV_fragment_program4;
}


bool load_gl_GL_EXT_point_parameters(void* function(string name) load) {
	if(!GL_EXT_point_parameters) return GL_EXT_point_parameters;

	glPointParameterfEXT = cast(typeof(glPointParameterfEXT))load("glPointParameterfEXT");
	glPointParameterfvEXT = cast(typeof(glPointParameterfvEXT))load("glPointParameterfvEXT");
	return GL_EXT_point_parameters;
}


bool load_gl_GL_PGI_misc_hints(void* function(string name) load) {
	if(!GL_PGI_misc_hints) return GL_PGI_misc_hints;

	glHintPGI = cast(typeof(glHintPGI))load("glHintPGI");
	return GL_PGI_misc_hints;
}


bool load_gl_GL_SGIX_subsample(void* function(string name) load) {
	if(!GL_SGIX_subsample) return GL_SGIX_subsample;

	return GL_SGIX_subsample;
}


bool load_gl_GL_AMD_shader_stencil_export(void* function(string name) load) {
	if(!GL_AMD_shader_stencil_export) return GL_AMD_shader_stencil_export;

	return GL_AMD_shader_stencil_export;
}


bool load_gl_GL_ARB_shader_texture_lod(void* function(string name) load) {
	if(!GL_ARB_shader_texture_lod) return GL_ARB_shader_texture_lod;

	return GL_ARB_shader_texture_lod;
}


bool load_gl_GL_ARB_vertex_shader(void* function(string name) load) {
	if(!GL_ARB_vertex_shader) return GL_ARB_vertex_shader;

	glBindAttribLocationARB = cast(typeof(glBindAttribLocationARB))load("glBindAttribLocationARB");
	glGetActiveAttribARB = cast(typeof(glGetActiveAttribARB))load("glGetActiveAttribARB");
	glGetAttribLocationARB = cast(typeof(glGetAttribLocationARB))load("glGetAttribLocationARB");
	return GL_ARB_vertex_shader;
}


bool load_gl_GL_ARB_depth_clamp(void* function(string name) load) {
	if(!GL_ARB_depth_clamp) return GL_ARB_depth_clamp;

	return GL_ARB_depth_clamp;
}


bool load_gl_GL_SGIS_texture_select(void* function(string name) load) {
	if(!GL_SGIS_texture_select) return GL_SGIS_texture_select;

	return GL_SGIS_texture_select;
}


bool load_gl_GL_NV_texture_shader(void* function(string name) load) {
	if(!GL_NV_texture_shader) return GL_NV_texture_shader;

	return GL_NV_texture_shader;
}


bool load_gl_GL_ARB_tessellation_shader(void* function(string name) load) {
	if(!GL_ARB_tessellation_shader) return GL_ARB_tessellation_shader;

	glPatchParameteri = cast(typeof(glPatchParameteri))load("glPatchParameteri");
	glPatchParameterfv = cast(typeof(glPatchParameterfv))load("glPatchParameterfv");
	return GL_ARB_tessellation_shader;
}


bool load_gl_GL_EXT_draw_buffers2(void* function(string name) load) {
	if(!GL_EXT_draw_buffers2) return GL_EXT_draw_buffers2;

	glColorMaskIndexedEXT = cast(typeof(glColorMaskIndexedEXT))load("glColorMaskIndexedEXT");
	glGetBooleanIndexedvEXT = cast(typeof(glGetBooleanIndexedvEXT))load("glGetBooleanIndexedvEXT");
	glGetIntegerIndexedvEXT = cast(typeof(glGetIntegerIndexedvEXT))load("glGetIntegerIndexedvEXT");
	glEnableIndexedEXT = cast(typeof(glEnableIndexedEXT))load("glEnableIndexedEXT");
	glDisableIndexedEXT = cast(typeof(glDisableIndexedEXT))load("glDisableIndexedEXT");
	glIsEnabledIndexedEXT = cast(typeof(glIsEnabledIndexedEXT))load("glIsEnabledIndexedEXT");
	return GL_EXT_draw_buffers2;
}


bool load_gl_GL_ARB_vertex_attrib_64bit(void* function(string name) load) {
	if(!GL_ARB_vertex_attrib_64bit) return GL_ARB_vertex_attrib_64bit;

	glVertexAttribL1d = cast(typeof(glVertexAttribL1d))load("glVertexAttribL1d");
	glVertexAttribL2d = cast(typeof(glVertexAttribL2d))load("glVertexAttribL2d");
	glVertexAttribL3d = cast(typeof(glVertexAttribL3d))load("glVertexAttribL3d");
	glVertexAttribL4d = cast(typeof(glVertexAttribL4d))load("glVertexAttribL4d");
	glVertexAttribL1dv = cast(typeof(glVertexAttribL1dv))load("glVertexAttribL1dv");
	glVertexAttribL2dv = cast(typeof(glVertexAttribL2dv))load("glVertexAttribL2dv");
	glVertexAttribL3dv = cast(typeof(glVertexAttribL3dv))load("glVertexAttribL3dv");
	glVertexAttribL4dv = cast(typeof(glVertexAttribL4dv))load("glVertexAttribL4dv");
	glVertexAttribLPointer = cast(typeof(glVertexAttribLPointer))load("glVertexAttribLPointer");
	glGetVertexAttribLdv = cast(typeof(glGetVertexAttribLdv))load("glGetVertexAttribLdv");
	return GL_ARB_vertex_attrib_64bit;
}


bool load_gl_GL_ARB_texture_gather(void* function(string name) load) {
	if(!GL_ARB_texture_gather) return GL_ARB_texture_gather;

	return GL_ARB_texture_gather;
}


bool load_gl_GL_AMD_interleaved_elements(void* function(string name) load) {
	if(!GL_AMD_interleaved_elements) return GL_AMD_interleaved_elements;

	glVertexAttribParameteriAMD = cast(typeof(glVertexAttribParameteriAMD))load("glVertexAttribParameteriAMD");
	return GL_AMD_interleaved_elements;
}


bool load_gl_GL_ARB_fragment_program(void* function(string name) load) {
	if(!GL_ARB_fragment_program) return GL_ARB_fragment_program;

	glProgramStringARB = cast(typeof(glProgramStringARB))load("glProgramStringARB");
	glBindProgramARB = cast(typeof(glBindProgramARB))load("glBindProgramARB");
	glDeleteProgramsARB = cast(typeof(glDeleteProgramsARB))load("glDeleteProgramsARB");
	glGenProgramsARB = cast(typeof(glGenProgramsARB))load("glGenProgramsARB");
	glProgramEnvParameter4dARB = cast(typeof(glProgramEnvParameter4dARB))load("glProgramEnvParameter4dARB");
	glProgramEnvParameter4dvARB = cast(typeof(glProgramEnvParameter4dvARB))load("glProgramEnvParameter4dvARB");
	glProgramEnvParameter4fARB = cast(typeof(glProgramEnvParameter4fARB))load("glProgramEnvParameter4fARB");
	glProgramEnvParameter4fvARB = cast(typeof(glProgramEnvParameter4fvARB))load("glProgramEnvParameter4fvARB");
	glProgramLocalParameter4dARB = cast(typeof(glProgramLocalParameter4dARB))load("glProgramLocalParameter4dARB");
	glProgramLocalParameter4dvARB = cast(typeof(glProgramLocalParameter4dvARB))load("glProgramLocalParameter4dvARB");
	glProgramLocalParameter4fARB = cast(typeof(glProgramLocalParameter4fARB))load("glProgramLocalParameter4fARB");
	glProgramLocalParameter4fvARB = cast(typeof(glProgramLocalParameter4fvARB))load("glProgramLocalParameter4fvARB");
	glGetProgramEnvParameterdvARB = cast(typeof(glGetProgramEnvParameterdvARB))load("glGetProgramEnvParameterdvARB");
	glGetProgramEnvParameterfvARB = cast(typeof(glGetProgramEnvParameterfvARB))load("glGetProgramEnvParameterfvARB");
	glGetProgramLocalParameterdvARB = cast(typeof(glGetProgramLocalParameterdvARB))load("glGetProgramLocalParameterdvARB");
	glGetProgramLocalParameterfvARB = cast(typeof(glGetProgramLocalParameterfvARB))load("glGetProgramLocalParameterfvARB");
	glGetProgramivARB = cast(typeof(glGetProgramivARB))load("glGetProgramivARB");
	glGetProgramStringARB = cast(typeof(glGetProgramStringARB))load("glGetProgramStringARB");
	glIsProgramARB = cast(typeof(glIsProgramARB))load("glIsProgramARB");
	return GL_ARB_fragment_program;
}


bool load_gl_GL_OML_resample(void* function(string name) load) {
	if(!GL_OML_resample) return GL_OML_resample;

	return GL_OML_resample;
}


bool load_gl_GL_APPLE_ycbcr_422(void* function(string name) load) {
	if(!GL_APPLE_ycbcr_422) return GL_APPLE_ycbcr_422;

	return GL_APPLE_ycbcr_422;
}


bool load_gl_GL_SGIX_texture_add_env(void* function(string name) load) {
	if(!GL_SGIX_texture_add_env) return GL_SGIX_texture_add_env;

	return GL_SGIX_texture_add_env;
}


bool load_gl_GL_ARB_shadow_ambient(void* function(string name) load) {
	if(!GL_ARB_shadow_ambient) return GL_ARB_shadow_ambient;

	return GL_ARB_shadow_ambient;
}


bool load_gl_GL_ARB_texture_storage(void* function(string name) load) {
	if(!GL_ARB_texture_storage) return GL_ARB_texture_storage;

	glTexStorage1D = cast(typeof(glTexStorage1D))load("glTexStorage1D");
	glTexStorage2D = cast(typeof(glTexStorage2D))load("glTexStorage2D");
	glTexStorage3D = cast(typeof(glTexStorage3D))load("glTexStorage3D");
	return GL_ARB_texture_storage;
}


bool load_gl_GL_EXT_pixel_buffer_object(void* function(string name) load) {
	if(!GL_EXT_pixel_buffer_object) return GL_EXT_pixel_buffer_object;

	return GL_EXT_pixel_buffer_object;
}


bool load_gl_GL_NV_vertex_program(void* function(string name) load) {
	if(!GL_NV_vertex_program) return GL_NV_vertex_program;

	glAreProgramsResidentNV = cast(typeof(glAreProgramsResidentNV))load("glAreProgramsResidentNV");
	glBindProgramNV = cast(typeof(glBindProgramNV))load("glBindProgramNV");
	glDeleteProgramsNV = cast(typeof(glDeleteProgramsNV))load("glDeleteProgramsNV");
	glExecuteProgramNV = cast(typeof(glExecuteProgramNV))load("glExecuteProgramNV");
	glGenProgramsNV = cast(typeof(glGenProgramsNV))load("glGenProgramsNV");
	glGetProgramParameterdvNV = cast(typeof(glGetProgramParameterdvNV))load("glGetProgramParameterdvNV");
	glGetProgramParameterfvNV = cast(typeof(glGetProgramParameterfvNV))load("glGetProgramParameterfvNV");
	glGetProgramivNV = cast(typeof(glGetProgramivNV))load("glGetProgramivNV");
	glGetProgramStringNV = cast(typeof(glGetProgramStringNV))load("glGetProgramStringNV");
	glGetTrackMatrixivNV = cast(typeof(glGetTrackMatrixivNV))load("glGetTrackMatrixivNV");
	glGetVertexAttribdvNV = cast(typeof(glGetVertexAttribdvNV))load("glGetVertexAttribdvNV");
	glGetVertexAttribfvNV = cast(typeof(glGetVertexAttribfvNV))load("glGetVertexAttribfvNV");
	glGetVertexAttribivNV = cast(typeof(glGetVertexAttribivNV))load("glGetVertexAttribivNV");
	glGetVertexAttribPointervNV = cast(typeof(glGetVertexAttribPointervNV))load("glGetVertexAttribPointervNV");
	glIsProgramNV = cast(typeof(glIsProgramNV))load("glIsProgramNV");
	glLoadProgramNV = cast(typeof(glLoadProgramNV))load("glLoadProgramNV");
	glProgramParameter4dNV = cast(typeof(glProgramParameter4dNV))load("glProgramParameter4dNV");
	glProgramParameter4dvNV = cast(typeof(glProgramParameter4dvNV))load("glProgramParameter4dvNV");
	glProgramParameter4fNV = cast(typeof(glProgramParameter4fNV))load("glProgramParameter4fNV");
	glProgramParameter4fvNV = cast(typeof(glProgramParameter4fvNV))load("glProgramParameter4fvNV");
	glProgramParameters4dvNV = cast(typeof(glProgramParameters4dvNV))load("glProgramParameters4dvNV");
	glProgramParameters4fvNV = cast(typeof(glProgramParameters4fvNV))load("glProgramParameters4fvNV");
	glRequestResidentProgramsNV = cast(typeof(glRequestResidentProgramsNV))load("glRequestResidentProgramsNV");
	glTrackMatrixNV = cast(typeof(glTrackMatrixNV))load("glTrackMatrixNV");
	glVertexAttribPointerNV = cast(typeof(glVertexAttribPointerNV))load("glVertexAttribPointerNV");
	glVertexAttrib1dNV = cast(typeof(glVertexAttrib1dNV))load("glVertexAttrib1dNV");
	glVertexAttrib1dvNV = cast(typeof(glVertexAttrib1dvNV))load("glVertexAttrib1dvNV");
	glVertexAttrib1fNV = cast(typeof(glVertexAttrib1fNV))load("glVertexAttrib1fNV");
	glVertexAttrib1fvNV = cast(typeof(glVertexAttrib1fvNV))load("glVertexAttrib1fvNV");
	glVertexAttrib1sNV = cast(typeof(glVertexAttrib1sNV))load("glVertexAttrib1sNV");
	glVertexAttrib1svNV = cast(typeof(glVertexAttrib1svNV))load("glVertexAttrib1svNV");
	glVertexAttrib2dNV = cast(typeof(glVertexAttrib2dNV))load("glVertexAttrib2dNV");
	glVertexAttrib2dvNV = cast(typeof(glVertexAttrib2dvNV))load("glVertexAttrib2dvNV");
	glVertexAttrib2fNV = cast(typeof(glVertexAttrib2fNV))load("glVertexAttrib2fNV");
	glVertexAttrib2fvNV = cast(typeof(glVertexAttrib2fvNV))load("glVertexAttrib2fvNV");
	glVertexAttrib2sNV = cast(typeof(glVertexAttrib2sNV))load("glVertexAttrib2sNV");
	glVertexAttrib2svNV = cast(typeof(glVertexAttrib2svNV))load("glVertexAttrib2svNV");
	glVertexAttrib3dNV = cast(typeof(glVertexAttrib3dNV))load("glVertexAttrib3dNV");
	glVertexAttrib3dvNV = cast(typeof(glVertexAttrib3dvNV))load("glVertexAttrib3dvNV");
	glVertexAttrib3fNV = cast(typeof(glVertexAttrib3fNV))load("glVertexAttrib3fNV");
	glVertexAttrib3fvNV = cast(typeof(glVertexAttrib3fvNV))load("glVertexAttrib3fvNV");
	glVertexAttrib3sNV = cast(typeof(glVertexAttrib3sNV))load("glVertexAttrib3sNV");
	glVertexAttrib3svNV = cast(typeof(glVertexAttrib3svNV))load("glVertexAttrib3svNV");
	glVertexAttrib4dNV = cast(typeof(glVertexAttrib4dNV))load("glVertexAttrib4dNV");
	glVertexAttrib4dvNV = cast(typeof(glVertexAttrib4dvNV))load("glVertexAttrib4dvNV");
	glVertexAttrib4fNV = cast(typeof(glVertexAttrib4fNV))load("glVertexAttrib4fNV");
	glVertexAttrib4fvNV = cast(typeof(glVertexAttrib4fvNV))load("glVertexAttrib4fvNV");
	glVertexAttrib4sNV = cast(typeof(glVertexAttrib4sNV))load("glVertexAttrib4sNV");
	glVertexAttrib4svNV = cast(typeof(glVertexAttrib4svNV))load("glVertexAttrib4svNV");
	glVertexAttrib4ubNV = cast(typeof(glVertexAttrib4ubNV))load("glVertexAttrib4ubNV");
	glVertexAttrib4ubvNV = cast(typeof(glVertexAttrib4ubvNV))load("glVertexAttrib4ubvNV");
	glVertexAttribs1dvNV = cast(typeof(glVertexAttribs1dvNV))load("glVertexAttribs1dvNV");
	glVertexAttribs1fvNV = cast(typeof(glVertexAttribs1fvNV))load("glVertexAttribs1fvNV");
	glVertexAttribs1svNV = cast(typeof(glVertexAttribs1svNV))load("glVertexAttribs1svNV");
	glVertexAttribs2dvNV = cast(typeof(glVertexAttribs2dvNV))load("glVertexAttribs2dvNV");
	glVertexAttribs2fvNV = cast(typeof(glVertexAttribs2fvNV))load("glVertexAttribs2fvNV");
	glVertexAttribs2svNV = cast(typeof(glVertexAttribs2svNV))load("glVertexAttribs2svNV");
	glVertexAttribs3dvNV = cast(typeof(glVertexAttribs3dvNV))load("glVertexAttribs3dvNV");
	glVertexAttribs3fvNV = cast(typeof(glVertexAttribs3fvNV))load("glVertexAttribs3fvNV");
	glVertexAttribs3svNV = cast(typeof(glVertexAttribs3svNV))load("glVertexAttribs3svNV");
	glVertexAttribs4dvNV = cast(typeof(glVertexAttribs4dvNV))load("glVertexAttribs4dvNV");
	glVertexAttribs4fvNV = cast(typeof(glVertexAttribs4fvNV))load("glVertexAttribs4fvNV");
	glVertexAttribs4svNV = cast(typeof(glVertexAttribs4svNV))load("glVertexAttribs4svNV");
	glVertexAttribs4ubvNV = cast(typeof(glVertexAttribs4ubvNV))load("glVertexAttribs4ubvNV");
	return GL_NV_vertex_program;
}


bool load_gl_GL_SGIS_pixel_texture(void* function(string name) load) {
	if(!GL_SGIS_pixel_texture) return GL_SGIS_pixel_texture;

	glPixelTexGenParameteriSGIS = cast(typeof(glPixelTexGenParameteriSGIS))load("glPixelTexGenParameteriSGIS");
	glPixelTexGenParameterivSGIS = cast(typeof(glPixelTexGenParameterivSGIS))load("glPixelTexGenParameterivSGIS");
	glPixelTexGenParameterfSGIS = cast(typeof(glPixelTexGenParameterfSGIS))load("glPixelTexGenParameterfSGIS");
	glPixelTexGenParameterfvSGIS = cast(typeof(glPixelTexGenParameterfvSGIS))load("glPixelTexGenParameterfvSGIS");
	glGetPixelTexGenParameterivSGIS = cast(typeof(glGetPixelTexGenParameterivSGIS))load("glGetPixelTexGenParameterivSGIS");
	glGetPixelTexGenParameterfvSGIS = cast(typeof(glGetPixelTexGenParameterfvSGIS))load("glGetPixelTexGenParameterfvSGIS");
	return GL_SGIS_pixel_texture;
}


bool load_gl_GL_SGIS_generate_mipmap(void* function(string name) load) {
	if(!GL_SGIS_generate_mipmap) return GL_SGIS_generate_mipmap;

	return GL_SGIS_generate_mipmap;
}


bool load_gl_GL_SGIX_instruments(void* function(string name) load) {
	if(!GL_SGIX_instruments) return GL_SGIX_instruments;

	glGetInstrumentsSGIX = cast(typeof(glGetInstrumentsSGIX))load("glGetInstrumentsSGIX");
	glInstrumentsBufferSGIX = cast(typeof(glInstrumentsBufferSGIX))load("glInstrumentsBufferSGIX");
	glPollInstrumentsSGIX = cast(typeof(glPollInstrumentsSGIX))load("glPollInstrumentsSGIX");
	glReadInstrumentsSGIX = cast(typeof(glReadInstrumentsSGIX))load("glReadInstrumentsSGIX");
	glStartInstrumentsSGIX = cast(typeof(glStartInstrumentsSGIX))load("glStartInstrumentsSGIX");
	glStopInstrumentsSGIX = cast(typeof(glStopInstrumentsSGIX))load("glStopInstrumentsSGIX");
	return GL_SGIX_instruments;
}


bool load_gl_GL_ARB_fragment_layer_viewport(void* function(string name) load) {
	if(!GL_ARB_fragment_layer_viewport) return GL_ARB_fragment_layer_viewport;

	return GL_ARB_fragment_layer_viewport;
}


bool load_gl_GL_ARB_shader_storage_buffer_object(void* function(string name) load) {
	if(!GL_ARB_shader_storage_buffer_object) return GL_ARB_shader_storage_buffer_object;

	glShaderStorageBlockBinding = cast(typeof(glShaderStorageBlockBinding))load("glShaderStorageBlockBinding");
	return GL_ARB_shader_storage_buffer_object;
}


bool load_gl_GL_EXT_blend_minmax(void* function(string name) load) {
	if(!GL_EXT_blend_minmax) return GL_EXT_blend_minmax;

	glBlendEquationEXT = cast(typeof(glBlendEquationEXT))load("glBlendEquationEXT");
	return GL_EXT_blend_minmax;
}


bool load_gl_GL_MESA_pack_invert(void* function(string name) load) {
	if(!GL_MESA_pack_invert) return GL_MESA_pack_invert;

	return GL_MESA_pack_invert;
}


bool load_gl_GL_ARB_base_instance(void* function(string name) load) {
	if(!GL_ARB_base_instance) return GL_ARB_base_instance;

	glDrawArraysInstancedBaseInstance = cast(typeof(glDrawArraysInstancedBaseInstance))load("glDrawArraysInstancedBaseInstance");
	glDrawElementsInstancedBaseInstance = cast(typeof(glDrawElementsInstancedBaseInstance))load("glDrawElementsInstancedBaseInstance");
	glDrawElementsInstancedBaseVertexBaseInstance = cast(typeof(glDrawElementsInstancedBaseVertexBaseInstance))load("glDrawElementsInstancedBaseVertexBaseInstance");
	return GL_ARB_base_instance;
}


bool load_gl_GL_SUN_global_alpha(void* function(string name) load) {
	if(!GL_SUN_global_alpha) return GL_SUN_global_alpha;

	glGlobalAlphaFactorbSUN = cast(typeof(glGlobalAlphaFactorbSUN))load("glGlobalAlphaFactorbSUN");
	glGlobalAlphaFactorsSUN = cast(typeof(glGlobalAlphaFactorsSUN))load("glGlobalAlphaFactorsSUN");
	glGlobalAlphaFactoriSUN = cast(typeof(glGlobalAlphaFactoriSUN))load("glGlobalAlphaFactoriSUN");
	glGlobalAlphaFactorfSUN = cast(typeof(glGlobalAlphaFactorfSUN))load("glGlobalAlphaFactorfSUN");
	glGlobalAlphaFactordSUN = cast(typeof(glGlobalAlphaFactordSUN))load("glGlobalAlphaFactordSUN");
	glGlobalAlphaFactorubSUN = cast(typeof(glGlobalAlphaFactorubSUN))load("glGlobalAlphaFactorubSUN");
	glGlobalAlphaFactorusSUN = cast(typeof(glGlobalAlphaFactorusSUN))load("glGlobalAlphaFactorusSUN");
	glGlobalAlphaFactoruiSUN = cast(typeof(glGlobalAlphaFactoruiSUN))load("glGlobalAlphaFactoruiSUN");
	return GL_SUN_global_alpha;
}


bool load_gl_GL_PGI_vertex_hints(void* function(string name) load) {
	if(!GL_PGI_vertex_hints) return GL_PGI_vertex_hints;

	return GL_PGI_vertex_hints;
}


bool load_gl_GL_EXT_texture_integer(void* function(string name) load) {
	if(!GL_EXT_texture_integer) return GL_EXT_texture_integer;

	glTexParameterIivEXT = cast(typeof(glTexParameterIivEXT))load("glTexParameterIivEXT");
	glTexParameterIuivEXT = cast(typeof(glTexParameterIuivEXT))load("glTexParameterIuivEXT");
	glGetTexParameterIivEXT = cast(typeof(glGetTexParameterIivEXT))load("glGetTexParameterIivEXT");
	glGetTexParameterIuivEXT = cast(typeof(glGetTexParameterIuivEXT))load("glGetTexParameterIuivEXT");
	glClearColorIiEXT = cast(typeof(glClearColorIiEXT))load("glClearColorIiEXT");
	glClearColorIuiEXT = cast(typeof(glClearColorIuiEXT))load("glClearColorIuiEXT");
	return GL_EXT_texture_integer;
}


bool load_gl_GL_ARB_texture_multisample(void* function(string name) load) {
	if(!GL_ARB_texture_multisample) return GL_ARB_texture_multisample;

	glTexImage2DMultisample = cast(typeof(glTexImage2DMultisample))load("glTexImage2DMultisample");
	glTexImage3DMultisample = cast(typeof(glTexImage3DMultisample))load("glTexImage3DMultisample");
	glGetMultisamplefv = cast(typeof(glGetMultisamplefv))load("glGetMultisamplefv");
	glSampleMaski = cast(typeof(glSampleMaski))load("glSampleMaski");
	return GL_ARB_texture_multisample;
}


bool load_gl_GL_S3_s3tc(void* function(string name) load) {
	if(!GL_S3_s3tc) return GL_S3_s3tc;

	return GL_S3_s3tc;
}


bool load_gl_GL_ARB_query_buffer_object(void* function(string name) load) {
	if(!GL_ARB_query_buffer_object) return GL_ARB_query_buffer_object;

	return GL_ARB_query_buffer_object;
}


bool load_gl_GL_AMD_vertex_shader_tessellator(void* function(string name) load) {
	if(!GL_AMD_vertex_shader_tessellator) return GL_AMD_vertex_shader_tessellator;

	glTessellationFactorAMD = cast(typeof(glTessellationFactorAMD))load("glTessellationFactorAMD");
	glTessellationModeAMD = cast(typeof(glTessellationModeAMD))load("glTessellationModeAMD");
	return GL_AMD_vertex_shader_tessellator;
}


bool load_gl_GL_ARB_invalidate_subdata(void* function(string name) load) {
	if(!GL_ARB_invalidate_subdata) return GL_ARB_invalidate_subdata;

	glInvalidateTexSubImage = cast(typeof(glInvalidateTexSubImage))load("glInvalidateTexSubImage");
	glInvalidateTexImage = cast(typeof(glInvalidateTexImage))load("glInvalidateTexImage");
	glInvalidateBufferSubData = cast(typeof(glInvalidateBufferSubData))load("glInvalidateBufferSubData");
	glInvalidateBufferData = cast(typeof(glInvalidateBufferData))load("glInvalidateBufferData");
	glInvalidateFramebuffer = cast(typeof(glInvalidateFramebuffer))load("glInvalidateFramebuffer");
	glInvalidateSubFramebuffer = cast(typeof(glInvalidateSubFramebuffer))load("glInvalidateSubFramebuffer");
	return GL_ARB_invalidate_subdata;
}


bool load_gl_GL_ARB_transform_feedback2(void* function(string name) load) {
	if(!GL_ARB_transform_feedback2) return GL_ARB_transform_feedback2;

	glBindTransformFeedback = cast(typeof(glBindTransformFeedback))load("glBindTransformFeedback");
	glDeleteTransformFeedbacks = cast(typeof(glDeleteTransformFeedbacks))load("glDeleteTransformFeedbacks");
	glGenTransformFeedbacks = cast(typeof(glGenTransformFeedbacks))load("glGenTransformFeedbacks");
	glIsTransformFeedback = cast(typeof(glIsTransformFeedback))load("glIsTransformFeedback");
	glPauseTransformFeedback = cast(typeof(glPauseTransformFeedback))load("glPauseTransformFeedback");
	glResumeTransformFeedback = cast(typeof(glResumeTransformFeedback))load("glResumeTransformFeedback");
	glDrawTransformFeedback = cast(typeof(glDrawTransformFeedback))load("glDrawTransformFeedback");
	return GL_ARB_transform_feedback2;
}


bool load_gl_GL_EXT_index_material(void* function(string name) load) {
	if(!GL_EXT_index_material) return GL_EXT_index_material;

	glIndexMaterialEXT = cast(typeof(glIndexMaterialEXT))load("glIndexMaterialEXT");
	return GL_EXT_index_material;
}


bool load_gl_GL_NV_blend_equation_advanced_coherent(void* function(string name) load) {
	if(!GL_NV_blend_equation_advanced_coherent) return GL_NV_blend_equation_advanced_coherent;

	return GL_NV_blend_equation_advanced_coherent;
}


bool load_gl_GL_ARB_texture_non_power_of_two(void* function(string name) load) {
	if(!GL_ARB_texture_non_power_of_two) return GL_ARB_texture_non_power_of_two;

	return GL_ARB_texture_non_power_of_two;
}


bool load_gl_GL_ATI_draw_buffers(void* function(string name) load) {
	if(!GL_ATI_draw_buffers) return GL_ATI_draw_buffers;

	glDrawBuffersATI = cast(typeof(glDrawBuffersATI))load("glDrawBuffersATI");
	return GL_ATI_draw_buffers;
}


bool load_gl_GL_EXT_cmyka(void* function(string name) load) {
	if(!GL_EXT_cmyka) return GL_EXT_cmyka;

	return GL_EXT_cmyka;
}


bool load_gl_GL_SGIX_pixel_texture(void* function(string name) load) {
	if(!GL_SGIX_pixel_texture) return GL_SGIX_pixel_texture;

	glPixelTexGenSGIX = cast(typeof(glPixelTexGenSGIX))load("glPixelTexGenSGIX");
	return GL_SGIX_pixel_texture;
}


bool load_gl_GL_NV_occlusion_query(void* function(string name) load) {
	if(!GL_NV_occlusion_query) return GL_NV_occlusion_query;

	glGenOcclusionQueriesNV = cast(typeof(glGenOcclusionQueriesNV))load("glGenOcclusionQueriesNV");
	glDeleteOcclusionQueriesNV = cast(typeof(glDeleteOcclusionQueriesNV))load("glDeleteOcclusionQueriesNV");
	glIsOcclusionQueryNV = cast(typeof(glIsOcclusionQueryNV))load("glIsOcclusionQueryNV");
	glBeginOcclusionQueryNV = cast(typeof(glBeginOcclusionQueryNV))load("glBeginOcclusionQueryNV");
	glEndOcclusionQueryNV = cast(typeof(glEndOcclusionQueryNV))load("glEndOcclusionQueryNV");
	glGetOcclusionQueryivNV = cast(typeof(glGetOcclusionQueryivNV))load("glGetOcclusionQueryivNV");
	glGetOcclusionQueryuivNV = cast(typeof(glGetOcclusionQueryuivNV))load("glGetOcclusionQueryuivNV");
	return GL_NV_occlusion_query;
}


bool load_gl_GL_ARB_seamless_cubemap_per_texture(void* function(string name) load) {
	if(!GL_ARB_seamless_cubemap_per_texture) return GL_ARB_seamless_cubemap_per_texture;

	return GL_ARB_seamless_cubemap_per_texture;
}


bool load_gl_GL_ARB_conservative_depth(void* function(string name) load) {
	if(!GL_ARB_conservative_depth) return GL_ARB_conservative_depth;

	return GL_ARB_conservative_depth;
}


bool load_gl_GL_SGIX_interlace(void* function(string name) load) {
	if(!GL_SGIX_interlace) return GL_SGIX_interlace;

	return GL_SGIX_interlace;
}


bool load_gl_GL_NV_parameter_buffer_object(void* function(string name) load) {
	if(!GL_NV_parameter_buffer_object) return GL_NV_parameter_buffer_object;

	glProgramBufferParametersfvNV = cast(typeof(glProgramBufferParametersfvNV))load("glProgramBufferParametersfvNV");
	glProgramBufferParametersIivNV = cast(typeof(glProgramBufferParametersIivNV))load("glProgramBufferParametersIivNV");
	glProgramBufferParametersIuivNV = cast(typeof(glProgramBufferParametersIuivNV))load("glProgramBufferParametersIuivNV");
	return GL_NV_parameter_buffer_object;
}


bool load_gl_GL_AMD_shader_trinary_minmax(void* function(string name) load) {
	if(!GL_AMD_shader_trinary_minmax) return GL_AMD_shader_trinary_minmax;

	return GL_AMD_shader_trinary_minmax;
}


bool load_gl_GL_EXT_rescale_normal(void* function(string name) load) {
	if(!GL_EXT_rescale_normal) return GL_EXT_rescale_normal;

	return GL_EXT_rescale_normal;
}


bool load_gl_GL_ARB_pixel_buffer_object(void* function(string name) load) {
	if(!GL_ARB_pixel_buffer_object) return GL_ARB_pixel_buffer_object;

	return GL_ARB_pixel_buffer_object;
}


bool load_gl_GL_ARB_uniform_buffer_object(void* function(string name) load) {
	if(!GL_ARB_uniform_buffer_object) return GL_ARB_uniform_buffer_object;

	glGetUniformIndices = cast(typeof(glGetUniformIndices))load("glGetUniformIndices");
	glGetActiveUniformsiv = cast(typeof(glGetActiveUniformsiv))load("glGetActiveUniformsiv");
	glGetActiveUniformName = cast(typeof(glGetActiveUniformName))load("glGetActiveUniformName");
	glGetUniformBlockIndex = cast(typeof(glGetUniformBlockIndex))load("glGetUniformBlockIndex");
	glGetActiveUniformBlockiv = cast(typeof(glGetActiveUniformBlockiv))load("glGetActiveUniformBlockiv");
	glGetActiveUniformBlockName = cast(typeof(glGetActiveUniformBlockName))load("glGetActiveUniformBlockName");
	glUniformBlockBinding = cast(typeof(glUniformBlockBinding))load("glUniformBlockBinding");
	return GL_ARB_uniform_buffer_object;
}


bool load_gl_GL_ARB_vertex_type_10f_11f_11f_rev(void* function(string name) load) {
	if(!GL_ARB_vertex_type_10f_11f_11f_rev) return GL_ARB_vertex_type_10f_11f_11f_rev;

	return GL_ARB_vertex_type_10f_11f_11f_rev;
}


bool load_gl_GL_ARB_texture_swizzle(void* function(string name) load) {
	if(!GL_ARB_texture_swizzle) return GL_ARB_texture_swizzle;

	return GL_ARB_texture_swizzle;
}


bool load_gl_GL_ARB_texture_compression(void* function(string name) load) {
	if(!GL_ARB_texture_compression) return GL_ARB_texture_compression;

	glCompressedTexImage3DARB = cast(typeof(glCompressedTexImage3DARB))load("glCompressedTexImage3DARB");
	glCompressedTexImage2DARB = cast(typeof(glCompressedTexImage2DARB))load("glCompressedTexImage2DARB");
	glCompressedTexImage1DARB = cast(typeof(glCompressedTexImage1DARB))load("glCompressedTexImage1DARB");
	glCompressedTexSubImage3DARB = cast(typeof(glCompressedTexSubImage3DARB))load("glCompressedTexSubImage3DARB");
	glCompressedTexSubImage2DARB = cast(typeof(glCompressedTexSubImage2DARB))load("glCompressedTexSubImage2DARB");
	glCompressedTexSubImage1DARB = cast(typeof(glCompressedTexSubImage1DARB))load("glCompressedTexSubImage1DARB");
	glGetCompressedTexImageARB = cast(typeof(glGetCompressedTexImageARB))load("glGetCompressedTexImageARB");
	return GL_ARB_texture_compression;
}


bool load_gl_GL_SGIX_async_pixel(void* function(string name) load) {
	if(!GL_SGIX_async_pixel) return GL_SGIX_async_pixel;

	return GL_SGIX_async_pixel;
}


bool load_gl_GL_NV_fragment_program_option(void* function(string name) load) {
	if(!GL_NV_fragment_program_option) return GL_NV_fragment_program_option;

	return GL_NV_fragment_program_option;
}


bool load_gl_GL_ARB_explicit_attrib_location(void* function(string name) load) {
	if(!GL_ARB_explicit_attrib_location) return GL_ARB_explicit_attrib_location;

	return GL_ARB_explicit_attrib_location;
}


bool load_gl_GL_EXT_blend_color(void* function(string name) load) {
	if(!GL_EXT_blend_color) return GL_EXT_blend_color;

	glBlendColorEXT = cast(typeof(glBlendColorEXT))load("glBlendColorEXT");
	return GL_EXT_blend_color;
}


bool load_gl_GL_EXT_stencil_wrap(void* function(string name) load) {
	if(!GL_EXT_stencil_wrap) return GL_EXT_stencil_wrap;

	return GL_EXT_stencil_wrap;
}


bool load_gl_GL_EXT_index_array_formats(void* function(string name) load) {
	if(!GL_EXT_index_array_formats) return GL_EXT_index_array_formats;

	return GL_EXT_index_array_formats;
}


bool load_gl_GL_EXT_histogram(void* function(string name) load) {
	if(!GL_EXT_histogram) return GL_EXT_histogram;

	glGetHistogramEXT = cast(typeof(glGetHistogramEXT))load("glGetHistogramEXT");
	glGetHistogramParameterfvEXT = cast(typeof(glGetHistogramParameterfvEXT))load("glGetHistogramParameterfvEXT");
	glGetHistogramParameterivEXT = cast(typeof(glGetHistogramParameterivEXT))load("glGetHistogramParameterivEXT");
	glGetMinmaxEXT = cast(typeof(glGetMinmaxEXT))load("glGetMinmaxEXT");
	glGetMinmaxParameterfvEXT = cast(typeof(glGetMinmaxParameterfvEXT))load("glGetMinmaxParameterfvEXT");
	glGetMinmaxParameterivEXT = cast(typeof(glGetMinmaxParameterivEXT))load("glGetMinmaxParameterivEXT");
	glHistogramEXT = cast(typeof(glHistogramEXT))load("glHistogramEXT");
	glMinmaxEXT = cast(typeof(glMinmaxEXT))load("glMinmaxEXT");
	glResetHistogramEXT = cast(typeof(glResetHistogramEXT))load("glResetHistogramEXT");
	glResetMinmaxEXT = cast(typeof(glResetMinmaxEXT))load("glResetMinmaxEXT");
	return GL_EXT_histogram;
}


bool load_gl_GL_SGIS_point_parameters(void* function(string name) load) {
	if(!GL_SGIS_point_parameters) return GL_SGIS_point_parameters;

	glPointParameterfSGIS = cast(typeof(glPointParameterfSGIS))load("glPointParameterfSGIS");
	glPointParameterfvSGIS = cast(typeof(glPointParameterfvSGIS))load("glPointParameterfvSGIS");
	return GL_SGIS_point_parameters;
}


bool load_gl_GL_EXT_direct_state_access(void* function(string name) load) {
	if(!GL_EXT_direct_state_access) return GL_EXT_direct_state_access;

	glMatrixLoadfEXT = cast(typeof(glMatrixLoadfEXT))load("glMatrixLoadfEXT");
	glMatrixLoaddEXT = cast(typeof(glMatrixLoaddEXT))load("glMatrixLoaddEXT");
	glMatrixMultfEXT = cast(typeof(glMatrixMultfEXT))load("glMatrixMultfEXT");
	glMatrixMultdEXT = cast(typeof(glMatrixMultdEXT))load("glMatrixMultdEXT");
	glMatrixLoadIdentityEXT = cast(typeof(glMatrixLoadIdentityEXT))load("glMatrixLoadIdentityEXT");
	glMatrixRotatefEXT = cast(typeof(glMatrixRotatefEXT))load("glMatrixRotatefEXT");
	glMatrixRotatedEXT = cast(typeof(glMatrixRotatedEXT))load("glMatrixRotatedEXT");
	glMatrixScalefEXT = cast(typeof(glMatrixScalefEXT))load("glMatrixScalefEXT");
	glMatrixScaledEXT = cast(typeof(glMatrixScaledEXT))load("glMatrixScaledEXT");
	glMatrixTranslatefEXT = cast(typeof(glMatrixTranslatefEXT))load("glMatrixTranslatefEXT");
	glMatrixTranslatedEXT = cast(typeof(glMatrixTranslatedEXT))load("glMatrixTranslatedEXT");
	glMatrixFrustumEXT = cast(typeof(glMatrixFrustumEXT))load("glMatrixFrustumEXT");
	glMatrixOrthoEXT = cast(typeof(glMatrixOrthoEXT))load("glMatrixOrthoEXT");
	glMatrixPopEXT = cast(typeof(glMatrixPopEXT))load("glMatrixPopEXT");
	glMatrixPushEXT = cast(typeof(glMatrixPushEXT))load("glMatrixPushEXT");
	glClientAttribDefaultEXT = cast(typeof(glClientAttribDefaultEXT))load("glClientAttribDefaultEXT");
	glPushClientAttribDefaultEXT = cast(typeof(glPushClientAttribDefaultEXT))load("glPushClientAttribDefaultEXT");
	glTextureParameterfEXT = cast(typeof(glTextureParameterfEXT))load("glTextureParameterfEXT");
	glTextureParameterfvEXT = cast(typeof(glTextureParameterfvEXT))load("glTextureParameterfvEXT");
	glTextureParameteriEXT = cast(typeof(glTextureParameteriEXT))load("glTextureParameteriEXT");
	glTextureParameterivEXT = cast(typeof(glTextureParameterivEXT))load("glTextureParameterivEXT");
	glTextureImage1DEXT = cast(typeof(glTextureImage1DEXT))load("glTextureImage1DEXT");
	glTextureImage2DEXT = cast(typeof(glTextureImage2DEXT))load("glTextureImage2DEXT");
	glTextureSubImage1DEXT = cast(typeof(glTextureSubImage1DEXT))load("glTextureSubImage1DEXT");
	glTextureSubImage2DEXT = cast(typeof(glTextureSubImage2DEXT))load("glTextureSubImage2DEXT");
	glCopyTextureImage1DEXT = cast(typeof(glCopyTextureImage1DEXT))load("glCopyTextureImage1DEXT");
	glCopyTextureImage2DEXT = cast(typeof(glCopyTextureImage2DEXT))load("glCopyTextureImage2DEXT");
	glCopyTextureSubImage1DEXT = cast(typeof(glCopyTextureSubImage1DEXT))load("glCopyTextureSubImage1DEXT");
	glCopyTextureSubImage2DEXT = cast(typeof(glCopyTextureSubImage2DEXT))load("glCopyTextureSubImage2DEXT");
	glGetTextureImageEXT = cast(typeof(glGetTextureImageEXT))load("glGetTextureImageEXT");
	glGetTextureParameterfvEXT = cast(typeof(glGetTextureParameterfvEXT))load("glGetTextureParameterfvEXT");
	glGetTextureParameterivEXT = cast(typeof(glGetTextureParameterivEXT))load("glGetTextureParameterivEXT");
	glGetTextureLevelParameterfvEXT = cast(typeof(glGetTextureLevelParameterfvEXT))load("glGetTextureLevelParameterfvEXT");
	glGetTextureLevelParameterivEXT = cast(typeof(glGetTextureLevelParameterivEXT))load("glGetTextureLevelParameterivEXT");
	glTextureImage3DEXT = cast(typeof(glTextureImage3DEXT))load("glTextureImage3DEXT");
	glTextureSubImage3DEXT = cast(typeof(glTextureSubImage3DEXT))load("glTextureSubImage3DEXT");
	glCopyTextureSubImage3DEXT = cast(typeof(glCopyTextureSubImage3DEXT))load("glCopyTextureSubImage3DEXT");
	glBindMultiTextureEXT = cast(typeof(glBindMultiTextureEXT))load("glBindMultiTextureEXT");
	glMultiTexCoordPointerEXT = cast(typeof(glMultiTexCoordPointerEXT))load("glMultiTexCoordPointerEXT");
	glMultiTexEnvfEXT = cast(typeof(glMultiTexEnvfEXT))load("glMultiTexEnvfEXT");
	glMultiTexEnvfvEXT = cast(typeof(glMultiTexEnvfvEXT))load("glMultiTexEnvfvEXT");
	glMultiTexEnviEXT = cast(typeof(glMultiTexEnviEXT))load("glMultiTexEnviEXT");
	glMultiTexEnvivEXT = cast(typeof(glMultiTexEnvivEXT))load("glMultiTexEnvivEXT");
	glMultiTexGendEXT = cast(typeof(glMultiTexGendEXT))load("glMultiTexGendEXT");
	glMultiTexGendvEXT = cast(typeof(glMultiTexGendvEXT))load("glMultiTexGendvEXT");
	glMultiTexGenfEXT = cast(typeof(glMultiTexGenfEXT))load("glMultiTexGenfEXT");
	glMultiTexGenfvEXT = cast(typeof(glMultiTexGenfvEXT))load("glMultiTexGenfvEXT");
	glMultiTexGeniEXT = cast(typeof(glMultiTexGeniEXT))load("glMultiTexGeniEXT");
	glMultiTexGenivEXT = cast(typeof(glMultiTexGenivEXT))load("glMultiTexGenivEXT");
	glGetMultiTexEnvfvEXT = cast(typeof(glGetMultiTexEnvfvEXT))load("glGetMultiTexEnvfvEXT");
	glGetMultiTexEnvivEXT = cast(typeof(glGetMultiTexEnvivEXT))load("glGetMultiTexEnvivEXT");
	glGetMultiTexGendvEXT = cast(typeof(glGetMultiTexGendvEXT))load("glGetMultiTexGendvEXT");
	glGetMultiTexGenfvEXT = cast(typeof(glGetMultiTexGenfvEXT))load("glGetMultiTexGenfvEXT");
	glGetMultiTexGenivEXT = cast(typeof(glGetMultiTexGenivEXT))load("glGetMultiTexGenivEXT");
	glMultiTexParameteriEXT = cast(typeof(glMultiTexParameteriEXT))load("glMultiTexParameteriEXT");
	glMultiTexParameterivEXT = cast(typeof(glMultiTexParameterivEXT))load("glMultiTexParameterivEXT");
	glMultiTexParameterfEXT = cast(typeof(glMultiTexParameterfEXT))load("glMultiTexParameterfEXT");
	glMultiTexParameterfvEXT = cast(typeof(glMultiTexParameterfvEXT))load("glMultiTexParameterfvEXT");
	glMultiTexImage1DEXT = cast(typeof(glMultiTexImage1DEXT))load("glMultiTexImage1DEXT");
	glMultiTexImage2DEXT = cast(typeof(glMultiTexImage2DEXT))load("glMultiTexImage2DEXT");
	glMultiTexSubImage1DEXT = cast(typeof(glMultiTexSubImage1DEXT))load("glMultiTexSubImage1DEXT");
	glMultiTexSubImage2DEXT = cast(typeof(glMultiTexSubImage2DEXT))load("glMultiTexSubImage2DEXT");
	glCopyMultiTexImage1DEXT = cast(typeof(glCopyMultiTexImage1DEXT))load("glCopyMultiTexImage1DEXT");
	glCopyMultiTexImage2DEXT = cast(typeof(glCopyMultiTexImage2DEXT))load("glCopyMultiTexImage2DEXT");
	glCopyMultiTexSubImage1DEXT = cast(typeof(glCopyMultiTexSubImage1DEXT))load("glCopyMultiTexSubImage1DEXT");
	glCopyMultiTexSubImage2DEXT = cast(typeof(glCopyMultiTexSubImage2DEXT))load("glCopyMultiTexSubImage2DEXT");
	glGetMultiTexImageEXT = cast(typeof(glGetMultiTexImageEXT))load("glGetMultiTexImageEXT");
	glGetMultiTexParameterfvEXT = cast(typeof(glGetMultiTexParameterfvEXT))load("glGetMultiTexParameterfvEXT");
	glGetMultiTexParameterivEXT = cast(typeof(glGetMultiTexParameterivEXT))load("glGetMultiTexParameterivEXT");
	glGetMultiTexLevelParameterfvEXT = cast(typeof(glGetMultiTexLevelParameterfvEXT))load("glGetMultiTexLevelParameterfvEXT");
	glGetMultiTexLevelParameterivEXT = cast(typeof(glGetMultiTexLevelParameterivEXT))load("glGetMultiTexLevelParameterivEXT");
	glMultiTexImage3DEXT = cast(typeof(glMultiTexImage3DEXT))load("glMultiTexImage3DEXT");
	glMultiTexSubImage3DEXT = cast(typeof(glMultiTexSubImage3DEXT))load("glMultiTexSubImage3DEXT");
	glCopyMultiTexSubImage3DEXT = cast(typeof(glCopyMultiTexSubImage3DEXT))load("glCopyMultiTexSubImage3DEXT");
	glEnableClientStateIndexedEXT = cast(typeof(glEnableClientStateIndexedEXT))load("glEnableClientStateIndexedEXT");
	glDisableClientStateIndexedEXT = cast(typeof(glDisableClientStateIndexedEXT))load("glDisableClientStateIndexedEXT");
	glGetFloatIndexedvEXT = cast(typeof(glGetFloatIndexedvEXT))load("glGetFloatIndexedvEXT");
	glGetDoubleIndexedvEXT = cast(typeof(glGetDoubleIndexedvEXT))load("glGetDoubleIndexedvEXT");
	glGetPointerIndexedvEXT = cast(typeof(glGetPointerIndexedvEXT))load("glGetPointerIndexedvEXT");
	glEnableIndexedEXT = cast(typeof(glEnableIndexedEXT))load("glEnableIndexedEXT");
	glDisableIndexedEXT = cast(typeof(glDisableIndexedEXT))load("glDisableIndexedEXT");
	glIsEnabledIndexedEXT = cast(typeof(glIsEnabledIndexedEXT))load("glIsEnabledIndexedEXT");
	glGetIntegerIndexedvEXT = cast(typeof(glGetIntegerIndexedvEXT))load("glGetIntegerIndexedvEXT");
	glGetBooleanIndexedvEXT = cast(typeof(glGetBooleanIndexedvEXT))load("glGetBooleanIndexedvEXT");
	glCompressedTextureImage3DEXT = cast(typeof(glCompressedTextureImage3DEXT))load("glCompressedTextureImage3DEXT");
	glCompressedTextureImage2DEXT = cast(typeof(glCompressedTextureImage2DEXT))load("glCompressedTextureImage2DEXT");
	glCompressedTextureImage1DEXT = cast(typeof(glCompressedTextureImage1DEXT))load("glCompressedTextureImage1DEXT");
	glCompressedTextureSubImage3DEXT = cast(typeof(glCompressedTextureSubImage3DEXT))load("glCompressedTextureSubImage3DEXT");
	glCompressedTextureSubImage2DEXT = cast(typeof(glCompressedTextureSubImage2DEXT))load("glCompressedTextureSubImage2DEXT");
	glCompressedTextureSubImage1DEXT = cast(typeof(glCompressedTextureSubImage1DEXT))load("glCompressedTextureSubImage1DEXT");
	glGetCompressedTextureImageEXT = cast(typeof(glGetCompressedTextureImageEXT))load("glGetCompressedTextureImageEXT");
	glCompressedMultiTexImage3DEXT = cast(typeof(glCompressedMultiTexImage3DEXT))load("glCompressedMultiTexImage3DEXT");
	glCompressedMultiTexImage2DEXT = cast(typeof(glCompressedMultiTexImage2DEXT))load("glCompressedMultiTexImage2DEXT");
	glCompressedMultiTexImage1DEXT = cast(typeof(glCompressedMultiTexImage1DEXT))load("glCompressedMultiTexImage1DEXT");
	glCompressedMultiTexSubImage3DEXT = cast(typeof(glCompressedMultiTexSubImage3DEXT))load("glCompressedMultiTexSubImage3DEXT");
	glCompressedMultiTexSubImage2DEXT = cast(typeof(glCompressedMultiTexSubImage2DEXT))load("glCompressedMultiTexSubImage2DEXT");
	glCompressedMultiTexSubImage1DEXT = cast(typeof(glCompressedMultiTexSubImage1DEXT))load("glCompressedMultiTexSubImage1DEXT");
	glGetCompressedMultiTexImageEXT = cast(typeof(glGetCompressedMultiTexImageEXT))load("glGetCompressedMultiTexImageEXT");
	glMatrixLoadTransposefEXT = cast(typeof(glMatrixLoadTransposefEXT))load("glMatrixLoadTransposefEXT");
	glMatrixLoadTransposedEXT = cast(typeof(glMatrixLoadTransposedEXT))load("glMatrixLoadTransposedEXT");
	glMatrixMultTransposefEXT = cast(typeof(glMatrixMultTransposefEXT))load("glMatrixMultTransposefEXT");
	glMatrixMultTransposedEXT = cast(typeof(glMatrixMultTransposedEXT))load("glMatrixMultTransposedEXT");
	glNamedBufferDataEXT = cast(typeof(glNamedBufferDataEXT))load("glNamedBufferDataEXT");
	glNamedBufferSubDataEXT = cast(typeof(glNamedBufferSubDataEXT))load("glNamedBufferSubDataEXT");
	glMapNamedBufferEXT = cast(typeof(glMapNamedBufferEXT))load("glMapNamedBufferEXT");
	glUnmapNamedBufferEXT = cast(typeof(glUnmapNamedBufferEXT))load("glUnmapNamedBufferEXT");
	glGetNamedBufferParameterivEXT = cast(typeof(glGetNamedBufferParameterivEXT))load("glGetNamedBufferParameterivEXT");
	glGetNamedBufferPointervEXT = cast(typeof(glGetNamedBufferPointervEXT))load("glGetNamedBufferPointervEXT");
	glGetNamedBufferSubDataEXT = cast(typeof(glGetNamedBufferSubDataEXT))load("glGetNamedBufferSubDataEXT");
	glProgramUniform1fEXT = cast(typeof(glProgramUniform1fEXT))load("glProgramUniform1fEXT");
	glProgramUniform2fEXT = cast(typeof(glProgramUniform2fEXT))load("glProgramUniform2fEXT");
	glProgramUniform3fEXT = cast(typeof(glProgramUniform3fEXT))load("glProgramUniform3fEXT");
	glProgramUniform4fEXT = cast(typeof(glProgramUniform4fEXT))load("glProgramUniform4fEXT");
	glProgramUniform1iEXT = cast(typeof(glProgramUniform1iEXT))load("glProgramUniform1iEXT");
	glProgramUniform2iEXT = cast(typeof(glProgramUniform2iEXT))load("glProgramUniform2iEXT");
	glProgramUniform3iEXT = cast(typeof(glProgramUniform3iEXT))load("glProgramUniform3iEXT");
	glProgramUniform4iEXT = cast(typeof(glProgramUniform4iEXT))load("glProgramUniform4iEXT");
	glProgramUniform1fvEXT = cast(typeof(glProgramUniform1fvEXT))load("glProgramUniform1fvEXT");
	glProgramUniform2fvEXT = cast(typeof(glProgramUniform2fvEXT))load("glProgramUniform2fvEXT");
	glProgramUniform3fvEXT = cast(typeof(glProgramUniform3fvEXT))load("glProgramUniform3fvEXT");
	glProgramUniform4fvEXT = cast(typeof(glProgramUniform4fvEXT))load("glProgramUniform4fvEXT");
	glProgramUniform1ivEXT = cast(typeof(glProgramUniform1ivEXT))load("glProgramUniform1ivEXT");
	glProgramUniform2ivEXT = cast(typeof(glProgramUniform2ivEXT))load("glProgramUniform2ivEXT");
	glProgramUniform3ivEXT = cast(typeof(glProgramUniform3ivEXT))load("glProgramUniform3ivEXT");
	glProgramUniform4ivEXT = cast(typeof(glProgramUniform4ivEXT))load("glProgramUniform4ivEXT");
	glProgramUniformMatrix2fvEXT = cast(typeof(glProgramUniformMatrix2fvEXT))load("glProgramUniformMatrix2fvEXT");
	glProgramUniformMatrix3fvEXT = cast(typeof(glProgramUniformMatrix3fvEXT))load("glProgramUniformMatrix3fvEXT");
	glProgramUniformMatrix4fvEXT = cast(typeof(glProgramUniformMatrix4fvEXT))load("glProgramUniformMatrix4fvEXT");
	glProgramUniformMatrix2x3fvEXT = cast(typeof(glProgramUniformMatrix2x3fvEXT))load("glProgramUniformMatrix2x3fvEXT");
	glProgramUniformMatrix3x2fvEXT = cast(typeof(glProgramUniformMatrix3x2fvEXT))load("glProgramUniformMatrix3x2fvEXT");
	glProgramUniformMatrix2x4fvEXT = cast(typeof(glProgramUniformMatrix2x4fvEXT))load("glProgramUniformMatrix2x4fvEXT");
	glProgramUniformMatrix4x2fvEXT = cast(typeof(glProgramUniformMatrix4x2fvEXT))load("glProgramUniformMatrix4x2fvEXT");
	glProgramUniformMatrix3x4fvEXT = cast(typeof(glProgramUniformMatrix3x4fvEXT))load("glProgramUniformMatrix3x4fvEXT");
	glProgramUniformMatrix4x3fvEXT = cast(typeof(glProgramUniformMatrix4x3fvEXT))load("glProgramUniformMatrix4x3fvEXT");
	glTextureBufferEXT = cast(typeof(glTextureBufferEXT))load("glTextureBufferEXT");
	glMultiTexBufferEXT = cast(typeof(glMultiTexBufferEXT))load("glMultiTexBufferEXT");
	glTextureParameterIivEXT = cast(typeof(glTextureParameterIivEXT))load("glTextureParameterIivEXT");
	glTextureParameterIuivEXT = cast(typeof(glTextureParameterIuivEXT))load("glTextureParameterIuivEXT");
	glGetTextureParameterIivEXT = cast(typeof(glGetTextureParameterIivEXT))load("glGetTextureParameterIivEXT");
	glGetTextureParameterIuivEXT = cast(typeof(glGetTextureParameterIuivEXT))load("glGetTextureParameterIuivEXT");
	glMultiTexParameterIivEXT = cast(typeof(glMultiTexParameterIivEXT))load("glMultiTexParameterIivEXT");
	glMultiTexParameterIuivEXT = cast(typeof(glMultiTexParameterIuivEXT))load("glMultiTexParameterIuivEXT");
	glGetMultiTexParameterIivEXT = cast(typeof(glGetMultiTexParameterIivEXT))load("glGetMultiTexParameterIivEXT");
	glGetMultiTexParameterIuivEXT = cast(typeof(glGetMultiTexParameterIuivEXT))load("glGetMultiTexParameterIuivEXT");
	glProgramUniform1uiEXT = cast(typeof(glProgramUniform1uiEXT))load("glProgramUniform1uiEXT");
	glProgramUniform2uiEXT = cast(typeof(glProgramUniform2uiEXT))load("glProgramUniform2uiEXT");
	glProgramUniform3uiEXT = cast(typeof(glProgramUniform3uiEXT))load("glProgramUniform3uiEXT");
	glProgramUniform4uiEXT = cast(typeof(glProgramUniform4uiEXT))load("glProgramUniform4uiEXT");
	glProgramUniform1uivEXT = cast(typeof(glProgramUniform1uivEXT))load("glProgramUniform1uivEXT");
	glProgramUniform2uivEXT = cast(typeof(glProgramUniform2uivEXT))load("glProgramUniform2uivEXT");
	glProgramUniform3uivEXT = cast(typeof(glProgramUniform3uivEXT))load("glProgramUniform3uivEXT");
	glProgramUniform4uivEXT = cast(typeof(glProgramUniform4uivEXT))load("glProgramUniform4uivEXT");
	glNamedProgramLocalParameters4fvEXT = cast(typeof(glNamedProgramLocalParameters4fvEXT))load("glNamedProgramLocalParameters4fvEXT");
	glNamedProgramLocalParameterI4iEXT = cast(typeof(glNamedProgramLocalParameterI4iEXT))load("glNamedProgramLocalParameterI4iEXT");
	glNamedProgramLocalParameterI4ivEXT = cast(typeof(glNamedProgramLocalParameterI4ivEXT))load("glNamedProgramLocalParameterI4ivEXT");
	glNamedProgramLocalParametersI4ivEXT = cast(typeof(glNamedProgramLocalParametersI4ivEXT))load("glNamedProgramLocalParametersI4ivEXT");
	glNamedProgramLocalParameterI4uiEXT = cast(typeof(glNamedProgramLocalParameterI4uiEXT))load("glNamedProgramLocalParameterI4uiEXT");
	glNamedProgramLocalParameterI4uivEXT = cast(typeof(glNamedProgramLocalParameterI4uivEXT))load("glNamedProgramLocalParameterI4uivEXT");
	glNamedProgramLocalParametersI4uivEXT = cast(typeof(glNamedProgramLocalParametersI4uivEXT))load("glNamedProgramLocalParametersI4uivEXT");
	glGetNamedProgramLocalParameterIivEXT = cast(typeof(glGetNamedProgramLocalParameterIivEXT))load("glGetNamedProgramLocalParameterIivEXT");
	glGetNamedProgramLocalParameterIuivEXT = cast(typeof(glGetNamedProgramLocalParameterIuivEXT))load("glGetNamedProgramLocalParameterIuivEXT");
	glEnableClientStateiEXT = cast(typeof(glEnableClientStateiEXT))load("glEnableClientStateiEXT");
	glDisableClientStateiEXT = cast(typeof(glDisableClientStateiEXT))load("glDisableClientStateiEXT");
	glGetFloati_vEXT = cast(typeof(glGetFloati_vEXT))load("glGetFloati_vEXT");
	glGetDoublei_vEXT = cast(typeof(glGetDoublei_vEXT))load("glGetDoublei_vEXT");
	glGetPointeri_vEXT = cast(typeof(glGetPointeri_vEXT))load("glGetPointeri_vEXT");
	glNamedProgramStringEXT = cast(typeof(glNamedProgramStringEXT))load("glNamedProgramStringEXT");
	glNamedProgramLocalParameter4dEXT = cast(typeof(glNamedProgramLocalParameter4dEXT))load("glNamedProgramLocalParameter4dEXT");
	glNamedProgramLocalParameter4dvEXT = cast(typeof(glNamedProgramLocalParameter4dvEXT))load("glNamedProgramLocalParameter4dvEXT");
	glNamedProgramLocalParameter4fEXT = cast(typeof(glNamedProgramLocalParameter4fEXT))load("glNamedProgramLocalParameter4fEXT");
	glNamedProgramLocalParameter4fvEXT = cast(typeof(glNamedProgramLocalParameter4fvEXT))load("glNamedProgramLocalParameter4fvEXT");
	glGetNamedProgramLocalParameterdvEXT = cast(typeof(glGetNamedProgramLocalParameterdvEXT))load("glGetNamedProgramLocalParameterdvEXT");
	glGetNamedProgramLocalParameterfvEXT = cast(typeof(glGetNamedProgramLocalParameterfvEXT))load("glGetNamedProgramLocalParameterfvEXT");
	glGetNamedProgramivEXT = cast(typeof(glGetNamedProgramivEXT))load("glGetNamedProgramivEXT");
	glGetNamedProgramStringEXT = cast(typeof(glGetNamedProgramStringEXT))load("glGetNamedProgramStringEXT");
	glNamedRenderbufferStorageEXT = cast(typeof(glNamedRenderbufferStorageEXT))load("glNamedRenderbufferStorageEXT");
	glGetNamedRenderbufferParameterivEXT = cast(typeof(glGetNamedRenderbufferParameterivEXT))load("glGetNamedRenderbufferParameterivEXT");
	glNamedRenderbufferStorageMultisampleEXT = cast(typeof(glNamedRenderbufferStorageMultisampleEXT))load("glNamedRenderbufferStorageMultisampleEXT");
	glNamedRenderbufferStorageMultisampleCoverageEXT = cast(typeof(glNamedRenderbufferStorageMultisampleCoverageEXT))load("glNamedRenderbufferStorageMultisampleCoverageEXT");
	glCheckNamedFramebufferStatusEXT = cast(typeof(glCheckNamedFramebufferStatusEXT))load("glCheckNamedFramebufferStatusEXT");
	glNamedFramebufferTexture1DEXT = cast(typeof(glNamedFramebufferTexture1DEXT))load("glNamedFramebufferTexture1DEXT");
	glNamedFramebufferTexture2DEXT = cast(typeof(glNamedFramebufferTexture2DEXT))load("glNamedFramebufferTexture2DEXT");
	glNamedFramebufferTexture3DEXT = cast(typeof(glNamedFramebufferTexture3DEXT))load("glNamedFramebufferTexture3DEXT");
	glNamedFramebufferRenderbufferEXT = cast(typeof(glNamedFramebufferRenderbufferEXT))load("glNamedFramebufferRenderbufferEXT");
	glGetNamedFramebufferAttachmentParameterivEXT = cast(typeof(glGetNamedFramebufferAttachmentParameterivEXT))load("glGetNamedFramebufferAttachmentParameterivEXT");
	glGenerateTextureMipmapEXT = cast(typeof(glGenerateTextureMipmapEXT))load("glGenerateTextureMipmapEXT");
	glGenerateMultiTexMipmapEXT = cast(typeof(glGenerateMultiTexMipmapEXT))load("glGenerateMultiTexMipmapEXT");
	glFramebufferDrawBufferEXT = cast(typeof(glFramebufferDrawBufferEXT))load("glFramebufferDrawBufferEXT");
	glFramebufferDrawBuffersEXT = cast(typeof(glFramebufferDrawBuffersEXT))load("glFramebufferDrawBuffersEXT");
	glFramebufferReadBufferEXT = cast(typeof(glFramebufferReadBufferEXT))load("glFramebufferReadBufferEXT");
	glGetFramebufferParameterivEXT = cast(typeof(glGetFramebufferParameterivEXT))load("glGetFramebufferParameterivEXT");
	glNamedCopyBufferSubDataEXT = cast(typeof(glNamedCopyBufferSubDataEXT))load("glNamedCopyBufferSubDataEXT");
	glNamedFramebufferTextureEXT = cast(typeof(glNamedFramebufferTextureEXT))load("glNamedFramebufferTextureEXT");
	glNamedFramebufferTextureLayerEXT = cast(typeof(glNamedFramebufferTextureLayerEXT))load("glNamedFramebufferTextureLayerEXT");
	glNamedFramebufferTextureFaceEXT = cast(typeof(glNamedFramebufferTextureFaceEXT))load("glNamedFramebufferTextureFaceEXT");
	glTextureRenderbufferEXT = cast(typeof(glTextureRenderbufferEXT))load("glTextureRenderbufferEXT");
	glMultiTexRenderbufferEXT = cast(typeof(glMultiTexRenderbufferEXT))load("glMultiTexRenderbufferEXT");
	glVertexArrayVertexOffsetEXT = cast(typeof(glVertexArrayVertexOffsetEXT))load("glVertexArrayVertexOffsetEXT");
	glVertexArrayColorOffsetEXT = cast(typeof(glVertexArrayColorOffsetEXT))load("glVertexArrayColorOffsetEXT");
	glVertexArrayEdgeFlagOffsetEXT = cast(typeof(glVertexArrayEdgeFlagOffsetEXT))load("glVertexArrayEdgeFlagOffsetEXT");
	glVertexArrayIndexOffsetEXT = cast(typeof(glVertexArrayIndexOffsetEXT))load("glVertexArrayIndexOffsetEXT");
	glVertexArrayNormalOffsetEXT = cast(typeof(glVertexArrayNormalOffsetEXT))load("glVertexArrayNormalOffsetEXT");
	glVertexArrayTexCoordOffsetEXT = cast(typeof(glVertexArrayTexCoordOffsetEXT))load("glVertexArrayTexCoordOffsetEXT");
	glVertexArrayMultiTexCoordOffsetEXT = cast(typeof(glVertexArrayMultiTexCoordOffsetEXT))load("glVertexArrayMultiTexCoordOffsetEXT");
	glVertexArrayFogCoordOffsetEXT = cast(typeof(glVertexArrayFogCoordOffsetEXT))load("glVertexArrayFogCoordOffsetEXT");
	glVertexArraySecondaryColorOffsetEXT = cast(typeof(glVertexArraySecondaryColorOffsetEXT))load("glVertexArraySecondaryColorOffsetEXT");
	glVertexArrayVertexAttribOffsetEXT = cast(typeof(glVertexArrayVertexAttribOffsetEXT))load("glVertexArrayVertexAttribOffsetEXT");
	glVertexArrayVertexAttribIOffsetEXT = cast(typeof(glVertexArrayVertexAttribIOffsetEXT))load("glVertexArrayVertexAttribIOffsetEXT");
	glEnableVertexArrayEXT = cast(typeof(glEnableVertexArrayEXT))load("glEnableVertexArrayEXT");
	glDisableVertexArrayEXT = cast(typeof(glDisableVertexArrayEXT))load("glDisableVertexArrayEXT");
	glEnableVertexArrayAttribEXT = cast(typeof(glEnableVertexArrayAttribEXT))load("glEnableVertexArrayAttribEXT");
	glDisableVertexArrayAttribEXT = cast(typeof(glDisableVertexArrayAttribEXT))load("glDisableVertexArrayAttribEXT");
	glGetVertexArrayIntegervEXT = cast(typeof(glGetVertexArrayIntegervEXT))load("glGetVertexArrayIntegervEXT");
	glGetVertexArrayPointervEXT = cast(typeof(glGetVertexArrayPointervEXT))load("glGetVertexArrayPointervEXT");
	glGetVertexArrayIntegeri_vEXT = cast(typeof(glGetVertexArrayIntegeri_vEXT))load("glGetVertexArrayIntegeri_vEXT");
	glGetVertexArrayPointeri_vEXT = cast(typeof(glGetVertexArrayPointeri_vEXT))load("glGetVertexArrayPointeri_vEXT");
	glMapNamedBufferRangeEXT = cast(typeof(glMapNamedBufferRangeEXT))load("glMapNamedBufferRangeEXT");
	glFlushMappedNamedBufferRangeEXT = cast(typeof(glFlushMappedNamedBufferRangeEXT))load("glFlushMappedNamedBufferRangeEXT");
	glClearNamedBufferDataEXT = cast(typeof(glClearNamedBufferDataEXT))load("glClearNamedBufferDataEXT");
	glClearNamedBufferSubDataEXT = cast(typeof(glClearNamedBufferSubDataEXT))load("glClearNamedBufferSubDataEXT");
	glNamedFramebufferParameteriEXT = cast(typeof(glNamedFramebufferParameteriEXT))load("glNamedFramebufferParameteriEXT");
	glGetNamedFramebufferParameterivEXT = cast(typeof(glGetNamedFramebufferParameterivEXT))load("glGetNamedFramebufferParameterivEXT");
	glProgramUniform1dEXT = cast(typeof(glProgramUniform1dEXT))load("glProgramUniform1dEXT");
	glProgramUniform2dEXT = cast(typeof(glProgramUniform2dEXT))load("glProgramUniform2dEXT");
	glProgramUniform3dEXT = cast(typeof(glProgramUniform3dEXT))load("glProgramUniform3dEXT");
	glProgramUniform4dEXT = cast(typeof(glProgramUniform4dEXT))load("glProgramUniform4dEXT");
	glProgramUniform1dvEXT = cast(typeof(glProgramUniform1dvEXT))load("glProgramUniform1dvEXT");
	glProgramUniform2dvEXT = cast(typeof(glProgramUniform2dvEXT))load("glProgramUniform2dvEXT");
	glProgramUniform3dvEXT = cast(typeof(glProgramUniform3dvEXT))load("glProgramUniform3dvEXT");
	glProgramUniform4dvEXT = cast(typeof(glProgramUniform4dvEXT))load("glProgramUniform4dvEXT");
	glProgramUniformMatrix2dvEXT = cast(typeof(glProgramUniformMatrix2dvEXT))load("glProgramUniformMatrix2dvEXT");
	glProgramUniformMatrix3dvEXT = cast(typeof(glProgramUniformMatrix3dvEXT))load("glProgramUniformMatrix3dvEXT");
	glProgramUniformMatrix4dvEXT = cast(typeof(glProgramUniformMatrix4dvEXT))load("glProgramUniformMatrix4dvEXT");
	glProgramUniformMatrix2x3dvEXT = cast(typeof(glProgramUniformMatrix2x3dvEXT))load("glProgramUniformMatrix2x3dvEXT");
	glProgramUniformMatrix2x4dvEXT = cast(typeof(glProgramUniformMatrix2x4dvEXT))load("glProgramUniformMatrix2x4dvEXT");
	glProgramUniformMatrix3x2dvEXT = cast(typeof(glProgramUniformMatrix3x2dvEXT))load("glProgramUniformMatrix3x2dvEXT");
	glProgramUniformMatrix3x4dvEXT = cast(typeof(glProgramUniformMatrix3x4dvEXT))load("glProgramUniformMatrix3x4dvEXT");
	glProgramUniformMatrix4x2dvEXT = cast(typeof(glProgramUniformMatrix4x2dvEXT))load("glProgramUniformMatrix4x2dvEXT");
	glProgramUniformMatrix4x3dvEXT = cast(typeof(glProgramUniformMatrix4x3dvEXT))load("glProgramUniformMatrix4x3dvEXT");
	glTextureBufferRangeEXT = cast(typeof(glTextureBufferRangeEXT))load("glTextureBufferRangeEXT");
	glTextureStorage1DEXT = cast(typeof(glTextureStorage1DEXT))load("glTextureStorage1DEXT");
	glTextureStorage2DEXT = cast(typeof(glTextureStorage2DEXT))load("glTextureStorage2DEXT");
	glTextureStorage3DEXT = cast(typeof(glTextureStorage3DEXT))load("glTextureStorage3DEXT");
	glTextureStorage2DMultisampleEXT = cast(typeof(glTextureStorage2DMultisampleEXT))load("glTextureStorage2DMultisampleEXT");
	glTextureStorage3DMultisampleEXT = cast(typeof(glTextureStorage3DMultisampleEXT))load("glTextureStorage3DMultisampleEXT");
	glVertexArrayBindVertexBufferEXT = cast(typeof(glVertexArrayBindVertexBufferEXT))load("glVertexArrayBindVertexBufferEXT");
	glVertexArrayVertexAttribFormatEXT = cast(typeof(glVertexArrayVertexAttribFormatEXT))load("glVertexArrayVertexAttribFormatEXT");
	glVertexArrayVertexAttribIFormatEXT = cast(typeof(glVertexArrayVertexAttribIFormatEXT))load("glVertexArrayVertexAttribIFormatEXT");
	glVertexArrayVertexAttribLFormatEXT = cast(typeof(glVertexArrayVertexAttribLFormatEXT))load("glVertexArrayVertexAttribLFormatEXT");
	glVertexArrayVertexAttribBindingEXT = cast(typeof(glVertexArrayVertexAttribBindingEXT))load("glVertexArrayVertexAttribBindingEXT");
	glVertexArrayVertexBindingDivisorEXT = cast(typeof(glVertexArrayVertexBindingDivisorEXT))load("glVertexArrayVertexBindingDivisorEXT");
	glVertexArrayVertexAttribLOffsetEXT = cast(typeof(glVertexArrayVertexAttribLOffsetEXT))load("glVertexArrayVertexAttribLOffsetEXT");
	glTexturePageCommitmentEXT = cast(typeof(glTexturePageCommitmentEXT))load("glTexturePageCommitmentEXT");
	return GL_EXT_direct_state_access;
}


bool load_gl_GL_NV_texture_rectangle(void* function(string name) load) {
	if(!GL_NV_texture_rectangle) return GL_NV_texture_rectangle;

	return GL_NV_texture_rectangle;
}


bool load_gl_GL_ARB_copy_image(void* function(string name) load) {
	if(!GL_ARB_copy_image) return GL_ARB_copy_image;

	glCopyImageSubData = cast(typeof(glCopyImageSubData))load("glCopyImageSubData");
	return GL_ARB_copy_image;
}


bool load_gl_GL_ARB_shader_precision(void* function(string name) load) {
	if(!GL_ARB_shader_precision) return GL_ARB_shader_precision;

	return GL_ARB_shader_precision;
}


bool load_gl_GL_EXT_vertex_shader(void* function(string name) load) {
	if(!GL_EXT_vertex_shader) return GL_EXT_vertex_shader;

	glBeginVertexShaderEXT = cast(typeof(glBeginVertexShaderEXT))load("glBeginVertexShaderEXT");
	glEndVertexShaderEXT = cast(typeof(glEndVertexShaderEXT))load("glEndVertexShaderEXT");
	glBindVertexShaderEXT = cast(typeof(glBindVertexShaderEXT))load("glBindVertexShaderEXT");
	glGenVertexShadersEXT = cast(typeof(glGenVertexShadersEXT))load("glGenVertexShadersEXT");
	glDeleteVertexShaderEXT = cast(typeof(glDeleteVertexShaderEXT))load("glDeleteVertexShaderEXT");
	glShaderOp1EXT = cast(typeof(glShaderOp1EXT))load("glShaderOp1EXT");
	glShaderOp2EXT = cast(typeof(glShaderOp2EXT))load("glShaderOp2EXT");
	glShaderOp3EXT = cast(typeof(glShaderOp3EXT))load("glShaderOp3EXT");
	glSwizzleEXT = cast(typeof(glSwizzleEXT))load("glSwizzleEXT");
	glWriteMaskEXT = cast(typeof(glWriteMaskEXT))load("glWriteMaskEXT");
	glInsertComponentEXT = cast(typeof(glInsertComponentEXT))load("glInsertComponentEXT");
	glExtractComponentEXT = cast(typeof(glExtractComponentEXT))load("glExtractComponentEXT");
	glGenSymbolsEXT = cast(typeof(glGenSymbolsEXT))load("glGenSymbolsEXT");
	glSetInvariantEXT = cast(typeof(glSetInvariantEXT))load("glSetInvariantEXT");
	glSetLocalConstantEXT = cast(typeof(glSetLocalConstantEXT))load("glSetLocalConstantEXT");
	glVariantbvEXT = cast(typeof(glVariantbvEXT))load("glVariantbvEXT");
	glVariantsvEXT = cast(typeof(glVariantsvEXT))load("glVariantsvEXT");
	glVariantivEXT = cast(typeof(glVariantivEXT))load("glVariantivEXT");
	glVariantfvEXT = cast(typeof(glVariantfvEXT))load("glVariantfvEXT");
	glVariantdvEXT = cast(typeof(glVariantdvEXT))load("glVariantdvEXT");
	glVariantubvEXT = cast(typeof(glVariantubvEXT))load("glVariantubvEXT");
	glVariantusvEXT = cast(typeof(glVariantusvEXT))load("glVariantusvEXT");
	glVariantuivEXT = cast(typeof(glVariantuivEXT))load("glVariantuivEXT");
	glVariantPointerEXT = cast(typeof(glVariantPointerEXT))load("glVariantPointerEXT");
	glEnableVariantClientStateEXT = cast(typeof(glEnableVariantClientStateEXT))load("glEnableVariantClientStateEXT");
	glDisableVariantClientStateEXT = cast(typeof(glDisableVariantClientStateEXT))load("glDisableVariantClientStateEXT");
	glBindLightParameterEXT = cast(typeof(glBindLightParameterEXT))load("glBindLightParameterEXT");
	glBindMaterialParameterEXT = cast(typeof(glBindMaterialParameterEXT))load("glBindMaterialParameterEXT");
	glBindTexGenParameterEXT = cast(typeof(glBindTexGenParameterEXT))load("glBindTexGenParameterEXT");
	glBindTextureUnitParameterEXT = cast(typeof(glBindTextureUnitParameterEXT))load("glBindTextureUnitParameterEXT");
	glBindParameterEXT = cast(typeof(glBindParameterEXT))load("glBindParameterEXT");
	glIsVariantEnabledEXT = cast(typeof(glIsVariantEnabledEXT))load("glIsVariantEnabledEXT");
	glGetVariantBooleanvEXT = cast(typeof(glGetVariantBooleanvEXT))load("glGetVariantBooleanvEXT");
	glGetVariantIntegervEXT = cast(typeof(glGetVariantIntegervEXT))load("glGetVariantIntegervEXT");
	glGetVariantFloatvEXT = cast(typeof(glGetVariantFloatvEXT))load("glGetVariantFloatvEXT");
	glGetVariantPointervEXT = cast(typeof(glGetVariantPointervEXT))load("glGetVariantPointervEXT");
	glGetInvariantBooleanvEXT = cast(typeof(glGetInvariantBooleanvEXT))load("glGetInvariantBooleanvEXT");
	glGetInvariantIntegervEXT = cast(typeof(glGetInvariantIntegervEXT))load("glGetInvariantIntegervEXT");
	glGetInvariantFloatvEXT = cast(typeof(glGetInvariantFloatvEXT))load("glGetInvariantFloatvEXT");
	glGetLocalConstantBooleanvEXT = cast(typeof(glGetLocalConstantBooleanvEXT))load("glGetLocalConstantBooleanvEXT");
	glGetLocalConstantIntegervEXT = cast(typeof(glGetLocalConstantIntegervEXT))load("glGetLocalConstantIntegervEXT");
	glGetLocalConstantFloatvEXT = cast(typeof(glGetLocalConstantFloatvEXT))load("glGetLocalConstantFloatvEXT");
	return GL_EXT_vertex_shader;
}


bool load_gl_GL_EXT_blend_func_separate(void* function(string name) load) {
	if(!GL_EXT_blend_func_separate) return GL_EXT_blend_func_separate;

	glBlendFuncSeparateEXT = cast(typeof(glBlendFuncSeparateEXT))load("glBlendFuncSeparateEXT");
	return GL_EXT_blend_func_separate;
}


bool load_gl_GL_APPLE_fence(void* function(string name) load) {
	if(!GL_APPLE_fence) return GL_APPLE_fence;

	glGenFencesAPPLE = cast(typeof(glGenFencesAPPLE))load("glGenFencesAPPLE");
	glDeleteFencesAPPLE = cast(typeof(glDeleteFencesAPPLE))load("glDeleteFencesAPPLE");
	glSetFenceAPPLE = cast(typeof(glSetFenceAPPLE))load("glSetFenceAPPLE");
	glIsFenceAPPLE = cast(typeof(glIsFenceAPPLE))load("glIsFenceAPPLE");
	glTestFenceAPPLE = cast(typeof(glTestFenceAPPLE))load("glTestFenceAPPLE");
	glFinishFenceAPPLE = cast(typeof(glFinishFenceAPPLE))load("glFinishFenceAPPLE");
	glTestObjectAPPLE = cast(typeof(glTestObjectAPPLE))load("glTestObjectAPPLE");
	glFinishObjectAPPLE = cast(typeof(glFinishObjectAPPLE))load("glFinishObjectAPPLE");
	return GL_APPLE_fence;
}


bool load_gl_GL_OES_byte_coordinates(void* function(string name) load) {
	if(!GL_OES_byte_coordinates) return GL_OES_byte_coordinates;

	glMultiTexCoord1bOES = cast(typeof(glMultiTexCoord1bOES))load("glMultiTexCoord1bOES");
	glMultiTexCoord1bvOES = cast(typeof(glMultiTexCoord1bvOES))load("glMultiTexCoord1bvOES");
	glMultiTexCoord2bOES = cast(typeof(glMultiTexCoord2bOES))load("glMultiTexCoord2bOES");
	glMultiTexCoord2bvOES = cast(typeof(glMultiTexCoord2bvOES))load("glMultiTexCoord2bvOES");
	glMultiTexCoord3bOES = cast(typeof(glMultiTexCoord3bOES))load("glMultiTexCoord3bOES");
	glMultiTexCoord3bvOES = cast(typeof(glMultiTexCoord3bvOES))load("glMultiTexCoord3bvOES");
	glMultiTexCoord4bOES = cast(typeof(glMultiTexCoord4bOES))load("glMultiTexCoord4bOES");
	glMultiTexCoord4bvOES = cast(typeof(glMultiTexCoord4bvOES))load("glMultiTexCoord4bvOES");
	glTexCoord1bOES = cast(typeof(glTexCoord1bOES))load("glTexCoord1bOES");
	glTexCoord1bvOES = cast(typeof(glTexCoord1bvOES))load("glTexCoord1bvOES");
	glTexCoord2bOES = cast(typeof(glTexCoord2bOES))load("glTexCoord2bOES");
	glTexCoord2bvOES = cast(typeof(glTexCoord2bvOES))load("glTexCoord2bvOES");
	glTexCoord3bOES = cast(typeof(glTexCoord3bOES))load("glTexCoord3bOES");
	glTexCoord3bvOES = cast(typeof(glTexCoord3bvOES))load("glTexCoord3bvOES");
	glTexCoord4bOES = cast(typeof(glTexCoord4bOES))load("glTexCoord4bOES");
	glTexCoord4bvOES = cast(typeof(glTexCoord4bvOES))load("glTexCoord4bvOES");
	glVertex2bOES = cast(typeof(glVertex2bOES))load("glVertex2bOES");
	glVertex2bvOES = cast(typeof(glVertex2bvOES))load("glVertex2bvOES");
	glVertex3bOES = cast(typeof(glVertex3bOES))load("glVertex3bOES");
	glVertex3bvOES = cast(typeof(glVertex3bvOES))load("glVertex3bvOES");
	glVertex4bOES = cast(typeof(glVertex4bOES))load("glVertex4bOES");
	glVertex4bvOES = cast(typeof(glVertex4bvOES))load("glVertex4bvOES");
	return GL_OES_byte_coordinates;
}


bool load_gl_GL_ARB_transpose_matrix(void* function(string name) load) {
	if(!GL_ARB_transpose_matrix) return GL_ARB_transpose_matrix;

	glLoadTransposeMatrixfARB = cast(typeof(glLoadTransposeMatrixfARB))load("glLoadTransposeMatrixfARB");
	glLoadTransposeMatrixdARB = cast(typeof(glLoadTransposeMatrixdARB))load("glLoadTransposeMatrixdARB");
	glMultTransposeMatrixfARB = cast(typeof(glMultTransposeMatrixfARB))load("glMultTransposeMatrixfARB");
	glMultTransposeMatrixdARB = cast(typeof(glMultTransposeMatrixdARB))load("glMultTransposeMatrixdARB");
	return GL_ARB_transpose_matrix;
}


bool load_gl_GL_ARB_provoking_vertex(void* function(string name) load) {
	if(!GL_ARB_provoking_vertex) return GL_ARB_provoking_vertex;

	glProvokingVertex = cast(typeof(glProvokingVertex))load("glProvokingVertex");
	return GL_ARB_provoking_vertex;
}


bool load_gl_GL_EXT_fog_coord(void* function(string name) load) {
	if(!GL_EXT_fog_coord) return GL_EXT_fog_coord;

	glFogCoordfEXT = cast(typeof(glFogCoordfEXT))load("glFogCoordfEXT");
	glFogCoordfvEXT = cast(typeof(glFogCoordfvEXT))load("glFogCoordfvEXT");
	glFogCoorddEXT = cast(typeof(glFogCoorddEXT))load("glFogCoorddEXT");
	glFogCoorddvEXT = cast(typeof(glFogCoorddvEXT))load("glFogCoorddvEXT");
	glFogCoordPointerEXT = cast(typeof(glFogCoordPointerEXT))load("glFogCoordPointerEXT");
	return GL_EXT_fog_coord;
}


bool load_gl_GL_EXT_vertex_array(void* function(string name) load) {
	if(!GL_EXT_vertex_array) return GL_EXT_vertex_array;

	glArrayElementEXT = cast(typeof(glArrayElementEXT))load("glArrayElementEXT");
	glColorPointerEXT = cast(typeof(glColorPointerEXT))load("glColorPointerEXT");
	glDrawArraysEXT = cast(typeof(glDrawArraysEXT))load("glDrawArraysEXT");
	glEdgeFlagPointerEXT = cast(typeof(glEdgeFlagPointerEXT))load("glEdgeFlagPointerEXT");
	glGetPointervEXT = cast(typeof(glGetPointervEXT))load("glGetPointervEXT");
	glIndexPointerEXT = cast(typeof(glIndexPointerEXT))load("glIndexPointerEXT");
	glNormalPointerEXT = cast(typeof(glNormalPointerEXT))load("glNormalPointerEXT");
	glTexCoordPointerEXT = cast(typeof(glTexCoordPointerEXT))load("glTexCoordPointerEXT");
	glVertexPointerEXT = cast(typeof(glVertexPointerEXT))load("glVertexPointerEXT");
	return GL_EXT_vertex_array;
}


bool load_gl_GL_ARB_half_float_vertex(void* function(string name) load) {
	if(!GL_ARB_half_float_vertex) return GL_ARB_half_float_vertex;

	return GL_ARB_half_float_vertex;
}


bool load_gl_GL_EXT_blend_equation_separate(void* function(string name) load) {
	if(!GL_EXT_blend_equation_separate) return GL_EXT_blend_equation_separate;

	glBlendEquationSeparateEXT = cast(typeof(glBlendEquationSeparateEXT))load("glBlendEquationSeparateEXT");
	return GL_EXT_blend_equation_separate;
}


bool load_gl_GL_ARB_multi_draw_indirect(void* function(string name) load) {
	if(!GL_ARB_multi_draw_indirect) return GL_ARB_multi_draw_indirect;

	glMultiDrawArraysIndirect = cast(typeof(glMultiDrawArraysIndirect))load("glMultiDrawArraysIndirect");
	glMultiDrawElementsIndirect = cast(typeof(glMultiDrawElementsIndirect))load("glMultiDrawElementsIndirect");
	return GL_ARB_multi_draw_indirect;
}


bool load_gl_GL_NV_copy_image(void* function(string name) load) {
	if(!GL_NV_copy_image) return GL_NV_copy_image;

	glCopyImageSubDataNV = cast(typeof(glCopyImageSubDataNV))load("glCopyImageSubDataNV");
	return GL_NV_copy_image;
}


bool load_gl_GL_HP_texture_lighting(void* function(string name) load) {
	if(!GL_HP_texture_lighting) return GL_HP_texture_lighting;

	return GL_HP_texture_lighting;
}


bool load_gl_GL_SGIX_convolution_accuracy(void* function(string name) load) {
	if(!GL_SGIX_convolution_accuracy) return GL_SGIX_convolution_accuracy;

	return GL_SGIX_convolution_accuracy;
}


bool load_gl_GL_ARB_transform_feedback3(void* function(string name) load) {
	if(!GL_ARB_transform_feedback3) return GL_ARB_transform_feedback3;

	glDrawTransformFeedbackStream = cast(typeof(glDrawTransformFeedbackStream))load("glDrawTransformFeedbackStream");
	glBeginQueryIndexed = cast(typeof(glBeginQueryIndexed))load("glBeginQueryIndexed");
	glEndQueryIndexed = cast(typeof(glEndQueryIndexed))load("glEndQueryIndexed");
	glGetQueryIndexediv = cast(typeof(glGetQueryIndexediv))load("glGetQueryIndexediv");
	return GL_ARB_transform_feedback3;
}


bool load_gl_GL_SGIX_ycrcba(void* function(string name) load) {
	if(!GL_SGIX_ycrcba) return GL_SGIX_ycrcba;

	return GL_SGIX_ycrcba;
}


bool load_gl_GL_EXT_bgra(void* function(string name) load) {
	if(!GL_EXT_bgra) return GL_EXT_bgra;

	return GL_EXT_bgra;
}


bool load_gl_GL_INTEL_parallel_arrays(void* function(string name) load) {
	if(!GL_INTEL_parallel_arrays) return GL_INTEL_parallel_arrays;

	glVertexPointervINTEL = cast(typeof(glVertexPointervINTEL))load("glVertexPointervINTEL");
	glNormalPointervINTEL = cast(typeof(glNormalPointervINTEL))load("glNormalPointervINTEL");
	glColorPointervINTEL = cast(typeof(glColorPointervINTEL))load("glColorPointervINTEL");
	glTexCoordPointervINTEL = cast(typeof(glTexCoordPointervINTEL))load("glTexCoordPointervINTEL");
	return GL_INTEL_parallel_arrays;
}


bool load_gl_GL_EXT_pixel_transform(void* function(string name) load) {
	if(!GL_EXT_pixel_transform) return GL_EXT_pixel_transform;

	glPixelTransformParameteriEXT = cast(typeof(glPixelTransformParameteriEXT))load("glPixelTransformParameteriEXT");
	glPixelTransformParameterfEXT = cast(typeof(glPixelTransformParameterfEXT))load("glPixelTransformParameterfEXT");
	glPixelTransformParameterivEXT = cast(typeof(glPixelTransformParameterivEXT))load("glPixelTransformParameterivEXT");
	glPixelTransformParameterfvEXT = cast(typeof(glPixelTransformParameterfvEXT))load("glPixelTransformParameterfvEXT");
	glGetPixelTransformParameterivEXT = cast(typeof(glGetPixelTransformParameterivEXT))load("glGetPixelTransformParameterivEXT");
	glGetPixelTransformParameterfvEXT = cast(typeof(glGetPixelTransformParameterfvEXT))load("glGetPixelTransformParameterfvEXT");
	return GL_EXT_pixel_transform;
}


bool load_gl_GL_NV_vertex_attrib_integer_64bit(void* function(string name) load) {
	if(!GL_NV_vertex_attrib_integer_64bit) return GL_NV_vertex_attrib_integer_64bit;

	glVertexAttribL1i64NV = cast(typeof(glVertexAttribL1i64NV))load("glVertexAttribL1i64NV");
	glVertexAttribL2i64NV = cast(typeof(glVertexAttribL2i64NV))load("glVertexAttribL2i64NV");
	glVertexAttribL3i64NV = cast(typeof(glVertexAttribL3i64NV))load("glVertexAttribL3i64NV");
	glVertexAttribL4i64NV = cast(typeof(glVertexAttribL4i64NV))load("glVertexAttribL4i64NV");
	glVertexAttribL1i64vNV = cast(typeof(glVertexAttribL1i64vNV))load("glVertexAttribL1i64vNV");
	glVertexAttribL2i64vNV = cast(typeof(glVertexAttribL2i64vNV))load("glVertexAttribL2i64vNV");
	glVertexAttribL3i64vNV = cast(typeof(glVertexAttribL3i64vNV))load("glVertexAttribL3i64vNV");
	glVertexAttribL4i64vNV = cast(typeof(glVertexAttribL4i64vNV))load("glVertexAttribL4i64vNV");
	glVertexAttribL1ui64NV = cast(typeof(glVertexAttribL1ui64NV))load("glVertexAttribL1ui64NV");
	glVertexAttribL2ui64NV = cast(typeof(glVertexAttribL2ui64NV))load("glVertexAttribL2ui64NV");
	glVertexAttribL3ui64NV = cast(typeof(glVertexAttribL3ui64NV))load("glVertexAttribL3ui64NV");
	glVertexAttribL4ui64NV = cast(typeof(glVertexAttribL4ui64NV))load("glVertexAttribL4ui64NV");
	glVertexAttribL1ui64vNV = cast(typeof(glVertexAttribL1ui64vNV))load("glVertexAttribL1ui64vNV");
	glVertexAttribL2ui64vNV = cast(typeof(glVertexAttribL2ui64vNV))load("glVertexAttribL2ui64vNV");
	glVertexAttribL3ui64vNV = cast(typeof(glVertexAttribL3ui64vNV))load("glVertexAttribL3ui64vNV");
	glVertexAttribL4ui64vNV = cast(typeof(glVertexAttribL4ui64vNV))load("glVertexAttribL4ui64vNV");
	glGetVertexAttribLi64vNV = cast(typeof(glGetVertexAttribLi64vNV))load("glGetVertexAttribLi64vNV");
	glGetVertexAttribLui64vNV = cast(typeof(glGetVertexAttribLui64vNV))load("glGetVertexAttribLui64vNV");
	glVertexAttribLFormatNV = cast(typeof(glVertexAttribLFormatNV))load("glVertexAttribLFormatNV");
	return GL_NV_vertex_attrib_integer_64bit;
}


bool load_gl_GL_ATI_fragment_shader(void* function(string name) load) {
	if(!GL_ATI_fragment_shader) return GL_ATI_fragment_shader;

	glGenFragmentShadersATI = cast(typeof(glGenFragmentShadersATI))load("glGenFragmentShadersATI");
	glBindFragmentShaderATI = cast(typeof(glBindFragmentShaderATI))load("glBindFragmentShaderATI");
	glDeleteFragmentShaderATI = cast(typeof(glDeleteFragmentShaderATI))load("glDeleteFragmentShaderATI");
	glBeginFragmentShaderATI = cast(typeof(glBeginFragmentShaderATI))load("glBeginFragmentShaderATI");
	glEndFragmentShaderATI = cast(typeof(glEndFragmentShaderATI))load("glEndFragmentShaderATI");
	glPassTexCoordATI = cast(typeof(glPassTexCoordATI))load("glPassTexCoordATI");
	glSampleMapATI = cast(typeof(glSampleMapATI))load("glSampleMapATI");
	glColorFragmentOp1ATI = cast(typeof(glColorFragmentOp1ATI))load("glColorFragmentOp1ATI");
	glColorFragmentOp2ATI = cast(typeof(glColorFragmentOp2ATI))load("glColorFragmentOp2ATI");
	glColorFragmentOp3ATI = cast(typeof(glColorFragmentOp3ATI))load("glColorFragmentOp3ATI");
	glAlphaFragmentOp1ATI = cast(typeof(glAlphaFragmentOp1ATI))load("glAlphaFragmentOp1ATI");
	glAlphaFragmentOp2ATI = cast(typeof(glAlphaFragmentOp2ATI))load("glAlphaFragmentOp2ATI");
	glAlphaFragmentOp3ATI = cast(typeof(glAlphaFragmentOp3ATI))load("glAlphaFragmentOp3ATI");
	glSetFragmentShaderConstantATI = cast(typeof(glSetFragmentShaderConstantATI))load("glSetFragmentShaderConstantATI");
	return GL_ATI_fragment_shader;
}


bool load_gl_GL_ARB_vertex_array_object(void* function(string name) load) {
	if(!GL_ARB_vertex_array_object) return GL_ARB_vertex_array_object;

	glBindVertexArray = cast(typeof(glBindVertexArray))load("glBindVertexArray");
	glDeleteVertexArrays = cast(typeof(glDeleteVertexArrays))load("glDeleteVertexArrays");
	glGenVertexArrays = cast(typeof(glGenVertexArrays))load("glGenVertexArrays");
	glIsVertexArray = cast(typeof(glIsVertexArray))load("glIsVertexArray");
	return GL_ARB_vertex_array_object;
}


bool load_gl_GL_ATI_pn_triangles(void* function(string name) load) {
	if(!GL_ATI_pn_triangles) return GL_ATI_pn_triangles;

	glPNTrianglesiATI = cast(typeof(glPNTrianglesiATI))load("glPNTrianglesiATI");
	glPNTrianglesfATI = cast(typeof(glPNTrianglesfATI))load("glPNTrianglesfATI");
	return GL_ATI_pn_triangles;
}


bool load_gl_GL_EXT_texture_env_add(void* function(string name) load) {
	if(!GL_EXT_texture_env_add) return GL_EXT_texture_env_add;

	return GL_EXT_texture_env_add;
}


bool load_gl_GL_EXT_packed_depth_stencil(void* function(string name) load) {
	if(!GL_EXT_packed_depth_stencil) return GL_EXT_packed_depth_stencil;

	return GL_EXT_packed_depth_stencil;
}


bool load_gl_GL_EXT_texture_mirror_clamp(void* function(string name) load) {
	if(!GL_EXT_texture_mirror_clamp) return GL_EXT_texture_mirror_clamp;

	return GL_EXT_texture_mirror_clamp;
}


bool load_gl_GL_NV_multisample_filter_hint(void* function(string name) load) {
	if(!GL_NV_multisample_filter_hint) return GL_NV_multisample_filter_hint;

	return GL_NV_multisample_filter_hint;
}


bool load_gl_GL_APPLE_float_pixels(void* function(string name) load) {
	if(!GL_APPLE_float_pixels) return GL_APPLE_float_pixels;

	return GL_APPLE_float_pixels;
}


bool load_gl_GL_ARB_transform_feedback_instanced(void* function(string name) load) {
	if(!GL_ARB_transform_feedback_instanced) return GL_ARB_transform_feedback_instanced;

	glDrawTransformFeedbackInstanced = cast(typeof(glDrawTransformFeedbackInstanced))load("glDrawTransformFeedbackInstanced");
	glDrawTransformFeedbackStreamInstanced = cast(typeof(glDrawTransformFeedbackStreamInstanced))load("glDrawTransformFeedbackStreamInstanced");
	return GL_ARB_transform_feedback_instanced;
}


bool load_gl_GL_SGIX_async(void* function(string name) load) {
	if(!GL_SGIX_async) return GL_SGIX_async;

	glAsyncMarkerSGIX = cast(typeof(glAsyncMarkerSGIX))load("glAsyncMarkerSGIX");
	glFinishAsyncSGIX = cast(typeof(glFinishAsyncSGIX))load("glFinishAsyncSGIX");
	glPollAsyncSGIX = cast(typeof(glPollAsyncSGIX))load("glPollAsyncSGIX");
	glGenAsyncMarkersSGIX = cast(typeof(glGenAsyncMarkersSGIX))load("glGenAsyncMarkersSGIX");
	glDeleteAsyncMarkersSGIX = cast(typeof(glDeleteAsyncMarkersSGIX))load("glDeleteAsyncMarkersSGIX");
	glIsAsyncMarkerSGIX = cast(typeof(glIsAsyncMarkerSGIX))load("glIsAsyncMarkerSGIX");
	return GL_SGIX_async;
}


bool load_gl_GL_EXT_texture_compression_latc(void* function(string name) load) {
	if(!GL_EXT_texture_compression_latc) return GL_EXT_texture_compression_latc;

	return GL_EXT_texture_compression_latc;
}


bool load_gl_GL_NV_shader_atomic_float(void* function(string name) load) {
	if(!GL_NV_shader_atomic_float) return GL_NV_shader_atomic_float;

	return GL_NV_shader_atomic_float;
}


bool load_gl_GL_ARB_shading_language_100(void* function(string name) load) {
	if(!GL_ARB_shading_language_100) return GL_ARB_shading_language_100;

	return GL_ARB_shading_language_100;
}


bool load_gl_GL_ARB_texture_mirror_clamp_to_edge(void* function(string name) load) {
	if(!GL_ARB_texture_mirror_clamp_to_edge) return GL_ARB_texture_mirror_clamp_to_edge;

	return GL_ARB_texture_mirror_clamp_to_edge;
}


bool load_gl_GL_NV_vertex_program2(void* function(string name) load) {
	if(!GL_NV_vertex_program2) return GL_NV_vertex_program2;

	return GL_NV_vertex_program2;
}


bool load_gl_GL_ARB_draw_indirect(void* function(string name) load) {
	if(!GL_ARB_draw_indirect) return GL_ARB_draw_indirect;

	glDrawArraysIndirect = cast(typeof(glDrawArraysIndirect))load("glDrawArraysIndirect");
	glDrawElementsIndirect = cast(typeof(glDrawElementsIndirect))load("glDrawElementsIndirect");
	return GL_ARB_draw_indirect;
}


bool load_gl_GL_ARB_ES2_compatibility(void* function(string name) load) {
	if(!GL_ARB_ES2_compatibility) return GL_ARB_ES2_compatibility;

	glReleaseShaderCompiler = cast(typeof(glReleaseShaderCompiler))load("glReleaseShaderCompiler");
	glShaderBinary = cast(typeof(glShaderBinary))load("glShaderBinary");
	glGetShaderPrecisionFormat = cast(typeof(glGetShaderPrecisionFormat))load("glGetShaderPrecisionFormat");
	glDepthRangef = cast(typeof(glDepthRangef))load("glDepthRangef");
	glClearDepthf = cast(typeof(glClearDepthf))load("glClearDepthf");
	return GL_ARB_ES2_compatibility;
}


bool load_gl_GL_ARB_indirect_parameters(void* function(string name) load) {
	if(!GL_ARB_indirect_parameters) return GL_ARB_indirect_parameters;

	glMultiDrawArraysIndirectCountARB = cast(typeof(glMultiDrawArraysIndirectCountARB))load("glMultiDrawArraysIndirectCountARB");
	glMultiDrawElementsIndirectCountARB = cast(typeof(glMultiDrawElementsIndirectCountARB))load("glMultiDrawElementsIndirectCountARB");
	return GL_ARB_indirect_parameters;
}


bool load_gl_GL_NV_half_float(void* function(string name) load) {
	if(!GL_NV_half_float) return GL_NV_half_float;

	glVertex2hNV = cast(typeof(glVertex2hNV))load("glVertex2hNV");
	glVertex2hvNV = cast(typeof(glVertex2hvNV))load("glVertex2hvNV");
	glVertex3hNV = cast(typeof(glVertex3hNV))load("glVertex3hNV");
	glVertex3hvNV = cast(typeof(glVertex3hvNV))load("glVertex3hvNV");
	glVertex4hNV = cast(typeof(glVertex4hNV))load("glVertex4hNV");
	glVertex4hvNV = cast(typeof(glVertex4hvNV))load("glVertex4hvNV");
	glNormal3hNV = cast(typeof(glNormal3hNV))load("glNormal3hNV");
	glNormal3hvNV = cast(typeof(glNormal3hvNV))load("glNormal3hvNV");
	glColor3hNV = cast(typeof(glColor3hNV))load("glColor3hNV");
	glColor3hvNV = cast(typeof(glColor3hvNV))load("glColor3hvNV");
	glColor4hNV = cast(typeof(glColor4hNV))load("glColor4hNV");
	glColor4hvNV = cast(typeof(glColor4hvNV))load("glColor4hvNV");
	glTexCoord1hNV = cast(typeof(glTexCoord1hNV))load("glTexCoord1hNV");
	glTexCoord1hvNV = cast(typeof(glTexCoord1hvNV))load("glTexCoord1hvNV");
	glTexCoord2hNV = cast(typeof(glTexCoord2hNV))load("glTexCoord2hNV");
	glTexCoord2hvNV = cast(typeof(glTexCoord2hvNV))load("glTexCoord2hvNV");
	glTexCoord3hNV = cast(typeof(glTexCoord3hNV))load("glTexCoord3hNV");
	glTexCoord3hvNV = cast(typeof(glTexCoord3hvNV))load("glTexCoord3hvNV");
	glTexCoord4hNV = cast(typeof(glTexCoord4hNV))load("glTexCoord4hNV");
	glTexCoord4hvNV = cast(typeof(glTexCoord4hvNV))load("glTexCoord4hvNV");
	glMultiTexCoord1hNV = cast(typeof(glMultiTexCoord1hNV))load("glMultiTexCoord1hNV");
	glMultiTexCoord1hvNV = cast(typeof(glMultiTexCoord1hvNV))load("glMultiTexCoord1hvNV");
	glMultiTexCoord2hNV = cast(typeof(glMultiTexCoord2hNV))load("glMultiTexCoord2hNV");
	glMultiTexCoord2hvNV = cast(typeof(glMultiTexCoord2hvNV))load("glMultiTexCoord2hvNV");
	glMultiTexCoord3hNV = cast(typeof(glMultiTexCoord3hNV))load("glMultiTexCoord3hNV");
	glMultiTexCoord3hvNV = cast(typeof(glMultiTexCoord3hvNV))load("glMultiTexCoord3hvNV");
	glMultiTexCoord4hNV = cast(typeof(glMultiTexCoord4hNV))load("glMultiTexCoord4hNV");
	glMultiTexCoord4hvNV = cast(typeof(glMultiTexCoord4hvNV))load("glMultiTexCoord4hvNV");
	glFogCoordhNV = cast(typeof(glFogCoordhNV))load("glFogCoordhNV");
	glFogCoordhvNV = cast(typeof(glFogCoordhvNV))load("glFogCoordhvNV");
	glSecondaryColor3hNV = cast(typeof(glSecondaryColor3hNV))load("glSecondaryColor3hNV");
	glSecondaryColor3hvNV = cast(typeof(glSecondaryColor3hvNV))load("glSecondaryColor3hvNV");
	glVertexWeighthNV = cast(typeof(glVertexWeighthNV))load("glVertexWeighthNV");
	glVertexWeighthvNV = cast(typeof(glVertexWeighthvNV))load("glVertexWeighthvNV");
	glVertexAttrib1hNV = cast(typeof(glVertexAttrib1hNV))load("glVertexAttrib1hNV");
	glVertexAttrib1hvNV = cast(typeof(glVertexAttrib1hvNV))load("glVertexAttrib1hvNV");
	glVertexAttrib2hNV = cast(typeof(glVertexAttrib2hNV))load("glVertexAttrib2hNV");
	glVertexAttrib2hvNV = cast(typeof(glVertexAttrib2hvNV))load("glVertexAttrib2hvNV");
	glVertexAttrib3hNV = cast(typeof(glVertexAttrib3hNV))load("glVertexAttrib3hNV");
	glVertexAttrib3hvNV = cast(typeof(glVertexAttrib3hvNV))load("glVertexAttrib3hvNV");
	glVertexAttrib4hNV = cast(typeof(glVertexAttrib4hNV))load("glVertexAttrib4hNV");
	glVertexAttrib4hvNV = cast(typeof(glVertexAttrib4hvNV))load("glVertexAttrib4hvNV");
	glVertexAttribs1hvNV = cast(typeof(glVertexAttribs1hvNV))load("glVertexAttribs1hvNV");
	glVertexAttribs2hvNV = cast(typeof(glVertexAttribs2hvNV))load("glVertexAttribs2hvNV");
	glVertexAttribs3hvNV = cast(typeof(glVertexAttribs3hvNV))load("glVertexAttribs3hvNV");
	glVertexAttribs4hvNV = cast(typeof(glVertexAttribs4hvNV))load("glVertexAttribs4hvNV");
	return GL_NV_half_float;
}


bool load_gl_GL_EXT_coordinate_frame(void* function(string name) load) {
	if(!GL_EXT_coordinate_frame) return GL_EXT_coordinate_frame;

	glTangent3bEXT = cast(typeof(glTangent3bEXT))load("glTangent3bEXT");
	glTangent3bvEXT = cast(typeof(glTangent3bvEXT))load("glTangent3bvEXT");
	glTangent3dEXT = cast(typeof(glTangent3dEXT))load("glTangent3dEXT");
	glTangent3dvEXT = cast(typeof(glTangent3dvEXT))load("glTangent3dvEXT");
	glTangent3fEXT = cast(typeof(glTangent3fEXT))load("glTangent3fEXT");
	glTangent3fvEXT = cast(typeof(glTangent3fvEXT))load("glTangent3fvEXT");
	glTangent3iEXT = cast(typeof(glTangent3iEXT))load("glTangent3iEXT");
	glTangent3ivEXT = cast(typeof(glTangent3ivEXT))load("glTangent3ivEXT");
	glTangent3sEXT = cast(typeof(glTangent3sEXT))load("glTangent3sEXT");
	glTangent3svEXT = cast(typeof(glTangent3svEXT))load("glTangent3svEXT");
	glBinormal3bEXT = cast(typeof(glBinormal3bEXT))load("glBinormal3bEXT");
	glBinormal3bvEXT = cast(typeof(glBinormal3bvEXT))load("glBinormal3bvEXT");
	glBinormal3dEXT = cast(typeof(glBinormal3dEXT))load("glBinormal3dEXT");
	glBinormal3dvEXT = cast(typeof(glBinormal3dvEXT))load("glBinormal3dvEXT");
	glBinormal3fEXT = cast(typeof(glBinormal3fEXT))load("glBinormal3fEXT");
	glBinormal3fvEXT = cast(typeof(glBinormal3fvEXT))load("glBinormal3fvEXT");
	glBinormal3iEXT = cast(typeof(glBinormal3iEXT))load("glBinormal3iEXT");
	glBinormal3ivEXT = cast(typeof(glBinormal3ivEXT))load("glBinormal3ivEXT");
	glBinormal3sEXT = cast(typeof(glBinormal3sEXT))load("glBinormal3sEXT");
	glBinormal3svEXT = cast(typeof(glBinormal3svEXT))load("glBinormal3svEXT");
	glTangentPointerEXT = cast(typeof(glTangentPointerEXT))load("glTangentPointerEXT");
	glBinormalPointerEXT = cast(typeof(glBinormalPointerEXT))load("glBinormalPointerEXT");
	return GL_EXT_coordinate_frame;
}


bool load_gl_GL_ATI_texture_mirror_once(void* function(string name) load) {
	if(!GL_ATI_texture_mirror_once) return GL_ATI_texture_mirror_once;

	return GL_ATI_texture_mirror_once;
}


bool load_gl_GL_IBM_rasterpos_clip(void* function(string name) load) {
	if(!GL_IBM_rasterpos_clip) return GL_IBM_rasterpos_clip;

	return GL_IBM_rasterpos_clip;
}


bool load_gl_GL_SGIX_shadow(void* function(string name) load) {
	if(!GL_SGIX_shadow) return GL_SGIX_shadow;

	return GL_SGIX_shadow;
}


bool load_gl_GL_NV_deep_texture3D(void* function(string name) load) {
	if(!GL_NV_deep_texture3D) return GL_NV_deep_texture3D;

	return GL_NV_deep_texture3D;
}


bool load_gl_GL_ARB_shader_draw_parameters(void* function(string name) load) {
	if(!GL_ARB_shader_draw_parameters) return GL_ARB_shader_draw_parameters;

	return GL_ARB_shader_draw_parameters;
}


bool load_gl_GL_SGIX_calligraphic_fragment(void* function(string name) load) {
	if(!GL_SGIX_calligraphic_fragment) return GL_SGIX_calligraphic_fragment;

	return GL_SGIX_calligraphic_fragment;
}


bool load_gl_GL_ARB_shader_bit_encoding(void* function(string name) load) {
	if(!GL_ARB_shader_bit_encoding) return GL_ARB_shader_bit_encoding;

	return GL_ARB_shader_bit_encoding;
}


bool load_gl_GL_EXT_compiled_vertex_array(void* function(string name) load) {
	if(!GL_EXT_compiled_vertex_array) return GL_EXT_compiled_vertex_array;

	glLockArraysEXT = cast(typeof(glLockArraysEXT))load("glLockArraysEXT");
	glUnlockArraysEXT = cast(typeof(glUnlockArraysEXT))load("glUnlockArraysEXT");
	return GL_EXT_compiled_vertex_array;
}


bool load_gl_GL_NV_depth_buffer_float(void* function(string name) load) {
	if(!GL_NV_depth_buffer_float) return GL_NV_depth_buffer_float;

	glDepthRangedNV = cast(typeof(glDepthRangedNV))load("glDepthRangedNV");
	glClearDepthdNV = cast(typeof(glClearDepthdNV))load("glClearDepthdNV");
	glDepthBoundsdNV = cast(typeof(glDepthBoundsdNV))load("glDepthBoundsdNV");
	return GL_NV_depth_buffer_float;
}


bool load_gl_GL_APPLE_flush_buffer_range(void* function(string name) load) {
	if(!GL_APPLE_flush_buffer_range) return GL_APPLE_flush_buffer_range;

	glBufferParameteriAPPLE = cast(typeof(glBufferParameteriAPPLE))load("glBufferParameteriAPPLE");
	glFlushMappedBufferRangeAPPLE = cast(typeof(glFlushMappedBufferRangeAPPLE))load("glFlushMappedBufferRangeAPPLE");
	return GL_APPLE_flush_buffer_range;
}


bool load_gl_GL_ARB_imaging(void* function(string name) load) {
	if(!GL_ARB_imaging) return GL_ARB_imaging;

	glColorTable = cast(typeof(glColorTable))load("glColorTable");
	glColorTableParameterfv = cast(typeof(glColorTableParameterfv))load("glColorTableParameterfv");
	glColorTableParameteriv = cast(typeof(glColorTableParameteriv))load("glColorTableParameteriv");
	glCopyColorTable = cast(typeof(glCopyColorTable))load("glCopyColorTable");
	glGetColorTable = cast(typeof(glGetColorTable))load("glGetColorTable");
	glGetColorTableParameterfv = cast(typeof(glGetColorTableParameterfv))load("glGetColorTableParameterfv");
	glGetColorTableParameteriv = cast(typeof(glGetColorTableParameteriv))load("glGetColorTableParameteriv");
	glColorSubTable = cast(typeof(glColorSubTable))load("glColorSubTable");
	glCopyColorSubTable = cast(typeof(glCopyColorSubTable))load("glCopyColorSubTable");
	glConvolutionFilter1D = cast(typeof(glConvolutionFilter1D))load("glConvolutionFilter1D");
	glConvolutionFilter2D = cast(typeof(glConvolutionFilter2D))load("glConvolutionFilter2D");
	glConvolutionParameterf = cast(typeof(glConvolutionParameterf))load("glConvolutionParameterf");
	glConvolutionParameterfv = cast(typeof(glConvolutionParameterfv))load("glConvolutionParameterfv");
	glConvolutionParameteri = cast(typeof(glConvolutionParameteri))load("glConvolutionParameteri");
	glConvolutionParameteriv = cast(typeof(glConvolutionParameteriv))load("glConvolutionParameteriv");
	glCopyConvolutionFilter1D = cast(typeof(glCopyConvolutionFilter1D))load("glCopyConvolutionFilter1D");
	glCopyConvolutionFilter2D = cast(typeof(glCopyConvolutionFilter2D))load("glCopyConvolutionFilter2D");
	glGetConvolutionFilter = cast(typeof(glGetConvolutionFilter))load("glGetConvolutionFilter");
	glGetConvolutionParameterfv = cast(typeof(glGetConvolutionParameterfv))load("glGetConvolutionParameterfv");
	glGetConvolutionParameteriv = cast(typeof(glGetConvolutionParameteriv))load("glGetConvolutionParameteriv");
	glGetSeparableFilter = cast(typeof(glGetSeparableFilter))load("glGetSeparableFilter");
	glSeparableFilter2D = cast(typeof(glSeparableFilter2D))load("glSeparableFilter2D");
	glGetHistogram = cast(typeof(glGetHistogram))load("glGetHistogram");
	glGetHistogramParameterfv = cast(typeof(glGetHistogramParameterfv))load("glGetHistogramParameterfv");
	glGetHistogramParameteriv = cast(typeof(glGetHistogramParameteriv))load("glGetHistogramParameteriv");
	glGetMinmax = cast(typeof(glGetMinmax))load("glGetMinmax");
	glGetMinmaxParameterfv = cast(typeof(glGetMinmaxParameterfv))load("glGetMinmaxParameterfv");
	glGetMinmaxParameteriv = cast(typeof(glGetMinmaxParameteriv))load("glGetMinmaxParameteriv");
	glHistogram = cast(typeof(glHistogram))load("glHistogram");
	glMinmax = cast(typeof(glMinmax))load("glMinmax");
	glResetHistogram = cast(typeof(glResetHistogram))load("glResetHistogram");
	glResetMinmax = cast(typeof(glResetMinmax))load("glResetMinmax");
	return GL_ARB_imaging;
}


bool load_gl_GL_ARB_sync(void* function(string name) load) {
	if(!GL_ARB_sync) return GL_ARB_sync;

	glFenceSync = cast(typeof(glFenceSync))load("glFenceSync");
	glIsSync = cast(typeof(glIsSync))load("glIsSync");
	glDeleteSync = cast(typeof(glDeleteSync))load("glDeleteSync");
	glClientWaitSync = cast(typeof(glClientWaitSync))load("glClientWaitSync");
	glWaitSync = cast(typeof(glWaitSync))load("glWaitSync");
	glGetInteger64v = cast(typeof(glGetInteger64v))load("glGetInteger64v");
	glGetSynciv = cast(typeof(glGetSynciv))load("glGetSynciv");
	return GL_ARB_sync;
}


bool load_gl_GL_ARB_draw_buffers_blend(void* function(string name) load) {
	if(!GL_ARB_draw_buffers_blend) return GL_ARB_draw_buffers_blend;

	glBlendEquationiARB = cast(typeof(glBlendEquationiARB))load("glBlendEquationiARB");
	glBlendEquationSeparateiARB = cast(typeof(glBlendEquationSeparateiARB))load("glBlendEquationSeparateiARB");
	glBlendFunciARB = cast(typeof(glBlendFunciARB))load("glBlendFunciARB");
	glBlendFuncSeparateiARB = cast(typeof(glBlendFuncSeparateiARB))load("glBlendFuncSeparateiARB");
	return GL_ARB_draw_buffers_blend;
}


bool load_gl_GL_NV_blend_square(void* function(string name) load) {
	if(!GL_NV_blend_square) return GL_NV_blend_square;

	return GL_NV_blend_square;
}


bool load_gl_GL_AMD_blend_minmax_factor(void* function(string name) load) {
	if(!GL_AMD_blend_minmax_factor) return GL_AMD_blend_minmax_factor;

	return GL_AMD_blend_minmax_factor;
}


bool load_gl_GL_EXT_texture_sRGB_decode(void* function(string name) load) {
	if(!GL_EXT_texture_sRGB_decode) return GL_EXT_texture_sRGB_decode;

	return GL_EXT_texture_sRGB_decode;
}


bool load_gl_GL_ARB_shading_language_420pack(void* function(string name) load) {
	if(!GL_ARB_shading_language_420pack) return GL_ARB_shading_language_420pack;

	return GL_ARB_shading_language_420pack;
}


bool load_gl_GL_ATI_meminfo(void* function(string name) load) {
	if(!GL_ATI_meminfo) return GL_ATI_meminfo;

	return GL_ATI_meminfo;
}


bool load_gl_GL_EXT_abgr(void* function(string name) load) {
	if(!GL_EXT_abgr) return GL_EXT_abgr;

	return GL_EXT_abgr;
}


bool load_gl_GL_AMD_pinned_memory(void* function(string name) load) {
	if(!GL_AMD_pinned_memory) return GL_AMD_pinned_memory;

	return GL_AMD_pinned_memory;
}


bool load_gl_GL_EXT_texture_snorm(void* function(string name) load) {
	if(!GL_EXT_texture_snorm) return GL_EXT_texture_snorm;

	return GL_EXT_texture_snorm;
}


bool load_gl_GL_SGIX_texture_coordinate_clamp(void* function(string name) load) {
	if(!GL_SGIX_texture_coordinate_clamp) return GL_SGIX_texture_coordinate_clamp;

	return GL_SGIX_texture_coordinate_clamp;
}


bool load_gl_GL_ARB_clear_buffer_object(void* function(string name) load) {
	if(!GL_ARB_clear_buffer_object) return GL_ARB_clear_buffer_object;

	glClearBufferData = cast(typeof(glClearBufferData))load("glClearBufferData");
	glClearBufferSubData = cast(typeof(glClearBufferSubData))load("glClearBufferSubData");
	return GL_ARB_clear_buffer_object;
}


bool load_gl_GL_ARB_multisample(void* function(string name) load) {
	if(!GL_ARB_multisample) return GL_ARB_multisample;

	glSampleCoverageARB = cast(typeof(glSampleCoverageARB))load("glSampleCoverageARB");
	return GL_ARB_multisample;
}


bool load_gl_GL_ARB_sample_shading(void* function(string name) load) {
	if(!GL_ARB_sample_shading) return GL_ARB_sample_shading;

	glMinSampleShadingARB = cast(typeof(glMinSampleShadingARB))load("glMinSampleShadingARB");
	return GL_ARB_sample_shading;
}


bool load_gl_GL_INTEL_map_texture(void* function(string name) load) {
	if(!GL_INTEL_map_texture) return GL_INTEL_map_texture;

	glSyncTextureINTEL = cast(typeof(glSyncTextureINTEL))load("glSyncTextureINTEL");
	glUnmapTexture2DINTEL = cast(typeof(glUnmapTexture2DINTEL))load("glUnmapTexture2DINTEL");
	glMapTexture2DINTEL = cast(typeof(glMapTexture2DINTEL))load("glMapTexture2DINTEL");
	return GL_INTEL_map_texture;
}


bool load_gl_GL_ARB_texture_env_crossbar(void* function(string name) load) {
	if(!GL_ARB_texture_env_crossbar) return GL_ARB_texture_env_crossbar;

	return GL_ARB_texture_env_crossbar;
}


bool load_gl_GL_EXT_422_pixels(void* function(string name) load) {
	if(!GL_EXT_422_pixels) return GL_EXT_422_pixels;

	return GL_EXT_422_pixels;
}


bool load_gl_GL_ARB_compute_shader(void* function(string name) load) {
	if(!GL_ARB_compute_shader) return GL_ARB_compute_shader;

	glDispatchCompute = cast(typeof(glDispatchCompute))load("glDispatchCompute");
	glDispatchComputeIndirect = cast(typeof(glDispatchComputeIndirect))load("glDispatchComputeIndirect");
	return GL_ARB_compute_shader;
}


bool load_gl_GL_EXT_blend_logic_op(void* function(string name) load) {
	if(!GL_EXT_blend_logic_op) return GL_EXT_blend_logic_op;

	return GL_EXT_blend_logic_op;
}


bool load_gl_GL_IBM_cull_vertex(void* function(string name) load) {
	if(!GL_IBM_cull_vertex) return GL_IBM_cull_vertex;

	return GL_IBM_cull_vertex;
}


bool load_gl_GL_IBM_vertex_array_lists(void* function(string name) load) {
	if(!GL_IBM_vertex_array_lists) return GL_IBM_vertex_array_lists;

	glColorPointerListIBM = cast(typeof(glColorPointerListIBM))load("glColorPointerListIBM");
	glSecondaryColorPointerListIBM = cast(typeof(glSecondaryColorPointerListIBM))load("glSecondaryColorPointerListIBM");
	glEdgeFlagPointerListIBM = cast(typeof(glEdgeFlagPointerListIBM))load("glEdgeFlagPointerListIBM");
	glFogCoordPointerListIBM = cast(typeof(glFogCoordPointerListIBM))load("glFogCoordPointerListIBM");
	glIndexPointerListIBM = cast(typeof(glIndexPointerListIBM))load("glIndexPointerListIBM");
	glNormalPointerListIBM = cast(typeof(glNormalPointerListIBM))load("glNormalPointerListIBM");
	glTexCoordPointerListIBM = cast(typeof(glTexCoordPointerListIBM))load("glTexCoordPointerListIBM");
	glVertexPointerListIBM = cast(typeof(glVertexPointerListIBM))load("glVertexPointerListIBM");
	return GL_IBM_vertex_array_lists;
}


bool load_gl_GL_ARB_color_buffer_float(void* function(string name) load) {
	if(!GL_ARB_color_buffer_float) return GL_ARB_color_buffer_float;

	glClampColorARB = cast(typeof(glClampColorARB))load("glClampColorARB");
	return GL_ARB_color_buffer_float;
}


bool load_gl_GL_ARB_bindless_texture(void* function(string name) load) {
	if(!GL_ARB_bindless_texture) return GL_ARB_bindless_texture;

	glGetTextureHandleARB = cast(typeof(glGetTextureHandleARB))load("glGetTextureHandleARB");
	glGetTextureSamplerHandleARB = cast(typeof(glGetTextureSamplerHandleARB))load("glGetTextureSamplerHandleARB");
	glMakeTextureHandleResidentARB = cast(typeof(glMakeTextureHandleResidentARB))load("glMakeTextureHandleResidentARB");
	glMakeTextureHandleNonResidentARB = cast(typeof(glMakeTextureHandleNonResidentARB))load("glMakeTextureHandleNonResidentARB");
	glGetImageHandleARB = cast(typeof(glGetImageHandleARB))load("glGetImageHandleARB");
	glMakeImageHandleResidentARB = cast(typeof(glMakeImageHandleResidentARB))load("glMakeImageHandleResidentARB");
	glMakeImageHandleNonResidentARB = cast(typeof(glMakeImageHandleNonResidentARB))load("glMakeImageHandleNonResidentARB");
	glUniformHandleui64ARB = cast(typeof(glUniformHandleui64ARB))load("glUniformHandleui64ARB");
	glUniformHandleui64vARB = cast(typeof(glUniformHandleui64vARB))load("glUniformHandleui64vARB");
	glProgramUniformHandleui64ARB = cast(typeof(glProgramUniformHandleui64ARB))load("glProgramUniformHandleui64ARB");
	glProgramUniformHandleui64vARB = cast(typeof(glProgramUniformHandleui64vARB))load("glProgramUniformHandleui64vARB");
	glIsTextureHandleResidentARB = cast(typeof(glIsTextureHandleResidentARB))load("glIsTextureHandleResidentARB");
	glIsImageHandleResidentARB = cast(typeof(glIsImageHandleResidentARB))load("glIsImageHandleResidentARB");
	glVertexAttribL1ui64ARB = cast(typeof(glVertexAttribL1ui64ARB))load("glVertexAttribL1ui64ARB");
	glVertexAttribL1ui64vARB = cast(typeof(glVertexAttribL1ui64vARB))load("glVertexAttribL1ui64vARB");
	glGetVertexAttribLui64vARB = cast(typeof(glGetVertexAttribLui64vARB))load("glGetVertexAttribLui64vARB");
	return GL_ARB_bindless_texture;
}


bool load_gl_GL_ARB_window_pos(void* function(string name) load) {
	if(!GL_ARB_window_pos) return GL_ARB_window_pos;

	glWindowPos2dARB = cast(typeof(glWindowPos2dARB))load("glWindowPos2dARB");
	glWindowPos2dvARB = cast(typeof(glWindowPos2dvARB))load("glWindowPos2dvARB");
	glWindowPos2fARB = cast(typeof(glWindowPos2fARB))load("glWindowPos2fARB");
	glWindowPos2fvARB = cast(typeof(glWindowPos2fvARB))load("glWindowPos2fvARB");
	glWindowPos2iARB = cast(typeof(glWindowPos2iARB))load("glWindowPos2iARB");
	glWindowPos2ivARB = cast(typeof(glWindowPos2ivARB))load("glWindowPos2ivARB");
	glWindowPos2sARB = cast(typeof(glWindowPos2sARB))load("glWindowPos2sARB");
	glWindowPos2svARB = cast(typeof(glWindowPos2svARB))load("glWindowPos2svARB");
	glWindowPos3dARB = cast(typeof(glWindowPos3dARB))load("glWindowPos3dARB");
	glWindowPos3dvARB = cast(typeof(glWindowPos3dvARB))load("glWindowPos3dvARB");
	glWindowPos3fARB = cast(typeof(glWindowPos3fARB))load("glWindowPos3fARB");
	glWindowPos3fvARB = cast(typeof(glWindowPos3fvARB))load("glWindowPos3fvARB");
	glWindowPos3iARB = cast(typeof(glWindowPos3iARB))load("glWindowPos3iARB");
	glWindowPos3ivARB = cast(typeof(glWindowPos3ivARB))load("glWindowPos3ivARB");
	glWindowPos3sARB = cast(typeof(glWindowPos3sARB))load("glWindowPos3sARB");
	glWindowPos3svARB = cast(typeof(glWindowPos3svARB))load("glWindowPos3svARB");
	return GL_ARB_window_pos;
}


bool load_gl_GL_ARB_internalformat_query(void* function(string name) load) {
	if(!GL_ARB_internalformat_query) return GL_ARB_internalformat_query;

	glGetInternalformativ = cast(typeof(glGetInternalformativ))load("glGetInternalformativ");
	return GL_ARB_internalformat_query;
}


bool load_gl_GL_ARB_shadow(void* function(string name) load) {
	if(!GL_ARB_shadow) return GL_ARB_shadow;

	return GL_ARB_shadow;
}


bool load_gl_GL_ARB_texture_mirrored_repeat(void* function(string name) load) {
	if(!GL_ARB_texture_mirrored_repeat) return GL_ARB_texture_mirrored_repeat;

	return GL_ARB_texture_mirrored_repeat;
}


bool load_gl_GL_EXT_shader_image_load_store(void* function(string name) load) {
	if(!GL_EXT_shader_image_load_store) return GL_EXT_shader_image_load_store;

	glBindImageTextureEXT = cast(typeof(glBindImageTextureEXT))load("glBindImageTextureEXT");
	glMemoryBarrierEXT = cast(typeof(glMemoryBarrierEXT))load("glMemoryBarrierEXT");
	return GL_EXT_shader_image_load_store;
}


bool load_gl_GL_EXT_copy_texture(void* function(string name) load) {
	if(!GL_EXT_copy_texture) return GL_EXT_copy_texture;

	glCopyTexImage1DEXT = cast(typeof(glCopyTexImage1DEXT))load("glCopyTexImage1DEXT");
	glCopyTexImage2DEXT = cast(typeof(glCopyTexImage2DEXT))load("glCopyTexImage2DEXT");
	glCopyTexSubImage1DEXT = cast(typeof(glCopyTexSubImage1DEXT))load("glCopyTexSubImage1DEXT");
	glCopyTexSubImage2DEXT = cast(typeof(glCopyTexSubImage2DEXT))load("glCopyTexSubImage2DEXT");
	glCopyTexSubImage3DEXT = cast(typeof(glCopyTexSubImage3DEXT))load("glCopyTexSubImage3DEXT");
	return GL_EXT_copy_texture;
}


bool load_gl_GL_NV_register_combiners2(void* function(string name) load) {
	if(!GL_NV_register_combiners2) return GL_NV_register_combiners2;

	glCombinerStageParameterfvNV = cast(typeof(glCombinerStageParameterfvNV))load("glCombinerStageParameterfvNV");
	glGetCombinerStageParameterfvNV = cast(typeof(glGetCombinerStageParameterfvNV))load("glGetCombinerStageParameterfvNV");
	return GL_NV_register_combiners2;
}


void load_gl_GL_VERSION_4_2(void* function(string name) load) {
	if(!GL_VERSION_4_2) return;
	glDrawArraysInstancedBaseInstance = cast(typeof(glDrawArraysInstancedBaseInstance))load("glDrawArraysInstancedBaseInstance");
	glDrawElementsInstancedBaseInstance = cast(typeof(glDrawElementsInstancedBaseInstance))load("glDrawElementsInstancedBaseInstance");
	glDrawElementsInstancedBaseVertexBaseInstance = cast(typeof(glDrawElementsInstancedBaseVertexBaseInstance))load("glDrawElementsInstancedBaseVertexBaseInstance");
	glGetInternalformati64v = cast(typeof(glGetInternalformati64v))load("glGetInternalformati64v");
	glGetActiveAtomicCounterBufferiv = cast(typeof(glGetActiveAtomicCounterBufferiv))load("glGetActiveAtomicCounterBufferiv");
	glBindImageTexture = cast(typeof(glBindImageTexture))load("glBindImageTexture");
	glMemoryBarrier = cast(typeof(glMemoryBarrier))load("glMemoryBarrier");
	glTexStorage1D = cast(typeof(glTexStorage1D))load("glTexStorage1D");
	glTexStorage2D = cast(typeof(glTexStorage2D))load("glTexStorage2D");
	glTexStorage3D = cast(typeof(glTexStorage3D))load("glTexStorage3D");
	glDrawTransformFeedbackInstanced = cast(typeof(glDrawTransformFeedbackInstanced))load("glDrawTransformFeedbackInstanced");
	glDrawTransformFeedbackStreamInstanced = cast(typeof(glDrawTransformFeedbackStreamInstanced))load("glDrawTransformFeedbackStreamInstanced");
	return;
}

void load_gl_GL_VERSION_4_3(void* function(string name) load) {
	if(!GL_VERSION_4_3) return;
	glClearBufferData = cast(typeof(glClearBufferData))load("glClearBufferData");
	glClearBufferSubData = cast(typeof(glClearBufferSubData))load("glClearBufferSubData");
	glDispatchCompute = cast(typeof(glDispatchCompute))load("glDispatchCompute");
	glDispatchComputeIndirect = cast(typeof(glDispatchComputeIndirect))load("glDispatchComputeIndirect");
	glCopyImageSubData = cast(typeof(glCopyImageSubData))load("glCopyImageSubData");
	glFramebufferParameteri = cast(typeof(glFramebufferParameteri))load("glFramebufferParameteri");
	glGetFramebufferParameteriv = cast(typeof(glGetFramebufferParameteriv))load("glGetFramebufferParameteriv");
	glGetInternalformati64v = cast(typeof(glGetInternalformati64v))load("glGetInternalformati64v");
	glInvalidateTexSubImage = cast(typeof(glInvalidateTexSubImage))load("glInvalidateTexSubImage");
	glInvalidateTexImage = cast(typeof(glInvalidateTexImage))load("glInvalidateTexImage");
	glInvalidateBufferSubData = cast(typeof(glInvalidateBufferSubData))load("glInvalidateBufferSubData");
	glInvalidateBufferData = cast(typeof(glInvalidateBufferData))load("glInvalidateBufferData");
	glInvalidateFramebuffer = cast(typeof(glInvalidateFramebuffer))load("glInvalidateFramebuffer");
	glInvalidateSubFramebuffer = cast(typeof(glInvalidateSubFramebuffer))load("glInvalidateSubFramebuffer");
	glMultiDrawArraysIndirect = cast(typeof(glMultiDrawArraysIndirect))load("glMultiDrawArraysIndirect");
	glMultiDrawElementsIndirect = cast(typeof(glMultiDrawElementsIndirect))load("glMultiDrawElementsIndirect");
	glGetProgramInterfaceiv = cast(typeof(glGetProgramInterfaceiv))load("glGetProgramInterfaceiv");
	glGetProgramResourceIndex = cast(typeof(glGetProgramResourceIndex))load("glGetProgramResourceIndex");
	glGetProgramResourceName = cast(typeof(glGetProgramResourceName))load("glGetProgramResourceName");
	glGetProgramResourceiv = cast(typeof(glGetProgramResourceiv))load("glGetProgramResourceiv");
	glGetProgramResourceLocation = cast(typeof(glGetProgramResourceLocation))load("glGetProgramResourceLocation");
	glGetProgramResourceLocationIndex = cast(typeof(glGetProgramResourceLocationIndex))load("glGetProgramResourceLocationIndex");
	glShaderStorageBlockBinding = cast(typeof(glShaderStorageBlockBinding))load("glShaderStorageBlockBinding");
	glTexBufferRange = cast(typeof(glTexBufferRange))load("glTexBufferRange");
	glTexStorage2DMultisample = cast(typeof(glTexStorage2DMultisample))load("glTexStorage2DMultisample");
	glTexStorage3DMultisample = cast(typeof(glTexStorage3DMultisample))load("glTexStorage3DMultisample");
	glTextureView = cast(typeof(glTextureView))load("glTextureView");
	glBindVertexBuffer = cast(typeof(glBindVertexBuffer))load("glBindVertexBuffer");
	glVertexAttribFormat = cast(typeof(glVertexAttribFormat))load("glVertexAttribFormat");
	glVertexAttribIFormat = cast(typeof(glVertexAttribIFormat))load("glVertexAttribIFormat");
	glVertexAttribLFormat = cast(typeof(glVertexAttribLFormat))load("glVertexAttribLFormat");
	glVertexAttribBinding = cast(typeof(glVertexAttribBinding))load("glVertexAttribBinding");
	glVertexBindingDivisor = cast(typeof(glVertexBindingDivisor))load("glVertexBindingDivisor");
	glDebugMessageControl = cast(typeof(glDebugMessageControl))load("glDebugMessageControl");
	glDebugMessageInsert = cast(typeof(glDebugMessageInsert))load("glDebugMessageInsert");
	glDebugMessageCallback = cast(typeof(glDebugMessageCallback))load("glDebugMessageCallback");
	glGetDebugMessageLog = cast(typeof(glGetDebugMessageLog))load("glGetDebugMessageLog");
	glPushDebugGroup = cast(typeof(glPushDebugGroup))load("glPushDebugGroup");
	glPopDebugGroup = cast(typeof(glPopDebugGroup))load("glPopDebugGroup");
	glObjectLabel = cast(typeof(glObjectLabel))load("glObjectLabel");
	glGetObjectLabel = cast(typeof(glGetObjectLabel))load("glGetObjectLabel");
	glObjectPtrLabel = cast(typeof(glObjectPtrLabel))load("glObjectPtrLabel");
	glGetObjectPtrLabel = cast(typeof(glGetObjectPtrLabel))load("glGetObjectPtrLabel");
	return;
}

void load_gl_GL_VERSION_4_0(void* function(string name) load) {
	if(!GL_VERSION_4_0) return;
	glMinSampleShading = cast(typeof(glMinSampleShading))load("glMinSampleShading");
	glBlendEquationi = cast(typeof(glBlendEquationi))load("glBlendEquationi");
	glBlendEquationSeparatei = cast(typeof(glBlendEquationSeparatei))load("glBlendEquationSeparatei");
	glBlendFunci = cast(typeof(glBlendFunci))load("glBlendFunci");
	glBlendFuncSeparatei = cast(typeof(glBlendFuncSeparatei))load("glBlendFuncSeparatei");
	glDrawArraysIndirect = cast(typeof(glDrawArraysIndirect))load("glDrawArraysIndirect");
	glDrawElementsIndirect = cast(typeof(glDrawElementsIndirect))load("glDrawElementsIndirect");
	glUniform1d = cast(typeof(glUniform1d))load("glUniform1d");
	glUniform2d = cast(typeof(glUniform2d))load("glUniform2d");
	glUniform3d = cast(typeof(glUniform3d))load("glUniform3d");
	glUniform4d = cast(typeof(glUniform4d))load("glUniform4d");
	glUniform1dv = cast(typeof(glUniform1dv))load("glUniform1dv");
	glUniform2dv = cast(typeof(glUniform2dv))load("glUniform2dv");
	glUniform3dv = cast(typeof(glUniform3dv))load("glUniform3dv");
	glUniform4dv = cast(typeof(glUniform4dv))load("glUniform4dv");
	glUniformMatrix2dv = cast(typeof(glUniformMatrix2dv))load("glUniformMatrix2dv");
	glUniformMatrix3dv = cast(typeof(glUniformMatrix3dv))load("glUniformMatrix3dv");
	glUniformMatrix4dv = cast(typeof(glUniformMatrix4dv))load("glUniformMatrix4dv");
	glUniformMatrix2x3dv = cast(typeof(glUniformMatrix2x3dv))load("glUniformMatrix2x3dv");
	glUniformMatrix2x4dv = cast(typeof(glUniformMatrix2x4dv))load("glUniformMatrix2x4dv");
	glUniformMatrix3x2dv = cast(typeof(glUniformMatrix3x2dv))load("glUniformMatrix3x2dv");
	glUniformMatrix3x4dv = cast(typeof(glUniformMatrix3x4dv))load("glUniformMatrix3x4dv");
	glUniformMatrix4x2dv = cast(typeof(glUniformMatrix4x2dv))load("glUniformMatrix4x2dv");
	glUniformMatrix4x3dv = cast(typeof(glUniformMatrix4x3dv))load("glUniformMatrix4x3dv");
	glGetUniformdv = cast(typeof(glGetUniformdv))load("glGetUniformdv");
	glGetSubroutineUniformLocation = cast(typeof(glGetSubroutineUniformLocation))load("glGetSubroutineUniformLocation");
	glGetSubroutineIndex = cast(typeof(glGetSubroutineIndex))load("glGetSubroutineIndex");
	glGetActiveSubroutineUniformiv = cast(typeof(glGetActiveSubroutineUniformiv))load("glGetActiveSubroutineUniformiv");
	glGetActiveSubroutineUniformName = cast(typeof(glGetActiveSubroutineUniformName))load("glGetActiveSubroutineUniformName");
	glGetActiveSubroutineName = cast(typeof(glGetActiveSubroutineName))load("glGetActiveSubroutineName");
	glUniformSubroutinesuiv = cast(typeof(glUniformSubroutinesuiv))load("glUniformSubroutinesuiv");
	glGetUniformSubroutineuiv = cast(typeof(glGetUniformSubroutineuiv))load("glGetUniformSubroutineuiv");
	glGetProgramStageiv = cast(typeof(glGetProgramStageiv))load("glGetProgramStageiv");
	glPatchParameteri = cast(typeof(glPatchParameteri))load("glPatchParameteri");
	glPatchParameterfv = cast(typeof(glPatchParameterfv))load("glPatchParameterfv");
	glBindTransformFeedback = cast(typeof(glBindTransformFeedback))load("glBindTransformFeedback");
	glDeleteTransformFeedbacks = cast(typeof(glDeleteTransformFeedbacks))load("glDeleteTransformFeedbacks");
	glGenTransformFeedbacks = cast(typeof(glGenTransformFeedbacks))load("glGenTransformFeedbacks");
	glIsTransformFeedback = cast(typeof(glIsTransformFeedback))load("glIsTransformFeedback");
	glPauseTransformFeedback = cast(typeof(glPauseTransformFeedback))load("glPauseTransformFeedback");
	glResumeTransformFeedback = cast(typeof(glResumeTransformFeedback))load("glResumeTransformFeedback");
	glDrawTransformFeedback = cast(typeof(glDrawTransformFeedback))load("glDrawTransformFeedback");
	glDrawTransformFeedbackStream = cast(typeof(glDrawTransformFeedbackStream))load("glDrawTransformFeedbackStream");
	glBeginQueryIndexed = cast(typeof(glBeginQueryIndexed))load("glBeginQueryIndexed");
	glEndQueryIndexed = cast(typeof(glEndQueryIndexed))load("glEndQueryIndexed");
	glGetQueryIndexediv = cast(typeof(glGetQueryIndexediv))load("glGetQueryIndexediv");
	return;
}

void load_gl_GL_VERSION_4_1(void* function(string name) load) {
	if(!GL_VERSION_4_1) return;
	glReleaseShaderCompiler = cast(typeof(glReleaseShaderCompiler))load("glReleaseShaderCompiler");
	glShaderBinary = cast(typeof(glShaderBinary))load("glShaderBinary");
	glGetShaderPrecisionFormat = cast(typeof(glGetShaderPrecisionFormat))load("glGetShaderPrecisionFormat");
	glDepthRangef = cast(typeof(glDepthRangef))load("glDepthRangef");
	glClearDepthf = cast(typeof(glClearDepthf))load("glClearDepthf");
	glGetProgramBinary = cast(typeof(glGetProgramBinary))load("glGetProgramBinary");
	glProgramBinary = cast(typeof(glProgramBinary))load("glProgramBinary");
	glProgramParameteri = cast(typeof(glProgramParameteri))load("glProgramParameteri");
	glUseProgramStages = cast(typeof(glUseProgramStages))load("glUseProgramStages");
	glActiveShaderProgram = cast(typeof(glActiveShaderProgram))load("glActiveShaderProgram");
	glCreateShaderProgramv = cast(typeof(glCreateShaderProgramv))load("glCreateShaderProgramv");
	glBindProgramPipeline = cast(typeof(glBindProgramPipeline))load("glBindProgramPipeline");
	glDeleteProgramPipelines = cast(typeof(glDeleteProgramPipelines))load("glDeleteProgramPipelines");
	glGenProgramPipelines = cast(typeof(glGenProgramPipelines))load("glGenProgramPipelines");
	glIsProgramPipeline = cast(typeof(glIsProgramPipeline))load("glIsProgramPipeline");
	glGetProgramPipelineiv = cast(typeof(glGetProgramPipelineiv))load("glGetProgramPipelineiv");
	glProgramUniform1i = cast(typeof(glProgramUniform1i))load("glProgramUniform1i");
	glProgramUniform1iv = cast(typeof(glProgramUniform1iv))load("glProgramUniform1iv");
	glProgramUniform1f = cast(typeof(glProgramUniform1f))load("glProgramUniform1f");
	glProgramUniform1fv = cast(typeof(glProgramUniform1fv))load("glProgramUniform1fv");
	glProgramUniform1d = cast(typeof(glProgramUniform1d))load("glProgramUniform1d");
	glProgramUniform1dv = cast(typeof(glProgramUniform1dv))load("glProgramUniform1dv");
	glProgramUniform1ui = cast(typeof(glProgramUniform1ui))load("glProgramUniform1ui");
	glProgramUniform1uiv = cast(typeof(glProgramUniform1uiv))load("glProgramUniform1uiv");
	glProgramUniform2i = cast(typeof(glProgramUniform2i))load("glProgramUniform2i");
	glProgramUniform2iv = cast(typeof(glProgramUniform2iv))load("glProgramUniform2iv");
	glProgramUniform2f = cast(typeof(glProgramUniform2f))load("glProgramUniform2f");
	glProgramUniform2fv = cast(typeof(glProgramUniform2fv))load("glProgramUniform2fv");
	glProgramUniform2d = cast(typeof(glProgramUniform2d))load("glProgramUniform2d");
	glProgramUniform2dv = cast(typeof(glProgramUniform2dv))load("glProgramUniform2dv");
	glProgramUniform2ui = cast(typeof(glProgramUniform2ui))load("glProgramUniform2ui");
	glProgramUniform2uiv = cast(typeof(glProgramUniform2uiv))load("glProgramUniform2uiv");
	glProgramUniform3i = cast(typeof(glProgramUniform3i))load("glProgramUniform3i");
	glProgramUniform3iv = cast(typeof(glProgramUniform3iv))load("glProgramUniform3iv");
	glProgramUniform3f = cast(typeof(glProgramUniform3f))load("glProgramUniform3f");
	glProgramUniform3fv = cast(typeof(glProgramUniform3fv))load("glProgramUniform3fv");
	glProgramUniform3d = cast(typeof(glProgramUniform3d))load("glProgramUniform3d");
	glProgramUniform3dv = cast(typeof(glProgramUniform3dv))load("glProgramUniform3dv");
	glProgramUniform3ui = cast(typeof(glProgramUniform3ui))load("glProgramUniform3ui");
	glProgramUniform3uiv = cast(typeof(glProgramUniform3uiv))load("glProgramUniform3uiv");
	glProgramUniform4i = cast(typeof(glProgramUniform4i))load("glProgramUniform4i");
	glProgramUniform4iv = cast(typeof(glProgramUniform4iv))load("glProgramUniform4iv");
	glProgramUniform4f = cast(typeof(glProgramUniform4f))load("glProgramUniform4f");
	glProgramUniform4fv = cast(typeof(glProgramUniform4fv))load("glProgramUniform4fv");
	glProgramUniform4d = cast(typeof(glProgramUniform4d))load("glProgramUniform4d");
	glProgramUniform4dv = cast(typeof(glProgramUniform4dv))load("glProgramUniform4dv");
	glProgramUniform4ui = cast(typeof(glProgramUniform4ui))load("glProgramUniform4ui");
	glProgramUniform4uiv = cast(typeof(glProgramUniform4uiv))load("glProgramUniform4uiv");
	glProgramUniformMatrix2fv = cast(typeof(glProgramUniformMatrix2fv))load("glProgramUniformMatrix2fv");
	glProgramUniformMatrix3fv = cast(typeof(glProgramUniformMatrix3fv))load("glProgramUniformMatrix3fv");
	glProgramUniformMatrix4fv = cast(typeof(glProgramUniformMatrix4fv))load("glProgramUniformMatrix4fv");
	glProgramUniformMatrix2dv = cast(typeof(glProgramUniformMatrix2dv))load("glProgramUniformMatrix2dv");
	glProgramUniformMatrix3dv = cast(typeof(glProgramUniformMatrix3dv))load("glProgramUniformMatrix3dv");
	glProgramUniformMatrix4dv = cast(typeof(glProgramUniformMatrix4dv))load("glProgramUniformMatrix4dv");
	glProgramUniformMatrix2x3fv = cast(typeof(glProgramUniformMatrix2x3fv))load("glProgramUniformMatrix2x3fv");
	glProgramUniformMatrix3x2fv = cast(typeof(glProgramUniformMatrix3x2fv))load("glProgramUniformMatrix3x2fv");
	glProgramUniformMatrix2x4fv = cast(typeof(glProgramUniformMatrix2x4fv))load("glProgramUniformMatrix2x4fv");
	glProgramUniformMatrix4x2fv = cast(typeof(glProgramUniformMatrix4x2fv))load("glProgramUniformMatrix4x2fv");
	glProgramUniformMatrix3x4fv = cast(typeof(glProgramUniformMatrix3x4fv))load("glProgramUniformMatrix3x4fv");
	glProgramUniformMatrix4x3fv = cast(typeof(glProgramUniformMatrix4x3fv))load("glProgramUniformMatrix4x3fv");
	glProgramUniformMatrix2x3dv = cast(typeof(glProgramUniformMatrix2x3dv))load("glProgramUniformMatrix2x3dv");
	glProgramUniformMatrix3x2dv = cast(typeof(glProgramUniformMatrix3x2dv))load("glProgramUniformMatrix3x2dv");
	glProgramUniformMatrix2x4dv = cast(typeof(glProgramUniformMatrix2x4dv))load("glProgramUniformMatrix2x4dv");
	glProgramUniformMatrix4x2dv = cast(typeof(glProgramUniformMatrix4x2dv))load("glProgramUniformMatrix4x2dv");
	glProgramUniformMatrix3x4dv = cast(typeof(glProgramUniformMatrix3x4dv))load("glProgramUniformMatrix3x4dv");
	glProgramUniformMatrix4x3dv = cast(typeof(glProgramUniformMatrix4x3dv))load("glProgramUniformMatrix4x3dv");
	glValidateProgramPipeline = cast(typeof(glValidateProgramPipeline))load("glValidateProgramPipeline");
	glGetProgramPipelineInfoLog = cast(typeof(glGetProgramPipelineInfoLog))load("glGetProgramPipelineInfoLog");
	glVertexAttribL1d = cast(typeof(glVertexAttribL1d))load("glVertexAttribL1d");
	glVertexAttribL2d = cast(typeof(glVertexAttribL2d))load("glVertexAttribL2d");
	glVertexAttribL3d = cast(typeof(glVertexAttribL3d))load("glVertexAttribL3d");
	glVertexAttribL4d = cast(typeof(glVertexAttribL4d))load("glVertexAttribL4d");
	glVertexAttribL1dv = cast(typeof(glVertexAttribL1dv))load("glVertexAttribL1dv");
	glVertexAttribL2dv = cast(typeof(glVertexAttribL2dv))load("glVertexAttribL2dv");
	glVertexAttribL3dv = cast(typeof(glVertexAttribL3dv))load("glVertexAttribL3dv");
	glVertexAttribL4dv = cast(typeof(glVertexAttribL4dv))load("glVertexAttribL4dv");
	glVertexAttribLPointer = cast(typeof(glVertexAttribLPointer))load("glVertexAttribLPointer");
	glGetVertexAttribLdv = cast(typeof(glGetVertexAttribLdv))load("glGetVertexAttribLdv");
	glViewportArrayv = cast(typeof(glViewportArrayv))load("glViewportArrayv");
	glViewportIndexedf = cast(typeof(glViewportIndexedf))load("glViewportIndexedf");
	glViewportIndexedfv = cast(typeof(glViewportIndexedfv))load("glViewportIndexedfv");
	glScissorArrayv = cast(typeof(glScissorArrayv))load("glScissorArrayv");
	glScissorIndexed = cast(typeof(glScissorIndexed))load("glScissorIndexed");
	glScissorIndexedv = cast(typeof(glScissorIndexedv))load("glScissorIndexedv");
	glDepthRangeArrayv = cast(typeof(glDepthRangeArrayv))load("glDepthRangeArrayv");
	glDepthRangeIndexed = cast(typeof(glDepthRangeIndexed))load("glDepthRangeIndexed");
	glGetFloati_v = cast(typeof(glGetFloati_v))load("glGetFloati_v");
	glGetDoublei_v = cast(typeof(glGetDoublei_v))load("glGetDoublei_v");
	return;
}

bool load_gl_GL_ARB_copy_buffer(void* function(string name) load) {
	if(!GL_ARB_copy_buffer) return GL_ARB_copy_buffer;

	glCopyBufferSubData = cast(typeof(glCopyBufferSubData))load("glCopyBufferSubData");
	return GL_ARB_copy_buffer;
}


bool load_gl_GL_NV_draw_texture(void* function(string name) load) {
	if(!GL_NV_draw_texture) return GL_NV_draw_texture;

	glDrawTextureNV = cast(typeof(glDrawTextureNV))load("glDrawTextureNV");
	return GL_NV_draw_texture;
}


bool load_gl_GL_EXT_texture_shared_exponent(void* function(string name) load) {
	if(!GL_EXT_texture_shared_exponent) return GL_EXT_texture_shared_exponent;

	return GL_EXT_texture_shared_exponent;
}


bool load_gl_GL_EXT_draw_instanced(void* function(string name) load) {
	if(!GL_EXT_draw_instanced) return GL_EXT_draw_instanced;

	glDrawArraysInstancedEXT = cast(typeof(glDrawArraysInstancedEXT))load("glDrawArraysInstancedEXT");
	glDrawElementsInstancedEXT = cast(typeof(glDrawElementsInstancedEXT))load("glDrawElementsInstancedEXT");
	return GL_EXT_draw_instanced;
}


bool load_gl_GL_NV_copy_depth_to_color(void* function(string name) load) {
	if(!GL_NV_copy_depth_to_color) return GL_NV_copy_depth_to_color;

	return GL_NV_copy_depth_to_color;
}


bool load_gl_GL_ARB_viewport_array(void* function(string name) load) {
	if(!GL_ARB_viewport_array) return GL_ARB_viewport_array;

	glViewportArrayv = cast(typeof(glViewportArrayv))load("glViewportArrayv");
	glViewportIndexedf = cast(typeof(glViewportIndexedf))load("glViewportIndexedf");
	glViewportIndexedfv = cast(typeof(glViewportIndexedfv))load("glViewportIndexedfv");
	glScissorArrayv = cast(typeof(glScissorArrayv))load("glScissorArrayv");
	glScissorIndexed = cast(typeof(glScissorIndexed))load("glScissorIndexed");
	glScissorIndexedv = cast(typeof(glScissorIndexedv))load("glScissorIndexedv");
	glDepthRangeArrayv = cast(typeof(glDepthRangeArrayv))load("glDepthRangeArrayv");
	glDepthRangeIndexed = cast(typeof(glDepthRangeIndexed))load("glDepthRangeIndexed");
	glGetFloati_v = cast(typeof(glGetFloati_v))load("glGetFloati_v");
	glGetDoublei_v = cast(typeof(glGetDoublei_v))load("glGetDoublei_v");
	return GL_ARB_viewport_array;
}


bool load_gl_GL_ARB_separate_shader_objects(void* function(string name) load) {
	if(!GL_ARB_separate_shader_objects) return GL_ARB_separate_shader_objects;

	glUseProgramStages = cast(typeof(glUseProgramStages))load("glUseProgramStages");
	glActiveShaderProgram = cast(typeof(glActiveShaderProgram))load("glActiveShaderProgram");
	glCreateShaderProgramv = cast(typeof(glCreateShaderProgramv))load("glCreateShaderProgramv");
	glBindProgramPipeline = cast(typeof(glBindProgramPipeline))load("glBindProgramPipeline");
	glDeleteProgramPipelines = cast(typeof(glDeleteProgramPipelines))load("glDeleteProgramPipelines");
	glGenProgramPipelines = cast(typeof(glGenProgramPipelines))load("glGenProgramPipelines");
	glIsProgramPipeline = cast(typeof(glIsProgramPipeline))load("glIsProgramPipeline");
	glGetProgramPipelineiv = cast(typeof(glGetProgramPipelineiv))load("glGetProgramPipelineiv");
	glProgramUniform1i = cast(typeof(glProgramUniform1i))load("glProgramUniform1i");
	glProgramUniform1iv = cast(typeof(glProgramUniform1iv))load("glProgramUniform1iv");
	glProgramUniform1f = cast(typeof(glProgramUniform1f))load("glProgramUniform1f");
	glProgramUniform1fv = cast(typeof(glProgramUniform1fv))load("glProgramUniform1fv");
	glProgramUniform1d = cast(typeof(glProgramUniform1d))load("glProgramUniform1d");
	glProgramUniform1dv = cast(typeof(glProgramUniform1dv))load("glProgramUniform1dv");
	glProgramUniform1ui = cast(typeof(glProgramUniform1ui))load("glProgramUniform1ui");
	glProgramUniform1uiv = cast(typeof(glProgramUniform1uiv))load("glProgramUniform1uiv");
	glProgramUniform2i = cast(typeof(glProgramUniform2i))load("glProgramUniform2i");
	glProgramUniform2iv = cast(typeof(glProgramUniform2iv))load("glProgramUniform2iv");
	glProgramUniform2f = cast(typeof(glProgramUniform2f))load("glProgramUniform2f");
	glProgramUniform2fv = cast(typeof(glProgramUniform2fv))load("glProgramUniform2fv");
	glProgramUniform2d = cast(typeof(glProgramUniform2d))load("glProgramUniform2d");
	glProgramUniform2dv = cast(typeof(glProgramUniform2dv))load("glProgramUniform2dv");
	glProgramUniform2ui = cast(typeof(glProgramUniform2ui))load("glProgramUniform2ui");
	glProgramUniform2uiv = cast(typeof(glProgramUniform2uiv))load("glProgramUniform2uiv");
	glProgramUniform3i = cast(typeof(glProgramUniform3i))load("glProgramUniform3i");
	glProgramUniform3iv = cast(typeof(glProgramUniform3iv))load("glProgramUniform3iv");
	glProgramUniform3f = cast(typeof(glProgramUniform3f))load("glProgramUniform3f");
	glProgramUniform3fv = cast(typeof(glProgramUniform3fv))load("glProgramUniform3fv");
	glProgramUniform3d = cast(typeof(glProgramUniform3d))load("glProgramUniform3d");
	glProgramUniform3dv = cast(typeof(glProgramUniform3dv))load("glProgramUniform3dv");
	glProgramUniform3ui = cast(typeof(glProgramUniform3ui))load("glProgramUniform3ui");
	glProgramUniform3uiv = cast(typeof(glProgramUniform3uiv))load("glProgramUniform3uiv");
	glProgramUniform4i = cast(typeof(glProgramUniform4i))load("glProgramUniform4i");
	glProgramUniform4iv = cast(typeof(glProgramUniform4iv))load("glProgramUniform4iv");
	glProgramUniform4f = cast(typeof(glProgramUniform4f))load("glProgramUniform4f");
	glProgramUniform4fv = cast(typeof(glProgramUniform4fv))load("glProgramUniform4fv");
	glProgramUniform4d = cast(typeof(glProgramUniform4d))load("glProgramUniform4d");
	glProgramUniform4dv = cast(typeof(glProgramUniform4dv))load("glProgramUniform4dv");
	glProgramUniform4ui = cast(typeof(glProgramUniform4ui))load("glProgramUniform4ui");
	glProgramUniform4uiv = cast(typeof(glProgramUniform4uiv))load("glProgramUniform4uiv");
	glProgramUniformMatrix2fv = cast(typeof(glProgramUniformMatrix2fv))load("glProgramUniformMatrix2fv");
	glProgramUniformMatrix3fv = cast(typeof(glProgramUniformMatrix3fv))load("glProgramUniformMatrix3fv");
	glProgramUniformMatrix4fv = cast(typeof(glProgramUniformMatrix4fv))load("glProgramUniformMatrix4fv");
	glProgramUniformMatrix2dv = cast(typeof(glProgramUniformMatrix2dv))load("glProgramUniformMatrix2dv");
	glProgramUniformMatrix3dv = cast(typeof(glProgramUniformMatrix3dv))load("glProgramUniformMatrix3dv");
	glProgramUniformMatrix4dv = cast(typeof(glProgramUniformMatrix4dv))load("glProgramUniformMatrix4dv");
	glProgramUniformMatrix2x3fv = cast(typeof(glProgramUniformMatrix2x3fv))load("glProgramUniformMatrix2x3fv");
	glProgramUniformMatrix3x2fv = cast(typeof(glProgramUniformMatrix3x2fv))load("glProgramUniformMatrix3x2fv");
	glProgramUniformMatrix2x4fv = cast(typeof(glProgramUniformMatrix2x4fv))load("glProgramUniformMatrix2x4fv");
	glProgramUniformMatrix4x2fv = cast(typeof(glProgramUniformMatrix4x2fv))load("glProgramUniformMatrix4x2fv");
	glProgramUniformMatrix3x4fv = cast(typeof(glProgramUniformMatrix3x4fv))load("glProgramUniformMatrix3x4fv");
	glProgramUniformMatrix4x3fv = cast(typeof(glProgramUniformMatrix4x3fv))load("glProgramUniformMatrix4x3fv");
	glProgramUniformMatrix2x3dv = cast(typeof(glProgramUniformMatrix2x3dv))load("glProgramUniformMatrix2x3dv");
	glProgramUniformMatrix3x2dv = cast(typeof(glProgramUniformMatrix3x2dv))load("glProgramUniformMatrix3x2dv");
	glProgramUniformMatrix2x4dv = cast(typeof(glProgramUniformMatrix2x4dv))load("glProgramUniformMatrix2x4dv");
	glProgramUniformMatrix4x2dv = cast(typeof(glProgramUniformMatrix4x2dv))load("glProgramUniformMatrix4x2dv");
	glProgramUniformMatrix3x4dv = cast(typeof(glProgramUniformMatrix3x4dv))load("glProgramUniformMatrix3x4dv");
	glProgramUniformMatrix4x3dv = cast(typeof(glProgramUniformMatrix4x3dv))load("glProgramUniformMatrix4x3dv");
	glValidateProgramPipeline = cast(typeof(glValidateProgramPipeline))load("glValidateProgramPipeline");
	glGetProgramPipelineInfoLog = cast(typeof(glGetProgramPipelineInfoLog))load("glGetProgramPipelineInfoLog");
	return GL_ARB_separate_shader_objects;
}


bool load_gl_GL_EXT_multisample(void* function(string name) load) {
	if(!GL_EXT_multisample) return GL_EXT_multisample;

	glSampleMaskEXT = cast(typeof(glSampleMaskEXT))load("glSampleMaskEXT");
	glSamplePatternEXT = cast(typeof(glSamplePatternEXT))load("glSamplePatternEXT");
	return GL_EXT_multisample;
}


bool load_gl_GL_EXT_depth_bounds_test(void* function(string name) load) {
	if(!GL_EXT_depth_bounds_test) return GL_EXT_depth_bounds_test;

	glDepthBoundsEXT = cast(typeof(glDepthBoundsEXT))load("glDepthBoundsEXT");
	return GL_EXT_depth_bounds_test;
}


bool load_gl_GL_HP_image_transform(void* function(string name) load) {
	if(!GL_HP_image_transform) return GL_HP_image_transform;

	glImageTransformParameteriHP = cast(typeof(glImageTransformParameteriHP))load("glImageTransformParameteriHP");
	glImageTransformParameterfHP = cast(typeof(glImageTransformParameterfHP))load("glImageTransformParameterfHP");
	glImageTransformParameterivHP = cast(typeof(glImageTransformParameterivHP))load("glImageTransformParameterivHP");
	glImageTransformParameterfvHP = cast(typeof(glImageTransformParameterfvHP))load("glImageTransformParameterfvHP");
	glGetImageTransformParameterivHP = cast(typeof(glGetImageTransformParameterivHP))load("glGetImageTransformParameterivHP");
	glGetImageTransformParameterfvHP = cast(typeof(glGetImageTransformParameterfvHP))load("glGetImageTransformParameterfvHP");
	return GL_HP_image_transform;
}


bool load_gl_GL_ARB_texture_env_add(void* function(string name) load) {
	if(!GL_ARB_texture_env_add) return GL_ARB_texture_env_add;

	return GL_ARB_texture_env_add;
}


bool load_gl_GL_NV_video_capture(void* function(string name) load) {
	if(!GL_NV_video_capture) return GL_NV_video_capture;

	glBeginVideoCaptureNV = cast(typeof(glBeginVideoCaptureNV))load("glBeginVideoCaptureNV");
	glBindVideoCaptureStreamBufferNV = cast(typeof(glBindVideoCaptureStreamBufferNV))load("glBindVideoCaptureStreamBufferNV");
	glBindVideoCaptureStreamTextureNV = cast(typeof(glBindVideoCaptureStreamTextureNV))load("glBindVideoCaptureStreamTextureNV");
	glEndVideoCaptureNV = cast(typeof(glEndVideoCaptureNV))load("glEndVideoCaptureNV");
	glGetVideoCaptureivNV = cast(typeof(glGetVideoCaptureivNV))load("glGetVideoCaptureivNV");
	glGetVideoCaptureStreamivNV = cast(typeof(glGetVideoCaptureStreamivNV))load("glGetVideoCaptureStreamivNV");
	glGetVideoCaptureStreamfvNV = cast(typeof(glGetVideoCaptureStreamfvNV))load("glGetVideoCaptureStreamfvNV");
	glGetVideoCaptureStreamdvNV = cast(typeof(glGetVideoCaptureStreamdvNV))load("glGetVideoCaptureStreamdvNV");
	glVideoCaptureNV = cast(typeof(glVideoCaptureNV))load("glVideoCaptureNV");
	glVideoCaptureStreamParameterivNV = cast(typeof(glVideoCaptureStreamParameterivNV))load("glVideoCaptureStreamParameterivNV");
	glVideoCaptureStreamParameterfvNV = cast(typeof(glVideoCaptureStreamParameterfvNV))load("glVideoCaptureStreamParameterfvNV");
	glVideoCaptureStreamParameterdvNV = cast(typeof(glVideoCaptureStreamParameterdvNV))load("glVideoCaptureStreamParameterdvNV");
	return GL_NV_video_capture;
}


bool load_gl_GL_ARB_sampler_objects(void* function(string name) load) {
	if(!GL_ARB_sampler_objects) return GL_ARB_sampler_objects;

	glGenSamplers = cast(typeof(glGenSamplers))load("glGenSamplers");
	glDeleteSamplers = cast(typeof(glDeleteSamplers))load("glDeleteSamplers");
	glIsSampler = cast(typeof(glIsSampler))load("glIsSampler");
	glBindSampler = cast(typeof(glBindSampler))load("glBindSampler");
	glSamplerParameteri = cast(typeof(glSamplerParameteri))load("glSamplerParameteri");
	glSamplerParameteriv = cast(typeof(glSamplerParameteriv))load("glSamplerParameteriv");
	glSamplerParameterf = cast(typeof(glSamplerParameterf))load("glSamplerParameterf");
	glSamplerParameterfv = cast(typeof(glSamplerParameterfv))load("glSamplerParameterfv");
	glSamplerParameterIiv = cast(typeof(glSamplerParameterIiv))load("glSamplerParameterIiv");
	glSamplerParameterIuiv = cast(typeof(glSamplerParameterIuiv))load("glSamplerParameterIuiv");
	glGetSamplerParameteriv = cast(typeof(glGetSamplerParameteriv))load("glGetSamplerParameteriv");
	glGetSamplerParameterIiv = cast(typeof(glGetSamplerParameterIiv))load("glGetSamplerParameterIiv");
	glGetSamplerParameterfv = cast(typeof(glGetSamplerParameterfv))load("glGetSamplerParameterfv");
	glGetSamplerParameterIuiv = cast(typeof(glGetSamplerParameterIuiv))load("glGetSamplerParameterIuiv");
	return GL_ARB_sampler_objects;
}


bool load_gl_GL_ARB_matrix_palette(void* function(string name) load) {
	if(!GL_ARB_matrix_palette) return GL_ARB_matrix_palette;

	glCurrentPaletteMatrixARB = cast(typeof(glCurrentPaletteMatrixARB))load("glCurrentPaletteMatrixARB");
	glMatrixIndexubvARB = cast(typeof(glMatrixIndexubvARB))load("glMatrixIndexubvARB");
	glMatrixIndexusvARB = cast(typeof(glMatrixIndexusvARB))load("glMatrixIndexusvARB");
	glMatrixIndexuivARB = cast(typeof(glMatrixIndexuivARB))load("glMatrixIndexuivARB");
	glMatrixIndexPointerARB = cast(typeof(glMatrixIndexPointerARB))load("glMatrixIndexPointerARB");
	return GL_ARB_matrix_palette;
}


bool load_gl_GL_SGIS_texture_color_mask(void* function(string name) load) {
	if(!GL_SGIS_texture_color_mask) return GL_SGIS_texture_color_mask;

	glTextureColorMaskSGIS = cast(typeof(glTextureColorMaskSGIS))load("glTextureColorMaskSGIS");
	return GL_SGIS_texture_color_mask;
}


bool load_gl_GL_EXT_packed_pixels(void* function(string name) load) {
	if(!GL_EXT_packed_pixels) return GL_EXT_packed_pixels;

	return GL_EXT_packed_pixels;
}


bool load_gl_GL_NV_transform_feedback2(void* function(string name) load) {
	if(!GL_NV_transform_feedback2) return GL_NV_transform_feedback2;

	glBindTransformFeedbackNV = cast(typeof(glBindTransformFeedbackNV))load("glBindTransformFeedbackNV");
	glDeleteTransformFeedbacksNV = cast(typeof(glDeleteTransformFeedbacksNV))load("glDeleteTransformFeedbacksNV");
	glGenTransformFeedbacksNV = cast(typeof(glGenTransformFeedbacksNV))load("glGenTransformFeedbacksNV");
	glIsTransformFeedbackNV = cast(typeof(glIsTransformFeedbackNV))load("glIsTransformFeedbackNV");
	glPauseTransformFeedbackNV = cast(typeof(glPauseTransformFeedbackNV))load("glPauseTransformFeedbackNV");
	glResumeTransformFeedbackNV = cast(typeof(glResumeTransformFeedbackNV))load("glResumeTransformFeedbackNV");
	glDrawTransformFeedbackNV = cast(typeof(glDrawTransformFeedbackNV))load("glDrawTransformFeedbackNV");
	return GL_NV_transform_feedback2;
}


bool load_gl_GL_APPLE_aux_depth_stencil(void* function(string name) load) {
	if(!GL_APPLE_aux_depth_stencil) return GL_APPLE_aux_depth_stencil;

	return GL_APPLE_aux_depth_stencil;
}


bool load_gl_GL_ARB_shader_subroutine(void* function(string name) load) {
	if(!GL_ARB_shader_subroutine) return GL_ARB_shader_subroutine;

	glGetSubroutineUniformLocation = cast(typeof(glGetSubroutineUniformLocation))load("glGetSubroutineUniformLocation");
	glGetSubroutineIndex = cast(typeof(glGetSubroutineIndex))load("glGetSubroutineIndex");
	glGetActiveSubroutineUniformiv = cast(typeof(glGetActiveSubroutineUniformiv))load("glGetActiveSubroutineUniformiv");
	glGetActiveSubroutineUniformName = cast(typeof(glGetActiveSubroutineUniformName))load("glGetActiveSubroutineUniformName");
	glGetActiveSubroutineName = cast(typeof(glGetActiveSubroutineName))load("glGetActiveSubroutineName");
	glUniformSubroutinesuiv = cast(typeof(glUniformSubroutinesuiv))load("glUniformSubroutinesuiv");
	glGetUniformSubroutineuiv = cast(typeof(glGetUniformSubroutineuiv))load("glGetUniformSubroutineuiv");
	glGetProgramStageiv = cast(typeof(glGetProgramStageiv))load("glGetProgramStageiv");
	return GL_ARB_shader_subroutine;
}


bool load_gl_GL_EXT_framebuffer_sRGB(void* function(string name) load) {
	if(!GL_EXT_framebuffer_sRGB) return GL_EXT_framebuffer_sRGB;

	return GL_EXT_framebuffer_sRGB;
}


bool load_gl_GL_ARB_texture_storage_multisample(void* function(string name) load) {
	if(!GL_ARB_texture_storage_multisample) return GL_ARB_texture_storage_multisample;

	glTexStorage2DMultisample = cast(typeof(glTexStorage2DMultisample))load("glTexStorage2DMultisample");
	glTexStorage3DMultisample = cast(typeof(glTexStorage3DMultisample))load("glTexStorage3DMultisample");
	return GL_ARB_texture_storage_multisample;
}


bool load_gl_GL_EXT_vertex_attrib_64bit(void* function(string name) load) {
	if(!GL_EXT_vertex_attrib_64bit) return GL_EXT_vertex_attrib_64bit;

	glVertexAttribL1dEXT = cast(typeof(glVertexAttribL1dEXT))load("glVertexAttribL1dEXT");
	glVertexAttribL2dEXT = cast(typeof(glVertexAttribL2dEXT))load("glVertexAttribL2dEXT");
	glVertexAttribL3dEXT = cast(typeof(glVertexAttribL3dEXT))load("glVertexAttribL3dEXT");
	glVertexAttribL4dEXT = cast(typeof(glVertexAttribL4dEXT))load("glVertexAttribL4dEXT");
	glVertexAttribL1dvEXT = cast(typeof(glVertexAttribL1dvEXT))load("glVertexAttribL1dvEXT");
	glVertexAttribL2dvEXT = cast(typeof(glVertexAttribL2dvEXT))load("glVertexAttribL2dvEXT");
	glVertexAttribL3dvEXT = cast(typeof(glVertexAttribL3dvEXT))load("glVertexAttribL3dvEXT");
	glVertexAttribL4dvEXT = cast(typeof(glVertexAttribL4dvEXT))load("glVertexAttribL4dvEXT");
	glVertexAttribLPointerEXT = cast(typeof(glVertexAttribLPointerEXT))load("glVertexAttribLPointerEXT");
	glGetVertexAttribLdvEXT = cast(typeof(glGetVertexAttribLdvEXT))load("glGetVertexAttribLdvEXT");
	return GL_EXT_vertex_attrib_64bit;
}


bool load_gl_GL_ARB_depth_texture(void* function(string name) load) {
	if(!GL_ARB_depth_texture) return GL_ARB_depth_texture;

	return GL_ARB_depth_texture;
}


void load_gl_GL_VERSION_2_0(void* function(string name) load) {
	if(!GL_VERSION_2_0) return;
	glBlendEquationSeparate = cast(typeof(glBlendEquationSeparate))load("glBlendEquationSeparate");
	glDrawBuffers = cast(typeof(glDrawBuffers))load("glDrawBuffers");
	glStencilOpSeparate = cast(typeof(glStencilOpSeparate))load("glStencilOpSeparate");
	glStencilFuncSeparate = cast(typeof(glStencilFuncSeparate))load("glStencilFuncSeparate");
	glStencilMaskSeparate = cast(typeof(glStencilMaskSeparate))load("glStencilMaskSeparate");
	glAttachShader = cast(typeof(glAttachShader))load("glAttachShader");
	glBindAttribLocation = cast(typeof(glBindAttribLocation))load("glBindAttribLocation");
	glCompileShader = cast(typeof(glCompileShader))load("glCompileShader");
	glCreateProgram = cast(typeof(glCreateProgram))load("glCreateProgram");
	glCreateShader = cast(typeof(glCreateShader))load("glCreateShader");
	glDeleteProgram = cast(typeof(glDeleteProgram))load("glDeleteProgram");
	glDeleteShader = cast(typeof(glDeleteShader))load("glDeleteShader");
	glDetachShader = cast(typeof(glDetachShader))load("glDetachShader");
	glDisableVertexAttribArray = cast(typeof(glDisableVertexAttribArray))load("glDisableVertexAttribArray");
	glEnableVertexAttribArray = cast(typeof(glEnableVertexAttribArray))load("glEnableVertexAttribArray");
	glGetActiveAttrib = cast(typeof(glGetActiveAttrib))load("glGetActiveAttrib");
	glGetActiveUniform = cast(typeof(glGetActiveUniform))load("glGetActiveUniform");
	glGetAttachedShaders = cast(typeof(glGetAttachedShaders))load("glGetAttachedShaders");
	glGetAttribLocation = cast(typeof(glGetAttribLocation))load("glGetAttribLocation");
	glGetProgramiv = cast(typeof(glGetProgramiv))load("glGetProgramiv");
	glGetProgramInfoLog = cast(typeof(glGetProgramInfoLog))load("glGetProgramInfoLog");
	glGetShaderiv = cast(typeof(glGetShaderiv))load("glGetShaderiv");
	glGetShaderInfoLog = cast(typeof(glGetShaderInfoLog))load("glGetShaderInfoLog");
	glGetShaderSource = cast(typeof(glGetShaderSource))load("glGetShaderSource");
	glGetUniformLocation = cast(typeof(glGetUniformLocation))load("glGetUniformLocation");
	glGetUniformfv = cast(typeof(glGetUniformfv))load("glGetUniformfv");
	glGetUniformiv = cast(typeof(glGetUniformiv))load("glGetUniformiv");
	glGetVertexAttribdv = cast(typeof(glGetVertexAttribdv))load("glGetVertexAttribdv");
	glGetVertexAttribfv = cast(typeof(glGetVertexAttribfv))load("glGetVertexAttribfv");
	glGetVertexAttribiv = cast(typeof(glGetVertexAttribiv))load("glGetVertexAttribiv");
	glGetVertexAttribPointerv = cast(typeof(glGetVertexAttribPointerv))load("glGetVertexAttribPointerv");
	glIsProgram = cast(typeof(glIsProgram))load("glIsProgram");
	glIsShader = cast(typeof(glIsShader))load("glIsShader");
	glLinkProgram = cast(typeof(glLinkProgram))load("glLinkProgram");
	glShaderSource = cast(typeof(glShaderSource))load("glShaderSource");
	glUseProgram = cast(typeof(glUseProgram))load("glUseProgram");
	glUniform1f = cast(typeof(glUniform1f))load("glUniform1f");
	glUniform2f = cast(typeof(glUniform2f))load("glUniform2f");
	glUniform3f = cast(typeof(glUniform3f))load("glUniform3f");
	glUniform4f = cast(typeof(glUniform4f))load("glUniform4f");
	glUniform1i = cast(typeof(glUniform1i))load("glUniform1i");
	glUniform2i = cast(typeof(glUniform2i))load("glUniform2i");
	glUniform3i = cast(typeof(glUniform3i))load("glUniform3i");
	glUniform4i = cast(typeof(glUniform4i))load("glUniform4i");
	glUniform1fv = cast(typeof(glUniform1fv))load("glUniform1fv");
	glUniform2fv = cast(typeof(glUniform2fv))load("glUniform2fv");
	glUniform3fv = cast(typeof(glUniform3fv))load("glUniform3fv");
	glUniform4fv = cast(typeof(glUniform4fv))load("glUniform4fv");
	glUniform1iv = cast(typeof(glUniform1iv))load("glUniform1iv");
	glUniform2iv = cast(typeof(glUniform2iv))load("glUniform2iv");
	glUniform3iv = cast(typeof(glUniform3iv))load("glUniform3iv");
	glUniform4iv = cast(typeof(glUniform4iv))load("glUniform4iv");
	glUniformMatrix2fv = cast(typeof(glUniformMatrix2fv))load("glUniformMatrix2fv");
	glUniformMatrix3fv = cast(typeof(glUniformMatrix3fv))load("glUniformMatrix3fv");
	glUniformMatrix4fv = cast(typeof(glUniformMatrix4fv))load("glUniformMatrix4fv");
	glValidateProgram = cast(typeof(glValidateProgram))load("glValidateProgram");
	glVertexAttrib1d = cast(typeof(glVertexAttrib1d))load("glVertexAttrib1d");
	glVertexAttrib1dv = cast(typeof(glVertexAttrib1dv))load("glVertexAttrib1dv");
	glVertexAttrib1f = cast(typeof(glVertexAttrib1f))load("glVertexAttrib1f");
	glVertexAttrib1fv = cast(typeof(glVertexAttrib1fv))load("glVertexAttrib1fv");
	glVertexAttrib1s = cast(typeof(glVertexAttrib1s))load("glVertexAttrib1s");
	glVertexAttrib1sv = cast(typeof(glVertexAttrib1sv))load("glVertexAttrib1sv");
	glVertexAttrib2d = cast(typeof(glVertexAttrib2d))load("glVertexAttrib2d");
	glVertexAttrib2dv = cast(typeof(glVertexAttrib2dv))load("glVertexAttrib2dv");
	glVertexAttrib2f = cast(typeof(glVertexAttrib2f))load("glVertexAttrib2f");
	glVertexAttrib2fv = cast(typeof(glVertexAttrib2fv))load("glVertexAttrib2fv");
	glVertexAttrib2s = cast(typeof(glVertexAttrib2s))load("glVertexAttrib2s");
	glVertexAttrib2sv = cast(typeof(glVertexAttrib2sv))load("glVertexAttrib2sv");
	glVertexAttrib3d = cast(typeof(glVertexAttrib3d))load("glVertexAttrib3d");
	glVertexAttrib3dv = cast(typeof(glVertexAttrib3dv))load("glVertexAttrib3dv");
	glVertexAttrib3f = cast(typeof(glVertexAttrib3f))load("glVertexAttrib3f");
	glVertexAttrib3fv = cast(typeof(glVertexAttrib3fv))load("glVertexAttrib3fv");
	glVertexAttrib3s = cast(typeof(glVertexAttrib3s))load("glVertexAttrib3s");
	glVertexAttrib3sv = cast(typeof(glVertexAttrib3sv))load("glVertexAttrib3sv");
	glVertexAttrib4Nbv = cast(typeof(glVertexAttrib4Nbv))load("glVertexAttrib4Nbv");
	glVertexAttrib4Niv = cast(typeof(glVertexAttrib4Niv))load("glVertexAttrib4Niv");
	glVertexAttrib4Nsv = cast(typeof(glVertexAttrib4Nsv))load("glVertexAttrib4Nsv");
	glVertexAttrib4Nub = cast(typeof(glVertexAttrib4Nub))load("glVertexAttrib4Nub");
	glVertexAttrib4Nubv = cast(typeof(glVertexAttrib4Nubv))load("glVertexAttrib4Nubv");
	glVertexAttrib4Nuiv = cast(typeof(glVertexAttrib4Nuiv))load("glVertexAttrib4Nuiv");
	glVertexAttrib4Nusv = cast(typeof(glVertexAttrib4Nusv))load("glVertexAttrib4Nusv");
	glVertexAttrib4bv = cast(typeof(glVertexAttrib4bv))load("glVertexAttrib4bv");
	glVertexAttrib4d = cast(typeof(glVertexAttrib4d))load("glVertexAttrib4d");
	glVertexAttrib4dv = cast(typeof(glVertexAttrib4dv))load("glVertexAttrib4dv");
	glVertexAttrib4f = cast(typeof(glVertexAttrib4f))load("glVertexAttrib4f");
	glVertexAttrib4fv = cast(typeof(glVertexAttrib4fv))load("glVertexAttrib4fv");
	glVertexAttrib4iv = cast(typeof(glVertexAttrib4iv))load("glVertexAttrib4iv");
	glVertexAttrib4s = cast(typeof(glVertexAttrib4s))load("glVertexAttrib4s");
	glVertexAttrib4sv = cast(typeof(glVertexAttrib4sv))load("glVertexAttrib4sv");
	glVertexAttrib4ubv = cast(typeof(glVertexAttrib4ubv))load("glVertexAttrib4ubv");
	glVertexAttrib4uiv = cast(typeof(glVertexAttrib4uiv))load("glVertexAttrib4uiv");
	glVertexAttrib4usv = cast(typeof(glVertexAttrib4usv))load("glVertexAttrib4usv");
	glVertexAttribPointer = cast(typeof(glVertexAttribPointer))load("glVertexAttribPointer");
	return;
}

void load_gl_GL_VERSION_2_1(void* function(string name) load) {
	if(!GL_VERSION_2_1) return;
	glUniformMatrix2x3fv = cast(typeof(glUniformMatrix2x3fv))load("glUniformMatrix2x3fv");
	glUniformMatrix3x2fv = cast(typeof(glUniformMatrix3x2fv))load("glUniformMatrix3x2fv");
	glUniformMatrix2x4fv = cast(typeof(glUniformMatrix2x4fv))load("glUniformMatrix2x4fv");
	glUniformMatrix4x2fv = cast(typeof(glUniformMatrix4x2fv))load("glUniformMatrix4x2fv");
	glUniformMatrix3x4fv = cast(typeof(glUniformMatrix3x4fv))load("glUniformMatrix3x4fv");
	glUniformMatrix4x3fv = cast(typeof(glUniformMatrix4x3fv))load("glUniformMatrix4x3fv");
	return;
}

bool load_gl_GL_NV_shader_buffer_store(void* function(string name) load) {
	if(!GL_NV_shader_buffer_store) return GL_NV_shader_buffer_store;

	return GL_NV_shader_buffer_store;
}


bool load_gl_GL_OES_query_matrix(void* function(string name) load) {
	if(!GL_OES_query_matrix) return GL_OES_query_matrix;

	glQueryMatrixxOES = cast(typeof(glQueryMatrixxOES))load("glQueryMatrixxOES");
	return GL_OES_query_matrix;
}


bool load_gl_GL_APPLE_texture_range(void* function(string name) load) {
	if(!GL_APPLE_texture_range) return GL_APPLE_texture_range;

	glTextureRangeAPPLE = cast(typeof(glTextureRangeAPPLE))load("glTextureRangeAPPLE");
	glGetTexParameterPointervAPPLE = cast(typeof(glGetTexParameterPointervAPPLE))load("glGetTexParameterPointervAPPLE");
	return GL_APPLE_texture_range;
}


bool load_gl_GL_NV_shader_storage_buffer_object(void* function(string name) load) {
	if(!GL_NV_shader_storage_buffer_object) return GL_NV_shader_storage_buffer_object;

	return GL_NV_shader_storage_buffer_object;
}


bool load_gl_GL_ARB_texture_query_lod(void* function(string name) load) {
	if(!GL_ARB_texture_query_lod) return GL_ARB_texture_query_lod;

	return GL_ARB_texture_query_lod;
}


bool load_gl_GL_SGIX_ir_instrument1(void* function(string name) load) {
	if(!GL_SGIX_ir_instrument1) return GL_SGIX_ir_instrument1;

	return GL_SGIX_ir_instrument1;
}


bool load_gl_GL_ARB_shader_image_size(void* function(string name) load) {
	if(!GL_ARB_shader_image_size) return GL_ARB_shader_image_size;

	return GL_ARB_shader_image_size;
}


bool load_gl_GL_NV_shader_atomic_counters(void* function(string name) load) {
	if(!GL_NV_shader_atomic_counters) return GL_NV_shader_atomic_counters;

	return GL_NV_shader_atomic_counters;
}


bool load_gl_GL_APPLE_object_purgeable(void* function(string name) load) {
	if(!GL_APPLE_object_purgeable) return GL_APPLE_object_purgeable;

	glObjectPurgeableAPPLE = cast(typeof(glObjectPurgeableAPPLE))load("glObjectPurgeableAPPLE");
	glObjectUnpurgeableAPPLE = cast(typeof(glObjectUnpurgeableAPPLE))load("glObjectUnpurgeableAPPLE");
	glGetObjectParameterivAPPLE = cast(typeof(glGetObjectParameterivAPPLE))load("glGetObjectParameterivAPPLE");
	return GL_APPLE_object_purgeable;
}


bool load_gl_GL_ARB_occlusion_query(void* function(string name) load) {
	if(!GL_ARB_occlusion_query) return GL_ARB_occlusion_query;

	glGenQueriesARB = cast(typeof(glGenQueriesARB))load("glGenQueriesARB");
	glDeleteQueriesARB = cast(typeof(glDeleteQueriesARB))load("glDeleteQueriesARB");
	glIsQueryARB = cast(typeof(glIsQueryARB))load("glIsQueryARB");
	glBeginQueryARB = cast(typeof(glBeginQueryARB))load("glBeginQueryARB");
	glEndQueryARB = cast(typeof(glEndQueryARB))load("glEndQueryARB");
	glGetQueryivARB = cast(typeof(glGetQueryivARB))load("glGetQueryivARB");
	glGetQueryObjectivARB = cast(typeof(glGetQueryObjectivARB))load("glGetQueryObjectivARB");
	glGetQueryObjectuivARB = cast(typeof(glGetQueryObjectuivARB))load("glGetQueryObjectuivARB");
	return GL_ARB_occlusion_query;
}


bool load_gl_GL_INGR_color_clamp(void* function(string name) load) {
	if(!GL_INGR_color_clamp) return GL_INGR_color_clamp;

	return GL_INGR_color_clamp;
}


bool load_gl_GL_SGI_color_table(void* function(string name) load) {
	if(!GL_SGI_color_table) return GL_SGI_color_table;

	glColorTableSGI = cast(typeof(glColorTableSGI))load("glColorTableSGI");
	glColorTableParameterfvSGI = cast(typeof(glColorTableParameterfvSGI))load("glColorTableParameterfvSGI");
	glColorTableParameterivSGI = cast(typeof(glColorTableParameterivSGI))load("glColorTableParameterivSGI");
	glCopyColorTableSGI = cast(typeof(glCopyColorTableSGI))load("glCopyColorTableSGI");
	glGetColorTableSGI = cast(typeof(glGetColorTableSGI))load("glGetColorTableSGI");
	glGetColorTableParameterfvSGI = cast(typeof(glGetColorTableParameterfvSGI))load("glGetColorTableParameterfvSGI");
	glGetColorTableParameterivSGI = cast(typeof(glGetColorTableParameterivSGI))load("glGetColorTableParameterivSGI");
	return GL_SGI_color_table;
}


bool load_gl_GL_EXT_framebuffer_multisample_blit_scaled(void* function(string name) load) {
	if(!GL_EXT_framebuffer_multisample_blit_scaled) return GL_EXT_framebuffer_multisample_blit_scaled;

	return GL_EXT_framebuffer_multisample_blit_scaled;
}


bool load_gl_GL_ARB_texture_cube_map_array(void* function(string name) load) {
	if(!GL_ARB_texture_cube_map_array) return GL_ARB_texture_cube_map_array;

	return GL_ARB_texture_cube_map_array;
}


bool load_gl_GL_AMD_debug_output(void* function(string name) load) {
	if(!GL_AMD_debug_output) return GL_AMD_debug_output;

	glDebugMessageEnableAMD = cast(typeof(glDebugMessageEnableAMD))load("glDebugMessageEnableAMD");
	glDebugMessageInsertAMD = cast(typeof(glDebugMessageInsertAMD))load("glDebugMessageInsertAMD");
	glDebugMessageCallbackAMD = cast(typeof(glDebugMessageCallbackAMD))load("glDebugMessageCallbackAMD");
	glGetDebugMessageLogAMD = cast(typeof(glGetDebugMessageLogAMD))load("glGetDebugMessageLogAMD");
	return GL_AMD_debug_output;
}


bool load_gl_GL_EXT_gpu_shader4(void* function(string name) load) {
	if(!GL_EXT_gpu_shader4) return GL_EXT_gpu_shader4;

	glGetUniformuivEXT = cast(typeof(glGetUniformuivEXT))load("glGetUniformuivEXT");
	glBindFragDataLocationEXT = cast(typeof(glBindFragDataLocationEXT))load("glBindFragDataLocationEXT");
	glGetFragDataLocationEXT = cast(typeof(glGetFragDataLocationEXT))load("glGetFragDataLocationEXT");
	glUniform1uiEXT = cast(typeof(glUniform1uiEXT))load("glUniform1uiEXT");
	glUniform2uiEXT = cast(typeof(glUniform2uiEXT))load("glUniform2uiEXT");
	glUniform3uiEXT = cast(typeof(glUniform3uiEXT))load("glUniform3uiEXT");
	glUniform4uiEXT = cast(typeof(glUniform4uiEXT))load("glUniform4uiEXT");
	glUniform1uivEXT = cast(typeof(glUniform1uivEXT))load("glUniform1uivEXT");
	glUniform2uivEXT = cast(typeof(glUniform2uivEXT))load("glUniform2uivEXT");
	glUniform3uivEXT = cast(typeof(glUniform3uivEXT))load("glUniform3uivEXT");
	glUniform4uivEXT = cast(typeof(glUniform4uivEXT))load("glUniform4uivEXT");
	return GL_EXT_gpu_shader4;
}


bool load_gl_GL_NV_geometry_program4(void* function(string name) load) {
	if(!GL_NV_geometry_program4) return GL_NV_geometry_program4;

	glProgramVertexLimitNV = cast(typeof(glProgramVertexLimitNV))load("glProgramVertexLimitNV");
	glFramebufferTextureEXT = cast(typeof(glFramebufferTextureEXT))load("glFramebufferTextureEXT");
	glFramebufferTextureLayerEXT = cast(typeof(glFramebufferTextureLayerEXT))load("glFramebufferTextureLayerEXT");
	glFramebufferTextureFaceEXT = cast(typeof(glFramebufferTextureFaceEXT))load("glFramebufferTextureFaceEXT");
	return GL_NV_geometry_program4;
}


bool load_gl_GL_NV_gpu_program5_mem_extended(void* function(string name) load) {
	if(!GL_NV_gpu_program5_mem_extended) return GL_NV_gpu_program5_mem_extended;

	return GL_NV_gpu_program5_mem_extended;
}


bool load_gl_GL_SGIX_scalebias_hint(void* function(string name) load) {
	if(!GL_SGIX_scalebias_hint) return GL_SGIX_scalebias_hint;

	return GL_SGIX_scalebias_hint;
}


bool load_gl_GL_ARB_texture_border_clamp(void* function(string name) load) {
	if(!GL_ARB_texture_border_clamp) return GL_ARB_texture_border_clamp;

	return GL_ARB_texture_border_clamp;
}


bool load_gl_GL_ARB_fragment_coord_conventions(void* function(string name) load) {
	if(!GL_ARB_fragment_coord_conventions) return GL_ARB_fragment_coord_conventions;

	return GL_ARB_fragment_coord_conventions;
}


bool load_gl_GL_SGIX_polynomial_ffd(void* function(string name) load) {
	if(!GL_SGIX_polynomial_ffd) return GL_SGIX_polynomial_ffd;

	glDeformationMap3dSGIX = cast(typeof(glDeformationMap3dSGIX))load("glDeformationMap3dSGIX");
	glDeformationMap3fSGIX = cast(typeof(glDeformationMap3fSGIX))load("glDeformationMap3fSGIX");
	glDeformSGIX = cast(typeof(glDeformSGIX))load("glDeformSGIX");
	glLoadIdentityDeformationMapSGIX = cast(typeof(glLoadIdentityDeformationMapSGIX))load("glLoadIdentityDeformationMapSGIX");
	return GL_SGIX_polynomial_ffd;
}


bool load_gl_GL_EXT_provoking_vertex(void* function(string name) load) {
	if(!GL_EXT_provoking_vertex) return GL_EXT_provoking_vertex;

	glProvokingVertexEXT = cast(typeof(glProvokingVertexEXT))load("glProvokingVertexEXT");
	return GL_EXT_provoking_vertex;
}


bool load_gl_GL_ARB_point_parameters(void* function(string name) load) {
	if(!GL_ARB_point_parameters) return GL_ARB_point_parameters;

	glPointParameterfARB = cast(typeof(glPointParameterfARB))load("glPointParameterfARB");
	glPointParameterfvARB = cast(typeof(glPointParameterfvARB))load("glPointParameterfvARB");
	return GL_ARB_point_parameters;
}


bool load_gl_GL_ARB_shader_image_load_store(void* function(string name) load) {
	if(!GL_ARB_shader_image_load_store) return GL_ARB_shader_image_load_store;

	glBindImageTexture = cast(typeof(glBindImageTexture))load("glBindImageTexture");
	glMemoryBarrier = cast(typeof(glMemoryBarrier))load("glMemoryBarrier");
	return GL_ARB_shader_image_load_store;
}


bool load_gl_GL_HP_occlusion_test(void* function(string name) load) {
	if(!GL_HP_occlusion_test) return GL_HP_occlusion_test;

	return GL_HP_occlusion_test;
}


bool load_gl_GL_ARB_ES3_compatibility(void* function(string name) load) {
	if(!GL_ARB_ES3_compatibility) return GL_ARB_ES3_compatibility;

	return GL_ARB_ES3_compatibility;
}


bool load_gl_GL_SGIX_framezoom(void* function(string name) load) {
	if(!GL_SGIX_framezoom) return GL_SGIX_framezoom;

	glFrameZoomSGIX = cast(typeof(glFrameZoomSGIX))load("glFrameZoomSGIX");
	return GL_SGIX_framezoom;
}


bool load_gl_GL_ARB_texture_buffer_object_rgb32(void* function(string name) load) {
	if(!GL_ARB_texture_buffer_object_rgb32) return GL_ARB_texture_buffer_object_rgb32;

	return GL_ARB_texture_buffer_object_rgb32;
}


bool load_gl_GL_NV_bindless_multi_draw_indirect(void* function(string name) load) {
	if(!GL_NV_bindless_multi_draw_indirect) return GL_NV_bindless_multi_draw_indirect;

	glMultiDrawArraysIndirectBindlessNV = cast(typeof(glMultiDrawArraysIndirectBindlessNV))load("glMultiDrawArraysIndirectBindlessNV");
	glMultiDrawElementsIndirectBindlessNV = cast(typeof(glMultiDrawElementsIndirectBindlessNV))load("glMultiDrawElementsIndirectBindlessNV");
	return GL_NV_bindless_multi_draw_indirect;
}


bool load_gl_GL_SGIX_texture_multi_buffer(void* function(string name) load) {
	if(!GL_SGIX_texture_multi_buffer) return GL_SGIX_texture_multi_buffer;

	return GL_SGIX_texture_multi_buffer;
}


bool load_gl_GL_EXT_transform_feedback(void* function(string name) load) {
	if(!GL_EXT_transform_feedback) return GL_EXT_transform_feedback;

	glBeginTransformFeedbackEXT = cast(typeof(glBeginTransformFeedbackEXT))load("glBeginTransformFeedbackEXT");
	glEndTransformFeedbackEXT = cast(typeof(glEndTransformFeedbackEXT))load("glEndTransformFeedbackEXT");
	glBindBufferRangeEXT = cast(typeof(glBindBufferRangeEXT))load("glBindBufferRangeEXT");
	glBindBufferOffsetEXT = cast(typeof(glBindBufferOffsetEXT))load("glBindBufferOffsetEXT");
	glBindBufferBaseEXT = cast(typeof(glBindBufferBaseEXT))load("glBindBufferBaseEXT");
	glTransformFeedbackVaryingsEXT = cast(typeof(glTransformFeedbackVaryingsEXT))load("glTransformFeedbackVaryingsEXT");
	glGetTransformFeedbackVaryingEXT = cast(typeof(glGetTransformFeedbackVaryingEXT))load("glGetTransformFeedbackVaryingEXT");
	return GL_EXT_transform_feedback;
}


bool load_gl_GL_KHR_texture_compression_astc_ldr(void* function(string name) load) {
	if(!GL_KHR_texture_compression_astc_ldr) return GL_KHR_texture_compression_astc_ldr;

	return GL_KHR_texture_compression_astc_ldr;
}


bool load_gl_GL_3DFX_multisample(void* function(string name) load) {
	if(!GL_3DFX_multisample) return GL_3DFX_multisample;

	return GL_3DFX_multisample;
}


bool load_gl_GL_ARB_texture_env_dot3(void* function(string name) load) {
	if(!GL_ARB_texture_env_dot3) return GL_ARB_texture_env_dot3;

	return GL_ARB_texture_env_dot3;
}


bool load_gl_GL_NV_gpu_program4(void* function(string name) load) {
	if(!GL_NV_gpu_program4) return GL_NV_gpu_program4;

	glProgramLocalParameterI4iNV = cast(typeof(glProgramLocalParameterI4iNV))load("glProgramLocalParameterI4iNV");
	glProgramLocalParameterI4ivNV = cast(typeof(glProgramLocalParameterI4ivNV))load("glProgramLocalParameterI4ivNV");
	glProgramLocalParametersI4ivNV = cast(typeof(glProgramLocalParametersI4ivNV))load("glProgramLocalParametersI4ivNV");
	glProgramLocalParameterI4uiNV = cast(typeof(glProgramLocalParameterI4uiNV))load("glProgramLocalParameterI4uiNV");
	glProgramLocalParameterI4uivNV = cast(typeof(glProgramLocalParameterI4uivNV))load("glProgramLocalParameterI4uivNV");
	glProgramLocalParametersI4uivNV = cast(typeof(glProgramLocalParametersI4uivNV))load("glProgramLocalParametersI4uivNV");
	glProgramEnvParameterI4iNV = cast(typeof(glProgramEnvParameterI4iNV))load("glProgramEnvParameterI4iNV");
	glProgramEnvParameterI4ivNV = cast(typeof(glProgramEnvParameterI4ivNV))load("glProgramEnvParameterI4ivNV");
	glProgramEnvParametersI4ivNV = cast(typeof(glProgramEnvParametersI4ivNV))load("glProgramEnvParametersI4ivNV");
	glProgramEnvParameterI4uiNV = cast(typeof(glProgramEnvParameterI4uiNV))load("glProgramEnvParameterI4uiNV");
	glProgramEnvParameterI4uivNV = cast(typeof(glProgramEnvParameterI4uivNV))load("glProgramEnvParameterI4uivNV");
	glProgramEnvParametersI4uivNV = cast(typeof(glProgramEnvParametersI4uivNV))load("glProgramEnvParametersI4uivNV");
	glGetProgramLocalParameterIivNV = cast(typeof(glGetProgramLocalParameterIivNV))load("glGetProgramLocalParameterIivNV");
	glGetProgramLocalParameterIuivNV = cast(typeof(glGetProgramLocalParameterIuivNV))load("glGetProgramLocalParameterIuivNV");
	glGetProgramEnvParameterIivNV = cast(typeof(glGetProgramEnvParameterIivNV))load("glGetProgramEnvParameterIivNV");
	glGetProgramEnvParameterIuivNV = cast(typeof(glGetProgramEnvParameterIuivNV))load("glGetProgramEnvParameterIuivNV");
	return GL_NV_gpu_program4;
}


bool load_gl_GL_NV_gpu_program5(void* function(string name) load) {
	if(!GL_NV_gpu_program5) return GL_NV_gpu_program5;

	glProgramSubroutineParametersuivNV = cast(typeof(glProgramSubroutineParametersuivNV))load("glProgramSubroutineParametersuivNV");
	glGetProgramSubroutineParameteruivNV = cast(typeof(glGetProgramSubroutineParameteruivNV))load("glGetProgramSubroutineParameteruivNV");
	return GL_NV_gpu_program5;
}


bool load_gl_GL_NV_float_buffer(void* function(string name) load) {
	if(!GL_NV_float_buffer) return GL_NV_float_buffer;

	return GL_NV_float_buffer;
}


bool load_gl_GL_SGIS_texture_edge_clamp(void* function(string name) load) {
	if(!GL_SGIS_texture_edge_clamp) return GL_SGIS_texture_edge_clamp;

	return GL_SGIS_texture_edge_clamp;
}


bool load_gl_GL_ARB_framebuffer_sRGB(void* function(string name) load) {
	if(!GL_ARB_framebuffer_sRGB) return GL_ARB_framebuffer_sRGB;

	return GL_ARB_framebuffer_sRGB;
}


bool load_gl_GL_SUN_slice_accum(void* function(string name) load) {
	if(!GL_SUN_slice_accum) return GL_SUN_slice_accum;

	return GL_SUN_slice_accum;
}


bool load_gl_GL_EXT_index_texture(void* function(string name) load) {
	if(!GL_EXT_index_texture) return GL_EXT_index_texture;

	return GL_EXT_index_texture;
}


bool load_gl_GL_ARB_geometry_shader4(void* function(string name) load) {
	if(!GL_ARB_geometry_shader4) return GL_ARB_geometry_shader4;

	glProgramParameteriARB = cast(typeof(glProgramParameteriARB))load("glProgramParameteriARB");
	glFramebufferTextureARB = cast(typeof(glFramebufferTextureARB))load("glFramebufferTextureARB");
	glFramebufferTextureLayerARB = cast(typeof(glFramebufferTextureLayerARB))load("glFramebufferTextureLayerARB");
	glFramebufferTextureFaceARB = cast(typeof(glFramebufferTextureFaceARB))load("glFramebufferTextureFaceARB");
	return GL_ARB_geometry_shader4;
}


bool load_gl_GL_EXT_separate_specular_color(void* function(string name) load) {
	if(!GL_EXT_separate_specular_color) return GL_EXT_separate_specular_color;

	return GL_EXT_separate_specular_color;
}


bool load_gl_GL_NV_fog_distance(void* function(string name) load) {
	if(!GL_NV_fog_distance) return GL_NV_fog_distance;

	return GL_NV_fog_distance;
}


bool load_gl_GL_SUN_convolution_border_modes(void* function(string name) load) {
	if(!GL_SUN_convolution_border_modes) return GL_SUN_convolution_border_modes;

	return GL_SUN_convolution_border_modes;
}


bool load_gl_GL_SGIX_sprite(void* function(string name) load) {
	if(!GL_SGIX_sprite) return GL_SGIX_sprite;

	glSpriteParameterfSGIX = cast(typeof(glSpriteParameterfSGIX))load("glSpriteParameterfSGIX");
	glSpriteParameterfvSGIX = cast(typeof(glSpriteParameterfvSGIX))load("glSpriteParameterfvSGIX");
	glSpriteParameteriSGIX = cast(typeof(glSpriteParameteriSGIX))load("glSpriteParameteriSGIX");
	glSpriteParameterivSGIX = cast(typeof(glSpriteParameterivSGIX))load("glSpriteParameterivSGIX");
	return GL_SGIX_sprite;
}


bool load_gl_GL_ARB_get_program_binary(void* function(string name) load) {
	if(!GL_ARB_get_program_binary) return GL_ARB_get_program_binary;

	glGetProgramBinary = cast(typeof(glGetProgramBinary))load("glGetProgramBinary");
	glProgramBinary = cast(typeof(glProgramBinary))load("glProgramBinary");
	glProgramParameteri = cast(typeof(glProgramParameteri))load("glProgramParameteri");
	return GL_ARB_get_program_binary;
}


bool load_gl_GL_ARB_timer_query(void* function(string name) load) {
	if(!GL_ARB_timer_query) return GL_ARB_timer_query;

	glQueryCounter = cast(typeof(glQueryCounter))load("glQueryCounter");
	glGetQueryObjecti64v = cast(typeof(glGetQueryObjecti64v))load("glGetQueryObjecti64v");
	glGetQueryObjectui64v = cast(typeof(glGetQueryObjectui64v))load("glGetQueryObjectui64v");
	return GL_ARB_timer_query;
}


bool load_gl_GL_SGIS_multisample(void* function(string name) load) {
	if(!GL_SGIS_multisample) return GL_SGIS_multisample;

	glSampleMaskSGIS = cast(typeof(glSampleMaskSGIS))load("glSampleMaskSGIS");
	glSamplePatternSGIS = cast(typeof(glSamplePatternSGIS))load("glSamplePatternSGIS");
	return GL_SGIS_multisample;
}


bool load_gl_GL_EXT_framebuffer_object(void* function(string name) load) {
	if(!GL_EXT_framebuffer_object) return GL_EXT_framebuffer_object;

	glIsRenderbufferEXT = cast(typeof(glIsRenderbufferEXT))load("glIsRenderbufferEXT");
	glBindRenderbufferEXT = cast(typeof(glBindRenderbufferEXT))load("glBindRenderbufferEXT");
	glDeleteRenderbuffersEXT = cast(typeof(glDeleteRenderbuffersEXT))load("glDeleteRenderbuffersEXT");
	glGenRenderbuffersEXT = cast(typeof(glGenRenderbuffersEXT))load("glGenRenderbuffersEXT");
	glRenderbufferStorageEXT = cast(typeof(glRenderbufferStorageEXT))load("glRenderbufferStorageEXT");
	glGetRenderbufferParameterivEXT = cast(typeof(glGetRenderbufferParameterivEXT))load("glGetRenderbufferParameterivEXT");
	glIsFramebufferEXT = cast(typeof(glIsFramebufferEXT))load("glIsFramebufferEXT");
	glBindFramebufferEXT = cast(typeof(glBindFramebufferEXT))load("glBindFramebufferEXT");
	glDeleteFramebuffersEXT = cast(typeof(glDeleteFramebuffersEXT))load("glDeleteFramebuffersEXT");
	glGenFramebuffersEXT = cast(typeof(glGenFramebuffersEXT))load("glGenFramebuffersEXT");
	glCheckFramebufferStatusEXT = cast(typeof(glCheckFramebufferStatusEXT))load("glCheckFramebufferStatusEXT");
	glFramebufferTexture1DEXT = cast(typeof(glFramebufferTexture1DEXT))load("glFramebufferTexture1DEXT");
	glFramebufferTexture2DEXT = cast(typeof(glFramebufferTexture2DEXT))load("glFramebufferTexture2DEXT");
	glFramebufferTexture3DEXT = cast(typeof(glFramebufferTexture3DEXT))load("glFramebufferTexture3DEXT");
	glFramebufferRenderbufferEXT = cast(typeof(glFramebufferRenderbufferEXT))load("glFramebufferRenderbufferEXT");
	glGetFramebufferAttachmentParameterivEXT = cast(typeof(glGetFramebufferAttachmentParameterivEXT))load("glGetFramebufferAttachmentParameterivEXT");
	glGenerateMipmapEXT = cast(typeof(glGenerateMipmapEXT))load("glGenerateMipmapEXT");
	return GL_EXT_framebuffer_object;
}


bool load_gl_GL_EXT_vertex_weighting(void* function(string name) load) {
	if(!GL_EXT_vertex_weighting) return GL_EXT_vertex_weighting;

	glVertexWeightfEXT = cast(typeof(glVertexWeightfEXT))load("glVertexWeightfEXT");
	glVertexWeightfvEXT = cast(typeof(glVertexWeightfvEXT))load("glVertexWeightfvEXT");
	glVertexWeightPointerEXT = cast(typeof(glVertexWeightPointerEXT))load("glVertexWeightPointerEXT");
	return GL_EXT_vertex_weighting;
}


bool load_gl_GL_ARB_vertex_array_bgra(void* function(string name) load) {
	if(!GL_ARB_vertex_array_bgra) return GL_ARB_vertex_array_bgra;

	return GL_ARB_vertex_array_bgra;
}


bool load_gl_GL_APPLE_vertex_array_range(void* function(string name) load) {
	if(!GL_APPLE_vertex_array_range) return GL_APPLE_vertex_array_range;

	glVertexArrayRangeAPPLE = cast(typeof(glVertexArrayRangeAPPLE))load("glVertexArrayRangeAPPLE");
	glFlushVertexArrayRangeAPPLE = cast(typeof(glFlushVertexArrayRangeAPPLE))load("glFlushVertexArrayRangeAPPLE");
	glVertexArrayParameteriAPPLE = cast(typeof(glVertexArrayParameteriAPPLE))load("glVertexArrayParameteriAPPLE");
	return GL_APPLE_vertex_array_range;
}


bool load_gl_GL_AMD_query_buffer_object(void* function(string name) load) {
	if(!GL_AMD_query_buffer_object) return GL_AMD_query_buffer_object;

	return GL_AMD_query_buffer_object;
}


bool load_gl_GL_NV_register_combiners(void* function(string name) load) {
	if(!GL_NV_register_combiners) return GL_NV_register_combiners;

	glCombinerParameterfvNV = cast(typeof(glCombinerParameterfvNV))load("glCombinerParameterfvNV");
	glCombinerParameterfNV = cast(typeof(glCombinerParameterfNV))load("glCombinerParameterfNV");
	glCombinerParameterivNV = cast(typeof(glCombinerParameterivNV))load("glCombinerParameterivNV");
	glCombinerParameteriNV = cast(typeof(glCombinerParameteriNV))load("glCombinerParameteriNV");
	glCombinerInputNV = cast(typeof(glCombinerInputNV))load("glCombinerInputNV");
	glCombinerOutputNV = cast(typeof(glCombinerOutputNV))load("glCombinerOutputNV");
	glFinalCombinerInputNV = cast(typeof(glFinalCombinerInputNV))load("glFinalCombinerInputNV");
	glGetCombinerInputParameterfvNV = cast(typeof(glGetCombinerInputParameterfvNV))load("glGetCombinerInputParameterfvNV");
	glGetCombinerInputParameterivNV = cast(typeof(glGetCombinerInputParameterivNV))load("glGetCombinerInputParameterivNV");
	glGetCombinerOutputParameterfvNV = cast(typeof(glGetCombinerOutputParameterfvNV))load("glGetCombinerOutputParameterfvNV");
	glGetCombinerOutputParameterivNV = cast(typeof(glGetCombinerOutputParameterivNV))load("glGetCombinerOutputParameterivNV");
	glGetFinalCombinerInputParameterfvNV = cast(typeof(glGetFinalCombinerInputParameterfvNV))load("glGetFinalCombinerInputParameterfvNV");
	glGetFinalCombinerInputParameterivNV = cast(typeof(glGetFinalCombinerInputParameterivNV))load("glGetFinalCombinerInputParameterivNV");
	return GL_NV_register_combiners;
}


bool load_gl_GL_ARB_draw_buffers(void* function(string name) load) {
	if(!GL_ARB_draw_buffers) return GL_ARB_draw_buffers;

	glDrawBuffersARB = cast(typeof(glDrawBuffersARB))load("glDrawBuffersARB");
	return GL_ARB_draw_buffers;
}


bool load_gl_GL_ARB_clear_texture(void* function(string name) load) {
	if(!GL_ARB_clear_texture) return GL_ARB_clear_texture;

	glClearTexImage = cast(typeof(glClearTexImage))load("glClearTexImage");
	glClearTexSubImage = cast(typeof(glClearTexSubImage))load("glClearTexSubImage");
	return GL_ARB_clear_texture;
}


bool load_gl_GL_NV_fragment_program(void* function(string name) load) {
	if(!GL_NV_fragment_program) return GL_NV_fragment_program;

	glProgramNamedParameter4fNV = cast(typeof(glProgramNamedParameter4fNV))load("glProgramNamedParameter4fNV");
	glProgramNamedParameter4fvNV = cast(typeof(glProgramNamedParameter4fvNV))load("glProgramNamedParameter4fvNV");
	glProgramNamedParameter4dNV = cast(typeof(glProgramNamedParameter4dNV))load("glProgramNamedParameter4dNV");
	glProgramNamedParameter4dvNV = cast(typeof(glProgramNamedParameter4dvNV))load("glProgramNamedParameter4dvNV");
	glGetProgramNamedParameterfvNV = cast(typeof(glGetProgramNamedParameterfvNV))load("glGetProgramNamedParameterfvNV");
	glGetProgramNamedParameterdvNV = cast(typeof(glGetProgramNamedParameterdvNV))load("glGetProgramNamedParameterdvNV");
	return GL_NV_fragment_program;
}


bool load_gl_GL_SGI_color_matrix(void* function(string name) load) {
	if(!GL_SGI_color_matrix) return GL_SGI_color_matrix;

	return GL_SGI_color_matrix;
}


bool load_gl_GL_EXT_cull_vertex(void* function(string name) load) {
	if(!GL_EXT_cull_vertex) return GL_EXT_cull_vertex;

	glCullParameterdvEXT = cast(typeof(glCullParameterdvEXT))load("glCullParameterdvEXT");
	glCullParameterfvEXT = cast(typeof(glCullParameterfvEXT))load("glCullParameterfvEXT");
	return GL_EXT_cull_vertex;
}


bool load_gl_GL_EXT_texture_sRGB(void* function(string name) load) {
	if(!GL_EXT_texture_sRGB) return GL_EXT_texture_sRGB;

	return GL_EXT_texture_sRGB;
}


bool load_gl_GL_APPLE_row_bytes(void* function(string name) load) {
	if(!GL_APPLE_row_bytes) return GL_APPLE_row_bytes;

	return GL_APPLE_row_bytes;
}


bool load_gl_GL_NV_texgen_reflection(void* function(string name) load) {
	if(!GL_NV_texgen_reflection) return GL_NV_texgen_reflection;

	return GL_NV_texgen_reflection;
}


bool load_gl_GL_IBM_multimode_draw_arrays(void* function(string name) load) {
	if(!GL_IBM_multimode_draw_arrays) return GL_IBM_multimode_draw_arrays;

	glMultiModeDrawArraysIBM = cast(typeof(glMultiModeDrawArraysIBM))load("glMultiModeDrawArraysIBM");
	glMultiModeDrawElementsIBM = cast(typeof(glMultiModeDrawElementsIBM))load("glMultiModeDrawElementsIBM");
	return GL_IBM_multimode_draw_arrays;
}


bool load_gl_GL_APPLE_vertex_array_object(void* function(string name) load) {
	if(!GL_APPLE_vertex_array_object) return GL_APPLE_vertex_array_object;

	glBindVertexArrayAPPLE = cast(typeof(glBindVertexArrayAPPLE))load("glBindVertexArrayAPPLE");
	glDeleteVertexArraysAPPLE = cast(typeof(glDeleteVertexArraysAPPLE))load("glDeleteVertexArraysAPPLE");
	glGenVertexArraysAPPLE = cast(typeof(glGenVertexArraysAPPLE))load("glGenVertexArraysAPPLE");
	glIsVertexArrayAPPLE = cast(typeof(glIsVertexArrayAPPLE))load("glIsVertexArrayAPPLE");
	return GL_APPLE_vertex_array_object;
}


bool load_gl_GL_3DFX_texture_compression_FXT1(void* function(string name) load) {
	if(!GL_3DFX_texture_compression_FXT1) return GL_3DFX_texture_compression_FXT1;

	return GL_3DFX_texture_compression_FXT1;
}


bool load_gl_GL_SGIX_ycrcb(void* function(string name) load) {
	if(!GL_SGIX_ycrcb) return GL_SGIX_ycrcb;

	return GL_SGIX_ycrcb;
}


bool load_gl_GL_AMD_conservative_depth(void* function(string name) load) {
	if(!GL_AMD_conservative_depth) return GL_AMD_conservative_depth;

	return GL_AMD_conservative_depth;
}


bool load_gl_GL_ARB_texture_float(void* function(string name) load) {
	if(!GL_ARB_texture_float) return GL_ARB_texture_float;

	return GL_ARB_texture_float;
}


bool load_gl_GL_ARB_compressed_texture_pixel_storage(void* function(string name) load) {
	if(!GL_ARB_compressed_texture_pixel_storage) return GL_ARB_compressed_texture_pixel_storage;

	return GL_ARB_compressed_texture_pixel_storage;
}


bool load_gl_GL_SGIS_detail_texture(void* function(string name) load) {
	if(!GL_SGIS_detail_texture) return GL_SGIS_detail_texture;

	glDetailTexFuncSGIS = cast(typeof(glDetailTexFuncSGIS))load("glDetailTexFuncSGIS");
	glGetDetailTexFuncSGIS = cast(typeof(glGetDetailTexFuncSGIS))load("glGetDetailTexFuncSGIS");
	return GL_SGIS_detail_texture;
}


bool load_gl_GL_ARB_draw_instanced(void* function(string name) load) {
	if(!GL_ARB_draw_instanced) return GL_ARB_draw_instanced;

	glDrawArraysInstancedARB = cast(typeof(glDrawArraysInstancedARB))load("glDrawArraysInstancedARB");
	glDrawElementsInstancedARB = cast(typeof(glDrawElementsInstancedARB))load("glDrawElementsInstancedARB");
	return GL_ARB_draw_instanced;
}


bool load_gl_GL_OES_read_format(void* function(string name) load) {
	if(!GL_OES_read_format) return GL_OES_read_format;

	return GL_OES_read_format;
}


bool load_gl_GL_ATI_texture_float(void* function(string name) load) {
	if(!GL_ATI_texture_float) return GL_ATI_texture_float;

	return GL_ATI_texture_float;
}


bool load_gl_GL_WIN_specular_fog(void* function(string name) load) {
	if(!GL_WIN_specular_fog) return GL_WIN_specular_fog;

	return GL_WIN_specular_fog;
}


bool load_gl_GL_AMD_vertex_shader_layer(void* function(string name) load) {
	if(!GL_AMD_vertex_shader_layer) return GL_AMD_vertex_shader_layer;

	return GL_AMD_vertex_shader_layer;
}


bool load_gl_GL_ARB_shading_language_include(void* function(string name) load) {
	if(!GL_ARB_shading_language_include) return GL_ARB_shading_language_include;

	glNamedStringARB = cast(typeof(glNamedStringARB))load("glNamedStringARB");
	glDeleteNamedStringARB = cast(typeof(glDeleteNamedStringARB))load("glDeleteNamedStringARB");
	glCompileShaderIncludeARB = cast(typeof(glCompileShaderIncludeARB))load("glCompileShaderIncludeARB");
	glIsNamedStringARB = cast(typeof(glIsNamedStringARB))load("glIsNamedStringARB");
	glGetNamedStringARB = cast(typeof(glGetNamedStringARB))load("glGetNamedStringARB");
	glGetNamedStringivARB = cast(typeof(glGetNamedStringivARB))load("glGetNamedStringivARB");
	return GL_ARB_shading_language_include;
}


bool load_gl_GL_APPLE_client_storage(void* function(string name) load) {
	if(!GL_APPLE_client_storage) return GL_APPLE_client_storage;

	return GL_APPLE_client_storage;
}


bool load_gl_GL_WIN_phong_shading(void* function(string name) load) {
	if(!GL_WIN_phong_shading) return GL_WIN_phong_shading;

	return GL_WIN_phong_shading;
}


bool load_gl_GL_INGR_blend_func_separate(void* function(string name) load) {
	if(!GL_INGR_blend_func_separate) return GL_INGR_blend_func_separate;

	glBlendFuncSeparateINGR = cast(typeof(glBlendFuncSeparateINGR))load("glBlendFuncSeparateINGR");
	return GL_INGR_blend_func_separate;
}


bool load_gl_GL_NV_path_rendering(void* function(string name) load) {
	if(!GL_NV_path_rendering) return GL_NV_path_rendering;

	glGenPathsNV = cast(typeof(glGenPathsNV))load("glGenPathsNV");
	glDeletePathsNV = cast(typeof(glDeletePathsNV))load("glDeletePathsNV");
	glIsPathNV = cast(typeof(glIsPathNV))load("glIsPathNV");
	glPathCommandsNV = cast(typeof(glPathCommandsNV))load("glPathCommandsNV");
	glPathCoordsNV = cast(typeof(glPathCoordsNV))load("glPathCoordsNV");
	glPathSubCommandsNV = cast(typeof(glPathSubCommandsNV))load("glPathSubCommandsNV");
	glPathSubCoordsNV = cast(typeof(glPathSubCoordsNV))load("glPathSubCoordsNV");
	glPathStringNV = cast(typeof(glPathStringNV))load("glPathStringNV");
	glPathGlyphsNV = cast(typeof(glPathGlyphsNV))load("glPathGlyphsNV");
	glPathGlyphRangeNV = cast(typeof(glPathGlyphRangeNV))load("glPathGlyphRangeNV");
	glWeightPathsNV = cast(typeof(glWeightPathsNV))load("glWeightPathsNV");
	glCopyPathNV = cast(typeof(glCopyPathNV))load("glCopyPathNV");
	glInterpolatePathsNV = cast(typeof(glInterpolatePathsNV))load("glInterpolatePathsNV");
	glTransformPathNV = cast(typeof(glTransformPathNV))load("glTransformPathNV");
	glPathParameterivNV = cast(typeof(glPathParameterivNV))load("glPathParameterivNV");
	glPathParameteriNV = cast(typeof(glPathParameteriNV))load("glPathParameteriNV");
	glPathParameterfvNV = cast(typeof(glPathParameterfvNV))load("glPathParameterfvNV");
	glPathParameterfNV = cast(typeof(glPathParameterfNV))load("glPathParameterfNV");
	glPathDashArrayNV = cast(typeof(glPathDashArrayNV))load("glPathDashArrayNV");
	glPathStencilFuncNV = cast(typeof(glPathStencilFuncNV))load("glPathStencilFuncNV");
	glPathStencilDepthOffsetNV = cast(typeof(glPathStencilDepthOffsetNV))load("glPathStencilDepthOffsetNV");
	glStencilFillPathNV = cast(typeof(glStencilFillPathNV))load("glStencilFillPathNV");
	glStencilStrokePathNV = cast(typeof(glStencilStrokePathNV))load("glStencilStrokePathNV");
	glStencilFillPathInstancedNV = cast(typeof(glStencilFillPathInstancedNV))load("glStencilFillPathInstancedNV");
	glStencilStrokePathInstancedNV = cast(typeof(glStencilStrokePathInstancedNV))load("glStencilStrokePathInstancedNV");
	glPathCoverDepthFuncNV = cast(typeof(glPathCoverDepthFuncNV))load("glPathCoverDepthFuncNV");
	glPathColorGenNV = cast(typeof(glPathColorGenNV))load("glPathColorGenNV");
	glPathTexGenNV = cast(typeof(glPathTexGenNV))load("glPathTexGenNV");
	glPathFogGenNV = cast(typeof(glPathFogGenNV))load("glPathFogGenNV");
	glCoverFillPathNV = cast(typeof(glCoverFillPathNV))load("glCoverFillPathNV");
	glCoverStrokePathNV = cast(typeof(glCoverStrokePathNV))load("glCoverStrokePathNV");
	glCoverFillPathInstancedNV = cast(typeof(glCoverFillPathInstancedNV))load("glCoverFillPathInstancedNV");
	glCoverStrokePathInstancedNV = cast(typeof(glCoverStrokePathInstancedNV))load("glCoverStrokePathInstancedNV");
	glGetPathParameterivNV = cast(typeof(glGetPathParameterivNV))load("glGetPathParameterivNV");
	glGetPathParameterfvNV = cast(typeof(glGetPathParameterfvNV))load("glGetPathParameterfvNV");
	glGetPathCommandsNV = cast(typeof(glGetPathCommandsNV))load("glGetPathCommandsNV");
	glGetPathCoordsNV = cast(typeof(glGetPathCoordsNV))load("glGetPathCoordsNV");
	glGetPathDashArrayNV = cast(typeof(glGetPathDashArrayNV))load("glGetPathDashArrayNV");
	glGetPathMetricsNV = cast(typeof(glGetPathMetricsNV))load("glGetPathMetricsNV");
	glGetPathMetricRangeNV = cast(typeof(glGetPathMetricRangeNV))load("glGetPathMetricRangeNV");
	glGetPathSpacingNV = cast(typeof(glGetPathSpacingNV))load("glGetPathSpacingNV");
	glGetPathColorGenivNV = cast(typeof(glGetPathColorGenivNV))load("glGetPathColorGenivNV");
	glGetPathColorGenfvNV = cast(typeof(glGetPathColorGenfvNV))load("glGetPathColorGenfvNV");
	glGetPathTexGenivNV = cast(typeof(glGetPathTexGenivNV))load("glGetPathTexGenivNV");
	glGetPathTexGenfvNV = cast(typeof(glGetPathTexGenfvNV))load("glGetPathTexGenfvNV");
	glIsPointInFillPathNV = cast(typeof(glIsPointInFillPathNV))load("glIsPointInFillPathNV");
	glIsPointInStrokePathNV = cast(typeof(glIsPointInStrokePathNV))load("glIsPointInStrokePathNV");
	glGetPathLengthNV = cast(typeof(glGetPathLengthNV))load("glGetPathLengthNV");
	glPointAlongPathNV = cast(typeof(glPointAlongPathNV))load("glPointAlongPathNV");
	return GL_NV_path_rendering;
}


bool load_gl_GL_ARB_compute_variable_group_size(void* function(string name) load) {
	if(!GL_ARB_compute_variable_group_size) return GL_ARB_compute_variable_group_size;

	glDispatchComputeGroupSizeARB = cast(typeof(glDispatchComputeGroupSizeARB))load("glDispatchComputeGroupSizeARB");
	return GL_ARB_compute_variable_group_size;
}


bool load_gl_GL_ATI_vertex_streams(void* function(string name) load) {
	if(!GL_ATI_vertex_streams) return GL_ATI_vertex_streams;

	glVertexStream1sATI = cast(typeof(glVertexStream1sATI))load("glVertexStream1sATI");
	glVertexStream1svATI = cast(typeof(glVertexStream1svATI))load("glVertexStream1svATI");
	glVertexStream1iATI = cast(typeof(glVertexStream1iATI))load("glVertexStream1iATI");
	glVertexStream1ivATI = cast(typeof(glVertexStream1ivATI))load("glVertexStream1ivATI");
	glVertexStream1fATI = cast(typeof(glVertexStream1fATI))load("glVertexStream1fATI");
	glVertexStream1fvATI = cast(typeof(glVertexStream1fvATI))load("glVertexStream1fvATI");
	glVertexStream1dATI = cast(typeof(glVertexStream1dATI))load("glVertexStream1dATI");
	glVertexStream1dvATI = cast(typeof(glVertexStream1dvATI))load("glVertexStream1dvATI");
	glVertexStream2sATI = cast(typeof(glVertexStream2sATI))load("glVertexStream2sATI");
	glVertexStream2svATI = cast(typeof(glVertexStream2svATI))load("glVertexStream2svATI");
	glVertexStream2iATI = cast(typeof(glVertexStream2iATI))load("glVertexStream2iATI");
	glVertexStream2ivATI = cast(typeof(glVertexStream2ivATI))load("glVertexStream2ivATI");
	glVertexStream2fATI = cast(typeof(glVertexStream2fATI))load("glVertexStream2fATI");
	glVertexStream2fvATI = cast(typeof(glVertexStream2fvATI))load("glVertexStream2fvATI");
	glVertexStream2dATI = cast(typeof(glVertexStream2dATI))load("glVertexStream2dATI");
	glVertexStream2dvATI = cast(typeof(glVertexStream2dvATI))load("glVertexStream2dvATI");
	glVertexStream3sATI = cast(typeof(glVertexStream3sATI))load("glVertexStream3sATI");
	glVertexStream3svATI = cast(typeof(glVertexStream3svATI))load("glVertexStream3svATI");
	glVertexStream3iATI = cast(typeof(glVertexStream3iATI))load("glVertexStream3iATI");
	glVertexStream3ivATI = cast(typeof(glVertexStream3ivATI))load("glVertexStream3ivATI");
	glVertexStream3fATI = cast(typeof(glVertexStream3fATI))load("glVertexStream3fATI");
	glVertexStream3fvATI = cast(typeof(glVertexStream3fvATI))load("glVertexStream3fvATI");
	glVertexStream3dATI = cast(typeof(glVertexStream3dATI))load("glVertexStream3dATI");
	glVertexStream3dvATI = cast(typeof(glVertexStream3dvATI))load("glVertexStream3dvATI");
	glVertexStream4sATI = cast(typeof(glVertexStream4sATI))load("glVertexStream4sATI");
	glVertexStream4svATI = cast(typeof(glVertexStream4svATI))load("glVertexStream4svATI");
	glVertexStream4iATI = cast(typeof(glVertexStream4iATI))load("glVertexStream4iATI");
	glVertexStream4ivATI = cast(typeof(glVertexStream4ivATI))load("glVertexStream4ivATI");
	glVertexStream4fATI = cast(typeof(glVertexStream4fATI))load("glVertexStream4fATI");
	glVertexStream4fvATI = cast(typeof(glVertexStream4fvATI))load("glVertexStream4fvATI");
	glVertexStream4dATI = cast(typeof(glVertexStream4dATI))load("glVertexStream4dATI");
	glVertexStream4dvATI = cast(typeof(glVertexStream4dvATI))load("glVertexStream4dvATI");
	glNormalStream3bATI = cast(typeof(glNormalStream3bATI))load("glNormalStream3bATI");
	glNormalStream3bvATI = cast(typeof(glNormalStream3bvATI))load("glNormalStream3bvATI");
	glNormalStream3sATI = cast(typeof(glNormalStream3sATI))load("glNormalStream3sATI");
	glNormalStream3svATI = cast(typeof(glNormalStream3svATI))load("glNormalStream3svATI");
	glNormalStream3iATI = cast(typeof(glNormalStream3iATI))load("glNormalStream3iATI");
	glNormalStream3ivATI = cast(typeof(glNormalStream3ivATI))load("glNormalStream3ivATI");
	glNormalStream3fATI = cast(typeof(glNormalStream3fATI))load("glNormalStream3fATI");
	glNormalStream3fvATI = cast(typeof(glNormalStream3fvATI))load("glNormalStream3fvATI");
	glNormalStream3dATI = cast(typeof(glNormalStream3dATI))load("glNormalStream3dATI");
	glNormalStream3dvATI = cast(typeof(glNormalStream3dvATI))load("glNormalStream3dvATI");
	glClientActiveVertexStreamATI = cast(typeof(glClientActiveVertexStreamATI))load("glClientActiveVertexStreamATI");
	glVertexBlendEnviATI = cast(typeof(glVertexBlendEnviATI))load("glVertexBlendEnviATI");
	glVertexBlendEnvfATI = cast(typeof(glVertexBlendEnvfATI))load("glVertexBlendEnvfATI");
	return GL_ATI_vertex_streams;
}


bool load_gl_GL_APPLE_specular_vector(void* function(string name) load) {
	if(!GL_APPLE_specular_vector) return GL_APPLE_specular_vector;

	return GL_APPLE_specular_vector;
}


bool load_gl_GL_APPLE_rgb_422(void* function(string name) load) {
	if(!GL_APPLE_rgb_422) return GL_APPLE_rgb_422;

	return GL_APPLE_rgb_422;
}


bool load_gl_GL_EXT_texture_lod_bias(void* function(string name) load) {
	if(!GL_EXT_texture_lod_bias) return GL_EXT_texture_lod_bias;

	return GL_EXT_texture_lod_bias;
}


bool load_gl_GL_ARB_seamless_cube_map(void* function(string name) load) {
	if(!GL_ARB_seamless_cube_map) return GL_ARB_seamless_cube_map;

	return GL_ARB_seamless_cube_map;
}


bool load_gl_GL_ARB_shader_group_vote(void* function(string name) load) {
	if(!GL_ARB_shader_group_vote) return GL_ARB_shader_group_vote;

	return GL_ARB_shader_group_vote;
}


bool load_gl_GL_NV_vdpau_interop(void* function(string name) load) {
	if(!GL_NV_vdpau_interop) return GL_NV_vdpau_interop;

	glVDPAUInitNV = cast(typeof(glVDPAUInitNV))load("glVDPAUInitNV");
	glVDPAUFiniNV = cast(typeof(glVDPAUFiniNV))load("glVDPAUFiniNV");
	glVDPAURegisterVideoSurfaceNV = cast(typeof(glVDPAURegisterVideoSurfaceNV))load("glVDPAURegisterVideoSurfaceNV");
	glVDPAURegisterOutputSurfaceNV = cast(typeof(glVDPAURegisterOutputSurfaceNV))load("glVDPAURegisterOutputSurfaceNV");
	glVDPAUIsSurfaceNV = cast(typeof(glVDPAUIsSurfaceNV))load("glVDPAUIsSurfaceNV");
	glVDPAUUnregisterSurfaceNV = cast(typeof(glVDPAUUnregisterSurfaceNV))load("glVDPAUUnregisterSurfaceNV");
	glVDPAUGetSurfaceivNV = cast(typeof(glVDPAUGetSurfaceivNV))load("glVDPAUGetSurfaceivNV");
	glVDPAUSurfaceAccessNV = cast(typeof(glVDPAUSurfaceAccessNV))load("glVDPAUSurfaceAccessNV");
	glVDPAUMapSurfacesNV = cast(typeof(glVDPAUMapSurfacesNV))load("glVDPAUMapSurfacesNV");
	glVDPAUUnmapSurfacesNV = cast(typeof(glVDPAUUnmapSurfacesNV))load("glVDPAUUnmapSurfacesNV");
	return GL_NV_vdpau_interop;
}


bool load_gl_GL_ARB_occlusion_query2(void* function(string name) load) {
	if(!GL_ARB_occlusion_query2) return GL_ARB_occlusion_query2;

	return GL_ARB_occlusion_query2;
}


bool load_gl_GL_ARB_internalformat_query2(void* function(string name) load) {
	if(!GL_ARB_internalformat_query2) return GL_ARB_internalformat_query2;

	glGetInternalformati64v = cast(typeof(glGetInternalformati64v))load("glGetInternalformati64v");
	return GL_ARB_internalformat_query2;
}


bool load_gl_GL_EXT_texture_filter_anisotropic(void* function(string name) load) {
	if(!GL_EXT_texture_filter_anisotropic) return GL_EXT_texture_filter_anisotropic;

	return GL_EXT_texture_filter_anisotropic;
}


bool load_gl_GL_SUN_vertex(void* function(string name) load) {
	if(!GL_SUN_vertex) return GL_SUN_vertex;

	glColor4ubVertex2fSUN = cast(typeof(glColor4ubVertex2fSUN))load("glColor4ubVertex2fSUN");
	glColor4ubVertex2fvSUN = cast(typeof(glColor4ubVertex2fvSUN))load("glColor4ubVertex2fvSUN");
	glColor4ubVertex3fSUN = cast(typeof(glColor4ubVertex3fSUN))load("glColor4ubVertex3fSUN");
	glColor4ubVertex3fvSUN = cast(typeof(glColor4ubVertex3fvSUN))load("glColor4ubVertex3fvSUN");
	glColor3fVertex3fSUN = cast(typeof(glColor3fVertex3fSUN))load("glColor3fVertex3fSUN");
	glColor3fVertex3fvSUN = cast(typeof(glColor3fVertex3fvSUN))load("glColor3fVertex3fvSUN");
	glNormal3fVertex3fSUN = cast(typeof(glNormal3fVertex3fSUN))load("glNormal3fVertex3fSUN");
	glNormal3fVertex3fvSUN = cast(typeof(glNormal3fVertex3fvSUN))load("glNormal3fVertex3fvSUN");
	glColor4fNormal3fVertex3fSUN = cast(typeof(glColor4fNormal3fVertex3fSUN))load("glColor4fNormal3fVertex3fSUN");
	glColor4fNormal3fVertex3fvSUN = cast(typeof(glColor4fNormal3fVertex3fvSUN))load("glColor4fNormal3fVertex3fvSUN");
	glTexCoord2fVertex3fSUN = cast(typeof(glTexCoord2fVertex3fSUN))load("glTexCoord2fVertex3fSUN");
	glTexCoord2fVertex3fvSUN = cast(typeof(glTexCoord2fVertex3fvSUN))load("glTexCoord2fVertex3fvSUN");
	glTexCoord4fVertex4fSUN = cast(typeof(glTexCoord4fVertex4fSUN))load("glTexCoord4fVertex4fSUN");
	glTexCoord4fVertex4fvSUN = cast(typeof(glTexCoord4fVertex4fvSUN))load("glTexCoord4fVertex4fvSUN");
	glTexCoord2fColor4ubVertex3fSUN = cast(typeof(glTexCoord2fColor4ubVertex3fSUN))load("glTexCoord2fColor4ubVertex3fSUN");
	glTexCoord2fColor4ubVertex3fvSUN = cast(typeof(glTexCoord2fColor4ubVertex3fvSUN))load("glTexCoord2fColor4ubVertex3fvSUN");
	glTexCoord2fColor3fVertex3fSUN = cast(typeof(glTexCoord2fColor3fVertex3fSUN))load("glTexCoord2fColor3fVertex3fSUN");
	glTexCoord2fColor3fVertex3fvSUN = cast(typeof(glTexCoord2fColor3fVertex3fvSUN))load("glTexCoord2fColor3fVertex3fvSUN");
	glTexCoord2fNormal3fVertex3fSUN = cast(typeof(glTexCoord2fNormal3fVertex3fSUN))load("glTexCoord2fNormal3fVertex3fSUN");
	glTexCoord2fNormal3fVertex3fvSUN = cast(typeof(glTexCoord2fNormal3fVertex3fvSUN))load("glTexCoord2fNormal3fVertex3fvSUN");
	glTexCoord2fColor4fNormal3fVertex3fSUN = cast(typeof(glTexCoord2fColor4fNormal3fVertex3fSUN))load("glTexCoord2fColor4fNormal3fVertex3fSUN");
	glTexCoord2fColor4fNormal3fVertex3fvSUN = cast(typeof(glTexCoord2fColor4fNormal3fVertex3fvSUN))load("glTexCoord2fColor4fNormal3fVertex3fvSUN");
	glTexCoord4fColor4fNormal3fVertex4fSUN = cast(typeof(glTexCoord4fColor4fNormal3fVertex4fSUN))load("glTexCoord4fColor4fNormal3fVertex4fSUN");
	glTexCoord4fColor4fNormal3fVertex4fvSUN = cast(typeof(glTexCoord4fColor4fNormal3fVertex4fvSUN))load("glTexCoord4fColor4fNormal3fVertex4fvSUN");
	glReplacementCodeuiVertex3fSUN = cast(typeof(glReplacementCodeuiVertex3fSUN))load("glReplacementCodeuiVertex3fSUN");
	glReplacementCodeuiVertex3fvSUN = cast(typeof(glReplacementCodeuiVertex3fvSUN))load("glReplacementCodeuiVertex3fvSUN");
	glReplacementCodeuiColor4ubVertex3fSUN = cast(typeof(glReplacementCodeuiColor4ubVertex3fSUN))load("glReplacementCodeuiColor4ubVertex3fSUN");
	glReplacementCodeuiColor4ubVertex3fvSUN = cast(typeof(glReplacementCodeuiColor4ubVertex3fvSUN))load("glReplacementCodeuiColor4ubVertex3fvSUN");
	glReplacementCodeuiColor3fVertex3fSUN = cast(typeof(glReplacementCodeuiColor3fVertex3fSUN))load("glReplacementCodeuiColor3fVertex3fSUN");
	glReplacementCodeuiColor3fVertex3fvSUN = cast(typeof(glReplacementCodeuiColor3fVertex3fvSUN))load("glReplacementCodeuiColor3fVertex3fvSUN");
	glReplacementCodeuiNormal3fVertex3fSUN = cast(typeof(glReplacementCodeuiNormal3fVertex3fSUN))load("glReplacementCodeuiNormal3fVertex3fSUN");
	glReplacementCodeuiNormal3fVertex3fvSUN = cast(typeof(glReplacementCodeuiNormal3fVertex3fvSUN))load("glReplacementCodeuiNormal3fVertex3fvSUN");
	glReplacementCodeuiColor4fNormal3fVertex3fSUN = cast(typeof(glReplacementCodeuiColor4fNormal3fVertex3fSUN))load("glReplacementCodeuiColor4fNormal3fVertex3fSUN");
	glReplacementCodeuiColor4fNormal3fVertex3fvSUN = cast(typeof(glReplacementCodeuiColor4fNormal3fVertex3fvSUN))load("glReplacementCodeuiColor4fNormal3fVertex3fvSUN");
	glReplacementCodeuiTexCoord2fVertex3fSUN = cast(typeof(glReplacementCodeuiTexCoord2fVertex3fSUN))load("glReplacementCodeuiTexCoord2fVertex3fSUN");
	glReplacementCodeuiTexCoord2fVertex3fvSUN = cast(typeof(glReplacementCodeuiTexCoord2fVertex3fvSUN))load("glReplacementCodeuiTexCoord2fVertex3fvSUN");
	glReplacementCodeuiTexCoord2fNormal3fVertex3fSUN = cast(typeof(glReplacementCodeuiTexCoord2fNormal3fVertex3fSUN))load("glReplacementCodeuiTexCoord2fNormal3fVertex3fSUN");
	glReplacementCodeuiTexCoord2fNormal3fVertex3fvSUN = cast(typeof(glReplacementCodeuiTexCoord2fNormal3fVertex3fvSUN))load("glReplacementCodeuiTexCoord2fNormal3fVertex3fvSUN");
	glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fSUN = cast(typeof(glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fSUN))load("glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fSUN");
	glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fvSUN = cast(typeof(glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fvSUN))load("glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fvSUN");
	return GL_SUN_vertex;
}


bool load_gl_GL_ARB_sparse_texture(void* function(string name) load) {
	if(!GL_ARB_sparse_texture) return GL_ARB_sparse_texture;

	glTexPageCommitmentARB = cast(typeof(glTexPageCommitmentARB))load("glTexPageCommitmentARB");
	return GL_ARB_sparse_texture;
}


bool load_gl_GL_SGIS_texture_lod(void* function(string name) load) {
	if(!GL_SGIS_texture_lod) return GL_SGIS_texture_lod;

	return GL_SGIS_texture_lod;
}


bool load_gl_GL_NV_vertex_program3(void* function(string name) load) {
	if(!GL_NV_vertex_program3) return GL_NV_vertex_program3;

	return GL_NV_vertex_program3;
}


bool load_gl_GL_NV_gpu_shader5(void* function(string name) load) {
	if(!GL_NV_gpu_shader5) return GL_NV_gpu_shader5;

	glUniform1i64NV = cast(typeof(glUniform1i64NV))load("glUniform1i64NV");
	glUniform2i64NV = cast(typeof(glUniform2i64NV))load("glUniform2i64NV");
	glUniform3i64NV = cast(typeof(glUniform3i64NV))load("glUniform3i64NV");
	glUniform4i64NV = cast(typeof(glUniform4i64NV))load("glUniform4i64NV");
	glUniform1i64vNV = cast(typeof(glUniform1i64vNV))load("glUniform1i64vNV");
	glUniform2i64vNV = cast(typeof(glUniform2i64vNV))load("glUniform2i64vNV");
	glUniform3i64vNV = cast(typeof(glUniform3i64vNV))load("glUniform3i64vNV");
	glUniform4i64vNV = cast(typeof(glUniform4i64vNV))load("glUniform4i64vNV");
	glUniform1ui64NV = cast(typeof(glUniform1ui64NV))load("glUniform1ui64NV");
	glUniform2ui64NV = cast(typeof(glUniform2ui64NV))load("glUniform2ui64NV");
	glUniform3ui64NV = cast(typeof(glUniform3ui64NV))load("glUniform3ui64NV");
	glUniform4ui64NV = cast(typeof(glUniform4ui64NV))load("glUniform4ui64NV");
	glUniform1ui64vNV = cast(typeof(glUniform1ui64vNV))load("glUniform1ui64vNV");
	glUniform2ui64vNV = cast(typeof(glUniform2ui64vNV))load("glUniform2ui64vNV");
	glUniform3ui64vNV = cast(typeof(glUniform3ui64vNV))load("glUniform3ui64vNV");
	glUniform4ui64vNV = cast(typeof(glUniform4ui64vNV))load("glUniform4ui64vNV");
	glGetUniformi64vNV = cast(typeof(glGetUniformi64vNV))load("glGetUniformi64vNV");
	glProgramUniform1i64NV = cast(typeof(glProgramUniform1i64NV))load("glProgramUniform1i64NV");
	glProgramUniform2i64NV = cast(typeof(glProgramUniform2i64NV))load("glProgramUniform2i64NV");
	glProgramUniform3i64NV = cast(typeof(glProgramUniform3i64NV))load("glProgramUniform3i64NV");
	glProgramUniform4i64NV = cast(typeof(glProgramUniform4i64NV))load("glProgramUniform4i64NV");
	glProgramUniform1i64vNV = cast(typeof(glProgramUniform1i64vNV))load("glProgramUniform1i64vNV");
	glProgramUniform2i64vNV = cast(typeof(glProgramUniform2i64vNV))load("glProgramUniform2i64vNV");
	glProgramUniform3i64vNV = cast(typeof(glProgramUniform3i64vNV))load("glProgramUniform3i64vNV");
	glProgramUniform4i64vNV = cast(typeof(glProgramUniform4i64vNV))load("glProgramUniform4i64vNV");
	glProgramUniform1ui64NV = cast(typeof(glProgramUniform1ui64NV))load("glProgramUniform1ui64NV");
	glProgramUniform2ui64NV = cast(typeof(glProgramUniform2ui64NV))load("glProgramUniform2ui64NV");
	glProgramUniform3ui64NV = cast(typeof(glProgramUniform3ui64NV))load("glProgramUniform3ui64NV");
	glProgramUniform4ui64NV = cast(typeof(glProgramUniform4ui64NV))load("glProgramUniform4ui64NV");
	glProgramUniform1ui64vNV = cast(typeof(glProgramUniform1ui64vNV))load("glProgramUniform1ui64vNV");
	glProgramUniform2ui64vNV = cast(typeof(glProgramUniform2ui64vNV))load("glProgramUniform2ui64vNV");
	glProgramUniform3ui64vNV = cast(typeof(glProgramUniform3ui64vNV))load("glProgramUniform3ui64vNV");
	glProgramUniform4ui64vNV = cast(typeof(glProgramUniform4ui64vNV))load("glProgramUniform4ui64vNV");
	return GL_NV_gpu_shader5;
}


bool load_gl_GL_NV_vertex_program4(void* function(string name) load) {
	if(!GL_NV_vertex_program4) return GL_NV_vertex_program4;

	glVertexAttribI1iEXT = cast(typeof(glVertexAttribI1iEXT))load("glVertexAttribI1iEXT");
	glVertexAttribI2iEXT = cast(typeof(glVertexAttribI2iEXT))load("glVertexAttribI2iEXT");
	glVertexAttribI3iEXT = cast(typeof(glVertexAttribI3iEXT))load("glVertexAttribI3iEXT");
	glVertexAttribI4iEXT = cast(typeof(glVertexAttribI4iEXT))load("glVertexAttribI4iEXT");
	glVertexAttribI1uiEXT = cast(typeof(glVertexAttribI1uiEXT))load("glVertexAttribI1uiEXT");
	glVertexAttribI2uiEXT = cast(typeof(glVertexAttribI2uiEXT))load("glVertexAttribI2uiEXT");
	glVertexAttribI3uiEXT = cast(typeof(glVertexAttribI3uiEXT))load("glVertexAttribI3uiEXT");
	glVertexAttribI4uiEXT = cast(typeof(glVertexAttribI4uiEXT))load("glVertexAttribI4uiEXT");
	glVertexAttribI1ivEXT = cast(typeof(glVertexAttribI1ivEXT))load("glVertexAttribI1ivEXT");
	glVertexAttribI2ivEXT = cast(typeof(glVertexAttribI2ivEXT))load("glVertexAttribI2ivEXT");
	glVertexAttribI3ivEXT = cast(typeof(glVertexAttribI3ivEXT))load("glVertexAttribI3ivEXT");
	glVertexAttribI4ivEXT = cast(typeof(glVertexAttribI4ivEXT))load("glVertexAttribI4ivEXT");
	glVertexAttribI1uivEXT = cast(typeof(glVertexAttribI1uivEXT))load("glVertexAttribI1uivEXT");
	glVertexAttribI2uivEXT = cast(typeof(glVertexAttribI2uivEXT))load("glVertexAttribI2uivEXT");
	glVertexAttribI3uivEXT = cast(typeof(glVertexAttribI3uivEXT))load("glVertexAttribI3uivEXT");
	glVertexAttribI4uivEXT = cast(typeof(glVertexAttribI4uivEXT))load("glVertexAttribI4uivEXT");
	glVertexAttribI4bvEXT = cast(typeof(glVertexAttribI4bvEXT))load("glVertexAttribI4bvEXT");
	glVertexAttribI4svEXT = cast(typeof(glVertexAttribI4svEXT))load("glVertexAttribI4svEXT");
	glVertexAttribI4ubvEXT = cast(typeof(glVertexAttribI4ubvEXT))load("glVertexAttribI4ubvEXT");
	glVertexAttribI4usvEXT = cast(typeof(glVertexAttribI4usvEXT))load("glVertexAttribI4usvEXT");
	glVertexAttribIPointerEXT = cast(typeof(glVertexAttribIPointerEXT))load("glVertexAttribIPointerEXT");
	glGetVertexAttribIivEXT = cast(typeof(glGetVertexAttribIivEXT))load("glGetVertexAttribIivEXT");
	glGetVertexAttribIuivEXT = cast(typeof(glGetVertexAttribIuivEXT))load("glGetVertexAttribIuivEXT");
	return GL_NV_vertex_program4;
}


bool load_gl_GL_AMD_transform_feedback3_lines_triangles(void* function(string name) load) {
	if(!GL_AMD_transform_feedback3_lines_triangles) return GL_AMD_transform_feedback3_lines_triangles;

	return GL_AMD_transform_feedback3_lines_triangles;
}


bool load_gl_GL_SGIS_fog_function(void* function(string name) load) {
	if(!GL_SGIS_fog_function) return GL_SGIS_fog_function;

	glFogFuncSGIS = cast(typeof(glFogFuncSGIS))load("glFogFuncSGIS");
	glGetFogFuncSGIS = cast(typeof(glGetFogFuncSGIS))load("glGetFogFuncSGIS");
	return GL_SGIS_fog_function;
}


bool load_gl_GL_EXT_x11_sync_object(void* function(string name) load) {
	if(!GL_EXT_x11_sync_object) return GL_EXT_x11_sync_object;

	glImportSyncEXT = cast(typeof(glImportSyncEXT))load("glImportSyncEXT");
	return GL_EXT_x11_sync_object;
}


void load_gl_GL_VERSION_1_5(void* function(string name) load) {
	if(!GL_VERSION_1_5) return;
	glGenQueries = cast(typeof(glGenQueries))load("glGenQueries");
	glDeleteQueries = cast(typeof(glDeleteQueries))load("glDeleteQueries");
	glIsQuery = cast(typeof(glIsQuery))load("glIsQuery");
	glBeginQuery = cast(typeof(glBeginQuery))load("glBeginQuery");
	glEndQuery = cast(typeof(glEndQuery))load("glEndQuery");
	glGetQueryiv = cast(typeof(glGetQueryiv))load("glGetQueryiv");
	glGetQueryObjectiv = cast(typeof(glGetQueryObjectiv))load("glGetQueryObjectiv");
	glGetQueryObjectuiv = cast(typeof(glGetQueryObjectuiv))load("glGetQueryObjectuiv");
	glBindBuffer = cast(typeof(glBindBuffer))load("glBindBuffer");
	glDeleteBuffers = cast(typeof(glDeleteBuffers))load("glDeleteBuffers");
	glGenBuffers = cast(typeof(glGenBuffers))load("glGenBuffers");
	glIsBuffer = cast(typeof(glIsBuffer))load("glIsBuffer");
	glBufferData = cast(typeof(glBufferData))load("glBufferData");
	glBufferSubData = cast(typeof(glBufferSubData))load("glBufferSubData");
	glGetBufferSubData = cast(typeof(glGetBufferSubData))load("glGetBufferSubData");
	glMapBuffer = cast(typeof(glMapBuffer))load("glMapBuffer");
	glUnmapBuffer = cast(typeof(glUnmapBuffer))load("glUnmapBuffer");
	glGetBufferParameteriv = cast(typeof(glGetBufferParameteriv))load("glGetBufferParameteriv");
	glGetBufferPointerv = cast(typeof(glGetBufferPointerv))load("glGetBufferPointerv");
	return;
}

void load_gl_GL_VERSION_1_4(void* function(string name) load) {
	if(!GL_VERSION_1_4) return;
	glBlendFuncSeparate = cast(typeof(glBlendFuncSeparate))load("glBlendFuncSeparate");
	glMultiDrawArrays = cast(typeof(glMultiDrawArrays))load("glMultiDrawArrays");
	glMultiDrawElements = cast(typeof(glMultiDrawElements))load("glMultiDrawElements");
	glPointParameterf = cast(typeof(glPointParameterf))load("glPointParameterf");
	glPointParameterfv = cast(typeof(glPointParameterfv))load("glPointParameterfv");
	glPointParameteri = cast(typeof(glPointParameteri))load("glPointParameteri");
	glPointParameteriv = cast(typeof(glPointParameteriv))load("glPointParameteriv");
	glBlendColor = cast(typeof(glBlendColor))load("glBlendColor");
	glBlendEquation = cast(typeof(glBlendEquation))load("glBlendEquation");
	return;
}

void load_gl_GL_VERSION_1_3(void* function(string name) load) {
	if(!GL_VERSION_1_3) return;
	glActiveTexture = cast(typeof(glActiveTexture))load("glActiveTexture");
	glSampleCoverage = cast(typeof(glSampleCoverage))load("glSampleCoverage");
	glCompressedTexImage3D = cast(typeof(glCompressedTexImage3D))load("glCompressedTexImage3D");
	glCompressedTexImage2D = cast(typeof(glCompressedTexImage2D))load("glCompressedTexImage2D");
	glCompressedTexImage1D = cast(typeof(glCompressedTexImage1D))load("glCompressedTexImage1D");
	glCompressedTexSubImage3D = cast(typeof(glCompressedTexSubImage3D))load("glCompressedTexSubImage3D");
	glCompressedTexSubImage2D = cast(typeof(glCompressedTexSubImage2D))load("glCompressedTexSubImage2D");
	glCompressedTexSubImage1D = cast(typeof(glCompressedTexSubImage1D))load("glCompressedTexSubImage1D");
	glGetCompressedTexImage = cast(typeof(glGetCompressedTexImage))load("glGetCompressedTexImage");
	return;
}

void load_gl_GL_VERSION_1_2(void* function(string name) load) {
	if(!GL_VERSION_1_2) return;
	glBlendColor = cast(typeof(glBlendColor))load("glBlendColor");
	glBlendEquation = cast(typeof(glBlendEquation))load("glBlendEquation");
	glDrawRangeElements = cast(typeof(glDrawRangeElements))load("glDrawRangeElements");
	glTexImage3D = cast(typeof(glTexImage3D))load("glTexImage3D");
	glTexSubImage3D = cast(typeof(glTexSubImage3D))load("glTexSubImage3D");
	glCopyTexSubImage3D = cast(typeof(glCopyTexSubImage3D))load("glCopyTexSubImage3D");
	return;
}

void load_gl_GL_VERSION_1_1(void* function(string name) load) {
	if(!GL_VERSION_1_1) return;
	glDrawArrays = cast(typeof(glDrawArrays))load("glDrawArrays");
	glDrawElements = cast(typeof(glDrawElements))load("glDrawElements");
	glPolygonOffset = cast(typeof(glPolygonOffset))load("glPolygonOffset");
	glCopyTexImage1D = cast(typeof(glCopyTexImage1D))load("glCopyTexImage1D");
	glCopyTexImage2D = cast(typeof(glCopyTexImage2D))load("glCopyTexImage2D");
	glCopyTexSubImage1D = cast(typeof(glCopyTexSubImage1D))load("glCopyTexSubImage1D");
	glCopyTexSubImage2D = cast(typeof(glCopyTexSubImage2D))load("glCopyTexSubImage2D");
	glTexSubImage1D = cast(typeof(glTexSubImage1D))load("glTexSubImage1D");
	glTexSubImage2D = cast(typeof(glTexSubImage2D))load("glTexSubImage2D");
	glBindTexture = cast(typeof(glBindTexture))load("glBindTexture");
	glDeleteTextures = cast(typeof(glDeleteTextures))load("glDeleteTextures");
	glGenTextures = cast(typeof(glGenTextures))load("glGenTextures");
	glIsTexture = cast(typeof(glIsTexture))load("glIsTexture");
	return;
}

void load_gl_GL_VERSION_1_0(void* function(string name) load) {
	if(!GL_VERSION_1_0) return;
	glCullFace = cast(typeof(glCullFace))load("glCullFace");
	glFrontFace = cast(typeof(glFrontFace))load("glFrontFace");
	glHint = cast(typeof(glHint))load("glHint");
	glLineWidth = cast(typeof(glLineWidth))load("glLineWidth");
	glPointSize = cast(typeof(glPointSize))load("glPointSize");
	glPolygonMode = cast(typeof(glPolygonMode))load("glPolygonMode");
	glScissor = cast(typeof(glScissor))load("glScissor");
	glTexParameterf = cast(typeof(glTexParameterf))load("glTexParameterf");
	glTexParameterfv = cast(typeof(glTexParameterfv))load("glTexParameterfv");
	glTexParameteri = cast(typeof(glTexParameteri))load("glTexParameteri");
	glTexParameteriv = cast(typeof(glTexParameteriv))load("glTexParameteriv");
	glTexImage1D = cast(typeof(glTexImage1D))load("glTexImage1D");
	glTexImage2D = cast(typeof(glTexImage2D))load("glTexImage2D");
	glDrawBuffer = cast(typeof(glDrawBuffer))load("glDrawBuffer");
	glClear = cast(typeof(glClear))load("glClear");
	glClearColor = cast(typeof(glClearColor))load("glClearColor");
	glClearStencil = cast(typeof(glClearStencil))load("glClearStencil");
	glClearDepth = cast(typeof(glClearDepth))load("glClearDepth");
	glStencilMask = cast(typeof(glStencilMask))load("glStencilMask");
	glColorMask = cast(typeof(glColorMask))load("glColorMask");
	glDepthMask = cast(typeof(glDepthMask))load("glDepthMask");
	glDisable = cast(typeof(glDisable))load("glDisable");
	glEnable = cast(typeof(glEnable))load("glEnable");
	glFinish = cast(typeof(glFinish))load("glFinish");
	glFlush = cast(typeof(glFlush))load("glFlush");
	glBlendFunc = cast(typeof(glBlendFunc))load("glBlendFunc");
	glLogicOp = cast(typeof(glLogicOp))load("glLogicOp");
	glStencilFunc = cast(typeof(glStencilFunc))load("glStencilFunc");
	glStencilOp = cast(typeof(glStencilOp))load("glStencilOp");
	glDepthFunc = cast(typeof(glDepthFunc))load("glDepthFunc");
	glPixelStoref = cast(typeof(glPixelStoref))load("glPixelStoref");
	glPixelStorei = cast(typeof(glPixelStorei))load("glPixelStorei");
	glReadBuffer = cast(typeof(glReadBuffer))load("glReadBuffer");
	glReadPixels = cast(typeof(glReadPixels))load("glReadPixels");
	glGetBooleanv = cast(typeof(glGetBooleanv))load("glGetBooleanv");
	glGetDoublev = cast(typeof(glGetDoublev))load("glGetDoublev");
	glGetError = cast(typeof(glGetError))load("glGetError");
	glGetFloatv = cast(typeof(glGetFloatv))load("glGetFloatv");
	glGetIntegerv = cast(typeof(glGetIntegerv))load("glGetIntegerv");
	glGetString = cast(typeof(glGetString))load("glGetString");
	glGetTexImage = cast(typeof(glGetTexImage))load("glGetTexImage");
	glGetTexParameterfv = cast(typeof(glGetTexParameterfv))load("glGetTexParameterfv");
	glGetTexParameteriv = cast(typeof(glGetTexParameteriv))load("glGetTexParameteriv");
	glGetTexLevelParameterfv = cast(typeof(glGetTexLevelParameterfv))load("glGetTexLevelParameterfv");
	glGetTexLevelParameteriv = cast(typeof(glGetTexLevelParameteriv))load("glGetTexLevelParameteriv");
	glIsEnabled = cast(typeof(glIsEnabled))load("glIsEnabled");
	glDepthRange = cast(typeof(glDepthRange))load("glDepthRange");
	glViewport = cast(typeof(glViewport))load("glViewport");
	return;
}

void load_gl_GL_VERSION_3_1(void* function(string name) load) {
	if(!GL_VERSION_3_1) return;
	glDrawArraysInstanced = cast(typeof(glDrawArraysInstanced))load("glDrawArraysInstanced");
	glDrawElementsInstanced = cast(typeof(glDrawElementsInstanced))load("glDrawElementsInstanced");
	glTexBuffer = cast(typeof(glTexBuffer))load("glTexBuffer");
	glPrimitiveRestartIndex = cast(typeof(glPrimitiveRestartIndex))load("glPrimitiveRestartIndex");
	glCopyBufferSubData = cast(typeof(glCopyBufferSubData))load("glCopyBufferSubData");
	glGetUniformIndices = cast(typeof(glGetUniformIndices))load("glGetUniformIndices");
	glGetActiveUniformsiv = cast(typeof(glGetActiveUniformsiv))load("glGetActiveUniformsiv");
	glGetActiveUniformName = cast(typeof(glGetActiveUniformName))load("glGetActiveUniformName");
	glGetUniformBlockIndex = cast(typeof(glGetUniformBlockIndex))load("glGetUniformBlockIndex");
	glGetActiveUniformBlockiv = cast(typeof(glGetActiveUniformBlockiv))load("glGetActiveUniformBlockiv");
	glGetActiveUniformBlockName = cast(typeof(glGetActiveUniformBlockName))load("glGetActiveUniformBlockName");
	glUniformBlockBinding = cast(typeof(glUniformBlockBinding))load("glUniformBlockBinding");
	return;
}

void load_gl_GL_VERSION_3_0(void* function(string name) load) {
	if(!GL_VERSION_3_0) return;
	glColorMaski = cast(typeof(glColorMaski))load("glColorMaski");
	glGetBooleani_v = cast(typeof(glGetBooleani_v))load("glGetBooleani_v");
	glGetIntegeri_v = cast(typeof(glGetIntegeri_v))load("glGetIntegeri_v");
	glEnablei = cast(typeof(glEnablei))load("glEnablei");
	glDisablei = cast(typeof(glDisablei))load("glDisablei");
	glIsEnabledi = cast(typeof(glIsEnabledi))load("glIsEnabledi");
	glBeginTransformFeedback = cast(typeof(glBeginTransformFeedback))load("glBeginTransformFeedback");
	glEndTransformFeedback = cast(typeof(glEndTransformFeedback))load("glEndTransformFeedback");
	glBindBufferRange = cast(typeof(glBindBufferRange))load("glBindBufferRange");
	glBindBufferBase = cast(typeof(glBindBufferBase))load("glBindBufferBase");
	glTransformFeedbackVaryings = cast(typeof(glTransformFeedbackVaryings))load("glTransformFeedbackVaryings");
	glGetTransformFeedbackVarying = cast(typeof(glGetTransformFeedbackVarying))load("glGetTransformFeedbackVarying");
	glClampColor = cast(typeof(glClampColor))load("glClampColor");
	glBeginConditionalRender = cast(typeof(glBeginConditionalRender))load("glBeginConditionalRender");
	glEndConditionalRender = cast(typeof(glEndConditionalRender))load("glEndConditionalRender");
	glVertexAttribIPointer = cast(typeof(glVertexAttribIPointer))load("glVertexAttribIPointer");
	glGetVertexAttribIiv = cast(typeof(glGetVertexAttribIiv))load("glGetVertexAttribIiv");
	glGetVertexAttribIuiv = cast(typeof(glGetVertexAttribIuiv))load("glGetVertexAttribIuiv");
	glVertexAttribI1i = cast(typeof(glVertexAttribI1i))load("glVertexAttribI1i");
	glVertexAttribI2i = cast(typeof(glVertexAttribI2i))load("glVertexAttribI2i");
	glVertexAttribI3i = cast(typeof(glVertexAttribI3i))load("glVertexAttribI3i");
	glVertexAttribI4i = cast(typeof(glVertexAttribI4i))load("glVertexAttribI4i");
	glVertexAttribI1ui = cast(typeof(glVertexAttribI1ui))load("glVertexAttribI1ui");
	glVertexAttribI2ui = cast(typeof(glVertexAttribI2ui))load("glVertexAttribI2ui");
	glVertexAttribI3ui = cast(typeof(glVertexAttribI3ui))load("glVertexAttribI3ui");
	glVertexAttribI4ui = cast(typeof(glVertexAttribI4ui))load("glVertexAttribI4ui");
	glVertexAttribI1iv = cast(typeof(glVertexAttribI1iv))load("glVertexAttribI1iv");
	glVertexAttribI2iv = cast(typeof(glVertexAttribI2iv))load("glVertexAttribI2iv");
	glVertexAttribI3iv = cast(typeof(glVertexAttribI3iv))load("glVertexAttribI3iv");
	glVertexAttribI4iv = cast(typeof(glVertexAttribI4iv))load("glVertexAttribI4iv");
	glVertexAttribI1uiv = cast(typeof(glVertexAttribI1uiv))load("glVertexAttribI1uiv");
	glVertexAttribI2uiv = cast(typeof(glVertexAttribI2uiv))load("glVertexAttribI2uiv");
	glVertexAttribI3uiv = cast(typeof(glVertexAttribI3uiv))load("glVertexAttribI3uiv");
	glVertexAttribI4uiv = cast(typeof(glVertexAttribI4uiv))load("glVertexAttribI4uiv");
	glVertexAttribI4bv = cast(typeof(glVertexAttribI4bv))load("glVertexAttribI4bv");
	glVertexAttribI4sv = cast(typeof(glVertexAttribI4sv))load("glVertexAttribI4sv");
	glVertexAttribI4ubv = cast(typeof(glVertexAttribI4ubv))load("glVertexAttribI4ubv");
	glVertexAttribI4usv = cast(typeof(glVertexAttribI4usv))load("glVertexAttribI4usv");
	glGetUniformuiv = cast(typeof(glGetUniformuiv))load("glGetUniformuiv");
	glBindFragDataLocation = cast(typeof(glBindFragDataLocation))load("glBindFragDataLocation");
	glGetFragDataLocation = cast(typeof(glGetFragDataLocation))load("glGetFragDataLocation");
	glUniform1ui = cast(typeof(glUniform1ui))load("glUniform1ui");
	glUniform2ui = cast(typeof(glUniform2ui))load("glUniform2ui");
	glUniform3ui = cast(typeof(glUniform3ui))load("glUniform3ui");
	glUniform4ui = cast(typeof(glUniform4ui))load("glUniform4ui");
	glUniform1uiv = cast(typeof(glUniform1uiv))load("glUniform1uiv");
	glUniform2uiv = cast(typeof(glUniform2uiv))load("glUniform2uiv");
	glUniform3uiv = cast(typeof(glUniform3uiv))load("glUniform3uiv");
	glUniform4uiv = cast(typeof(glUniform4uiv))load("glUniform4uiv");
	glTexParameterIiv = cast(typeof(glTexParameterIiv))load("glTexParameterIiv");
	glTexParameterIuiv = cast(typeof(glTexParameterIuiv))load("glTexParameterIuiv");
	glGetTexParameterIiv = cast(typeof(glGetTexParameterIiv))load("glGetTexParameterIiv");
	glGetTexParameterIuiv = cast(typeof(glGetTexParameterIuiv))load("glGetTexParameterIuiv");
	glClearBufferiv = cast(typeof(glClearBufferiv))load("glClearBufferiv");
	glClearBufferuiv = cast(typeof(glClearBufferuiv))load("glClearBufferuiv");
	glClearBufferfv = cast(typeof(glClearBufferfv))load("glClearBufferfv");
	glClearBufferfi = cast(typeof(glClearBufferfi))load("glClearBufferfi");
	glGetStringi = cast(typeof(glGetStringi))load("glGetStringi");
	glIsRenderbuffer = cast(typeof(glIsRenderbuffer))load("glIsRenderbuffer");
	glBindRenderbuffer = cast(typeof(glBindRenderbuffer))load("glBindRenderbuffer");
	glDeleteRenderbuffers = cast(typeof(glDeleteRenderbuffers))load("glDeleteRenderbuffers");
	glGenRenderbuffers = cast(typeof(glGenRenderbuffers))load("glGenRenderbuffers");
	glRenderbufferStorage = cast(typeof(glRenderbufferStorage))load("glRenderbufferStorage");
	glGetRenderbufferParameteriv = cast(typeof(glGetRenderbufferParameteriv))load("glGetRenderbufferParameteriv");
	glIsFramebuffer = cast(typeof(glIsFramebuffer))load("glIsFramebuffer");
	glBindFramebuffer = cast(typeof(glBindFramebuffer))load("glBindFramebuffer");
	glDeleteFramebuffers = cast(typeof(glDeleteFramebuffers))load("glDeleteFramebuffers");
	glGenFramebuffers = cast(typeof(glGenFramebuffers))load("glGenFramebuffers");
	glCheckFramebufferStatus = cast(typeof(glCheckFramebufferStatus))load("glCheckFramebufferStatus");
	glFramebufferTexture1D = cast(typeof(glFramebufferTexture1D))load("glFramebufferTexture1D");
	glFramebufferTexture2D = cast(typeof(glFramebufferTexture2D))load("glFramebufferTexture2D");
	glFramebufferTexture3D = cast(typeof(glFramebufferTexture3D))load("glFramebufferTexture3D");
	glFramebufferRenderbuffer = cast(typeof(glFramebufferRenderbuffer))load("glFramebufferRenderbuffer");
	glGetFramebufferAttachmentParameteriv = cast(typeof(glGetFramebufferAttachmentParameteriv))load("glGetFramebufferAttachmentParameteriv");
	glGenerateMipmap = cast(typeof(glGenerateMipmap))load("glGenerateMipmap");
	glBlitFramebuffer = cast(typeof(glBlitFramebuffer))load("glBlitFramebuffer");
	glRenderbufferStorageMultisample = cast(typeof(glRenderbufferStorageMultisample))load("glRenderbufferStorageMultisample");
	glFramebufferTextureLayer = cast(typeof(glFramebufferTextureLayer))load("glFramebufferTextureLayer");
	glMapBufferRange = cast(typeof(glMapBufferRange))load("glMapBufferRange");
	glFlushMappedBufferRange = cast(typeof(glFlushMappedBufferRange))load("glFlushMappedBufferRange");
	glBindVertexArray = cast(typeof(glBindVertexArray))load("glBindVertexArray");
	glDeleteVertexArrays = cast(typeof(glDeleteVertexArrays))load("glDeleteVertexArrays");
	glGenVertexArrays = cast(typeof(glGenVertexArrays))load("glGenVertexArrays");
	glIsVertexArray = cast(typeof(glIsVertexArray))load("glIsVertexArray");
	return;
}

void load_gl_GL_VERSION_3_3(void* function(string name) load) {
	if(!GL_VERSION_3_3) return;
	glBindFragDataLocationIndexed = cast(typeof(glBindFragDataLocationIndexed))load("glBindFragDataLocationIndexed");
	glGetFragDataIndex = cast(typeof(glGetFragDataIndex))load("glGetFragDataIndex");
	glGenSamplers = cast(typeof(glGenSamplers))load("glGenSamplers");
	glDeleteSamplers = cast(typeof(glDeleteSamplers))load("glDeleteSamplers");
	glIsSampler = cast(typeof(glIsSampler))load("glIsSampler");
	glBindSampler = cast(typeof(glBindSampler))load("glBindSampler");
	glSamplerParameteri = cast(typeof(glSamplerParameteri))load("glSamplerParameteri");
	glSamplerParameteriv = cast(typeof(glSamplerParameteriv))load("glSamplerParameteriv");
	glSamplerParameterf = cast(typeof(glSamplerParameterf))load("glSamplerParameterf");
	glSamplerParameterfv = cast(typeof(glSamplerParameterfv))load("glSamplerParameterfv");
	glSamplerParameterIiv = cast(typeof(glSamplerParameterIiv))load("glSamplerParameterIiv");
	glSamplerParameterIuiv = cast(typeof(glSamplerParameterIuiv))load("glSamplerParameterIuiv");
	glGetSamplerParameteriv = cast(typeof(glGetSamplerParameteriv))load("glGetSamplerParameteriv");
	glGetSamplerParameterIiv = cast(typeof(glGetSamplerParameterIiv))load("glGetSamplerParameterIiv");
	glGetSamplerParameterfv = cast(typeof(glGetSamplerParameterfv))load("glGetSamplerParameterfv");
	glGetSamplerParameterIuiv = cast(typeof(glGetSamplerParameterIuiv))load("glGetSamplerParameterIuiv");
	glQueryCounter = cast(typeof(glQueryCounter))load("glQueryCounter");
	glGetQueryObjecti64v = cast(typeof(glGetQueryObjecti64v))load("glGetQueryObjecti64v");
	glGetQueryObjectui64v = cast(typeof(glGetQueryObjectui64v))load("glGetQueryObjectui64v");
	glVertexAttribDivisor = cast(typeof(glVertexAttribDivisor))load("glVertexAttribDivisor");
	glVertexAttribP1ui = cast(typeof(glVertexAttribP1ui))load("glVertexAttribP1ui");
	glVertexAttribP1uiv = cast(typeof(glVertexAttribP1uiv))load("glVertexAttribP1uiv");
	glVertexAttribP2ui = cast(typeof(glVertexAttribP2ui))load("glVertexAttribP2ui");
	glVertexAttribP2uiv = cast(typeof(glVertexAttribP2uiv))load("glVertexAttribP2uiv");
	glVertexAttribP3ui = cast(typeof(glVertexAttribP3ui))load("glVertexAttribP3ui");
	glVertexAttribP3uiv = cast(typeof(glVertexAttribP3uiv))load("glVertexAttribP3uiv");
	glVertexAttribP4ui = cast(typeof(glVertexAttribP4ui))load("glVertexAttribP4ui");
	glVertexAttribP4uiv = cast(typeof(glVertexAttribP4uiv))load("glVertexAttribP4uiv");
	glVertexP2ui = cast(typeof(glVertexP2ui))load("glVertexP2ui");
	glVertexP2uiv = cast(typeof(glVertexP2uiv))load("glVertexP2uiv");
	glVertexP3ui = cast(typeof(glVertexP3ui))load("glVertexP3ui");
	glVertexP3uiv = cast(typeof(glVertexP3uiv))load("glVertexP3uiv");
	glVertexP4ui = cast(typeof(glVertexP4ui))load("glVertexP4ui");
	glVertexP4uiv = cast(typeof(glVertexP4uiv))load("glVertexP4uiv");
	glTexCoordP1ui = cast(typeof(glTexCoordP1ui))load("glTexCoordP1ui");
	glTexCoordP1uiv = cast(typeof(glTexCoordP1uiv))load("glTexCoordP1uiv");
	glTexCoordP2ui = cast(typeof(glTexCoordP2ui))load("glTexCoordP2ui");
	glTexCoordP2uiv = cast(typeof(glTexCoordP2uiv))load("glTexCoordP2uiv");
	glTexCoordP3ui = cast(typeof(glTexCoordP3ui))load("glTexCoordP3ui");
	glTexCoordP3uiv = cast(typeof(glTexCoordP3uiv))load("glTexCoordP3uiv");
	glTexCoordP4ui = cast(typeof(glTexCoordP4ui))load("glTexCoordP4ui");
	glTexCoordP4uiv = cast(typeof(glTexCoordP4uiv))load("glTexCoordP4uiv");
	glMultiTexCoordP1ui = cast(typeof(glMultiTexCoordP1ui))load("glMultiTexCoordP1ui");
	glMultiTexCoordP1uiv = cast(typeof(glMultiTexCoordP1uiv))load("glMultiTexCoordP1uiv");
	glMultiTexCoordP2ui = cast(typeof(glMultiTexCoordP2ui))load("glMultiTexCoordP2ui");
	glMultiTexCoordP2uiv = cast(typeof(glMultiTexCoordP2uiv))load("glMultiTexCoordP2uiv");
	glMultiTexCoordP3ui = cast(typeof(glMultiTexCoordP3ui))load("glMultiTexCoordP3ui");
	glMultiTexCoordP3uiv = cast(typeof(glMultiTexCoordP3uiv))load("glMultiTexCoordP3uiv");
	glMultiTexCoordP4ui = cast(typeof(glMultiTexCoordP4ui))load("glMultiTexCoordP4ui");
	glMultiTexCoordP4uiv = cast(typeof(glMultiTexCoordP4uiv))load("glMultiTexCoordP4uiv");
	glNormalP3ui = cast(typeof(glNormalP3ui))load("glNormalP3ui");
	glNormalP3uiv = cast(typeof(glNormalP3uiv))load("glNormalP3uiv");
	glColorP3ui = cast(typeof(glColorP3ui))load("glColorP3ui");
	glColorP3uiv = cast(typeof(glColorP3uiv))load("glColorP3uiv");
	glColorP4ui = cast(typeof(glColorP4ui))load("glColorP4ui");
	glColorP4uiv = cast(typeof(glColorP4uiv))load("glColorP4uiv");
	glSecondaryColorP3ui = cast(typeof(glSecondaryColorP3ui))load("glSecondaryColorP3ui");
	glSecondaryColorP3uiv = cast(typeof(glSecondaryColorP3uiv))load("glSecondaryColorP3uiv");
	return;
}

void load_gl_GL_VERSION_3_2(void* function(string name) load) {
	if(!GL_VERSION_3_2) return;
	glDrawElementsBaseVertex = cast(typeof(glDrawElementsBaseVertex))load("glDrawElementsBaseVertex");
	glDrawRangeElementsBaseVertex = cast(typeof(glDrawRangeElementsBaseVertex))load("glDrawRangeElementsBaseVertex");
	glDrawElementsInstancedBaseVertex = cast(typeof(glDrawElementsInstancedBaseVertex))load("glDrawElementsInstancedBaseVertex");
	glMultiDrawElementsBaseVertex = cast(typeof(glMultiDrawElementsBaseVertex))load("glMultiDrawElementsBaseVertex");
	glProvokingVertex = cast(typeof(glProvokingVertex))load("glProvokingVertex");
	glFenceSync = cast(typeof(glFenceSync))load("glFenceSync");
	glIsSync = cast(typeof(glIsSync))load("glIsSync");
	glDeleteSync = cast(typeof(glDeleteSync))load("glDeleteSync");
	glClientWaitSync = cast(typeof(glClientWaitSync))load("glClientWaitSync");
	glWaitSync = cast(typeof(glWaitSync))load("glWaitSync");
	glGetInteger64v = cast(typeof(glGetInteger64v))load("glGetInteger64v");
	glGetSynciv = cast(typeof(glGetSynciv))load("glGetSynciv");
	glGetInteger64i_v = cast(typeof(glGetInteger64i_v))load("glGetInteger64i_v");
	glGetBufferParameteri64v = cast(typeof(glGetBufferParameteri64v))load("glGetBufferParameteri64v");
	glFramebufferTexture = cast(typeof(glFramebufferTexture))load("glFramebufferTexture");
	glTexImage2DMultisample = cast(typeof(glTexImage2DMultisample))load("glTexImage2DMultisample");
	glTexImage3DMultisample = cast(typeof(glTexImage3DMultisample))load("glTexImage3DMultisample");
	glGetMultisamplefv = cast(typeof(glGetMultisamplefv))load("glGetMultisamplefv");
	glSampleMaski = cast(typeof(glSampleMaski))load("glSampleMaski");
	return;
}

bool load_gl_GL_OES_fixed_point(void* function(string name) load) {
	if(!GL_OES_fixed_point) return GL_OES_fixed_point;

	glAlphaFuncxOES = cast(typeof(glAlphaFuncxOES))load("glAlphaFuncxOES");
	glClearColorxOES = cast(typeof(glClearColorxOES))load("glClearColorxOES");
	glClearDepthxOES = cast(typeof(glClearDepthxOES))load("glClearDepthxOES");
	glClipPlanexOES = cast(typeof(glClipPlanexOES))load("glClipPlanexOES");
	glColor4xOES = cast(typeof(glColor4xOES))load("glColor4xOES");
	glDepthRangexOES = cast(typeof(glDepthRangexOES))load("glDepthRangexOES");
	glFogxOES = cast(typeof(glFogxOES))load("glFogxOES");
	glFogxvOES = cast(typeof(glFogxvOES))load("glFogxvOES");
	glFrustumxOES = cast(typeof(glFrustumxOES))load("glFrustumxOES");
	glGetClipPlanexOES = cast(typeof(glGetClipPlanexOES))load("glGetClipPlanexOES");
	glGetFixedvOES = cast(typeof(glGetFixedvOES))load("glGetFixedvOES");
	glGetTexEnvxvOES = cast(typeof(glGetTexEnvxvOES))load("glGetTexEnvxvOES");
	glGetTexParameterxvOES = cast(typeof(glGetTexParameterxvOES))load("glGetTexParameterxvOES");
	glLightModelxOES = cast(typeof(glLightModelxOES))load("glLightModelxOES");
	glLightModelxvOES = cast(typeof(glLightModelxvOES))load("glLightModelxvOES");
	glLightxOES = cast(typeof(glLightxOES))load("glLightxOES");
	glLightxvOES = cast(typeof(glLightxvOES))load("glLightxvOES");
	glLineWidthxOES = cast(typeof(glLineWidthxOES))load("glLineWidthxOES");
	glLoadMatrixxOES = cast(typeof(glLoadMatrixxOES))load("glLoadMatrixxOES");
	glMaterialxOES = cast(typeof(glMaterialxOES))load("glMaterialxOES");
	glMaterialxvOES = cast(typeof(glMaterialxvOES))load("glMaterialxvOES");
	glMultMatrixxOES = cast(typeof(glMultMatrixxOES))load("glMultMatrixxOES");
	glMultiTexCoord4xOES = cast(typeof(glMultiTexCoord4xOES))load("glMultiTexCoord4xOES");
	glNormal3xOES = cast(typeof(glNormal3xOES))load("glNormal3xOES");
	glOrthoxOES = cast(typeof(glOrthoxOES))load("glOrthoxOES");
	glPointParameterxvOES = cast(typeof(glPointParameterxvOES))load("glPointParameterxvOES");
	glPointSizexOES = cast(typeof(glPointSizexOES))load("glPointSizexOES");
	glPolygonOffsetxOES = cast(typeof(glPolygonOffsetxOES))load("glPolygonOffsetxOES");
	glRotatexOES = cast(typeof(glRotatexOES))load("glRotatexOES");
	glSampleCoverageOES = cast(typeof(glSampleCoverageOES))load("glSampleCoverageOES");
	glScalexOES = cast(typeof(glScalexOES))load("glScalexOES");
	glTexEnvxOES = cast(typeof(glTexEnvxOES))load("glTexEnvxOES");
	glTexEnvxvOES = cast(typeof(glTexEnvxvOES))load("glTexEnvxvOES");
	glTexParameterxOES = cast(typeof(glTexParameterxOES))load("glTexParameterxOES");
	glTexParameterxvOES = cast(typeof(glTexParameterxvOES))load("glTexParameterxvOES");
	glTranslatexOES = cast(typeof(glTranslatexOES))load("glTranslatexOES");
	glGetLightxvOES = cast(typeof(glGetLightxvOES))load("glGetLightxvOES");
	glGetMaterialxvOES = cast(typeof(glGetMaterialxvOES))load("glGetMaterialxvOES");
	glPointParameterxOES = cast(typeof(glPointParameterxOES))load("glPointParameterxOES");
	glSampleCoveragexOES = cast(typeof(glSampleCoveragexOES))load("glSampleCoveragexOES");
	glAccumxOES = cast(typeof(glAccumxOES))load("glAccumxOES");
	glBitmapxOES = cast(typeof(glBitmapxOES))load("glBitmapxOES");
	glBlendColorxOES = cast(typeof(glBlendColorxOES))load("glBlendColorxOES");
	glClearAccumxOES = cast(typeof(glClearAccumxOES))load("glClearAccumxOES");
	glColor3xOES = cast(typeof(glColor3xOES))load("glColor3xOES");
	glColor3xvOES = cast(typeof(glColor3xvOES))load("glColor3xvOES");
	glColor4xvOES = cast(typeof(glColor4xvOES))load("glColor4xvOES");
	glConvolutionParameterxOES = cast(typeof(glConvolutionParameterxOES))load("glConvolutionParameterxOES");
	glConvolutionParameterxvOES = cast(typeof(glConvolutionParameterxvOES))load("glConvolutionParameterxvOES");
	glEvalCoord1xOES = cast(typeof(glEvalCoord1xOES))load("glEvalCoord1xOES");
	glEvalCoord1xvOES = cast(typeof(glEvalCoord1xvOES))load("glEvalCoord1xvOES");
	glEvalCoord2xOES = cast(typeof(glEvalCoord2xOES))load("glEvalCoord2xOES");
	glEvalCoord2xvOES = cast(typeof(glEvalCoord2xvOES))load("glEvalCoord2xvOES");
	glFeedbackBufferxOES = cast(typeof(glFeedbackBufferxOES))load("glFeedbackBufferxOES");
	glGetConvolutionParameterxvOES = cast(typeof(glGetConvolutionParameterxvOES))load("glGetConvolutionParameterxvOES");
	glGetHistogramParameterxvOES = cast(typeof(glGetHistogramParameterxvOES))load("glGetHistogramParameterxvOES");
	glGetLightxOES = cast(typeof(glGetLightxOES))load("glGetLightxOES");
	glGetMapxvOES = cast(typeof(glGetMapxvOES))load("glGetMapxvOES");
	glGetMaterialxOES = cast(typeof(glGetMaterialxOES))load("glGetMaterialxOES");
	glGetPixelMapxv = cast(typeof(glGetPixelMapxv))load("glGetPixelMapxv");
	glGetTexGenxvOES = cast(typeof(glGetTexGenxvOES))load("glGetTexGenxvOES");
	glGetTexLevelParameterxvOES = cast(typeof(glGetTexLevelParameterxvOES))load("glGetTexLevelParameterxvOES");
	glIndexxOES = cast(typeof(glIndexxOES))load("glIndexxOES");
	glIndexxvOES = cast(typeof(glIndexxvOES))load("glIndexxvOES");
	glLoadTransposeMatrixxOES = cast(typeof(glLoadTransposeMatrixxOES))load("glLoadTransposeMatrixxOES");
	glMap1xOES = cast(typeof(glMap1xOES))load("glMap1xOES");
	glMap2xOES = cast(typeof(glMap2xOES))load("glMap2xOES");
	glMapGrid1xOES = cast(typeof(glMapGrid1xOES))load("glMapGrid1xOES");
	glMapGrid2xOES = cast(typeof(glMapGrid2xOES))load("glMapGrid2xOES");
	glMultTransposeMatrixxOES = cast(typeof(glMultTransposeMatrixxOES))load("glMultTransposeMatrixxOES");
	glMultiTexCoord1xOES = cast(typeof(glMultiTexCoord1xOES))load("glMultiTexCoord1xOES");
	glMultiTexCoord1xvOES = cast(typeof(glMultiTexCoord1xvOES))load("glMultiTexCoord1xvOES");
	glMultiTexCoord2xOES = cast(typeof(glMultiTexCoord2xOES))load("glMultiTexCoord2xOES");
	glMultiTexCoord2xvOES = cast(typeof(glMultiTexCoord2xvOES))load("glMultiTexCoord2xvOES");
	glMultiTexCoord3xOES = cast(typeof(glMultiTexCoord3xOES))load("glMultiTexCoord3xOES");
	glMultiTexCoord3xvOES = cast(typeof(glMultiTexCoord3xvOES))load("glMultiTexCoord3xvOES");
	glMultiTexCoord4xvOES = cast(typeof(glMultiTexCoord4xvOES))load("glMultiTexCoord4xvOES");
	glNormal3xvOES = cast(typeof(glNormal3xvOES))load("glNormal3xvOES");
	glPassThroughxOES = cast(typeof(glPassThroughxOES))load("glPassThroughxOES");
	glPixelMapx = cast(typeof(glPixelMapx))load("glPixelMapx");
	glPixelStorex = cast(typeof(glPixelStorex))load("glPixelStorex");
	glPixelTransferxOES = cast(typeof(glPixelTransferxOES))load("glPixelTransferxOES");
	glPixelZoomxOES = cast(typeof(glPixelZoomxOES))load("glPixelZoomxOES");
	glPrioritizeTexturesxOES = cast(typeof(glPrioritizeTexturesxOES))load("glPrioritizeTexturesxOES");
	glRasterPos2xOES = cast(typeof(glRasterPos2xOES))load("glRasterPos2xOES");
	glRasterPos2xvOES = cast(typeof(glRasterPos2xvOES))load("glRasterPos2xvOES");
	glRasterPos3xOES = cast(typeof(glRasterPos3xOES))load("glRasterPos3xOES");
	glRasterPos3xvOES = cast(typeof(glRasterPos3xvOES))load("glRasterPos3xvOES");
	glRasterPos4xOES = cast(typeof(glRasterPos4xOES))load("glRasterPos4xOES");
	glRasterPos4xvOES = cast(typeof(glRasterPos4xvOES))load("glRasterPos4xvOES");
	glRectxOES = cast(typeof(glRectxOES))load("glRectxOES");
	glRectxvOES = cast(typeof(glRectxvOES))load("glRectxvOES");
	glTexCoord1xOES = cast(typeof(glTexCoord1xOES))load("glTexCoord1xOES");
	glTexCoord1xvOES = cast(typeof(glTexCoord1xvOES))load("glTexCoord1xvOES");
	glTexCoord2xOES = cast(typeof(glTexCoord2xOES))load("glTexCoord2xOES");
	glTexCoord2xvOES = cast(typeof(glTexCoord2xvOES))load("glTexCoord2xvOES");
	glTexCoord3xOES = cast(typeof(glTexCoord3xOES))load("glTexCoord3xOES");
	glTexCoord3xvOES = cast(typeof(glTexCoord3xvOES))load("glTexCoord3xvOES");
	glTexCoord4xOES = cast(typeof(glTexCoord4xOES))load("glTexCoord4xOES");
	glTexCoord4xvOES = cast(typeof(glTexCoord4xvOES))load("glTexCoord4xvOES");
	glTexGenxOES = cast(typeof(glTexGenxOES))load("glTexGenxOES");
	glTexGenxvOES = cast(typeof(glTexGenxvOES))load("glTexGenxvOES");
	glVertex2xOES = cast(typeof(glVertex2xOES))load("glVertex2xOES");
	glVertex2xvOES = cast(typeof(glVertex2xvOES))load("glVertex2xvOES");
	glVertex3xOES = cast(typeof(glVertex3xOES))load("glVertex3xOES");
	glVertex3xvOES = cast(typeof(glVertex3xvOES))load("glVertex3xvOES");
	glVertex4xOES = cast(typeof(glVertex4xOES))load("glVertex4xOES");
	glVertex4xvOES = cast(typeof(glVertex4xvOES))load("glVertex4xvOES");
	return GL_OES_fixed_point;
}


bool load_gl_GL_EXT_framebuffer_multisample(void* function(string name) load) {
	if(!GL_EXT_framebuffer_multisample) return GL_EXT_framebuffer_multisample;

	glRenderbufferStorageMultisampleEXT = cast(typeof(glRenderbufferStorageMultisampleEXT))load("glRenderbufferStorageMultisampleEXT");
	return GL_EXT_framebuffer_multisample;
}


bool load_gl_GL_ARB_gpu_shader5(void* function(string name) load) {
	if(!GL_ARB_gpu_shader5) return GL_ARB_gpu_shader5;

	return GL_ARB_gpu_shader5;
}


bool load_gl_GL_SGIS_texture4D(void* function(string name) load) {
	if(!GL_SGIS_texture4D) return GL_SGIS_texture4D;

	glTexImage4DSGIS = cast(typeof(glTexImage4DSGIS))load("glTexImage4DSGIS");
	glTexSubImage4DSGIS = cast(typeof(glTexSubImage4DSGIS))load("glTexSubImage4DSGIS");
	return GL_SGIS_texture4D;
}


bool load_gl_GL_EXT_texture3D(void* function(string name) load) {
	if(!GL_EXT_texture3D) return GL_EXT_texture3D;

	glTexImage3DEXT = cast(typeof(glTexImage3DEXT))load("glTexImage3DEXT");
	glTexSubImage3DEXT = cast(typeof(glTexSubImage3DEXT))load("glTexSubImage3DEXT");
	return GL_EXT_texture3D;
}


bool load_gl_GL_ARB_multitexture(void* function(string name) load) {
	if(!GL_ARB_multitexture) return GL_ARB_multitexture;

	glActiveTextureARB = cast(typeof(glActiveTextureARB))load("glActiveTextureARB");
	glClientActiveTextureARB = cast(typeof(glClientActiveTextureARB))load("glClientActiveTextureARB");
	glMultiTexCoord1dARB = cast(typeof(glMultiTexCoord1dARB))load("glMultiTexCoord1dARB");
	glMultiTexCoord1dvARB = cast(typeof(glMultiTexCoord1dvARB))load("glMultiTexCoord1dvARB");
	glMultiTexCoord1fARB = cast(typeof(glMultiTexCoord1fARB))load("glMultiTexCoord1fARB");
	glMultiTexCoord1fvARB = cast(typeof(glMultiTexCoord1fvARB))load("glMultiTexCoord1fvARB");
	glMultiTexCoord1iARB = cast(typeof(glMultiTexCoord1iARB))load("glMultiTexCoord1iARB");
	glMultiTexCoord1ivARB = cast(typeof(glMultiTexCoord1ivARB))load("glMultiTexCoord1ivARB");
	glMultiTexCoord1sARB = cast(typeof(glMultiTexCoord1sARB))load("glMultiTexCoord1sARB");
	glMultiTexCoord1svARB = cast(typeof(glMultiTexCoord1svARB))load("glMultiTexCoord1svARB");
	glMultiTexCoord2dARB = cast(typeof(glMultiTexCoord2dARB))load("glMultiTexCoord2dARB");
	glMultiTexCoord2dvARB = cast(typeof(glMultiTexCoord2dvARB))load("glMultiTexCoord2dvARB");
	glMultiTexCoord2fARB = cast(typeof(glMultiTexCoord2fARB))load("glMultiTexCoord2fARB");
	glMultiTexCoord2fvARB = cast(typeof(glMultiTexCoord2fvARB))load("glMultiTexCoord2fvARB");
	glMultiTexCoord2iARB = cast(typeof(glMultiTexCoord2iARB))load("glMultiTexCoord2iARB");
	glMultiTexCoord2ivARB = cast(typeof(glMultiTexCoord2ivARB))load("glMultiTexCoord2ivARB");
	glMultiTexCoord2sARB = cast(typeof(glMultiTexCoord2sARB))load("glMultiTexCoord2sARB");
	glMultiTexCoord2svARB = cast(typeof(glMultiTexCoord2svARB))load("glMultiTexCoord2svARB");
	glMultiTexCoord3dARB = cast(typeof(glMultiTexCoord3dARB))load("glMultiTexCoord3dARB");
	glMultiTexCoord3dvARB = cast(typeof(glMultiTexCoord3dvARB))load("glMultiTexCoord3dvARB");
	glMultiTexCoord3fARB = cast(typeof(glMultiTexCoord3fARB))load("glMultiTexCoord3fARB");
	glMultiTexCoord3fvARB = cast(typeof(glMultiTexCoord3fvARB))load("glMultiTexCoord3fvARB");
	glMultiTexCoord3iARB = cast(typeof(glMultiTexCoord3iARB))load("glMultiTexCoord3iARB");
	glMultiTexCoord3ivARB = cast(typeof(glMultiTexCoord3ivARB))load("glMultiTexCoord3ivARB");
	glMultiTexCoord3sARB = cast(typeof(glMultiTexCoord3sARB))load("glMultiTexCoord3sARB");
	glMultiTexCoord3svARB = cast(typeof(glMultiTexCoord3svARB))load("glMultiTexCoord3svARB");
	glMultiTexCoord4dARB = cast(typeof(glMultiTexCoord4dARB))load("glMultiTexCoord4dARB");
	glMultiTexCoord4dvARB = cast(typeof(glMultiTexCoord4dvARB))load("glMultiTexCoord4dvARB");
	glMultiTexCoord4fARB = cast(typeof(glMultiTexCoord4fARB))load("glMultiTexCoord4fARB");
	glMultiTexCoord4fvARB = cast(typeof(glMultiTexCoord4fvARB))load("glMultiTexCoord4fvARB");
	glMultiTexCoord4iARB = cast(typeof(glMultiTexCoord4iARB))load("glMultiTexCoord4iARB");
	glMultiTexCoord4ivARB = cast(typeof(glMultiTexCoord4ivARB))load("glMultiTexCoord4ivARB");
	glMultiTexCoord4sARB = cast(typeof(glMultiTexCoord4sARB))load("glMultiTexCoord4sARB");
	glMultiTexCoord4svARB = cast(typeof(glMultiTexCoord4svARB))load("glMultiTexCoord4svARB");
	return GL_ARB_multitexture;
}


bool load_gl_GL_EXT_secondary_color(void* function(string name) load) {
	if(!GL_EXT_secondary_color) return GL_EXT_secondary_color;

	glSecondaryColor3bEXT = cast(typeof(glSecondaryColor3bEXT))load("glSecondaryColor3bEXT");
	glSecondaryColor3bvEXT = cast(typeof(glSecondaryColor3bvEXT))load("glSecondaryColor3bvEXT");
	glSecondaryColor3dEXT = cast(typeof(glSecondaryColor3dEXT))load("glSecondaryColor3dEXT");
	glSecondaryColor3dvEXT = cast(typeof(glSecondaryColor3dvEXT))load("glSecondaryColor3dvEXT");
	glSecondaryColor3fEXT = cast(typeof(glSecondaryColor3fEXT))load("glSecondaryColor3fEXT");
	glSecondaryColor3fvEXT = cast(typeof(glSecondaryColor3fvEXT))load("glSecondaryColor3fvEXT");
	glSecondaryColor3iEXT = cast(typeof(glSecondaryColor3iEXT))load("glSecondaryColor3iEXT");
	glSecondaryColor3ivEXT = cast(typeof(glSecondaryColor3ivEXT))load("glSecondaryColor3ivEXT");
	glSecondaryColor3sEXT = cast(typeof(glSecondaryColor3sEXT))load("glSecondaryColor3sEXT");
	glSecondaryColor3svEXT = cast(typeof(glSecondaryColor3svEXT))load("glSecondaryColor3svEXT");
	glSecondaryColor3ubEXT = cast(typeof(glSecondaryColor3ubEXT))load("glSecondaryColor3ubEXT");
	glSecondaryColor3ubvEXT = cast(typeof(glSecondaryColor3ubvEXT))load("glSecondaryColor3ubvEXT");
	glSecondaryColor3uiEXT = cast(typeof(glSecondaryColor3uiEXT))load("glSecondaryColor3uiEXT");
	glSecondaryColor3uivEXT = cast(typeof(glSecondaryColor3uivEXT))load("glSecondaryColor3uivEXT");
	glSecondaryColor3usEXT = cast(typeof(glSecondaryColor3usEXT))load("glSecondaryColor3usEXT");
	glSecondaryColor3usvEXT = cast(typeof(glSecondaryColor3usvEXT))load("glSecondaryColor3usvEXT");
	glSecondaryColorPointerEXT = cast(typeof(glSecondaryColorPointerEXT))load("glSecondaryColorPointerEXT");
	return GL_EXT_secondary_color;
}


bool load_gl_GL_NV_parameter_buffer_object2(void* function(string name) load) {
	if(!GL_NV_parameter_buffer_object2) return GL_NV_parameter_buffer_object2;

	return GL_NV_parameter_buffer_object2;
}


bool load_gl_GL_ATI_vertex_array_object(void* function(string name) load) {
	if(!GL_ATI_vertex_array_object) return GL_ATI_vertex_array_object;

	glNewObjectBufferATI = cast(typeof(glNewObjectBufferATI))load("glNewObjectBufferATI");
	glIsObjectBufferATI = cast(typeof(glIsObjectBufferATI))load("glIsObjectBufferATI");
	glUpdateObjectBufferATI = cast(typeof(glUpdateObjectBufferATI))load("glUpdateObjectBufferATI");
	glGetObjectBufferfvATI = cast(typeof(glGetObjectBufferfvATI))load("glGetObjectBufferfvATI");
	glGetObjectBufferivATI = cast(typeof(glGetObjectBufferivATI))load("glGetObjectBufferivATI");
	glFreeObjectBufferATI = cast(typeof(glFreeObjectBufferATI))load("glFreeObjectBufferATI");
	glArrayObjectATI = cast(typeof(glArrayObjectATI))load("glArrayObjectATI");
	glGetArrayObjectfvATI = cast(typeof(glGetArrayObjectfvATI))load("glGetArrayObjectfvATI");
	glGetArrayObjectivATI = cast(typeof(glGetArrayObjectivATI))load("glGetArrayObjectivATI");
	glVariantArrayObjectATI = cast(typeof(glVariantArrayObjectATI))load("glVariantArrayObjectATI");
	glGetVariantArrayObjectfvATI = cast(typeof(glGetVariantArrayObjectfvATI))load("glGetVariantArrayObjectfvATI");
	glGetVariantArrayObjectivATI = cast(typeof(glGetVariantArrayObjectivATI))load("glGetVariantArrayObjectivATI");
	return GL_ATI_vertex_array_object;
}


bool load_gl_GL_SGIX_igloo_interface(void* function(string name) load) {
	if(!GL_SGIX_igloo_interface) return GL_SGIX_igloo_interface;

	glIglooInterfaceSGIX = cast(typeof(glIglooInterfaceSGIX))load("glIglooInterfaceSGIX");
	return GL_SGIX_igloo_interface;
}


bool load_gl_GL_SGIS_point_line_texgen(void* function(string name) load) {
	if(!GL_SGIS_point_line_texgen) return GL_SGIS_point_line_texgen;

	return GL_SGIS_point_line_texgen;
}


bool load_gl_GL_EXT_draw_range_elements(void* function(string name) load) {
	if(!GL_EXT_draw_range_elements) return GL_EXT_draw_range_elements;

	glDrawRangeElementsEXT = cast(typeof(glDrawRangeElementsEXT))load("glDrawRangeElementsEXT");
	return GL_EXT_draw_range_elements;
}


bool load_gl_GL_SGIX_blend_alpha_minmax(void* function(string name) load) {
	if(!GL_SGIX_blend_alpha_minmax) return GL_SGIX_blend_alpha_minmax;

	return GL_SGIX_blend_alpha_minmax;
}


