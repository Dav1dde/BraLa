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


struct Tessellator {
    World world;
    
    float* buffer;
    size_t buffer_length;

    size_t elements = 0;

    mixin BlockBuilder!();
    
    this(World world, ref float* buffer, ref size_t buffer_length) {
        this.world = world;
        this.buffer = buffer;
        this.buffer_length = buffer_length;
    }

    void realloc_buffer(size_t interval) {
        buffer_length += interval;
        buffer = cast(float*)realloc(buffer, buffer_length*float.sizeof);
    }

    void realloc_buffer_if_needed(size_t interval) {
        if(elements+interval >= buffer_length) {
            realloc_buffer(interval);
        }
    }
    
    void add_vertex(float x, float y, float z, float nx, float nz, float ny, float u, float v)
        in { assert(elements+8 <= buffer_length, "not enough allocated memory for tessellator"); }
        body {
            buffer[elements++] = x;
            buffer[elements++] = y;
            buffer[elements++] = z;
            buffer[elements++] = nx;
            buffer[elements++] = ny;
            buffer[elements++] = nz;
            buffer[elements++] = u;
            buffer[elements++] = v;
        }

    void add_template_vertices(float x_offset, float y_offset, float z_offset, const ref float[] vertices)
        in { assert(elements+vertices.length <= buffer_length, "not enough allocated memory for tessellator"); }
        body {
            buffer[elements..(elements+(vertices.length))] = vertices;

            size_t end = elements+vertices.length;
            for(; elements < end; elements += 5) {
                buffer[elements++] += x_offset;
                buffer[elements++] += y_offset;
                buffer[elements++] += z_offset;
            }
        }

    void add_vertices(const ref float[] vertices)
        in { assert(elements+vertices.length <= buffer_length, "not enough allocated memory for tesselator"); }
        body {
            buffer[elements..(elements+(vertices.length))] = vertices;
            elements += vertices.length;
        }
    
    void feed(vec3i world_coords, int x, int y, int z,
              float x_offset, float x_offset_r, float y_offset, float y_offset_t, float z_offset, float z_offset_n,
              const ref Block value, const ref Block right, const ref Block top, const ref Block front) {

        if(blocks[value.id].empty) { // render neighbours
            if(right.id != 0) dispatch!(Side.LEFT)(x_offset_r, y_offset, z_offset, right);
            if(top.id != 0)   dispatch!(Side.BOTTOM)(x_offset, y_offset_t, z_offset, top);
            if(front.id !=0)  dispatch!(Side.FAR)(x_offset, y_offset, z_offset_n, front);

            if(value.id != 0) {
                if(blocks[right.id].empty) dispatch!(Side.RIGHT)(x_offset, y_offset, z_offset, value);
                if(blocks[top.id].empty)   dispatch!(Side.TOP)(x_offset, y_offset, z_offset, value);
                if(blocks[front.id].empty) dispatch!(Side.NEAR)(x_offset, y_offset, z_offset, value);
            }
        } else {
            if(blocks[right.id].empty) dispatch!(Side.RIGHT)(x_offset, y_offset, z_offset, value);
            if(blocks[top.id].empty)   dispatch!(Side.TOP)(x_offset, y_offset, z_offset, value);
            if(blocks[front.id].empty) dispatch!(Side.NEAR)(x_offset, y_offset, z_offset, value);
        }

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

    void tessellate_simple_block(Side side)(float x_offset, float y_offset, float z_offset, const ref Block block) {
        static if(side == Side.LEFT) {
            add_template_vertices(x_offset, y_offset, z_offset, BLOCK_VERTICES_LEFT[block.id]);
        } else static if(side == Side.RIGHT) {
            add_template_vertices(x_offset, y_offset, z_offset, BLOCK_VERTICES_RIGHT[block.id]);
        } else static if(side == Side.NEAR) {
            add_template_vertices(x_offset, y_offset, z_offset, BLOCK_VERTICES_NEAR[block.id]);
        } else static if(side == Side.FAR) {
            add_template_vertices(x_offset, y_offset, z_offset, BLOCK_VERTICES_FAR[block.id]);
        } else static if(side == Side.TOP) {
            add_template_vertices(x_offset, y_offset, z_offset, BLOCK_VERTICES_TOP[block.id]);
        } else static if(side == Side.BOTTOM) {
            add_template_vertices(x_offset, y_offset, z_offset, BLOCK_VERTICES_BOTTOM[block.id]);
        }
    }

    void fill_vbo(Buffer vbo) {
        vbo.set_data(buffer[0..elements], GL_FLOAT);
    }
}