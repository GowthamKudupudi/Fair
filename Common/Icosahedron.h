#include <math.h>

class Icosohedron{
public:
    static const float vertices[];
    static const float triangles[];
    static const float φby2;
};

const float Icosohedron::vertices[] = {
     0.5,  φby2,  0.0,
    -0.5,  φby2,  0.0,
    -0.5, -φby2,  0.0,
     0.5, -φby2,  0.0,

     0.0,  0.5,  φby2,
     0.0, -0.5,  φby2,
     0.0, -0.5, -φby2,
     0.0,  0.5, -φby2,

     φby2, 0.0,  0.5,
     φby2, 0.0, -0.5,
    -φby2, 0.0, -0.5,
    -φby2, 0.0,  0.5
};

const float Icosohedron::triangles[] = {
  0, 1, 4,
  1, 4, 7,
  2, 3, 5,
  3, 2, 6,

  4, 5, 8,
  5, 8, 11,
  6, 7, 9,
  7, 6, 10,

  8, 9, 0,
  9, 0, 3,
  10, 11, 1,
  11, 10, 2
}

const float Icosohedron::φby2 = (1 + sqrtf(5))  / 4;
