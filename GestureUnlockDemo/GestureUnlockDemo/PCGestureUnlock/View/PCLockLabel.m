//
//  AppDelegate.m
//  GestureUnlockDemo
//
//  Created by zsk on 2017/10/21.
//  Copyright © 2017年 zsk. All rights reserved.
//

#import "PCLockLabel.h"
#import "CALayer+Anim.h"

@implementation PCLockLabel

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        //视图初始化
        [self viewPrepare];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if(self){
        //视图初始化
        [self viewPrepare];
    }
    return self;
}

- (UIColor *)textColorWarningState {
    if (_textColorWarningState == nil) {
        _textColorWarningState = [UIColor colorWithRed:254/255.0 green:82/255.0 blue:92/255.0 alpha:1];
    }
    return _textColorWarningState;
}

- (UIColor *)textColorNormalState {
    if (_textColorNormalState == nil) {
        _textColorNormalState = [UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1];
    }
    return _textColorNormalState;
}

/*
 *  视图初始化
 */
- (void)viewPrepare{
    [self setFont:[UIFont systemFontOfSize:14.0f]];
    [self setTextAlignment:NSTextAlignmentCenter];
}

/*
 *  普通提示信息
 */
- (void)showNormalMsg:(NSString *)msg{
    [self setText:msg];
    [self setTextColor:self.textColorNormalState];
}

/*
 *  警示信息
 */
- (void)showWarnMsg:(NSString *)msg{
    [self setText:msg];
    [self setTextColor:self.textColorWarningState];
}

/*
 *  警示信息(shake)
 */
- (void)showWarnMsgAndShake:(NSString *)msg{
    [self setText:msg];
    [self setTextColor:self.textColorWarningState];
    
    //添加一个shake动画
    [self.layer shake];
}

@end
