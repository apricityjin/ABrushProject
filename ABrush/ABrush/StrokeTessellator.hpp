//
// Created by apricity on 2023/6/13.
//

#ifndef STROKETESSELLATOR_HPP
#define STROKETESSELLATOR_HPP

#include "Path.hpp"
#include "Affine.hpp"
#include <cmath>
#include "RenderData.hpp"

namespace ABrush
{
struct StrokeTessellator
{

    /// 交点风格
    enum class LineJoin : uint8_t
    {
        LineJoinMiter, // 延长相交
        LineJoinRound, // 圆弧过渡
        LineJoinBevel, // 直接连接
    };
    /// 端点风格
    enum class LineCap : uint8_t
    {
        LineCapRound,
        LineCapSquare,
    };
    LineJoin line_join_style = LineJoin::LineJoinBevel;
    LineCap line_cap_style = LineCap::LineCapSquare;
    float line_width = 1.0;
    
    void stroke(Flatten *flattens, RenderData &data);
};
}

#endif //ABRUSH_STROKETESSELLATOR_H

