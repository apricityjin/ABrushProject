//
//  ABrushTypes.h
//  ABrush
//
//  Created by Apricity on 2023/7/12.
//

#ifndef ABShaderTypes_h
#define ABShaderTypes_h

#include <simd/simd.h>

typedef struct {
//    vector_float2 pos; // 空间坐标
//    vector_float2 uv; // 纹理坐标
    float x, y;
    float u, v;
} Vertex;

//typedef struct {
//    vector_float2 start;
//    vector_float2 end;
//    uint colorSize;
//    uint type;
//} GradientData;

#endif /* ABShaderTypes_h */
