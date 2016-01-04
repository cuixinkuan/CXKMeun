//
//  ViewController.m
//  CXKMeun
//
//  Created by admin on 15/12/30.
//  Copyright © 2015年 CXK. All rights reserved.
//

#import "ViewController.h"
#import "ContextMenuCell.h"
#import "CXKContextMenuTableView.h"
#import "CXKNavigationBar.h"

static NSString * const menuCellIdentifier = @"rotationCell";

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,CXKContextMenuTableViewDelegate>

@property (nonatomic,strong)CXKContextMenuTableView * contextMenuTableView;
@property (nonatomic,strong)NSArray * menuTitles;
@property (nonatomic,strong)NSArray * menuIcons;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initiateMenuOptions];
    [self.navigationController setValue:[[CXKNavigationBar alloc] init] forKey:@"navigationBar"];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.contextMenuTableView reloadData];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.contextMenuTableView updateAlongsideRotation];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self.contextMenuTableView reloadData];
    }];
    [self.contextMenuTableView updateAlongsideRotation];
}

#pragma mark - local methods
- (void)initiateMenuOptions {
    self.menuTitles = @[@"add friends",@"like icon",@"delete icon",@"add favourites",@"send messages"];
    self.menuIcons = @[[UIImage imageNamed:@"menu1"],[UIImage imageNamed:@"menu2"],[UIImage imageNamed:@"menu3"],[UIImage imageNamed:@"menu4"],[UIImage imageNamed:@"menu5"]];
}


#pragma mark - IBAction
- (IBAction)presentMenuButtonTapped:(UIBarButtonItem *)sender {
    if (!self.contextMenuTableView) {
        self.contextMenuTableView = [[CXKContextMenuTableView alloc] initWithTableViewDelegateDataSource:self];
        self.contextMenuTableView.animationDuration = 0.15;
        self.contextMenuTableView.cxkDelegate = self;
        self.contextMenuTableView.menuItemsSide = Right;
        self.contextMenuTableView.menuItemsAppearanceDirection = FromTopToBottom;
        
        // register nib
        UINib * cellNib = [UINib nibWithNibName:@"ContextMenuCell" bundle:nil];
        [self.contextMenuTableView registerNib:cellNib forCellReuseIdentifier:menuCellIdentifier];
    }
    
    [self.contextMenuTableView showInView:self.navigationController.view withEdgeInsets:UIEdgeInsetsZero animated:YES];
    
}

#pragma mark - cxkContextMenuTableViewDelegate
- (void)contextMenuTableView:(CXKContextMenuTableView *)contextMenuTableView didDismissWithIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"------------> indexPath.row:%ld",(long)indexPath.row);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuTitles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContextMenuCell * cell = [tableView dequeueReusableCellWithIdentifier:menuCellIdentifier forIndexPath:indexPath];
    if (cell) {
        cell.backgroundColor = [UIColor clearColor];
        cell.menuTitleLabel.text = [self.menuTitles objectAtIndex:indexPath.row];
        cell.menuImageView.image = [self.menuIcons objectAtIndex:indexPath.row];
    }
    return cell;
}

- (void)tableView:(CXKContextMenuTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView dismisWithIndexPath:indexPath];
}





















- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
