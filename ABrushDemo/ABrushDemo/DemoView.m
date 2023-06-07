//
//  DemoView.m
//  ABrushDemo
//
//  Created by apricity on 2023/6/7.
//

#import "DemoView.h"

@implementation DemoView

- (void)drawRect:(CGRect)rect {
    // Drawing code
    UIBezierPath * path = [UIBezierPath bezierPath];
    path.lineWidth = 10;
    [path moveToPoint:(CGPointMake(100, 100))];
    [path addLineToPoint:(CGPointMake(200, 200))];
    [path moveToPoint:(CGPointMake(100, 200))];
    [path addLineToPoint:(CGPointMake(200, 300))];
    [path addCurveToPoint:(CGPointMake(100, 400))
            controlPoint1:(CGPointMake(200, 100))
            controlPoint2:(CGPointMake(200, 400))];

    path.lineCapStyle = kCGLineCapSquare;

    path.lineJoinStyle = kCGLineJoinRound;
    [UIColor.whiteColor set];
    [path stroke];
}


@end
