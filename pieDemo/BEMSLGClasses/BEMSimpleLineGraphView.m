//
//  BEMSimpleLineGraphView.m
//  SimpleLineGraph
//
//  Created by Bobo on 12/27/13. Updated by Sam Spencer on 1/11/14.
//  Copyright (c) 2013 Boris Emorine. All rights reserved.
//  Copyright (c) 2014 Sam Spencer.
//

#import "BEMSimpleLineGraphView.h"

const CGFloat BEMNullGraphValue = CGFLOAT_MAX;


#if !__has_feature(objc_arc)
// Add the -fobjc-arc flag to enable ARC for only these files, as described in the ARC documentation: http://clang.llvm.org/docs/AutomaticReferenceCounting.html
#error BEMSimpleLineGraph is built with Objective-C ARC. You must enable ARC for these files.
#endif

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define DEFAULT_FONT_NAME @"HelveticaNeue-Light"


typedef NS_ENUM(NSInteger, BEMInternalTags)
{
    LabelYAxisTag2000 = 2000,
    BackgroundYAxisTag2100 = 2100,
    BackgroundXAxisTag2200 = 2200,
    PermanentPopUpViewTag3100 = 3100,
    BackgroundViewTag4001 = 4001,
    BackgroundViewTag4002 = 4002,
    DotFirstTag10000 = 10000,
    DotLastTag100000 = 100000,
};

@interface BEMSimpleLineGraphView () {
    /// The number of Points in the Graph
    NSInteger numberOfPoints;
    
    /// The closest point to the touch point
    BEMCircle *closestDot;
    CGFloat currentlyCloser;
    
    /// All of the X-Axis Values
    NSMutableArray *xAxisValues;
    
    /// All of the X-Axis Label Points
    NSMutableArray *xAxisLabelPoints;
    
    /// All of the X-Axis Label Points
    CGFloat xAxisHorizontalFringeNegationValue;
    
    /// All of the Y-Axis Label Points
    NSMutableArray *yAxisLabelPoints;
    
    /// All of the Y-Axis Values
    NSMutableArray *yAxisValues;
    
    /// All of the Data Points
    NSMutableArray *dataPoints;
    
    /// All of the X-Axis Labels
    NSMutableArray *xAxisLabels;
}

/// The vertical line which appears when the user drags across the graph
@property (strong, nonatomic) UIView *touchInputLine;

/// View for picking up pan gesture
@property (strong, nonatomic, readwrite) UIView *panView;

/// Label to display when there is no data
@property (strong, nonatomic) UILabel *noDataLabel;

/// The gesture recognizer picking up the pan in the graph view
@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;

/// This gesture recognizer picks up the initial touch on the graph view
@property (nonatomic) UILongPressGestureRecognizer *longPressGesture;

/// The label displayed when enablePopUpReport is set to YES
@property (strong, nonatomic) UILabel *popUpLabel;

/// The view used for the background of the popup label
@property (strong, nonatomic) UIView *popUpView;

/// The X position (center) of the view for the popup label
@property (nonatomic) CGFloat xCenterLabel;

/// The Y position (center) of the view for the popup label
@property (nonatomic) CGFloat yCenterLabel;

/// The Y offset necessary to compensate the labels on the X-Axis
@property (nonatomic) CGFloat XAxisLabelYOffset;

/// The X offset necessary to compensate the labels on the Y-Axis. Will take the value of the bigger label on the Y-Axis
@property (nonatomic) CGFloat YAxisLabelXOffset;

/// The biggest value out of all of the data points
@property (nonatomic) CGFloat maxValue;

/// The smallest value out of all of the data points
@property (nonatomic) CGFloat minValue;

/// Find which point is currently the closest to the vertical line
- (BEMCircle *)closestDotFromtouchInputLine:(UIView *)touchInputLine;

/// Determines the biggest Y-axis value from all the points
- (CGFloat)maxValue;

/// Determines the smallest Y-axis value from all the points
- (CGFloat)minValue;

// Tracks whether the popUpView is custom or default
@property (nonatomic) BOOL usingCustomPopupView;

// Stores the current view size to detect whether a redraw is needed in layoutSubviews
@property (nonatomic) CGSize currentViewSize;

// Stores the background X Axis view
@property (nonatomic) UIView *backgroundXAxis;
// 显示当前选中的点的数据
@property (nonatomic, strong) UIView *backgroundTagView;

@end

@implementation BEMSimpleLineGraphView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) [self commonInit];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) [self commonInit];
    return self;
}

- (UIView *)backgroundTagView {
    if (!_backgroundTagView) {
        _backgroundTagView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, self.frame.size.width - 20, 40)];
    }
    return _backgroundTagView;
}

// 设置初始化属性
- (void)commonInit {
    // Do any initialization that's common to both -initWithFrame: and -initWithCoder: in this method
    
    // Set the X Axis label font
    _labelFont = [UIFont fontWithName:DEFAULT_FONT_NAME size:13];
    
    // Set Animation Values
    _animationGraphEntranceTime = 1.5;
    
    // Set Color Values
    _colorXaxisLabel = [UIColor blackColor];
    _colorYaxisLabel = [UIColor blackColor];
    _colorTop = [UIColor colorWithRed:0 green:122.0/255.0 blue:255/255 alpha:1];
    _colorLine = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1];
    _colorBottom = [UIColor colorWithRed:0 green:122.0/255.0 blue:255/255 alpha:1];
    _colorPoint = [UIColor colorWithWhite:1.0 alpha:0.7];
    _colorTouchInputLine = [UIColor grayColor];
    _colorBackgroundPopUplabel = [UIColor whiteColor];
    _alphaTouchInputLine = 0.2;
    _widthTouchInputLine = 1.0;
    _colorBackgroundXaxis = nil;
    _alphaBackgroundXaxis = 1.0;
    _colorBackgroundYaxis = nil;
    _alphaBackgroundYaxis = 1.0;
    _displayDotsWhileAnimating = YES;
    
    // Set Alpha Values
    _alphaTop = 1.0;
    _alphaBottom = 1.0;
    _alphaLine = 1.0;
    
    // Set Size Values
    _widthLine = 1.0;
    _widthReferenceLines = 1.0;
    _sizePoint = 10.0;
    
    // Set Default Feature Values
    _enableTouchReport = NO;
    _touchReportFingersRequired = 1;
    _enablePopUpReport = NO;
    _enableBezierCurve = NO;
    _enableXAxisLabel = YES;
    _enableYAxisLabel = NO;
    _YAxisLabelXOffset = 0;
    _autoScaleYAxis = YES;
    _alwaysDisplayDots = NO;
    _alwaysDisplayPopUpLabels = NO;
    _enableLeftReferenceAxisFrameLine = YES;
    _enableBottomReferenceAxisFrameLine = YES;
    _formatStringForValues = @"%.0f";
    _interpolateNullValues = YES;
    _displayDotsOnly = NO;
    
    // Initialize the various arrays
    xAxisValues = [NSMutableArray array];
    xAxisHorizontalFringeNegationValue = 0.0;
    xAxisLabelPoints = [NSMutableArray array];
    yAxisLabelPoints = [NSMutableArray array];
    dataPoints = [NSMutableArray array];
    xAxisLabels = [NSMutableArray array];
    yAxisValues = [NSMutableArray array];
    
    // Initialize BEM Objects
    _averageLine = [[BEMAverageLine alloc] init];
}

// 使用xib或者storyboard时 当视图正准备在Interface Builder显示时执行
- (void)prepareForInterfaceBuilder {
    // 设置点数组，同时移除之前绘制的所有圆点
    numberOfPoints = 10;
    for (UILabel *subview in [self subviews]) {
        if ([subview isEqual:self.noDataLabel])
            [subview removeFromSuperview];
    }
    // 绘制整个图形
    [self drawEntireGraph];
}

- (void)drawGraph {
    // 调用协议，通知已经开始绘制
    if ([self.delegate respondsToSelector:@selector(lineGraphDidBeginLoading:)])
        [self.delegate lineGraphDidBeginLoading:self];
    
    // 获得图像绘制的点
    [self layoutNumberOfPoints];
    
    if (numberOfPoints <= 1) {
        return;
    } else {
        // 绘制图形
        [self drawEntireGraph];
        
        // 设置触摸的反馈事件
        [self layoutTouchReport];
        
        // 调用协议，通知绘制完成
        if ([self.delegate respondsToSelector:@selector(lineGraphDidFinishLoading:)])
            [self.delegate lineGraphDidFinishLoading:self];
    }
    
}


/**
 调用机制
 1. initWithFrame 进行初始化时, 当rect的值不为CGRectZero时, 会触发. 所以init时不触发，因为frame为CGRectZero
 2. addSubview会触发layoutSubviews
 3. 设置view的Frame会触发layoutSubviews，当然前提是frame的值设置前后发生了变化
 4. 滚动一个UIScrollView会触发layoutSubviews
 5. 旋转Screen会触发父UIView上的layoutSubviews事件
 6. 改变一个UIView大小的时候也会触发父UIView上的layoutSubviews事件
 总结就是当frame发生改变或者添加一个子视图时会触发layoutSubviews事件
 */
- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 只有当之前存储的size和现在实际的size不一致时，才会重新绘制
    // 但是这个判断是不是多此一举呢？ 因为layoutSubviews只有frame改变才会触发
    if (CGSizeEqualToSize(self.currentViewSize, self.bounds.size))  return;
    self.currentViewSize = self.bounds.size;
    
    // 绘制图形
    [self drawGraph];
}

