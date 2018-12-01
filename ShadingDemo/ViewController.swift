//
//  ViewController.swift
//  ShadingDemo
//
//  Created by lowe on 2018/11/17.
//  Copyright © 2018 lowe. All rights reserved.
//

import Cocoa
import MetalKit
import Math

class ViewController: NSViewController {

    private var renderer: Renderer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        guard let metalView = view as? MTKView else {
            fatalError("metal view must set in storyboard")
        }
        
        let device = MTLCreateSystemDefaultDevice()
        metalView.device = device
        metalView.depthStencilPixelFormat = .depth32Float
        
        do {
            renderer = try Renderer(mtkView: metalView)
            let gameScene = GameScene(sceneSize: metalView.bounds.size, device: renderer.device)
            renderer.scene = gameScene
            addGesture(to: metalView)
        } catch {
            print(error)
        }
    }

    func addGesture(to view: NSView) {
        let pan = NSPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        view.addGestureRecognizer(pan)
    }
    
    @objc func handlePan(gesture: NSPanGestureRecognizer) {
        let translation: float2 = [
            Float(gesture.translation(in: gesture.view).x),
            Float(gesture.translation(in: gesture.view).y)
        ]

        rotate(translation: translation)
        gesture.setTranslation(.zero, in: gesture.view)
    }
    
    override func scrollWheel(with event: NSEvent) {
        let sensitivity: Float = 0.01
        zoom(delta: event.deltaY, sensitivity: sensitivity)
    }
    
    func rotate(translation: float2, sensitivity: Float = 0.01) {
        guard let camera = renderer.scene?.camera else {
            return
        }
        
        camera.position = Math.rotation(axis: [0, 1, 0], angle: -translation.x * sensitivity).upperLeft * camera.position
    }
    
    func zoom(delta: CGFloat, sensitivity: Float = 0.1) {
        guard let camera = renderer.scene?.camera else {
            return
        }
        
        let cameraVector = camera.modelMatrix.columns.3.xyz
        camera.position += Float(delta) * sensitivity * cameraVector
    }
}

