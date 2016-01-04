//
//  CXKContextMenuTableView.h
//  CXKMeun
//
//  Created by admin on 15/12/30.
//  Copyright © 2015年 CXK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CXKContextMenuTableView;

typedef NS_ENUM(NSInteger,MenuItemsSide) {
    Left,
    Right
};

typedef NS_ENUM(NSInteger,MenuItemsAppearanceDirection) {
    FromTopToBottom,
    FromBottomToTop
};

@protocol CXKContextMenuTableViewDelegate <NSObject>

@optional
/**
 *  This method called when menu dismissed.
 *
 *  @param contextMenuTableView object dismissed
 *  @param indexPath            indexPath of cell selected
 */
- (void)contextMenuTableView:(CXKContextMenuTableView *)contextMenuTableView didDismissWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface CXKContextMenuTableView : UITableView

@property (nonatomic,weak)id <CXKContextMenuTableViewDelegate> cxkDelegate;

@property (nonatomic)CGFloat animationDuration;
@property (nonatomic)MenuItemsSide menuItemsSide;
@property (nonatomic)MenuItemsAppearanceDirection menuItemsAppearanceDirection;

- (instancetype)initWithTableViewDelegateDataSource:(id<UITableViewDelegate,UITableViewDataSource>)delegateDataSource;

- (void)showInView:(UIView *)superview withEdgeInsets:(UIEdgeInsets)edgeInsets animated:(BOOL)animated;

- (void)dismisWithIndexPath:(NSIndexPath *)indexPath;

- (void)updateAlongsideRotation;









































@end
