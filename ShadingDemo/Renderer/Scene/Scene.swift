//
//  Scene.swift
//  ShadingDemo
//
//  Created by lowe on 2018/11/29.
//  Copyright © 2018 lowe. All rights reserved.
//

import MetalKit

class Scene {
    var sceneSize: CGSize
    
    var cameras = [Camera()]
    var currentCameraIndex = 0
    var camera: Camera {
        return cameras[currentCameraIndex]
    }
    
    let rootNode = Node()
    var renderables: [Renderable] = []
    var uniforms = Uniforms()
    
    var inputController = InputController()
    
    var device: MTLDevice
    
    init(sceneSize: CGSize, device: MTLDevice) {
        self.sceneSize = sceneSize
        self.device = device
        
        setupScene()
        
        sceneSizeWillChange(to: sceneSize)
    }
    
    func setupScene() {
        // override this to add objects to the scene
    }
    
    final func update(deltaTime: Float) {
        inputController.updateCamera(deltaTime: deltaTime)
        uniforms.projectionMatrix = camera.projectionMatrix
        uniforms.viewMatrix = camera.viewMatrix
        updateScene(deltaTime: deltaTime)
        update(nodes: rootNode.children, deltaTime: deltaTime)
    }
    
    private func update(nodes: [Node], deltaTime: Float) {
        for node in nodes {
            node.update(deltaTime: deltaTime)
            update(nodes: node.children, deltaTime: deltaTime)
        }
    }
    
    func updateScene(deltaTime: Float) {
        // override this to update scene
    }
    
    final func add(_ node: Node, parent: Node? = nil, render: Bool = true) {
        if let parent = parent {
            parent.add(node)
        } else {
            rootNode.add(node)
        }
        
        guard render, let renderable = node as? Renderable else {
            return
        }
        
        renderables.append(renderable)
    }
    
    final func remove(_ node: Node) {
        if let parent = node.parent {
            parent.remove(node)
        } else {
            for child in node.children {
                child.parent = nil
            }
            
            node.children = []
        }
        
        guard node is Renderable,
            let index = renderables.index(where: { $0 as? Node === node }) else {
            return
        }
        
        renderables.remove(at: index)
    }
    
    final func sceneSizeWillChange(to size: CGSize) {
        for camera in cameras {
            camera.aspect = Float(size.width / size.height)
        }
        sceneSize = size
    }
}
