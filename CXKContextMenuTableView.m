//
//  CXKContextMenuTableView.m
//  CXKMeun
//
//  Created by admin on 15/12/30.
//  Copyright © 2015年 CXK. All rights reserved.
//

#import "CXKContextMenuTableView.h"

#import "UIView+CXKConstraints.h"
#import "CXKContextMenuCell.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

static CGFloat const defaultDuration = 0.3;
static CGPoint const defaultViewAnchorPoint = {0.5f,0.5f};

typedef void(^completionBlock)(BOOL completed);

typedef NS_ENUM(NSUInteger,Direction) {
   left,
    right,
    top,
    bottom
};

typedef NS_ENUM(NSUInteger,AnimatingState) {
    Hiding = -1,
    Stable = 0,
    Showing = 1
};

@interface CXKContextMenuTableView ()

@property (nonatomic)__block NSInteger animatingIndex;
@property (nonatomic,strong)NSMutableArray * topCells;
@property (nonatomic,strong)NSMutableArray * bottomCells;
@property (nonatomic,strong)UITableViewCell <CXKContextMenuCell> * selectedCell;
@property (nonatomic,strong)NSIndexPath * dismissalIndexPath;
@property (nonatomic)AnimatingState animatingState;

@end


@implementation CXKContextMenuTableView

#pragma mark - Initicalizer 

