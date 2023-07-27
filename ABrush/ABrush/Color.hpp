//
// Created by apricity on 2023/6/15.
//

#ifndef COLOR_HPP
#define COLOR_HPP

#include <iostream>
#include <cstdint>
#include <algorithm>

namespace ABrush
{

    /// 直接拷贝到 buffer 里就可以使用
    struct Color
    {
        Color(uint8_t r, uint8_t g, uint8_t b, uint8_t a);
        Color(uint8_t r, uint8_t g, uint8_t b);
        Color(uint32_t hex);

        Color();

        uint8_t r() const;

        uint8_t g() const;

        uint8_t b() const;

        uint8_t a() const;
        
        void setRGBA(uint8_t r, uint8_t g, uint8_t b, uint8_t a);
        void setRGB (uint8_t r, uint8_t g, uint8_t b);

        void setR(uint8_t r);
        
        void setG(uint8_t g);

        void setB(uint8_t b);

        void setA(uint8_t a);

        uint32_t rgba;
    };

} // ABrush

uint32_t rgbaScale(uint32_t rgba, float scale);

uint32_t rgbaAdd(uint32_t rgba1, uint32_t rgba2);

uint32_t rgbaInterpolation(ABrush::Color &color1, float percent1,
                           ABrush::Color &color2, float percent2);

#endif //ABRUSH_COLOR_H
