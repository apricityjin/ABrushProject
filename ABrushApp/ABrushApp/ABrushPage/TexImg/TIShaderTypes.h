//
//  TIShaderTypes.h
//  ABrushApp
//
//  Created by Apricity on 2023/7/17.
//

#ifndef TIShaderTypes_h
#define TIShaderTypes_h

#include <simd/simd.h>

typedef enum TIVertexInputIndex {
    TIVertexInputIndexVertices     = 0,
    TIVertexInputIndexViewportSize = 1,
} TIVertexInputIndex;

typedef enum TIFragmentInputIndex {
    TIFragmentInputIndexViewportSize = 0,
    TIFragmentInputIndexImageData = 1,
} TIFragmentInputIndex;

typedef struct {
    
} Affine;

typedef struct {
    vector_float2 position; // 空间坐标
    vector_float2 uv; // 纹理坐标
} TIVertex;

typedef struct {
    int width;
    int height;
    int dataSize;
    int storedChannels;
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
} TIImageData;


#endif /* TIShaderTypes_h */
