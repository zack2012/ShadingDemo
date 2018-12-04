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
            
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
                self.keyDown(with: $0)
                return nil
            }
            
            NSEvent.addLocalMonitorForEvents(matching: .keyUp) {
                self.keyUp(with: $0)
                return nil
            }
            
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

        renderer?.scene?.inputController.rotate(translation: translation)
        gesture.setTranslation(.zero, in: gesture.view)
    }
    
    override func scrollWheel(with event: NSEvent) {
        renderer?.scene?.inputController.zoom(delta: event.deltaY)
    }
    
    override func keyDown(with event: NSEvent) {
        guard let key = KeyboardControl(rawValue: event.keyCode) else {
            return
        }
        
        let state: InputState = event.isARepeat ? .continued : .began
        renderer?.scene?.inputController.processEvent(key: key, state: state)
    }
    
    override func keyUp(with event: NSEvent) {
        guard let key = KeyboardControl(rawValue: event.keyCode) else {
            return
        }
        
        renderer?.scene?.inputController.processEvent(key: key, state: .ended)
    }
}