- (void)layoutNumberOfPoints {
    // 通过协议获得数据数组的个数
    if ([self.dataSource respondsToSelector:@selector(numberOfPointsInLineGraph:)]) {
        numberOfPoints = [self.dataSource numberOfPointsInLineGraph:self];
    } else if ([self.delegate respondsToSelector:@selector(numberOfPointsInGraph)]) {
        // 如果没有实现numberOfPointsInLineGraph，实现了numberOfPointsInGraph则，输出提醒语句，让他最好实现上个方法，此方法不久会被遗弃
        [self printDeprecationWarningForOldMethod:@"numberOfPointsInGraph" andReplacementMethod:@"numberOfPointsInLineGraph:"];
        
        // numberOfPointsInGraph已经被标记为遗弃，直接使用会出现警告，如下使用可以消除警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        numberOfPoints = [self.delegate numberOfPointsInGraph];
#pragma clang diagnostic pop
        
        
#pragma clang diagnostic push
        // 这句字面意思就是忽略遗弃声明（ignored deprecated declarations）
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        // 此处放代码，即调用遗弃方法
#pragma clang diagnostic pop
        
        
    } else if ([self.delegate respondsToSelector:@selector(numberOfPointsInLineGraph:)]) {
        [self printDeprecationAndUnavailableWarningForOldMethod:@"numberOfPointsInLineGraph:"];
        numberOfPoints = 0;
        
    } else numberOfPoints = 0;
    
    // 判断是否有数据，如果没有数据则进行处理
    if (numberOfPoints == 0) {
        // 如果是这种情况，通知上个界面
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(noDataLabelEnableForLineGraph:)] &&
            ![self.delegate noDataLabelEnableForLineGraph:self]) return;
        
        // 如果不符合上面情况，打印警告信息
        NSLog(@"[BEMSimpleLineGraph] Data source contains no data. A no data label will be displayed and drawing will stop. Add data to the data source and then reload the graph.");
        
        // 同时根据不同的加载情况，显示对应的提示信息
#if !TARGET_INTERFACE_BUILDER
        self.noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.viewForFirstBaselineLayout.frame.size.width, self.viewForFirstBaselineLayout.frame.size.height)];
#else
        self.noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.viewForFirstBaselineLayout.frame.size.width, self.viewForFirstBaselineLayout.frame.size.height-(self.viewForFirstBaselineLayout.frame.size.height/4))];
#endif
        
        self.noDataLabel.backgroundColor = [UIColor clearColor];
        self.noDataLabel.textAlignment = NSTextAlignmentCenter;
        
#if !TARGET_INTERFACE_BUILDER
        NSString *noDataText;
        if ([self.delegate respondsToSelector:@selector(noDataLabelTextForLineGraph:)]) {
            noDataText = [self.delegate noDataLabelTextForLineGraph:self];
        }
        self.noDataLabel.text = noDataText ?: NSLocalizedString(@"No Data", nil);
#else
        self.noDataLabel.text = @"Data is not loaded in Interface Builder";
#endif
        self.noDataLabel.font = self.noDataLabelFont ?: [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
        self.noDataLabel.textColor = self.noDataLabelColor ?: self.colorLine;
        
        [self.viewForFirstBaselineLayout addSubview:self.noDataLabel];
        
        // 结束加载通知
        if ([self.delegate respondsToSelector:@selector(lineGraphDidFinishLoading:)])
            [self.delegate lineGraphDidFinishLoading:self];
        return;
        
    } else if (numberOfPoints == 1) {
        // 如果只有一个数据，打印警告信息，并创建一个圆点，加载到视图上
        NSLog(@"[BEMSimpleLineGraph] Data source contains only one data point. Add more data to the data source and then reload the graph.");
        BEMCircle *circleDot = [[BEMCircle alloc] initWithFrame:CGRectMake(0, 0, self.sizePoint, self.sizePoint)];
        circleDot.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        circleDot.Pointcolor = self.colorPoint;
        circleDot.alpha = 1;
        [self addSubview:circleDot];
        return;
        
    } else {
        // 移除之前所有绘制的圆点
        for (UILabel *subview in [self subviews]) {
            if ([subview isEqual:self.noDataLabel])
                [subview removeFromSuperview];
        }
    }
}

- (void)layoutTouchReport {
    // If the touch report is enabled, set it up
    if (self.enableTouchReport == YES || self.enablePopUpReport == YES) {
        // Initialize the vertical gray line that appears where the user touches the graph.
        self.touchInputLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.widthTouchInputLine, self.frame.size.height * 0.95)];
        self.touchInputLine.backgroundColor = self.colorTouchInputLine;
        self.touchInputLine.alpha = 0;
        [self addSubview:self.touchInputLine];
        
        self.panView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, self.viewForFirstBaselineLayout.frame.size.width, self.viewForFirstBaselineLayout.frame.size.height)];
        self.panView.backgroundColor = [UIColor clearColor];
        [self.viewForFirstBaselineLayout addSubview:self.panView];
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureAction:)];
        self.panGesture.delegate = self;
        [self.panGesture setMaximumNumberOfTouches:1];
        [self.panView addGestureRecognizer:self.panGesture];
        
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureAction:)];
        self.longPressGesture.minimumPressDuration = 0.1f;
        [self.panView addGestureRecognizer:self.longPressGesture];
        
        if (self.enablePopUpReport == YES && self.alwaysDisplayPopUpLabels == NO) {
            if ([self.delegate respondsToSelector:@selector(popUpViewForLineGraph:)]) {
                self.popUpView = [self.delegate popUpViewForLineGraph:self];
                self.usingCustomPopupView = YES;
                self.popUpView.alpha = 0;
                [self addSubview:self.popUpView];
            } else {
                NSString *maxValueString = [NSString stringWithFormat:self.formatStringForValues, [self calculateMaximumPointValue].doubleValue];
                NSString *minValueString = [NSString stringWithFormat:self.formatStringForValues, [self calculateMinimumPointValue].doubleValue];
                
                NSString *longestString = @"";
                if (maxValueString.length > minValueString.length) {
                    longestString = maxValueString;
                } else {
                    longestString = minValueString;
                }
                
                NSString *prefix = @"";
                NSString *suffix = @"";
                if ([self.delegate respondsToSelector:@selector(popUpSuffixForlineGraph:)]) {
                    suffix = [self.delegate popUpSuffixForlineGraph:self];
                }
                if ([self.delegate respondsToSelector:@selector(popUpPrefixForlineGraph:)]) {
                    prefix = [self.delegate popUpPrefixForlineGraph:self];
                }
                
                NSString *fullString = [NSString stringWithFormat:@"%@%@%@", prefix, longestString, suffix];
                
                NSString *mString = [fullString stringByReplacingOccurrencesOfString:@"[0-9-]" withString:@"N" options:NSRegularExpressionSearch range:NSMakeRange(0, [longestString length])];
                
                self.popUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
                self.popUpLabel.text = mString;
                self.popUpLabel.textAlignment = 1;
                self.popUpLabel.numberOfLines = 1;
                self.popUpLabel.font = self.labelFont;
                self.popUpLabel.backgroundColor = [UIColor clearColor];
                [self.popUpLabel sizeToFit];
                self.popUpLabel.alpha = 0;
                
                self.popUpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.popUpLabel.frame.size.width + 10, self.popUpLabel.frame.size.height + 2)];
                self.popUpView.backgroundColor = self.colorBackgroundPopUplabel;
                self.popUpView.alpha = 0;
                self.popUpView.layer.cornerRadius = 3;
                [self addSubview:self.popUpView];
                [self addSubview:self.popUpLabel];
            }
        }
    }
}

#pragma mark - Drawing

- (void)didFinishDrawingIncludingYAxis:(BOOL)yAxisFinishedDrawing {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.animationGraphEntranceTime * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (self.enableYAxisLabel == NO) {
            // Let the delegate know that the graph finished rendering
            if ([self.delegate respondsToSelector:@selector(lineGraphDidFinishDrawing:)])
                [self.delegate lineGraphDidFinishDrawing:self];
            return;
        } else {
            if (yAxisFinishedDrawing == YES) {
                // Let the delegate know that the graph finished rendering
                if ([self.delegate respondsToSelector:@selector(lineGraphDidFinishDrawing:)])
                    [self.delegate lineGraphDidFinishDrawing:self];
                return;
            }
        }
    });
}

