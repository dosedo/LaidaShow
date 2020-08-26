//
//  KErrorCode.m
//  HopeHelpClient
//
//  Created by wkun on 3/27/16.
//  Copyright © 2016 deepai. All rights reserved.
//

#import "KErrorCode.h"

/**
 *  错误码范围：[700,900]
 */
@implementation KErrorCode

/**
 *  错误码的初始值
 */
NSInteger const KErrorCodeDefault                 = -1;

NSInteger const KErrorCodePhoneNumNull            = 5700;                   //电话号码为空
NSInteger const KErrorCodePhoneNumInvalid         = 5701;                   //电话号码无效
NSInteger const KErrorCodePwdsNoConsistent        = 5702;                   //两次输入密码不一致
NSInteger const KErrorCodePwdLengthInvalid        = 5703;                   //密码长度不合法
NSInteger const KErrorCodePwdContentInvalid       = 5704;                   //密码内容不合法
NSInteger const KErrorCodePwdNull                 = 5705;                   //密码为空
NSInteger const KErrorCodeVerifyCodeNull          = 5706;                   //验证码为空
NSInteger const KErrorCodeVerifyCodeLengthInvalid = 5707;                   //验证码长度不合法
NSInteger const KErrorCodeVerifyCodeContentInvalid= 5708;                   //验证码内容不合法
NSInteger const KErrorCodePwdError                = 5709;                   //密码错误
NSInteger const KErrorCodeUserNameNull            = 5710;                   //用户名为空
NSInteger const KErrorCodePwdOldNull              = 5711;                   //原始密码为空
NSInteger const KErrorCodePwdNewLengthInvalid     = 5712;                   //修改密码时，新密码长度不合法
NSInteger const KErrorCodeEmailInvalid            = 5713;                   //邮箱不合法
NSInteger const KErrorCodeEmerncyContactsNull     = 5714;                   //紧急联系人为空
NSInteger const KErrorCodeEmailNull               = 5715;                   //邮箱为空
NSInteger const KErrorCodeUserNameLengthInvalid   = 5716;                   //用户名长度不合法
NSInteger const KErrorCodeUserNameContentInvalid  = 5717;                   //用户名内容不合法
NSInteger const KErrorCode12306VerifyCodeNull     = 5718;                   //12306验证码为空


/**
 *  错误模块部分
 */
NSString *const KErrorDomainNetwork               = @"NetWork";               //网络部分
NSString *const KErrorDomainDataFormmatter        = @"DataFormmater";         //登陆注册部分

@end

