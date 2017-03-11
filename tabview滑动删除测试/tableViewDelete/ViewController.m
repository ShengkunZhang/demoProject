//
//  ViewController.m
//  tableViewDelete
//
//  Created by zsk on 2017/1/9.
//  Copyright © 2017年 zsk. All rights reserved.
//


//一些简单方法的宏定义
//主屏幕大小的获取
#define ScreenFrame             [UIScreen mainScreen].bounds
#define ScreenWidth             [UIScreen mainScreen].bounds.size.width
#define ScreenHeight            [UIScreen mainScreen].bounds.size.height
#define AppNewVersion           [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]
#define OnePX                   1/[UIScreen mainScreen].scale

//动态的确定你所要设置的颜色的RGB
#define RGBAM(r,g,b,a)          [UIColor colorWithRed:r/255.0   green:g/255.0   blue:b/255.0    alpha:a]
#define RGB(r,g,b)              [UIColor colorWithRed:r/255.0   green:g/255.0   blue:b/255.0    alpha:1.0]
#define AppColor                [UIColor colorWithRed:0/255.0   green:184/255.0 blue:117/255.0  alpha:1.0]
#define AppBlack                [UIColor colorWithRed:51/255.0  green:51/255.0  blue:51/255.0   alpha:1.0]
#define AppDarkGray             [UIColor colorWithRed:89/255.0  green:89/255.0  blue:89/255.0   alpha:1.0]
#define AppLightGray            [UIColor colorWithRed:146/255.0 green:146/255.0 blue:146/255.0  alpha:1.0]
#define AppSeperatorColor       [UIColor colorWithRed:200/255.0 green:199/255.0 blue:204/255.0  alpha:1.0]

#import "ViewController.h"
#import "TRRTitleTableViewCell.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView     *tableView;
@property (strong, nonatomic) NSMutableArray         *wordArray;
@property (strong, nonatomic) NSMutableArray         *otherWordArray;
@property (strong, nonatomic) NSMutableArray         *headerArray;
@property (strong, nonatomic) NSMutableArray         *resultsArray;
@property (strong, nonatomic) NSArray                *sectionIndexTitles;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableView];
}


#pragma mark - TableView

- (void)setupTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.sectionIndexColor = [UIColor grayColor];
    self.sectionIndexTitles = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"];
    self.otherWordArray = [NSMutableArray array];
    self.resultsArray   = [NSMutableArray array];
    self.headerArray    = [NSMutableArray array];
    self.wordArray      = [NSMutableArray array];
    
    self.headerArray = [@[@"A", @"B"] mutableCopy];
    NSArray *arr1 = @[@"act", @"actt" ,@"acttoe"];
    NSArray *arr2 = @[@"bset", @"br" ,@"bbs"];
    [self.otherWordArray addObject:arr1];
    [self.otherWordArray addObject:arr2];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.headerArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    for (int i = 0; i < self.otherWordArray.count; i ++) {
        if (i == section) {
            NSArray *arr = self.otherWordArray[i];
            return arr.count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TRRTitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSArray *array = self.otherWordArray[indexPath.section];
    cell.otherTitleLabel.text = array[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *HeaderIdentifier = @"header";
    UITableViewHeaderFooterView *header = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:HeaderIdentifier];
    
    if(!header) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:HeaderIdentifier];
        header.contentView.backgroundColor = RGB(236, 236, 236);
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(18, 2, ScreenWidth - 36, 16)];
        label.textColor = AppColor;
        label.font = [UIFont systemFontOfSize:16];
        label.tag = 101;
        [header addSubview:label];
    }
    UILabel *label = [header viewWithTag:101];
    label.text = self.headerArray[section];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0f;
}

//添加索引列
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (self.headerArray.count == self.sectionIndexTitles.count) {
        //[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        return index;
    } else {
        // 查询离这个单词位置或者离这个单词最近是哪一个
        for (NSInteger i = index; i >= 0; i--) {
            NSString *otherTitle = self.sectionIndexTitles[i];
            for (NSString *string in self.headerArray) {
                if ([string isEqualToString:otherTitle]) {
                    return [self.headerArray indexOfObject:string];
                }
            }
        }
        // 默认是返回-1 则代表不需要变化
        return -1;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
    }];
    return @[deleteAction];
}


@end
