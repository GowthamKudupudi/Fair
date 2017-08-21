//
//  MySceneViewController.swift
//  HelloMetal
//
//  Created by Gowtham Kudupudi on 03/05/17.
//  Copyright © 2017 Gowtham Kudupudi. All rights reserved.
//

import UIKit

class MySceneViewController: MetalViewController,MetalViewControllerDelegate {
    
    var viewMatrix: Matrix4!
    var lightPosition = float4(x:0.0,y:0.0,z:9.0,w:1.0)
    var lightColor = float4(1.0,1.0,1.0,1.0)
    var ambientColor = float4(0.1, 0.1, 0.1, 1.0)
    var lightPower = Float(50.0)
    var objectToDraw: BasicNode!
    let panSensivity:Float = 5.0
    var lastPanLocation: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewMatrix = Matrix4()
        viewMatrix.translate(0.0, y: 0.0, z: -3.0)
        //viewMatrix.rotateAroundX(Matrix4.degrees(toRad: 45), y: Matrix4.degrees(toRad: 45), z: Matrix4.degrees(toRad: 0))
        
        objectToDraw = Icosahedron(device: device, commandQ:commandQueue)
        //objectToDraw = Sphere(device: device, commandQ:commandQueue)
        self.metalViewControllerDelegate = self
        
        setupGestures()
        
    }
    
    //MARK: - MetalViewControllerDelegate
    func renderObjects(drawable:CAMetalDrawable) {
        
        objectToDraw.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawable, parentModelViewMatrix: viewMatrix, projectionMatrix: projectionMatrix, clearColor: nil)
    }
    
    func updateLogic(timeSinceLastUpdate: CFTimeInterval) {
        objectToDraw.updateWithDelta(delta: timeSinceLastUpdate)
    }
    
    //MARK: - Gesture related
    // 1
    func setupGestures(){
        let pan = UIPanGestureRecognizer(target: self, action: #selector(MySceneViewController.pan))
        self.view.addGestureRecognizer(pan)
    }
    
    // 2
    func pan(panGesture: UIPanGestureRecognizer){
        if panGesture.state == UIGestureRecognizerState.changed {
            let pointInView = panGesture.location(in: self.view)
            // 3
            let xDelta = Float((lastPanLocation.x - pointInView.x)/self.view.bounds.width) * panSensivity
            let yDelta = Float((lastPanLocation.y - pointInView.y)/self.view.bounds.height) * panSensivity
            // 4
            objectToDraw.rotation.y -= xDelta
            objectToDraw.rotation.x -= yDelta
            lastPanLocation = pointInView
        } else if panGesture.state == UIGestureRecognizerState.began {
            lastPanLocation = panGesture.location(in: self.view)
        }
    }
    
}
