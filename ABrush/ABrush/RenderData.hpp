//
// Created by apricity on 2023/6/15.
//

#ifndef RENDERDATA_HPP
#define RENDERDATA_HPP

#include <vector>
#include <simd/simd.h>
#include "Image.hpp"
#include "Paint.hpp"

namespace ABrush {

struct Vertex {
    union {
        struct {
            float x;
            float y;
        };
        vector_float2 position;
    };
    float alpha;
    float z; // 用来显示字体的参数
    
    Vertex();
    Vertex(vector_float2 position, float alpha);
};

struct RenderDataItem
{
    RenderDataItem();
    
    std::vector<Vertex>   vertices;
    std::vector<uint16_t> indices;
    Paint paint;
};

struct RenderData
{
    std::vector<RenderDataItem> items;
    size_t verticesLength = 0;
    size_t indicesLength = 0;
    size_t fragmentLength = 0;
};

}

#endif //ABRUSH_RENDERDATA_H
