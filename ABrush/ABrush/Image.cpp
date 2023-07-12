//
//  Image.cpp
//  ABrush
//
//  Created by Apricity on 2023/7/10.
//

#include "Image.hpp"

namespace ABrush
{

Image::Image(const std::string& filePath, int desiredChannels)
{
    int channels;
    data = stbi_load(filePath.c_str(), &width, &height, &channels, desiredChannels);
    if (!data) {
        throw std::runtime_error("Failed to load image: " + filePath);
    }
    
    dataSize = width * height * desiredChannels;
    storedChannels = desiredChannels;
}

const uint8_t* Image::getData() const
{
    return data;
}

int Image::getWidth() const
{
    return width;
}

int Image::getHeight() const
{
    return height;
}

int Image::getStoredChannels() const
{
    return storedChannels;
}

Image::~Image()
{
    if (data) {
        free(data);
    }
}

} // ABrush
