//
//  ViewController.m
//  jetfireClientDemo
//
//  Created by zsk on 2017/9/5.
//  Copyright © 2017年 zsk. All rights reserved.
//

#import "ViewController.h"
#import "JFRWebSocket/JFRWebSocket.h"

@interface ViewController ()<JFRWebSocketDelegate>

@property (weak, nonatomic) IBOutlet UITextField *addressTF;
@property (weak, nonatomic) IBOutlet UITextField *portTF;
@property (weak, nonatomic) IBOutlet UITextField *messageTF;
@property (weak, nonatomic) IBOutlet UITextView *showMessageTF;
@property (weak, nonatomic) IBOutlet UILabel *keepLabel;
//客户端socket
@property (strong, nonatomic) JFRWebSocket *clinetSocket;

@end

@implementation ViewController

//开始连接
- (IBAction)connectAction:(id)sender {
    // URL: wss://echo.websocket.org:443, 可以后缀端口号
    // URL: @"wss://streamer.cryptocompare.com" 连接失败，原因未知，貌似是因为服务器是用改的socket.io
    //1、初始化
    self.clinetSocket = [[JFRWebSocket alloc] initWithURL:[NSURL URLWithString:self.addressTF.text] protocols:@[]];
    self.clinetSocket.delegate = self;
    //2、连接服务器
    [self.clinetSocket connect];
}

- (IBAction)disconnectAction:(id)sender {
    // 关闭连接
    [self.clinetSocket disconnect];
}

//发送消息
- (IBAction)sendMessageAction:(id)sender {
    [self.clinetSocket writeString:self.messageTF.text];
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

#pragma mark - delegate
- (void)websocketDidConnect:(JFRWebSocket *)socket {
    [self showMessageWithStr:@"链接成功"];
}

- (void)websocketDidDisconnect:(JFRWebSocket *)socket error:(NSError *)error {
    NSLog(@"%@", error);
    if (error.code == 1000) {
        [self showMessageWithStr:@"断开链接成功"];
    } else {
        [self showMessageWithStr:@"链接失败"];
    }
}

- (void)websocket:(JFRWebSocket *)socket didReceiveMessage:(NSString *)string {
    [self showMessageWithStr:string];
}

- (void)websocket:(JFRWebSocket *)socket didReceiveData:(NSData *)data {
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self showMessageWithStr:text];
}

@end
