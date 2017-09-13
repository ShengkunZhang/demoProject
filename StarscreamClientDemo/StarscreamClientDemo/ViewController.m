//
//  ViewController.m
//  StarscreamClientDemo
//
//  Created by zsk on 2017/9/6.
//  Copyright © 2017年 zsk. All rights reserved.
//

#import "ViewController.h"
#import "StarscreamClientDemo-Bridging-Header.h"
@import Starscream;

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *addressTF;
@property (weak, nonatomic) IBOutlet UITextField *portTF;
@property (weak, nonatomic) IBOutlet UITextField *messageTF;
@property (weak, nonatomic) IBOutlet UITextView *showMessageTF;
@property (weak, nonatomic) IBOutlet UILabel *keepLabel;
//客户端socket
@property (strong, nonatomic) WebSocket *clinetSocket;

@end

@implementation ViewController

//开始连接
- (IBAction)connectAction:(id)sender {
    // URL: wss://echo.websocket.org:443, 可以后缀端口号
    //1、初始化
    self.clinetSocket = [[WebSocket alloc] initWithUrl:[NSURL URLWithString:self.addressTF.text] protocols:@[]];
    //2、连接服务器
    [self.clinetSocket connect];
    
    self.clinetSocket.onConnect = ^{
        NSLog(@"链接成功");
    };
    
    self.clinetSocket.onDisconnect = ^(NSError * err) {
        NSLog(@"失去链接, err: %@", err);
    };
    
    self.clinetSocket.onText = ^(NSString * str) {
        NSLog(@"收到信息: %@", str);
    };
}

- (IBAction)disconnectAction:(id)sender {
    // 关闭连接
    
}

//发送消息
- (IBAction)sendMessageAction:(id)sender {
    [self.clinetSocket writeWithString:self.messageTF.text completion:^{
        NSLog(@"发送成功");
    }];
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
//    [self.clinetSocket disconnect];
}

@end
