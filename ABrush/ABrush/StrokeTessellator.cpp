//
//  StrokeTessellator.cpp
//  ABrush
//
//  Created by Apricity on 2023/7/10.
//

#include <simd/simd.h>

#include "StrokeTessellator.hpp"

namespace ABrush
{

simd_float2x2 getMatPerAngle(float segment, float angle) {
    float a = angle / segment;
    simd_float2x2 mat = {
        simd_make_float2(cos(a), sin(a)),
        simd_make_float2(-sin(a), cos(a))
    };
    return mat;
}

int getSegment(float radius, float angle) {
    return getSegment(radius, angle, 0.1);
}

int getSegment(float radius, float angle, float tolerance) {
    tolerance = std::min(tolerance, radius);
    float step = std::sqrt(2.0 * tolerance * radius - tolerance * tolerance) * 2.0;
    float arcLength = angle * radius;
    int segment = std::ceil(arcLength / step);
    if (segment < 2) { segment = 2; }
    return segment;
}

void StrokeTessellator::stroke(Flatten *flattens, RenderDataItem &item)
{
    using namespace std;
    size_t size = flattens[0].size;
    int index_offset = 0; // 为了只用传递一次 vertices，这里在绘制多个线段的时候需要添加上offset
    std::vector<Vertex> vertices;
    std::vector<uint16_t> indices;
    for (size_t pathIdx = 0; pathIdx < size; ++pathIdx) {
        Flatten &f = flattens[pathIdx];
        size_t num_pts = f.points.size();
        
//        for (int j = 0; j < f.points.size(); ++j) {
//            printf("(%f, %f) ", f.points[j].x, f.points[j].y);
//        }
//        printf("\n");
        
        float config_w = 1, config_lw = line_width; // lw 线宽的一半
        float w = config_w / 2, l = config_lw / 2, lw = l - w; // lw : internal / l : external

        bool isClosed = f.isClosed;
        vector_float2 * pts = static_cast<vector_float2 *>(f.store());
        
        int j = 0;
        vector_float2 st = pts[num_pts - 1];
        vector_float2 ct = pts[j];
        vector_float2 ed = pts[j + 1];
        vector_float2 SC = simd_normalize(ct - st);
        vector_float2 CE = simd_normalize(ed - ct);
        vector_float2 SC_left  = simd_make_float2( SC.y, -SC.x);
        vector_float2 CE_left  = simd_make_float2( CE.y, -CE.x);
        vector_float2 SC_right = simd_make_float2(-SC.y,  SC.x);
        vector_float2 CE_right = simd_make_float2(-CE.y,  CE.x);
        vector_float2 cur_l_l;
        vector_float2 cur_r_l;
        vector_float2 cur_l_lw;
        vector_float2 cur_r_lw;
        
        int segment = 1;
//        int idx_pre = 0;
        int idx_pre = index_offset;
        int idx_st_l_l = idx_pre+3, idx_st_r_l = idx_pre+1, idx_st_l_lw = idx_pre+2, idx_st_r_lw = idx_pre;
        int idx_r_lw = 0, idx_r_l = 0, idx_l_lw = 0, idx_l_l = 0;
        
        if (!isClosed) {
            if (line_cap_style == LineCap::Round) {
                segment = getSegment(l, M_PI);
                simd_float2x2 mat = getMatPerAngle(segment, M_PI);
                idx_r_lw = idx_pre; idx_r_l = idx_pre+1; idx_l_lw = idx_pre + segment * 2; idx_l_l = idx_l_lw + 1;
                for (int idx = idx_pre; idx < idx_l_lw; idx += 2) {
                    indices.push_back(idx_r_lw); indices.push_back(idx);   indices.push_back(idx+2);
                    indices.push_back(idx);      indices.push_back(idx+1); indices.push_back(idx+2);
                    indices.push_back(idx+1);    indices.push_back(idx+2); indices.push_back(idx+3);
                    cur_r_l  = l  * CE_right + ct; cur_r_lw = lw * CE_right + ct;
                    vertices.push_back({ cur_r_lw, 1});
                    vertices.push_back({ cur_r_l,  0 });
                    CE_right = simd_mul(mat, CE_right);
                }
                cur_l_l  = l  * CE_left  + ct;
                cur_l_lw = lw * CE_left  + ct;
                vertices.push_back({ cur_l_lw, 1 });
                vertices.push_back({ cur_l_l,  0 });
                idx_pre = idx_l_lw + 2;
            }
            else if (line_cap_style == LineCap::Butt) {
                cur_l_l  = l  * CE_left  - w * CE + ct; cur_l_lw = lw * CE_left  + ct;
                cur_r_l  = l  * CE_right - w * CE + ct; cur_r_lw = lw * CE_right + ct;
                vertices.push_back({ cur_r_lw, 1 });
                vertices.push_back({ cur_r_l,  0 });
                vertices.push_back({ cur_l_lw, 1 });
                vertices.push_back({ cur_l_l,  0 });
                idx_r_lw = idx_pre++; idx_r_l = idx_pre++; idx_l_lw = idx_pre++; idx_l_l = idx_pre++;
                indices.push_back(idx_r_lw); indices.push_back(idx_r_l);   indices.push_back(idx_l_lw);
                indices.push_back(idx_r_l);  indices.push_back(idx_l_lw);  indices.push_back(idx_l_l);
            }
            else if (line_cap_style == LineCap::Square) {
                cur_r_l  = l  * (CE_right - CE) + ct; cur_l_l  = l  * (CE_left  - CE) + ct;
                cur_r_lw = lw * (CE_right - CE) + ct; cur_l_lw = lw * (CE_left  - CE) + ct;
                vertices.push_back({ cur_r_lw, 1 });
                vertices.push_back({ cur_r_l,  0 });
                vertices.push_back({ cur_l_lw, 1 });
                vertices.push_back({ cur_l_l,  0 });
                idx_r_lw = idx_pre++; idx_r_l = idx_pre++; idx_l_lw = idx_pre++; idx_l_l = idx_pre++;
                indices.push_back(idx_r_lw); indices.push_back(idx_r_l);   indices.push_back(idx_l_lw);
                indices.push_back(idx_r_l);  indices.push_back(idx_l_lw);  indices.push_back(idx_l_l);
            }
        }
        else {
            float a = acos(simd_dot(SC_left, CE_left)), cos_a_2 = cos(a / 2);; // simd_length(SC_left) * simd_length(CE_left) -> 1
            vector_float2 n_r = simd_normalize(SC_right + CE_right) / cos_a_2;
            vector_float2 n_l = simd_normalize(SC_left + CE_left) / cos_a_2;
            float rotate = simd_cross(SC, CE).z; // rotate > 0 -> right | rotate < 0 -> left
            if (line_join_style == LineJoin::Round) {
                if (rotate > 0) {
                    cur_r_l  = l  * n_r + ct; cur_l_l  = l  * SC_left + ct;
                    cur_r_lw = lw * n_r + ct; cur_l_lw = lw * SC_left + ct;
                    vertices.push_back({ cur_r_lw, 1 }); vertices.push_back({ cur_r_l, 0 });
                    vertices.push_back({ cur_l_lw, 1 }); vertices.push_back({ cur_l_l, 0 });
                    idx_r_lw = idx_pre; idx_r_l = idx_pre + 1; idx_l_lw = idx_pre + 2; idx_l_l = idx_pre + 3;
                    segment = getSegment(l, a);
                    simd_float2x2 mat = getMatPerAngle(segment, a);
                    idx_l_lw += segment * 2;
                    idx_l_l = idx_l_lw + 1;
                    for (int idx = idx_pre + 2; idx < idx_l_lw; idx += 2) {
                        indices.push_back(idx_r_lw); indices.push_back(idx);   indices.push_back(idx+2);
                        indices.push_back(idx);      indices.push_back(idx+1); indices.push_back(idx+2);
                        indices.push_back(idx+1);    indices.push_back(idx+2); indices.push_back(idx+3);
                        SC_left = simd_mul(mat, SC_left);
                        cur_l_lw = lw * SC_left + ct;
                        cur_l_l  = l  * SC_left + ct;
                        vertices.push_back({ cur_l_lw, 1 });
                        vertices.push_back({ cur_l_l,  0 });
                    }
                    idx_pre = idx_l_l + 1;
                }
                else if (rotate < 0) {
                    idx_st_r_lw = idx_pre+2; idx_st_r_l = idx_pre+3;
                    idx_st_l_lw = idx_pre;   idx_st_l_l = idx_pre+1;
                    cur_l_l  = l  * n_l + ct; cur_r_l  = l  * SC_right + ct;
                    cur_l_lw = lw * n_l + ct; cur_r_lw = lw * SC_right + ct;
                    vertices.push_back({ cur_l_lw, 1 }); vertices.push_back({ cur_l_l, 0 });
                    vertices.push_back({ cur_r_lw, 1 }); vertices.push_back({ cur_r_l, 0 });
                    idx_l_lw = idx_pre; idx_l_l = idx_pre+1; idx_r_lw = idx_pre+2; idx_r_l = idx_pre+3;
                    segment = getSegment(l, a);
                    simd_float2x2 mat = getMatPerAngle(segment, -a);
                    idx_r_lw += segment * 2;
                    idx_r_l = idx_r_lw + 1;
                    for (int idx = idx_pre + 2; idx < idx_r_lw; idx+=2) {
                        indices.push_back(idx_l_lw); indices.push_back(idx);   indices.push_back(idx+2);
                        indices.push_back(idx);      indices.push_back(idx+1); indices.push_back(idx+2);
                        indices.push_back(idx+1);    indices.push_back(idx+2); indices.push_back(idx+3);
                        SC_right = simd_mul(mat, SC_right);
                        cur_r_lw = lw * SC_right + ct;
                        cur_r_l  = l  * SC_right + ct;
                        vertices.push_back({ cur_r_lw, 1 });
                        vertices.push_back({ cur_r_l,  0 });
                    }
                    idx_pre = idx_r_l + 1;
                }
            }
            else if (line_join_style == LineJoin::Miter) {
                cur_r_l  = l  * n_r + ct; cur_l_l  = l  * n_l + ct;
                cur_r_lw = lw * n_r + ct; cur_l_lw = lw * n_l + ct;
                vertices.push_back({ cur_r_lw, 1 }); vertices.push_back({ cur_r_l, 0 });
                vertices.push_back({ cur_l_lw, 1 }); vertices.push_back({ cur_l_l, 0 });
                idx_r_lw = idx_pre++; idx_r_l = idx_pre++; idx_l_lw = idx_pre++; idx_l_l = idx_pre++;
            }
            else if (line_join_style == LineJoin::Bevel) {
                if (rotate > 0) {
                    cur_r_l  = l  * n_r + ct; cur_l_l  = l  * SC_left + ct;
                    cur_r_lw = lw * n_r + ct; cur_l_lw = lw * SC_left + ct;
                    vertices.push_back({ cur_r_lw, 1 }); vertices.push_back({ cur_r_l, 0 });
                    vertices.push_back({ cur_l_lw, 1 }); vertices.push_back({ cur_l_l, 0 });
                    cur_l_l  = l  * CE_left + ct;
                    cur_l_lw = lw * CE_left + ct;
                    vertices.push_back({ cur_l_lw, 1 }); vertices.push_back({ cur_l_l, 0 });
                    idx_r_lw = idx_pre++; idx_r_l = idx_pre++; idx_l_lw = idx_pre++; idx_l_l = idx_pre++;
                    indices.push_back(idx_r_lw); indices.push_back(idx_l_lw); indices.push_back(idx_pre);
                    indices.push_back(idx_l_lw); indices.push_back(idx_l_l);  indices.push_back(idx_pre);
                    indices.push_back(idx_l_l);  indices.push_back(idx_pre);  indices.push_back(idx_pre+1);
                    idx_l_lw = idx_pre++; idx_l_l = idx_pre++;
                }
                else if (rotate < 0) {
                    idx_st_r_lw = idx_pre+2; idx_st_r_l = idx_pre+3;
                    idx_st_l_lw = idx_pre;   idx_st_l_l = idx_pre+1;
                    cur_l_l  = l  * n_l + ct; cur_r_l  = l  * SC_right + ct;
                    cur_l_lw = lw * n_l + ct; cur_r_lw = lw * SC_right + ct;
                    vertices.push_back({ cur_l_lw, 1 }); vertices.push_back({ cur_l_l, 0 });
                    vertices.push_back({ cur_r_lw, 1 }); vertices.push_back({ cur_r_l, 0 });
                    cur_r_l  = l  * CE_right + ct;
                    cur_r_lw = lw * CE_right + ct;
                    vertices.push_back({ cur_r_lw, 1 }); vertices.push_back({ cur_r_l, 0 });
                    idx_l_lw = idx_pre++; idx_l_l = idx_pre++; idx_r_lw = idx_pre++; idx_r_l = idx_pre++;
                    indices.push_back(idx_l_lw); indices.push_back(idx_r_lw); indices.push_back(idx_pre);
                    indices.push_back(idx_l_lw); indices.push_back(idx_l_l);  indices.push_back(idx_pre);
                    indices.push_back(idx_l_l);  indices.push_back(idx_pre);  indices.push_back(idx_pre+1);
                    idx_l_lw = idx_pre++; idx_l_l = idx_pre++;
                }
            }
        }
        
        for (j = 1; j < num_pts - 1; ++j) {
            st = pts[j - 1];
            ct = pts[j];
            ed = pts[j + 1];
            SC = simd_normalize(ct - st);
            CE = simd_normalize(ed - ct);
            SC_left  = simd_make_float2( SC.y, -SC.x);
            CE_left  = simd_make_float2( CE.y, -CE.x);
            SC_right = simd_make_float2(-SC.y,  SC.x);
            CE_right = simd_make_float2(-CE.y,  CE.x);
            float a = acos(simd_dot(SC_left, CE_left)), cos_a_2 = cos(a / 2);; // simd_length(SC_left) * simd_length(CE_left) -> 1
            vector_float2 n_r = simd_normalize(SC_right + CE_right) / cos_a_2;
            vector_float2 n_l = simd_normalize(SC_left + CE_left) / cos_a_2;
            float rotate = simd_cross(SC, CE).z; // rotate > 0 -> right | rotate < 0 -> left
            if (line_join_style == LineJoin::Round) {
                if (rotate > 0) {
                    cur_r_l  = l  * n_r + ct; cur_l_l  = l  * SC_left + ct;
                    cur_r_lw = lw * n_r + ct; cur_l_lw = lw * SC_left + ct;
                    vertices.push_back({ cur_r_lw, 1 }); vertices.push_back({ cur_r_l, 0 });
                    vertices.push_back({ cur_l_lw, 1 }); vertices.push_back({ cur_l_l, 0 });
                    indices.push_back(idx_r_lw); indices.push_back(idx_r_l);     indices.push_back(idx_pre);
                    indices.push_back(idx_r_l);  indices.push_back(idx_pre);     indices.push_back(idx_pre+1);
                    indices.push_back(idx_l_lw); indices.push_back(idx_l_l);     indices.push_back(idx_pre+2);
                    indices.push_back(idx_l_l);  indices.push_back(idx_pre+2); indices.push_back(idx_pre+3);
                    indices.push_back(idx_r_lw); indices.push_back(idx_l_lw);    indices.push_back(idx_pre);
                    indices.push_back(idx_l_lw); indices.push_back(idx_pre);     indices.push_back(idx_pre+2);
                    idx_r_lw = idx_pre; idx_r_l = idx_pre + 1; idx_l_lw = idx_pre + 2; idx_l_l = idx_pre + 3;
                    segment = getSegment(l, a);
                    simd_float2x2 mat = getMatPerAngle(segment, a);
                    idx_l_lw += segment * 2;
                    idx_l_l = idx_l_lw + 1;
                    for (int idx = idx_pre + 2; idx < idx_l_lw; idx += 2) {
                        indices.push_back(idx_r_lw); indices.push_back(idx);   indices.push_back(idx+2);
                        indices.push_back(idx);      indices.push_back(idx+1); indices.push_back(idx+2);
                        indices.push_back(idx+1);    indices.push_back(idx+2); indices.push_back(idx+3);
                        SC_left = simd_mul(mat, SC_left);
                        cur_l_lw = lw * SC_left + ct;
                        cur_l_l  = l  * SC_left + ct;
                        vertices.push_back({ cur_l_lw, 1 });
                        vertices.push_back({ cur_l_l,  0 });
                    }
                    idx_pre = idx_l_l + 1;
                }
                else if (rotate < 0) {
                    cur_l_l  = l  * n_l + ct; cur_r_l  = l  * SC_right + ct;
                    cur_l_lw = lw * n_l + ct; cur_r_lw = lw * SC_right + ct;
                    vertices.push_back({ cur_l_lw, 1 }); vertices.push_back({ cur_l_l, 0 });
                    vertices.push_back({ cur_r_lw, 1 }); vertices.push_back({ cur_r_l, 0 });
                    indices.push_back(idx_r_lw); indices.push_back(idx_r_l);     indices.push_back(idx_pre+2);
                    indices.push_back(idx_r_l);  indices.push_back(idx_pre+2);   indices.push_back(idx_pre+3);
                    indices.push_back(idx_l_lw); indices.push_back(idx_l_l);     indices.push_back(idx_pre);
                    indices.push_back(idx_l_l);  indices.push_back(idx_pre);     indices.push_back(idx_pre+1);
                    indices.push_back(idx_r_lw); indices.push_back(idx_l_lw);    indices.push_back(idx_pre+2);
                    indices.push_back(idx_l_lw); indices.push_back(idx_pre+2);   indices.push_back(idx_pre);
                    idx_l_lw = idx_pre; idx_l_l = idx_pre+1; idx_r_lw = idx_pre+2; idx_r_l = idx_pre+3;
                    segment = getSegment(l, a);
                    simd_float2x2 mat = getMatPerAngle(segment, -a);
                    idx_r_lw += segment * 2;
                    idx_r_l = idx_r_lw + 1;
                    for (int idx = idx_pre + 2; idx < idx_r_lw; idx+=2) {
                        indices.push_back(idx_l_lw); indices.push_back(idx);   indices.push_back(idx+2);
                        indices.push_back(idx);      indices.push_back(idx+1); indices.push_back(idx+2);
                        indices.push_back(idx+1);    indices.push_back(idx+2); indices.push_back(idx+3);
                        SC_right = simd_mul(mat, SC_right);
                        cur_r_lw = lw * SC_right + ct;
                        cur_r_l  = l  * SC_right + ct;
                        vertices.push_back({ cur_r_lw, 1 });
                        vertices.push_back({ cur_r_l,  0 });
                    }
                    idx_pre = idx_r_l + 1;
                }
            }
            else if (line_join_style == LineJoin::Miter) {
                cur_r_l  = l  * n_r + ct; cur_l_l  = l  * n_l + ct;
                cur_r_lw = lw * n_r + ct; cur_l_lw = lw * n_l + ct;
                vertices.push_back({ cur_r_lw, 1 }); vertices.push_back({ cur_r_l, 0 });
                vertices.push_back({ cur_l_lw, 1 }); vertices.push_back({ cur_l_l, 0 });
                indices.push_back(idx_r_lw); indices.push_back(idx_r_l);     indices.push_back(idx_pre);
                indices.push_back(idx_r_l);  indices.push_back(idx_pre);     indices.push_back(idx_pre + 1);
                indices.push_back(idx_l_lw); indices.push_back(idx_l_l);     indices.push_back(idx_pre + 2);
                indices.push_back(idx_l_l);  indices.push_back(idx_pre + 2); indices.push_back(idx_pre + 3);
                indices.push_back(idx_r_lw); indices.push_back(idx_l_lw);    indices.push_back(idx_pre);
                indices.push_back(idx_l_lw); indices.push_back(idx_pre);     indices.push_back(idx_pre + 2);
                idx_r_lw = idx_pre++; idx_r_l = idx_pre++; idx_l_lw = idx_pre++; idx_l_l = idx_pre++;
            }
            else if (line_join_style == LineJoin::Bevel) {
                if (rotate > 0) {
                    cur_r_l  = l  * n_r + ct; cur_l_l  = l  * SC_left + ct;
                    cur_r_lw = lw * n_r + ct; cur_l_lw = lw * SC_left + ct;
                    vertices.push_back({ cur_r_lw, 1 }); vertices.push_back({ cur_r_l, 0 });
                    vertices.push_back({ cur_l_lw, 1 }); vertices.push_back({ cur_l_l, 0 });
                    indices.push_back(idx_r_lw); indices.push_back(idx_r_l);     indices.push_back(idx_pre);
                    indices.push_back(idx_r_l);  indices.push_back(idx_pre);     indices.push_back(idx_pre + 1);
                    indices.push_back(idx_l_lw); indices.push_back(idx_l_l);     indices.push_back(idx_pre + 2);
                    indices.push_back(idx_l_l);  indices.push_back(idx_pre + 2); indices.push_back(idx_pre + 3);
                    indices.push_back(idx_r_lw); indices.push_back(idx_l_lw);    indices.push_back(idx_pre);
                    indices.push_back(idx_l_lw); indices.push_back(idx_pre);     indices.push_back(idx_pre + 2);
                    idx_r_lw = idx_pre++; idx_r_l = idx_pre++; idx_l_lw = idx_pre++; idx_l_l = idx_pre++;
                    cur_l_lw = lw * CE_left + ct;
                    cur_l_l  = l  * CE_left + ct;
                    vertices.push_back({ cur_l_lw, 1 }); vertices.push_back({ cur_l_l, 0 });
                    indices.push_back(idx_l_lw); indices.push_back(idx_l_l);     indices.push_back(idx_l_l+1);
                    indices.push_back(idx_l_l);  indices.push_back(idx_l_l+1);   indices.push_back(idx_l_l+2);
                    indices.push_back(idx_r_lw); indices.push_back(idx_l_lw);    indices.push_back(idx_l_lw+2);
                    idx_l_lw = idx_pre++; idx_l_l = idx_pre++;
                }
                else if (rotate < 0) {
                    cur_r_l  = l  * SC_right + ct; cur_l_l  = l  * n_l + ct;
                    cur_r_lw = lw * SC_right + ct; cur_l_lw = lw * n_l + ct;
                    vertices.push_back({ cur_r_lw, 1 }); vertices.push_back({ cur_r_l, 0 });
                    vertices.push_back({ cur_l_lw, 1 }); vertices.push_back({ cur_l_l, 0 });
                    indices.push_back(idx_r_lw); indices.push_back(idx_r_l);     indices.push_back(idx_pre);
                    indices.push_back(idx_r_l);  indices.push_back(idx_pre);     indices.push_back(idx_pre + 1);
                    indices.push_back(idx_l_lw); indices.push_back(idx_l_l);     indices.push_back(idx_pre + 2);
                    indices.push_back(idx_l_l);  indices.push_back(idx_pre + 2); indices.push_back(idx_pre + 3);
                    indices.push_back(idx_r_lw); indices.push_back(idx_l_lw);    indices.push_back(idx_pre);
                    indices.push_back(idx_l_lw); indices.push_back(idx_pre);     indices.push_back(idx_pre + 2);
                    idx_r_lw = idx_pre++; idx_r_l = idx_pre++; idx_l_lw = idx_pre++; idx_l_l = idx_pre++;
                    cur_r_lw = lw * CE_right + ct;
                    cur_r_l  = l  * CE_right + ct;
                    vertices.push_back({ cur_r_lw, 1 }); vertices.push_back({ cur_r_l, 0 });
                    indices.push_back(idx_r_lw); indices.push_back(idx_r_l);     indices.push_back(idx_l_l+1);
                    indices.push_back(idx_r_l);  indices.push_back(idx_l_l+1);   indices.push_back(idx_l_l+2);
                    indices.push_back(idx_r_lw); indices.push_back(idx_l_lw);    indices.push_back(idx_l_lw+2);
                    idx_r_lw = idx_pre++; idx_r_l = idx_pre++;
                }
            }
        }
        
        st = pts[j - 1];
        ct = pts[j];
        ed = pts[0];
        SC = simd_normalize(ct - st);
        CE = simd_normalize(ed - ct);
        SC_left  = simd_make_float2( SC.y, -SC.x);
        SC_right = simd_make_float2(-SC.y,  SC.x);
        CE_left  = simd_make_float2( CE.y, -CE.x);
        CE_right = simd_make_float2(-CE.y,  CE.x);
        if (!isClosed) {
            if (line_cap_style == LineCap::Round) {
                cur_l_lw = lw * SC_left  + ct;
                cur_l_l  = l  * SC_left  + ct;
                vertices.push_back({ cur_l_lw, 1 }); vertices.push_back({ cur_l_l, 0 });
                indices.push_back(idx_l_lw); indices.push_back(idx_l_l);  indices.push_back(idx_pre);
                indices.push_back(idx_l_l);  indices.push_back(idx_pre);  indices.push_back(idx_pre+1);
                indices.push_back(idx_l_lw); indices.push_back(idx_r_lw); indices.push_back(idx_pre);
                idx_l_lw = idx_pre; idx_l_l = idx_pre+1;
                segment = getSegment(l, M_PI);
                simd_float2x2 mat = getMatPerAngle(segment, M_PI);
                idx_pre += segment * 2;
                indices.push_back(idx_r_lw); indices.push_back(idx_l_lw); indices.push_back(idx_pre);
                indices.push_back(idx_r_lw); indices.push_back(idx_r_l);  indices.push_back(idx_pre);
                indices.push_back(idx_r_l);  indices.push_back(idx_pre);  indices.push_back(idx_pre+1);
                idx_r_lw = idx_pre; idx_r_l = idx_r_lw + 1;
                for (int idx = idx_l_lw; idx < idx_r_lw; idx+=2) {
                    indices.push_back(idx_r_lw); indices.push_back(idx);   indices.push_back(idx+2);
                    indices.push_back(idx);      indices.push_back(idx+1); indices.push_back(idx+2);
                    indices.push_back(idx+1);    indices.push_back(idx+2); indices.push_back(idx+3);
                    SC_left = simd_mul(mat, SC_left);
                    cur_l_lw = lw * SC_left + ct;
                    cur_l_l  = l  * SC_left + ct;
                    vertices.push_back({ cur_l_lw, 1 });
                    vertices.push_back({ cur_l_l,  0 });
                }
                idx_pre = idx_r_l + 1;
            }
            else if (line_cap_style == LineCap::Butt) {
                cur_l_lw = lw * SC_left  + ct;
                cur_r_lw = lw * SC_right + ct;
                cur_l_l  = l  * SC_left  + w * SC + ct;
                cur_r_l  = l  * SC_right + w * SC + ct;
                vertices.push_back({ cur_r_lw, 1 });
                vertices.push_back({ cur_r_l,  0 });
                vertices.push_back({ cur_l_lw, 1 });
                vertices.push_back({ cur_l_l,  0 });
                indices.push_back(idx_r_lw); indices.push_back(idx_r_l);   indices.push_back(idx_pre);
                indices.push_back(idx_r_l);  indices.push_back(idx_pre);   indices.push_back(idx_pre+1);
                indices.push_back(idx_l_lw); indices.push_back(idx_l_l);   indices.push_back(idx_pre+2);
                indices.push_back(idx_l_l);  indices.push_back(idx_pre+2); indices.push_back(idx_pre+3);
                indices.push_back(idx_r_lw); indices.push_back(idx_l_lw);  indices.push_back(idx_pre);
                indices.push_back(idx_l_lw); indices.push_back(idx_pre);   indices.push_back(idx_pre+2);
                idx_r_lw = idx_pre++; idx_r_l = idx_pre++; idx_l_lw = idx_pre++; idx_l_l = idx_pre++;
                indices.push_back(idx_r_lw);  indices.push_back(idx_l_lw);  indices.push_back(idx_r_l);
                indices.push_back(idx_l_lw);  indices.push_back(idx_r_l);   indices.push_back(idx_l_l);
            }
            else if (line_cap_style == LineCap::Square) {
                cur_l_lw = lw * (SC_left  + SC) + ct;
                cur_r_lw = lw * (SC_right + SC) + ct;
                cur_l_l  = l  * (SC_left  + SC) + ct;
                cur_r_l  = l  * (SC_right + SC) + ct;
                vertices.push_back({ cur_r_lw, 1 });
                vertices.push_back({ cur_r_l,  0 });
                vertices.push_back({ cur_l_lw, 1 });
                vertices.push_back({ cur_l_l,  0 });
                indices.push_back(idx_r_lw); indices.push_back(idx_r_l);   indices.push_back(idx_pre);
                indices.push_back(idx_r_l);  indices.push_back(idx_pre);   indices.push_back(idx_pre+1);
                indices.push_back(idx_l_lw); indices.push_back(idx_l_l);   indices.push_back(idx_pre+2);
                indices.push_back(idx_l_l);  indices.push_back(idx_pre+2); indices.push_back(idx_pre+3);
                indices.push_back(idx_r_lw); indices.push_back(idx_l_lw);  indices.push_back(idx_pre);
                indices.push_back(idx_l_lw); indices.push_back(idx_pre);   indices.push_back(idx_pre+2);
                idx_r_lw = idx_pre++; idx_r_l = idx_pre++; idx_l_lw = idx_pre++; idx_l_l = idx_pre++;
                indices.push_back(idx_r_lw);  indices.push_back(idx_l_lw);  indices.push_back(idx_r_l);
                indices.push_back(idx_l_lw);  indices.push_back(idx_r_l);   indices.push_back(idx_l_l);
            }
        }
        else {
            float a = acos(simd_dot(SC_left, CE_left)), cos_a_2 = cos(a / 2);; // simd_length(SC_left) * simd_length(CE_left) -> 1
            vector_float2 n_r = simd_normalize(SC_right + CE_right) / cos_a_2;
            vector_float2 n_l = simd_normalize(SC_left + CE_left) / cos_a_2;
            float rotate = simd_cross(SC, CE).z; // rotate > 0 -> right | rotate < 0 -> left
            if (line_join_style == LineJoin::Round) {
                if (rotate > 0) {
                    cur_r_l  = l  * n_r + ct; cur_l_l  = l  * SC_left + ct;
                    cur_r_lw = lw * n_r + ct; cur_l_lw = lw * SC_left + ct;
                    vertices.push_back({ cur_r_lw, 1 }); vertices.push_back({ cur_r_l, 0 });
                    vertices.push_back({ cur_l_lw, 1 }); vertices.push_back({ cur_l_l, 0 });
                    indices.push_back(idx_r_lw); indices.push_back(idx_r_l);     indices.push_back(idx_pre);
                    indices.push_back(idx_r_l);  indices.push_back(idx_pre);     indices.push_back(idx_pre+1);
                    indices.push_back(idx_l_lw); indices.push_back(idx_l_l);     indices.push_back(idx_pre+2);
                    indices.push_back(idx_l_l);  indices.push_back(idx_pre+2); indices.push_back(idx_pre+3);
                    indices.push_back(idx_r_lw); indices.push_back(idx_l_lw);    indices.push_back(idx_pre);
                    indices.push_back(idx_l_lw); indices.push_back(idx_pre);     indices.push_back(idx_pre+2);
                    idx_r_lw = idx_pre; idx_r_l = idx_pre + 1; idx_l_lw = idx_pre + 2; idx_l_l = idx_pre + 3;
                    segment = getSegment(l, a);
                    simd_float2x2 mat = getMatPerAngle(segment, a);
                    idx_l_lw += segment * 2;
                    idx_l_l = idx_l_lw + 1;
                    for (int idx = idx_pre + 2; idx < idx_l_lw; idx += 2) {
                        indices.push_back(idx_r_lw); indices.push_back(idx);   indices.push_back(idx+2);
                        indices.push_back(idx);      indices.push_back(idx+1); indices.push_back(idx+2);
                        indices.push_back(idx+1);    indices.push_back(idx+2); indices.push_back(idx+3);
                        SC_left = simd_mul(mat, SC_left);
                        cur_l_lw = lw * SC_left + ct;
                        cur_l_l  = l  * SC_left + ct;
                        vertices.push_back({ cur_l_lw, 1 });
                        vertices.push_back({ cur_l_l,  0 });
                    }
                    idx_pre = idx_l_l + 1;
                }
                else if (rotate < 0) {
                    cur_l_l  = l  * n_l + ct; cur_r_l  = l  * SC_right + ct;
                    cur_l_lw = lw * n_l + ct; cur_r_lw = lw * SC_right + ct;
                    vertices.push_back({ cur_l_lw, 1 }); vertices.push_back({ cur_l_l, 0 });
                    vertices.push_back({ cur_r_lw, 1 }); vertices.push_back({ cur_r_l, 0 });
                    indices.push_back(idx_r_lw); indices.push_back(idx_r_l);     indices.push_back(idx_pre+2);
                    indices.push_back(idx_r_l);  indices.push_back(idx_pre+2);   indices.push_back(idx_pre+3);
                    indices.push_back(idx_l_lw); indices.push_back(idx_l_l);     indices.push_back(idx_pre);
                    indices.push_back(idx_l_l);  indices.push_back(idx_pre);     indices.push_back(idx_pre+1);
                    indices.push_back(idx_r_lw); indices.push_back(idx_l_lw);    indices.push_back(idx_pre+2);
                    indices.push_back(idx_l_lw); indices.push_back(idx_pre+2);   indices.push_back(idx_pre);
                    idx_l_lw = idx_pre; idx_l_l = idx_pre+1; idx_r_lw = idx_pre+2; idx_r_l = idx_pre+3;
                    segment = getSegment(l, a);
                    simd_float2x2 mat = getMatPerAngle(segment, -a);
                    idx_r_lw += segment * 2;
                    idx_r_l = idx_r_lw + 1;
                    for (int idx = idx_pre + 2; idx < idx_r_lw; idx+=2) {
                        indices.push_back(idx_l_lw); indices.push_back(idx);   indices.push_back(idx+2);
                        indices.push_back(idx);      indices.push_back(idx+1); indices.push_back(idx+2);
                        indices.push_back(idx+1);    indices.push_back(idx+2); indices.push_back(idx+3);
                        SC_right = simd_mul(mat, SC_right);
                        cur_r_lw = lw * SC_right + ct;
                        cur_r_l  = l  * SC_right + ct;
                        vertices.push_back({ cur_r_lw, 1 });
                        vertices.push_back({ cur_r_l,  0 });
                    }
                    idx_pre = idx_r_l + 1;
                }
            }
            else if (line_join_style == LineJoin::Miter) {
                cur_r_l  = l  * n_r + ct; cur_l_l  = l  * n_l + ct;
                cur_r_lw = lw * n_r + ct; cur_l_lw = lw * n_l + ct;
                vertices.push_back({ cur_r_lw, 1 }); vertices.push_back({ cur_r_l, 0 });
                vertices.push_back({ cur_l_lw, 1 }); vertices.push_back({ cur_l_l, 0 });
                indices.push_back(idx_r_lw); indices.push_back(idx_r_l);     indices.push_back(idx_pre);
                indices.push_back(idx_r_l);  indices.push_back(idx_pre);     indices.push_back(idx_pre + 1);
                indices.push_back(idx_l_lw); indices.push_back(idx_l_l);     indices.push_back(idx_pre + 2);
                indices.push_back(idx_l_l);  indices.push_back(idx_pre + 2); indices.push_back(idx_pre + 3);
                indices.push_back(idx_r_lw); indices.push_back(idx_l_lw);    indices.push_back(idx_pre);
                indices.push_back(idx_l_lw); indices.push_back(idx_pre);     indices.push_back(idx_pre + 2);
                idx_r_lw = idx_pre++; idx_r_l = idx_pre++; idx_l_lw = idx_pre++; idx_l_l = idx_pre++;
            }
            else if (line_join_style == LineJoin::Bevel) {
                if (rotate > 0) {
                    cur_r_l  = l  * n_r + ct; cur_l_l  = l  * SC_left + ct;
                    cur_r_lw = lw * n_r + ct; cur_l_lw = lw * SC_left + ct;
                    vertices.push_back({ cur_r_lw, 1 }); vertices.push_back({ cur_r_l, 0 });
                    vertices.push_back({ cur_l_lw, 1 }); vertices.push_back({ cur_l_l, 0 });
                    indices.push_back(idx_r_lw); indices.push_back(idx_r_l);     indices.push_back(idx_pre);
                    indices.push_back(idx_r_l);  indices.push_back(idx_pre);     indices.push_back(idx_pre + 1);
                    indices.push_back(idx_l_lw); indices.push_back(idx_l_l);     indices.push_back(idx_pre + 2);
                    indices.push_back(idx_l_l);  indices.push_back(idx_pre + 2); indices.push_back(idx_pre + 3);
                    indices.push_back(idx_r_lw); indices.push_back(idx_l_lw);    indices.push_back(idx_pre);
                    indices.push_back(idx_l_lw); indices.push_back(idx_pre);     indices.push_back(idx_pre + 2);
                    idx_r_lw = idx_pre++; idx_r_l = idx_pre++; idx_l_lw = idx_pre++; idx_l_l = idx_pre++;
                    cur_l_lw = lw * CE_left + ct;
                    cur_l_l  = l  * CE_left + ct;
                    vertices.push_back({ cur_l_lw, 1 }); vertices.push_back({ cur_l_l, 0 });
                    indices.push_back(idx_l_lw); indices.push_back(idx_l_l);     indices.push_back(idx_l_l+1);
                    indices.push_back(idx_l_l);  indices.push_back(idx_l_l+1);   indices.push_back(idx_l_l+2);
                    indices.push_back(idx_r_lw); indices.push_back(idx_l_lw);    indices.push_back(idx_l_lw+2);
                    idx_l_lw = idx_pre++; idx_l_l = idx_pre++;
                }
                else if (rotate < 0) {
                    cur_r_l  = l  * SC_right + ct; cur_l_l  = l  * n_l + ct;
                    cur_r_lw = lw * SC_right + ct; cur_l_lw = lw * n_l + ct;
                    vertices.push_back({ cur_r_lw, 1 }); vertices.push_back({ cur_r_l, 0 });
                    vertices.push_back({ cur_l_lw, 1 }); vertices.push_back({ cur_l_l, 0 });
                    indices.push_back(idx_r_lw); indices.push_back(idx_r_l);     indices.push_back(idx_pre);
                    indices.push_back(idx_r_l);  indices.push_back(idx_pre);     indices.push_back(idx_pre + 1);
                    indices.push_back(idx_l_lw); indices.push_back(idx_l_l);     indices.push_back(idx_pre + 2);
                    indices.push_back(idx_l_l);  indices.push_back(idx_pre + 2); indices.push_back(idx_pre + 3);
                    indices.push_back(idx_r_lw); indices.push_back(idx_l_lw);    indices.push_back(idx_pre);
                    indices.push_back(idx_l_lw); indices.push_back(idx_pre);     indices.push_back(idx_pre + 2);
                    idx_r_lw = idx_pre++; idx_r_l = idx_pre++; idx_l_lw = idx_pre++; idx_l_l = idx_pre++;
                    cur_r_lw = lw * CE_right + ct;
                    cur_r_l  = l  * CE_right + ct;
                    vertices.push_back({ cur_r_lw, 1 }); vertices.push_back({ cur_r_l, 0 });
                    indices.push_back(idx_r_lw); indices.push_back(idx_r_l);     indices.push_back(idx_l_l+1);
                    indices.push_back(idx_r_l);  indices.push_back(idx_l_l+1);   indices.push_back(idx_l_l+2);
                    indices.push_back(idx_r_lw); indices.push_back(idx_l_lw);    indices.push_back(idx_l_lw+2);
                    idx_r_lw = idx_pre++; idx_r_l = idx_pre++;
                }
            }
            indices.push_back(idx_r_lw); indices.push_back(idx_r_l);     indices.push_back(idx_st_r_lw);
            indices.push_back(idx_r_l);  indices.push_back(idx_st_r_lw); indices.push_back(idx_st_r_l);
            indices.push_back(idx_l_lw); indices.push_back(idx_l_l);     indices.push_back(idx_st_l_lw);
            indices.push_back(idx_l_l);  indices.push_back(idx_st_l_lw); indices.push_back(idx_st_l_l);
            indices.push_back(idx_r_lw); indices.push_back(idx_l_lw);    indices.push_back(idx_st_r_lw);
            indices.push_back(idx_l_lw); indices.push_back(idx_st_r_lw); indices.push_back(idx_st_l_lw);
        }
        index_offset = (int)vertices.size();
    }
    item.vertices = vertices;
    item.indices = indices;
    return;
}
}
