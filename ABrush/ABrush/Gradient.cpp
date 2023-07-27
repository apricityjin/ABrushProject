//
//  Gradient.cpp
//  ABrush
//
//  Created by Apricity on 2023/7/11.
//

#include "Gradient.hpp"
#include <cmath>

namespace ABrush
{

Gradient::Gradient()
= default;

Gradient::Gradient(const Gradient &g)
{
    stops = g.stops;
    affine = g.affine;
    gradientType = g.gradientType;
    spreadMethod = g.spreadMethod;
    opacity = g.opacity;
}

/// 大小 size，size在一种颜色的情况下为1，在多个颜色情况下为256。
uint *Gradient::buildColorLuT()
{
    // count = 0 -> 不用渲染，count = 1 -> 只用渲染一种颜色， count >= 2 -> 颜色插值运算
    size_t count = stops.size();
    uint * buffer = nullptr;
    if (count == 0) {
        buffer = (uint * )
        calloc(1, sizeof(uint));
        *buffer = 0;
        return buffer;
    } else if (count == 1) {
        Color &c = stops[0].color;
        buffer = (uint * )calloc(1, sizeof(uint));
        *buffer = c.rgba;
        return buffer;
    }
    // count >= 2
    // 默认切割256份
    int size = 256;
    buffer = (uint * )calloc(size, sizeof(uint));
    uint * pointer = buffer;
    int l = 0, r = 1;
    Color leftColor = stops[l].color;
    Color rightColor = stops[r].color;
    Color curColor = leftColor;
    float leftLocation = stops[l].location;
    float rightLocation = stops[r].location;
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
            leftColor = stops[l].color;
            rightColor = stops[r].color;
            leftLocation = stops[l].location;
            rightLocation = stops[r].location;
        }
        float len = rightLocation - leftLocation,
        rPercent = (curLocation - leftLocation) / len,
        lPercent = 1 - rPercent;
        uint res = rgbaInterpolation(leftColor, lPercent, rightColor, rPercent);
        *pointer++ = res;
    }
    return buffer;
}
Gradient& Gradient::addStop(GradientStop &stop)
{
    return addStop(stop.location, stop.color.r(), stop.color.g(), stop.color.b(), stop.color.a());
}
Gradient& Gradient::addStop(float location, Color &color)
{
    return addStop(location, color.r(), color.g(), color.b(), color.a());
}
Gradient& Gradient::addStop(float location, uint8_t r, uint8_t g, uint8_t b)
{
    return addStop(location, r, g, b, 255);
}
Gradient& Gradient::addStop(float location, uint8_t r, uint8_t g, uint8_t b, uint8_t a)
{
    if(location < 0.0) { location = 0.0; };
    if(location > 1.0) { location = 1.0; };
    GradientStop stop;
    stop.location = location;
    stop.color.setRGBA(r, g, b, a);
    int i;
    for (i = 0; i < stops.size(); ++i) {
        if (location < stops[i].location) {
            break;
        }
    }
    stops.insert(stops.begin() + i, stop);
    return *this;
}
void Gradient::clearStops()
{
    stops.clear();
}


void Gradient::resetAffine()
{
    affine.setIdentity();
}

void Gradient::setAffine(Affine &a)
{
    affine.multiply(a);
}

void Gradient::setLinear(APoint &start, APoint &end)
{
    APoint p = end - start;
    float s = p.length(),
    a = atan2(p.y, p.x);
    affine.scale(s).rotate(a).translate(start.x, start.y);
    gradientType = GradientType::Linear;
}
void Gradient::setRadial(APoint &center, float cr, float r, float angle)
{
    float sx = cr,
    sy = r,
    a = angle;
    affine.scale(sx, sy).rotate(a).translate(center.x, center.y);
    gradientType = GradientType::Radial;
}
void Gradient::setAngular(APoint &center, float cr, float r, float angle)
{
    float sx = cr,
    sy = r,
    a = M_PI + angle;
    affine.scale(sx, sy).rotate(a).translate(center.x, center.y);
    gradientType = GradientType::Angular;
}
void Gradient::setDiamond(APoint &center, float cr, float r, float angle)
{
    float sx = cr,
    sy = r,
    a = angle;
    affine.scale(sx, sy).rotate(a).translate(center.x, center.y);
    gradientType = GradientType::Diamond;
}

} // ABrush
