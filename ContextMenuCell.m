//
//  ContextMenuCell.m
//  CXKMeun
//
//  Created by admin on 15/12/30.
//  Copyright © 2015年 CXK. All rights reserved.
//

#import "ContextMenuCell.h"

@implementation ContextMenuCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.layer.masksToBounds = YES;
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.shadowColor = [UIColor colorWithRed:181.0/255.0f green:181.0/255.0f blue:181.0/255.0f alpha:1].CGColor;
    self.layer.shadowRadius = 5;
    self.layer.shadowOpacity = 0.5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

#pragma mark - CXKContextMenuCell

- (UIView *)animatedIcon {
    return self.menuImageView;
}

- (UIView *)animatedContent {
    return self.menuTitleLabel;
}

@end
