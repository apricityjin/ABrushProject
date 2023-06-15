//
//  DMShaders.metal
//  DemoMetal
//
//  Created by apricity on 2023/5/30.
//

#include <metal_stdlib>
using namespace metal;

#include "DMShaderTypes.h"

// Vertex shader outputs and fragment shader inputs
struct RasterizerData
{
    float4 position [[position]];
    float2 texture;
};

vertex RasterizerData
vertexShader(uint vertexID [[vertex_id]],
             constant DMVertext *vertices [[buffer(0)]])
{
    RasterizerData out;
    out.position = vertices[vertexID].position;
    out.texture = vertices[vertexID].texture;
    return out;
}

fragment float4
fragmentShader(RasterizerData in [[stage_in]],
               texture2d<half> texture [[texture(0)]])
{
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear); // sampler是采样器
    
    half4 colorSample = texture.sample(textureSampler, in.texture); // 得到纹理对应位置的颜色
    
    return float4(colorSample);
}
