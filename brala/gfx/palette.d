module brala.gfx.palette;

private {
    import brala.utils.image : Image, RGB;
}


Image palette_atlas(Image grasscolor, Image leavecolor, Image watercolor)
    in { assert(grasscolor.width == leavecolor.width && grasscolor.width == watercolor.width);
         assert(grasscolor.height == leavecolor.height && grasscolor.height == watercolor.height); }
    body {
        if(grasscolor.comp != RGB) {
            grasscolor = grasscolor.convert(RGB);
        }
        if(leavecolor.comp != RGB) {
            leavecolor = leavecolor.convert(RGB);
        }
        if(watercolor.comp != RGB) {
            watercolor = watercolor.convert(RGB);
        }

        int width = grasscolor.width; // others have the same width/height/comp
        int height = grasscolor.height;
        int comp = RGB;
        /*  _____
           |__|__| Empty, grass
           |__|__| leaves, water
        */
        Image palette = Image.empty(width*2, height*2, comp);
        palette.data[] = 0xff;
        
        palette.replace(width, 0, grasscolor);
        palette.replace(0, height, leavecolor);
        palette.replace(width, height, watercolor);

        return palette;
    }
