//
//  DeviceInfo.m
//  JavaScriptCoreDemo
//
//  Created by zsk on 2017/9/9.
//  Copyright © 2017年 zsk. All rights reserved.
//

#import "DeviceInfo.h"

@implementation DeviceInfo
@synthesize model = _model;
@synthesize initialOS = _initialOS;
@synthesize latestOS = _latestOS;
@synthesize imageURL = _imageURL;

- (instancetype)initWithModel:(NSString *)model {
    self = [super init];
    self.model = model;
    return self;
}

- (NSString *)concatOS {
    if (self.initialOS && self.latestOS) {
        return [NSString stringWithFormat:@"%@ - %@", self.initialOS, self.latestOS];
    }
    return @"";
}

// 初始化方法
- (DeviceInfo *)initializeDevice:(NSString *)model {
    DeviceInfo *deviceInfo = [[DeviceInfo alloc] initWithModel:model];
    return deviceInfo;
}

// 另一个初始化方法
- (DeviceInfo *)initializeDeviceModel:(NSString *)model initialOS:(NSString *)initialOS latestOS:(NSString *)latestOS imageURL:(NSString *)imageURL {
    DeviceInfo *deviceInfo = [[DeviceInfo alloc] initWithModel:model];
    deviceInfo.initialOS = initialOS;
    deviceInfo.latestOS = latestOS;
    deviceInfo.imageURL = imageURL;
    return deviceInfo;
}

@end
