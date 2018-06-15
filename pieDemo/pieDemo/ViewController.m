//
//  ViewController.m
//  pieDemo
//
//  Created by zsk on 2018/2/7.
//  Copyright © 2018年 zsk. All rights reserved.
//

#import "ViewController.h"

#import "VBPieChart.h"
#import "UIColor+HexColor.h"
#import "VBPiePiece.h"

#import "BEMSimpleLineGraphView.h"

#import "UIImage+TRRColor.h"
#import "CollectionViewCell.h"


@interface ViewController () <BEMSimpleLineGraphDelegate, BEMSimpleLineGraphDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) VBPieChart *chart;
@property (nonatomic, strong) NSArray *chartValues;

@property (nonatomic, strong) BEMSimpleLineGraphView *myGraph;
@property (strong, nonatomic) NSMutableArray *arrayOfValues;
@property (strong, nonatomic) NSMutableArray *arrayOfOtherValues;
@property (strong, nonatomic) NSMutableArray *arrayOfDates;
@property (assign, nonatomic) CGFloat minValue;
@property (assign, nonatomic) CGFloat maxValue;

@property (strong, nonatomic) UICollectionView *collectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initCollectionView];
    [self initOtherUI];
}

//===============================UICollection====================================
- (void)initCollectionView {
    // 初始化CollectionView
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, width, height) collectionViewLayout:layout];
    [self.view addSubview:collectionView];
    
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.showsVerticalScrollIndicator = NO;
    
    //初始设置cell的大小和内边距
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(0, 8, 0, 8);
    //初始设置cell的大小和内边距
    layout.itemSize = CGSizeMake((width - 4 * 8)/3.0 - 2, 62);
    self.collectionView = collectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y <= 0) {
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
    }
}

//===============================初始化UI=========================================
- (void)initOtherUI {
    UIView *topView = [[UIView alloc] init];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    //CGFloat height = [UIScreen mainScreen].bounds.size.height;
    // 头部背景图
    UIImage *backImage = [UIImage imageNamed:@"Oval"];
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, backImage.size.height)];
    backImageView.image = backImage;
    [topView addSubview:backImageView];
    
    // 悬浮 + 高斯模糊 的背景图
    // 悬浮效果
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(8, 68, width - 8 * 2, 240)];
    backView.backgroundColor = [UIColor whiteColor];
    backView.layer.shadowOpacity = 0.3;
    backView.layer.shadowOffset = CGSizeMake(1, 1);
    backView.layer.shadowColor = [UIColor blackColor].CGColor;
    backView.layer.cornerRadius = 4;
    backView.alpha = 0.7;
    // 高斯模糊
    UIBlurEffect *beffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *graphView = [[UIVisualEffectView alloc] initWithEffect:beffect];
    graphView.frame = CGRectMake(8, 68, width - 8 * 2, 240);
    graphView.layer.cornerRadius = 4.0f;
    graphView.layer.masksToBounds = YES;
    // 先加入高斯模糊视图，然后在添加悬浮层
    [topView addSubview:graphView];
    [topView addSubview:backView];
    
    // 曲线
    [self initGraph];
    self.myGraph.frame = CGRectMake(0, 0, backView.frame.size.width, backView.frame.size.height * 3/4);
    // 刷新界面
    [self.myGraph reloadGraph];
    [backView addSubview:self.myGraph];
    
    // 不同分割的按钮， 按日，月，年等方式
    NSArray *stringArray = @[@"1D", @"1W", @"1M", @"3M", @"6M", @"1Y", @"ALL"];
    UIView *btnView = [[UIView alloc] initWithFrame:CGRectMake(0, backView.frame.size.height * 3/4 - 10, backView.frame.size.width, 30)];
    btnView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [backView addSubview:btnView];
    
    CGFloat btnWidth = 40;
    CGFloat btnheight = 25;
    CGFloat spaceWidth = (backView.frame.size.width - stringArray.count * btnWidth)/ (stringArray.count + 1.0);
    for (int i = 0; i < stringArray.count; i++) {
        // 循环加入视图中
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(spaceWidth * (i + 1) + btnWidth * i, 2.5, btnWidth, btnheight)];
        [btn setTitle:stringArray[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.tag = i + 10;
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 4.0;
        btn.layer.masksToBounds = YES;
        [btn setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:232.0/255.0 green:232.0/255.0 blue:232.0/255.0 alpha:1]] forState:UIControlStateSelected];
        [btn setTitleColor:[UIColor colorWithRed:33/255.0 green:209/255.0 blue:163/255.0 alpha:1] forState:UIControlStateSelected];
        [btnView addSubview:btn];
    }
    
    // 3个大的按钮
    UIView *thirdBtnView = [[UIView alloc] initWithFrame:CGRectMake(80, backView.frame.origin.y + backView.frame.size.height - 40/2, width - 80 * 2, 40)];
    thirdBtnView.backgroundColor = [UIColor colorWithRed:0/255.0 green:213.0/255.0 blue:150.0/255.0 alpha:1];
    thirdBtnView.layer.cornerRadius = 40/2;
    thirdBtnView.layer.borderColor = [UIColor colorWithRed:76/255.0 green:193.0/255.0 blue:252.0/255.0 alpha:1].CGColor;
    thirdBtnView.layer.borderWidth = 2;
    [topView addSubview:thirdBtnView];
    
    CGFloat chartWidth = 200;
    self.chart.frame = CGRectMake((width - chartWidth)/2.0, thirdBtnView.frame.size.height + thirdBtnView.frame.origin.y + 30, chartWidth, chartWidth);
    // 绘制饼图
    [topView addSubview:self.chart];
    // 赋值
    [self setChartsValue];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(8, self.chart.frame.size.height + self.chart.frame.origin.y + 15, width - 2 * 8, 0.5)];
    lineView.backgroundColor = [UIColor grayColor];
    [topView addSubview:lineView];
    
    topView.frame = CGRectMake(0, 0, width, lineView.frame.size.height + lineView.frame.origin.y);
    [self.collectionView addSubview:topView];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.headerReferenceSize = CGSizeMake(width, topView.frame.size.height + topView.frame.origin.y + 5);
}

