//
//  AppDelegate.m
//  GestureUnlockDemo
//
//  Created by zsk on 2017/10/21.
//  Copyright © 2017年 zsk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCLockLabel : UILabel

/**
 *  普通状态下文字提示的颜色
 */
@property (nonatomic,strong) UIColor *textColorNormalState;

/**
 *  警告状态下文字提示的颜色
 */
@property (nonatomic,strong) UIColor *textColorWarningState;

/*
 *  普通提示信息
 */
- (void)showNormalMsg:(NSString *)msg;

/*
 *  警示信息
 */
- (void)showWarnMsg:(NSString *)msg;

/*
 *  警示信息(shake)
 */
- (void)showWarnMsgAndShake:(NSString *)msg;

@end
