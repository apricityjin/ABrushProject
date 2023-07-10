//
// Created by apricity on 2023/6/13.
//

#ifndef AFFINE_HPP
#define AFFINE_HPP

#include "APoint.hpp"

namespace ABrush
{
    /**
     * Affine Transform
     *                     <identity>
     * [sx   shy  0]       [1  0  0]
     * [shx  sy   0]  <=>  [0  1  0]
     * [tx   ty   1]       [0  0  1]
     *
     * 1. translate
     * [1  0  0]   [ 1  0  0]
     * [0  1  0] * [ 0  1  0]
     * [0  0  1]   [tx ty  1]
     *
     * 2. scale
     * [1  0  0]   [sx  0  0]
     * [0  1  0] * [0  sy  0]
     * [0  0  1]   [0   0  1]
     *
     * 3. shear
     * [1  0  0]   [ 1  shy 0]
     * [0  1  0] * [shx  1  0]
     * [0  0  1]   [ 0   0  1]
     *
     * 4. rotate
     * [1  0  0]   [ cos(theta)  sin(theta) 0]
     * [0  1  0] * [-sin(theta)  cos(theta) 0]
     * [0  0  1]   [     0           0      1]
     *
     */
    class Affine
    {
    public:
        Affine() : sx(1.0), shy(0.0), shx(0.0), sy(1.0), tx(0.0), ty(0.0)
        {}

        Affine(float sx, float shy, float shx, float sy, float tx, float ty) :
                sx(sx), shy(shy), shx(shx), sy(sy), tx(tx), ty(ty)
        {}

        Affine &translate(float x, float y)
        {
            tx += x;
            ty += y;
            return *this;
        }

        Affine &scale(float s)
        {
            sx *= s;
            sy *= s;
            tx *= s;
            ty *= s;
            shx *= s;
            shy *= s;
            return *this;
        }

        Affine &rotate(float a)
        {
            float ca = cos(a);
            float sa = sin(a);
            float t0 = sx * ca - shy * sa;
            float t2 = shx * ca - sy * sa;
            float t4 = tx * ca - ty * sa;
            shy = sx * sa + shy * ca;
            sy  = shx * sa + sy * ca;
            ty  = tx * sa + ty * ca;
            sx  = t0;
            shx = t2;
            tx  = t4;
            return *this;
        }

        Affine &translateX(float x)
        {
            tx += x;
            return *this;
        }

        Affine &translateY(float y)
        {
            ty += y;
            return *this;
        }

        Affine &scaleX(float x)
        {
            sx *= x;
            shx *= x;
            tx *= x;
            return *this;
        }

        Affine &scaleY(float y)
        {
            shy *= y;
            sy *= y;
            ty *= y;
            return *this;
        }

        Affine &shear(float x, float y)
        {
            sx += shy * x;
            shx += sy * x;
            tx += ty * x;
            sy += shx * y;
            shy += sx * y;
            ty += tx * y;
            return *this;
        }

        Affine &shearX(float x)
        {
            sx += shy * x;
            shx += sy * x;
            tx += ty * x;
            return *this;
        }

        Affine &shearY(float y)
        {
            sy += shx * y;
            shy += sx * y;
            ty += tx * y;
            return *this;
        }

        Affine &scale(float x, float y)
        {
            sx *= x;
            shx *= x;
            tx *= x;
            shy *= y;
            sy *= y;
            ty *= y;
            return *this;
        }

        Affine &multiply(ABrush::Affine &affine)
        {
            float t0 = sx * affine.sx + shy * affine.shx;
            float t2 = shx * affine.sx + sy * affine.shx;
            float t4 = tx * affine.sx + ty * affine.shx + affine.tx;
            shy = sx * affine.shy + shy * affine.sy;
            sy  = shx * affine.shy + sy * affine.sy;
            ty  = tx * affine.shy + ty * affine.sy + affine.ty;
            sx  = t0;
            shx = t2;
            tx  = t4;
            return *this;
        }

        Affine &setIdentity()
        {
            sx = sy = 1.0;
            tx = ty = shx = shy = 0.0;
            return *this;
        }

        [[nodiscard]] bool isIdentity() const
        {
            return almost_equal(sx, static_cast<float>(1)) &&
                   almost_equal(sy, static_cast<float>(1))&&
                   almost_equal(tx, static_cast<float>(0))&&
                   almost_equal(ty, static_cast<float>(0))&&
                   almost_equal(shx,static_cast<float>(0)) &&
                   almost_equal(shy,static_cast<float>(0));
        }

        Affine &invert()
        {
            float d  = static_cast<float>(1) / (sx * sy - shy * shx);
            float t0 = sy * d;
            sy  = sx * d;
            shy = -shy * d;
            shx = -shx * d;

            float t4 = -tx * t0 - ty * shx;
            ty = -tx * shy - ty * sy;

            sx = t0;
            tx = t4;
            return *this;
        }

        Affine &flipX()
        {
            sx  = -sx;
            shy = -shy;
            tx  = -tx;
            return *this;
        }

        Affine &flipY()
        {
            shx = -shx;
            sy  = -sy;
            ty  = -ty;
            return *this;
        }

        void transform(float *x, float *y) const
        {
            float temp = *x;
            *x = temp * sx + *y * shx + tx;
            *y = temp * shy + *y * sy + ty;
        }

        void transform2x2(float *x, float *y) const
        {
            float temp = *x;
            *x = temp * sx + *y * shx;
            *y = temp * shy + *y * sy;
        }

        Affine &multiplyInvert(Affine &affine)
        {
            Affine t = affine;
            t.invert();
            return multiply(t);
        }

        Affine &preMultiply(Affine &affine)
        {
            Affine t = affine;
            return *this = t.multiply(*this);
        }

        Affine &preMultiplyInvert(Affine &affine)
        {
            Affine t = affine;
            t.invert();
            return *this = t.multiply(*this);
        }

        Affine operator*(Affine &affine)
        {
            Affine result = *this;
            result *= affine;
            return result;
        }

        Affine &operator*=(Affine &affine)
        {
            multiply(affine);
            return *this;
        }

        Affine operator/(Affine &affine) const
        {
            Affine result = *this;
            result /= affine;
            return result;
        }

        Affine &operator/=(Affine &affine)
        {
            preMultiply(affine);
            return *this;
        }

        Affine operator~() const
        {
            Affine result = *this;
            result.invert();
            return result;
        }

        bool operator!=(Affine &affine) const
        {
            return !(*this == affine);
        }

        bool operator==(Affine &affine) const
        {
            return almost_equal(sx, static_cast<float>(1.0))&&
                   almost_equal(sy, static_cast<float>(1.0))&&
                   almost_equal(shx,static_cast<float>(0.0)) &&
                   almost_equal(shy,static_cast<float>(0.0)) &&
                   almost_equal(tx, static_cast<float>(0.0))&&
                   almost_equal(ty, static_cast<float>(0.0));
        }

        float sx  = 1.0, shy = 0.0,
               shx = 0.0, sy = 1.0,
               tx  = 0.0, ty = 0.0;
    };

    APoint operator*(APoint &p, Affine &affine)
    {
        APoint result = APoint();
        result.x = p.x * affine.sx + p.y * affine.shx + affine.tx;
        result.y = p.x * affine.shy + p.y * affine.sy + affine.ty;
        return result;
    }

    APoint &operator*=(APoint &p, Affine &affine)
    {
        float x = p.x, y = p.y;
        p.x = x * affine.sx + y * affine.shx + affine.tx;
        p.y = x * affine.shy + y * affine.sy + affine.ty;
        return p;
    }
}

#endif //ABRUSH_AFFINE_H
