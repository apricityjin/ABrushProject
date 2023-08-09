//
//  GSShaderTypes.h
//  ABrushApp
//
//  Created by Apricity on 2023/7/12.
//

#ifndef GSShaderTypes_h
#define GSShaderTypes_h

#include <simd/simd.h>

typedef enum VertexInputIndex {
    VertexInputIndexVertices        = 0,
    VertexInputIndexViewportSize    = 1,
} VertexInputIndex;

typedef enum FragmentInputIndex {
    FragmentInputIndexViewportSize    = 0,
    FragmentInputIndexData            = 1,
} FragmentInputIndex;

typedef enum : int {
    PaintTypeColor              = 0,
    PaintTypeGradient           = 1,
    PaintTypeTexture            = 2,
} PaintType;

typedef enum : int {
    GradientTypeLinear       = 0,
    GradientTypeRadial       = 1,
    GradientTypeAngular      = 2,
    GradientTypeDiamond      = 3,
} GradientType;

typedef enum : int {
    SpreadMethodPad        = 0,
    SpreadMethodReflect    = 1,
    SpreadMethodRepeat     = 2,
} SpreadMethod;

typedef struct GradientData {
//    int method; // SpreadMethod
    int type; // GradientType
    int colorLuTIdx;
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
    };
} GradientData;

typedef struct TextureData {
    union {
        struct {
            int width;
            int height;
        };
        simd_int2 size;
    };
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
    };
} TextureData;


typedef struct FragmentData {
    int type; // PaintType
    union {
        uint32_t c;
        GradientData g;
        TextureData t;
    };
} FragmentData;

typedef struct {
    vector_float2 position; // 空间坐标
    float alpha;
    float z;
} Vertex;

#endif /* GSShaderTypes_h */
