//
//  DevicesViewController.m
//  JavaScriptCoreDemo
//
//  Created by zsk on 2017/9/8.
//  Copyright © 2017年 zsk. All rights reserved.
//

#import "DevicesViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "DeviceInfo.h"

@interface DevicesViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) JSContext *jsContext;
@property (strong, nonatomic) NSMutableArray *deviceInfo;

//@property (strong, nonatomic) void (^consoleLog)(NSString *);

@end

@implementation DevicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设备列表VC";
    
    //self.consoleLog = ^(NSString *str) {
    //    NSLog(@"自定义函数的调用>>consoleLog>>%@", str);
    //};
    
    [self initializeJS];
    [self parseDeviceData];
}

- (JSContext *)jsContext {
    if (_jsContext == nil) {
        _jsContext = [[JSContext alloc] init];
    }
    return _jsContext;
}

- (NSMutableArray *)deviceInfo {
    if (_deviceInfo == nil) {
        _deviceInfo = [NSMutableArray array];
    }
    return _deviceInfo;
}

- (void)initializeJS {
    // 添加异常处理事件，处理js中的异常事件
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        NSLog(@"js异常回调>>exceptionHandler:%@", exception.toString);
    };
    
    // 找到资源
    NSString *paPaparsePath = [[NSBundle mainBundle] pathForResource:@"papaparse.min" ofType:@"js"];
    if (paPaparsePath) {
        @try {
            // 转化为字符
            NSString *paPaparseContents = [NSString stringWithContentsOfFile:paPaparsePath encoding:NSUTF8StringEncoding error:nil];
            // 执行js字符
            [self.jsContext evaluateScript:paPaparseContents];
        } @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
    }
    
    // 找到资源
    NSString *jsSourcePath = [[NSBundle mainBundle] pathForResource:@"jssource" ofType:@"js"];
    if (jsSourcePath) {
        @try {
            // 转化为字符
            NSString *jsSourceContents = [NSString stringWithContentsOfFile:jsSourcePath encoding:NSUTF8StringEncoding error:nil];
            // 执行js字符
            [self.jsContext evaluateScript:jsSourceContents];
        } @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
    }
    
    //// 转换block为js可以调用的函数
    //id consoleLogObject = self.consoleLog;
    //// 把这个block与js函数consoleLog绑定
    //[self.jsContext setObject:consoleLogObject forKeyedSubscript:@"consoleLog"];
    //// 把这个js函数在加进去
    //[self.jsContext evaluateScript:@"consoleLog"];
    
    // 把DeviceInfo对象传递到js环境中
    [self.jsContext setObject:[[DeviceInfo alloc] init] forKeyedSubscript:@"DeviceInfo"];
}

- (void)parseDeviceData {
    // 传递内容到js中，并调用相关方法以及得到处理后的数据
    NSString *path = [[NSBundle mainBundle] pathForResource:@"iPhone_List" ofType:@"csv"];
    if (path) {
        NSString *contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        JSValue *functionParseiPhoneList = [self.jsContext objectForKeyedSubscript:@"parseiPhoneList"];
        if (functionParseiPhoneList) {
            JSValue *parsedDeviceData = [functionParseiPhoneList callWithArguments:@[contents]];
            if (parsedDeviceData) {
                self.deviceInfo = [NSMutableArray arrayWithArray:parsedDeviceData.toArray];
                [self.tableView reloadData];
            }
        }
    }
}

#pragma mark - tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deviceInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    UITableViewCell *Cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    DeviceInfo *info = self.deviceInfo[indexPath.row];
    Cell.textLabel.text = info.model;
    Cell.detailTextLabel.text = [info concatOS];
    return Cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

@end
