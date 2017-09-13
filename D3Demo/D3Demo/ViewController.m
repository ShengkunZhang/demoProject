//
//  ViewController.m
//  D3Demo
//
//  Created by zsk on 2017/9/12.
//  Copyright © 2017年 zsk. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.typeString;
    NSString *css = nil;
    NSString *js = nil;
    NSString *svg = nil;
    if ([self.typeString isEqualToString:@"电钢琴"]) {
        css = [NSString stringWithFormat:@"<link rel=\"stylesheet\" type=\"text/css\" href=\"piano.css\">"];
        js = [NSString stringWithFormat:@"<script src=\"d3.v4.min.js\"></script><script src=\"piano.js\"></script>"];
        svg = @"<svg width=\"414\" height=\"414\"></svg>";
    } else if ([self.typeString isEqualToString:@"蒙娜丽莎"]) {
        css = [NSString stringWithFormat:@"<link rel=\"stylesheet\" type=\"text/css\" href=\"monalisha.css\">"];
        js = [NSString stringWithFormat:@"<script src=\"d3.v4.min.js\"></script><script src=\"monalisha.js\"></script>"];
        svg = @"<canvas width=\"414\" height=\"414\"></canvas> <svg width=\"414\" height=\"414\"></svg>";
    } else if ([self.typeString isEqualToString:@"折线图"]) {
        css = [NSString stringWithFormat:@"<link rel=\"stylesheet\" type=\"text/css\" href=\"line.css\">"];
        js = [NSString stringWithFormat:@"<script src=\"d3.v4.min.js\"></script><script src=\"line.js\"></script>"];
        svg = @"<svg width=\"414\" height=\"414\"></svg>";
    }
    
    
    NSString *htmlString = [NSString stringWithFormat:@"<html><head><meta charset=\"utf-8\">%@</head><body> %@ %@</body></html>", css, svg, js];
    
    NSURL *baseURL = [[NSBundle mainBundle] resourceURL];
    [self.webview loadHTMLString:htmlString baseURL:baseURL];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
