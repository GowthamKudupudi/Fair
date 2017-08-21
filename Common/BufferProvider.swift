//
//  BufferProvider.swift
//  HelloMetal
//
//  Created by Gowtham Kudupudi on 01/05/17.
//  Copyright © 2017 Gowtham Kudupudi. All rights reserved.
//

import Foundation
import Metal

class BufferProvider: NSObject {
    let inflightBuffersCount: Int
    private var uniformsBuffers: [MTLBuffer]
    private var availableBufferIndex: Int = 0
    var avaliableResourcesSemaphore: DispatchSemaphore
    init(device:MTLDevice, inflightBuffersCount: Int, sizeOfUniformsBuffer: Int) {
        avaliableResourcesSemaphore = DispatchSemaphore(value: inflightBuffersCount)
        self.inflightBuffersCount = inflightBuffersCount
        uniformsBuffers = [MTLBuffer]()
        
        for _ in 0...inflightBuffersCount-1 {
            let uniformsBuffer = device.makeBuffer(length: sizeOfUniformsBuffer, options: [])
            uniformsBuffers.append(uniformsBuffer)
        }
    }
    
    func nextUniformsBuffer(projectionMatrix: Matrix4, viewMatrix: Matrix4, modelMatrix: Matrix4, light: Light) -> MTLBuffer {
        
        // 1
        let buffer = uniformsBuffers[availableBufferIndex]
        
        // 2
        var bufferPointer = buffer.contents()
        
        // 3
        memcpy(bufferPointer, modelMatrix.raw(), MemoryLayout<Float>.size * Matrix4.numberOfElements())
        bufferPointer += MemoryLayout<Float>.size*Matrix4.numberOfElements()
        memcpy(bufferPointer  , viewMatrix.raw(), MemoryLayout<Float>.size*Matrix4.numberOfElements())
        bufferPointer += MemoryLayout<Float>.size*Matrix4.numberOfElements()
        memcpy(bufferPointer, projectionMatrix.raw(), MemoryLayout<Float>.size * Matrix4.numberOfElements())
        bufferPointer += MemoryLayout<Float>.size*Matrix4.numberOfElements()
        memcpy(bufferPointer, light.raw(), Light.size())
        
        // 4
        availableBufferIndex += 1
        if availableBufferIndex == inflightBuffersCount{
            availableBufferIndex = 0
        }
        
        return buffer
    }

    deinit{
        for _ in 0...self.inflightBuffersCount{
            self.avaliableResourcesSemaphore.signal()
        }
    }
}
