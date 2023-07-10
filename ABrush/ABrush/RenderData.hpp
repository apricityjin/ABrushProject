//
// Created by apricity on 2023/6/15.
//

#ifndef RENDERDATA_HPP
#define RENDERDATA_HPP

#include <vector>

namespace ABrush {

struct RenderData
{
    struct Vertex
    {
        float x, y;
        //        float u, v;
    };
    
    RenderData(const std::vector<Vertex> &vertices, const std::vector<uint16_t> &indices);
    
    RenderData();
    
    // 直接将所有的vertices和indices往这两个vector塞
    std::vector<Vertex>   vertices;
    std::vector<uint16_t> indices;
    /* memory:
     * |type | start  | end    |  size | colors
     * |4B   | (4+4)B | (4+4)B |  4B   | ......(4 * size)B
     * |type | center | radius |  size | colors
     * |4B   | (4+4)B | 4B     |  4B   | ......(4 * size)B
     */
    
    // start end | center radius
    float * vertexPoint;
};

}

#endif //ABRUSH_RENDERDATA_H
