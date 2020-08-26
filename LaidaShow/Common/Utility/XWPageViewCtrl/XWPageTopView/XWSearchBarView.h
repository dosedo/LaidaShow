//
//  XWSearchBarView.h
//  HituSocial
//
//  Created by hitomedia on 2018/1/16.
//  Copyright © 2018年 hitumedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XWSearchBarView : UIView

@property (nonatomic, strong) UIColor *searchBarTextColor;
@property (nonatomic, strong) UIColor *searchBarTextFieldBackColor;
@property (nonatomic, strong) UIView *searchBarView;
@property (nonatomic, strong) UIButton *cancleBtn;

- (id)initWithFrame:(CGRect)frame showCancleBtn:(BOOL)showCancleBtn;

@end
