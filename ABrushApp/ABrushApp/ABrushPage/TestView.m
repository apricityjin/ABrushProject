//
//  TestView.m
//  ABrushApp
//
//  Created by apricity on 2023/6/9.
//

#import "TestView.h"

@implementation TestView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    UIBezierPath * path = [UIBezierPath bezierPath];
    path.lineWidth = 10;
    path.lineCapStyle = kCGLineCapRound; // 端点风格
    path.lineJoinStyle = kCGLineJoinBevel; // 交点风格
//    CGPoint point = CGPointZero;
    
    [path moveToPoint:CGPointMake(100, 50)];
//    point = CGPathGetCurrentPoint(path.CGPath);
//    NSLog(@"%f, %f", point.x, point.y);

    [path addLineToPoint:CGPointMake(60, 300)];
//    point = CGPathGetCurrentPoint(path.CGPath);
//    NSLog(@"%f, %f", point.x, point.y);
    
    [path addLineToPoint:CGPointMake(200, 500)];
    [path addLineToPoint:CGPointMake(100, 50)];
    
//    [path closePath];
//    point = CGPathGetCurrentPoint(path.CGPath);
//    NSLog(@"%f, %f", point.x, point.y);
//    [path addLineToPoint:CGPointMake(150, 100)];
//
//    [path moveToPoint:CGPointMake(150, 100)];
////    point = CGPathGetCurrentPoint(path.CGPath);
////    NSLog(@"%f, %f", point.x, point.y);
//
//    [path addCurveToPoint:CGPointMake(200, 400)
//            controlPoint1:CGPointMake(200, 150)
//            controlPoint2:CGPointMake(300, 400)];
//    point = CGPathGetCurrentPoint(path.CGPath);
//    NSLog(@"%f, %f", point.x, point.y);

//    [path closePath];
//    point = CGPathGetCurrentPoint(path.CGPath);
//    NSLog(@"%f, %f", point.x, point.y);
    
    [UIColor.redColor set];
    [path stroke];
//    [path fill];
}

@end
