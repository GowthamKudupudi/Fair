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

let φby2 = (1 + sqrtf(5))  / 4
class Icosahedron: BasicNode {
    let vertices = [
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
    ]
    let triangles:[UInt16] = [
        0, 1, 4,
        1, 0, 7,
        2, 3, 5,
        3, 2, 6,
        
        4, 5, 8,
        5, 4, 11,
        6, 7, 9,
        7, 6, 10,
        
        8, 9, 0,
        9, 8, 3,
        10, 11, 1,
        11, 10, 2,
        
        0,  4,  8,
        1, 11,  4,
        2,  5, 11,
        3,  8,  5,
        
        2, 10, 6,
        3,  6,  9,
        0, 9, 7,
        1, 7, 10
    ]
    init(device: MTLDevice, commandQ: MTLCommandQueue){
        let texture = MetalTexture(resourceName: "cube", ext: "png", mipmaped: true)
        texture.loadTexture(device: device, commandQ: commandQ, flip: true)
        
        super.init(name: "Icosahedron", device: device, vertexData: &vertices, vertexCount: triangles.count, texture:texture.texture,indexData: &triangles)
    }
}

