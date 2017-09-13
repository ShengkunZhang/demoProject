//
//  ViewController.m
//  CocoaAsyncSocketClientDemo
//
//  Created by zsk on 2017/8/28.
//  Copyright © 2017年 zsk. All rights reserved.
//

#import "ViewController.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

@interface ViewController ()<GCDAsyncSocketDelegate>

@property (weak, nonatomic) IBOutlet UITextField *addressTF;
@property (weak, nonatomic) IBOutlet UITextField *portTF;
@property (weak, nonatomic) IBOutlet UITextField *messageTF;
@property (weak, nonatomic) IBOutlet UITextView *showMessageTF;
@property (weak, nonatomic) IBOutlet UILabel *keepLabel;
//客户端socket
@property (strong, nonatomic) GCDAsyncSocket *clinetSocket;

@end

NSInteger testTag = 10000;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //1、初始化
    self.clinetSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
}

//开始连接
- (IBAction)connectAction:(id)sender {
    //2、连接服务器
    [self.clinetSocket connectToHost:self.addressTF.text onPort:self.portTF.text.integerValue withTimeout:-1 error:nil];
}

- (IBAction)disconnectAction:(id)sender {
    // 关闭连接
    [self.clinetSocket disconnect];
}

//发送消息
- (IBAction)sendMessageAction:(id)sender {
    NSData *data = [self.messageTF.text dataUsingEncoding:NSUTF8StringEncoding];
    //withTimeout -1 :无穷大
    //tag： 消息标记
    [self.clinetSocket writeData:data withTimeout:-1 tag:testTag];
}

// 展示信息
- (void)showMessageWithStr:(NSString *)str{
    self.showMessageTF.text = [self.showMessageTF.text stringByAppendingFormat:@"%@\n", str];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)dealloc {
    // 关闭连接
    [self.clinetSocket disconnect];
}

#pragma mark - GCDAsynSocket Delegate
// 连接服务器成功
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    [self showMessageWithStr:@"链接成功"];
    [self showMessageWithStr:[NSString stringWithFormat:@"服务器IP ： %@ -端口： %d", host, port]];
    // 确定这个客户端的tag
    [self.clinetSocket readDataWithTimeout:-1 tag:testTag];
}

// 断开连接成功
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    if (err) {
        NSLog(@"%@", err);
        [self showMessageWithStr:@"链接出错"];
    } else {
        [self showMessageWithStr:@"断开链接成功"];
    }
}

//收到消息
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@, tag>%ld", text, tag);
    if (tag == testTag) {
        self.keepLabel.text = text;
    } else {
        [self showMessageWithStr:text];
    }
    [self.clinetSocket readDataWithTimeout:-1 tag:tag];
}

@end
