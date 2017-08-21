//
//  wrapper.cpp
//  HelloMetal
//
//  Created by Gowtham Kudupudi on 28/04/17.
//  Copyright © 2017 Gowtham Kudupudi. All rights reserved.
//

#include "nautical.h"

extern "C" void ExtNormal(const GLfloat* gfSolid, unsigned int uiSolidSize, GLfloat* gfSphere, unsigned int uiSphereSize, unsigned short iRegression, unsigned short usDimensions){
    Normal(gfSolid, uiSolidSize, gfSphere, uiSphereSize, iRegression, usDimensions);
}

extern "C" MyFloat3 ExtCurl(const float (* const triangle)[][3]){
    return Curl(*triangle);
}
