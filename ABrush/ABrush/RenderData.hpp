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

struct RenderData
{
    RenderData();
    
    std::vector<APoint>   vertices;
    std::vector<uint16_t> indices;
    Paint paint;
};

}

#endif //ABRUSH_RENDERDATA_H
