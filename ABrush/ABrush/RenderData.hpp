//
// Created by apricity on 2023/6/15.
//

#ifndef ABRUSH_RENDERDATA_H
#define ABRUSH_RENDERDATA_H

#include <iostream>

struct RenderData
{

    struct Vertex
    {
        float x, y;
//        float u, v;
    };

    RenderData(const std::vector<Vertex> &vertices, const std::vector<uint16_t> &indices)
            : vertices(vertices), indices(indices)
    {}

    RenderData()
    =default;

    // 直接将所有的vertices和indices往这两个vector塞
    std::vector<Vertex>   vertices;
    std::vector<uint16_t> indices;
    /// size     + colors
    /// uint32_t + ......(uint32_t * size)
    uint32_t * colorsLut;
};

#endif //ABRUSH_RENDERDATA_H
