//
//  ContextMenuCell.h
//  CXKMeun
//
//  Created by admin on 15/12/30.
//  Copyright © 2015年 CXK. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CXKContextMenuCell.h"

@interface ContextMenuCell : UITableViewCell <CXKContextMenuCell>
@property (weak, nonatomic) IBOutlet UILabel *menuTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *menuImageView;

@end
