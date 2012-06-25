module brala.dine.builder.builder;

private {
    import brala.dine.chunk : Block;
    import brala.dine.builder.constants : Side;
    import brala.dine.builder.tessellator : Vertex;
}


mixin template BlockBuilder() {
    void add_vertex(float x, float y, float z, float nx, float ny, float nz, byte u, byte v)
        in { assert(elements+1 <= buffer_length, "not enough allocated memory for tessellator"); }
        body {
            buffer[elements++] = Vertex(x, y, z, nx, ny, nz, u, v, 0, 0);
        }

    void add_vertex(const ref Vertex vertex)
        in { assert(elements+1 <= buffer_length, "not enough allocated memory for tessellator"); }
        body {
            buffer[elements++] = vertex;
        }
        
    void add_template_vertices(float x_offset, float y_offset, float z_offset, const ref Vertex[] vertices)
        in { assert(elements+vertices.length <= buffer_length, "not enough allocated memory for tessellator"); }
        body {
            buffer[elements..(elements+(vertices.length))] = vertices;

            size_t end = elements+vertices.length;
            for(; elements < end; elements++) {
                Vertex* vertex = &buffer[elements];
                vertex.x += x_offset;
                vertex.y += y_offset;
                vertex.z += z_offset;
            }
        }

    void add_vertices(const ref Vertex[] vertices)
        in { assert(elements+vertices.length <= buffer_length, "not enough allocated memory for tesselator"); }
        body {
            buffer[elements..(elements+(vertices.length))] = vertices;
            elements += vertices.length;
        }

    
    void dispatch(Side side)(float x_offset, float y_offset, float z_offset, const ref Block block) {
        switch(block.id) {
            default: tessellate_simple_block!(side)(x_offset, y_offset, z_offset, block); 
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
        } else static if(side == Side.ALL) {
            tessellate_simple_block!(Side.LEFT)(x_offset, y_offset, z_offset, block);
            tessellate_simple_block!(Side.RIGHT)(x_offset, y_offset, z_offset, block);
            tessellate_simple_block!(Side.NEAR)(x_offset, y_offset, z_offset, block);
            tessellate_simple_block!(Side.FAR)(x_offset, y_offset, z_offset, block);
            tessellate_simple_block!(Side.TOP)(x_offset, y_offset, z_offset, block);
            tessellate_simple_block!(Side.BOTTOM)(x_offset, y_offset, z_offset, block);
        }
    }
}