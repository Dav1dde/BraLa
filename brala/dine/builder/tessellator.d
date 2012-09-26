module brala.dine.builder.tessellator;

private {
    import glamour.gl : GL_FLOAT;
    import glamour.vbo : Buffer;
    
    import gl3n.linalg : vec3i;
    
    import brala.dine.chunk : Block;
    import brala.dine.world : World, TessellationBuffer;
    import brala.dine.builder.builder; // import everything
    import brala.dine.builder.blocks : BLOCKS;
    import brala.dine.builder.biomes : BiomeData;
    
    import brala.utils.memory : realloc;
}


align(1) struct Vertex {
    align(1):
    float x;
    float y;
    float z;
//     float nx;
//     float ny;
//     float nz;
    ubyte r;
    ubyte g;
    ubyte b;
    ubyte a;
    short u_terrain;
    short v_terrain;
    short u_mask;
    short v_mask;
    ubyte sky_light;
    ubyte block_light;
    short pad;
}

static assert(Vertex.sizeof % 4 == 0, "Vertex size must be multiple of 4");


struct Tessellator {
    World world;
    
    TessellationBuffer* buffer;

    uint elements = 0;

    mixin BlockBuilder!();
    
    this(World world, TessellationBuffer* tb) {
        this.world = world;
        buffer = tb;
    }

    void realloc_buffer(size_t interval) {
        buffer.realloc(buffer.length + interval);
    }

    void realloc_buffer_if_needed(size_t interval) {
        if(elements+interval >= buffer.length) {
            realloc_buffer(interval);
        }
    }
    
    void feed(vec3i world_coords, int x, int y, int z,
              float x_offset, float x_offset_r, float y_offset, float y_offset_t, float z_offset, float z_offset_n,
              const ref Block value, const ref Block right, const ref Block top, const ref Block front,
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
                Block left = world.get_block_safe(vec3i(world_coords.x-1, world_coords.y, world_coords.z));

                if(BLOCKS[left.id].empty) dispatch!(Side.LEFT)(value, biome_data, world_coords, x_offset, y_offset, z_offset);
            }

            if(y == 0) {
                // always render this, it's the lowest bedrock level
                dispatch!(Side.BOTTOM)(value, biome_data, world_coords, x_offset, y_offset, z_offset);
            }

            if(z == 0) {
                Block back = world.get_block_safe(vec3i(world_coords.x, world_coords.y, world_coords.z-1));

                if(BLOCKS[back.id].empty) dispatch!(Side.FAR)(value, biome_data, world_coords, x_offset, y_offset, z_offset);
            }
        }
    }

    void fill_vbo(Buffer vbo) {
        vbo.set_data(buffer.ptr, elements);
    }
}