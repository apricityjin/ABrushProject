//
// Created by apricity on 2023/6/13.
//

#ifndef STROKETESSELLATOR_HPP
#define STROKETESSELLATOR_HPP

#include <cmath>
#include <simd/simd.h>

#include "Path.hpp"
#include "Affine.hpp"
#include "RenderData.hpp"

namespace ABrush
{
struct StrokeTessellator
{

    /// 交点风格
    enum class LineJoin
    {
        Miter, // 延长相交
        Round, // 圆弧过渡
        Bevel, // 直接连接
    };
    /// 端点风格
    enum class LineCap
    {
        Butt,
        Round,
        Square,
    };
    LineJoin line_join_style = LineJoin::Bevel;
    LineCap line_cap_style = LineCap::Square;
    float line_width = 1.0;
    float miterlimit;
    
    void stroke(Flatten *flattens, RenderDataItem &data);
    
};

simd_float2x2 getMatPerAngle(float segment, float angle);

int getSegment(float radius, float angle);

int getSegment(float radius, float angle, float tolerance);

}

#endif //ABRUSH_STROKETESSELLATOR_H

