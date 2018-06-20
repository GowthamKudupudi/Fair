//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import "Matrix4.h"
//#import <OpenGLES/ES2/glext.h>
//#import "Icosohedron.h"
void ExtNormal (const GLfloat* gfSolid, unsigned int uiSolidSize, 
   GLfloat* gfSphere, unsigned int uiSphereSize, unsigned short iRegression, 
   unsigned short usDimensions);
struct MyFloat3 {
    float x;
    float y;
    float z;
};
struct MyFloat3 ExtCurl (const float (* const triangle)[][3]);
//static float* icosoHedronVertices = IcosoHedron::vertices;
//static float* icosoHedronTrinagles = IcosoHedron::triangles;
