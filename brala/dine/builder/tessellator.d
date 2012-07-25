module brala.dine.builder.tessellator;

private {
    import glamour.gl : GL_FLOAT;
    import glamour.vbo : Buffer;
    
    import gl3n.linalg : vec3i;
    
    import brala.dine.chunk : Block;
    import brala.dine.world : World;
    import brala.dine.builder.builder; // import everything
    import brala.dine.builder.blocks : BLOCKS;
    import brala.dine.builder.biomes : BiomeData;
    
    import brala.utils.alloc : realloc;
}


enum Side : ubyte {
    LEFT,
    RIGHT,
    NEAR,
    FAR,
    TOP,
    BOTTOM,
    ALL
}


struct Vertex {
    float x;
    float y;
    float z;
    float nx;
    float ny;
    float nz;
    float u_terrain;
    float v_terrain;
    float u_biome;
    float v_biome;
}


struct Tessellator {
    World world;
    
    Vertex* buffer;
    size_t buffer_length;

    uint elements = 0;

    mixin BlockBuilder!();
    
    this(World world, ref Vertex* buffer, ref size_t buffer_length) {
        this.world = world;
        this.buffer = buffer;
        this.buffer_length = buffer_length;
    }

    void realloc_buffer(size_t interval) {
        buffer_length += interval*Vertex.sizeof;
        buffer = cast(Vertex*)realloc(buffer, buffer_length);
    }

    void realloc_buffer_if_needed(size_t interval) {
        if(elements+interval >= buffer_length) {
            realloc_buffer(interval);
        }
    }
    
    void feed(vec3i world_coords, int x, int y, int z,
              float x_offset, float x_offset_r, float y_offset, float y_offset_t, float z_offset, float z_offset_n,
              const ref Block value, const ref Block right, const ref Block top, const ref Block front,
              const ref BiomeData biome_data) {

       
        if(BLOCKS[value.id].empty) { // render neighbours
            if(!BLOCKS[right.id].empty) dispatch!(Side.LEFT)(right, biome_data, x_offset_r, y_offset, z_offset);
            if(!BLOCKS[top.id].empty)   dispatch!(Side.BOTTOM)(top, biome_data, x_offset, y_offset_t, z_offset);
            if(!BLOCKS[front.id].empty) dispatch!(Side.FAR)(front, biome_data, x_offset, y_offset, z_offset_n);

            if(value.id != 0) {
                dispatch!(Side.ALL)(value, biome_data, x_offset, y_offset, z_offset);
            }
        } else {
            if(BLOCKS[right.id].empty) dispatch!(Side.RIGHT)(value, biome_data, x_offset, y_offset, z_offset);
            if(BLOCKS[top.id].empty)   dispatch!(Side.TOP)(value, biome_data, x_offset, y_offset, z_offset);
            if(BLOCKS[front.id].empty) dispatch!(Side.NEAR)(value, biome_data, x_offset, y_offset, z_offset);

            if(x == 0) {
                Block left = world.get_block_safe(vec3i(world_coords.x-1, world_coords.y, world_coords.z));

                if(BLOCKS[left.id].empty) dispatch!(Side.LEFT)(value, biome_data, x_offset, y_offset, z_offset);
            }

            if(y == 0) {
                // always render this, it's the lowest bedrock level
                dispatch!(Side.BOTTOM)(value, biome_data, x_offset, y_offset, z_offset);
            }

            if(z == 0) {
                Block back = world.get_block_safe(vec3i(world_coords.x, world_coords.y, world_coords.z-1));

                if(BLOCKS[back.id].empty) dispatch!(Side.FAR)(value, biome_data, x_offset, y_offset, z_offset);
            }
        }
    }

    void fill_vbo(Buffer vbo) {
        //float* v = cast(float*)buffer;
        //vbo.set_data(v[0..elements*10]);
        vbo.set_data(buffer[0..elements]);
    }
}