//
//  FillTessellator.cpp
//  ABrush
//
//  Created by Apricity on 2023/7/10.
//

#include "FillTessellator.hpp"
#include "libtess2/Include/tesselator.h"
#include <simd/simd.h>

namespace ABrush
{
void FillTessellator::fill(Flatten *flattens, RenderDataItem &data)
{
    size_t size = flattens[0].size;
    uint32_t index_offset = 0;
    std::vector<Vertex> vertices;
    std::vector<uint16_t> indices;
    for (size_t i = 0; i < size; ++i) {
        Flatten f = flattens[i];
        const size_t num_points = f.points.size(); // 获得点数量
        void * pts = f.store();
        int element_count = 0, vertex_count = 0;
        vector_float2 * verts = nullptr;
        int * elements = nullptr;
        float config_w = 2, w = config_w / 2;
        {
            int ptsCount = (int)num_points;
            void *polygon_coordinates = pts;
            TESStesselator *tesselator = tessNewTess(nullptr);
            if (!tesselator) { return; }
            tessAddContour(tesselator, 2, polygon_coordinates, sizeof(vector_float2), ptsCount);
            if (tessTesselate(tesselator, TESS_WINDING_ODD, TESS_BOUNDARY_CONTOURS, 0, 2, nullptr)) {
                // 获取输出形状数量、顶点数量
                element_count = tessGetElementCount(tesselator);
                vertex_count = tessGetVertexCount(tesselator);
                // 获取输出顶点
                size_t len = sizeof(vector_float2) * vertex_count;
                verts = (vector_float2 *)malloc(len);
                memcpy(verts, tessGetVertices(tesselator), len);
                len = sizeof(int) * 2 * element_count;
                elements = (int *)malloc(len);
                memcpy(elements, tessGetElements(tesselator), len);
            }
            tessDeleteTess(tesselator);
        }
        
        if (!verts && !elements) { return; }
        
        std::vector<uint16_t> indices_temp;
        std::vector<Vertex> vertices_temp(vertex_count * 2);
        vector_float2 * leftOffsets  = (vector_float2 *)malloc(sizeof(vector_float2) * vertex_count);
        vector_float2 * rightOffsets = (vector_float2 *)malloc(sizeof(vector_float2) * vertex_count);
        vector_float2 * internal = nullptr, * external = nullptr;
        
        for (int i = 0; i < element_count; ++i) {
            int startIdx = elements[i * 2], vertCount = elements[i * 2 + 1];
            {
                int offsetIdx = startIdx;
                for (int idx = startIdx; idx < startIdx + vertCount; ++idx) {
                    int ict = idx;
                    int ist = ict == startIdx ? startIdx + vertCount - 1 : ict - 1;
                    int ied = ict == startIdx + vertCount - 1 ? startIdx : ict + 1;
                    vector_float2 st = verts[ist];
                    vector_float2 ct = verts[ict];
                    vector_float2 ed = verts[ied];
                    vector_float2 SC = simd_normalize(ct - st);
                    vector_float2 CE = simd_normalize(ed - ct);
                    vector_float2 SC_left  = simd_make_float2( SC.y, -SC.x);
                    vector_float2 CE_left  = simd_make_float2( CE.y, -CE.x);
                    vector_float2 SC_right = simd_make_float2(-SC.y,  SC.x);
                    vector_float2 CE_right = simd_make_float2(-CE.y,  CE.x);
                    float l = w / cos(acos(simd_dot(SC_left, CE_left)) / 2); // simd_length(SC_left) * simd_length(CE_left) -> 1
                    vector_float2 ct_left  = simd_normalize(SC_left + CE_left) * l  + ct;
                    vector_float2 ct_right = simd_normalize(SC_right + CE_right) * l + ct;
                    leftOffsets[offsetIdx] = ct_left;
                    rightOffsets[offsetIdx] = ct_right;
                    offsetIdx += 1;
                }
            }
            {
                int sum = simd_orient(verts[startIdx + vertCount - 1], verts[startIdx]); // x -> y
                for (int m = 1; m < vertCount; ++m) {
                    sum += simd_orient(verts[startIdx + m - 1], verts[startIdx + m]);
                }
                if (sum > 0) { // sum > 0 -> clockwise
                    internal = rightOffsets;
                    external = leftOffsets ;
                }
                else if (sum < 0) { // sum < 0 -> anti-clockwise
                    internal = leftOffsets;
                    external = rightOffsets;
                }
                else {
                    // error
                    return;
                }
                // 先用三角剖分将内部的多边形添加到 vertices 中
                for (int j = startIdx; j < startIdx + vertCount; ++j) {
                    vertices_temp[j] = (Vertex){ internal[j], 1 }; // 内部
                    vertices_temp[vertex_count + j] = (Vertex){ external[j], 0 }; // 外部
                }
                // 处理内部的顶点
                {
                    int num_points = vertCount;
                    void * polygon = internal + startIdx;
                    TESStesselator * tess = tessNewTess(nullptr);
                    if (!tess) { return; }
                    tessAddContour(tess, 2, polygon, sizeof(vector_float2), num_points);
                    if (tessTesselate(tess, TESS_WINDING_NONZERO, TESS_POLYGONS, 3, 2, nullptr)) {
                        int element_count = tessGetElementCount(tess);
                        const int *elements = tessGetElements(tess);
                        const int *vertexIndices = tessGetVertexIndices(tess);
                        for (int j = 0; j < element_count; ++j) {
                            indices_temp.push_back(index_offset + startIdx + vertexIndices[elements[j * 3]]);
                            indices_temp.push_back(index_offset + startIdx + vertexIndices[elements[j * 3 + 1]]);
                            indices_temp.push_back(index_offset + startIdx + vertexIndices[elements[j * 3 + 2]]);
                        }
                    }
                    tessDeleteTess(tess);
                }
                // 处理外部的顶点
                {
                    int i1, i2, i3, i4;
                    for (int j = startIdx; j < startIdx + vertCount; ++j) {
                        // i1, i2 internal / i3, i4 external
                        i1 = j;                 i2 = (j + 1) == (startIdx + vertCount) ? startIdx : j + 1;
                        i3 = i1 + vertex_count; i4 = i2 + vertex_count;
                        indices_temp.push_back(index_offset + i1); indices_temp.push_back(index_offset + i2); indices_temp.push_back(index_offset + i3);
                        indices_temp.push_back(index_offset + i2); indices_temp.push_back(index_offset + i3); indices_temp.push_back(index_offset + i4);
                    }
                }
            }
            index_offset = (int)vertices_temp.size();
            vertices.insert(vertices.end(), vertices_temp.begin(), vertices_temp.end());
            indices.insert(indices.end(), indices_temp.begin(), indices_temp.end());
        }
    }
    data.vertices = vertices;
    data.indices = indices;
    return;
}
};
