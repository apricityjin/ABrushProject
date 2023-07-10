//
//  RenderData.cpp
//  ABrush
//
//  Created by Apricity on 2023/7/10.
//

#include "RenderData.hpp"

namespace ABrush {

RenderData::RenderData(const std::vector<Vertex> &vertices, const std::vector<uint16_t> &indices)
: vertices(vertices), indices(indices)
{}

RenderData::RenderData()
=default;

}
