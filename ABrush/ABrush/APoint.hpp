//
// Created by apricity on 2023/6/13.
//

#ifndef APOINT_HPP
#define APOINT_HPP

#include <vector>

namespace ABrush
{
template<class T>
typename std::enable_if<!std::numeric_limits<T>::is_integer, bool>::type
almost_equal(T x, T y);

/**
 坐标系定义：
 以屏幕左上角为原点，沿屏幕水平向右为 X轴正方向，
 以屏幕左上角为原点，沿屏幕垂直向下为 Y轴正方向。
 */
struct APoint
{
    
    APoint();
    
    APoint(float x, float y);
    
    APoint(float x, float y, bool normalize);
    
    APoint(const APoint &aVector2);
    
    APoint(const APoint &aVector2, bool normalize);
    
    void set(float aX, float aY);
    
    void set(const APoint &aVector2);
    
    float length() const;
    
    void normalize();
    
    APoint &normalized();
    
    APoint operator+(const APoint &aVector2) const;
    
    APoint &operator+=(const APoint &aVector2);
    
    APoint operator-(const APoint &aVector2) const;
    
    APoint &operator-=(const APoint &aVector2);
    
    APoint operator*(float s) const;
    
    APoint &operator*=(float s);
    
    APoint operator*(const APoint &aVector2) const;
    
    APoint &operator*=(const APoint &aVector2);
    
    APoint operator/(float s) const;
    
    APoint &operator/=(float s);
    
    APoint operator/(const APoint &aVector2) const;
    
    APoint &operator/=(const APoint &aVector2);
    
    APoint operator-() const;
    
    bool operator==(const APoint &aVector2) const;
    
    bool operator!=(const APoint &aVector2) const;
    
    float x, y;
    static const size_t size = 2;
};

typedef APoint Normal;
typedef APoint Tangent;
}


#endif //ABRUSH_APOINT_H