- (instancetype)init {
    self = [super init];
    if (self) {
        self.animatingState = Stable;
        self.animationDuration = defaultDuration;
        self.animatingIndex = 0;
        self.menuItemsSide = Right;
        self.menuItemsAppearanceDirection = FromTopToBottom;
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
        self.separatorColor = [UIColor colorWithRed:181.0/255.0f green:181.0/255.0f blue:181.0/255.0f alpha:0];
        self.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return self;
}

- (instancetype)initWithTableViewDelegateDataSource:(id<UITableViewDelegate,UITableViewDataSource>)delegateDataSource {
    self = [super init];
    if (self) {
        self.delegate = delegateDataSource;
        self.dataSource = delegateDataSource;
    }
    return self;
}

#pragma mark - Show / Dismiss
- (void)showInView:(UIView *)superview withEdgeInsets:(UIEdgeInsets)edgeInsets animated:(BOOL)animated {
    if (self.animatingState != Stable) {
        return;
    }
    
    for (UITableViewCell <CXKContextMenuCell> * aCell in [self visibleCells]) {
        aCell.contentView.hidden = YES;
    }
    self.dismissalIndexPath = nil;
    [superview addSubview:self withSidesConstrainsInsets:edgeInsets];
    if (animated) {
        self.animatingState = Showing;
        self.alpha = 0;
        [self setUserInteractionEnabled:NO];
        
        [UIView animateWithDuration:self.animationDuration animations:^{
            self.alpha = 1;
        } completion:^(BOOL finished) {
            [self show:YES visibleCellsAnimated:YES];
            [self setUserInteractionEnabled:YES];
        }];
    }else {
        [self show:YES visibleCellsAnimated:NO];
    }
    
}

- (void)dismisWithIndexPath:(NSIndexPath *)indexPath {
    if (self.animatingState != Stable) {
        return;
    }
    
    if (!indexPath) {
        [self removeFromSuperview];
        return;
    }
    
    self.dismissalIndexPath = indexPath;
    self.animatingState = Hiding;
    [self setUserInteractionEnabled: NO];
    
    NSArray * visibleCells = [self visibleCells];
    self.topCells = [NSMutableArray array];
    self.bottomCells = [NSMutableArray array];
    for (UITableViewCell<CXKContextMenuCell> * visibleCell in visibleCells) {
        if ([self indexPathForCell:visibleCell].row < indexPath.row) {
            [self.topCells addObject:visibleCell];
        }else if ([self indexPathForCell:visibleCell].row > indexPath.row) {
            [self.bottomCells addObject:visibleCell];
        }else {
            self.selectedCell = visibleCell;
        }
    }
    
    [self dismissTopCells];
    [self dismissBottomCells];
    [self shouldDismissSelf];
    
}

- (void)dismissTopCells {
    if (self.topCells.count) {
        UITableViewCell <CXKContextMenuCell> * hidingCell = [self.topCells firstObject];
        [self show:NO cell:hidingCell aniamted:YES direction:self.menuItemsAppearanceDirection == FromBottomToTop ? top : bottom clockwise:self.menuItemsAppearanceDirection == FromBottomToTop ? NO : YES completion:^(BOOL completed) {
            if (completed) {
                [self.topCells removeObjectAtIndex:0];
                [self dismissTopCells];
                [self shouldDismissSelf];
            }
        }];
    }
}

- (void)dismissBottomCells {
    if (self.bottomCells.count) {
        UITableViewCell <CXKContextMenuCell> * hidongCell = [self.bottomCells lastObject];
        [self show:NO cell:hidongCell aniamted:YES direction:self.menuItemsAppearanceDirection == FromBottomToTop ? bottom : top clockwise:self.menuItemsAppearanceDirection == FromBottomToTop ? YES : NO completion:^(BOOL completed) {
            if (completed) {
                [self.bottomCells removeLastObject];
                [self dismissBottomCells];
                [self shouldDismissSelf];
            }
        }];
    }
}

- (void)shouldDismissSelf {
    if (self.bottomCells.count == 0 && self.topCells.count == 0 ) {
        [self dismissSelf];
    }
}

- (void)dismissSelf {
    Direction direction = self.menuItemsSide == Right ? right : left;
    BOOL clockwise = self.menuItemsSide == Right ? NO : YES;
    [self show:NO cell:self.selectedCell aniamted:YES direction:direction clockwise:clockwise completion:^(BOOL completed) {
        [self removeFromSuperview];
        
        if ([self.cxkDelegate respondsToSelector:@selector(contextMenuTableView:didDismissWithIndexPath:)]) {
            [self.cxkDelegate contextMenuTableView:self didDismissWithIndexPath:[self indexPathForCell:self.selectedCell]];
        }
        self.animatingState = Stable;
    }];
}


- (void)updateAlongsideRotation {
    if (self.animatingState == Hiding) {
        if ([self.cxkDelegate respondsToSelector:@selector(contextMenuTableView:didDismissWithIndexPath:)]) {
            [self.cxkDelegate contextMenuTableView:self didDismissWithIndexPath:[self indexPathForCell:self.selectedCell]];
        }
        [self removeFromSuperview];
    }else if (self.animatingState == Showing) {
        [self show:YES visibleCellsAnimated:NO];
    }
    self.animatingState = Stable;
}



#pragma mark - Pirvate

- (void)show:(BOOL)show visibleCellsAnimated:(BOOL)animated {
    NSArray * visibleCellsIndexPaths = [self indexPathsForVisibleRows];
    NSInteger firstVisibleRowIndex = [(NSIndexPath *)visibleCellsIndexPaths.firstObject row];
    NSInteger lastVisibleRowIndex = [(NSIndexPath *)visibleCellsIndexPaths.lastObject row];
    
    if (visibleCellsIndexPaths.count == 0 || self.animatingIndex > lastVisibleRowIndex) {
        self.animatingIndex = 0;
        [self setUserInteractionEnabled:YES];
        [self reloadData];
        self.animatingState = Stable;
        return;
    }
    
    NSIndexPath * animatingIndexPath = [NSIndexPath indexPathForRow:self.animatingIndex inSection:0];
    UITableViewCell <CXKContextMenuCell> * visibleCell = (UITableViewCell <CXKContextMenuCell > *)[self cellForRowAtIndexPath:animatingIndexPath];
    if (visibleCell) {
        [self prepareCellForShowAnimation:visibleCell];
        [visibleCell contentView].hidden = NO;
        Direction direction;
        if (self.animatingIndex == firstVisibleRowIndex) {
            direction = self.menuItemsSide == Right?right:left;
        }else {
            direction = self.menuItemsAppearanceDirection == FromBottomToTop?bottom:top;
        }
        
        [self show:show cell:visibleCell aniamted:animated direction:direction clockwise:NO completion:^(BOOL completed) {
            self.animatingIndex ++ ;
            [self show:show visibleCellsAnimated:animated];
        }];
    }else {
        self.animatingIndex = firstVisibleRowIndex;
        [self show:show visibleCellsAnimated:animated];
    }
}

- (void)show:(BOOL)show cell:(UITableViewCell <CXKContextMenuCell> *)cell aniamted:(BOOL)animated direction:(Direction)direction clockwise:(BOOL)clockwise completion:(completionBlock)completed {

    UIView * icon = [cell animatedIcon];
    UIView * content = [cell animatedContent];
    
    CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
    rotationAndPerspectiveTransform.m34 = 1.0/200;
    
    CGFloat rotation = 90;
    if (clockwise) {
        rotation = - rotation;
    }
    if (show) {
        rotation = 0;
    }
    
    switch (direction) {
        case left:
        {
            [self setAnchorPoint:CGPointMake(0, 0.5) forView:icon];
            rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, DEGREES_TO_RADIANS(rotation), 0.0f, 1.0f, 0.0f);
              break;
        }
        case right:
        {
            [self setAnchorPoint:CGPointMake(1, 0.5) forView:icon];
            rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, DEGREES_TO_RADIANS(rotation), 0.0f, 1.0f, 0.0f);
            break;
        }
        case top:
        {
            [self setAnchorPoint:CGPointMake(0.5, 0.0) forView:icon];
            rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, DEGREES_TO_RADIANS(rotation), 1.0f, 0.0f, 0.0f);
            break;
        }
        case bottom:
        {
            [self setAnchorPoint:CGPointMake(0.5, 1) forView:icon];
            rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, DEGREES_TO_RADIANS(rotation), 1.0f, 0.0f, 0.0f);
            break;
        }
          
        default:
            break;
    }
    
    if (animated) {
        [UIView animateWithDuration:self.animationDuration animations:^{
            icon.layer.transform = rotationAndPerspectiveTransform;
            content.alpha = show;
        } completion:^(BOOL finished) {
            if (completed) {
                completed(finished);
            }
        }];
    }else {
        icon.layer.transform = rotationAndPerspectiveTransform;
        content.alpha = show;
        if (completed) {
            completed(YES);
        }
    }
    
}


