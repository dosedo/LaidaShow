//
//  UINavigationController+Ext.m
//  HiTravelService
//
//  Created by hitomedia on 2017/4/14.
//  Copyright © 2017年 hitumedia. All rights reserved.
//

#import "UINavigationController+Ext.h"
#import "UIColor+Ext.h"

@implementation UINavigationController (Ext)
- (void)configNavigationCtrl{
    // Do any additional setup after loading the view.
    [self setNeedsStatusBarAppearanceUpdate];
    //取出Appearance对象
    UINavigationBar *navBar = [UINavigationBar appearance];
    
    [navBar setBarStyle:UIBarStyleBlack];
    //设置返回按钮为黑色
    navBar.tintColor = navBar.barTintColor = [UIColor blackColor];
    
    //设置barButtonItem的主题
    UIBarButtonItem *item = [UIBarButtonItem appearance];
    //不显示返回按钮的标题
    [item setBackButtonTitlePositionAdjustment:UIOffsetMake(NSIntegerMin, 0) forBarMetrics:UIBarMetricsDefault];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStyleDone target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backBtn];
    item.tintColor = [UIColor blackColor];
    
    //设置文字颜色 隐藏返回按钮标题
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRgb51],
                                   NSFontAttributeName:[UIFont fontWithName:@"STHeitiSC-Light" size:14.0]}
                        forState:UIControlStateNormal];

    //设置标题的文字字号颜色
    NSDictionary *attr =
    @{NSForegroundColorAttributeName:[UIColor blackColor],
      NSFontAttributeName:[UIFont fontWithName:@"STHeitiSC-Light"//@"STHeitiSC-Light"
                                          size:18.0]};
    [navBar setTitleTextAttributes:attr];
}

/**
 设置NaviBar 透明
 */
- (void)setNavigationBarBgClear{
    
    self.navigationBar.translucent = YES;
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
}

#pragma mark - 适配ios13 preferredStatusBarStyle不调用问题

//- (UIViewController *)childViewControllerForStatusBarStyle{
//    return self.topViewController;
//}
//
//- (UIViewController*)childViewControllerForStatusBarHidden{
//    return self.topViewController;;
//}

// 重写这个方法才能让 viewControllers 对 statusBar 的控制生效
- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.topViewController.preferredStatusBarStyle;
}

#pragma mark - reload 

- (UIViewController*)childViewControllerForStatusBarStyle{
    return self.visibleViewController;
}

@end
