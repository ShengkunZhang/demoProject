//
//  AppDelegate.m
//  GestureUnlockDemo
//
//  Created by zsk on 2017/10/21.
//  Copyright © 2017年 zsk. All rights reserved.
//

#import "PCCircle.h"

@interface PCCircle()

/**
 *  外环颜色
 */
@property (nonatomic, strong) UIColor *outCircleColor;

/**
 *  实心圆颜色
 */
@property (nonatomic, strong) UIColor *inCircleColor;

/**
 *  三角形颜色
 */
@property (nonatomic, strong) UIColor *trangleColor;

@end

@implementation PCCircle

- (instancetype)init
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat radio;
    CGRect circleRect = CGRectMake(self.CircleEdgeWidth, self.CircleEdgeWidth, rect.size.width - 2 * self.CircleEdgeWidth, rect.size.height - 2 * self.CircleEdgeWidth);
    if (self.type == CircleTypeGesture) {
        radio = self.CircleRadio;
    } else {
        radio = 1;
    }
    
    // 上下文旋转
    [self transFormCtx:ctx rect:rect];
    // 画圆环
    [self drawEmptyCircleWithContext:ctx rect:circleRect color:self.outCircleColor];
    // 画实心圆
    [self drawSolidCircleWithContext:ctx rect:rect radio:radio color:self.inCircleColor];
 
    if (self.arrow) {
        // 画三角形箭头
        [self drawTrangleWithContext:ctx topPoint:CGPointMake(rect.size.width/2, 10) length:self.kTrangleLength color:self.trangleColor];
    }
}

#pragma mark - 画外圆环
/**
 *  画外圆环
 *
 *  @param ctx   图形上下文
 *  @param rect  绘画范围
 *  @param color 绘制颜色
 */
- (void)drawEmptyCircleWithContext:(CGContextRef)ctx rect:(CGRect)rect color:(UIColor *)color
{
    CGMutablePathRef circlePath = CGPathCreateMutable();
    CGPathAddEllipseInRect(circlePath, NULL, rect);
    CGContextAddPath(ctx, circlePath);
    [color set];
    CGContextSetLineWidth(ctx, self.CircleEdgeWidth);
    CGContextStrokePath(ctx);
    CGPathRelease(circlePath);
}

#pragma mark - 画实心圆
/**
 *  画实心圆
 *
 *  @param ctx   图形上下文
 *  @param rect  绘制范围
 *  @param radio 占大圆比例
 *  @param color 绘制颜色
 */
- (void)drawSolidCircleWithContext:(CGContextRef)ctx rect:(CGRect)rect radio:(CGFloat)radio color:(UIColor *)color
{
    CGMutablePathRef circlePath = CGPathCreateMutable();
    CGPathAddEllipseInRect(circlePath, NULL, CGRectMake(rect.size.width/2 * (1 - radio) + self.CircleEdgeWidth, rect.size.height/2 * (1 - radio) + self.CircleEdgeWidth, rect.size.width * radio - self.CircleEdgeWidth * 2, rect.size.height * radio - self.CircleEdgeWidth * 2));
    [color set];
    CGContextAddPath(ctx, circlePath);
    CGContextFillPath(ctx);
    CGPathRelease(circlePath);
}

#pragma mark - 画三角形
/**
 *  画三角形
 *
 *  @param ctx    图形上下文
 *  @param point  顶点
 *  @param length 边长
 *  @param color  绘制颜色
 */
- (void)drawTrangleWithContext:(CGContextRef)ctx topPoint:(CGPoint)point length:(CGFloat)length color:(UIColor *)color
{
    CGMutablePathRef trianglePathM = CGPathCreateMutable();
    CGPathMoveToPoint(trianglePathM, NULL, point.x, point.y);
    CGPathAddLineToPoint(trianglePathM, NULL, point.x - length/2, point.y + length/2);
    CGPathAddLineToPoint(trianglePathM, NULL, point.x + length/2, point.y + length/2);
    CGContextAddPath(ctx, trianglePathM);
    [color set];
    CGContextFillPath(ctx);
    CGPathRelease(trianglePathM);
}

/*
 *  上下文旋转
 */
-(void)transFormCtx:(CGContextRef)ctx rect:(CGRect)rect{
//    if(self.angle == 0) return;
    CGFloat translateXY = rect.size.width * .5f;
    //平移
    CGContextTranslateCTM(ctx, translateXY, translateXY);
    CGContextRotateCTM(ctx, self.angle);
    //再平移回来
    CGContextTranslateCTM(ctx, -translateXY, -translateXY);
}

- (UIColor *)outCircleColor
{
    UIColor *color;
    switch (self.state) {
        case CircleStateNormal:
            color = self.CircleStateNormalOutsideColor;
            break;
        case CircleStateSelected:
            color = self.CircleStateSelectedOutsideColor;
            break;
        case CircleStateError:
            color = self.CircleStateErrorOutsideColor;
            break;
        case CircleStateLastOneSelected:
            color = self.CircleStateSelectedOutsideColor;
            break;
        case CircleStateLastOneError:
            color = self.CircleStateErrorOutsideColor;
            break;
        default:
            color = self.CircleStateNormalOutsideColor;
            break;
    }
    return color;
}

