//
//  ViewController.m
//  FBSocketRocketClientDemo
//
//  Created by zsk on 2017/9/5.
//  Copyright © 2017年 zsk. All rights reserved.
//

#import "ViewController.h"
#import <SocketRocket/SRWebSocket.h>

@interface ViewController ()<SRWebSocketDelegate>

@property (weak, nonatomic) IBOutlet UITextField *addressTF;
@property (weak, nonatomic) IBOutlet UITextField *portTF;
@property (weak, nonatomic) IBOutlet UITextField *messageTF;
@property (weak, nonatomic) IBOutlet UITextView *showMessageTF;
@property (weak, nonatomic) IBOutlet UILabel *keepLabel;
//客户端socket
@property (strong, nonatomic) SRWebSocket *clinetSocket;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

//开始连接
- (IBAction)connectAction:(id)sender {
    // URL: wss://echo.websocket.org:443, 可以后缀端口号
    //1、初始化
    self.clinetSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:self.addressTF.text]];
    self.clinetSocket.delegate = self;
    //2、连接服务器
    [self.clinetSocket open];
}

- (IBAction)disconnectAction:(id)sender {
    // 关闭连接
    [self.clinetSocket close];
}

//发送消息
- (IBAction)sendMessageAction:(id)sender {
    [self.clinetSocket send:self.messageTF.text];
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
    [self.clinetSocket close];
}

#pragma mark - delegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"%@", webSocket.url);
    [self showMessageWithStr:@"链接成功"];
    //[self showMessageWithStr:[NSString stringWithFormat:@"服务器IP ： %@ -端口： %d", host, port]];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    if ([message isKindOfClass:[NSString class]]) {
        [self showMessageWithStr:message];
    } else if ([message isKindOfClass:[NSData class]]) {
        NSString *text = [[NSString alloc] initWithData:message encoding:NSUTF8StringEncoding];
        [self showMessageWithStr:text];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
    [self showMessageWithStr:@"链接出错"];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    [self showMessageWithStr:@"断开链接成功"];
    NSLog(@"reason: %@, code: %ld", reason, code);
}


@end
