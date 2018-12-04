//
//  Camera.swift
//  ShadingDemo
//
//  Created by lowe on 2018/11/17.
//  Copyright © 2018 lowe. All rights reserved.
//

import MetalKit
import Math

class Camera: Node {
    var fovDegrees: Float = 70
    
    var aspect: Float = 1
    var near: Float = 0.01
    var far: Float = 100
    
    private(set) var center = float3()
    private(set) var up = float3()
    
    var projectionMatrix: float4x4 {
        return perspective(aspect: aspect,
                           fovy: fovDegrees.radian,
                           near: near, far: far)
    }
    
    var viewMatrix: float4x4 {
        return Math.rigidTransformInverse(modelMatrix)
    }
    
    func lookAt(center: float3, up: float3) {
        self.center = center
        self.up = up
    }
    
    override var modelMatrix: float4x4 {
        return Math.lookAt(eye: position, center: center, up: up)
    }
}
