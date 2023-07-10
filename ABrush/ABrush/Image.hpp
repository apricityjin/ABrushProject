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

    struct Image
    {
        Image(const std::string& filePath, int desiredChannels);

        const uint8_t* getData() const;

        int getWidth() const;

        int getHeight() const;

        int getStoredChannels() const;

        virtual ~Image();

        std::uint8_t *data = nullptr;
        int width = 0;
        int height = 0;
        int dataSize = 0;
        int storedChannels = 0; // 结果缓冲区中的通道数。
    };

} // ABrush

#endif //ABRUSH_IMAGE_H
