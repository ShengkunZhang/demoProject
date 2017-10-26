//
//  AppDelegate.m
//  GestureUnlockDemo
//
//  Created by zsk on 2017/10/21.
//  Copyright © 2017年 zsk. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  单个圆的各种状态
 */
typedef enum{
    CircleStateNormal = 1,
    CircleStateSelected,
    CircleStateError,
    CircleStateLastOneSelected,
    CircleStateLastOneError
}CircleState;

/**
 *  单个圆的用途类型
 */
typedef enum
{
    CircleTypeInfo = 1,
    CircleTypeGesture
}CircleType;

@interface PCCircle : UIView

/**
 *  所处的状态
 */
@property (nonatomic, assign) CircleState state;

/**
 *  类型
 */
@property (nonatomic, assign) CircleType type;

/**
 *  是否有箭头 default is YES
 */
@property (nonatomic, assign) BOOL arrow;

/** 角度 */
@property (nonatomic,assign) CGFloat angle;

/**
 *  三角形边长
 */
@property (nonatomic,assign) CGFloat kTrangleLength;

/**
 *  空心圆圆环宽度
 */
@property (nonatomic,assign) CGFloat CircleEdgeWidth;

/**
 *  内部实心圆占空心圆的比例系数
 */
@property (nonatomic,assign) CGFloat CircleRadio;

/**
 *  普通状态下外空心圆颜色
 */
@property (nonatomic,strong) UIColor *CircleStateNormalOutsideColor;

/**
 *  选中状态下外空心圆颜色
 */
@property (nonatomic,strong) UIColor *CircleStateSelectedOutsideColor;

/**
 *  错误状态下外空心圆颜色
 */
@property (nonatomic,strong) UIColor *CircleStateErrorOutsideColor;

/**
 *  普通状态下内实心圆颜色
 */
@property (nonatomic,strong) UIColor *CircleStateNormalInsideColor;

/**
 *  选中状态下内实心圆颜色
 */
@property (nonatomic,strong) UIColor *CircleStateSelectedInsideColor;

/**
 *  错误状态内实心圆颜色
 */
@property (nonatomic,strong) UIColor *CircleStateErrorInsideColor;


/**
 *  普通状态下三角形颜色
 */
@property (nonatomic,strong) UIColor *CircleStateNormalTrangleColor;

/**
 *  选中状态下三角形颜色
 */
@property (nonatomic,strong) UIColor *CircleStateSelectedTrangleColor;

/**
 *  错误状态三角形颜色
 */
@property (nonatomic,strong) UIColor *CircleStateErrorTrangleColor;

@end
