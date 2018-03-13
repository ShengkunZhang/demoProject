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
    // URL: ws://echo.websocket.org:443, 可以后缀端口号
    // 链接: wss://streamer.cryptocompare.com
    // https://streamer.cryptocompare.com
    // 如果服务器端是用的socket.io 则客户端在连接的url后拼接'/socket.io/?EIO=4&transport=websocket'
    //1、初始化
    //self.clinetSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:self.addressTF.text]];
    self.clinetSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:@"wss://streamer.cryptocompare.com/socket.io/?EIO=6&transport=websocket"]];
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
    //[self.clinetSocket send:self.messageTF.text];
    // 'SubAdd', { subs: ['0~Poloniex~BTC~USD'] }
    //NSString *string = @"'SubAdd', { subs: ['0~Poloniex~BTC~USD'] }";
    NSString *string = @"['0~Poloniex~BTC~USD']";
    [self.clinetSocket send:string];
    [self showMessageWithStr:[NSString stringWithFormat:@"发送:%@", string]];
    
    // socket.emit('SubAdd', { subs: ['0~Poloniex~BTC~USD'] } );
    // {"event": "somevent", "data": "This is a message", "cid": 2}
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
    NSString *text = nil;
    if ([message isKindOfClass:[NSString class]]) {
        text = (NSString *)message;
    } else if ([message isKindOfClass:[NSData class]]) {
        text = [[NSString alloc] initWithData:message encoding:NSUTF8StringEncoding];
    }
    
    [self showMessageWithStr:[NSString stringWithFormat:@"收到:%@", text]];
    NSLog(@"%@", text);
    text = [text substringFromIndex:1];
    NSData *jsonData = [text dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *rdic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (rdic[@"sid"]) {
        NSDictionary *dic = @{@"event": @"SubAdd", @"sid": rdic[@"sid"]};
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", jsonString);
        //去除掉首尾的空白字符和换行字符
        jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSLog(@"%@", jsonString);
        [self.clinetSocket send:jsonString];
        [self showMessageWithStr:[NSString stringWithFormat:@"发送:%@", jsonString]];
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

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    NSString *text = [[NSString alloc] initWithData:pongPayload encoding:NSUTF8StringEncoding];
    [self showMessageWithStr:[NSString stringWithFormat:@"收到pong:%@", text]];
}

@end
