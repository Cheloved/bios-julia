#include "math.h"

float pi = 3.141592653589793f;

complex cadd(complex a, complex b)
{
    complex result = { .re=a.re+b.re, .im=a.im+b.im};
    return result;
}

complex cmul(complex a, complex b)
{
    // (a+bi)*(c+di) = (ac - bd) + (ad + bc)i
    complex result;
    result.re = a.re*b.re - a.im*b.im;
    result.im = a.re*b.im + a.im*b.re;

    return result;
}

complex cmulr(complex a, float b)
{
    complex result = { .re=a.re*b, .im=a.im*b };
    return result;
}

float cabssqr(complex a)
{
    return a.re*a.re + a.im*a.im;
}

float sin(float x)
{
    float result;
    asm volatile
        (
            "fld %1\n"
            "fsin\n"
            "fstp %0"
            : "=m" (result)
            : "m" (x)
            : "st" 
        );
    return result;
}

float cos(float x)
{
    float result;
    asm volatile
        (
            "fld %1\n"
            "fcos\n"
            "fstp %0"
            : "=m" (result)
            : "m" (x)
            : "st" 
        );
    return result;
}
