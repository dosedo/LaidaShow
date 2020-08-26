//
//  HTProgressHUD.m
//  Hitu
//
//  Created by hitomedia on 16/7/19.
//  Copyright © 2016年 hitomedia. All rights reserved.
//

#import "HTProgressHUD.h"
#import "MBProgressHUD.h"

@interface MBProgressHUD(Ext)
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view;
+ (void)showSuccess:(NSString *)success;
+ (void)showSuccess:(NSString *)success toView:(UIView*)view;
@end

@implementation MBProgressHUD(Ext)
#pragma mark 显示一些信息
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // YES代表需要蒙版效果
//    hud. = NO;
    
    return hud;
}

+ (void)showSuccess:(NSString *)success{
    [self showSuccess:success toView:[UIApplication sharedApplication].keyWindow];
}

+ (void)showSuccess:(NSString *)success toView:(UIView*)view
{
//    [self showSuccess:success toView:nil];
//    [self showMessage:success toView:nil];
    
    MBProgressHUD *hud1 = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    hud1.mode = MBProgressHUDModeText;
    hud1.label.text = success;
    hud1.label.numberOfLines = 0;
    hud1.margin = 10.f;
    hud1.removeFromSuperViewOnHide = YES;
//    hud1.bezelView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [hud1 hideAnimated:YES afterDelay:1];
}

@end

@implementation HTProgressHUD{
    MBProgressHUD *_hud;
}


+ (void)showError:(NSString *)error{
    
    //[MBProgressHUD show:error icon:nil view:nil];
    
//    [MBProgressHUD showError:error];
    MBProgressHUD *hud1 = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
//    hud1.mode = MBProgressHUDModeText;
    hud1.mode = MBProgressHUDModeText;;
//    hud1.label.text = error;
    hud1.detailsLabel.text = error;
    hud1.detailsLabel.font = [UIFont systemFontOfSize:14];
    
    hud1.margin = 10.f;
    hud1.removeFromSuperViewOnHide = YES;
    [hud1 hideAnimated:YES afterDelay:1.5];
}

+ (void)showSuccess:(NSString *)success{
    [MBProgressHUD showSuccess:success];
}

+ (void)showSuccess:(NSString *)success toView:(UIView*)view{
    [MBProgressHUD showSuccess:success toView:view];
}

+ (HTProgressHUD *)showMessage:(NSString *)msg toView:(UIView *)view{
    HTProgressHUD *hud = [[HTProgressHUD alloc] init];
    
    MBProgressHUD *mbHud = [MBProgressHUD showMessage:msg toView:view];
    hud->_hud = mbHud;
    
    return hud;
}

- (void)updateShowMessage:(NSString *)msg{
    _hud.label.text = msg;
}

- (void)hide{
    [_hud hideAnimated:YES];
    _hud = nil;
}

- (BOOL)isShowing{
    _isShowing = !_hud.isHidden;
    return _isShowing;
}

- (void)setTag:(NSUInteger)tag{
    _tag = tag;
    _hud.tag = tag;
}

@end
