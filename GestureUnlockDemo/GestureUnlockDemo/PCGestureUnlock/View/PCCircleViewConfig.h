//
//  AppDelegate.m
//  GestureUnlockDemo
//
//  Created by zsk on 2017/10/21.
//  Copyright © 2017年 zsk. All rights reserved.
//

#import <Foundation/Foundation.h>

#define rgba(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define kScreenW [UIScreen mainScreen].bounds.size.width
#define kScreenH [UIScreen mainScreen].bounds.size.height

/**
 *  单个圆背景色
 */
#define CircleBackgroundColor [UIColor clearColor]

/**
 *  解锁背景色
 */
#define CircleViewBackgroundColor rgba(13,52,89,1)

/**
 *  单个圆的半径
 */
#define CircleRadius 30.0f

/**
 *  单个圆的圆心
 */
#define CircleCenter CGPointMake(CircleRadius, CircleRadius)

/**
 *  整个解锁View居中时，距离屏幕左边和右边的距离
 */
#define CircleViewEdgeMargin 30.0f

/**
 *  整个解锁View的Center.y值 在当前屏幕的3/5位置
 */
#define CircleViewCenterY kScreenH * 3/5

/**
 *  最终的手势密码存储key
 */
static NSString *gestureFinalSaveKey = @"gestureFinalSaveKey";

/**
 *  第一个手势密码存储key
 */
static NSString *gestureOneSaveKey = @"gestureOneSaveKey";

/**
 *  绘制解锁界面准备好时，提示文字
 */
static NSString *gestureTextBeforeSet = @"绘制解锁图案";

/**
 *  设置时，连线个数少，提示文字
 */
static NSString *gestureTextConnectLess = @"最少连接4个点，请重新输入";

/**
 *  确认图案，提示再次绘制
 */
static NSString *gestureTextDrawAgain = @"再次绘制解锁图案";

/**
 *  再次绘制不一致，提示文字
 */
static NSString *gestureTextDrawAgainError = @"与上次绘制不一致，请重新绘制";

/**
 *  设置成功
 */
static NSString *gestureTextSetSuccess = @"设置成功";

/**
 *  请输入原手势密码
 */
static NSString *gestureTextOldGesture = @"请输入原手势密码";

/**
 *  密码错误
 */
static NSString *gestureTextGestureVerifyError = @"密码错误";

@interface PCCircleViewConfig : NSObject

/**
 *  偏好设置：存字符串（手势密码）
 *
 *  @param gesture 字符串对象
 *  @param key     存储key
 */
+ (void)saveGesture:(NSString *)gesture Key:(NSString *)key;

/**
 *  偏好设置：取字符串手势密码
 *
 *  @param key key
 *
 *  @return 字符串对象
 */
+ (NSString *)getGestureWithKey:(NSString *)key;

@end
