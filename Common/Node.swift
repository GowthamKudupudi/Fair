//
//  Node.swift
//  HelloMetal
//
//  Created by Gowtham Kudupudi on 24/04/17.
//  Copyright © 2017 Gowtham Kudupudi. All rights reserved.
//

import Foundation
import Metal
import QuartzCore
import CoreMotion
import AudioToolbox

class BasicNode {
    var device: MTLDevice
    var name: String
    var vertexCount: Int
    var vertexBuffer: MTLBuffer
    var indexBuffer: MTLBuffer? = nil
    var indexCount: Int = 0
    var position = float3(0.0, 0.0, 0.0)
    var rotation = float3(0.0, 0.0, 0.0)
    var scale: Float     = 1.0
    var time:CFTimeInterval = 0.0
    var bufferProvider: BufferProvider
    var texture: MTLTexture
    let density=0.0
    let restoringFactor=Float(100.0)
    let dampingFactor=Float(0.98)
    var acceleration = float3(0.0,0.0,0.0)
    var velocity = float3(0.0,0.0,0.0)
    lazy var samplerState: MTLSamplerState? = Node.defaultSampler(device: self.device)
    let light = Light(color: (1.0, 1.0, 1.0), ambientIntensity: 0.1, position: (0.0,0.0,12.0,1.0), intensity: 100.0, shininess: 15)
    let motionManager = CMMotionManager()
    // Sound
    let sampleRate = 44100
    let numChannels = 2
    var ringBufferCount:Int = 3
    var inFormat:AudioStreamBasicDescription
    var inQueue: AudioQueueRef? = nil
    var presentRingBufRef:AudioQueueBufferRef? = nil
    var player = Player()
    var ringBufProvider: RingBufferProvider
    init(name: String, device:MTLDevice, vertexData:inout Array<Float>,vertexCount: Int,texture: MTLTexture, indexData: inout Array<UInt16>)
    {
        self.name = name
        self.device = device
        var dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options:[])
        let sizeOfUniformsBuffer = MemoryLayout<Float>.size * Matrix4.numberOfElements() * 3 + Light.size()
        self.bufferProvider = BufferProvider(device: device, inflightBuffersCount: 3, sizeOfUniformsBuffer: sizeOfUniformsBuffer)
        self.vertexCount=vertexCount
        self.texture = texture
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates()
        }
        inFormat = AudioStreamBasicDescription(
            mSampleRate:        Double(sampleRate),
            mFormatID:          kAudioFormatLinearPCM,
            mFormatFlags:       kLinearPCMFormatFlagIsBigEndian | kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked,
            mBytesPerPacket:    UInt32(numChannels * MemoryLayout<UInt16>.size),
            mFramesPerPacket:   1,
            mBytesPerFrame:     UInt32(numChannels * MemoryLayout<UInt16>.size),
            mChannelsPerFrame:  UInt32(numChannels),
            mBitsPerChannel:    UInt32(8 * (MemoryLayout<UInt16>.size)),
            mReserved:          UInt32(0)
        )
        AudioQueueNewOutput(&inFormat, AQOutputCallback, &player, nil, nil, 0, &inQueue)
        ringBufProvider = RingBufferProvider(inQueue: inQueue!, inflightBuffersCount: ringBufferCount, sizeOfRingBuffer: numChannels*sampleRate/50)
        player.packetDescs = UnsafeMutablePointer<AudioStreamPacketDescription>.allocate(capacity: MemoryLayout<AudioStreamPacketDescription>.size * Int(player.numPacketsToRead))
        if(indexData.count > 0) {
            dataSize = indexData.count * MemoryLayout.size(ofValue: indexData[0])
            indexBuffer = device.makeBuffer(bytes: indexData, length: dataSize, options:[])
        }
    }
    deinit {
        motionManager.stopDeviceMotionUpdates()
    }
    class Player {
        var playbackFile: AudioFileID? = nil
        var packetPosition: Int64 = 0
        var numPacketsToRead: UInt32 = 0
        var packetDescs: UnsafeMutablePointer<AudioStreamPacketDescription>? = nil
        var isDone = false
    }
    func render(commandQueue: MTLCommandQueue, pipelineState:MTLRenderPipelineState, drawable: CAMetalDrawable, parentModelViewMatrix: Matrix4, projectionMatrix: Matrix4, clearColor:MTLClearColor?) {
        _ = bufferProvider.avaliableResourcesSemaphore.wait(timeout: DispatchTime.distantFuture)
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        let commandBuffer = commandQueue.makeCommandBuffer()
        commandBuffer.addCompletedHandler { (_) in
            self.bufferProvider.avaliableResourcesSemaphore.signal()
        }
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoder.setCullMode(MTLCullMode.front)
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
        renderEncoder.setFragmentTexture(texture, at: 0)
        if let samplerState = samplerState{
            renderEncoder.setFragmentSamplerState(samplerState, at: 0)
        }
        let nodeModelMatrix = self.modelMatrix()
        //nodeModelMatrix.multiplyLeft(parentModelViewMatrix)
        let uniformBuffer = bufferProvider.nextUniformsBuffer(projectionMatrix: projectionMatrix, viewMatrix: parentModelViewMatrix, modelMatrix: nodeModelMatrix, light: light)
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, at: 1)
        renderEncoder.setFragmentBuffer(uniformBuffer,offset:0, at: 1)
        if(indexBuffer==nil){
            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: 1)
        }
        else {
            renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: vertexCount, indexType: .uint16, indexBuffer: indexBuffer!, indexBufferOffset: 0)
        }
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
        // Sound
        //DispatchQueue.global(qos: .userInitiated).async {
            