- (void)prepareCellForShowAnimation:(UITableViewCell <CXKContextMenuCell> *)cell {

    [self resetAnimatedIconForCell:cell];
    
    Direction direction;
    BOOL clockwise;
    if ([self indexPathForCell:cell].row == 0) {
        direction = self.menuItemsSide == Right ? right : left;
        clockwise = self.menuItemsSide == Right ? NO : YES;
    }else {
        direction = self.menuItemsAppearanceDirection == FromBottomToTop ? bottom : top;
        clockwise = self.menuItemsAppearanceDirection == FromBottomToTop ? YES : NO;
    }
    
    [self show:NO cell:cell aniamted:NO direction:direction clockwise:clockwise completion:nil];
    
}

- (void)resetAnimatedIconForCell:(UITableViewCell <CXKContextMenuCell> *)cell {
    UIView * icon = [cell animatedIcon];
    icon.layer.anchorPoint = defaultViewAnchorPoint;
    icon.layer.transform = CATransform3DIdentity;
    [icon layoutIfNeeded];
}

- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view {
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}

#pragma mark - Setters 

- (void)setMenuItemsAppearanceDirection:(MenuItemsAppearanceDirection)menuItemsAppearanceDirection {
    if (menuItemsAppearanceDirection != _menuItemsAppearanceDirection) {
        _menuItemsAppearanceDirection = menuItemsAppearanceDirection;
        if (self.menuItemsAppearanceDirection == FromBottomToTop) {
            self.layer.transform = CATransform3DRotate(CATransform3DIdentity, M_PI, 0.0f, 0.0f, 1.0f);
        }
    }
}

#pragma mark - OverRiden 

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell <CXKContextMenuCell> * cell = [super dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    [self resetAnimatedIconForCell:cell];
    
    if (cell) {
        if (self.animatingState == Showing) {
            cell.contentView.hidden = YES;
        }else if (self.animatingState == Stable) {
            cell.contentView.hidden = NO;
            [cell animatedContent].alpha = 1;
        }
        if (self.menuItemsAppearanceDirection == FromBottomToTop) {
            cell.layer.transform = CATransform3DRotate(CATransform3DIdentity, M_PI, 0.0f, 0.0f, 1.0f);
        }
    }
    return cell;
}














@end
