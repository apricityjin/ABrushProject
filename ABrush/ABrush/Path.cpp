//
//  Path.cpp
//  ABrush
//
//  Created by Apricity on 2023/7/10.
//

#include "Path.hpp"
#include <cmath>

namespace ABrush
{

void recursive_bezier(std::vector<APoint> &bezierPoints,
                      int depth,
                      APoint &p0, APoint &p1, APoint &p2, APoint &p3)
{
    if (depth >= 20) {
        return;
    }
    APoint p01        = (p0 + p1) / 2,
    p12        = (p1 + p2) / 2,
    p23        = (p2 + p3) / 2;
    APoint p012       = (p01 + p12) / 2,
    p123       = (p12 + p23) / 2;
    APoint p0123      = (p012 + p123) / 2;
    float dx         = p3.x - p0.x, dy = p3.y - p0.y;
    float d1         = fabs((p1.x - p3.x) * dy - (p1.y - p3.y) * dx);
    float d2         = fabs((p2.x - p3.x) * dy - (p2.y - p3.y) * dx);
    float m_distance = 1;
    if ((d1 + d2) * (d1 + d2) < m_distance * (dx * dx + dy * dy)) {
        bezierPoints.push_back(p0123);
        return;
    }
    recursive_bezier(bezierPoints,
                     depth + 1,
                     p0, p01, p012, p0123);
    recursive_bezier(bezierPoints,
                     depth + 1,
                     p0123, p123, p23, p3);
}


void bezier(std::vector<APoint> &bezierPoints,
            APoint &start,
            APoint &p1,
            APoint &p2,
            APoint &end)
{
    //        bezierPoints.emplace_back(start);
    recursive_bezier(bezierPoints,
                     0,
                     start, p1, p2, end);
    bezierPoints.emplace_back(end);
}

float *Flatten::store() const
{
    size_t points_count = points.size();
    float  *m;
    m = (float *) calloc(points_count * 2, sizeof(float));
    for (int i = 0; i < points_count; ++i) {
        m[i * 2]     = points.at(i).x;
        m[i * 2 + 1] = points.at(i).y;
    }
    return m;
}

Path::Path()
= default;

Path &Path::moveTo(APoint &p)
{
    Contour c;
    c.commandIndex = commands.size();
    c.pointIndex   = points.size();
    contours.push_back(c);
    commands.push_back(Command::MoveTo);
    points.push_back(p);
    return *this;
}

Path &Path::lineTo(APoint &p)
{
    commands.push_back(Command::LineTo);
    points.push_back(p);
    return *this;
}

Path &Path::close()
{
    Contour *c = nullptr;
    if (!contours.empty()) {
        c = &contours.back();
    }
    c->close = true;
    points.push_back(this->points.at(c->pointIndex));
    commands.push_back(Command::Close);
    return *this;
}

Path &Path::curveTo(APoint &p1, APoint &p2, APoint &endPoint)
{
    commands.push_back(Command::CurveTo);
    points.push_back(p1);
    points.push_back(p2);
    points.push_back(endPoint);
    return *this;
}

Path &Path::moveTo(float x, float y)
{
    APoint p = APoint(x, y);
    moveTo(p);
    return *this;
}

Path &Path::lineTo(float x, float y)
{
    APoint p = APoint(x, y);
    lineTo(p);
    return *this;
}

Path &Path::curveTo(float x1, float y1,
              float x2, float y2,
              float end_x, float end_y)
{
    APoint p1       = APoint(x1, y1);
    APoint p2       = APoint(x2, y2);
    APoint endPoint = APoint(end_x, end_y);
    curveTo(p1, p2, endPoint);
    return *this;
}

Flatten *Path::flatten()
{
    Flatten *flattens = (Flatten *) calloc(contours.size(), sizeof(Flatten));
    int ptIdx     = 0;
    int PathCount = -1;
    
    for (Command &cmd: commands) {
        switch (cmd) {
                
            case Command::MoveTo:
                PathCount += 1;
                flattens[PathCount].points.push_back(points.at(ptIdx));
                flattens[PathCount].size = contours.size();
                ptIdx++;
                break;
            case Command::LineTo:
                flattens[PathCount].points.push_back(points.at(ptIdx));
                ptIdx++;
                break;
            case Command::CurveTo:
                bezier(flattens[PathCount].points,
                       points.at(ptIdx - 1),
                       points.at(ptIdx),
                       points.at(ptIdx + 1),
                       points.at(ptIdx + 2));
                ptIdx += 3;
                break;
            case Command::Close:
                flattens[PathCount].points.push_back(flattens[PathCount].points.at(0));
                flattens[PathCount].isClosed = true;
                ptIdx++;
                break;
        }
    }
    return flattens;
}

}
