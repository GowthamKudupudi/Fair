//
//  nautical.cpp
//  exploreGLES
//
//  Created by Gowtham Kudupudi on 06/04/17.
//  Copyright © 2017 SatyaGowthamKudupudi. All rights reserved.
//

#include "nautical.h"
#include <stdlib.h>
#include <iostream>
#include <string>
#include <string.h>
#include <cmath>
#import <OpenGLES/ES2/glext.h>

void Normal (const GLfloat* gfSolid, unsigned int uiSolidSize, 
   GLfloat* gfSphere, unsigned int uiSphereSize, unsigned short iRegression,
   unsigned short usDimensions
) {
   if(uiSphereSize < (pow(4,iRegression)*uiSolidSize)) return;
   int i=0,j=0;
   unsigned int uiTempSolidFillSize=uiSolidSize;
   unsigned int uiTempSolidSize=uiSphereSize;
   GLfloat* gfTempSolid = (GLfloat*)malloc(uiTempSolidSize * sizeof(*gfSolid));
   memcpy(gfTempSolid, gfSolid, uiTempSolidFillSize * sizeof(*gfSolid));
   GLfloat gfTempTriangle[3*3];
   for (int r=0; r < iRegression; r++){
      i = 0;
      j = 0;
      while (i < uiTempSolidFillSize) {
         // generate mid veritces
         int k = 0;
         int n = 0;
         GLfloat gfLen;
         for (k = 0; k < 3; ++k) {
            // for each dimension
            gfLen = 0;
            for (n=0; n < usDimensions; n++) {
               gfTempTriangle[3*k+n] = gfTempSolid[(3*k)+i+n] + 
                  gfTempSolid[3*((k+1)%3)+i+n];
               gfLen += pow(gfTempTriangle[3*k+n],2);
            }
            gfLen = sqrt(gfLen);
            // normalize length
            for (n=0; n < usDimensions; ++n) gfTempTriangle[3*k+n] /= gfLen;
         }
         // group vertices with mid vertices
         // each vertex
         for (k=0; k<3; ++k) {
            // at each dimension
            for (n=0; n<3; ++n) {
               gfSphere[j+n]     = gfTempSolid[i+3*(k%3)+n];
               gfSphere[j+3+n]   = gfTempTriangle[3*k+n];
               gfSphere[j+6+n]   = gfTempTriangle[3*((k+2)%3)+n];
            }
            j+=9;
         }
         // vertices of triangle with mid points
         for(k=0;k<9;++k,++j)
            gfSphere[j]=gfTempTriangle[k];
         i+=9;
      }
      uiTempSolidFillSize=j;
      memcpy(gfTempSolid, gfSphere, uiTempSolidFillSize*sizeof(*gfTempSolid));
   }
}

MyFloat3 Curl(const float triangle[3][3]){
   MyFloat3 curl;
   curl.x = (triangle[1][1]-triangle[0][1]) * (triangle[2][2]-triangle[0][2]) - 
      (triangle[1][2]-triangle[0][2]) * (triangle[2][1]-triangle[0][1]);
   curl.y = (triangle[1][2]-triangle[0][2]) * (triangle[2][0]-triangle[0][0]) - 
      (triangle[1][0]-triangle[0][0]) * (triangle[2][2]-triangle[0][2]);
   curl.z = (triangle[1][0]-triangle[0][0]) * (triangle[2][1]-triangle[0][1]) - 
      (triangle[1][1]-triangle[0][1]) * (triangle[2][0]-triangle[0][0]);
   return curl;
}