// 绘制整个图形
- (void)drawEntireGraph {
    // The following method calls are in this specific order for a reason
    // Changing the order of the method calls below can result in drawing glitches and even crashes
    
    // 获得传入数据的最大值和最小值
    self.maxValue = [self getMaximumValue];
    self.minValue = [self getMinimumValue];
    
    // Set the Y-Axis Offset if the Y-Axis is enabled. The offset is relative to the size of the longest label on the Y-Axis.
    // 如果enableYAxisLabel是yes, 则设置Y-Axis的偏移量, 以真实的最长的label的长度作为偏移量
    if (self.enableYAxisLabel) {
        NSDictionary *attributes = @{NSFontAttributeName: self.labelFont};
        // 如果开启了自动，则如下去计算
        if (self.autoScaleYAxis == YES){
            NSString *maxValueString = [NSString stringWithFormat:self.formatStringForValues, self.maxValue];
            NSString *minValueString = [NSString stringWithFormat:self.formatStringForValues, self.minValue];
            
            NSString *longestString = @"";
            if (maxValueString.length > minValueString.length) longestString = maxValueString;
            else longestString = minValueString;
            
            // 前缀
            NSString *prefix = @"";
            // 后缀
            NSString *suffix = @"";
            
            if ([self.delegate respondsToSelector:@selector(yAxisPrefixOnLineGraph:)]) {
                prefix = [self.delegate yAxisPrefixOnLineGraph:self];
            }
            
            if ([self.delegate respondsToSelector:@selector(yAxisSuffixOnLineGraph:)]) {
                suffix = [self.delegate yAxisSuffixOnLineGraph:self];
            }
            
            NSString *mString = [longestString stringByReplacingOccurrencesOfString:@"[0-9-]" withString:@"N" options:NSRegularExpressionSearch range:NSMakeRange(0, [longestString length])];
            NSString *fullString = [NSString stringWithFormat:@"%@%@%@", prefix, mString, suffix];
            self.YAxisLabelXOffset = [fullString sizeWithAttributes:attributes].width + 2;
            //MAX([maxValueString sizeWithAttributes:attributes].width + 10,
            //    [minValueString sizeWithAttributes:attributes].width) + 5;
        } else {
            // 如果没有开启自动，则如下粗略获取
            NSString *longestString = [NSString stringWithFormat:@"%i", (int)self.frame.size.height];
            self.YAxisLabelXOffset = [longestString sizeWithAttributes:attributes].width + 5;
        }
    } else self.YAxisLabelXOffset = 0;
    
    // 绘制X轴坐标
    [self drawXAxis];
    
    // 绘制圆点
    [self drawDots];
    
    // 绘制Y轴坐标
    if (self.enableYAxisLabel) [self drawYAxis];
}

- (void)drawDots {
    CGFloat positionOnXAxis; // The position on the X-axis of the point currently being created.
    CGFloat positionOnYAxis; // The position on the Y-axis of the point currently being created.
    
    // Remove all dots that were previously on the graph
    for (UIView *subview in [self subviews]) {
        if ([subview isKindOfClass:[BEMCircle class]] || [subview isKindOfClass:[BEMPermanentPopupView class]] || [subview isKindOfClass:[BEMPermanentPopupLabel class]])
            [subview removeFromSuperview];
    }
    
    // Remove all data points before adding them to the array
    [dataPoints removeAllObjects];
    
    // Remove all yAxis values before adding them to the array
    [yAxisValues removeAllObjects];
    
    // Loop through each point and add it to the graph
    @autoreleasepool {
        NSArray *array = nil;
        if ([self.dataSource respondsToSelector:@selector(lineGraphPointData:)]) {
            array = [self.dataSource lineGraphPointData:self];
        }
        
        for (int j = 0; j < array.count; j++) {
            NSArray *valuesArr = array[j];
            NSMutableArray *tempArray = [NSMutableArray array];
            for (int i = 0; i < valuesArr.count; i++) {
                CGFloat dotValue = [valuesArr[i] doubleValue];
                [dataPoints addObject:@(dotValue)];
                
                // 圆点的X值，等宽即每个点之间的间距相等
                if (self.positionYAxisRight) {
                    positionOnXAxis = (((self.frame.size.width - self.YAxisLabelXOffset) / (numberOfPoints - 1)) * i);
                } else {
                    positionOnXAxis = (((self.frame.size.width - self.YAxisLabelXOffset) / (numberOfPoints - 1)) * i) + self.YAxisLabelXOffset;
                }
                // 圆点的Y值
                positionOnYAxis = [self yPositionForDotValue:dotValue];
                
                [tempArray addObject:@(positionOnYAxis)];
                
                
                // If we're dealing with an null value, don't draw the dot
                
                if (dotValue != BEMNullGraphValue && j == 0) {
                    BEMCircle *circleDot = [[BEMCircle alloc] initWithFrame:CGRectMake(0, 0, self.sizePoint, self.sizePoint)];
                    circleDot.center = CGPointMake(positionOnXAxis, positionOnYAxis);
                    circleDot.tag = i+ DotFirstTag10000 * (j + 1);
                    circleDot.alpha = 0;
                    circleDot.absoluteValue = dotValue;
                    circleDot.Pointcolor = self.colorPoint;
                    
                    [self addSubview:circleDot];
                    if (self.alwaysDisplayPopUpLabels == YES) {
                        if ([self.delegate respondsToSelector:@selector(lineGraph:alwaysDisplayPopUpAtIndex:)]) {
                            if ([self.delegate lineGraph:self alwaysDisplayPopUpAtIndex:i] == YES) {
                                [self displayPermanentLabelForPoint:circleDot];
                            }
                        } else [self displayPermanentLabelForPoint:circleDot];
                    }
                    
                    // Dot entrance animation
                    if (self.animationGraphEntranceTime == 0) {
                        if (self.displayDotsOnly == YES) circleDot.alpha = 1.0;
                        else {
                            if (self.alwaysDisplayDots == NO) circleDot.alpha = 0;
                            else circleDot.alpha = 1.0;
                        }
                    } else {
                        if (self.displayDotsWhileAnimating) {
                            [UIView animateWithDuration:(float)self.animationGraphEntranceTime/numberOfPoints delay:(float)i*((float)self.animationGraphEntranceTime/numberOfPoints) options:UIViewAnimationOptionCurveLinear animations:^{
                                circleDot.alpha = 1.0;
                            } completion:^(BOOL finished) {
                                if (self.alwaysDisplayDots == NO && self.displayDotsOnly == NO) {
                                    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                                        circleDot.alpha = 0;
                                    } completion:nil];
                                }
                            }];
                        }
                    }
                }
            }
            // 加入数组
            [yAxisValues addObject:[tempArray copy]];
        }
    }
    
    // CREATION OF THE LINE AND BOTTOM AND TOP FILL
    [self drawLine];
}

- (void)drawLine {
    for (UIView *subview in [self subviews]) {
        if ([subview isKindOfClass:[BEMLine class]])
            [subview removeFromSuperview];
    }
    
    BEMLine *line = [[BEMLine alloc] initWithFrame:[self drawableGraphArea]];
    
    line.opaque = NO;
    line.alpha = 1;
    line.backgroundColor = [UIColor clearColor];
    line.topColor = self.colorTop;
    line.bottomColor = self.colorBottom;
    line.topAlpha = self.alphaTop;
    line.bottomAlpha = self.alphaBottom;
    line.topGradient = self.gradientTop;
    line.bottomGradient = self.gradientBottom;
    line.lineWidth = self.widthLine;
    line.referenceLineWidth = self.widthReferenceLines ? self.widthReferenceLines : (self.widthLine/2);
    line.lineAlpha = self.alphaLine;
    line.bezierCurveIsEnabled = self.enableBezierCurve;
    
    
    line.arrayOfPoints = yAxisValues;
    line.arrayOfValues = self.graphValuesForDataPoints;
    line.lineDashPatternForReferenceYAxisLines = self.lineDashPatternForReferenceYAxisLines;
    line.lineDashPatternForReferenceXAxisLines = self.lineDashPatternForReferenceXAxisLines;
    line.interpolateNullValues = self.interpolateNullValues;
    
    
    line.enableRefrenceFrame = self.enableReferenceAxisFrame;
    line.enableRightReferenceFrameLine = self.enableRightReferenceAxisFrameLine;
    line.enableTopReferenceFrameLine = self.enableTopReferenceAxisFrameLine;
    line.enableLeftReferenceFrameLine = self.enableLeftReferenceAxisFrameLine;
    line.enableBottomReferenceFrameLine = self.enableBottomReferenceAxisFrameLine;
    
    if (self.enableReferenceXAxisLines || self.enableReferenceYAxisLines) {
        line.enableRefrenceLines = YES;
        line.refrenceLineColor = self.colorReferenceLines;
        line.verticalReferenceHorizontalFringeNegation = xAxisHorizontalFringeNegationValue;
        line.arrayOfVerticalRefrenceLinePoints = self.enableReferenceXAxisLines ? xAxisLabelPoints : nil;
        line.arrayOfHorizontalRefrenceLinePoints = self.enableReferenceYAxisLines ? yAxisLabelPoints : nil;
    }
    
    line.color = self.colorLine;
    line.lineGradient = self.gradientLine;
    line.lineGradientDirection = self.gradientLineDirection;
    line.animationTime = self.animationGraphEntranceTime;
    line.animationType = self.animationGraphStyle;
    
    if (self.averageLine.enableAverageLine == YES) {
        if (self.averageLine.yValue == 0.0) self.averageLine.yValue = [self calculatePointValueAverage].floatValue;
        line.averageLineYCoordinate = [self yPositionForDotValue:self.averageLine.yValue];
        line.averageLine = self.averageLine;
    } else line.averageLine = self.averageLine;
    
    line.disableMainLine = self.displayDotsOnly;
    
    [self addSubview:line];
    [self sendSubviewToBack:line];
    [self sendSubviewToBack:self.backgroundXAxis];
    [self didFinishDrawingIncludingYAxis:NO];
    
    // 添加点击选中点的数据
    if (!self.backgroundTagView.superview) {
        [self addSubview:self.backgroundTagView];
        
        // 当前价值
        UILabel *labelNowValue = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.backgroundTagView.frame.size.width, 15)];
        labelNowValue.font = self.labelFont;
        labelNowValue.textColor = [UIColor blackColor];
        labelNowValue.textAlignment = NSTextAlignmentLeft;
        labelNowValue.tag = BackgroundViewTag4001;
        [self.backgroundTagView addSubview:labelNowValue];
        
        // 投入资金
        UILabel *labelInputValue = [[UILabel alloc] initWithFrame:CGRectMake(0, labelNowValue.frame.size.height + labelNowValue.frame.origin.y + 2, labelNowValue.frame.size.width, labelNowValue.frame.size.height)];
        labelInputValue.font = self.labelFont;
        labelInputValue.textColor = [UIColor blackColor];
        labelInputValue.textAlignment = NSTextAlignmentLeft;
        labelInputValue.tag = BackgroundViewTag4002;
        [self.backgroundTagView addSubview:labelInputValue];
        // 显示当前的值
        [self changeLabelTextWithPoint:nil];
    }
}

