//
//  Renderable.swift
//  ShadingDemo
//
//  Created by lowe on 2018/11/29.
//  Copyright © 2018 lowe. All rights reserved.
//

import MetalKit

protocol Renderable {
    var name: String { get }
    var mesh: MTKMesh { get }
    var submeshes: [Submesh] { get }
    
    var modelMatrix: float4x4 { get }
    var normalMatrix: float3x3 { get }
}
