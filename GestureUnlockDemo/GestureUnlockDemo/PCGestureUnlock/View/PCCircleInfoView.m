//
//  AppDelegate.m
//  GestureUnlockDemo
//
//  Created by zsk on 2017/10/21.
//  Copyright © 2017年 zsk. All rights reserved.
//

#import "PCCircleInfoView.h"
#import "PCCircle.h"

@interface PCCircleInfoView()

@end

@implementation PCCircleInfoView

- (instancetype)init
{
    if (self = [super init]) {
        // 解锁视图
        [self lockViewPrepare];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        // 解锁视图
        [self lockViewPrepare];
    }
    return self;
}

- (CGFloat)CircleInfoRadius {
    if (_CircleInfoRadius == 0) {
        _CircleInfoRadius = 5;
    }
    return _CircleInfoRadius;
}

/*
 *  解锁视图
 */
-(void)lockViewPrepare{
    self.backgroundColor = [UIColor clearColor];
    for (NSUInteger i=0; i<9; i++) {
        PCCircle *circle = [[PCCircle alloc] init];
        circle.type = CircleTypeInfo;
        [self addSubview:circle];
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat itemViewWH = self.CircleInfoRadius * 2;
    CGFloat marginValue = (self.frame.size.width - 3 * itemViewWH) / 3.0f;
    [self.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        NSUInteger row = idx % 3;
        NSUInteger col = idx / 3;
        CGFloat x = marginValue * row + row * itemViewWH + marginValue/2;
        CGFloat y = marginValue * col + col * itemViewWH + marginValue/2;
        CGRect frame = CGRectMake(x, y, itemViewWH, itemViewWH);
        // 设置tag -> 密码记录的单元
        subview.tag = idx + 1;
        subview.frame = frame;
    }];
}

@end

