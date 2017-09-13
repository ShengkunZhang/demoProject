//
//  ViewController.m
//  CocoaAsyncSocketServerDemo
//
//  Created by zsk on 2017/8/28.
//  Copyright © 2017年 zsk. All rights reserved.
//

#import "ViewController.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

@interface ViewController ()<GCDAsyncSocketDelegate>

@property (weak, nonatomic) IBOutlet UITextField *portF;
@property (weak, nonatomic) IBOutlet UITextField *messageTF;
@property (weak, nonatomic) IBOutlet UITextView *showContentMessageTV;

//服务器socket（开放端口，监听客户端socket的链接）
@property (strong, nonatomic) GCDAsyncSocket *serverSocket;

//保护客户端socket
@property (strong, nonatomic) GCDAsyncSocket *clientSocket;

@property (assign, nonatomic) NSInteger count;
@property (strong, nonatomic) NSTimer *timer;

@end

NSInteger testTag = 8888;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.count = 0;
    // 1、初始化服务器socket，在主线程力回调
    self.serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
}

//开始监听
- (IBAction)startReceive:(id)sender {
    //2、开放哪一个端口
    NSError *error = nil;
    BOOL result = [self.serverSocket acceptOnPort:self.portF.text.integerValue error:&error];
    if (result && error == nil) {
        //开放成功
        [self showMessageWithStr:@"开放成功"];
    }
}

//发送消息
- (IBAction)sendMessage:(id)sender {
    NSData *data = [self.messageTF.text dataUsingEncoding:NSUTF8StringEncoding];
    //withTimeout -1:无穷大，一直等
    //tag:消息标记
    [self.clientSocket writeData:data withTimeout:-1 tag:testTag];
}

// 循环发送信息
- (IBAction)sendManyMessage:(id)sender {
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(sendClick) userInfo:nil repeats:YES];
    } else {
        [self.timer invalidate];
        self.timer = nil;
        self.count = 0;
    }
}

- (void)sendClick {
    self.count ++;
    NSString *str = [NSString stringWithFormat:@"第%ld条信息", self.count];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [self.clientSocket writeData:data withTimeout:-1 tag:testTag];
}

// 展示信息
- (void)showMessageWithStr:(NSString *)str{
    self.showContentMessageTV.text = [self.showContentMessageTV.text stringByAppendingFormat:@"%@\n",str];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)dealloc {
    // 关闭连接
    [self.serverSocket disconnect];
}

#pragma mark - 服务器socket Delegate
// 收到客户端连接请求
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    //保存客户端的socket
    self.clientSocket = newSocket;
    [self showMessageWithStr:@"链接成功"];
    [self showMessageWithStr:[NSString stringWithFormat:@"客户端地址：%@ -端口： %d", newSocket.connectedHost, newSocket.connectedPort]];
    [self.clientSocket readDataWithTimeout:-1 tag:testTag];
}

//收到消息
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self showMessageWithStr:text];
    [self.clientSocket readDataWithTimeout:-1 tag:tag];
    NSLog(@"%@, tag>%ld", text, tag);
}

// 断开连接成功
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    [self showMessageWithStr:@"client断开链接"];
    [self.serverSocket readDataWithTimeout:-1 tag:testTag];
    NSLog(@"%@", err);
}

@end
