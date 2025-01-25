#include <stdint.h>

void main()
{
    volatile char* vga = (volatile char*)0xb8000;
    vga[4] = 'C';
    vga[5] = 0x0f;
    while(1);
}
