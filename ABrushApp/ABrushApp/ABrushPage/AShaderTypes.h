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
} AVertexInputIndex;

typedef enum AFragmentInputIndex
{
    AFragmentInputIndexColorsLut     = 0,
} AFragmentInputIndex;

typedef struct{
    vector_float2 position;
//    float u,v;
} AVertex;

#endif /* ShaderTypes_h */
