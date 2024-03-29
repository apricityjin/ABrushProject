//
// Created by apricity on 2023/6/13.
//

#ifndef PATH_HPP
#define PATH_HPP

#include <vector>
#include "APoint.hpp"

namespace ABrush
{

void recursive_bezier(std::vector<APoint> &bezierPoints,
                      int depth,
                      APoint &p0, APoint &p1, APoint &p2, APoint &p3);

void bezier(std::vector<APoint> &bezierPoints,
            APoint &start,
            APoint &p1,
            APoint &p2,
            APoint &end);

struct Flatten
{
    std::vector<APoint> points;
    bool               isClosed;
    size_t size; // 这个参数指的是Path内部的线条数，放在这里方便就这样写了，后续需要改
    void *store() const;
    
};

struct Path
{
    enum class Command {
        MoveTo,
        LineTo,
        CurveTo,
        Close,
    };
    
    std::vector<APoint>   points;
    std::vector<Command> commands;
    
    APoint start = {0, 0};
    
    Path &moveTo(APoint &p);
    Path &lineTo(APoint &p);
    Path &quadTo(APoint &p1, APoint &endPoint);
    Path &curveTo(APoint &p1, APoint &p2, APoint &endPoint);
    Path &close();
    
    Path &addRectangle(APoint &p, float width, float height);
    
    
    // 这里以后需要舍弃
    struct Contour
    {
        uint32_t pointIndex   = 0;
        uint32_t commandIndex = 0;
        bool     close        = false;
    };
    
    std::vector<Contour> contours;
    
    Path();
    
    
    Path &moveTo(float x, float y);
    
    Path &lineTo(float x, float y);
    
    Path &curveTo(float x1, float y1,
                  float x2, float y2,
                  float end_x, float end_y);
    
    void reset();
    
    Flatten *flatten();
    
    
    
};
}

#endif //ABRUSH_PATH_H
