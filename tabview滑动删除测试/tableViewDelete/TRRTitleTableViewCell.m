/*************************************************************************
 *
 * FThinking CONFIDENTIAL
 * ______________________
 *
 *  Copyright © 2016年 FThinking Technology Co., Ltd.
 *  All rights reserved.
 *
 * NOTICE:  All information contained herein is, and remains the property
 * of FThinking Technology (Beijing) Co., Ltd. and its suppliers,
 * if any.  The intellectual and technical concepts contained herein are
 * proprietary to FThinking Technology (Beijing) Co., Ltd. and its
 * suppliers and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from FThinking Technology (Beijing) Co., Ltd.
 **************************************************************************/

#import "TRRTitleTableViewCell.h"

@implementation TRRTitleTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