- (void)drawXAxis {
    if (!self.enableXAxisLabel) return;
    if (![self.dataSource respondsToSelector:@selector(lineGraph:labelOnXAxisForIndex:)]) return;
    
    for (UIView *subview in [self subviews]) {
        if ([subview isKindOfClass:[UILabel class]] && subview.tag == DotLastTag100000) [subview removeFromSuperview];
        else if ([subview isKindOfClass:[UIView class]] && subview.tag == BackgroundXAxisTag2200) [subview removeFromSuperview];
    }
    
    // Remove all X-Axis Labels before adding them to the array
    [xAxisValues removeAllObjects];
    [xAxisLabels removeAllObjects];
    [xAxisLabelPoints removeAllObjects];
    xAxisHorizontalFringeNegationValue = 0.0;
    
    // 绘制X轴的背景区域
    self.backgroundXAxis = [[UIView alloc] initWithFrame:[self drawableXAxisArea]];
    self.backgroundXAxis.tag = BackgroundXAxisTag2200;
    if (self.colorBackgroundXaxis == nil) self.backgroundXAxis.backgroundColor = self.colorBottom;
    else self.backgroundXAxis.backgroundColor = self.colorBackgroundXaxis;
    
    self.backgroundXAxis.alpha = self.alphaBackgroundXaxis;
    [self addSubview:self.backgroundXAxis];
    
    if ([self.delegate respondsToSelector:@selector(incrementPositionsForXAxisOnLineGraph:)]) {
        NSArray *axisValues = [self.delegate incrementPositionsForXAxisOnLineGraph:self];
        for (NSNumber *increment in axisValues) {
            NSInteger index = increment.integerValue;
            NSString *xAxisLabelText = [self xAxisTextForIndex:index];
            
            UILabel *labelXAxis = [self xAxisLabelWithText:xAxisLabelText atIndex:index];
            [xAxisLabels addObject:labelXAxis];
            
            if (self.positionYAxisRight) {
                NSNumber *xAxisLabelCoordinate = [NSNumber numberWithFloat:labelXAxis.center.x];
                [xAxisLabelPoints addObject:xAxisLabelCoordinate];
            } else {
                NSNumber *xAxisLabelCoordinate = [NSNumber numberWithFloat:labelXAxis.center.x-self.YAxisLabelXOffset];
                [xAxisLabelPoints addObject:xAxisLabelCoordinate];
            }
            
            [self addSubview:labelXAxis];
            [xAxisValues addObject:xAxisLabelText];
        }
    } else if ([self.delegate respondsToSelector:@selector(baseIndexForXAxisOnLineGraph:)] && [self.delegate respondsToSelector:@selector(incrementIndexForXAxisOnLineGraph:)]) {
        NSInteger baseIndex = [self.delegate baseIndexForXAxisOnLineGraph:self];
        NSInteger increment = [self.delegate incrementIndexForXAxisOnLineGraph:self];
        
        NSInteger startingIndex = baseIndex;
        while (startingIndex < numberOfPoints) {
            
            NSString *xAxisLabelText = [self xAxisTextForIndex:startingIndex];
            
            UILabel *labelXAxis = [self xAxisLabelWithText:xAxisLabelText atIndex:startingIndex];
            [xAxisLabels addObject:labelXAxis];
            
            if (self.positionYAxisRight) {
                NSNumber *xAxisLabelCoordinate = [NSNumber numberWithFloat:labelXAxis.center.x];
                [xAxisLabelPoints addObject:xAxisLabelCoordinate];
            } else {
                NSNumber *xAxisLabelCoordinate = [NSNumber numberWithFloat:labelXAxis.center.x-self.YAxisLabelXOffset];
                [xAxisLabelPoints addObject:xAxisLabelCoordinate];
            }
            
            [self addSubview:labelXAxis];
            [xAxisValues addObject:xAxisLabelText];
            
            startingIndex += increment;
        }
    } else {
        NSInteger numberOfGaps = 1;
        
        if ([self.delegate respondsToSelector:@selector(numberOfGapsBetweenLabelsOnLineGraph:)]) {
            numberOfGaps = [self.delegate numberOfGapsBetweenLabelsOnLineGraph:self] + 1;
            
        } else if ([self.delegate respondsToSelector:@selector(numberOfGapsBetweenLabels)]) {
            [self printDeprecationWarningForOldMethod:@"numberOfGapsBetweenLabels" andReplacementMethod:@"numberOfGapsBetweenLabelsOnLineGraph:"];
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            numberOfGaps = [self.delegate numberOfGapsBetweenLabels] + 1;
#pragma clang diagnostic pop
            
        } else {
            numberOfGaps = 1;
        }
        
        if (numberOfGaps >= (numberOfPoints - 1)) {
            NSString *firstXLabel = [self xAxisTextForIndex:0];
            NSString *lastXLabel = [self xAxisTextForIndex:numberOfPoints - 1];
            
            CGFloat viewWidth = self.frame.size.width - self.YAxisLabelXOffset;
            
            CGFloat xAxisXPositionFirstOffset;
            CGFloat xAxisXPositionLastOffset;
            if (self.positionYAxisRight) {
                xAxisXPositionFirstOffset = 3;
                xAxisXPositionLastOffset = xAxisXPositionFirstOffset + 1 + viewWidth/2;
            } else {
                xAxisXPositionFirstOffset = 3+self.YAxisLabelXOffset;
                xAxisXPositionLastOffset = viewWidth/2 + xAxisXPositionFirstOffset + 1;
            }
            UILabel *firstLabel = [self xAxisLabelWithText:firstXLabel atIndex:0];
            firstLabel.frame = CGRectMake(xAxisXPositionFirstOffset, self.frame.size.height-20, viewWidth/2, 20);
            
            firstLabel.textAlignment = NSTextAlignmentLeft;
            [self addSubview:firstLabel];
            [xAxisValues addObject:firstXLabel];
            [xAxisLabels addObject:firstLabel];
            
            UILabel *lastLabel = [self xAxisLabelWithText:lastXLabel atIndex:numberOfPoints - 1];
            lastLabel.frame = CGRectMake(xAxisXPositionLastOffset, self.frame.size.height-20, viewWidth/2 - 4, 20);
            lastLabel.textAlignment = NSTextAlignmentRight;
            [self addSubview:lastLabel];
            [xAxisValues addObject:lastXLabel];
            [xAxisLabels addObject:lastLabel];
            
            if (self.positionYAxisRight) {
                NSNumber *xFirstAxisLabelCoordinate = @(firstLabel.center.x);
                NSNumber *xLastAxisLabelCoordinate = @(lastLabel.center.x);
                [xAxisLabelPoints addObject:xFirstAxisLabelCoordinate];
                [xAxisLabelPoints addObject:xLastAxisLabelCoordinate];
            } else {
                NSNumber *xFirstAxisLabelCoordinate = @(firstLabel.center.x - self.YAxisLabelXOffset);
                NSNumber *xLastAxisLabelCoordinate = @(lastLabel.center.x - self.YAxisLabelXOffset);
                [xAxisLabelPoints addObject:xFirstAxisLabelCoordinate];
                [xAxisLabelPoints addObject:xLastAxisLabelCoordinate];
            }
        } else {
            @autoreleasepool {
                NSInteger offset = [self offsetForXAxisWithNumberOfGaps:numberOfGaps]; // The offset (if possible and necessary) used to shift the Labels on the X-Axis for them to be centered.
                
                for (int i = 1; i <= (numberOfPoints/numberOfGaps); i++) {
                    NSInteger index = i *numberOfGaps - 1 - offset;
                    NSString *xAxisLabelText = [self xAxisTextForIndex:index];
                    
                    UILabel *labelXAxis = [self xAxisLabelWithText:xAxisLabelText atIndex:index];
                    [xAxisLabels addObject:labelXAxis];
                    
                    if (self.positionYAxisRight) {
                        NSNumber *xAxisLabelCoordinate = [NSNumber numberWithFloat:labelXAxis.center.x];
                        [xAxisLabelPoints addObject:xAxisLabelCoordinate];
                    } else {
                        NSNumber *xAxisLabelCoordinate = [NSNumber numberWithFloat:labelXAxis.center.x - self.YAxisLabelXOffset];
                        [xAxisLabelPoints addObject:xAxisLabelCoordinate];
                    }
                    
                    [self addSubview:labelXAxis];
                    [xAxisValues addObject:xAxisLabelText];
                }
                
            }
        }
    }
    __block NSUInteger lastMatchIndex;
    
    NSMutableArray *overlapLabels = [NSMutableArray arrayWithCapacity:0];
    [xAxisLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            lastMatchIndex = 0;
        } else { // Skip first one
            UILabel *prevLabel = [xAxisLabels objectAtIndex:lastMatchIndex];
            CGRect r = CGRectIntersection(prevLabel.frame, label.frame);
            if (CGRectIsNull(r)) lastMatchIndex = idx;
            else [overlapLabels addObject:label]; // Overlapped
        }
        
        BOOL fullyContainsLabel = CGRectContainsRect(self.bounds, label.frame);
        if (!fullyContainsLabel) {
            [overlapLabels addObject:label];
        }
    }];
    
    for (UILabel *l in overlapLabels) {
        [l removeFromSuperview];
    }
}

