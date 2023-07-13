//
// Created by apricity on 2023/6/15.
//

#ifndef GRADIENT_HPP
#define GRADIENT_HPP

#include <vector>
#include <stdexcept>
#include "Color.hpp"
#include "APoint.hpp"

namespace ABrush
{
    struct Gradient
    {
        Gradient(const std::vector<Color> &colors, const std::vector<float> &locations);

        Gradient();
        /// 线性渐变需要颜色与坐标对应
        void add(const Color &color, const float &location);

        void sort();

        void swap(auto i, auto j);

        /// 大小 size，size在一种颜色的情况下为1，在多个颜色情况下为256。
        uint *buildLut();

        /// 储存颜色
        std::vector<Color> colors;
        /// 储存坐标 0.0 ~ 1.0
        std::vector<float> locations;
        uint size = 256;
    };

} // ABrush

#endif //ABRUSH_GRADIENT_H
