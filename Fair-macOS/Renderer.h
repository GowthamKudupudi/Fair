//
//  Renderer.h
//  HelloMetal-macOS
//
//  Created by Gowtham Kudupudi on 01/07/17.
//  Copyright © 2017 Gowtham Kudupudi. All rights reserved.
//

#import <simd/simd.h>
#import <ModelIO/ModelIO.h>
#import <Metal/Metal.h>

// Protocol abstracting the platform specific view in order to keep the Renderer
//   class independent from platform
@protocol RenderDestinationProvider

@property (nonatomic, readonly, nullable) MTLRenderPassDescriptor *currentRenderPassDescriptor;
@property (nonatomic, readonly, nullable) id<MTLDrawable> currentDrawable;

@property (nonatomic) MTLPixelFormat colorPixelFormat;
@property (nonatomic) MTLPixelFormat depthStencilPixelFormat;
@property (nonatomic) NSUInteger sampleCount;

@end

@interface Renderer : NSObject

-(nonnull instancetype)initWithMetalDevice:(nonnull id<MTLDevice>)device renderDestinationProvider:(nonnull id<RenderDestinationProvider>)renderDestinationProvider;

- (void)drawRectResized:(CGSize)size;

- (void)update;

@end


