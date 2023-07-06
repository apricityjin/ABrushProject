//
// Created by apricity on 2023/6/15.
//

#ifndef ABRUSH_BUILDER_H
#define ABRUSH_BUILDER_H

#include "Color.hpp"
#include "Image.hpp"
#include "FillTessellator.hpp"
#include "StrokeTessellator.hpp"
#include "Gradient.hpp"

namespace ABrush
{
    class Builder
    {
    public:
        Builder()
        = default;

        void setFillColor(uint8_t r, uint8_t g, uint8_t b, uint8_t a)
        {
            fillColor.setRGBA(r, g, b, a);
        }

        void setFillColor(const Color &color)
        {
            fillColor = color;
        }

        void setStrokeColor(const Color &color)
        {
            strokeColor = color;
        }

        void setStrokeColor(uint8_t r, uint8_t g, uint8_t b, uint8_t a)
        {
            strokeColor.setRGBA(r, g, b, a);
        }

        void setLineWidth(float width)
        {
            lineWidth = width;
        }

        void addPath(Path &p)
        {
            paths.push_back(p);
        }

        /// 线性渐变（一一对应进行颜色插值，颜色和坐标数量不对应就取size较小的那个）
        /// 这里取 start为 A，end为 B，需要计算的点为 P，P在 AB上垂点为 F
        uint32_t *drawLinearGradient(Gradient &g, APoint &start, APoint &end)
        {
            uint32_t *gradientBuffer = g.buildLut();
            uint32_t *gradientColorsBuffer = gradientBuffer + 1; // 指向颜色的内存，idx = 0 的颜色
            uint32_t size = *gradientBuffer - 1;
            float x1 = start.x, y1 = start.y;
            // 从这里开始，A点坐标为 (0, 0)
            float x2 = end.x - x1, y2 = end.y - y1;
            float lenAB = sqrt(x2 * x2 + y2 * y2);

            // 用苹果14作为例子，屏幕分辨率：2532 x 1170，逻辑分辨率：844 x 390 -> (y, x)
            uint32_t *tex = (uint32_t *) calloc(844 * 390, sizeof(uint32_t));
            uint32_t *pointer = tex;
            for (float y = 0.0; y < 844.0; ++y) {
                for (float x = 0.0; x < 390.0; ++x) {
                    float x0 = x - x1, y0 = y - y1;
                    float costheta = x2 / lenAB, sintheta = y2 / lenAB;
                    float k = (x0 * costheta + y0 * sintheta) / lenAB; // k -> [0.0, 1.0]
                    if (k > 1.0) {
                        k = 1.0;
                    } else if (k < 0.0) {
                        k = 0.0;
                    }
                    uint32_t idx = size * k + 0.5; // 四舍五入
                    uint32_t rgba = *(gradientColorsBuffer + idx);
                    *pointer++ = rgba;
                }
            }
            free(gradientBuffer);
            return tex;
        }

        /// 径向渐变（颜色沿由一个中心点向外的半径方向渐变。）
        uint32_t *drawRadialGradient(Gradient &g, APoint &center, float radius)
        {
            uint32_t *gradientBuffer = g.buildLut();
            uint32_t *gradientColorsBuffer = gradientBuffer + 1; // 指向颜色的内存，idx = 0 的颜色
            uint32_t size = *gradientBuffer - 1;
            // 用苹果14作为例子，屏幕分辨率：2532 x 1170，逻辑分辨率：844 x 390 -> (y, x)
            uint32_t *tex = (uint32_t *) calloc(844 * 390, sizeof(uint32_t));
            uint32_t *pointer = tex;
            float x1 = center.x, y1 = center.y;
            for (float y = 0.0; y < 844.0; ++y) {
                for (float x = 0.0; x < 390.0; ++x) {
                    float len = sqrt((x - x1) * (x - x1) + (y - y1) * (y - y1));
                    float k = len > radius ? 1.0 : len / radius;
                    uint32_t idx = size * k + 0.5; // 四舍五入
                    uint32_t rgba = *(gradientColorsBuffer + idx);
                    *pointer++ = rgba;
                }
            }
            return tex;
        }

        Color fillColor;
        Color strokeColor;
        float lineWidth = 1.0;
        Image *image = nullptr;
        std::vector<Path> paths;
    };
}

#endif //ABRUSH_BUILDER_H
