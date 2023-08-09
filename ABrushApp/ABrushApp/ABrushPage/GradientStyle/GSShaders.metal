//
//  GSShaders.metal
//  ABrushApp
//
//  Created by Apricity on 2023/7/12.
//

#include <metal_stdlib>
using namespace metal;

#include "ShaderTypes.h"

struct RasterizerData {
    float4 position [[position]];
    float alpha;
};

vertex RasterizerData
vertexShader(uint vertexID [[vertex_id]],
               constant Vertex * vertices [[buffer(VertexInputIndexVertices)]],
               constant float2 * viewportSizePointer [[buffer(VertexInputIndexViewportSize)]])
{
//    RasterizerData out;
//    float2 viewportSize = float2(*viewportSizePointer);
//    float2 pixelSpacePosition = vertices[vertexID].position.xy;
//    out.position = float4(0.0, 0.0, 0.0, 1.0);
//    out.position.xy = (pixelSpacePosition / viewportSize) * 2 - 1; // y = 2 * x - 1
//    out.position.y = -out.position.y;
//    return out;
    RasterizerData out;
    float2 viewportSize = float2(*viewportSizePointer);
    Vertex vtx = vertices[vertexID];
    float2 pixelSpacePosition = vtx.position.xy;
    out.position = float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = (pixelSpacePosition / viewportSize) * 2 - 1; // y = 2 * x - 1
    out.position.y = -out.position.y;
    out.alpha = vtx.alpha;
    return out;
}

fragment float4
fragmentShader(RasterizerData in [[stage_in]],
                 constant float2 * viewportSizePointer [[buffer(FragmentInputIndexViewportSize)]],
                 constant FragmentData * fragmentData [[buffer(FragmentInputIndexData)]],
                 texture2d<float> texture [[texture(0)]])
{
    FragmentData data = *fragmentData;
    if (data.type == PaintTypeColor) {
        uint32_t c = data.c;
        float4 color = {
            ((c >>  0) & 0xFF) / 255.0,
            ((c >>  8) & 0xFF) / 255.0,
            ((c >> 16) & 0xFF) / 255.0,
            ((c >> 24) & 0xFF) / 255.0,
        };
        return float4(color.xyz, in.alpha);
    }
    else if (data.type == PaintTypeGradient) {
        GradientData gData = data.g;
        float2 pt = float2x2(gData.mat) * in.position.xy + gData.tranlate;
        float k;
        switch (gData.type) {
            case GradientTypeLinear:
                k = pt.x;
                break;
            case GradientTypeRadial:
                k = length(pt);
                break;
            case GradientTypeAngular:
                k = atan2(pt.y, pt.x) / (M_PI_F * 2) + 0.5;
                break;
            case GradientTypeDiamond:
                k = max(abs(pt.x), abs(pt.y));
                break;
            default:
                k = 0.0;
                break;
        }
        float l = fmod(k, 1.0);
        constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
        float4 color = texture.sample(textureSampler, {k, static_cast<float>(gData.colorLuTIdx)});
//        return color;
        return float4(color.xyz, color.w * in.alpha);
    }
    else if (data.type == PaintTypeTexture) {
        TextureData tData = data.t;
        float2 pt = tData.mat * in.position.xy + tData.tranlate;
        float2 uv = pt / float2( tData.size );
        constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
        float4 color = texture.sample(textureSampler, uv);
//        return color;
        return float4(color.xyz, in.alpha);
    }
    else {
        return { 0, 0, 0, 0 };
    }
}
