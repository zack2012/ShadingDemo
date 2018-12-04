//
//  InputController.swift
//  ShadingDemo
//
//  Created by lowe on 2018/12/2.
//  Copyright © 2018 lowe. All rights reserved.
//

import Cocoa
import Math

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
    var camera: Camera?
    
    var translationSpeed: Float = 2
    var rotationSpeed: Float = 1.0
    
    weak var keyboardDelegate: KeyboardDelegate?
    var directionKeysDown: Set<KeyboardControl> = []
    
    private var cameraFront: float3 = [0, 0, -1]
    
    func updateCamera(deltaTime: Float) {
        guard let camera = self.camera else {
            return
        }
        
        let translationSpeed = deltaTime * self.translationSpeed
        let rotationSpeed = deltaTime * self.rotationSpeed
        
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
            case .left, .q:
                direction.y += 1
            case .right, .e:
                direction.y -= 1
            default:
                break
            }
        }
        
        if direction != [0, 0, 0] {
            let cameraVec = cameraFront
            camera.position += direction.z * cameraVec * 0.1
            camera.position += cameraVec.cross(camera.up).normalize * direction.x * 0.1
            camera.lookAt(center: camera.position + cameraVec, up: camera.up)
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
    
    var pitch: Float = 0
    var yaw: Float = 0
    
    func rotate(translation: float2) {
        guard let camera = self.camera else {
            return
        }
        
        pitch += translation.y * 0.01
        yaw += translation.x * 0.01
        
        if pitch > .pi / 2 - 0.1 {
            pitch = .pi / 2 - 0.1
        }
        
        if pitch < -.pi / 2 + 0.1 {
            pitch = -.pi / 2 + 0.1
        }
        
        cameraFront.x = cos(pitch) * cos(yaw)
        cameraFront.y = sin(pitch)
        cameraFront.z = cos(pitch) * sin(yaw)
        cameraFront = cameraFront.normalize
        
        let cameraVec = cameraFront
        camera.lookAt(center: camera.position + cameraVec, up: camera.up)
    }
    
    func zoom(delta: CGFloat) {
        guard let camera = self.camera else {
            return
        }
        
        let cameraVector = camera.modelMatrix.columns.3.xyz
        camera.position += Float(delta) * 0.1 * cameraVector
    }
}
