//
//  SimpleViewController.m
//  JavaScriptCoreDemo
//
//  Created by zsk on 2017/9/8.
//  Copyright © 2017年 zsk. All rights reserved.
//

#import "SimpleViewController.h"
// 导入文件
#import <JavaScriptCore/JavaScriptCore.h>

@interface SimpleViewController ()

@property (strong, nonatomic) JSContext *jsContext;
// 定义一个block 返回值为void即无，block调用名为luckyNumbersHandler，传入参数为数组NSArray
@property (strong, nonatomic) void (^luckyNumbersHandler)(NSArray *);
@property (strong, nonatomic) void (^consoleLog)(NSString *);

@property (strong, nonatomic) NSArray *guessedNumbers;

@end

@implementation SimpleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidReceiveLuckyNumbersNotification:) name:@"didReceiveRandomNumbers" object:nil];
    
    // 自定义block的实现
    self.luckyNumbersHandler = ^(NSArray *arr) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveRandomNumbers" object:arr];
    };
    
    self.consoleLog = ^(NSString *str) {
        NSLog(@"自定义函数的调用>>consoleLog>>%@", str);
    };
    
    self.guessedNumbers = @[@5, @37, @22, @18, @9, @42];
    
    [self initializeJS];
    [self helloWorld];
    [self getFullName];
    [self testException];
    [self jsCallObjective];
}

- (JSContext *)jsContext {
    if (_jsContext == nil) {
        _jsContext = [[JSContext alloc] init];
    }
    return _jsContext;
}

- (void)initializeJS {
    // 添加异常处理事件，处理js中的异常事件
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        NSLog(@"js异常回调>>exceptionHandler:%@", exception.toString);
    };
    
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
    
    // 转换block为js可以调用的函数
    id consoleLogObject = self.consoleLog;
    // 把这个block与js函数consoleLog绑定
    [self.jsContext setObject:consoleLogObject forKeyedSubscript:@"consoleLog"];
    // 把这个js函数在执行起来
    [self.jsContext evaluateScript:@"consoleLog"];
}

- (void)helloWorld {
    // 获得js文件的helloWorld属性的值
    JSValue *variableHelloWorld = [self.jsContext objectForKeyedSubscript:@"helloWorld"];
    if (variableHelloWorld) {
        NSLog(@"调用js的属性并输出属性值>>%@", variableHelloWorld.toString);
    }
}

- (void)getFullName {
    NSString *firstName = @"Mickey";
    NSString *secondName = @"Mouse";
    // 这次获得的是函数
    JSValue *functionFullname = [self.jsContext objectForKeyedSubscript:@"getFullname"];
    if (functionFullname) {
        // 函数这样调用, 如果这个函数没有参数，则传递nil
        JSValue *fullname = [functionFullname callWithArguments:@[firstName, secondName]];
        NSLog(@"调用js的函数并输出函数返回值>>%@", fullname.toString);
    }
}

- (void)testException {
    /* 故意执行错误函数以捕获异常
     // jssource.js中这句不注释就会出现异常，因为没有average方法
     var average = Math.average(values);
     */
    NSArray *arr = @[@10, @(-5), @22, @14, @(-35), @101, @(-55), @16, @14];
    JSValue *functionMaxMinAverage = [self.jsContext objectForKeyedSubscript:@"maxMinAverage"];
    if (functionMaxMinAverage) {
        JSValue *results = [functionMaxMinAverage callWithArguments:@[arr]];
        if (results) {
            NSDictionary *resultsDict = results.toDictionary;
            if (resultsDict) {
                NSLog(@"调用js的函数并输出函数返回值>>%@", resultsDict);
            }
        }
    }
}

- (void)jsCallObjective {
    // 把一个block函数搞成js可以调用的接口
    id luckyNumberObject = self.luckyNumbersHandler;
    [self.jsContext setObject:luckyNumberObject forKeyedSubscript:@"handleLuckyNumbers"];
    [self.jsContext evaluateScript:@"handleLuckyNumbers"];
    
    // 调用js中generateLuckyNumbers函数， 这个函数会执行我们自己定义的函数
    JSValue *functionGenerateLuckyNumbers = [self.jsContext objectForKeyedSubscript:@"generateLuckyNumbers"];
    [functionGenerateLuckyNumbers callWithArguments:nil];
}

// 通知函数
- (void)handleDidReceiveLuckyNumbersNotification:(NSNotification *)noti {
    NSArray *luckyNumbers = (NSArray *)noti.object;
    if (luckyNumbers) {
        NSLog(@"Lucky numbers:%@, Your guess:%@", luckyNumbers, self.guessedNumbers);
        NSInteger correctGuesses = 0;
        for (NSNumber *number in luckyNumbers) {
            for (NSNumber *number1 in self.guessedNumbers) {
                if (number == number1) {
                    NSLog(@"You guessed correctly: %@", number);
                    correctGuesses +=1;
                    break;
                }
            }
        }
        NSLog(@"Total correct guesses: %ld", correctGuesses);
        if (correctGuesses == 6) {
            NSLog(@"You are the big winner!!!");
        }
    }
}

@end
