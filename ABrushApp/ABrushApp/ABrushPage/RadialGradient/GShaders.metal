//
//  GShaders.metal
//  ABrushApp
//
//  Created by Apricity on 2023/7/11.
//

#include <metal_stdlib>
using namespace metal;

#include "GShaderTypes.h"

// Vertex shader outputs and fragment shader inputs
struct GRasterizerData
{
    float4 position [[position]];
//    float2 uv;
};

vertex GRasterizerData
vertexGShader(uint vertexID [[vertex_id]],
              constant GVertex *vertices [[buffer(GVertexInputIndexVertices)]],
              constant float2 *viewportSizePointer [[buffer(GVertexInputIndexViewportSize)]])
{
    GRasterizerData out;
    
    float2 pixelSpacePosition = vertices[vertexID].position.xy;
    
    float2 viewportSize = float2(*viewportSizePointer);
    
    out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = pixelSpacePosition / (viewportSize / 2.0);
    
    return out;
}

fragment half4 fragmentGShader(GRasterizerData in [[stage_in]],
                               texture2d<half> tex [[texture(0)]],
                               constant float2 *vertexPoint [[buffer(GFragmentInputIndexVertexPoint)]],
                               constant float2 *viewportSizePointer [[buffer(GFragmentInputIndexViewportSize)]])
{
    float2 viewportSize = float2(*viewportSizePointer);
    float2 pixelSpacePosition = in.position.xy - (viewportSize / 2.0);
    pixelSpacePosition.y = - pixelSpacePosition.y;
    float2 start = vertexPoint[0], end = vertexPoint[1];
    float lenSE = length(end - start), lenSP = length(pixelSpacePosition - start);
    float k = clamp(lenSP / lenSE, 0.0, 1.0); // k -> [0.0, 1.0]
    
    const half4 color = tex.read(ushort2(k * 255, 0));
    
    return color;
}