//            var presentRingBufRef = self.ringBufProvider.nextRingBuffer()
//            var presentRingBuf = UnsafeMutableBufferPointer<UInt16>(start:        presentRingBufRef.pointee.mAudioData.assumingMemoryBound(to: UInt16.self),count:self.ringBufProvider.sizeOfRingBuffer)
//            
//            for var i in stride(from:0,to:self.ringBufferCount-1, by:2){
//                presentRingBuf[i]=UInt16(Float(UInt32.max)*sin(2*Float.pi*Magnitude(of: self.velocity))).bigEndian
//                presentRingBuf[i+1] = presentRingBuf[i]
//            }
//            AudioQueueStop(self.inQueue!, true)
//            AudioQueueFlush(self.inQueue!)
//            AudioQueueEnqueueBuffer(self.inQueue!, presentRingBufRef, UInt32(self.ringBufProvider.sizeOfRingBuffer/self.numChannels), self.player.packetDescs!)
//            AudioQueueStart(self.inQueue!, nil)
//            self.presentRingBufRef = presentRingBufRef
        //}
    }
    let AQOutputCallback: AudioQueueOutputCallback = {(inUserData, inAQ, inCompleteAQBuffer) -> () in
        //let aqp = UnsafeMutablePointer<Player>(inUserData).memory
//        let aqp = inUserData?.assumingMemoryBound(to: Player.self).pointee
//        
//        guard !(aqp?.isDone)! else {
//            return
//        }
//        
//        var numBytes = UInt32()
//        var nPackets = aqp?.numPacketsToRead
        
        
    }
    func modelMatrix() -> Matrix4 {
        let matrix = Matrix4()
        matrix.translate(position.x, y: position.y, z: position.z)
        matrix.rotateAroundX(rotation.x, y: rotation.y, z: rotation.z)
        matrix.scale(scale, y: scale, z: scale)
        return matrix
    }
    func updateWithDelta(delta: CFTimeInterval){
        time += delta // initial: 0, units: seconds
        //print("delta: \(delta)")
        var dt = Float(delta)
        dt = dt>0.5 ? 0.5:dt
        if motionManager.isDeviceMotionAvailable {
            var data = motionManager.deviceMotion
            if(data != nil){
                var accel=float3(Float((data?.userAcceleration.x)!), Float((data?.userAcceleration.y)!), Float((data?.userAcceleration.z)!))
                accel*=100
                var dt2 = pow(dt, 2)
                var accFact = (dt2/2)/(1+(restoringFactor*dt2/4))
                var dx=float3(0.0,0.0,0.0)
                dx+=(accel+acceleration)*accFact
                dx+=velocity*dt
                dx*=dampingFactor
                position+=dx
                acceleration = -(position*restoringFactor)
                if(dt>0){velocity=dx*(1/dt)}
            }
        }
        
        // Sound
        
    }
    class func defaultSampler(device: MTLDevice) -> MTLSamplerState {
        let sampler = MTLSamplerDescriptor()
        sampler.minFilter             = MTLSamplerMinMagFilter.nearest
        sampler.magFilter             = MTLSamplerMinMagFilter.nearest
        sampler.mipFilter             = MTLSamplerMipFilter.nearest
        sampler.maxAnisotropy         = 1
        sampler.sAddressMode          = MTLSamplerAddressMode.clampToEdge
        sampler.tAddressMode          = MTLSamplerAddressMode.clampToEdge
        sampler.rAddressMode          = MTLSamplerAddressMode.clampToEdge
        sampler.normalizedCoordinates = true
        sampler.lodMinClamp           = 0
        sampler.lodMaxClamp           = FLT_MAX
        return device.makeSamplerState(descriptor: sampler)
    }
}

