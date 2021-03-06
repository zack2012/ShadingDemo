//
//  Test.metal
//  ShadingDemo
//
//  Created by lowe on 2018/11/18.
//  Copyright © 2018 lowe. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "Common.h"

struct VertexInput {
    float3 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
    float2 uv [[attribute(2)]];
    float2 tangent [[attribute(3)]];
    float2 bitangent [[attribute(4)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 worldPosition;
    float3 worldNormal;
    float2 uv;
};

vertex VertexOut mainVertex(VertexInput in [[stage_in]],
                               constant Uniforms &uniforms [[buffer(10)]]
                               ) {
    VertexOut vertexOut;
    
    vertexOut.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * float4(in.position, 1);
    vertexOut.uv = in.uv;
    
    return vertexOut;
}

fragment float4 mainFragment(VertexOut inVertex [[stage_in]],
                             texture2d<float> baseColorTexture [[texture(0)]],
                             texture2d<float> normalTexture [[texture(1)]],
                             texture2d<float> roughnessTexture [[texture(2)]]
                             ) {
    constexpr sampler baseColorSampler(filter::nearest, address::repeat);
    float3 baseColor = baseColorTexture.sample(baseColorSampler, inVertex.uv).rgb;
    return float4(baseColor, 1);
//    float3 world = inVertex.worldPosition;
//    float3 normal = normalize(inVertex.worldNormal);
//
//    float3 lightPosition = float3(10, 10, 10);
//
//    // 指向光源的单位向量
//    float3 lightVec = normalize(lightPosition - world.xyz);
//
//    float cosValue = max(0.0, dot(normal, lightVec));
//    float3 cosVec = float3(cosValue, cosValue, cosValue);
//
//    // 环境光系数
//    float3 ca = float3(0.2, 0.2, 0.2);
//    float3 la = float3(0.8, 0.8, 0.8);
//
//    // 镜面反射系数
//    float3 cr = float3(0.7, 0.7, 0.7);
//    float3 lr = float3(0.8, 0.8, 0.8);
//
//    uint p = 32;
//    float3 viewer = float3(3, 3, 10);
//    float3 e = normalize(viewer - world.xyz);
//    float len = length(lightVec + e);
//    float3 h = (lightVec + e) / len;
//    float rcosValue = max(0.0, dot(h, normal));
//    float3 rcosVec = float3(rcosValue);
//
//    constexpr sampler textureSampler(filter::nearest, address::repeat);
//    float3 baseColor = baseColorTexture.sample(textureSampler, inVertex.uv).rgb;
//
//    float3 color = ca * la + baseColor * float3(0.8, 0.8, 0.8) * cosVec + cr * lr * pow(rcosVec, p);
//    // 颜色范围要在0～1之间
//    return saturate(float4(color, 1));
}
