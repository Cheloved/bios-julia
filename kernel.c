#include <stdint.h>

void main()
{
    volatile char* fb = (volatile char*)0xb8000;
    fb[4] = 'C';
    fb[5] = 0x0f;

    while(1);
}
