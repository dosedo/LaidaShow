//
//  TSForgetPwdPhoneCtrl.h
//  ThreeShow
//
//  Created by hitomedia on 05/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 找回密码，输入手机号页面
 */
@interface TSForgetPwdPhoneCtrl : UIViewController

/**
 用户账号，若登陆页面输入了，则带过来
 */
@property (nonatomic, strong) NSString *userAcccount;

@end
