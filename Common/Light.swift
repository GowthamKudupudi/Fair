//
//  Light.swift
//  HelloMetal
//
//  Created by Gowtham Kudupudi on 05/05/17.
//  Copyright © 2017 Gowtham Kudupudi. All rights reserved.
//

import Foundation

struct Light {
    var color: (Float, Float, Float)
    var ambientIntensity: Float
    var position: (Float,Float,Float,Float)
    var intensity:Float
    var shininess: Float
    static func size() -> Int {
        return MemoryLayout<Float>.size * 12
    }
    func raw() -> [Float] {
        let raw = [color.0, color.1, color.2, ambientIntensity, position.0, position.1, position.2,position.3, intensity, shininess]
        return raw
    }
}
