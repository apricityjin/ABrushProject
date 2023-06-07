//
//  Point.hpp
//  ABrush
//
//  Created by apricity on 2023/6/7.
//

#ifndef Point_hpp
#define Point_hpp

namespace ABrush
{
    class Point
    {
    public:
        float x = 0.0;
        float y = 0.0;

    public:
        Point();

        virtual ~Point();

        Point(float x, float y);

        Point operator+(Point &p) const;

        Point operator-(Point &p);

        Point operator*(Point &p);

        Point operator/(Point &p);

        void setXY(float x, float y);
    };
}

#endif /* Point_hpp */
