//
//  RenderData.cpp
//  ABrush
//
//  Created by Apricity on 2023/7/10.
//

#include "RenderData.hpp"

namespace ABrush {

Vertex::Vertex(vector_float2 position, float alpha)
: position(position), alpha(alpha)
{}

Vertex::Vertex()
{}

RenderDataItem::RenderDataItem()
=default;

}
