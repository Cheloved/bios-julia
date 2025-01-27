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

uint16_t max_iter = 256;

void main()
{
    for ( uint16_t col = 0; col < width; col++ )
    {
        for ( uint16_t row = 0; row < height; row++ )
        {
            uint32_t idx = row*width + col;

            float x = cxstart + ((float)col / (float)width) * cxsize;
            float y = cyend - ((float)row / (float)height) * cysize;

            complex z = { .re=x, .im=y };
            complex c = { .re=-0.4f, .im=0.6f };

            uint8_t oob = 0; 
            for ( uint16_t iter = 0; iter < max_iter; iter++ )
            {
                z = cadd( cmul(z, z), c );

                if ( cabssqr(z) <= 4 )
                    continue;

                uint8_t intensity = iter % 256;
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
    /* fill_framebuffer(fb, (uint32_t)0x00000000, width, height); */

    while(1);
}
