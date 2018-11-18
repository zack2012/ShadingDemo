//
//  Node.swift
//  ShadingDemo
//
//  Created by lowe on 2018/11/17.
//  Copyright © 2018 lowe. All rights reserved.
//

import MetalKit
import Math

class Node {
    var name = ""
    var position: float3 = [0, 0, 0]
    var rotation: float3 = [0, 0, 0]
    var scale: float3 = [1, 1, 1]
    
    var modelMatrix: float4x4 {
        let translateMatrix = Math.translate(position)
        let rotateMatrix = Math.rotation(rotation)
        let scaleMatrix = Math.scale(scale)
        
        return translateMatrix * rotateMatrix * scaleMatrix
    }
}