- (NSString *)xAxisTextForIndex:(NSInteger)index {
    NSString *xAxisLabelText = @"";
    
    if ([self.dataSource respondsToSelector:@selector(lineGraph:labelOnXAxisForIndex:)]) {
        xAxisLabelText = [self.dataSource lineGraph:self labelOnXAxisForIndex:index];
        
    } else if ([self.delegate respondsToSelector:@selector(labelOnXAxisForIndex:)]) {
        [self printDeprecationWarningForOldMethod:@"labelOnXAxisForIndex:" andReplacementMethod:@"lineGraph:labelOnXAxisForIndex:"];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        xAxisLabelText = [self.delegate labelOnXAxisForIndex:index];
#pragma clang diagnostic pop
        
    } else if ([self.delegate respondsToSelector:@selector(lineGraph:labelOnXAxisForIndex:)]) {
        [self printDeprecationAndUnavailableWarningForOldMethod:@"lineGraph:labelOnXAxisForIndex:"];
        NSException *exception = [NSException exceptionWithName:@"Implementing Unavailable Delegate Method" reason:@"lineGraph:labelOnXAxisForIndex: is no longer available on the delegate. It must be implemented on the data source." userInfo:nil];
        [exception raise];
        
    } else  {
        xAxisLabelText = @"";
    }
    
    return xAxisLabelText;
}

- (UILabel *)xAxisLabelWithText:(NSString *)text atIndex:(NSInteger)index {
    UILabel *labelXAxis = [[UILabel alloc] init];
    labelXAxis.text = text;
    labelXAxis.font = self.labelFont;
    labelXAxis.textAlignment = 1;
    labelXAxis.textColor = self.colorXaxisLabel;
    labelXAxis.backgroundColor = [UIColor clearColor];
    labelXAxis.tag = DotLastTag100000;
    
    // Add support multi-line, but this might overlap with the graph line if text have too many lines
    labelXAxis.numberOfLines = 0;
    CGRect lRect = [labelXAxis.text boundingRectWithSize:self.viewForFirstBaselineLayout.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:labelXAxis.font} context:nil];
    
    CGPoint center;
    
    /* OLD LABEL GENERATION CODE
     CGFloat availablePositionRoom = self.viewForFirstBaselineLayout.frame.size.width; // Get view width of view
     CGFloat positioningDivisor = (float)index / numberOfPoints; // Generate relative position of point based on current index and total
     CGFloat horizontalTranslation = self.YAxisLabelXOffset + lRect.size.width;
     CGFloat xPosition = (availablePositionRoom * positioningDivisor) + horizontalTranslation;
     // NSLog(@"availablePositionRoom: %f, positioningDivisor: %f, horizontalTranslation: %f, xPosition: %f", availablePositionRoom, positioningDivisor, horizontalTranslation, xPosition); // Uncomment for debugging */
    
    // Determine the horizontal translation to perform on the far left and far right labels
    // This property is negated when calculating the position of reference frames
    CGFloat horizontalTranslation;
    if (index == 0) {
        horizontalTranslation = lRect.size.width/2;
    } else if (index+1 == numberOfPoints) {
        horizontalTranslation = -lRect.size.width/2;
    } else horizontalTranslation = 0;
    xAxisHorizontalFringeNegationValue = horizontalTranslation;
    
    // Determine the final x-axis position
    CGFloat positionOnXAxis;
    if (self.positionYAxisRight) {
        positionOnXAxis = (((self.frame.size.width - self.YAxisLabelXOffset) / (numberOfPoints - 1)) * index) + horizontalTranslation;
    } else {
        positionOnXAxis = (((self.frame.size.width - self.YAxisLabelXOffset) / (numberOfPoints - 1)) * index) + self.YAxisLabelXOffset + horizontalTranslation;
    }
    
    // Set the final center point of the x-axis labels
    if (self.positionYAxisRight) {
        center = CGPointMake(positionOnXAxis, self.frame.size.height - lRect.size.height/2);
    } else {
        center = CGPointMake(positionOnXAxis, self.frame.size.height - lRect.size.height/2);
    }
    
    CGRect rect = labelXAxis.frame;
    rect.size = lRect.size;
    labelXAxis.frame = rect;
    labelXAxis.center = center;
    return labelXAxis;
}

- (void)drawYAxis {
    for (UIView *subview in [self subviews]) {
        if ([subview isKindOfClass:[UILabel class]] && subview.tag == LabelYAxisTag2000 ) {
            [subview removeFromSuperview];
        } else if ([subview isKindOfClass:[UIView class]] && subview.tag == BackgroundYAxisTag2100 ) {
            [subview removeFromSuperview];
        }
    }
    
    CGRect frameForBackgroundYAxis;
    CGRect frameForLabelYAxis;
    CGFloat xValueForCenterLabelYAxis;
    NSTextAlignment textAlignmentForLabelYAxis;
    
    if (self.positionYAxisRight) {
        frameForBackgroundYAxis = CGRectMake(self.frame.size.width - self.YAxisLabelXOffset, 0, self.YAxisLabelXOffset, self.frame.size.height);
        frameForLabelYAxis = CGRectMake(self.frame.size.width - self.YAxisLabelXOffset - 5, 0, self.YAxisLabelXOffset - 5, 15);
        xValueForCenterLabelYAxis = self.frame.size.width - self.YAxisLabelXOffset /2;
        textAlignmentForLabelYAxis = NSTextAlignmentRight;
    } else {
        frameForBackgroundYAxis = CGRectMake(0, 0, self.YAxisLabelXOffset, self.frame.size.height);
        frameForLabelYAxis = CGRectMake(0, 0, self.YAxisLabelXOffset - 5, 15);
        xValueForCenterLabelYAxis = self.YAxisLabelXOffset/2;
        textAlignmentForLabelYAxis = NSTextAlignmentRight;
    }
    
    UIView *backgroundYaxis = [[UIView alloc] initWithFrame:frameForBackgroundYAxis];
    backgroundYaxis.tag = BackgroundYAxisTag2100;
    if (self.colorBackgroundYaxis == nil) backgroundYaxis.backgroundColor = self.colorTop;
    else backgroundYaxis.backgroundColor = self.colorBackgroundYaxis;
    
    backgroundYaxis.alpha = self.alphaBackgroundYaxis;
    [self addSubview:backgroundYaxis];
    
    NSMutableArray *yAxisLabels = [NSMutableArray arrayWithCapacity:0];
    [yAxisLabelPoints removeAllObjects];
    
    NSString *yAxisSuffix = @"";
    NSString *yAxisPrefix = @"";
    
    if ([self.delegate respondsToSelector:@selector(yAxisPrefixOnLineGraph:)]) yAxisPrefix = [self.delegate yAxisPrefixOnLineGraph:self];
    if ([self.delegate respondsToSelector:@selector(yAxisSuffixOnLineGraph:)]) yAxisSuffix = [self.delegate yAxisSuffixOnLineGraph:self];
    
    if (self.autoScaleYAxis) {
        // Plot according to min-max range
        NSNumber *minimumValue;
        NSNumber *maximumValue;
        
        minimumValue = [self calculateMinimumPointValue];
        maximumValue = [self calculateMaximumPointValue];
        
        CGFloat numberOfLabels;
        if ([self.delegate respondsToSelector:@selector(numberOfYAxisLabelsOnLineGraph:)]) {
            numberOfLabels = [self.delegate numberOfYAxisLabelsOnLineGraph:self];
        } else numberOfLabels = 3;
        
        NSMutableArray *dotValues = [[NSMutableArray alloc] initWithCapacity:numberOfLabels];
        if ([self.delegate respondsToSelector:@selector(baseValueForYAxisOnLineGraph:)] && [self.delegate respondsToSelector:@selector(incrementValueForYAxisOnLineGraph:)]) {
            CGFloat baseValue = [self.delegate baseValueForYAxisOnLineGraph:self];
            CGFloat increment = [self.delegate incrementValueForYAxisOnLineGraph:self];
            
            float yAxisPosition = baseValue;
            if (baseValue + increment * 100 < maximumValue.doubleValue) {
                NSLog(@"[BEMSimpleLineGraph] Increment does not properly lay out Y axis, bailing early");
                return;
            }
            
            while(yAxisPosition < maximumValue.floatValue + increment) {
                [dotValues addObject:@(yAxisPosition)];
                yAxisPosition += increment;
            }
        } else if (numberOfLabels <= 0) return;
        else if (numberOfLabels == 1) {
            [dotValues removeAllObjects];
            [dotValues addObject:[NSNumber numberWithInt:(minimumValue.intValue + maximumValue.intValue)/2]];
        } else {
            [dotValues addObject:minimumValue];
            [dotValues addObject:maximumValue];
            for (int i=1; i<numberOfLabels-1; i++) {
                [dotValues addObject:[NSNumber numberWithFloat:(minimumValue.doubleValue + ((maximumValue.doubleValue - minimumValue.doubleValue)/(numberOfLabels-1))*i)]];
            }
        }
        
        for (NSNumber *dotValue in dotValues) {
            CGFloat yAxisPosition = [self yPositionForDotValue:dotValue.floatValue];
            UILabel *labelYAxis = [[UILabel alloc] initWithFrame:frameForLabelYAxis];
            NSString *formattedValue = [NSString stringWithFormat:self.formatStringForValues, dotValue.doubleValue];
            labelYAxis.text = [NSString stringWithFormat:@"%@%@%@", yAxisPrefix, formattedValue, yAxisSuffix];
            labelYAxis.textAlignment = textAlignmentForLabelYAxis;
            labelYAxis.font = self.labelFont;
            labelYAxis.textColor = self.colorYaxisLabel;
            labelYAxis.backgroundColor = [UIColor clearColor];
            labelYAxis.tag = LabelYAxisTag2000;
            labelYAxis.center = CGPointMake(xValueForCenterLabelYAxis, yAxisPosition);
            [self addSubview:labelYAxis];
            [yAxisLabels addObject:labelYAxis];
            
            NSNumber *yAxisLabelCoordinate = @(labelYAxis.center.y);
            [yAxisLabelPoints addObject:yAxisLabelCoordinate];
        }
    } else {
        NSInteger numberOfLabels;
        if ([self.delegate respondsToSelector:@selector(numberOfYAxisLabelsOnLineGraph:)]) numberOfLabels = [self.delegate numberOfYAxisLabelsOnLineGraph:self];
        else numberOfLabels = 3;
        
        CGFloat graphHeight = self.frame.size.height;
        CGFloat graphSpacing = (graphHeight - self.XAxisLabelYOffset) / numberOfLabels;
        
        CGFloat yAxisPosition = graphHeight - self.XAxisLabelYOffset + graphSpacing/2;
        
        for (NSInteger i = numberOfLabels; i > 0; i--) {
            yAxisPosition -= graphSpacing;
            
            UILabel *labelYAxis = [[UILabel alloc] initWithFrame:frameForLabelYAxis];
            labelYAxis.center = CGPointMake(xValueForCenterLabelYAxis, yAxisPosition);
            labelYAxis.text = [NSString stringWithFormat:self.formatStringForValues, (graphHeight - self.XAxisLabelYOffset - yAxisPosition)];
            labelYAxis.font = self.labelFont;
            labelYAxis.textAlignment = textAlignmentForLabelYAxis;
            labelYAxis.textColor = self.colorYaxisLabel;
            labelYAxis.backgroundColor = [UIColor clearColor];
            labelYAxis.tag = LabelYAxisTag2000;
            
            [self addSubview:labelYAxis];
            
            [yAxisLabels addObject:labelYAxis];
            
            NSNumber *yAxisLabelCoordinate = @(labelYAxis.center.y);
            [yAxisLabelPoints addObject:yAxisLabelCoordinate];
        }
    }
    
    // Detect overlapped labels
    __block NSUInteger lastMatchIndex = 0;
    NSMutableArray *overlapLabels = [NSMutableArray arrayWithCapacity:0];
    
    [yAxisLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
        
        if (idx==0) lastMatchIndex = 0;
        else { // Skip first one
            UILabel *prevLabel = yAxisLabels[lastMatchIndex];
            CGRect r = CGRectIntersection(prevLabel.frame, label.frame);
            if (CGRectIsNull(r)) lastMatchIndex = idx;
            else [overlapLabels addObject:label]; // overlapped
        }
        
        // Axis should fit into our own view
        BOOL fullyContainsLabel = CGRectContainsRect(self.bounds, label.frame);
        if (!fullyContainsLabel) {
            [overlapLabels addObject:label];
            [yAxisLabelPoints removeObject:@(label.center.y)];
        }
    }];
    
    for (UILabel *label in overlapLabels) {
        [label removeFromSuperview];
    }
    
    [self didFinishDrawingIncludingYAxis:YES];
}

