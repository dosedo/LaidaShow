//
//  DSCenterButtonTabbarController.h
//  DSCenterButtonTabbarController
//
//  Created by cgw on 2019/2/20.
//  Copyright © 2019 bill. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 带有中心按钮的TabbarController
 可配置按钮所有属性
 */
@interface DSCenterButtonTabbarController : UITabBarController

- (id)initWithShowCenterButton:(BOOL)showCenterButton;

@property (nonatomic, strong, readonly) UIButton *centerButton;

@end

NS_ASSUME_NONNULL_END
