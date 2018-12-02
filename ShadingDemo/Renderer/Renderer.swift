//
//  Renderer.swift
//  ShadingDemo
//
//  Created by lowe on 2018/11/17.
//  Copyright © 2018 lowe. All rights reserved.
//

import MetalKit
import Math
import ModelIO

class Renderer: NSObject {
    init(mtkView: MTKView) throws {
        guard let device = mtkView.device else {
            throw ShadingError.isNil(message: "MTLDevice is nil")
        }
        
        guard let commandQueue = device.makeCommandQueue() else {
            throw ShadingError.isNil(message: "makeCommandQueue is nil")
        }
        
        self.device = device
        self.commandQueue = commandQueue
        
        let pipelineDesc = MTLRenderPipelineDescriptor()
        
        let library = device.makeDefaultLibrary()
        let vertexFunc = library?.makeFunction(name: "mainVertex")
        let fragmentFunc = library?.makeFunction(name: "mainFragment")
        pipelineDesc.vertexFunction = vertexFunc
        pipelineDesc.fragmentFunction = fragmentFunc
        
        let mtlVertexDesc = Renderer.makeVertexDescriptor()
        
        pipelineDesc.vertexDescriptor = mtlVertexDesc
        pipelineDesc.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        
        pipelineDesc.depthAttachmentPixelFormat = mtkView.depthStencilPixelFormat
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDesc)
        
        let depthStateDesc = MTLDepthStencilDescriptor()
        depthStateDesc.depthCompareFunction = .less
        depthStateDesc.isDepthWriteEnabled = true
        depthState = device.makeDepthStencilState(descriptor: depthStateDesc)
        
        super.init()
        
        mtkView.delegate = self
    }
    
    var scene: Scene?
    
    private var pipelineState: MTLRenderPipelineState!
    private var depthState: MTLDepthStencilState!
    
    var device: MTLDevice
    var commandQueue: MTLCommandQueue
    
    private static func makeVertexDescriptor() -> MTLVertexDescriptor {
        let mtlVertexDesc = MTLVertexDescriptor()
        
        // position
        mtlVertexDesc.attributes[0].format = .float3
        mtlVertexDesc.attributes[0].offset = 0
        mtlVertexDesc.attributes[0].bufferIndex = 0
        
        // normal
        mtlVertexDesc.attributes[1].format = .float3
        mtlVertexDesc.attributes[1].offset = 12
        mtlVertexDesc.attributes[1].bufferIndex = 0
        
        // uv
        mtlVertexDesc.attributes[2].format = .float2
        mtlVertexDesc.attributes[2].offset = 24
        mtlVertexDesc.attributes[2].bufferIndex = 0
        
        // tangent
        mtlVertexDesc.attributes[3].format = .float3
        mtlVertexDesc.attributes[3].offset = 0
        // 用ModelIO生成的tangent默认bufferIndex = 1，这里要保持同步
        mtlVertexDesc.attributes[3].bufferIndex = 1
        
        // bitangent
        mtlVertexDesc.attributes[4].format = .float3
        mtlVertexDesc.attributes[4].offset = 0
        // 用ModelIO生成的bitangent默认bufferIndex = 2，这里要保持同步
        mtlVertexDesc.attributes[4].bufferIndex = 2
        
        mtlVertexDesc.layouts[0].stride = 32
        mtlVertexDesc.layouts[0].stepFunction = .perVertex
        
        mtlVertexDesc.layouts[1].stride = 12
        mtlVertexDesc.layouts[1].stepFunction = .perVertex
        
        mtlVertexDesc.layouts[2].stride = 12
        mtlVertexDesc.layouts[2].stepFunction = .perVertex
        
        return mtlVertexDesc
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        scene?.sceneSizeWillChange(to: size)
    }
    
    func draw(in view: MTKView) {
        guard let scene = scene else {
            return
        }
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        
        guard let drawable = view.currentDrawable,
            let renderPassDesc = view.currentRenderPassDescriptor else {
                return
        }
        
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDesc) else {
            return
        }
        
        let deltaTime = 1 / Float(view.preferredFramesPerSecond)
        scene.update(deltaTime: deltaTime)
        
        setupEncoder(encoder, pipelineState: pipelineState)

        for renderable in scene.renderables {
            encoder.pushDebugGroup(renderable.name)
            
            var uniforms = scene.uniforms
            uniforms.modelMatrix = renderable.modelMatrix
            uniforms.normalMatrix = renderable.normalMatrix
            
            encoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 10)
            
            for (i, meshBuffer) in renderable.mesh.vertexBuffers.enumerated() {
                encoder.setVertexBuffer(meshBuffer.buffer, offset: meshBuffer.offset, index: i)
            }
            
            for modelSubmesh in renderable.submeshes {
                let submesh = modelSubmesh.submesh
                
                // set texture
                encoder.setFragmentTexture(modelSubmesh.textures.baseColor, index: 0)
                encoder.setFragmentTexture(modelSubmesh.textures.normal, index: 1)
                encoder.setFragmentTexture(modelSubmesh.textures.roughtness, index: 2)
                
                encoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                              indexCount: submesh.indexCount,
                                              indexType: submesh.indexType,
                                              indexBuffer: submesh.indexBuffer.buffer,
                                              indexBufferOffset: submesh.indexBuffer.offset)
            }
            
            encoder.popDebugGroup()
        }
        
        encoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    private func setupEncoder(_ encoder: MTLRenderCommandEncoder, pipelineState: MTLRenderPipelineState) {
        encoder.setDepthStencilState(depthState)
        encoder.setCullMode(.back)
        encoder.setFrontFacing(.counterClockwise)
        encoder.setRenderPipelineState(pipelineState)
    }
    
    private func draw(encoder: MTLRenderCommandEncoder, meshes: [MTKMesh]) {
        for mesh in meshes {
            for (i, meshBuffer) in mesh.vertexBuffers.enumerated() {
                encoder.setVertexBuffer(meshBuffer.buffer, offset: meshBuffer.offset, index: i)
            }
            
            for submesh in mesh.submeshes {
                encoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                              indexCount: submesh.indexCount,
                                              indexType: submesh.indexType,
                                              indexBuffer: submesh.indexBuffer.buffer,
                                              indexBufferOffset: submesh.indexBuffer.offset)
            }
        }
    }
}
