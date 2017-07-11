//
//  ViewController.m
//  createKaoYanEnglishHtmlFile
//
//  Created by zsk on 2017/4/26.
//  Copyright © 2017年 zsk. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建文件
    NSFileManager *mannager = [NSFileManager defaultManager];
    // 加载文件
    NSArray *array = @[@"/Users/zsk/Desktop/demoProject/createKaoYanEnglishHtmlFile/csv文件/part1.txt", @"/Users/zsk/Desktop/demoProject/createKaoYanEnglishHtmlFile/csv文件/part2.txt"];
    for (NSString *filePath in array) {
        NSString *fileString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        NSArray *fileArray = [fileString componentsSeparatedByString:@"\"\n"];
        for (NSString *aString in fileArray) {
            NSString *abcString = [aString stringByReplacingOccurrencesOfString:@" " withString:@" "];
            // 区分<p><b>***</b></p> 与其他
            NSArray *abcArray = [abcString componentsSeparatedByString:@"</b></p>"];
            if (abcArray.count < 2) {
                break;
            }
            NSString *pbString = abcArray.firstObject;
            NSArray *pbcArray = [pbString componentsSeparatedByString:@"<p><b>"];
            
            NSString *title = pbcArray[1];
            NSLog(@"title>>%@", title);
            NSString *newFileString = [NSString stringWithFormat:@"<html> <head> <meta charset=\"utf-8\" /> <title>%@</title> </head> <body> <div> %@ </div> </body> </html>", title, abcArray[1]];
            [mannager createFileAtPath:[NSString stringWithFormat:@"/Users/zsk/Desktop/考研/html文件/%@.html", title] contents:[newFileString dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
