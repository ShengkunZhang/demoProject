//
//  DeviceInfo.h
//  JavaScriptCoreDemo
//
//  Created by zsk on 2017/9/9.
//  Copyright © 2017年 zsk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@class DeviceInfo;
// 遵循JSExport协议，指定暴露给js环境的方法和属性
@protocol DeviceInfoJSExport <JSExport>

/* 这些对js暴露的属性，不需要重写set和get方法，js中就能直接做set和get
 - (void)setModel:(NSString *)model;
 - (NSString *)model;
 */

@property NSString *model;
@property NSString *initialOS;
@property NSString *latestOS;
@property NSString *imageURL;
// 暴露给js用的初始化的方法
- (DeviceInfo *)initializeDevice:(NSString *)model;

// 下面是调用方式的方式和技巧
//- (DeviceInfo *)initializeDevice:(NSString *)model;
//JSExportAs(initializeDevice,
//- (DeviceInfo *)initializeDevice:(NSString *)model
//);
// 上面的两个定义方法在js中的调用方式一致均为：var deviceInfo = DeviceInfo.initializeDevice(model);

/*
- (DeviceInfo *)initializeDeviceModel:(NSString *)model initialOS:(NSString *)initialOS latestOS:(NSString *)latestOS imageURL:(NSString *)imageURL;
//这个方法在js中的使用为: var deviceInfo = DeviceInfo.initializeDeviceModelInitialOSLatestOSImageURL(model, initialOS, latestOS, imageURL);
 //即initializeDeviceModel + initialOS + latestOS + imageURL, 的拼接然后后三个首字母大写
 //所以这个方法可以这么定义
JSExportAs(initializeDeviceInfo,
- (DeviceInfo *)initializeDeviceModel:(NSString *)model initialOS:(NSString *)initialOS latestOS:(NSString *)latestOS imageURL:(NSString *)imageURL
);
 //调用方式为: var deviceInfo = DeviceInfo.initializeDeviceInfo(model, initialOS, latestOS, imageURL);
 // 注意，写的方法都要去实现
 */

@end

@interface DeviceInfo : NSObject <DeviceInfoJSExport>
- (NSString *)concatOS;
@end
