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
    float4 color;
    float2 pixelSpacePosition = in.position.xy,
    start = float2(data.x1, data.y1),
    end = float2(data.x2, data.y2),
    cp = float2(data.x3, data.y3), // control point
    SE = end - start,
    SV = pixelSpacePosition.xy - start, // SE: start -> end SV: start -> vertex
    SC = cp - start;
    float k = 0;
    if (data.style == 0) {
        float lenAB = length(SE);
        float costheta = SE.x / lenAB, sintheta = SE.y / lenAB;
        k = clamp((SV.x * costheta + SV.y * sintheta) / lenAB, 0.0, 1.0); // k -> [0.0, 1.0]
    } else if (data.style == 1) {
        
        float lenSE = length(SE),
        lenSC = length(SC);
        
        float a = dot(SV, SE) / lenSE / lenSE,
        b = dot(SV, SC) / lenSC / lenSC;
        
        k = clamp(sqrt(a * a + b * b), 0.0, 1.0); // k -> [0.0, 1.0]
        
        
    } else if (data.style == 2) {
        float theta = atan2(SV.y, SV.x) - atan2(SE.y, SE.x);
        if (theta < 0) {
            theta += 2 * M_PI_F;
        }
        k = clamp(theta / (2 * M_PI_F), 0.0, 1.0); // k -> [0.0, 1.0]
    } else {
        color = float4(0);
    }
    uint32_t c = *((colorsLut + (uint32_t)(k * (gradientData->colorSize - 1))));
    return {
        (((c      ) & 0xFF) / 255.0),
        (((c >>  8) & 0xFF) / 255.0),
        (((c >> 16) & 0xFF) / 255.0),
        (((c >> 24) & 0xFF) / 255.0),
    };
}
