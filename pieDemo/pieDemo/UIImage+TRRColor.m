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

#import "UIImage+TRRColor.h"

@implementation UIImage (TRRColor)

+ (UIImage*)createImageWithColor:(UIColor*)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
