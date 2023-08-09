//
// Created by apricity on 2023/6/15.
//

#ifndef GRADIENT_HPP
#define GRADIENT_HPP

#include <vector>
#include <stdexcept>
#include "Affine.hpp"
#include "Color.hpp"
#include "APoint.hpp"

namespace ABrush
{
    struct Gradient
    {
        enum class GradientType {
            Linear,
            Radial,
            Angular,
            Diamond,
        };
        typedef struct {
            Color color;
            float location;
        } GradientStop;
        
        GradientType gradientType = GradientType::Linear;
        Affine affine = Affine(); // 正变换，在主动调用setAffine之后再求逆
        std::vector<GradientStop> stops;
        float opacity = 1.0;
        
        Gradient();
        Gradient(const Gradient &g);
        Gradient& addStop(GradientStop &stop);
        Gradient& addStop(float location, Color &color);
        Gradient& addStop(float location, uint8_t r, uint8_t g, uint8_t b);
        Gradient& addStop(float location, uint8_t r, uint8_t g, uint8_t b, uint8_t a);
        void clearStops();
        /// 大小 size，size在一种颜色的情况下为1，在多个颜色情况下为256。
        uint *buildColorLuT();
        void resetAffine();
        void setAffine(Affine &a);
        
        void setLinear(APoint &start, APoint &end);
        void setRadial(APoint &center, float cr, float r, float angle);
        void setAngular(APoint &center, float cr, float r, float angle);
        void setDiamond(APoint &center, float cr, float r, float angle);
    };

} // ABrush

#endif //ABRUSH_GRADIENT_H
