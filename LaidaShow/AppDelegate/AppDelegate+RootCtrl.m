//
//  AppDelegate+RootCtrl.m
//  ThreeShow
//
//  Created by wkun on 2019/2/17.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "AppDelegate+RootCtrl.h"
#import "UINavigationController+Ext.h"
#import "UIColor+Ext.h"
#import "UITabBarController+Ext.h"


@implementation AppDelegate (RootCtrl)

+ (void)rootCtrl{
    
}

+ (UIViewController *)tabbarCtrl{
    UITabBarController *tabbar = [UITabBarController new];
    NSArray *ctrls = @[[self naviCtrlWithRootCtrlName:@"OLScheduleCtrl"],
                       [self naviCtrlWithRootCtrlName:@"OLStatisticsCtrl"],
                       [self naviCtrlWithRootCtrlName:@"OLMeCtrl"]];
    NSArray *titles = @[@"日程",@"统计",@"我的"];
    NSArray *niNames = @[@"tabbar_schedule",@"tabbar_statistics",@"tabbar_me"];
    NSArray *siNames = @[@"tabbar_schedule_s",@"tabbar_statistics_s",@"tabbar_me_s"];
    [tabbar configTabbarWithCtrls:ctrls titles:titles
                 selectedImgNames:siNames
                   normalImgNames:niNames
                        textColor:[UIColor orangeColor]
                 selctedTextColor:[UIColor redColor]];
    
    tabbar.tabBar.barTintColor = [UIColor whiteColor];
    tabbar.delegate =(id) [UIApplication sharedApplication].delegate;
    return tabbar;
}

+ (UINavigationController*)naviCtrlWithRootCtrlName:(NSString*)cn{
    if( [cn isKindOfClass:[NSString class]] ){
        UIViewController *ctrl = [NSClassFromString(cn) new];
        if( [ctrl isKindOfClass:[UIViewController class]] ){
            UINavigationController *naviCtrl =
            [[UINavigationController alloc] initWithRootViewController:ctrl];
            [naviCtrl configNavigationCtrl];
            [naviCtrl setNavigationBarBgClear];
            return naviCtrl;
        }
    }
    return [UINavigationController new];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    
    tabBarController.view.tag = [tabBarController.viewControllers indexOfObject:viewController];
    
    return YES;
}

@end
