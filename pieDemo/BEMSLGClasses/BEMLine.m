//
//  BEMLine.m
//  SimpleLineGraph
//
//  Created by Bobo on 12/27/13. Updated by Sam Spencer on 1/11/14.
//  Copyright (c) 2013 Boris Emorine. All rights reserved.
//  Copyright (c) 2014 Sam Spencer.
//

#import "BEMLine.h"
#import "BEMSimpleLineGraphView.h"

#if CGFLOAT_IS_DOUBLE
#define CGFloatValue doubleValue
#else
#define CGFloatValue floatValue
#endif


@interface BEMLine()

@property (nonatomic, strong) NSMutableArray *points;

@end

@implementation BEMLine

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        _enableLeftReferenceFrameLine = YES;
        _enableBottomReferenceFrameLine = YES;
        _interpolateNullValues = YES;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    //----------------------------//
    //---- Draw Refrence Lines ---// 绘制坐标系，x轴，y轴以及x y的标签
    //----------------------------//
    // 垂直的
    UIBezierPath *verticalReferenceLinesPath = [UIBezierPath bezierPath];
    // 水平的
    UIBezierPath *horizontalReferenceLinesPath = [UIBezierPath bezierPath];
    // 作为参考的路径即坐标系
    UIBezierPath *referenceFramePath = [UIBezierPath bezierPath];
    /*
     kCGLineCapButt,//无端点
     kCGLineCapRound,//圆形端点
     kCGLineCapSquare//和无端点差不多，但是要长一点
     */
    verticalReferenceLinesPath.lineCapStyle = kCGLineCapButt;
    verticalReferenceLinesPath.lineWidth = 0.7;
    
    horizontalReferenceLinesPath.lineCapStyle = kCGLineCapButt;
    horizontalReferenceLinesPath.lineWidth = 0.7;
    
    referenceFramePath.lineCapStyle = kCGLineCapButt;
    referenceFramePath.lineWidth = 0.7;
    
    // 如果这个值为YES，则绘制坐标系
    if (self.enableRefrenceFrame == YES) {
        if (self.enableBottomReferenceFrameLine) {
            // Bottom Line
            [referenceFramePath moveToPoint:CGPointMake(0, self.frame.size.height)];
            [referenceFramePath addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
        }
        
        if (self.enableLeftReferenceFrameLine) {
            // Left Line
            [referenceFramePath moveToPoint:CGPointMake(0+self.referenceLineWidth/4, self.frame.size.height)];
            [referenceFramePath addLineToPoint:CGPointMake(0+self.referenceLineWidth/4, 0)];
        }
        
        if (self.enableTopReferenceFrameLine) {
            // Top Line
            [referenceFramePath moveToPoint:CGPointMake(0+self.referenceLineWidth/4, 0)];
            [referenceFramePath addLineToPoint:CGPointMake(self.frame.size.width, 0)];
        }
        
        if (self.enableRightReferenceFrameLine) {
            // Right Line
            [referenceFramePath moveToPoint:CGPointMake(self.frame.size.width - self.referenceLineWidth/4, self.frame.size.height)];
            [referenceFramePath addLineToPoint:CGPointMake(self.frame.size.width - self.referenceLineWidth/4, 0)];
        }
    }
    
    if (self.enableRefrenceLines == YES) {
        if (self.arrayOfVerticalRefrenceLinePoints.count > 0) {
            for (NSNumber *xNumber in self.arrayOfVerticalRefrenceLinePoints) {
                CGFloat xValue;
                if (self.verticalReferenceHorizontalFringeNegation != 0.0) {
                    if ([self.arrayOfVerticalRefrenceLinePoints indexOfObject:xNumber] == 0) { // far left reference line
                        xValue = [xNumber floatValue] + self.verticalReferenceHorizontalFringeNegation;
                    } else if ([self.arrayOfVerticalRefrenceLinePoints indexOfObject:xNumber] == [self.arrayOfVerticalRefrenceLinePoints count]-1) { // far right reference line
                        xValue = [xNumber floatValue] - self.verticalReferenceHorizontalFringeNegation;
                    } else xValue = [xNumber floatValue];
                } else xValue = [xNumber floatValue];
                
                CGPoint initialPoint = CGPointMake(xValue, self.frame.size.height);
                CGPoint finalPoint = CGPointMake(xValue, 0);
                
                [verticalReferenceLinesPath moveToPoint:initialPoint];
                [verticalReferenceLinesPath addLineToPoint:finalPoint];
            }
        }
        
        if (self.arrayOfHorizontalRefrenceLinePoints.count > 0) {
            for (NSNumber *yNumber in self.arrayOfHorizontalRefrenceLinePoints) {
                CGPoint initialPoint = CGPointMake(0, [yNumber floatValue]);
                CGPoint finalPoint = CGPointMake(self.frame.size.width, [yNumber floatValue]);
                
                [horizontalReferenceLinesPath moveToPoint:initialPoint];
                [horizontalReferenceLinesPath addLineToPoint:finalPoint];
            }
        }
    }
    
    
    //----------------------------//
    //----- Draw Average Line ----//
    //----------------------------//
    UIBezierPath *averageLinePath = [UIBezierPath bezierPath];
    if (self.averageLine.enableAverageLine == YES) {
        averageLinePath.lineCapStyle = kCGLineCapButt;
        averageLinePath.lineWidth = self.averageLine.width;
        
        CGPoint initialPoint = CGPointMake(0, self.averageLineYCoordinate);
        CGPoint finalPoint = CGPointMake(self.frame.size.width, self.averageLineYCoordinate);
        
        [averageLinePath moveToPoint:initialPoint];
        [averageLinePath addLineToPoint:finalPoint];
    }
    
    
    //----------------------------//
    //------ Draw Graph Line -----//
    //----------------------------//
    // LINE
    UIBezierPath *line = [UIBezierPath bezierPath];
    UIBezierPath *fillTop;
    UIBezierPath *fillBottom;
    
    NSInteger lineCount = self.arrayOfPoints.count;
    NSInteger arrayCount = ((NSArray *)self.arrayOfPoints.firstObject).count;
    CGFloat xIndexScale = self.frame.size.width/(arrayCount - 1);
    
    NSMutableArray *lineArray = [NSMutableArray array];
    for (NSInteger j = 0; j < lineCount; j++) {
        NSArray *tempArray = self.arrayOfPoints[j];
        if (j == 0) {
            self.points = [NSMutableArray arrayWithCapacity:arrayCount];
            for (int i = 0; i < arrayCount; i++) {
                CGPoint value = CGPointMake(xIndexScale * i, [tempArray[i] CGFloatValue]);
                if (value.y != BEMNullGraphValue || !self.interpolateNullValues) {
                    [self.points addObject:[NSValue valueWithCGPoint:value]];
                }
            }
            
            BOOL bezierStatus = self.bezierCurveIsEnabled;
            if (arrayCount <= 2 && self.bezierCurveIsEnabled == YES) bezierStatus = NO;
            
            if (!self.disableMainLine && bezierStatus) {
                // 弧线及填充 对象
                line = [BEMLine quadCurvedPathWithPoints:self.points];
                fillBottom = [BEMLine quadCurvedPathWithPoints:self.bottomPointsArray];
                fillTop = [BEMLine quadCurvedPathWithPoints:self.topPointsArray];
            } else if (!self.disableMainLine && !bezierStatus) {
                // 折线及填充 对象
                line = [BEMLine linesToPoints:self.points];
                fillBottom = [BEMLine linesToPoints:self.bottomPointsArray];
                fillTop = [BEMLine linesToPoints:self.topPointsArray];
            } else {
                // 填充对象
                fillBottom = [BEMLine linesToPoints:self.bottomPointsArray];
                fillTop = [BEMLine linesToPoints:self.topPointsArray];
            }
            
            [lineArray addObject:line];
        } else {
            // 测试
            NSMutableArray *pointsOther = [NSMutableArray arrayWithCapacity:arrayCount];
            
            for (NSInteger i = 0; i < arrayCount; i++) {
                CGPoint value = CGPointMake(xIndexScale * i, [tempArray[i] CGFloatValue]);
                if (value.y != BEMNullGraphValue || !self.interpolateNullValues) {
                    [pointsOther addObject:[NSValue valueWithCGPoint:value]];
                }
                
                // 不是最后一个元素
                if (i + 1 <= arrayCount - 1) {
                    // 且当前点与下一个点不等
                    CGFloat tempValue =  [tempArray[i] CGFloatValue];
                    CGFloat tempValue1 =  [tempArray[i + 1] CGFloatValue];
                    if (tempValue != tempValue1) {
                        CGPoint value = CGPointMake(xIndexScale * (i + 1), [tempArray[i] CGFloatValue]);
                        if (value.y != BEMNullGraphValue || !self.interpolateNullValues) {
                            [pointsOther addObject:[NSValue valueWithCGPoint:value]];
                        }
                    }
                }
            }
            UIBezierPath *lineTest = [UIBezierPath bezierPath];
            lineTest = [BEMLine linesToPoints:pointsOther];
            [lineArray addObject:lineTest];
        }
    }
    
    //----------------------------//
    //----- Draw Fill Colors -----// 填充颜色
    //----------------------------//
    // 上边的填充色
    [self.topColor set];
    // 用指定的混合模式和透明度来填充路径包围的区域
    [fillTop fillWithBlendMode:kCGBlendModeNormal alpha:self.topAlpha];
    // 下边的填充色
    [self.bottomColor set];
    [fillBottom fillWithBlendMode:kCGBlendModeNormal alpha:self.bottomAlpha];
    
    // 获得图形上下文对象
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (self.topGradient != nil) {
        // 压栈操作，保存一份当前图形上下文
        CGContextSaveGState(ctx);
        CGContextAddPath(ctx, [fillTop CGPath]);
        // ctx裁剪路径,后续操作的路径
        CGContextClip(ctx);
        // gradient渐变颜色,startPoint开始渐变的起始位置,endPoint结束坐标,options开始坐标之前或者开始之后开始渐变, 开始坐标和结束坐标是控制渐变的方向和形状
        // CGContextDrawLinearGradient(CGContextRef context,CGGradientRef gradient, CGPoint startPoint, CGPoint endPoint,CGGradientDrawingOptions options)
        CGContextDrawLinearGradient(ctx, self.topGradient, CGPointZero, CGPointMake(0, CGRectGetMaxY(fillTop.bounds)), 0);
        // 出栈操作，恢复一份当前图形上下文
        CGContextRestoreGState(ctx);
    }
    
    if (self.bottomGradient != nil) {
        CGContextSaveGState(ctx);
        CGContextAddPath(ctx, [fillBottom CGPath]);
        CGContextClip(ctx);
        CGContextDrawLinearGradient(ctx, self.bottomGradient, CGPointZero, CGPointMake(0, CGRectGetMaxY(fillBottom.bounds)), 0);
        CGContextRestoreGState(ctx);
    }
    
    
    //----------------------------//
    //------ Animate Drawing -----// 动画绘制
    //----------------------------//
    if (self.enableRefrenceLines == YES) {
        // 创建对象
        CAShapeLayer *verticalReferenceLinesPathLayer = [CAShapeLayer layer];
        // 设置frame
        verticalReferenceLinesPathLayer.frame = self.bounds;
        // 设置path
        verticalReferenceLinesPathLayer.path = verticalReferenceLinesPath.CGPath;
        // 设置透明度
        verticalReferenceLinesPathLayer.opacity = self.lineAlpha == 0 ? 0.1 : self.lineAlpha/2;
        // 填充路径的颜色
        verticalReferenceLinesPathLayer.fillColor = nil;
        // 设置线条宽度
        verticalReferenceLinesPathLayer.lineWidth = self.referenceLineWidth/2;
        
        if (self.lineDashPatternForReferenceYAxisLines) {
            // 虚线设置
            verticalReferenceLinesPathLayer.lineDashPattern = self.lineDashPatternForReferenceYAxisLines;
        }
        
        if (self.refrenceLineColor) {
            // 填充路径的描边轮廓的颜色
            verticalReferenceLinesPathLayer.strokeColor = self.refrenceLineColor.CGColor;
        } else {
            verticalReferenceLinesPathLayer.strokeColor = self.color.CGColor;
        }
        
        // 添加动画
        if (self.animationTime > 0)
            [self animateForLayer:verticalReferenceLinesPathLayer withAnimationType:self.animationType isAnimatingReferenceLine:YES];
        [self.layer addSublayer:verticalReferenceLinesPathLayer];
        
        // 创建水平方向 layer对象
        CAShapeLayer *horizontalReferenceLinesPathLayer = [CAShapeLayer layer];
        horizontalReferenceLinesPathLayer.frame = self.bounds;
        horizontalReferenceLinesPathLayer.path = horizontalReferenceLinesPath.CGPath;
        horizontalReferenceLinesPathLayer.opacity = self.lineAlpha == 0 ? 0.1 : self.lineAlpha/2;
        horizontalReferenceLinesPathLayer.fillColor = nil;
        horizontalReferenceLinesPathLayer.lineWidth = self.referenceLineWidth/2;
        if(self.lineDashPatternForReferenceXAxisLines) {
            horizontalReferenceLinesPathLayer.lineDashPattern = self.lineDashPatternForReferenceXAxisLines;
        }
        
        if (self.refrenceLineColor) {
            horizontalReferenceLinesPathLayer.strokeColor = self.refrenceLineColor.CGColor;
        } else {
            horizontalReferenceLinesPathLayer.strokeColor = self.color.CGColor;
        }
        
        if (self.animationTime > 0)
            [self animateForLayer:horizontalReferenceLinesPathLayer withAnimationType:self.animationType isAnimatingReferenceLine:YES];
        [self.layer addSublayer:horizontalReferenceLinesPathLayer];
    }
    
    // 创建参考系 layer对象
    CAShapeLayer *referenceLinesPathLayer = [CAShapeLayer layer];
    referenceLinesPathLayer.frame = self.bounds;
    referenceLinesPathLayer.path = referenceFramePath.CGPath;
    referenceLinesPathLayer.opacity = self.lineAlpha == 0 ? 0.1 : self.lineAlpha/2;
    referenceLinesPathLayer.fillColor = nil;
    referenceLinesPathLayer.lineWidth = self.referenceLineWidth/2;
    
    if (self.refrenceLineColor) referenceLinesPathLayer.strokeColor = self.refrenceLineColor.CGColor;
    else referenceLinesPathLayer.strokeColor = self.color.CGColor;
    
    if (self.animationTime > 0)
        [self animateForLayer:referenceLinesPathLayer withAnimationType:self.animationType isAnimatingReferenceLine:YES];
    [self.layer addSublayer:referenceLinesPathLayer];
    
    if (self.disableMainLine == NO) {
        for (NSInteger i = 0; i < lineArray.count; i++) {
            UIBezierPath *line = lineArray[i];
            CAShapeLayer *pathLayer = [CAShapeLayer layer];
            if (i == 0) {
                pathLayer.frame = self.bounds;
                pathLayer.path = line.CGPath;
                pathLayer.strokeColor = self.color.CGColor;
                pathLayer.fillColor = nil;
                pathLayer.opacity = self.lineAlpha;
                pathLayer.lineWidth = self.lineWidth;
                pathLayer.lineJoin = kCALineJoinBevel;
                pathLayer.lineCap = kCALineCapRound;
            } else {
                // 其他线
                pathLayer.frame = self.bounds;
                pathLayer.path = line.CGPath;
                pathLayer.strokeColor = [UIColor colorWithRed:250.0/255.0 green:197.0/255.0 blue:112.0/255.0 alpha:1.0].CGColor;
                pathLayer.fillColor = nil;
                pathLayer.opacity = 1;
                pathLayer.lineWidth = 0.7;
                pathLayer.lineJoin = kCALineJoinBevel;
                pathLayer.lineCap = kCALineCapRound;
                pathLayer.lineDashPattern = @[@(2),@(2)];
            }
            
            if (self.animationTime > 0) {
                [self animateForLayer:pathLayer withAnimationType:self.animationType isAnimatingReferenceLine:NO];
            }
            if (self.lineGradient) {
                [self.layer addSublayer:[self backgroundGradientLayerForLayer:pathLayer]];
            } else {
                [self.layer addSublayer:pathLayer];
            }
        }
    }
    
    // 中间线
    if (self.averageLine.enableAverageLine == YES) {
        CAShapeLayer *averageLinePathLayer = [CAShapeLayer layer];
        averageLinePathLayer.frame = self.bounds;
        averageLinePathLayer.path = averageLinePath.CGPath;
        averageLinePathLayer.opacity = self.averageLine.alpha;
        averageLinePathLayer.fillColor = nil;
        averageLinePathLayer.lineWidth = self.averageLine.width;
        
        // 设置为虚线
        if (self.averageLine.dashPattern) averageLinePathLayer.lineDashPattern = self.averageLine.dashPattern;
        
        if (self.averageLine.color) averageLinePathLayer.strokeColor = self.averageLine.color.CGColor;
        else averageLinePathLayer.strokeColor = self.color.CGColor;
        
        if (self.animationTime > 0)
            [self animateForLayer:averageLinePathLayer withAnimationType:self.animationType isAnimatingReferenceLine:NO];
        [self.layer addSublayer:averageLinePathLayer];
    }
}

