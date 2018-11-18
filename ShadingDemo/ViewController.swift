//
//  ViewController.swift
//  ShadingDemo
//
//  Created by lowe on 2018/11/17.
//  Copyright © 2018 lowe. All rights reserved.
//

import Cocoa
import MetalKit

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

        renderer?.rotate(translation: translation)
        gesture.setTranslation(.zero, in: gesture.view)
    }
    
    override func scrollWheel(with event: NSEvent) {
        let sensitivity: Float = 0.01
        renderer?.zoom(delta: event.deltaY, sensitivity: sensitivity)
    }
}

