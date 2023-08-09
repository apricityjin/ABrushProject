//
//  MetalRender.hpp
//  ABrush
//
//  Created by apricity on 2023/8/9.
//

#ifndef MetalRender_hpp
#define MetalRender_hpp

#include <stdio.h>
#include <Metal/Metal.h>
#include <MetalKit/MetalKit.h>
#include "RenderData.hpp"
#include "Affine.hpp"

namespace ABrush
{
struct MetalRender
{
    typedef enum VertexInputIndex {
        VertexInputIndexVertices        = 0,
        VertexInputIndexViewportSize    = 1,
    } VertexInputIndex;

    typedef enum FragmentInputIndex {
        FragmentInputIndexViewportSize    = 0,
        FragmentInputIndexData            = 1,
    } FragmentInputIndex;

    
    typedef struct GradientData {
//        int method; // SpreadMethod
        int type; // GradientType
        int colorLuTIdx; // 颜色查找表的索引，直接在一块大的texture上存colorLuT
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
            Affine a;
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
            Affine a;
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
    
    id<MTLDevice> device;
    id<MTLRenderPipelineState> pipelineState;
    id<MTLCommandQueue> commandQueue;
    
    id<MTLBuffer> vertices;
    id<MTLBuffer> indices;
    id<MTLBuffer> fragmentBuffer;
    id<MTLTexture> colorLuTs;
    id<MTLTexture> texs;
    
    std::vector<int> vtsOffsets;
    std::vector<int> idsOffsets;
    std::vector<int> fgtOffsets;
    std::vector<size_t> idxCounts;
    
    void setDevice(id<MTLDevice> device);
    void draw(id<MTLTexture> texture);
    void draw(id<CAMetalDrawable> drawable);
    
    void initData(RenderData &data);
    
    MetalRender(id<MTLDevice> device);
};
}

#endif /* MetalRender_hpp */
