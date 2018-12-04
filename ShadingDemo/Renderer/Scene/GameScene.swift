//
//  GameScene.swift
//  ShadingDemo
//
//  Created by lowe on 2018/12/1.
//  Copyright © 2018 lowe. All rights reserved.
//

import MetalKit

class GameScene: Scene {
    private var teapot: Prop?
    
    override func setupScene() {
        camera.position = [0, 0, 2]
        camera.lookAt(center: [0, 0, 0], up: [0, 1, 0])

        let cow = Prop(name: "spot", device: device)
        cow.position = [0, 0, 0]
        cow.scale = [2, 2, 2]
        add(cow)

        let cube = Prop(name: "cube", device: device)
        cube.position = [2, 1, 1]
        cube.scale = [0.5, 0.5, 0.5]
        add(cube)
        
        inputController.camera = camera
        
//        let dragon = DragonProp(name: "dragon", device: device)
//        dragon.position = [2, 0, 0]
//        dragon.rotation = [0, 1, 0]
//        add(dragon)
//
//        let teapot = Prop(name: "teapot", device: device)
//        teapot.position = [0, 1, 0]
//        teapot.scale = [0.2, 0.2, 0.2]
//        self.teapot = teapot
//        add(teapot)
    }
    
    override func updateScene(deltaTime: Float) {
        guard let teapot = self.teapot else {
            return
        }
        
        if teapot.position.x > 2 {
            sign = -1
        }
        
        if teapot.position.x < -2 {
            sign = 1
        }
        
        teapot.position.x += sign * 0.01
        
        teapot.rotation += float3(sign * 0.01)
    }
    
    private var sign: Float = 1
}
