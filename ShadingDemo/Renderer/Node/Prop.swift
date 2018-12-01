//
//  Prop.swift
//  ShadingDemo
//
//  Created by lowe on 2018/12/1.
//  Copyright © 2018 lowe. All rights reserved.
//

import MetalKit

class Prop: Node, Renderable {
    let mesh: MTKMesh
    let submeshes: [Submesh]
    let vertexDescriptor: MDLVertexDescriptor
    
    init(name: String, device: MTLDevice) {
        let assetURL = Bundle.main.url(forResource: name, withExtension: "obj")!
        let allocator = MTKMeshBufferAllocator(device: device)
        let asset = MDLAsset(url: assetURL,
                             vertexDescriptor: Prop.makeMDLVertexDescriptor(),
                             bufferAllocator: allocator)
        let mdlMesh = asset.object(at: 0) as! MDLMesh
        
        // add tangent and bitangent here
        mdlMesh.addTangentBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate,
                                tangentAttributeNamed: MDLVertexAttributeTangent,
                                bitangentAttributeNamed: MDLVertexAttributeBitangent)
        
        self.vertexDescriptor = mdlMesh.vertexDescriptor
        
        let mesh = try! MTKMesh(mesh: mdlMesh, device: device)
        self.mesh = mesh
       
        submeshes = mdlMesh.submeshes?.enumerated().compactMap { index, submesh in
            guard let submesh = submesh as? MDLSubmesh else {
                return nil
            }
            
            return Submesh(submesh: mesh.submeshes[index], mdlSubmesh: submesh, device: device)
        } ?? []
        
        super.init()
        
        self.name = name
    }
    
    private static func makeMDLVertexDescriptor() -> MDLVertexDescriptor {
        let vertexDescriptor = MDLVertexDescriptor()
        vertexDescriptor.attributes[0] =
            MDLVertexAttribute(name: MDLVertexAttributePosition,
                               format: .float3,
                               offset: 0, bufferIndex: 0)
        vertexDescriptor.attributes[1] =
            MDLVertexAttribute(name: MDLVertexAttributeNormal,
                               format: .float3,
                               offset: 12, bufferIndex: 0)
        vertexDescriptor.attributes[2] =
            MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate,
                               format: .float2,
                               offset: 24, bufferIndex: 0)
        
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: 32)
        return vertexDescriptor
    }

}
