//
//  AGShaderTypes.h
//  ABrushApp
//
//  Created by Apricity on 2023/7/11.
//

#ifndef AGShaderTypes_h
#define AGShaderTypes_h

#include <simd/simd.h>

typedef enum AGVertexInputIndex
{
    AGVertexInputIndexVertices     = 0,
    AGVertexInputIndexViewportSize = 1,
} AGVertexInputIndex;

typedef enum AGFragmentInputIndex
{
    AGFragmentInputIndexVertexPoint  = 0,
    AGFragmentInputIndexViewportSize = 1,
} AGFragmentInputIndex;

typedef struct AGVertex
{
    vector_float2 position;
        vector_float2 uv;
} AGVertex;

#endif /* AGShaderTypes_h */