- (void)btnClick:(UIButton *)btn {
    // 根据区分按钮的tag，进行事件的切换
    btn.selected = !btn.selected;
    for (int i = 0; i < 7; i++) {
        NSInteger tag = i + 10;
        UIButton *tempBtn = [self.view viewWithTag:tag];
        if (tag != btn.tag) {
            tempBtn.selected = NO;
        }
    }
    
    [self.arrayOfValues removeAllObjects];
    [self.arrayOfOtherValues removeAllObjects];
    if (btn.selected) {
        [self.arrayOfValues addObjectsFromArray:@[@(8000), @(8000), @(1000), @(1000), @(12000), @(3000), @(17000), @(8000), @(8782), @(4000), @(4000), @(16000), @(2000), @(12000), @(3000), @(17000), @(8000), @(8782)]];
        
        [self.arrayOfOtherValues addObjectsFromArray:@[@(1000), @(1000), @(16000), @(16000), @(5000), @(5000), @(10000), @(10000), @(8000), @(4000), @(4000), @(9000), @(9000), @(5000), @(5000), @(20000), @(20000), @(8000)]];
    } else {
        [self.arrayOfValues addObjectsFromArray:@[@(4000), @(4000), @(16000), @(2000), @(12000), @(3000), @(17000), @(8000), @(8782), @(4000), @(4000), @(16000), @(2000), @(12000), @(3000), @(17000), @(8000), @(8782)]];
        
        [self.arrayOfOtherValues addObjectsFromArray:@[@(4000), @(4000), @(9000), @(9000), @(5000), @(5000), @(20000), @(20000), @(8000), @(4000), @(4000), @(9000), @(9000), @(5000), @(5000), @(20000), @(20000), @(8000)]];
    }
    // 刷新界面
    [self.myGraph reloadGraph];
}

//===============================Graph==========================================
- (BEMSimpleLineGraphView *)myGraph {
    if (!_myGraph) {
        _myGraph = [[BEMSimpleLineGraphView alloc] init];
        _myGraph.delegate = self;
        _myGraph.dataSource = self;
    }
    return _myGraph;
}

