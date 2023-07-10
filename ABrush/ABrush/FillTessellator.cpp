//
//  FillTessellator.cpp
//  ABrush
//
//  Created by Apricity on 2023/7/10.
//

#include "FillTessellator.hpp"
#include "libtess2/Include/tesselator.h"

namespace ABrush
{
    void FillTessellator::fill(Flatten *flattens, RenderData &data)
    {
        size_t size = flattens[0].size;
        uint32_t index_offset = 0;
        for (size_t i = 0; i < size; ++i) {
            auto f = flattens[i];
            const size_t num_points = f.points.size(); // 获得点数量
            float *polygon_coordinates = f.store();
            TESStesselator *tesselator = tessNewTess(nullptr);
            if (!tesselator) {
                // error
                return;
            }
            tessAddContour(tesselator, 2, polygon_coordinates, sizeof(float) * 2, (int) num_points);
            if (tessTesselate(tesselator, TESS_WINDING_NONZERO, TESS_POLYGONS, 3, 2, nullptr)) {
                // 获取输出三角形数量、顶点数量
                const int element_count = tessGetElementCount(tesselator);
                const int vertex_count = tessGetVertexCount(tesselator);
                const int index_count = element_count * 3;
                // 获取输出顶点
                const float *vertices = tessGetVertices(tesselator);
                const int *elements = tessGetElements(tesselator);
                for (int j = 0; j < vertex_count; ++j) {
                    data.vertices.push_back({vertices[j * 2], vertices[j * 2 + 1]});
                }
                for (int j = 0; j < element_count; ++j) {
                    data.indices.push_back(elements[j * 3] + index_offset);
                    data.indices.push_back(elements[j * 3 + 1] + index_offset);
                    data.indices.push_back(elements[j * 3 + 2] + index_offset);
                }
                index_offset += index_count;
            }
            tessDeleteTess(tesselator);
            free(polygon_coordinates);
        }
    }
};
