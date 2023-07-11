//
// Created by apricity on 2023/6/15.
//

#ifndef BUILDER_HPP
#define BUILDER_HPP

#include "Color.hpp"
#include "Image.hpp"
#include "FillTessellator.hpp"
#include "StrokeTessellator.hpp"
#include "Gradient.hpp"
#include "RenderData.hpp"

namespace ABrush
{
    struct Builder
    {
        Builder();

        void setFillColor(uint8_t r, uint8_t g, uint8_t b, uint8_t a);

        void setFillColor(const Color &color);

        void setStrokeColor(const Color &color);

        void setStrokeColor(uint8_t r, uint8_t g, uint8_t b, uint8_t a);

        void setLineWidth(float width);

        void addPath(Path &p);

        /// 线性渐变（一一对应进行颜色插值，颜色和坐标数量不对应就取size较小的那个）
        /// 这里取 start为 A，end为 B，需要计算的点为 P，P在 AB上垂点为 F
        /// memory: |type|start| end |
        ///         | 4B | 8B  | 8B  |
        void buildLinearGradient(RenderData &data, Gradient &g, APoint &start, APoint &end);

        /// 径向渐变（颜色沿由一个中心点向外的半径方向渐变。）
        /// memory: |type|start|end|
        ///         | 4B | 8B  |8B |
        void buildRadialGradient(RenderData &data, Gradient &g, APoint &start, APoint &end);
        
        /// 渐变（颜色沿由一个中心点向外的半径方向渐变。）
        /// memory: |type|start|end|
        ///         | 4B | 8B  |8B |
        void buildAngularGradient(RenderData &data, Gradient &g, APoint &start, APoint &end);

        Color fillColor;
        Color strokeColor;
        float lineWidth = 1.0;
        Image *image = nullptr;
        std::vector<Path> paths;
    };
}

#endif //ABRUSH_BUILDER_H