- (void)setMyGraphAttribute:(BEMSimpleLineGraphView *)myGraph {
    // 折线图下半部分颜色的渐变效果设置
    //// Create a gradient to apply to the bottom portion of the graph
    //CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    //size_t num_locations = 2;
    //CGFloat locations[2] = { 0.0, 1.0 };
    //CGFloat components[8] = {
    //    1.0, 1.0, 1.0, 1.0,
    //    1.0, 1.0, 1.0, 0.0
    //};
    //
    //// Apply the gradient to the bottom portion of the graph
    //self.myGraph.gradientBottom = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
    // Dash the y reference lines
    // self.myGraph.lineDashPatternForReferenceYAxisLines = @[@(2),@(2)];
    
    // y轴标签内容显示的格式
    // self.myGraph.formatStringForValues = @"%.1f";
    
    // 线图的下半部分的设置
    // self.myGraph.alphaBottom = 1; // 不透明
    // self.myGraph.colorBottom = [UIColor whiteColor];
    
    // 折线的设置
    myGraph.colorLine = [UIColor colorWithRed:33/255.0 green:209/255.0 blue:163/255.0 alpha:1];
    myGraph.widthLine = 2;
    // 线的上半部分和下半部分 均透明，即无背景色
    myGraph.alphaTop = 0;
    myGraph.alphaBottom = 0;
    // 折线还是曲线
    myGraph.enableBezierCurve = YES;
    // 设置点的颜色
    myGraph.colorPoint = [UIColor colorWithRed:33/255.0 green:209/255.0 blue:163/255.0 alpha:1];
    // 开启点击屏幕显示折线点
    myGraph.enableTouchReport = YES;
    // 开启点击屏幕显示折线点的内容
    myGraph.enablePopUpReport = NO;
    // 是否显示y轴标签
    myGraph.enableYAxisLabel = NO;
    // 是否显示x轴标签
    myGraph.enableXAxisLabel = NO;
    // y轴是否自动缩放
    myGraph.autoScaleYAxis = YES;
    // 折线的每个折线的点是否显示
    myGraph.alwaysDisplayDots = NO;
    // 不显示x轴和y轴的刻度线, 以及最低的X轴线
    myGraph.enableReferenceXAxisLines = NO;
    myGraph.enableReferenceYAxisLines = NO;
    myGraph.enableReferenceAxisFrame = NO;
    
    // 设置动画效果类型
    myGraph.animationGraphStyle = BEMLineAnimationDraw;
    
    // y轴平均线的绘制设置
    myGraph.averageLine.enableAverageLine = NO;
    myGraph.averageLine.alpha = 0.6;
    myGraph.averageLine.color = [UIColor darkGrayColor];
    myGraph.averageLine.width = 2.5;
    myGraph.averageLine.dashPattern = @[@(2),@(2)];
    
    // 点击时出现的一条线的颜色
    myGraph.colorTouchInputLine = [UIColor blackColor];
    
    // [UIColor colorWithRed:33/255.0 green:209/255.0 blue:163/255.0 alpha:1];

    
    /*
     // Reload the graph
     [self.myGraph reloadGraph];
     
     // Retrieve current X-Axis values
     NSArray *arrayOfXLabels = [self.myGraph graphValuesForXAxis];
     // The returned NSArray contains an array of NSString objects
     
     // Retrieve the Data Points
     NSArray *arrayOfDataPoints = [self.myGraph graphValuesForDataPoints];
     // The returned NSArray contains an array of NSNumber objects (originally formatted as a float).
     */
}

