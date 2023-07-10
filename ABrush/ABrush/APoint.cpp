//
//  APoint.cpp
//  ABrush
//
//  Created by Apricity on 2023/7/10.
//

#include "APoint.hpp"

namespace ABrush
{

template<class T>
typename std::enable_if<!std::numeric_limits<T>::is_integer, bool>::type
almost_equal(T x, T y)
{
    return std::fabs(x - y) <= std::numeric_limits<T>::epsilon() * std::fabs(x + y) * 2 ||
    std::fabs(x - y) < std::numeric_limits<T>::min();
}

APoint::APoint() : x(0.0), y(0.0)
{}

APoint::APoint(float x, float y) : x(x), y(y)
{}

APoint::APoint(float x, float y, bool normalize) : x(x), y(y)
{
    if (normalize) {
        this->normalize();
    }
}

APoint::APoint(const APoint &aVector2) : x(aVector2.x), y(aVector2.y)
{}

APoint::APoint(const APoint &aVector2, bool normalize) : x(aVector2.x), y(aVector2.y)
{
    if (normalize) {
        this->normalize();
    }
}

void APoint::set(float aX, float aY)
{
    x = aX;
    y = aY;
}

void APoint::set(const APoint &aVector2)
{
    x = aVector2.x;
    y = aVector2.y;
}

float APoint::length() const
{
    return sqrt(x * x + y * y);
}

void APoint::normalize()
{
    float len = length();
    x /= len;
    y /= len;
}

APoint &APoint::normalized()
{
    float len = length();
    x /= len;
    y /= len;
    return *this;
}

APoint APoint::operator+(const APoint &aVector2) const
{
    return {x + aVector2.x, y + aVector2.y};
}

APoint &APoint::operator+=(const APoint &aVector2)
{
    this->x += aVector2.x;
    this->y += aVector2.y;
    return *this;
}

APoint APoint::operator-(const APoint &aVector2) const
{
    return {x - aVector2.x, y - aVector2.y};
}

APoint &APoint::operator-=(const APoint &aVector2)
{
    this->x -= aVector2.x;
    this->y -= aVector2.y;
    return *this;
}

APoint APoint::operator*(float s) const
{
    return {x * s, y * s};
}

APoint &APoint::operator*=(float s)
{
    this->x *= s;
    this->y *= s;
    return *this;
}

APoint APoint::operator*(const APoint &aVector2) const
{
    return {x * aVector2.x, y * aVector2.y};
}

APoint &APoint::operator*=(const APoint &aVector2)
{
    this->x *= aVector2.x;
    this->y *= aVector2.y;
    return *this;
}

APoint APoint::operator/(float s) const
{
    return {x / s, y / s};
}

APoint &APoint::operator/=(float s)
{
    this->x /= s;
    this->y /= s;
    return *this;
}

APoint APoint::operator/(const APoint &aVector2) const
{
    return {x / aVector2.x, y / aVector2.y};
}

APoint &APoint::operator/=(const APoint &aVector2)
{
    this->x /= aVector2.x;
    this->y /= aVector2.y;
    return *this;
}

APoint APoint::operator-() const
{
    return {-x, -y};
}

bool APoint::operator==(const APoint &aVector2) const
{
    return almost_equal(x, aVector2.x) &&
    almost_equal(y, aVector2.y);
}

bool APoint::operator!=(const APoint &aVector2) const
{
    return !(*this == aVector2);
}

}
