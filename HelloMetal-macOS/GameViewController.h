//
//  GameViewController.h
//  HelloMetal-macOS
//
//  Created by Gowtham Kudupudi on 01/07/17.
//  Copyright © 2017 Gowtham Kudupudi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import "Renderer.h"

// Our view controller.  Implements the MTKViewDelegate protocol, which allows it to accept
//   per-frame update and drawable resize callbacks.  Also implements the RenderDestinationProvider
//   protocol, which allows our renderer object to get and set drawable properties such as pixel
//   format and sample count

@interface GameViewController : NSViewController<MTKViewDelegate, RenderDestinationProvider>

@end


