//
//  GSShaders.metal
//  ABrushApp
//
//  Created by Apricity on 2023/7/12.
//

#include <metal_stdlib>
using namespace metal;

#include "GSShaderTypes.h"

struct GSRasterizerData {
    float4 position [[position]];
};

vertex GSRasterizerData
vertexGSShader(uint vertexID [[vertex_id]],
               constant GSVertex * vertices [[buffer(GSVertexInputIndexVertices)]],
               constant float2 * viewportSizePointer [[buffer(GSVertexInputIndexViewportSize)]])
{
    GSRasterizerData out;
    float2 viewportSize = float2(*viewportSizePointer);
    float2 pixelSpacePosition = vertices[vertexID].position.xy;
    out.position = float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = (pixelSpacePosition / viewportSize) * 2 - 1; // y = 2 * x - 1
    out.position.y = -out.position.y;
    return out;
}

fragment float4
fragmentGSShader(GSRasterizerData in [[stage_in]],
                 constant float2 * viewportSizePointer [[buffer(GSFragmentInputIndexViewportSize)]],
                 constant GSGradientData * gradientData [[buffer(GSFragmentInputIndexGradientData)]],
                 constant uint32_t * colorsLut [[buffer(GSFragmentInputIndexColorsLut)]])
{
    GSGradientData data = *gradientData;
//    float2 pt = in.position.xy * float2x2(data.sx, data.shy, data.shx, data.sx) + float2(data.tx, data.ty);
    float2 pt = in.position.xy * data.mat + data.tranlate;
    float k;
    switch (data.style) {
        case GSGradientStyleLinear:
            k = pt.x;
            break;
        case GSGradientStyleRadial:
            k = length(pt);
            break;
        case GSGradientStyleAngular:
            k = atan2(pt.y, pt.x) / (M_PI_F * 2) + 0.5;
            break;
        case GSGradientStyleDiamond:
            k = max(abs(pt.x), abs(pt.y));
            break;
        default:
            k = 0.0;
            break;
    }
    k = clamp(k, 0.0, 1.0);
    uint32_t c = *((colorsLut + (uint32_t)(k * (gradientData->colorSize - 1))));
    return {
        (((c      ) & 0xFF) / 255.0),
        (((c >>  8) & 0xFF) / 255.0),
        (((c >> 16) & 0xFF) / 255.0),
        (((c >> 24) & 0xFF) / 255.0),
    };
}