// 补充topPoints数组
- (NSArray *)topPointsArray {
    CGPoint topPointZero = CGPointMake(0,0);
    CGPoint topPointFull = CGPointMake(self.frame.size.width, 0);
    NSMutableArray *topPoints = [NSMutableArray arrayWithArray:self.points];
    [topPoints insertObject:[NSValue valueWithCGPoint:topPointZero] atIndex:0];
    [topPoints addObject:[NSValue valueWithCGPoint:topPointFull]];
    return topPoints;
}

// 补充bottomPoints数组
- (NSArray *)bottomPointsArray {
    CGPoint bottomPointZero = CGPointMake(0, self.frame.size.height);
    CGPoint bottomPointFull = CGPointMake(self.frame.size.width, self.frame.size.height);
    NSMutableArray *bottomPoints = [NSMutableArray arrayWithArray:self.points];
    [bottomPoints insertObject:[NSValue valueWithCGPoint:bottomPointZero] atIndex:0];
    [bottomPoints addObject:[NSValue valueWithCGPoint:bottomPointFull]];
    return bottomPoints;
}

// 方方正正的折线
+ (UIBezierPath *)linesToPoints:(NSArray *)points {
    UIBezierPath *path = [UIBezierPath bezierPath];
    NSValue *value = points[0];
    CGPoint p1 = [value CGPointValue];
    [path moveToPoint:p1];
    
    for (NSUInteger i = 1; i < points.count; i++) {
        value = points[i];
        CGPoint p2 = [value CGPointValue];
        [path addLineToPoint:p2];
    }
    return path;
}

