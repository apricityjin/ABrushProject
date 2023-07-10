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
struct Affine
{
    Affine();
    
    Affine(float sx, float shy, float shx, float sy, float tx, float ty);
    
    Affine &translate(float x, float y);
    
    Affine &scale(float s);
    
    Affine &rotate(float a);
    
    Affine &translateX(float x);
    
    Affine &translateY(float y);
    
    Affine &scaleX(float x);
    
    Affine &scaleY(float y);
    
    Affine &shear(float x, float y);
    
    Affine &shearX(float x);
    
    Affine &shearY(float y);
    
    Affine &scale(float x, float y);
    
    Affine &multiply(ABrush::Affine &affine);
    
    Affine &setIdentity();
    
    bool isIdentity() const;
    
    Affine &invert();
    
    Affine &flipX();
    
    Affine &flipY();
    
    void transform(float *x, float *y) const;
    
    void transform2x2(float *x, float *y) const;
    
    Affine &multiplyInvert(Affine &affine);
    
    Affine &preMultiply(Affine &affine);
    
    Affine &preMultiplyInvert(Affine &affine);
    
    Affine operator*(Affine &affine);
    
    Affine &operator*=(Affine &affine);
    
    Affine operator/(Affine &affine) const;
    
    Affine &operator/=(Affine &affine);
    
    Affine operator~() const;
    
    bool operator!=(Affine &affine) const;
    
    bool operator==(Affine &affine) const;
    
    float sx  = 1.0, shy = 0.0,
    shx = 0.0, sy = 1.0,
    tx  = 0.0, ty = 0.0;
};

APoint operator*(APoint &p, Affine &affine);
APoint &operator*=(APoint &p, Affine &affine);
}

#endif //ABRUSH_AFFINE_H
