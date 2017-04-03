//
//  ViewController.m
//  一个具有内边距的Label
//
//  Created by zsk on 2017/4/3.
//  Copyright © 2017年 zsk. All rights reserved.
//

#import "ViewController.h"
#import "CustomLabel.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet CustomLabel *testLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.testLabel.text = @"我的测试";
    self.testLabel.layer.cornerRadius = 2.0;
    self.testLabel.layer.borderWidth = 1.0;
    self.testLabel.layer.borderColor = [UIColor grayColor].CGColor;
    self.testLabel.edgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [self.testLabel sizeToFit];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
