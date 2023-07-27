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
};

vertex RasterizerData
vertexShader(uint vertexID [[vertex_id]],
               constant Vertex * vertices [[buffer(VertexInputIndexVertices)]],
               constant float2 * viewportSizePointer [[buffer(VertexInputIndexViewportSize)]])
{
    RasterizerData out;
    float2 viewportSize = float2(*viewportSizePointer);
    float2 pixelSpacePosition = vertices[vertexID].position.xy;
    out.position = float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = (pixelSpacePosition / viewportSize) * 2 - 1; // y = 2 * x - 1
    out.position.y = -out.position.y;
    return out;
}

fragment float4
fragmentShader(RasterizerData in [[stage_in]],
                 constant float2 * viewportSizePointer [[buffer(FragmentInputIndexViewportSize)]],
                 constant FragmentData * fragmentData [[buffer(FragmentInputIndexData)]],
                 texture2d<half> texture [[texture(0)]])
{
    FragmentData data = *fragmentData;
    if (data.type == PaintTypeColor) {
        uint32_t color = data.c;
        return {
            ((color >>  0) & 0xFF) / 255.0,
            ((color >>  8) & 0xFF) / 255.0,
            ((color >> 16) & 0xFF) / 255.0,
            ((color >> 24) & 0xFF) / 255.0,
        };
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
        switch (gData.method) {
            case SpreadMethodRepeat:
                k = l < 0 ? l + 1.0 : l;
                break;
            case SpreadMethodReflect:
                k = fabs( l );
                break;
            case SpreadMethodPad:
            default:
                k = clamp(k, 0.0, 1.0);
                break;
        }
        constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
        half4 color = texture.sample(textureSampler, {k, 0});
        return float4(color);
    }
    else if (data.type == PaintTypeTexture) {
        TextureData tData = data.t;
        float2 pt = tData.mat * in.position.xy + tData.tranlate;
        float2 uv = pt / float2( tData.size );
        constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
        half4 colorSample = texture.sample(textureSampler, uv);
        return float4(colorSample);
    }
    else {
        return { 0, 0, 0, 0 };
    }
}
