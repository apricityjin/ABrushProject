//
//  Point.cpp
//  ABrush
//
//  Created by apricity on 2023/6/7.
//

#include "Point.hpp"

namespace ABrush
{
    Point::Point(float x, float y) : x(x), y(y)
    {}

    Point::~Point()
    = default;

    Point::Point()
    = default;

    Point Point::operator+(Point &p) const
    {
        return Point(this->x + p.x, this->y + p.y);
    }

    Point Point::operator-(Point &p)
    {
        return Point(this->x - p.x, this->y - p.y);
    }

    Point Point::operator*(Point &p)
    {
        return Point(this->x * p.x, this->y * p.y);
    }

    Point Point::operator/(Point &p)
    {
        return Point(this->x / p.x, this->y / p.y);
    }

    void Point::setXY(float new_x, float new_y)
    {
        x = new_x;
        y = new_y;
    }
}
