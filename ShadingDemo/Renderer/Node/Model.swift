//
//  Model.swift
//  ShadingDemo
//
//  Created by lowe on 2018/11/26.
//  Copyright © 2018 lowe. All rights reserved.
//

import MetalKit

class Model: Node {
    static var defaultVertexDesc: MDLVertexDescriptor = {
        let vertexDesc = MDLVertexDescriptor()
        vertexDesc.attributes[0] = MDLVertexAttribute(name: MDLVertexAttributePosition, format: .float3, offset: 0, bufferIndex: 0)
        vertexDesc.attributes[1] = MDLVertexAttribute(name: MDLVertexAttributeNormal, format: .float3, offset: 12, bufferIndex: 0)
        vertexDesc.attributes[2] = MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate, format: .float2, offset: 24, bufferIndex: 0)
        
        vertexDesc.layouts[0] = MDLVertexBufferLayout(stride: 32)
        return vertexDesc
    }()
    
    let vertexBuffer: MTLBuffer
    let vertexDesc: MDLVertexDescriptor
    let mesh: MTKMesh
    let tiling: UInt32 = 1
    let samplerState: MTLSamplerState?
    
    init(name: String, device: MTLDevice, vertexFunctionName: String, fragmetFunctionName: String) throws {
        guard let assetURL = Bundle.main.url(forResource: name, withExtension: "obj") else {
            throw ShadingError.isNil(message: "assert url is nil")
        }

        let allocator = MTKMeshBufferAllocator(device: device)
        let asset = MDLAsset(url: assetURL, vertexDescriptor: Model.defaultVertexDesc, bufferAllocator: allocator)
        let mdlMesh = asset.object(at: 0) as! MDLMesh
        vertexDesc = mdlMesh.vertexDescriptor
        
        self.mesh = try MTKMesh(mesh: mdlMesh, device: device)
        vertexBuffer = mesh.vertexBuffers[0].buffer
        samplerState = Model.makeSamplerState(device: device)
        
        super.init()
        
    }
    
    private static func makeSamplerState(device: MTLDevice) -> MTLSamplerState? {
        let desc = MTLSamplerDescriptor()
        desc.sAddressMode = .repeat
        desc.tAddressMode = .repeat
        desc.mipFilter = .linear
        desc.magFilter = .linear
        //TODO: mean
        desc.maxAnisotropy = 8
        
        return device.makeSamplerState(descriptor: desc)
    }
}
