#include <stdint.h>

uint32_t* fb;
uint16_t  width;
uint16_t  height;
uint8_t   bpp;

void main()
{
    // Заливка синим цветом
    for ( uint16_t x = 0; x < width; x++ )
    {
        for ( uint16_t y = 0; y < height; y++ )
        {
            fb[y*width + x] = 0x000000FF;
        }
    }

    while(1);
}
