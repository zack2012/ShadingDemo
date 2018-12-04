//
//  Node.swift
//  ShadingDemo
//
//  Created by lowe on 2018/11/17.
//  Copyright © 2018 lowe. All rights reserved.
//

import MetalKit
import GMath

class Node {
    var name = ""
    var position: float3 = [0, 0, 0]
    var rotation: float3 = [0, 0, 0]
    var scale: float3 = [1, 1, 1]
    
    weak var parent: Node?
    var children: [Node] = []
    
    var modelMatrix: float4x4 {
        let translateMatrix = GMath.translate(position)
        let rotateMatrix = GMath.rotation(rotation)
        let scaleMatrix = GMath.scale(scale)
        
        return translateMatrix * rotateMatrix * scaleMatrix
    }
    
    var worldTransform: float4x4 {
        if let parent = parent {
            return parent.worldTransform * modelMatrix
        }
        
        return modelMatrix
    }
        
    var normalMatrix: float3x3 {
        return modelMatrix.upperLeft
    }
    
    final func add(_ node: Node) {
        children.append(node)
        node.parent = self
    }
    
    final func remove(_ node: Node) {
        // 将要移除的子节点的所有子节点添加到当前节点
        for child in node.children {
            child.parent = self
            children.append(child)
        }
        
        node.children = []
        
        guard let index = children.index(where: { $0 === node }) else {
            return
        }
        
        children.remove(at: index)
        node.parent = nil
    }
    
    func update(deltaTime: Float) {
        // override this to update node
    }
}
