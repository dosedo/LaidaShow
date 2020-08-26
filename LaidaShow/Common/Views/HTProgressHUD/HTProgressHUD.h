//
//  HTProgressHUD.h
//  Hitu
//
//  Created by hitomedia on 16/7/19.
//  Copyright © 2016年 hitomedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HTProgressHUD : NSObject

@property (nonatomic, assign) NSUInteger tag;

@property (nonatomic, assign) BOOL isShowing; //是否展示中


+ (void)showError:(NSString*)error;

+ (void)showSuccess:(NSString*)success;

+ (void)showSuccess:(NSString *)success toView:(UIView*)view;

+ (HTProgressHUD*)showMessage:(NSString*)msg toView:(UIView*)view;

- (void)hide;

- (void)updateShowMessage:(NSString*)msg;

@end
