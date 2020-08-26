//
//  DSAppleLogin.h
//  ThreeShow
//
//  Created by Met on 2020/7/18.
//  Copyright © 2020 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface DSAppleLogin : NSObject

+(instancetype)shareAppleLogin;

@property (nonatomic, copy) void(^competeBlock)(NSString *userId,NSString* name);

- (UIView*)getLoginBtnWithFrame:(CGRect)fr target:(id)target sel:(SEL)sel;

// 处理授权
- (void)handleAuthorizationAppleIDButtonPress;

// 如果存在iCloud Keychain 凭证或者AppleID 凭证提示用户
- (void)perfomExistingAccountSetupFlows;

@end

NS_ASSUME_NONNULL_END
