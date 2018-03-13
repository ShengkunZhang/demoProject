//
//  ViewController.m
//  SocketIOClientDemo
//
//  Created by zsk on 2017/9/6.
//  Copyright © 2017年 zsk. All rights reserved.
//

#import "ViewController.h"
#import "SocketIOClientDemo-Bridging-Header.h"
@import SocketIO;

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *addressTF;
@property (weak, nonatomic) IBOutlet UITextField *portTF;
@property (weak, nonatomic) IBOutlet UITextField *messageTF;
@property (weak, nonatomic) IBOutlet UITextView *showMessageTF;
@property (weak, nonatomic) IBOutlet UILabel *keepLabel;
//客户端socket
@property (strong, nonatomic) SocketIOClient *clinetSocket;

@end

@implementation ViewController

//开始连接
- (IBAction)connectAction:(id)sender {
    // URL: wss://echo.websocket.org:443, 可以后缀端口号
    //1、初始化
    //SocketIOClient *clinetSocket = [[SocketIOClient alloc] initWithSocketURL:[NSURL URLWithString:self.addressTF.text] config:@{}];
    SocketIOClient *clinetSocket = [[SocketIOClient alloc] initWithSocketURL:[NSURL URLWithString:@"wss://streamer.cryptocompare.com"] config:@{}];
    //2、实现链接成功回调
    [clinetSocket on:@"connect" callback:^(NSArray * data, SocketAckEmitter * ack) {
        [self showMessageWithStr:@"Connect"];
    }];
//    //3、
//    [clinetSocket on:@"currentAmount" callback:^(NSArray * data, SocketAckEmitter * ack) {
//        double cur = [[data objectAtIndex:0] floatValue];
//        
//        [[clinetSocket emitWithAck:@"canUpdate" with:@[@(cur)]] timingOutAfter:0 callback:^(NSArray * data) {
//            [clinetSocket emit:@"update" with:@[@{@"amount": @(cur + 2.50)}]];
//        }];
//    }];
    
    self.clinetSocket = clinetSocket;
}

- (IBAction)disconnectAction:(id)sender {
    // 关闭连接
    [self.clinetSocket disconnect];
}

//发送消息
- (IBAction)sendMessageAction:(id)sender {
//    [self.clinetSocket writeString:self.messageTF.text];
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

@end
