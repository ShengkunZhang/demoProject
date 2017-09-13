//
//  MarkdownViewController.m
//  JavaScriptCoreDemo
//
//  Created by zsk on 2017/9/8.
//  Copyright © 2017年 zsk. All rights reserved.
//

#import "MarkdownViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface MarkdownViewController ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) JSContext *jsContext;
@property (strong, nonatomic) void (^consoleLog)(NSString *);
@property (strong, nonatomic) void (^markdownToHTMLHandler)(NSString *);

@end

@implementation MarkdownViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"markdownVC";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMarkdownToHTMLNotification:) name:@"markdownToHTMLNotification" object:nil];
    
    // 自定义block的实现
    self.markdownToHTMLHandler = ^(NSString *str) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"markdownToHTMLNotification" object:str];
    };
    
    self.consoleLog = ^(NSString *str) {
        NSLog(@"自定义函数的调用>>consoleLog>>%@", str);
    };
    
    [self initializeJS];
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
    NSString *showdownPath = [[NSBundle mainBundle] pathForResource:@"showdown.min" ofType:@"js"];
    if (jsSourcePath && showdownPath) {
        @try {
            // 转化为字符
            NSString *jsSourceContents = [NSString stringWithContentsOfFile:jsSourcePath encoding:NSUTF8StringEncoding error:nil];
            // 执行js字符
            [self.jsContext evaluateScript:jsSourceContents];
            
            // 加入Markdown to html 的js文件
            NSString *showdownContents = [NSString stringWithContentsOfFile:showdownPath encoding:NSUTF8StringEncoding error:nil];
            // NSString *snowdownScript = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"https://cdn.rawgit.com/showdownjs/showdown/1.7.4/dist/showdown.min.js"] encoding:NSUTF8StringEncoding error:nil];
            [self.jsContext evaluateScript:showdownContents];
        } @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
    }
    
    // 转换block为js可以调用的函数
    id consoleLogObject = self.consoleLog;
    // 把这个block与js函数consoleLog绑定
    [self.jsContext setObject:consoleLogObject forKeyedSubscript:@"consoleLog"];
    // 把这个js函数在加进去
    [self.jsContext evaluateScript:@"consoleLog"];
    
    // 转换block为js可以调用的函数
    id htmlResultsHandler = self.markdownToHTMLHandler;
    [self.jsContext setObject:htmlResultsHandler forKeyedSubscript:@"handleConvertedMarkdown"];
    [self.jsContext evaluateScript:@"handleConvertedMarkdown"];
}

- (void)convertMarkdownToHTML {
    // 调用js的函数处理输入的内容
    JSValue *functionConvertMarkdownToHTML = [self.jsContext objectForKeyedSubscript:@"convertMarkdownToHTML"];
    if (functionConvertMarkdownToHTML) {
        [functionConvertMarkdownToHTML callWithArguments:@[self.textView.text]];
    }
}

- (void)handleMarkdownToHTMLNotification:(NSNotification *)noti {
    NSString *html = (NSString *)noti.object;
    if (html) {
        NSString *newContent = [NSString stringWithFormat:@"<html><head><style>body { background-color: #3498db; color: #ffffff; } </style></head><body>%@</body></html>", html];
        NSURL *baseURL = [[NSBundle mainBundle] resourceURL];
        [self.webView loadHTMLString:newContent baseURL:baseURL];
    }
}

#pragma mark - TextView
- (void)textViewDidChange:(UITextView *)textView {
    [self convertMarkdownToHTML];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
}

//- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
//    return YES;
//}
//
//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    return YES;
//}

@end
