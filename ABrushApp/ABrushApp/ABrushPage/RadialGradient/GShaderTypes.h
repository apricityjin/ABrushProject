//
//  GShaderTypes.h
//  ABrushApp
//
//  Created by Apricity on 2023/7/11.
//

#ifndef GShaderTypes_h
#define GShaderTypes_h

#include <simd/simd.h>

typedef enum GVertexInputIndex
{
    GVertexInputIndexVertices     = 0,
    GVertexInputIndexViewportSize = 1,
} GVertexInputIndex;

typedef enum GFragmentInputIndex
{
    GFragmentInputIndexVertexPoint  = 0,
    GFragmentInputIndexViewportSize = 1,
} GFragmentInputIndex;



typedef struct GVertex
{
    vector_float2 position;
        vector_float2 uv;
} GVertex;

#endif /* GShaderTypes_h */
