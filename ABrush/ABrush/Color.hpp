//
// Created by apricity on 2023/6/15.
//

#ifndef ABRUSH_COLOR_H
#define ABRUSH_COLOR_H

#include <iostream>
#include <cstdint>
#include <algorithm>

namespace ABrush
{
    /// 直接拷贝到 buffer 里就可以使用
    struct Color
    {
        Color(uint8_t r, uint8_t g, uint8_t b, uint8_t a)
                : rgba((a << 24) | (b << 16) | (g << 8) | r)
        {}

        Color()
        = default;

        [[nodiscard]] uint8_t r() const
        {
            return rgba & 0xFF;
        }

        [[nodiscard]] uint8_t g() const
        {
            return (rgba >> 8) & 0xFF;
        }

        [[nodiscard]] uint8_t b() const
        {
            return (rgba >> 16) & 0xFF;
        }

        [[nodiscard]] uint8_t a() const
        {
            return (rgba >> 24) & 0xFF;
        }

        void setRGBA(uint8_t r, uint8_t g, uint8_t b, uint8_t a)
        {
            setR(r);
            setG(g);
            setB(b);
            setA(a);
        }

        void setR(uint8_t r)
        {
            rgba = (rgba & 0xFFFFFF00) | r;
        }

        void setG(uint8_t g)
        {
            rgba = (rgba & 0xFFFF00FF) | (g << 8);
        }

        void setB(uint8_t b)
        {
            rgba = (rgba & 0xFF00FFFF) | (b << 16);
        }

        void setA(uint8_t a)
        {
            rgba = (rgba & 0x00FFFFFF) | (a << 24);
        }

        uint32_t rgba;
    };
} // ABrush

uint32_t rgbaScale(uint32_t rgba, float scale)
{
    unsigned char r = static_cast<unsigned char>((rgba >> 0) & 0xFF);
    unsigned char g = static_cast<unsigned char>((rgba >> 8) & 0xFF);
    unsigned char b = static_cast<unsigned char>((rgba >> 16) & 0xFF);
    unsigned char a = static_cast<unsigned char>((rgba >> 24) & 0xFF);

    r = static_cast<unsigned char>(r * scale);
    g = static_cast<unsigned char>(g * scale);
    b = static_cast<unsigned char>(b * scale);
    a = static_cast<unsigned char>(a * scale);

    return (a << 24) | (b << 16) | (g << 8) | r;
}

uint32_t rgbaAdd(uint32_t rgba1, uint32_t rgba2
)
{
    unsigned char r1 = static_cast<unsigned char>((rgba1 >> 0) & 0xFF);
    unsigned char g1 = static_cast<unsigned char>((rgba1 >> 8) & 0xFF);
    unsigned char b1 = static_cast<unsigned char>((rgba1 >> 16) & 0xFF);
    unsigned char a1 = static_cast<unsigned char>((rgba1 >> 24) & 0xFF);

    unsigned char r2 = static_cast<unsigned char>((rgba2 >> 0) & 0xFF);
    unsigned char g2 = static_cast<unsigned char>((rgba2 >> 8) & 0xFF);
    unsigned char b2 = static_cast<unsigned char>((rgba2 >> 16) & 0xFF);
    unsigned char a2 = static_cast<unsigned char>((rgba2 >> 24) & 0xFF);

    unsigned char r = std::min(255, r1 + r2);
    unsigned char g = std::min(255, g1 + g2);
    unsigned char b = std::min(255, b1 + b2);
    unsigned char a = std::min(255, a1 + a2);

    return (a << 24) | (b << 16) | (g << 8) | r;
}

uint32_t rgbaInterpolation(ABrush::Color &color1, float percent1,
                           ABrush::Color &color2, float percent2)
{
    uint32_t res = rgbaAdd(rgbaScale(color1.rgba, percent1),
                           rgbaScale(color2.rgba, percent2));
    return res;
}

#endif //ABRUSH_COLOR_H
