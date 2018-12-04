//
//  Camera.swift
//  ShadingDemo
//
//  Created by lowe on 2018/11/17.
//  Copyright © 2018 lowe. All rights reserved.
//

import MetalKit
import GMath

class Camera: Node {
    var fovDegrees: Float = 70
    
    var aspect: Float = 1
    var near: Float = 0.01
    var far: Float = 100
    
    private(set) var target = float3()
    private(set) var up = float3()
    
    var projectionMatrix: float4x4 {
        return perspective(aspect: aspect,
                           fovy: fovDegrees.radian,
                           near: near, far: far)
    }
    
    var viewMatrix: float4x4 {
        return GMath.rigidTransformInverse(modelMatrix)
    }
    
    func lookAt(eye: float3, target: float3, up: float3) {
        self.position = eye
        self.target = target
        self.up = up
    }
    
    override var modelMatrix: float4x4 {
        return GMath.lookAt(eye: position, target: target, up: up)
    }
    
    /// point to target vector, opposite view space z axis
    var forwardVector: float3 {
        return (target - position).normalize
    }
    
    /// view space x axis
    var rightVector: float3 {
        return up.cross(position - target).normalize
    }
    
    /// view space y axis
    var upVector: float3 {
        return rightVector.cross(forwardVector)
    }
    
    var currentPitch: Float {
        return asin(forwardVector.y)
    }
    
    var currentYaw: Float {
        return asin(forwardVector.z / cos(currentPitch))
    }
}
