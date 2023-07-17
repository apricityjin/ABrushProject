//
//  TIShaders.metal
//  ABrushApp
//
//  Created by Apricity on 2023/7/17.
//

#include <metal_stdlib>
using namespace metal;

#include "TIShaderTypes.h"

struct TIRasterizerData {
    float4 position [[position]];
    float2 uv;
};

vertex TIRasterizerData
vertexTIShader(uint vertexID [[vertex_id]],
               constant TIVertex * vertices [[buffer(TIVertexInputIndexVertices)]],
               constant float2 * viewportSizePointer [[buffer(TIVertexInputIndexViewportSize)]])
{
    TIRasterizerData out;
    float2 viewportSize = float2(*viewportSizePointer);
    float2 pixelSpacePosition = vertices[vertexID].position.xy;
    out.position = float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = (pixelSpacePosition / viewportSize) * 2 - 1; // y = 2 * x - 1
    out.position.y = -out.position.y;
    out.uv = vertices[vertexID].uv;
    return out;
}

fragment half4
fragmentTIShader(TIRasterizerData in [[stage_in]],
                 constant float2 * viewportSizePointer [[buffer(TIFragmentInputIndexViewportSize)]],
                 constant TIImageData * imageData [[buffer(TIFragmentInputIndexImageData)]],
                 texture2d<half> texture [[texture(0)]])
{
    TIImageData data = *imageData;
    //    float2 pt = in.position.xy * float2x2(data.sx, data.shy, data.shx, data.sx) + float2(data.tx, data.ty);
    float2 pt = in.position.xy * data.mat + data.tranlate;
    
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear); // sampler是采样器
    
    half4 colorSample = texture.sample(textureSampler, in.uv); // 得到纹理对应位置的颜色
    
    return colorSample;
}
