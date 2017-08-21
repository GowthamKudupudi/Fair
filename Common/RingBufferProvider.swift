//
//  RingBufferProvider.swift
//  HelloMetal
//
//  Created by Gowtham Kudupudi on 19/05/17.
//  Copyright © 2017 Gowtham Kudupudi. All rights reserved.
//

import Foundation
import AudioToolbox

class RingBufferProvider: NSObject {
    let inflightBuffersCount: Int
    private var availableBufferIndex:Int = 0
    private var ringBuffers:AudioQueueBufferRef? = nil
    private var ringBuffers2:AudioQueueBufferRef? = nil
    var avaliableResourcesSemaphore: DispatchSemaphore
    let sizeOfRingBuffer:Int
    init(inQueue: AudioQueueRef, inflightBuffersCount: Int, sizeOfRingBuffer: Int) {
        self.inflightBuffersCount=inflightBuffersCount
        avaliableResourcesSemaphore = DispatchSemaphore(value: inflightBuffersCount)
        //ringBuffers = [AudioQueueBufferRef](repeating: nil, count:inflightBuffersCount)
        //ringBuffers = nil
        self.sizeOfRingBuffer = sizeOfRingBuffer
        //for var i in 0...inflightBuffersCount-1{
            var status = AudioQueueAllocateBuffer(inQueue, UInt32(self.sizeOfRingBuffer*MemoryLayout.size(ofValue: UInt16.self)), &ringBuffers)
            print("\(status.description)")
        status = AudioQueueAllocateBuffer(inQueue, UInt32(self.sizeOfRingBuffer*MemoryLayout.size(ofValue: UInt16.self)), &ringBuffers2)
        print("\(status.description)")

            //print("\(ringBuffers[i])")
        //}
    }
    
    func nextRingBuffer() -> AudioQueueBufferRef {
        

        // 4
        availableBufferIndex += 1
        if availableBufferIndex == inflightBuffersCount{
            availableBufferIndex = 0
        }
        if availableBufferIndex == 0 {
        return ringBuffers!
        } else {
            return ringBuffers2!
        }
    }
    
    deinit{
        for _ in 0...self.inflightBuffersCount{
            self.avaliableResourcesSemaphore.signal()
        }
    }
}