/// 图中不包含轴的区域, 即除去绘制Y轴和X轴后剩余的区域，也就是曲线绘制的区域
- (CGRect)drawableGraphArea {
    //  CGRectMake(xAxisXPositionFirstOffset, self.frame.size.height-20, viewWidth/2, 20);
    NSInteger xAxisHeight = 20;
    CGFloat xOrigin = self.positionYAxisRight ? 0 : self.YAxisLabelXOffset;
    CGFloat viewWidth = self.frame.size.width - self.YAxisLabelXOffset;
    CGFloat adjustedHeight = self.bounds.size.height - xAxisHeight;
    
    CGRect rect = CGRectMake(xOrigin, 0, viewWidth, adjustedHeight);
    return rect;
}

// X轴绘制的区域
- (CGRect)drawableXAxisArea {
    NSInteger xAxisHeight = 20;
    NSInteger xAxisWidth = [self drawableGraphArea].size.width + 1;
    CGFloat xAxisXOrigin = self.positionYAxisRight ? 0 : self.YAxisLabelXOffset;
    CGFloat xAxisYOrigin = self.bounds.size.height - xAxisHeight;
    return CGRectMake(xAxisXOrigin, xAxisYOrigin, xAxisWidth, xAxisHeight);
}

/// Calculates the optimum offset needed for the Labels to be centered on the X-Axis.
- (NSInteger)offsetForXAxisWithNumberOfGaps:(NSInteger)numberOfGaps {
    NSInteger leftGap = numberOfGaps - 1;
    NSInteger rightGap = numberOfPoints - (numberOfGaps*(numberOfPoints/numberOfGaps));
    NSInteger offset = 0;
    
    if (leftGap != rightGap) {
        for (int i = 0; i <= numberOfGaps; i++) {
            if (leftGap - i == rightGap + i) {
                offset = i;
            }
        }
    }
    
    return offset;
}

- (void)displayPermanentLabelForPoint:(BEMCircle *)circleDot {
    self.enablePopUpReport = NO;
    self.xCenterLabel = circleDot.center.x;
    
    BEMPermanentPopupLabel *permanentPopUpLabel = [[BEMPermanentPopupLabel alloc] init];
    permanentPopUpLabel.textAlignment = NSTextAlignmentCenter;
    permanentPopUpLabel.numberOfLines = 0;
    
    NSString *prefix = @"";
    NSString *suffix = @"";
    
    if ([self.delegate respondsToSelector:@selector(popUpSuffixForlineGraph:)])
        suffix = [self.delegate popUpSuffixForlineGraph:self];
    
    if ([self.delegate respondsToSelector:@selector(popUpPrefixForlineGraph:)])
        prefix = [self.delegate popUpPrefixForlineGraph:self];
    
    int index = (int)(circleDot.tag - DotFirstTag10000);
    NSNumber *value = dataPoints[index]; // @((NSInteger) circleDot.absoluteValue)
    NSString *formattedValue = [NSString stringWithFormat:self.formatStringForValues, value.doubleValue];
    permanentPopUpLabel.text = [NSString stringWithFormat:@"%@%@%@", prefix, formattedValue, suffix];
    
    permanentPopUpLabel.font = self.labelFont;
    permanentPopUpLabel.backgroundColor = [UIColor clearColor];
    [permanentPopUpLabel sizeToFit];
    permanentPopUpLabel.center = CGPointMake(self.xCenterLabel, circleDot.center.y - circleDot.frame.size.height/2 - 15);
    permanentPopUpLabel.alpha = 0;
    
    BEMPermanentPopupView *permanentPopUpView = [[BEMPermanentPopupView alloc] initWithFrame:CGRectMake(0, 0, permanentPopUpLabel.frame.size.width + 7, permanentPopUpLabel.frame.size.height + 2)];
    permanentPopUpView.backgroundColor = self.colorBackgroundPopUplabel;
    permanentPopUpView.alpha = 0;
    permanentPopUpView.layer.cornerRadius = 3;
    permanentPopUpView.tag = PermanentPopUpViewTag3100;
    permanentPopUpView.center = permanentPopUpLabel.center;
    
    if (permanentPopUpLabel.frame.origin.x <= 0) {
        self.xCenterLabel = permanentPopUpLabel.frame.size.width/2 + 4;
        permanentPopUpLabel.center = CGPointMake(self.xCenterLabel, circleDot.center.y - circleDot.frame.size.height/2 - 15);
    } else if (self.enableYAxisLabel == YES && permanentPopUpLabel.frame.origin.x <= self.YAxisLabelXOffset) {
        self.xCenterLabel = permanentPopUpLabel.frame.size.width/2 + 4;
        permanentPopUpLabel.center = CGPointMake(self.xCenterLabel + self.YAxisLabelXOffset, circleDot.center.y - circleDot.frame.size.height/2 - 15);
    } else if ((permanentPopUpLabel.frame.origin.x + permanentPopUpLabel.frame.size.width) >= self.frame.size.width) {
        self.xCenterLabel = self.frame.size.width - permanentPopUpLabel.frame.size.width/2 - 4;
        permanentPopUpLabel.center = CGPointMake(self.xCenterLabel, circleDot.center.y - circleDot.frame.size.height/2 - 15);
    }
    
    if (permanentPopUpLabel.frame.origin.y <= 2) {
        permanentPopUpLabel.center = CGPointMake(self.xCenterLabel, circleDot.center.y + circleDot.frame.size.height/2 + 15);
    }
    
    if ([self checkOverlapsForView:permanentPopUpView] == YES) {
        permanentPopUpLabel.center = CGPointMake(self.xCenterLabel, circleDot.center.y + circleDot.frame.size.height/2 + 15);
    }
    
    permanentPopUpView.center = permanentPopUpLabel.center;
    
    [self addSubview:permanentPopUpView];
    [self addSubview:permanentPopUpLabel];
    
    if (self.animationGraphEntranceTime == 0) {
        permanentPopUpLabel.alpha = 1;
        permanentPopUpView.alpha = 0.7;
    } else {
        [UIView animateWithDuration:0.5 delay:self.animationGraphEntranceTime options:UIViewAnimationOptionCurveLinear animations:^{
            permanentPopUpLabel.alpha = 1;
            permanentPopUpView.alpha = 0.7;
        } completion:nil];
    }
}

