//
//  InputController.swift
//  ShadingDemo
//
//  Created by lowe on 2018/12/2.
//  Copyright © 2018 lowe. All rights reserved.
//

import Cocoa
import GMath

enum KeyboardControl: UInt16 {
    case a =      0
    case d =      2
    case w =      13
    case s =      1
    case down =   125
    case up =     126
    case right =  124
    case left =   123
    case q =      12
    case e =      14
    case key1 =   18
    case key2 =   19
    case key0 =   29
    case space =  49
    case c =      8
}

enum InputState {
    case began, moved, ended, cancelled, continued
}

protocol KeyboardDelegate: class {
    func keyPressed(key: KeyboardControl, state: InputState) -> Bool
}

class InputController {
    var camera: Camera? {
        didSet {
            if let camera = self.camera {
                pitch = camera.currentPitch
                yaw = camera.currentYaw
            }
        }
    }
    
    var translationSpeed: Float = 0.08
    var rotationSpeed: Float = 0.005
    
    weak var keyboardDelegate: KeyboardDelegate?
    var directionKeysDown: Set<KeyboardControl> = []
    
    private var pitch: Float = 0
    private var yaw: Float = 0
    
    func updateCamera(deltaTime: Float) {
        guard let camera = self.camera else {
            return
        }

        var direction = float3()
        
        for key in directionKeysDown {
            switch key {
            case .w:
                direction.z += 1
            case .a:
                direction.x -= 1
            case .s:
                direction.z -= 1
            case .d:
                direction.x += 1
            case .up, .q:
                direction.y += 1
            case .down, .e:
                direction.y -= 1
            case .left:
                break
            case .right:
                break
            default:
                break
            }
        }
        
        if direction != [0, 0, 0] {
            var position = camera.position
            position += direction.z * camera.forwardVector * self.translationSpeed
            position += camera.rightVector * direction.x * self.translationSpeed
            position += camera.upVector * direction.y * self.translationSpeed
            
            camera.lookAt(eye: position, target: position + camera.forwardVector, up: camera.up)
        }
    }
    
    func processEvent(key: KeyboardControl, state: InputState) {
        if !(keyboardDelegate?.keyPressed(key: key, state: state) ?? true) {
            return
        }
        
        if state == .began {
            directionKeysDown.insert(key)
        }
        
        if state == .ended {
            directionKeysDown.remove(key)
        }
    }
    
    func rotate(translation: float2) {
        guard let camera = self.camera else {
            return
        }
        
        pitch += translation.y * self.rotationSpeed
        yaw += translation.x * self.rotationSpeed
        
        //TODO: 这里不能太接近90度，否则会抖动
        let maxPitch: Float = .pi / 2 - (.pi / 180) * 10
        pitch = GMath.clamp(pitch, min: -maxPitch, max: maxPitch)
        
        var cameraVec = float3()
        cameraVec.x = cos(pitch) * cos(yaw)
        cameraVec.y = sin(pitch)
        cameraVec.z = cos(pitch) * sin(yaw)
        cameraVec = cameraVec.normalize
        
        camera.lookAt(eye: camera.position, target: camera.position + cameraVec, up: camera.up)
    }
    
    func zoom(delta: CGFloat) {
        guard let camera = self.camera else {
            return
        }
        
        let degree = 180 / .pi * Float(delta) * 0.02
        camera.fovDegrees += degree
        
        if camera.fovDegrees > 70 {
            camera.fovDegrees = 70
        }
        
        if camera.fovDegrees < 2 {
            camera.fovDegrees = 2
        }
    }
}
