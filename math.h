#pragma once

#include <stdint.h>

typedef struct
{
    float re;
    float im;
} complex;

extern float pi;

complex cadd(complex a, complex b);
complex cmul(complex a, complex b);
complex cmulr(complex a, float b);
float cabssqr(complex a);

float sin(float x);
float cos(float x);