- (BOOL)checkOverlapsForView:(UIView *)view {
    for (UIView *viewForLabel in [self subviews]) {
        if ([viewForLabel isKindOfClass:[UIView class]] && viewForLabel.tag == PermanentPopUpViewTag3100 ) {
            if ((viewForLabel.frame.origin.x + viewForLabel.frame.size.width) >= view.frame.origin.x) {
                if (viewForLabel.frame.origin.y >= view.frame.origin.y && viewForLabel.frame.origin.y <= view.frame.origin.y + view.frame.size.height) return YES;
                else if (viewForLabel.frame.origin.y + viewForLabel.frame.size.height >= view.frame.origin.y && viewForLabel.frame.origin.y + viewForLabel.frame.size.height <= view.frame.origin.y + view.frame.size.height) return YES;
            }
        }
    }
    return NO;
}

- (UIImage *)graphSnapshotImage {
    return [self graphSnapshotImageRenderedWhileInBackground:NO];
}

- (UIImage *)graphSnapshotImageRenderedWhileInBackground:(BOOL)appIsInBackground {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    
    if (appIsInBackground == NO) [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    else [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - Data Source

- (void)reloadGraph {
    for (UIView *subviews in self.subviews) {
        [subviews removeFromSuperview];
    }
    [self drawGraph];
    //    [self setNeedsLayout];
}

#pragma mark - Calculations

- (NSArray *)calculationDataPoints {
    NSPredicate *filter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSNumber *value = (NSNumber *)evaluatedObject;
        BOOL retVal = ![value isEqualToNumber:@(BEMNullGraphValue)];
        return retVal;
    }];
    NSArray *filteredArray = [dataPoints filteredArrayUsingPredicate:filter];
    return filteredArray;
}

- (NSNumber *)calculatePointValueAverage {
    NSArray *filteredArray = [self calculationDataPoints];
    if (filteredArray.count == 0) return [NSNumber numberWithInt:0];
    
    NSExpression *expression = [NSExpression expressionForFunction:@"average:" arguments:@[[NSExpression expressionForConstantValue:filteredArray]]];
    NSNumber *value = [expression expressionValueWithObject:nil context:nil];
    
    return value;
}

- (NSNumber *)calculatePointValueSum {
    NSArray *filteredArray = [self calculationDataPoints];
    if (filteredArray.count == 0) return [NSNumber numberWithInt:0];
    
    NSExpression *expression = [NSExpression expressionForFunction:@"sum:" arguments:@[[NSExpression expressionForConstantValue:filteredArray]]];
    NSNumber *value = [expression expressionValueWithObject:nil context:nil];
    
    return value;
}

- (NSNumber *)calculatePointValueMedian {
    NSArray *filteredArray = [self calculationDataPoints];
    if (filteredArray.count == 0) return [NSNumber numberWithInt:0];
    
    NSExpression *expression = [NSExpression expressionForFunction:@"median:" arguments:@[[NSExpression expressionForConstantValue:filteredArray]]];
    NSNumber *value = [expression expressionValueWithObject:nil context:nil];
    
    return value;
}

- (NSNumber *)calculatePointValueMode {
    NSArray *filteredArray = [self calculationDataPoints];
    if (filteredArray.count == 0) return [NSNumber numberWithInt:0];
    
    NSExpression *expression = [NSExpression expressionForFunction:@"mode:" arguments:@[[NSExpression expressionForConstantValue:filteredArray]]];
    NSMutableArray *value = [expression expressionValueWithObject:nil context:nil];
    
    return [value firstObject];
}

- (NSNumber *)calculateLineGraphStandardDeviation {
    NSArray *filteredArray = [self calculationDataPoints];
    if (filteredArray.count == 0) return [NSNumber numberWithInt:0];
    
    NSExpression *expression = [NSExpression expressionForFunction:@"stddev:" arguments:@[[NSExpression expressionForConstantValue:filteredArray]]];
    NSNumber *value = [expression expressionValueWithObject:nil context:nil];
    
    return value;
}

- (NSNumber *)calculateMinimumPointValue {
    NSArray *filteredArray = [self calculationDataPoints];
    if (filteredArray.count == 0) return [NSNumber numberWithInt:0];
    
    NSExpression *expression = [NSExpression expressionForFunction:@"min:" arguments:@[[NSExpression expressionForConstantValue:filteredArray]]];
    NSNumber *value = [expression expressionValueWithObject:nil context:nil];
    return value;
}

- (NSNumber *)calculateMaximumPointValue {
    NSArray *filteredArray = [self calculationDataPoints];
    if (filteredArray.count == 0) return [NSNumber numberWithInt:0];
    
    NSExpression *expression = [NSExpression expressionForFunction:@"max:" arguments:@[[NSExpression expressionForConstantValue:filteredArray]]];
    NSNumber *value = [expression expressionValueWithObject:nil context:nil];
    
    return value;
}


#pragma mark - Values

- (NSArray *)graphValuesForXAxis {
    return xAxisValues;
}

- (NSArray *)graphValuesForDataPoints {
    return dataPoints;
}

- (NSArray *)graphLabelsForXAxis {
    return xAxisLabels;
}

- (void)setAnimationGraphStyle:(BEMLineAnimation)animationGraphStyle {
    _animationGraphStyle = animationGraphStyle;
    if (_animationGraphStyle == BEMLineAnimationNone)
        self.animationGraphEntranceTime = 0.f;
}


#pragma mark - Touch Gestures

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isEqual:self.panGesture]) {
        if (gestureRecognizer.numberOfTouches >= self.touchReportFingersRequired) {
            CGPoint translation = [self.panGesture velocityInView:self.panView];
            return fabs(translation.y) < fabs(translation.x);
        } else return NO;
        return YES;
    } else return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (void)handleGestureAction:(UIGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer locationInView:self.viewForFirstBaselineLayout];
    
    if (!((translation.x + self.frame.origin.x) <= self.frame.origin.x) && !((translation.x + self.frame.origin.x) >= self.frame.origin.x + self.frame.size.width)) { // To make sure the vertical line doesn't go beyond the frame of the graph.
        self.touchInputLine.frame = CGRectMake(translation.x - self.widthTouchInputLine/2, 0, self.widthTouchInputLine, self.frame.size.height *0.95);
    }
    
    self.touchInputLine.alpha = self.alphaTouchInputLine;
    
    closestDot = [self closestDotFromtouchInputLine:self.touchInputLine];
    // 显示圆点
    [self changeDotAlpha:closestDot];
    
    // 找到点击的圆点的真实数据，并展示在界面上
    [self changeLabelTextWithPoint:closestDot];
    
    if (self.enablePopUpReport == YES && closestDot.tag >= DotFirstTag10000 && closestDot.tag < DotLastTag100000 && [closestDot isKindOfClass:[BEMCircle class]] && self.alwaysDisplayPopUpLabels == NO) {
        // 显示标签
        [self setUpPopUpLabelAbovePoint:closestDot];
    }
    
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
        if (closestDot.tag >= DotFirstTag10000 && closestDot.tag < DotLastTag100000 && [closestDot isMemberOfClass:[BEMCircle class]]) {
            // 通知点击了第几个
            if ([self.delegate respondsToSelector:@selector(lineGraph:didTouchGraphWithClosestIndex:)] && self.enableTouchReport == YES) {
                [self.delegate lineGraph:self didTouchGraphWithClosestIndex:((NSInteger)closestDot.tag - DotFirstTag10000)];
            }
        }
    }
    
    // ON RELEASE
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(lineGraph:didReleaseTouchFromGraphWithClosestIndex:)]) {
            [self.delegate lineGraph:self didReleaseTouchFromGraphWithClosestIndex:(closestDot.tag - DotFirstTag10000)];
        }
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            if (self.alwaysDisplayDots == NO && self.displayDotsOnly == NO) {
                // 隐藏圆点
                [self changeDotAlpha:closestDot];
                // 标签上的文字显示当前的状态，不在是点击时
                [self changeLabelTextWithPoint:nil];
            }
            
            self.touchInputLine.alpha = 0;
            if (self.enablePopUpReport == YES) {
                self.popUpView.alpha = 0;
                self.popUpLabel.alpha = 0;
                //self.customPopUpView.alpha = 0;
            }
        } completion:nil];
    }
}

