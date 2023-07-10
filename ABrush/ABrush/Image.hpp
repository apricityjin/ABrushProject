//
// Created by apricity on 2023/6/15.
//

#ifndef IMAGE_HPP
#define IMAGE_HPP

#include <string>
#include <vector>
#define STB_IMAGE_IMPLEMENTATION
#include "stb/stb_image.h"

namespace ABrush
{

    class Image
    {
    public:
        Image(const std::string& filePath, int desiredChannels)
        {
            int channels;
            data = stbi_load(filePath.c_str(), &width, &height, &channels, desiredChannels);
            if (!data) {
                throw std::runtime_error("Failed to load image: " + filePath);
            }

            dataSize = width * height * desiredChannels;
            storedChannels = desiredChannels;
        }

        const uint8_t* getData() const {
            return data;
        }

        int getWidth() const {
            return width;
        }

        int getHeight() const {
            return height;
        }

        int getStoredChannels() const {
            return storedChannels;
        }

        virtual ~Image()
        {
            if (data) {
                free(data);
            }
        }

        std::uint8_t *data = nullptr;
        int width = 0;
        int height = 0;
        int dataSize = 0;
        int storedChannels = 0; // 结果缓冲区中的通道数。
    };

} // ABrush

#endif //ABRUSH_IMAGE_H
