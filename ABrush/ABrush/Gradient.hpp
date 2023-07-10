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
        Gradient(const std::vector<Color> &colors, const std::vector<float> &locations)
                : colors(colors), locations(locations)
        {}

        Gradient()
        = default;

        /// 线性渐变需要颜色与坐标对应
        void add(const Color &color, const float &location)
        {
            colors.push_back(color);
            locations.push_back(location);
        }

        void sort()
        {
            auto len = locations.size();
            for (int i = 0; i < len - 1; ++i) {
                for (auto j = len - 1; j > i; --j) {
                    if (locations[j] < locations[j - 1]) {
                        swap(j, j - 1);
                    }
                }
            }
        }

        void swap(auto i, auto j)
        {
            float t = locations[j];
            locations[j] = locations[i];
            locations[i] = t;
            uint tc = colors[j].rgba;
            colors[j].rgba = colors[i].rgba;
            colors[i].rgba = tc;
        }

        /// 大小 size，size在一种颜色的情况下为1，在多个颜色情况下为256。
        uint *buildLut()
        {
            sort();
            // count = 0 -> 不用渲染，count = 1 -> 只用渲染一种颜色， count >= 2 -> 颜色插值运算
            auto count = std::min(colors.size(), locations.size());
            uint * buffer = nullptr;
            if (count == 0) {
                buffer = (uint * )
                calloc(1, sizeof(uint));
                *buffer = 0;
                return buffer;
            } else if (count == 1) {
                size = 1;
                Color &c = colors[0];
                buffer = (uint * )calloc(1, sizeof(uint));
                *buffer = c.rgba;
                return buffer;
            }
            // count >= 2
            // 默认切割255份
            size = 256;
            buffer = (uint * )calloc(size, sizeof(uint));
            uint * pointer = buffer;
            int l = 0, r = 1;
            Color leftColor = colors[l];
            Color rightColor = colors[r];
            Color curColor = leftColor;
            float leftLocation = locations[l];
            float rightLocation = locations[r];
            float curLocation = 0.0;

            for (int i = 0; i < size; ++i) {
                curLocation = (float) i / (float) (size - 1);
                if (curLocation < leftLocation) {
                    *pointer++ = curColor.rgba;
                    continue;
                } else if (curLocation > rightLocation && r >= count - 1) {
                    *pointer++ = rightColor.rgba;
                    continue;
                } else if (curLocation > rightLocation && r < count - 1) {
                    l++;
                    r++;
                    leftColor = colors[l];
                    rightColor = colors[r];
                    leftLocation = locations[l];
                    rightLocation = locations[r];
                }
                float len = rightLocation - leftLocation,
                        rPercent = (curLocation - leftLocation) / len,
                        lPercent = 1 - rPercent;
                uint res = rgbaInterpolation(leftColor, lPercent, rightColor, rPercent);
                *pointer++ = res;
            }
            return buffer;
        }

        /// 储存颜色
        std::vector<Color> colors;
        /// 储存坐标 0.0 ~ 1.0
        std::vector<float> locations;
        uint size;
    };

} // ABrush

#endif //ABRUSH_GRADIENT_H