- (void)changeLabelTextWithPoint:(BEMCircle *)point {
    UILabel *lableNow = (UILabel *)[self viewWithTag:BackgroundViewTag4001];
    UILabel *lableInput = (UILabel *)[self viewWithTag:BackgroundViewTag4002];
    NSInteger arrayCount = ((NSArray *)yAxisValues.firstObject).count;
    
    NSInteger tag = 0;
    if (point) {
        tag = (NSInteger)point.tag - DotFirstTag10000;
    } else {
        tag = arrayCount - 1;
    }
    NSString *nowValue = [NSString stringWithFormat:@"当前价值: %@ 元", dataPoints[tag + 0 * arrayCount]];
    NSString *inputValue = [NSString stringWithFormat:@"投入资金: %@ 元", dataPoints[tag + 1 * arrayCount]];
    
    lableNow.text = nowValue;
    lableInput.text = inputValue;
}

- (void)changeDotAlpha:(BEMCircle *)point {
    point.alpha = point.alpha == 0 ? 0.8 : 0;
    //NSInteger count = yAxisValues.count;
    //NSInteger tag = point.tag - DotFirstTag10000;
    //for (NSInteger i = 1; i < count; i++) {
    //    BEMCircle *otherPoint = [self viewWithTag:(i + 1) * DotFirstTag10000 + tag];
    //    otherPoint.alpha = otherPoint.alpha == 0 ? 0.8 : 0;
    //}
}

- (CGFloat)distanceToClosestPoint {
    return sqrt(pow(closestDot.center.x - self.touchInputLine.center.x, 2));
}

- (void)setUpPopUpLabelAbovePoint:(BEMCircle *)closestPoint {
    self.xCenterLabel = closestDot.center.x;
    self.yCenterLabel = closestDot.center.y - closestDot.frame.size.height/2 - 15;
    self.popUpView.center = CGPointMake(self.xCenterLabel, self.yCenterLabel);
    self.popUpLabel.center = self.popUpView.center;
    int index = (int)(closestDot.tag - DotFirstTag10000);
    
    if ([self.delegate respondsToSelector:@selector(lineGraph:modifyPopupView:forIndex:)]) {
        [self.delegate lineGraph:self modifyPopupView:self.popUpView forIndex:index];
    }
    self.xCenterLabel = closestDot.center.x;
    self.yCenterLabel = closestDot.center.y - closestDot.frame.size.height/2 - 15;
    self.popUpView.center = CGPointMake(self.xCenterLabel, self.yCenterLabel);
    
    self.popUpView.alpha = 1.0;
    
    CGPoint popUpViewCenter = CGPointZero;
    
    if ([self.delegate respondsToSelector:@selector(popUpSuffixForlineGraph:)])
        self.popUpLabel.text = [NSString stringWithFormat:@"%li%@", (long)[dataPoints[(NSInteger) closestDot.tag - DotFirstTag10000] integerValue], [self.delegate popUpSuffixForlineGraph:self]];
    else
        self.popUpLabel.text = [NSString stringWithFormat:@"%li", (long)[dataPoints[(NSInteger) closestDot.tag - DotFirstTag10000] integerValue]];
    
    if (self.enableYAxisLabel == YES && self.popUpView.frame.origin.x <= self.YAxisLabelXOffset && !self.positionYAxisRight) {
        self.xCenterLabel = self.popUpView.frame.size.width/2;
        popUpViewCenter = CGPointMake(self.xCenterLabel + self.YAxisLabelXOffset + 1, self.yCenterLabel);
    } else if ((self.popUpView.frame.origin.x + self.popUpView.frame.size.width) >= self.frame.size.width - self.YAxisLabelXOffset && self.positionYAxisRight) {
        self.xCenterLabel = self.frame.size.width - self.popUpView.frame.size.width/2;
        popUpViewCenter = CGPointMake(self.xCenterLabel - self.YAxisLabelXOffset, self.yCenterLabel);
    } else if (self.popUpView.frame.origin.x <= 0) {
        self.xCenterLabel = self.popUpView.frame.size.width/2;
        popUpViewCenter = CGPointMake(self.xCenterLabel, self.yCenterLabel);
    } else if ((self.popUpView.frame.origin.x + self.popUpView.frame.size.width) >= self.frame.size.width) {
        self.xCenterLabel = self.frame.size.width - self.popUpView.frame.size.width/2;
        popUpViewCenter = CGPointMake(self.xCenterLabel, self.yCenterLabel);
    }
    
    if (self.popUpView.frame.origin.y <= 2) {
        self.yCenterLabel = closestDot.center.y + closestDot.frame.size.height/2 + 15;
        popUpViewCenter = CGPointMake(self.xCenterLabel, closestDot.center.y + closestDot.frame.size.height/2 + 15);
    }
    
    if (!CGPointEqualToPoint(popUpViewCenter, CGPointZero)) {
        self.popUpView.center = popUpViewCenter;
    }
    
    if (!self.usingCustomPopupView) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.popUpView.alpha = 0.7;
            self.popUpLabel.alpha = 1;
        } completion:nil];
        NSString *prefix = @"";
        NSString *suffix = @"";
        if ([self.delegate respondsToSelector:@selector(popUpSuffixForlineGraph:)]) {
            suffix = [self.delegate popUpSuffixForlineGraph:self];
        }
        if ([self.delegate respondsToSelector:@selector(popUpPrefixForlineGraph:)]) {
            prefix = [self.delegate popUpPrefixForlineGraph:self];
        }
        NSNumber *value = dataPoints[index];
        NSString *formattedValue = [NSString stringWithFormat:self.formatStringForValues, value.doubleValue];
        self.popUpLabel.text = [NSString stringWithFormat:@"%@%@%@", prefix, formattedValue, suffix];
        self.popUpLabel.center = self.popUpView.center;
    }
}

#pragma mark - Graph Calculations

- (BEMCircle *)closestDotFromtouchInputLine:(UIView *)touchInputLine {
    currentlyCloser = CGFLOAT_MAX;
    for (BEMCircle *point in self.subviews) {
        if (point.tag >= DotFirstTag10000 && point.tag < DotLastTag100000 && [point isMemberOfClass:[BEMCircle class]]) {
            if (self.alwaysDisplayDots == NO && self.displayDotsOnly == NO) {
                point.alpha = 0;
            }
            
            CGFloat value = pow(((point.center.x) - touchInputLine.center.x), 2);
            if (value < currentlyCloser) {
                currentlyCloser = value;
                closestDot = point;
            }
        }
    }
    return closestDot;
}

- (CGFloat)getMaximumValue {
    // 获得最大值
    // 如果实现了这个协议，直接获取
    if ([self.delegate respondsToSelector:@selector(maxValueForLineGraph:)]) {
        return [self.delegate maxValueForLineGraph:self];
    } else {
        return FLT_MAX;
    }
}

// 获得最小值
- (CGFloat)getMinimumValue {
    if ([self.delegate respondsToSelector:@selector(minValueForLineGraph:)]) {
        return [self.delegate minValueForLineGraph:self];
    } else {
        return FLT_MIN;
    }
}

- (CGFloat)yPositionForDotValue:(CGFloat)dotValue {
    if (dotValue == BEMNullGraphValue) {
        return BEMNullGraphValue;
    }
    
    CGFloat positionOnYAxis; // The position on the Y-axis of the point currently being created.
    CGFloat padding = self.frame.size.height/2;
    if (padding > 90.0) {
        padding = 90.0;
    }
    
    if ([self.delegate respondsToSelector:@selector(staticPaddingForLineGraph:)])
        padding = [self.delegate staticPaddingForLineGraph:self];
    
    if (self.enableXAxisLabel) {
        if ([self.dataSource respondsToSelector:@selector(lineGraph:labelOnXAxisForIndex:)] || [self.dataSource respondsToSelector:@selector(labelOnXAxisForIndex:)]) {
            if ([xAxisLabels count] > 0) {
                UILabel *label = [xAxisLabels objectAtIndex:0];
                self.XAxisLabelYOffset = label.frame.size.height + self.widthLine;
            }
        }
    }
    
    if (self.minValue == self.maxValue && self.autoScaleYAxis == YES) {
        positionOnYAxis = self.frame.size.height/2;
    } else if (self.autoScaleYAxis == YES) {
        positionOnYAxis = ((self.frame.size.height - padding/2) - ((dotValue - self.minValue) / ((self.maxValue - self.minValue) / (self.frame.size.height - padding)))) + self.XAxisLabelYOffset/2;
    } else {
        positionOnYAxis = ((self.frame.size.height) - dotValue);
    }
    
    positionOnYAxis -= self.XAxisLabelYOffset;
    
    return positionOnYAxis;
}

#pragma mark - Customization Methods

- (void)setColorTouchInputLine:(UIColor *)colorTouchInputLine {
    _colorTouchInputLine = colorTouchInputLine;
}

#pragma mark - Other Methods

- (void)printDeprecationAndUnavailableWarningForOldMethod:(NSString *)oldMethod {
    NSLog(@"[BEMSimpleLineGraph] UNAVAILABLE, DEPRECATION ERROR. The delegate method, %@, is both deprecated and unavailable. It is now a data source method. You must implement this method from BEMSimpleLineGraphDataSource. Update your delegate method as soon as possible. One of two things will now happen: A) an exception will be thrown, or B) the graph will not load.", oldMethod);
}

- (void)printDeprecationWarningForOldMethod:(NSString *)oldMethod andReplacementMethod:(NSString *)replacementMethod {
    NSLog(@"[BEMSimpleLineGraph] DEPRECATION WARNING. The delegate method, %@, is deprecated and will become unavailable in a future version. Use %@ instead. Update your delegate method as soon as possible. An exception will be thrown in a future version.", oldMethod, replacementMethod);
}

@end

