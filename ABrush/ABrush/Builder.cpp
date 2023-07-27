//
//  Builder.cpp
//  ABrush
//
//  Created by Apricity on 2023/7/11.
//

#include "Builder.hpp"
#include "Affine.hpp"
#include <simd/simd.h>

namespace ABrush
{

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

void Builder::setPath(Path &p)
{
    paths.push_back(p);
}

void Builder::fill()
{
    data.vertices.clear();
    data.indices.clear();
    Flatten *flattens = paths.back().flatten();
    FillTessellator tess = FillTessellator();
    tess.fill(flattens, data);
}

void Builder::stroke()
{
    data.vertices.clear();
    data.indices.clear();
    Flatten *flattens = paths.back().flatten();
    StrokeTessellator tess = StrokeTessellator();
    tess.line_width = lineWidth;
    tess.line_cap_style = strokeCap;
    tess.line_join_style = strokeJoin;
    tess.stroke(flattens, data);
}

void Builder::setColor(Color &color)
{
    Paint p;
    p.type = Paint::PaintType::Color;
    p.color = color;
    data.paint = p;
}

void Builder:: setGradient(Gradient &gradient)
{
    Paint p;
    p.type = Paint::PaintType::Gradient;
    p.gradient = new Gradient;
    *p.gradient = gradient;
    data.paint = p;
}

void Builder:: setTexture(Texture &texture)
{
    Paint p;
    p.type = Paint::PaintType::Texture;
    p.texture = (Texture *)malloc(sizeof(Texture));
    *p.texture = texture;
    data.paint = p;
}

void Builder::build(void ** ver, void ** tex)
{
    // vertices.size  + indices.size + verticesLength + indicesLength + vertices + indices
    size_t verticesLength = data.vertices.size() * sizeof(APoint);
    size_t indicesLength = data.indices.size() * sizeof(uint16_t);
    int *buffer = (int *)malloc(16 + verticesLength + indicesLength);
    int *pointer = buffer;
    *pointer++ = (int)data.vertices.size();
    *pointer++ = (int)data.indices.size();
    *pointer++ = (int)verticesLength;
    *pointer++ = (int)indicesLength;
    memcpy(pointer, data.vertices.data(), verticesLength);
    pointer += data.vertices.size() * 2;
    memcpy(pointer, data.indices.data(), indicesLength);
    *ver = buffer;
    
    if (data.paint.type == Paint::PaintType::Color) {
        Color * colorBuffer = (Color *)malloc(sizeof(Color));
        Color * colorPointer = colorBuffer;
        *colorPointer = data.paint.color;
        *tex = colorBuffer;
    }
    else if (data.paint.type == Paint::PaintType::Gradient) {
        GradientData * gdBuffer = (GradientData *)malloc(sizeof(GradientData));
        GradientData * gdPointer = gdBuffer;
        switch ( data.paint.gradient->spreadMethod ) {
            case Gradient::SpreadMethod::Pad:
                gdPointer->spread = 0;
                break;
            case Gradient::SpreadMethod::Reflect:
                gdPointer->spread = 1;
                break;
            case Gradient::SpreadMethod::Repeat:
                gdPointer->spread = 2;
                break;
        }
        switch (data.paint.gradient->gradientType) {
            case Gradient::GradientType::Linear:
                gdPointer->type = 0;
                break;
            case Gradient::GradientType::Radial:
                gdPointer->type = 1;
                break;
            case Gradient::GradientType::Angular:
                gdPointer->type = 2;
                break;
            case Gradient::GradientType::Diamond:
                gdPointer->type = 3;
                break;
            default:
                break;
        }
        gdPointer->a = data.paint.gradient->affine;
        gdPointer->a.invert();
        memcpy(gdPointer->colorLuT, data.paint.gradient->buildColorLuT(), sizeof(uint32_t) * 256);
        *tex = gdPointer;
    }
    else if (data.paint.type == Paint::PaintType::Texture) {
        size_t pixelsSize = data.paint.texture->height * data.paint.texture->stride;
        TextureData * tdBuffer = (TextureData *)malloc(sizeof(TextureData) + pixelsSize);
        TextureData * tdPointer = tdBuffer;
        tdPointer->width = data.paint.texture->width;
        tdPointer->height = data.paint.texture->height;
        tdPointer->a = data.paint.texture->affine;
        tdPointer->a.invert();
        tdPointer += 1;
        memcpy(tdPointer, data.paint.texture->pixels, pixelsSize);
        *tex = tdBuffer;
    }
    else { /*  */ }
}

}
