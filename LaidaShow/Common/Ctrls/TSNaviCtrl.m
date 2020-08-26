//
//  TSNaviCtrl.m
//  ThreeShow
//
//  Created by hitomedia on 30/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSNaviCtrl.h"
#import "TSCourseCtrl.h"

@interface TSNaviCtrl ()<UINavigationBarDelegate>

@end

@implementation TSNaviCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//{
//    return toInterfaceOrientation != UIDeviceOrientationPortraitUpsideDown;
//}
//
//- (BOOL)shouldAutorotate
//{
//    if ([self.topViewController isKindOfClass:[TSCourseCtrl class]]) { // 如果是这个 vc 则支持自动旋转
//        return YES;
//    }
//    return NO;
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    
//    return UIInterfaceOrientationMaskAllButUpsideDown;
//}

#pragma mark - NavigationBarDelegate
//为了解决 左滑返回时。在导航控制器的根视图页面 左滑几次，在点其他按钮push页面，就会卡死问题
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item{
    //只有一个控制器的时候禁止手势，防止卡死现象
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    if (self.childViewControllers.count > 1) {
        if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.interactivePopGestureRecognizer.enabled = YES;
        }
    }
    return YES;
}

- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item {
    //只有一个控制器的时候禁止手势，防止卡死现象
    if (self.childViewControllers.count == 1) {
        if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.interactivePopGestureRecognizer.enabled = NO;
        }
    }
}

@end
