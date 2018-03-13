//
//  CollectionViewCell.m
//  pieDemo
//
//  Created by zsk on 2018/3/9.
//  Copyright © 2018年 zsk. All rights reserved.
//

#import "CollectionViewCell.h"

@interface CollectionViewCell()

@property (weak, nonatomic) IBOutlet  UIImageView *tagImage;

@end

@implementation CollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.tagImage.layer.cornerRadius = 5.0;
    self.tagImage.layer.masksToBounds = YES;
}

@end
