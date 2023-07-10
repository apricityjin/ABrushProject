//
// Created by apricity on 2023/6/13.
//

#ifndef FILLTESSELLATOR_HPP
#define FILLTESSELLATOR_HPP

#include "Path.hpp"
#include "RenderData.hpp"

namespace ABrush
{

struct FillTessellator
{
    void fill(Flatten *flattens, RenderData &data);
};

}

#endif //ABRUSH_FILLTESSELLATOR_H
