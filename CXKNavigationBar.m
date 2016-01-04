//
//  CXKNavigationBar.m
//  CXKMeun
//
//  Created by admin on 15/12/30.
//  Copyright © 2015年 CXK. All rights reserved.
//

#import "CXKNavigationBar.h"

static float const defaultHeight = 65.0f;

@implementation CXKNavigationBar

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize amendedSize = [super sizeThatFits:size];
    amendedSize.height = defaultHeight;
    return amendedSize;
}

@end
