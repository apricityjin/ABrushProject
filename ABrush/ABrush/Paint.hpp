//
//  Paint.hpp
//  ABrush
//
//  Created by Apricity on 2023/7/23.
//

#ifndef Paint_hpp
#define Paint_hpp

#include <iostream>
#include "Color.hpp"
#include "Gradient.hpp"
#include "Texture.hpp"

namespace ABrush
{

struct Paint
{
    enum class PaintType
    {
        Color,
        Gradient,
        Texture,
    };
    
    PaintType type;
    Color color;
    Gradient * gradient = nullptr;
    Texture * texture = nullptr;
};

}

#endif /* Paint_hpp */
