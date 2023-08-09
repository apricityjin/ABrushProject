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
#include "Paint.hpp"

namespace ABrush
{
    struct Builder // ctx
    {
//        struct GradientData
//        {
//            int spread;
//            int type;
//            Affine a;
//            uint32_t colorLuT[256];
//        };
//        
//        struct TextureData
//        {
//            int width;
//            int height;
//            Affine a;
//        };
        
        enum class TessellatorStyle : uint8_t {
            strokeStyle,
            fillStyle,
        };

        void setFillColor(uint8_t r, uint8_t g, uint8_t b, uint8_t a);
        void setFillColor(const Color &color);
        void setStrokeColor(const Color &color);
        void setStrokeColor(uint8_t r, uint8_t g, uint8_t b, uint8_t a);
        void setLineWidth(float width);
        void setPath(Path &p);
        
        // 这里以下的方法保留
        
        void fill();
        void stroke();
        void setColor(Color &color);
        void setGradient(Gradient &gradient);
        void setTexture(Texture &texture);
        void build(void ** ver, void ** tex);
        
        Color fillColor;
        Color strokeColor;
        StrokeTessellator::LineJoin strokeJoin = StrokeTessellator::LineJoin::Bevel;
        StrokeTessellator::LineCap strokeCap = StrokeTessellator::LineCap::Butt;
        float lineWidth = 1.0;
        std::vector<Path> paths;
        Affine affine;
        RenderData data;
        RenderDataItem curItem;
    };
}

#endif //ABRUSH_BUILDER_H
