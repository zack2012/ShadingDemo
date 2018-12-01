//
//  DragonProp.swift
//  ShadingDemo
//
//  Created by lowe on 2018/12/1.
//  Copyright © 2018 lowe. All rights reserved.
//

import MetalKit
import simd

class DragonProp: Prop {
    private var sign: Float = 1
    
    override func update(deltaTime: Float) {
        if position.x > 3 {
            sign = -1
        }
        
        if position.x < -3 {
            sign = 1
        }
        
        position.x += sign * 0.01
        
        rotation += float3(sign * 0.01)
        
        scale += float3(sign * 0.01)
        scale = max(scale, [0.5, 0.5, 0.5])
    }
}
