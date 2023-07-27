//
// Created by apricity on 2023/6/15.
//

#ifndef TEXTURE_HPP
#define TEXTURE_HPP

#include <iostream>
#include "Affine.hpp"

namespace ABrush
{

struct Texture
{
    enum class TextureType
    {
        Plain,
        Tiled,
    };
    
    int width;
    int height;
    int stride;
    void * pixels = nullptr;
    int owndata;
    
    TextureType type;
    Affine affine;
    float opacity = 1.0;
    
    Texture(int width, int height);
    Texture(int width, int height, void* pixels);
    Texture(const Texture &t);
    void reset();
    ~Texture();
};

}

#endif //ABRUSH_TEXTURE_H
