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
    func render(encoder: MTLRenderCommandEncoder, uniforms: Uniforms)
}
