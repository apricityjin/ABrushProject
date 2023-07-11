//
//  Builder.cpp
//  ABrush
//
//  Created by Apricity on 2023/7/11.
//

#include "Builder.hpp"
#include <simd/simd.h>

namespace ABrush
{
Builder::Builder()
= default;

void Builder::setFillColor(uint8_t r, uint8_t g, uint8_t b, uint8_t a)
{
    fillColor.setRGBA(r, g, b, a);
}

void Builder::setFillColor(const Color &color)
{
    fillColor = color;
}

void Builder::setStrokeColor(const Color &color)
{
    strokeColor = color;
}

void Builder::setStrokeColor(uint8_t r, uint8_t g, uint8_t b, uint8_t a)
{
    strokeColor.setRGBA(r, g, b, a);
}

void Builder::setLineWidth(float width)
{
    lineWidth = width;
}

void Builder::addPath(Path &p)
{
    paths.push_back(p);
}

/// 线性渐变（一一对应进行颜色插值，颜色和坐标数量不对应就取size较小的那个）
/// 这里取 start为 A，end为 B，需要计算的点为 P，P在 AB上垂点为 F
/// memory: |type|start|end|
///         | 4B | 8B  |8B |
void Builder::buildLinearGradient(RenderData &data, Gradient &g, APoint &start, APoint &end)
{
    data.vertexPoint = (vector_float2 *)calloc(2, sizeof(vector_float2));
    vector_float2 *pointer = data.vertexPoint;
    *pointer++ = vector2(start.x,start.y);
    *pointer++ = vector2(end.x, end.y);
    /*
     uint32_t *colorsLut = g.buildLut();
     uint32_t length = *colorsLut;
     data.gradientLen = 5 + length;
     data.gradient = (uint32_t *)calloc(5 + length, sizeof(uint32_t));
     uint32_t *pointer = data.gradient;
     *pointer++ = 0;
     //            *pointer++ = start.x;
     //            *pointer++ = start.y;
     //            *pointer++ = end.x;
     //            *pointer++ = end.y;
     float d[] = {
     start.x,
     start.y,
     end.x,
     end.y,
     };
     memcpy(pointer, &d, 4 * sizeof(uint32_t));
     pointer += 4;
     memcpy(pointer, colorsLut, length * sizeof(uint32_t));
     
     
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
     //                    uint32_t idx = size * k + 0.5; // 四舍五入
     //                    uint32_t rgba = *(gradientColorsBuffer + idx);
     //                    *pointer++ = rgba;
     }
     }
     */
}

/// 径向渐变（颜色沿由一个中心点向外的半径方向渐变。）
/// memory: |type|start|end|
///         | 4B | 8B  |8B |
void Builder::buildRadialGradient(RenderData &data, Gradient &g, APoint &start, APoint &end)
{
    data.vertexPoint = (vector_float2 *)calloc(2, sizeof(vector_float2));
    vector_float2 *pointer = data.vertexPoint;
    *pointer++ = vector2(start.x,start.y);
    *pointer++ = vector2(end.x, end.y);
    /*
     uint32_t *colorsLut = g.buildLut();
     uint32_t length = *colorsLut;
     data.gradientLen = 4 + length;
     data.gradient = (uint32_t *)calloc(4 + length, sizeof(uint32_t));
     uint32_t *pointer = data.gradient;
     *pointer++ = 1;
     //            *pointer++ = center.x;
     //            *pointer++ = center.y;
     //            *pointer++ = radius;
     float d[] = {
     center.x,
     center.y,
     radius,
     };
     memcpy(pointer, &d, 3 * sizeof(uint32_t));
     pointer += 3;
     memcpy(pointer, colorsLut, length * sizeof(uint32_t));
     
     // 用苹果14作为例子，屏幕分辨率：2532 x 1170，逻辑分辨率：844 x 390 -> (y, x)
     uint32_t *tex = (uint32_t *) calloc(844 * 390, sizeof(uint32_t));
     uint32_t *pointer = tex;
     float x1 = center.x, y1 = center.y;
     for (float y = 0.0; y < 844.0; ++y) {
     for (float x = 0.0; x < 390.0; ++x) {
     float len = sqrt((x - x1) * (x - x1) + (y - y1) * (y - y1));
     float k = len > radius ? 1.0 : len / radius;
     //                    uint32_t idx = size * k + 0.5; // 四舍五入
     //                    uint32_t rgba = *(gradientColorsBuffer + idx);
     //                    *pointer++ = rgba;
     }
     }
     */
}

void Builder::buildAngularGradient(RenderData &data, Gradient &g, APoint &start, APoint &end)
{
    data.vertexPoint = (vector_float2 *)calloc(2, sizeof(vector_float2));
    vector_float2 *pointer = data.vertexPoint;
    *pointer++ = vector2(start.x,start.y);
    *pointer++ = vector2(end.x, end.y);
}

}
