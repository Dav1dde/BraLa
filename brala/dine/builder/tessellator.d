module brala.dine.builder.tessellator;

private {
    import glamour.gl : GL_FLOAT;
    import glamour.vbo : Buffer;
    
    import gl3n.linalg : vec3i;
    
    import brala.dine.chunk : Block;
    import brala.dine.world : World;
    import brala.dine.builder.builder : BlockBuilder;
    import brala.dine.builder.constants : Side;
    import brala.dine.builder.blocks : blocks;
    import brala.dine.builder.vertices : BLOCK_VERTICES_LEFT, BLOCK_VERTICES_RIGHT, BLOCK_VERTICES_NEAR,
                                         BLOCK_VERTICES_FAR, BLOCK_VERTICES_TOP, BLOCK_VERTICES_BOTTOM;
    import brala.utils.alloc : realloc;
}


align(1) struct Vertex {
    float x;
    float y;
    float z;
    float nx;
    float ny;
    float nz;
    byte u_terrain;
    byte v_terrain;
    byte u_palette;
    byte v_palette;
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
        buffer_length += interval;
        buffer = cast(Vertex*)realloc(buffer, buffer_length*Vertex.sizeof);
    }

    void realloc_buffer_if_needed(size_t interval) {
        if(elements+interval >= buffer_length) {
            realloc_buffer(interval);
        }
    }
    
    void feed(vec3i world_coords, int x, int y, int z,
              float x_offset, float x_offset_r, float y_offset, float y_offset_t, float z_offset, float z_offset_n,
              const ref Block value, const ref Block right, const ref Block top, const ref Block front) {

       
        if(blocks[value.id].empty) { // render neighbours
            if(!blocks[right.id].empty) dispatch!(Side.LEFT)(x_offset_r, y_offset, z_offset, right);
            if(!blocks[top.id].empty)   dispatch!(Side.BOTTOM)(x_offset, y_offset_t, z_offset, top);
            if(!blocks[front.id].empty) dispatch!(Side.FAR)(x_offset, y_offset, z_offset_n, front);

            if(value.id != 0) {
                dispatch!(Side.ALL)(x_offset, y_offset, z_offset, value);
            }
        } else {
            if(blocks[right.id].empty) dispatch!(Side.RIGHT)(x_offset, y_offset, z_offset, value);
            if(blocks[top.id].empty)   dispatch!(Side.TOP)(x_offset, y_offset, z_offset, value);
            if(blocks[front.id].empty) dispatch!(Side.NEAR)(x_offset, y_offset, z_offset, value);

            if(x == 0) {
                Block left = world.get_block_safe(vec3i(world_coords.x-1, world_coords.y, world_coords.z));

                if(blocks[left.id].empty) dispatch!(Side.LEFT)(x_offset, y_offset, z_offset, value);
            }

            if(y == 0) {
                // always render this, it's the lowest bedrock level
                dispatch!(Side.BOTTOM)(x_offset, y_offset, z_offset, value);
            }

            if(z == 0) {
                Block back = world.get_block_safe(vec3i(world_coords.x, world_coords.y, world_coords.z-1));

                if(blocks[back.id].empty) dispatch!(Side.FAR)(x_offset, y_offset, z_offset, value);
            }
        }
    }

    void fill_vbo(Buffer vbo) {
        vbo.set_data(buffer[0..elements]);
    }
}