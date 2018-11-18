//
//  Common.h
//  ShadingDemo
//
//  Created by lowe on 2018/11/18.
//  Copyright © 2018 lowe. All rights reserved.
//

#ifndef Common_h
#define Common_h

#import <simd/simd.h>

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
    matrix_float3x3 normalMatrix;
} Uniforms;

#endif /* Common_h */
