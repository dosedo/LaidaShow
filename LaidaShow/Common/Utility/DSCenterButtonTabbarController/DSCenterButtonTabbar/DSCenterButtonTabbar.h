//
//  DSCenterButtonTabbar.h
//  DSCenterButtonTabbarController
//
//  Created by cgw on 2019/2/20.
//  Copyright © 2019 bill. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#ifndef DSCENTERBUTTONTABBAR
#define DSCENTERBUTTONTABBAR
//按钮默认的frame的值，通过对比该值来判断用户是否需要修改按钮frame
#define CBT_ButtonDefaultFrame (CGRectMake(-1, -1, 50, 50))

#endif

@interface DSCenterButtonTabbar : UITabBar

- (DSCenterButtonTabbar*)initWithCenterButton:(UIButton*)centerButton;

@end

NS_ASSUME_NONNULL_END
