//
//  GSShaderTypes.h
//  ABrushApp
//
//  Created by Apricity on 2023/7/12.
//

#ifndef GSShaderTypes_h
#define GSShaderTypes_h

typedef enum GSVertexInputIndex {
    GSVertexInputIndexVertices     = 0,
    GSVertexInputIndexViewportSize = 1,
} GSVertexInputIndex;

typedef enum GSFragmentInputIndex {
    GSFragmentInputIndexViewportSize = 0,
    GSFragmentInputIndexGradientData = 1,
    GSFragmentInputIndexColorsLut    = 2,
} GSFragmentInputIndex;

typedef enum : uint32_t {
    GSGradientStyleLinear  = 0,
    GSGradientStyleRadial  = 1,
    GSGradientStyleAngular = 2,
} GSGradientStyle;

typedef struct {
    uint32_t colorSize;
    uint32_t style;
    float x1, y1,
    x2, y2,
    x3, y3;
} GSGradientData;

typedef struct {
    vector_float2 position; // 空间坐标
    vector_float2 uv; // 纹理坐标
    //    float x, y;
    //    float u, v;
} GSVertex;

#endif /* GSShaderTypes_h */
