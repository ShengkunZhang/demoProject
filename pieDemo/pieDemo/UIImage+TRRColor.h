/*************************************************************************
 *
 * FThinking CONFIDENTIAL
 * ______________________
 *
 *  Copyright © 2017年 FThinking Technology Co., Ltd.
 *  All rights reserved.
 *
 * NOTICE:  All information contained herein is, and remains the property
 * of FThinking Technology (Beijing) Co., Ltd. and its suppliers,
 * if any.  The intellectual and technical concepts contained herein are
 * proprietary to FThinking Technology (Beijing) Co., Ltd. and its
 * suppliers and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from FThinking Technology (Beijing) Co., Ltd.
 **************************************************************************/

#import <UIKit/UIKit.h>

@interface UIImage (TRRColor)

/**
 *  颜色值转换为图片
 */
+ (UIImage*)createImageWithColor:(UIColor*)color;

@end
