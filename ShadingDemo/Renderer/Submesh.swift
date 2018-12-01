//
//  Submesh.swift
//  ShadingDemo
//
//  Created by lowe on 2018/11/30.
//  Copyright © 2018 lowe. All rights reserved.
//

import MetalKit

protocol LoadTexturable {}

extension LoadTexturable {
    static func loadTexture(imageName: String, device: MTLDevice) throws -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: device)
        let textureLoaderOptions: [MTKTextureLoader.Option: Any] = [
            .origin: MTKTextureLoader.Origin.bottomLeft,
            .SRGB: false,
            .generateMipmaps: NSNumber(booleanLiteral: true)
        ]
        
        let fileExtension = URL(fileURLWithPath: imageName).pathExtension.isEmpty ? "png" : nil
        
        guard let url = Bundle.main.url(forResource: imageName, withExtension: fileExtension) else {
            return try textureLoader.newTexture(name: imageName,
                                                scaleFactor: 1,
                                                bundle: Bundle.main,
                                                options: nil)
        }
        
        let texture = try textureLoader.newTexture(URL: url,
                                                   options: textureLoaderOptions)
        
        return texture
    }
}

final class Submesh {
    let textures: Textures
    var material: Material
    var submesh: MTKSubmesh
    
    init(submesh: MTKSubmesh, mdlSubmesh: MDLSubmesh, device: MTLDevice) {
        self.submesh = submesh
        textures = Textures(material: mdlSubmesh.material, device: device)
        material = Material(material: mdlSubmesh.material)
    }
    
    func makeFunctionConstants() -> MTLFunctionConstantValues {
        let functionConstants = MTLFunctionConstantValues()
        
        var property = false
        
        for (i, texture) in [textures.baseColor, textures.normal, textures.roughtness].enumerated() {
            property = texture != nil
            functionConstants.setConstantValue(&property, type: .bool, index: i)
        }
        
        property = false
        functionConstants.setConstantValue(&property, type: .bool, index: 3)
        functionConstants.setConstantValue(&property, type: .bool, index: 4)
        
        return functionConstants
    }
}

extension Submesh {
    struct Textures: LoadTexturable {
        let baseColor: MTLTexture?
        let normal: MTLTexture?
        let roughtness: MTLTexture?
    }
}

private extension Submesh.Textures {
    init(material: MDLMaterial?, device: MTLDevice) {
        func property(semantic: MDLMaterialSemantic) -> MTLTexture? {
            guard let property = material?.property(with: semantic), property.type == .string,
                let filename = property.stringValue,
                let texture = try? Submesh.Textures.loadTexture(imageName: filename, device: device) else {
                    return nil
            }
            
            return texture
        }
        
        baseColor = property(semantic: .baseColor)
        normal = property(semantic: .tangentSpaceNormal)
        roughtness = property(semantic: .roughness)
    }
}

private extension Material {
    init(material: MDLMaterial?) {
        self.init()
        
        if let baseColor = material?.property(with: .baseColor),
            baseColor.type == .float3 {
            self.baseColor = baseColor.float3Value
        }
        
        if let specular = material?.property(with: .specular),
            specular.type == .float3 {
            self.specularColor = specular.float3Value
        }
        
        if let shininess = material?.property(with: .specularExponent),
            shininess.type == .float {
            self.shininess = shininess.floatValue
        }
        
        if let roughness = material?.property(with: .roughness),
            roughness.type == .float {
            self.roughness = roughness.floatValue
        }
    }
}
