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
            throw Err.isNil(message: "MTLDevice is nil")
        }
        
        guard let commandQueue = device.makeCommandQueue() else {
            throw Err.isNil(message: "makeCommandQueue is nil")
        }
        
        self.device = device
        self.commandQueue = commandQueue
        
        let pipelineDesc = MTLRenderPipelineDescriptor()
        
        let library = device.makeDefaultLibrary()
        let vertexFunc = library?.makeFunction(name: "testVertex")
        let fragmentFunc = library?.makeFunction(name: "testFragment")
        pipelineDesc.vertexFunction = vertexFunc
        pipelineDesc.fragmentFunction = fragmentFunc
        
        let mtlVertexDesc = MTLVertexDescriptor()
        
        // position
        mtlVertexDesc.attributes[0].format = .float3
        mtlVertexDesc.attributes[0].offset = 0
        mtlVertexDesc.attributes[0].bufferIndex = 0
        
        // normal
        mtlVertexDesc.attributes[1].format = .float3
        mtlVertexDesc.attributes[1].offset = 12
        mtlVertexDesc.attributes[1].bufferIndex = 0
        
        mtlVertexDesc.layouts[0].stride = 24
        mtlVertexDesc.layouts[0].stepFunction = .perVertex
        
        pipelineDesc.vertexDescriptor = mtlVertexDesc
        pipelineDesc.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        
        pipelineDesc.depthAttachmentPixelFormat = mtkView.depthStencilPixelFormat
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDesc)
        
        let depthStateDesc = MTLDepthStencilDescriptor()
        depthStateDesc.depthCompareFunction = .less
        depthStateDesc.isDepthWriteEnabled = true
        depthState = device.makeDepthStencilState(descriptor: depthStateDesc)
        
        let mdlVertexDesc = try! MTKModelIOVertexDescriptorFromMetalWithError(mtlVertexDesc)
        
        // attribute.name must be set, or draw call will failed
        var attribute = mdlVertexDesc.attributes[0] as! MDLVertexAttribute
        attribute.name = MDLVertexAttributePosition
        
        attribute = mdlVertexDesc.attributes[1] as! MDLVertexAttribute
        attribute.name = MDLVertexAttributeNormal
        
        let bufferAlloctor = MTKMeshBufferAllocator(device: device)
        let bundle = Bundle.main
        let url = bundle.url(forResource: "spot", withExtension: "obj")!
        let cow = MDLAsset(url: url, vertexDescriptor: mdlVertexDesc, bufferAllocator: bufferAlloctor)
        
        (_, self.cowMeshes) = try! MTKMesh.newMeshes(asset: cow, device: device)
        
        super.init()
        
        camera.position = [3, 3, 5]
        camera.lookAt(center: [0, 0, 0], up: [0, 1, 0])
        mtkView.delegate = self
    }
    
    var pipelineState: MTLRenderPipelineState!
    var depthState: MTLDepthStencilState!
    private var cowMeshes: [MTKMesh]
    var uniforms = Uniforms()

    var camera = Camera()
    
    func rotate(translation: float2, sensitivity: Float = 0.01) {
        camera.position = Math.rotation(axis: [0, 1, 0], angle: -translation.x * sensitivity).upperLeft * camera.position
    }
    
    func zoom(delta: CGFloat, sensitivity: Float = 0.1) {
        let cameraVector = camera.modelMatrix.columns.3.xyz
        camera.position += Float(delta) * sensitivity * cameraVector
    }
    
    private var device: MTLDevice
    private var commandQueue: MTLCommandQueue
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        camera.aspect = Float(size.width / size.height)
    }
    
    func draw(in view: MTKView) {
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
        
        setupEncoder(encoder, pipelineState: pipelineState)
        
        uniforms.projectionMatrix = camera.projectionMatrix
        uniforms.viewMatrix = camera.viewMatrix
        let node = Node()
        node.scale = [1, 1, 1]
        node.position = [1, 0, 0]
        uniforms.modelMatrix = node.modelMatrix
        uniforms.normalMatrix = node.modelMatrix.upperLeft
        
        encoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
        
        draw(encoder: encoder, meshes: self.cowMeshes)
        
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

extension Renderer {
    enum Err: Swift.Error {
        case isNil(message: String)
    }
}
