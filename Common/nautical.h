//
//  nautical.hpp
//  exploreGLES
//
//  Created by Gowtham Kudupudi on 06/04/17.
//  Copyright © 2017 SatyaGowthamKudupudi. All rights reserved.
//

#ifndef nautical_h
#define nautical_h

#import <OpenGLES/ES2/glext.h>

struct MyFloat3 {
    float x;
    float y;
    float z;
};
void Normal (const GLfloat* gfSolid, unsigned int uiSolidSize, 
   GLfloat* gfSphere, unsigned int uiSphereSize, unsigned short iRegression, 
   unsigned short usDimensions);

MyFloat3 Curl(const float triangle[3][3]);

#endif /* nautical_h */