class Node_legacy:BasicNode{
    var indexData:Array<UInt16>=[]
    init(name: String, vertices: UnsafeMutablePointer<GLfloat>, device: MTLDevice, count:Int, texture: MTLTexture){
        var vertexData = Array<Float>()
        //for i in 0 ..< count {
        var i=0
        let coordinatesCount = count*3
        var u = Float(0.63)
        var v = Float(0.37)
        var triangle:[[Float]] = [
            [0.0, 0.0, 0.0],
            [0.0, 0.0, 0.0],
            [0.0, 0.0, 0.0]
        ]
        var triangle0:[Float] = [
            0.0, 0.0, 0.0,
            0.0, 0.0, 0.0,
            0.0, 0.0, 0.0
        ]
        var normal:[Float]
        var m=0
        var n=0
        while i<coordinatesCount{
            //vertexData.append(vertices[i])
            triangle[m][n] = vertices[i]
            i+=1
            n+=1
            if(i%3 == 0){
                n=0
                m+=1
                if(i%9==0){
                    m=0
                    //normal = Curl(triangle: triangle)
                    var normal0 = triangle.flatMap{ $0 }.withUnsafeBufferPointer { (buffer) -> MyFloat3 in
                        var p = buffer.baseAddress
                        return ExtCurl(OpaquePointer(p))
                    }
                    normal = [normal0.x, normal0.y, normal0.z]
                //u = 2 * u * (1 - v)
                u += 0.08
                v = 1 - u
                if(u > 1){u-=1}
                    vertexData += triangle[0]
                    vertexData += [1.0,1.0,1.0,1.0, 0.0, 0.0]
                    vertexData += triangle[0]
                    vertexData += triangle[1]
                    vertexData += [1.0,1.0,1.0,1.0, 0.0, 0.0]
                    vertexData += triangle[1]
                    vertexData += triangle[2]
                    vertexData += [1.0,1.0,1.0,1.0, 0.0, 0.0]
                    vertexData += triangle[2]
                }
            }
        }
        super.init(name:name,device:device,vertexData: &vertexData,vertexCount:count, texture:texture, indexData: &indexData)
        
    }

}

class Node:BasicNode{
    var indexData:Array<UInt16>=[]
    init(name: String, vertices: Array<Vertex>, device: MTLDevice, texture: MTLTexture){
        var vertexData = Array<Float>()
        for vertex in vertices{
            vertexData += vertex.floatBuffer()
        }
        super.init(name:name,device:device,vertexData: &vertexData, vertexCount:vertices.count, texture:texture, indexData: &indexData)
    }
}

func Curl(triangle:[[Float]])->[Float]{
    var curl:[Float]=[0.0,0.0,0.0];
    curl[2] = (triangle[1][0] - triangle[0][0])*(triangle[2][1]-triangle[0][1]) - (triangle[1][1] - triangle[0][1])*(triangle[2][0]-triangle[0][0]);
    curl[1] = (triangle[1][2] - triangle[0][2])*(triangle[2][1]-triangle[0][1]) - (triangle[1][0] - triangle[0][0])*(triangle[2][2]-triangle[0][0]);
    curl[0] = (triangle[1][1] - triangle[0][1])*(triangle[2][2]-triangle[0][2]) - (triangle[1][2] - triangle[0][2])*(triangle[2][1]-triangle[0][1]);
    return curl;
}

precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ^ : PowerPrecedence
func ^<T,U> (radix: T, power: U) -> Double {
    return pow(radix as! Double, power as! Double)
}

func AccelerationMagnitude(accel:CMAcceleration) -> Double{
    return sqrt(accel.x^2+accel.y^2+accel.z^2)
}
func Magnitude(of:float3) -> Float{
    return sqrt(Float(of.x^2+of.y^2+of.z^2))
}
func CheckError(_ error: OSStatus, operation: String) {
    guard error != noErr else {
        return
    }
    
    var result: String = ""
    var char = Int(error.bigEndian)
    
    for _ in 0..<4 {
        guard isprint(Int32(char&255)) == 1 else {
            result = "\(error)"
            break
        }
        result.append(String(describing: UnicodeScalar(char&255)))
        char = char/256
    }
    
    print("Error: \(operation) (\(result))")
    
    exit(1)
}