- (void)initGraph {
    [self setMyGraphAttribute:self.myGraph];
    
    if (!self.arrayOfValues) self.arrayOfValues = [[NSMutableArray alloc] init];
    if (!self.arrayOfOtherValues) self.arrayOfOtherValues = [[NSMutableArray alloc] init];
    if (!self.arrayOfDates) self.arrayOfDates = [[NSMutableArray alloc] init];
    [self.arrayOfValues removeAllObjects];
    [self.arrayOfDates removeAllObjects];
    
    [self.arrayOfValues removeAllObjects];
    [self.arrayOfValues addObjectsFromArray:@[@(4000), @(4000), @(16000), @(2000), @(12000), @(3000), @(17000), @(8000), @(8782), @(4000), @(4000), @(16000), @(2000), @(12000), @(3000), @(17000), @(8000), @(8782)]];
    
    [self.arrayOfOtherValues addObjectsFromArray:@[@(4000), @(4000), @(9000), @(9000), @(5000), @(5000), @(20000), @(20000), @(8000), @(4000), @(4000), @(9000), @(9000), @(5000), @(5000), @(20000), @(20000), @(8000)]];
    // 初始化数据
    [self hydrateDatasetsWithArrayOfDates:self.arrayOfDates];
    
    // 根据真实数据计算最小值和最大值
    [self getMaxAndMinValue];
}

- (void)getMaxAndMinValue {
    // 如果只有一个数据源
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.arrayOfValues];
    // 还有一个的话
    [array addObjectsFromArray:self.arrayOfOtherValues];
    
    [array sortUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
        // 此处的规则含义为：若前一元素比后一元素小，则返回降序（即后一元素在前，为从大到小排列）
        // 排序结果为 5，4，3，2，1
        if ([obj1 floatValue] < [obj2 floatValue]) {
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
    }];
    
    // 最小值
    self.minValue = [array.lastObject doubleValue];
    // 最大值
    self.maxValue = [array.firstObject doubleValue];
}

- (NSString *)labelForDateAtIndex:(NSInteger)index {
    NSDate *date = self.arrayOfDates[index];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"MM/dd";
    NSString *label = [df stringFromDate:date];
    return label;
}

- (NSDate *)dateForGraphAfterDate:(NSDate *)date {
    NSTimeInterval secondsInTwentyFourHours = 24 * 60 * 60;
    NSDate *newDate = [date dateByAddingTimeInterval:secondsInTwentyFourHours];
    return newDate;
}

- (float)getRandomFloat {
    float i1 = (float)(arc4random() % 1000000) / 100 ;
    return i1;
}

// 初始化数据
- (void)hydrateDatasetsWithArrayOfDates:(NSMutableArray *)arrayOfDates {
    // 2018-2-24
    NSDate *baseDate = [NSDate dateWithTimeIntervalSince1970:1519401600];
    
    for (int i = 0; i < self.arrayOfValues.count; i++) {
        if (i == 0) {
            [arrayOfDates addObject:baseDate];
        } else {
            [arrayOfDates addObject:[self dateForGraphAfterDate:arrayOfDates[i-1]]];
        }
    }
}

// 几个点
- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return (int)[self.arrayOfValues count];
}

// 数据
- (NSArray *)lineGraphPointData:(BEMSimpleLineGraphView *)graph {
    return @[[self.arrayOfValues copy], [self.arrayOfOtherValues copy]];
}

// X轴某个位置的数据
- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
    NSString *label = [self labelForDateAtIndex:index];
    return [label stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
}

//// 默认y轴显示3个标签，这里可以设置让显示更多个
//- (NSInteger)numberOfYAxisLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
//    return 0;
//}

// 两个X轴标签之间有几个点
- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return 2;
}

// 在界面中点击了某处，或者手指在屏幕上滑动，都会触发这个方法
- (void)lineGraph:(BEMSimpleLineGraphView *)graph didTouchGraphWithClosestIndex:(NSInteger)index {
    NSString *string = [NSString stringWithFormat:@"%@", [self.arrayOfValues objectAtIndex:index]];
    NSString *string1 = [NSString stringWithFormat:@"%@", [self.arrayOfOtherValues objectAtIndex:index]];
    NSString *dateStrng = [NSString stringWithFormat:@"in %@", [self labelForDateAtIndex:index]];
    NSLog(@"%@, %@, %@", string, string1, dateStrng);
    
    // 实时改变饼图颜色
    [self setChartsValue];
}

// 最小值
- (CGFloat)minValueForLineGraph:(BEMSimpleLineGraphView *)graph {
    return self.minValue;
}

// 最大值
- (CGFloat)maxValueForLineGraph:(BEMSimpleLineGraphView *)graph {
    return self.maxValue;
}

// 点击显示的标签内容的后缀
- (NSString *)popUpSuffixForlineGraph:(BEMSimpleLineGraphView *)graph {
    return @" 元";
}


