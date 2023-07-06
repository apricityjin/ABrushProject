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
};

vertex ARasterizerData
vertexAShader(uint vertexID [[vertex_id]],
             constant AVertex *vertices [[buffer(AVertexInputIndexVertices)]],
             constant vector_float2 *viewportSizePointer [[buffer(AVertexInputIndexViewportSize)]])
{
    ARasterizerData out;
    
    float2 pixelSpacePosition = vertices[vertexID].position.xy;
    
    vector_float2 viewportSize = vector_float2(*viewportSizePointer);
    
    out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = pixelSpacePosition / (viewportSize / 2.0);
    
    return out;
}


fragment float4
fragmentAShader(ARasterizerData in [[stage_in]])
{
    
    return {255, 0, 255, 0};
}
