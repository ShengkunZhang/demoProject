//
//  NextViewController.m
//  LocalizationAndInternationalizationDemo
//
//  Created by zsk on 2017/9/15.
//  Copyright © 2017年 zsk. All rights reserved.
//

#import "NextViewController.h"
#import "NSBundle+Language.h"

@interface NextViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *changeBtn;

@end

static NSString *english = @"en";
static NSString *chinese = @"zh-Hans";
static NSString *toEnglish = @"切换为英文";
static NSString *toChinese = @"chang to Chinese";

@implementation NextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *imageName = NSLocalizedString(@"icon", nil);
    UIImage *image = [UIImage imageNamed:imageName];
    self.imageView.image = image;
    
    // 获得当前的语言
    //NSArray *languages = [[NSUserDefaults standardUserDefaults] valueForKey:@"AppleLanguages"];
    NSString *currentLanguage = [[NSUserDefaults standardUserDefaults] valueForKey:@"myLanguages"];
    if (!currentLanguage) {
        currentLanguage = english;
    }
    if ([currentLanguage isEqualToString:english]) {
        // 当前为英语设置为中文
        currentLanguage = toChinese;
    } else if ([currentLanguage isEqualToString:chinese]) {
        // 当前为中文设置为英文
        currentLanguage = toEnglish;
    }
    [self.changeBtn setTitle:currentLanguage forState:UIControlStateNormal];
}

- (IBAction)changeLanguage:(id)sender {
    NSString *currentLanguage = nil;
    if ([self.changeBtn.titleLabel.text isEqualToString:toChinese]) {
        currentLanguage = chinese;
        [self.changeBtn setTitle:toEnglish forState:UIControlStateNormal];
    } else if ([self.changeBtn.titleLabel.text isEqualToString:toEnglish]) {
        currentLanguage = english;
        [self.changeBtn setTitle:toChinese forState:UIControlStateNormal];
    }
    
    // 设置语言
    [NSBundle setLanguage:currentLanguage];
    [[NSUserDefaults standardUserDefaults] setObject:currentLanguage forKey:@"myLanguages"];
    
    // 重新初始化rootVC
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *rootNav = [storyBoard instantiateViewControllerWithIdentifier:@"rootNav"];
    [UIApplication sharedApplication].keyWindow.rootViewController = rootNav;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
