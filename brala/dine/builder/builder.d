module brala.dine.builder.builder;

private {
    import brala.dine.chunk : Block;
    import brala.dine.builder.constants : Side;
}


mixin template BlockBuilder() {
    void simple_block(Side side)(float x_offset, float y_offset, float z_offset, const ref Block block) {
        tessellate_simple_block!(side)(x_offset, y_offset, z_offset, block);
    }

    void dispatch(Side side)(float x_offset, float y_offset, float z_offset, const ref Block block) {
        switch(block.id) {
            default: simple_block!(side)(x_offset, y_offset, z_offset, block); 
        }
    }
}