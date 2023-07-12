//
//  Shaders.metal
//  ABrushApp
//
//  Created by Apricity on 2023/7/6.
//

#include <metal_stdlib>
using namespace metal;

#include "AShaderTypes.h"

// Vertex shader outputs and fragment shader inputs
struct ARasterizerData
{
    float4 position [[position]];
    float2 uv;
};

vertex ARasterizerData
vertexAShader(uint vertexID [[vertex_id]],
              constant AVertex *vertices [[buffer(AVertexInputIndexVertices)]],
              constant vector_float2 *viewportSizePointer [[buffer(AVertexInputIndexViewportSize)]],
              constant float2 *vertexPoint [[buffer(AVertexInputIndexVertexPoint)]])
{
    ARasterizerData out;
    
    float2 pixelSpacePosition = vertices[vertexID].position.xy;
    
    vector_float2 viewportSize = vector_float2(*viewportSizePointer);
    
    out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = pixelSpacePosition / (viewportSize / 2.0);
    
    float2 start = vertexPoint[0], end = vertexPoint[1];
    float2 SE = end - start, SV = pixelSpacePosition.xy - start; // SE: start -> end SV: start -> vertex
    float lenAB = length(SE);
    float costheta = SE.x / lenAB, sintheta = SE.y / lenAB;
    
    float k = clamp((SV.x * costheta + SV.y * sintheta) / lenAB, 0.0, 1.0); // k -> [0.0, 1.0]
    
    out.uv = vector_float2(k, 0.0);
    
    return out;
}

fragment half4 fragmentAShader(ARasterizerData in [[stage_in]],
                               texture2d<half> tex [[texture(0)]])
{
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear);
    const half4 color = tex.sample(textureSampler, in.uv);
    return color;
}
