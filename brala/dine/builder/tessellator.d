module brala.dine.builder.tessellator;

private {
    import glamour.gl : GL_FLOAT;
    import glamour.vbo : Buffer;
    
    import gl3n.linalg : vec3i;
    
    import brala.dine.chunk : Block, Chunk;
    import brala.dine.world : World, TessellationBuffer;
    import brala.dine.builder.builder; // import everything
    import brala.dine.builder.light : is_light;
    import brala.dine.builder.blocks : BLOCKS;
    import brala.dine.builder.biomes : BiomeData;
    import brala.gfx.terrain : MinecraftAtlas;
    import brala.gfx.data : LightVertex;
    import brala.utils.memory : realloc;
    import brala.utils.gloom : Gloom;
}


struct Tessellator {
    World world;
    MinecraftAtlas atlas;
    TessellationBuffer* buffer;
    float[] light_vertices_template;

    uint terrain_elements = 0;
    uint light_elements = 0;

    mixin BlockBuilder!();
    
    this(World world, MinecraftAtlas atlas, Gloom gloom, TessellationBuffer* tb) {
        this.world = world;
        this.atlas = atlas;
        light_vertices_template = gloom.vertices;
        buffer = tb;

        assert(LightVertex.sizeof == gloom.stride*float.sizeof);
    }

    void trigger_realloc() {
        // this uses worstcase for one layer *2
        buffer.terrain.realloc_interval_if_needed(terrain_elements,
                    16*16*Vertex.sizeof*6*10);
        buffer.light.realloc_interval_if_needed(light_elements,
                    16*16*LightVertex.sizeof*light_vertices_template.length);
    }

    void feed(Chunk chunk, vec3i world_coords, int x, int y, int z,
              float x_offset, float x_offset_r, float y_offset, float y_offset_t, float z_offset, float z_offset_n,
              const Block value, const Block right, const Block top, const Block front,
              const ref BiomeData biome_data) {
       
        if(BLOCKS[value.id].empty) { // render neighbours
            if(!BLOCKS[right.id].empty) dispatch!(Side.LEFT)(right, biome_data, world_coords, x_offset_r, y_offset, z_offset);
            if(!BLOCKS[top.id].empty)   dispatch!(Side.BOTTOM)(top, biome_data, world_coords, x_offset, y_offset_t, z_offset);
            if(!BLOCKS[front.id].empty) dispatch!(Side.FAR)(front, biome_data, world_coords, x_offset, y_offset, z_offset_n);

            if(value.id != 0) {
                dispatch!(Side.ALL)(value, biome_data, world_coords, x_offset, y_offset, z_offset);
            }
        } else {
            if(BLOCKS[right.id].empty) dispatch!(Side.RIGHT)(value, biome_data, world_coords, x_offset, y_offset, z_offset);
            if(BLOCKS[top.id].empty)   dispatch!(Side.TOP)(value, biome_data, world_coords, x_offset, y_offset, z_offset);
            if(BLOCKS[front.id].empty) dispatch!(Side.NEAR)(value, biome_data, world_coords, x_offset, y_offset, z_offset);

            if(x == 0) {
                Block left = world.get_block_safe(world_coords.x-1, world_coords.y, world_coords.z);

                if(BLOCKS[left.id].empty) dispatch!(Side.LEFT)(value, biome_data, world_coords, x_offset, y_offset, z_offset);
            }

            if(y == 0) {
                // always render this, it's the lowest bedrock level
                dispatch!(Side.BOTTOM)(value, biome_data, world_coords, x_offset, y_offset, z_offset);
            }

            if(z == 0) {
                Block back = world.get_block_safe(world_coords.x, world_coords.y, world_coords.z-1);

                if(BLOCKS[back.id].empty) dispatch!(Side.FAR)(value, biome_data, world_coords, x_offset, y_offset, z_offset);
            }
        }

        if(value.id.is_light) {
            add_light_vertices(x_offset, y_offset, z_offset);
        }
    }

    void add_light_vertices(float x_offset, float y_offset, float z_offset)
        in { assert(light_elements+light_vertices_template.length*LightVertex.sizeof <= buffer.light.length,
                    "not enough memory for lights!"); }
        body {
            size_t end = light_elements + light_vertices_template.length*float.sizeof;
            buffer.light.ptr[light_elements..end] = cast(void[])light_vertices_template;

            for(; light_elements < end; light_elements += LightVertex.sizeof) {
                LightVertex* vertex = cast(LightVertex*)&((buffer.light.ptr)[light_elements]);
                vertex.x += x_offset;
                vertex.y += y_offset;
                vertex.z += z_offset;
            }
        }

    void fill_vbo(Buffer vbo) {
        vbo.set_data(buffer.terrain.ptr, terrain_elements);
    }
}