// 把点数组转化为 二次贝塞尔曲线对象 （弧线）
+ (UIBezierPath *)quadCurvedPathWithPoints:(NSArray *)points {
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    NSValue *value = points[0];
    CGPoint p1 = [value CGPointValue];
    [path moveToPoint:p1];
    
    if (points.count == 2) {
        value = points[1];
        CGPoint p2 = [value CGPointValue];
        [path addLineToPoint:p2];
        return path;
    }
    
    for (NSUInteger i = 1; i < points.count; i++) {
        value = points[i];
        CGPoint p2 = [value CGPointValue];
        
        CGPoint midPoint = midPointForPoints(p1, p2);
        [path addQuadCurveToPoint:midPoint controlPoint:controlPointForPoints(midPoint, p1)];
        [path addQuadCurveToPoint:p2 controlPoint:controlPointForPoints(midPoint, p2)];
        
        p1 = p2;
    }
    return path;
}

// 得到中间点
static CGPoint midPointForPoints(CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
}

// 得到控制点
static CGPoint controlPointForPoints(CGPoint p1, CGPoint p2) {
    CGPoint controlPoint = midPointForPoints(p1, p2);
    CGFloat diffY = fabs(p2.y - controlPoint.y);
    
    if (p1.y < p2.y)
        controlPoint.y += diffY;
    else if (p1.y > p2.y)
        controlPoint.y -= diffY;
    
    return controlPoint;
}

