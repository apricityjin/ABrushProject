//
//  ABrushTypes.h
//  ABrush
//
//  Created by Apricity on 2023/7/12.
//

#ifndef ABShaderTypes_h
#define ABShaderTypes_h

#include <simd/simd.h>

typedef enum : uint32_t {
    GradientStyleLinear  = 0,
    GradientStyleRadial  = 1,
    GradientStyleAngular = 2,
    GradientStyleDiamond = 3,
} GradientStyle;

typedef struct {
//    vector_float2 pos; // 空间坐标
//    vector_float2 uv; // 纹理坐标
    float x, y;
    float u, v;
} Vertex;

typedef struct {
    uint32_t colorSize;
    uint32_t style; // GradientStyle
    union {
        struct {
            float sx, shy,
            shx, sy,
            tx, ty;
        };
        struct {
            simd_float2x2 mat;
            simd_float2 tranlate;
        };
    }; // 内存对齐
} GradientData;

#endif /* ABShaderTypes_h */
