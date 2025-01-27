#include <stdint.h>

#include "math.h"

uint32_t* fb;       // Адрес начала видеопамяти
uint16_t  width;    // Кол-во пикселей в ширину
uint16_t  height;   // Кол-во пикселей в ширину
uint8_t   bpp;      // Кол-во бит на пиксель

void fill_framebuffer(uint32_t* fb, uint32_t color, uint16_t width, uint16_t height) {
    uint32_t* end = fb + width * height;
    while (fb < end) {
        *fb++ = color;
    }
}

const float cxstart = -2.0f;
const float cxend   = 2.0f;
const float cxsize  = cxend - cxstart;

const float cystart = -1.0f;
const float cyend   = 1.0f;
const float cysize  = cyend - cystart;

uint16_t max_iter = 32;

complex calc_c(float x)
{
    complex result = { .re=sin(x), .im=cos(x) };
    result = cmulr(result, 0.7885);
    return result;
}

void main()
{
    float angle = 0.0f;
    complex c = calc_c(angle);

    float row_scale = cysize / (float)height;
    float col_scale = cxsize / (float)width;
    while (1)
    {
        for ( uint16_t col = 0; col < width; col++ )
        {
            float x = cxstart + (float)col * col_scale;

            for ( uint16_t row = 0; row < height; row++ )
            {
                uint32_t idx = row*width + col;

                float y = cyend - (float)row * row_scale;

                complex z = { .re=x, .im=y };

                uint8_t oob = 0; 
                for ( uint16_t iter = 0; iter < max_iter; iter++ )
                {
                    z = cadd( cmul(z, z), c );

                    if ( cabssqr(z) <= 4 )
                        continue;

                    /* uint8_t intensity = iter % 256; */
                    uint8_t intensity = (float)iter / (float)max_iter * 256;
                    uint32_t color = (uint32_t)intensity;
                    color = (color << 8) | intensity;
                    color = (color << 8) | intensity;
                    /* fb[idx] = 0x00000000; */
                    fb[idx] = color;
                    oob = 1;
                    break;
                }

                if ( !oob )
                    fb[idx] = 0x00FFFFFF;
            }
        }
        angle += pi / 180.0f;
        if ( angle >= 2*pi )
            angle = 0;
        c = calc_c(angle);
    }
    /* fill_framebuffer(fb, (uint32_t)0x00000000, width, height); */

    while(1);
}
