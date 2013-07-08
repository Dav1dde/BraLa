module brala.gfx.util;

private {
    import brala.utils.image : Image;
}


bool is_power_of_two(Image image) {
    if(image.width == 0 || image.height == 0 ||
        (image.width & (image.width - 1)) ||
        (image.height & (image.height - 1))) {

        return false;
    }

    return true;
}