//
//  CXKContextMenuCell.h
//  CXKMeun
//
//  Created by admin on 15/12/30.
//  Copyright © 2015年 CXK. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CXKContextMenuCell <NSObject>
/**
 *  Following methods called for cell when animation to be processed.
 *
 */
- (UIView *)animatedIcon;
- (UIView *)animatedContent;

@end