// 添加layer的动画效果
- (void)animateForLayer:(CAShapeLayer *)shapeLayer withAnimationType:(BEMLineAnimation)animationType isAnimatingReferenceLine:(BOOL)shouldHalfOpacity {
    // 根据不同的类型，设置不同的动画效果
    if (animationType == BEMLineAnimationNone) return;
    else if (animationType == BEMLineAnimationFade) {
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        pathAnimation.duration = self.animationTime;
        pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        if (shouldHalfOpacity == YES) pathAnimation.toValue = [NSNumber numberWithFloat:self.lineAlpha == 0 ? 0.1 : self.lineAlpha/2];
        else pathAnimation.toValue = [NSNumber numberWithFloat:self.lineAlpha];
        [shapeLayer addAnimation:pathAnimation forKey:@"opacity"];
        
        return;
    } else if (animationType == BEMLineAnimationExpand) {
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
        pathAnimation.duration = self.animationTime;
        pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        pathAnimation.toValue = [NSNumber numberWithFloat:shapeLayer.lineWidth];
        [shapeLayer addAnimation:pathAnimation forKey:@"lineWidth"];
        
        return;
    } else {
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.duration = self.animationTime;
        pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
        [shapeLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
        
        return;
    }
}

- (CALayer *)backgroundGradientLayerForLayer:(CAShapeLayer *)shapeLayer {
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef imageCtx = UIGraphicsGetCurrentContext();
    CGPoint start, end;
    if (self.lineGradientDirection == BEMLineGradientDirectionHorizontal) {
        start = CGPointMake(0, CGRectGetMidY(shapeLayer.bounds));
        end = CGPointMake(CGRectGetMaxX(shapeLayer.bounds), CGRectGetMidY(shapeLayer.bounds));
    } else {
        start = CGPointMake(CGRectGetMidX(shapeLayer.bounds), 0);
        end = CGPointMake(CGRectGetMidX(shapeLayer.bounds), CGRectGetMaxY(shapeLayer.bounds));
    }
    
    CGContextDrawLinearGradient(imageCtx, self.lineGradient, start, end, 0);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CALayer *gradientLayer = [CALayer layer];
    gradientLayer.frame = self.bounds;
    gradientLayer.contents = (id)image.CGImage;
    gradientLayer.mask = shapeLayer;
    return gradientLayer;
}

@end

