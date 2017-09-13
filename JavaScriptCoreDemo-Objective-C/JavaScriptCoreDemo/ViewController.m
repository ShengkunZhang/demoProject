//
//  ViewController.m
//  JavaScriptCoreDemo
//
//  Created by zsk on 2017/9/8.
//  Copyright © 2017年 zsk. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) NSArray *array;

@end

@implementation ViewController

- (NSArray *)array {
    if (_array == nil) {
        _array = @[@"调用javaScript的函数和变量", @"Markdown to HTML", @"iPhone Devices List"];
    }
    return _array;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    UITableViewCell *Cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    Cell.textLabel.text = self.array[indexPath.row];
    return Cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"simpleVC" sender:nil];
    } else if (indexPath.row == 1) {
        [self performSegueWithIdentifier:@"markdownVC" sender:nil];
    } else {
        [self performSegueWithIdentifier:@"devicesVC" sender:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

@end
