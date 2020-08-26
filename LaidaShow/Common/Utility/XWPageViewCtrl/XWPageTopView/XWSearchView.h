//
//  XWSearchView.h
//  XWPageViewControllerDemo
//
//  Created by hitomedia on 16/7/29.
//  Copyright © 2016年 hitu. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
自动设置其高宽
 */
@interface XWSearchView : UIView

@property (nonatomic, strong, readonly) UISearchBar *searchBar;

@property (nonatomic, strong) UIColor *searchBarTextFieldBackColor;

- (id)init; //自动计算宽高，但需要设置origin

//
- (id)initWithFrame:(CGRect)frame backColor:(UIColor*)backColor;

@end
