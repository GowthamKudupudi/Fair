//
//  Sphere.swift
//  HelloMetal
//
//  Created by Gowtham Kudupudi on 25/04/17.
//  Copyright © 2017 Gowtham Kudupudi. All rights reserved.
//

import Foundation
//
//  Cube.swift
//  HelloMetal
//
//  Created by Gowtham Kudupudi on 24/04/17.
//  Copyright © 2017 Gowtham Kudupudi. All rights reserved.
//

import Foundation
import Metal

class Sphere: Node_legacy {
    
    init(device: MTLDevice, commandQ: MTLCommandQueue){
        
        var g_octahedron_vertex_buffer_data:[GLfloat] = [
            0.0, 1.0, 0.0,
            -1.0, 0.0, 0.0,
            0.0, 0.0, 1.0,
            0.0, 1.0, 0.0,
            0.0, 0.0, 1.0,
            1.0, 0.0, 0.0,
            0.0, 1.0, 0.0,
            1.0, 0.0, 0.0,
            0.0, 0.0,-1.0,
            0.0, 1.0, 0.0,
            0.0, 0.0,-1.0,
            -1.0, 0.0, 0.0,
            0.0,-1.0, 0.0,
            0.0, 0.0, 1.0,
            -1.0, 0.0, 0.0,
            0.0,-1.0, 0.0,
            1.0, 0.0, 0.0,
            0.0, 0.0, 1.0,
            0.0,-1.0, 0.0,
            0.0, 0.0,-1.0,
            1.0, 0.0, 0.0,
            0.0,-1.0, 0.0,
            -1.0, 0.0, 0.0,
            0.0, 0.0,-1.0
            
        ]
        
        let uiNumSphericalVertices=3*8*4*4*4*4;//3*numberOfTriangles
        var gfSphereVertexBufferData = UnsafeMutablePointer<GLfloat>.allocate(capacity: Int(3*uiNumSphericalVertices));
        ExtNormal(g_octahedron_vertex_buffer_data, 3*3*8, gfSphereVertexBufferData, UInt32(3*uiNumSphericalVertices), 4,3);
        
        //super.init(name: "Sphere", vertices:&g_octahedron_vertex_buffer_data, device: device, count:uiNumSphericalVertices)
        let texture = MetalTexture(resourceName: "cube", ext: "png", mipmaped: true)
        texture.loadTexture(device: device, commandQ: commandQ, flip: true)
        super.init(name: "Sphere", vertices:gfSphereVertexBufferData, device: device, count:uiNumSphericalVertices,texture:texture.texture)
    }
//    override func updateWithDelta(delta: CFTimeInterval) {
//        
//        super.updateWithDelta(delta: delta)
//        
//        let secsPerMove: Float = 6.0
//        rotationY = sinf( Float(time) * 2.0 * Float(M_PI) / secsPerMove)
//        rotationX = sinf( Float(time) * 2.0 * Float(M_PI) / secsPerMove)
//    }
}