- (UIColor *)inCircleColor
{
    UIColor *color;
    switch (self.state) {
        case CircleStateNormal:
            color = self.CircleStateNormalInsideColor;
            break;
        case CircleStateSelected:
            color = self.CircleStateSelectedInsideColor;
            break;
        case CircleStateError:
            color = self.CircleStateErrorInsideColor;
            break;
        case CircleStateLastOneSelected:
            color = self.CircleStateSelectedInsideColor;
            break;
        case CircleStateLastOneError:
            color = self.CircleStateErrorInsideColor;
            break;
        default:
            color = self.CircleStateNormalInsideColor;
            break;
    }
    return color;
}

- (UIColor *)trangleColor
{
    UIColor *color;
    switch (self.state) {
        case CircleStateNormal:
            color = self.CircleStateNormalTrangleColor;
            break;
        case CircleStateSelected:
            color = self.CircleStateSelectedTrangleColor;
            break;
        case CircleStateError:
            color = self.CircleStateErrorTrangleColor;
            break;
        case CircleStateLastOneSelected:
            color = self.CircleStateNormalTrangleColor;
            break;
        case CircleStateLastOneError:
            color = self.CircleStateNormalTrangleColor;
            break;
        default:
            color = self.CircleStateNormalTrangleColor;
            break;
    }
    return color;
}

- (void)setAngle:(CGFloat)angle
{
    _angle = angle;
    [self setNeedsDisplay];
}

- (void)setState:(CircleState)state
{
    _state = state;
    [self setNeedsDisplay];
}

- (CGFloat)kTrangleLength {
    if (_kTrangleLength == 0) {
        _kTrangleLength = 10.0f;
    }
    return _kTrangleLength;
}

- (CGFloat)CircleEdgeWidth {
    if (_CircleEdgeWidth == 0) {
        _CircleEdgeWidth = 1.0f;
    }
    return _CircleEdgeWidth;
}

- (CGFloat)CircleRadio {
    if (_CircleRadio == 0) {
        _CircleRadio = 0.4f;
    }
    return _CircleRadio;
}

- (UIColor *)CircleStateNormalOutsideColor {
    if (_CircleStateNormalOutsideColor == nil) {
        _CircleStateNormalOutsideColor = [UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1];
    }
    return _CircleStateNormalOutsideColor;
}

- (UIColor *)CircleStateSelectedOutsideColor {
    if (_CircleStateSelectedOutsideColor == nil) {
        _CircleStateSelectedOutsideColor = [UIColor colorWithRed:34/255.0 green:178/255.0 blue:246/255.0 alpha:1];
    }
    return _CircleStateSelectedOutsideColor;
}

- (UIColor *)CircleStateErrorOutsideColor {
    if (_CircleStateErrorOutsideColor == nil) {
        _CircleStateErrorOutsideColor = [UIColor colorWithRed:254/255.0 green:82/255.0 blue:92/255.0 alpha:1];
    }
    return _CircleStateErrorOutsideColor;
}

- (UIColor *)CircleStateNormalInsideColor {
    if (_CircleStateNormalInsideColor == nil) {
        _CircleStateNormalInsideColor = [UIColor clearColor];
    }
    return _CircleStateNormalInsideColor;
}

- (UIColor *)CircleStateSelectedInsideColor {
    if (_CircleStateSelectedInsideColor == nil) {
        _CircleStateSelectedInsideColor = [UIColor colorWithRed:34/255.0 green:178/255.0 blue:246/255.0 alpha:1];
    }
    return _CircleStateSelectedInsideColor;
}

- (UIColor *)CircleStateErrorInsideColor {
    if (_CircleStateErrorInsideColor == nil) {
        _CircleStateErrorInsideColor = [UIColor colorWithRed:254/255.0 green:82/255.0 blue:92/255.0 alpha:1];
    }
    return _CircleStateErrorInsideColor;
}

- (UIColor *)CircleStateNormalTrangleColor {
    if (_CircleStateNormalTrangleColor == nil) {
        _CircleStateNormalTrangleColor = [UIColor clearColor];
    }
    return _CircleStateNormalTrangleColor;
}

- (UIColor *)CircleStateSelectedTrangleColor {
    if (_CircleStateSelectedTrangleColor == nil) {
        _CircleStateSelectedTrangleColor = [UIColor colorWithRed:34/255.0 green:178/255.0 blue:246/255.0 alpha:1];
    }
    return _CircleStateSelectedTrangleColor;
}

- (UIColor *)CircleStateErrorTrangleColor {
    if (_CircleStateErrorTrangleColor == nil) {
        _CircleStateErrorTrangleColor = [UIColor colorWithRed:254/255.0 green:82/255.0 blue:92/255.0 alpha:1];
    }
    return _CircleStateErrorTrangleColor;
}

@end
