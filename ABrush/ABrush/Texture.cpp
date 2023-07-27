//
//  Texture.cpp
//  ABrush
//
//  Created by Apricity on 2023/7/11.
//

#include "Texture.hpp"

namespace ABrush
{

Texture::Texture(int width, int height)
: width(width), height(height), stride(width << 2), owndata(1)
{
    pixels = calloc(1, (size_t)(stride * height));
}

Texture::Texture(int width, int height, void* pixels)
: width(width), height(height), stride(width << 2), owndata(0), pixels(pixels)
{}

Texture::Texture(const Texture &t)
: width(t.width), height(t.height), stride(t.stride), pixels(t.pixels), owndata(0), type(t.type), affine(t.affine), opacity(t.opacity)
{}

void Texture::reset()
{
    width = 0;
    height = 0;
    stride = 0;
    opacity = 1.0;
    affine.setIdentity();
    if (owndata && pixels) {
        free(pixels);
    }
    owndata = 0;
}

Texture::~Texture()
{
    if (owndata && pixels) {
        free(pixels);
    }
}

}
