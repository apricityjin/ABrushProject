//
// Created by apricity on 2023/6/15.
//

#ifndef RENDERDATA_HPP
#define RENDERDATA_HPP

#include <vector>
#include <simd/simd.h>
#include "ABShaderTypes.h"

namespace ABrush {

struct RenderData
{
    
    RenderData(const std::vector<Vertex> &vertices, const std::vector<uint16_t> &indices);
    
    RenderData();
    
    // 直接将所有的vertices和indices往这两个vector塞
    std::vector<Vertex> vertices;
    std::vector<uint16_t> indices;
    
    // start end | center radius
    vector_float2 * vertexPoint = nullptr;
    GradientData * gradientData = nullptr;
    uint32_t * colorLuT = nullptr;
};

}

#endif //ABRUSH_RENDERDATA_H
