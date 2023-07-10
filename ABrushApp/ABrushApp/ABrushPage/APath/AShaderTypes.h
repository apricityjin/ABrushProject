//
//  ShaderTypes.h
//  ABrushApp
//
//  Created by Apricity on 2023/7/6.
//

#ifndef AShaderTypes_h
#define AShaderTypes_h

#include <simd/simd.h>

typedef enum AVertexInputIndex
{
    AVertexInputIndexVertices     = 0,
    AVertexInputIndexViewportSize = 1,
    AVertexInputIndexVertexPoint  = 2,
} AVertexInputIndex;

typedef struct AVertex
{
    vector_float2 position;
//    vector_float2 uv;
} AVertex;

#endif /* ShaderTypes_h */
