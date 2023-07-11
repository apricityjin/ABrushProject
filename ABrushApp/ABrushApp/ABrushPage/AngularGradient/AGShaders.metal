//
//  AGShaders.metal
//  ABrushApp
//
//  Created by Apricity on 2023/7/11.
//

#include <metal_stdlib>
using namespace metal;

#include "AGShaderTypes.h"

// Vertex shader outputs and fragment shader inputs
struct AGRasterizerData
{
    float4 position [[position]];
    //    float2 uv;
};

vertex AGRasterizerData
vertexAGShader(uint vertexID [[vertex_id]],
              constant AGVertex *vertices [[buffer(AGVertexInputIndexVertices)]],
              constant float2 *viewportSizePointer [[buffer(AGVertexInputIndexViewportSize)]])
{
    AGRasterizerData out;
    
    float2 viewportSize = float2(*viewportSizePointer);
    float2 pixelSpacePosition = vertices[vertexID].position.xy;
    // 转化关系为 y = 2 * x - 1
    
    out.position = float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = (pixelSpacePosition / viewportSize) * 2 - 1;
    out.position.y = -out.position.y;
    return out;
}

fragment half4 fragmentAGShader(AGRasterizerData in [[stage_in]],
                               texture2d<half> tex [[texture(0)]],
                               constant float2 *vertexPoint [[buffer(AGFragmentInputIndexVertexPoint)]],
                               constant float2 *viewportSizePointer [[buffer(AGFragmentInputIndexViewportSize)]])
{
//    float2 viewportSize = float2(*viewportSizePointer);
    float2 pixelSpacePosition = in.position.xy;
    float2 start = vertexPoint[0], end = vertexPoint[1];
    float2 SE = end - start, SP = pixelSpacePosition - start;
    float theta = atan2(SP.y, SP.x) - atan2(SE.y, SE.x);
    if (theta < 0) {
        theta += 2 * M_PI_F;
    }
    float k = clamp(theta / (2 * M_PI_F), 0.0, 1.0); // k -> [0.0, 1.0]
    const half4 color = tex.read(ushort2(k * 255, 0));
    return color;
}