//=======================================pie=====================================
- (VBPieChart *)chart {
    if (!_chart) {
        _chart = [[VBPieChart alloc] init];
        _chart.startAngle = M_PI+M_PI_2;
        [_chart setHoleRadiusPrecent:0.2];
        // 默认不显示label, 如下设置则显示标签
        [_chart setLabelsPosition:VBLabelsPositionOutChart];
        // 关闭交互
        _chart.userInteractionEnabled = NO;
    }
    return _chart;
}

- (void)setChartsValue {
    NSArray *arr = @[@(arc4random() % 1000), @(arc4random() % 1000), @(arc4random() % 1000), @(arc4random() % 1000)];
    self.chartValues = @[
                         // Data can be passed after JSON Deserialization
                         @{@"name":@"BTC", @"value":arr[0], @"color":@"#dd191daa", @"strokeColor":@"#fff", @"labelColor": [UIColor blackColor]},
                         // chart can be with or without titles
                         @{@"name":@"EOS", @"value":arr[1], @"color":[UIColor colorWithHex:0x3f51b5aa], @"strokeColor":[UIColor whiteColor], @"labelColor": [UIColor blackColor]},
                         @{@"name":@"ETH", @"value":arr[2], @"color":[UIColor colorWithHex:0x5677fcaa], @"strokeColor":[UIColor whiteColor], @"labelColor": [UIColor blackColor]},
                         @{@"name":@"NAS", @"value":arr[3], @"color":[UIColor colorWithHex:0xb0bec5aa], @"strokeColor":[UIColor whiteColor], @"labelColor": [UIColor blackColor]},
                         ];
//    [_chart setChartValues:_chartValues animation:YES options:VBPieChartAnimationFanAll];
    [_chart setChartValues:_chartValues animation:NO];
    
    
    /*
     name: 就是label显示的文字
     value: 就是一个数值，根据总体的数值，以及这个数值，计算这块所占的比例
     color: 就是扇面的颜色
     strokeColor: 就是扇面的边框的颜色
     labelColor: 就是lable的字体颜色
     accent: 就是这个扇面是正常显示，还是显示脱离整个扇面的效果。bool值，no是正常，yes显示脱离效果
     <bug: 一个问题就是想显示脱离或者点击导致脱离时，label不随扇面移动>
     */
    
    /*
    UIColor *colorWithImagePattern = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern.jpg"]];
    UIColor *colorWithImagePattern2 = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern2.png"]];
    
    self.chartValues = @[
                         // Data can be passed after JSON Deserialization
                         @{@"name":@"first", @"value":@50, @"color":@"#dd191daa", @"strokeColor":@"#fff", @"labelColor": [UIColor blackColor]},
                         
                         // Chart can use patterns
                         @{@"name":@"sec", @"value":@20, @"color":colorWithImagePattern, @"strokeColor":@"#fff", @"labelColor": [UIColor blackColor]},
                         @{@"name":@"third", @"value":@40, @"color":colorWithImagePattern2, @"strokeColor":[UIColor whiteColor], @"labelColor": [UIColor blackColor]},
                         
                         // chart can be with or without titles
                         @{@"name":@"fourth", @"value":@70, @"color":[UIColor colorWithHex:0x3f51b5aa], @"strokeColor":[UIColor whiteColor], @"labelColor": [UIColor blackColor]},
                         @{@"value":@65, @"color":[UIColor colorWithHex:0x5677fcaa], @"strokeColor":[UIColor whiteColor]},
                         @{@"value":@23, @"color":[UIColor colorWithHex:0x2baf2baa], @"strokeColor":[UIColor whiteColor]},
                         @{@"value":@34, @"color":[UIColor colorWithHex:0xb0bec5aa], @"strokeColor":[UIColor whiteColor]},
                         @{@"name":@"stroke", @"value":@54, @"color":[UIColor colorWithHex:0xf57c00aa], @"strokeColor":[UIColor whiteColor], @"labelColor": [UIColor blackColor]}
                         ];
    [_chart setChartValues:_chartValues animation:YES options:VBPieChartAnimationFanAll];
    */
}


@end
