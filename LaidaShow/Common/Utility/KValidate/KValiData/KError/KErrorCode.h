//
//  KErrorCode.h
//  HopeHelpClient
//
//  Created by wkun on 3/27/16.
//  Copyright © 2016 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  错误码范围：[700,900]  :调用者可自行扩充，扩充后，在kError.strings文件中，添加错误码对应的描述即可
 */
@interface KErrorCode : NSObject

/**
 *  错误码的初始值
 */
extern NSInteger const KErrorCodeDefault;

extern NSInteger const KErrorCodePhoneNumNull;               //电话号码为空
extern NSInteger const KErrorCodePhoneNumInvalid;            //电话号码无效
extern NSInteger const KErrorCodePwdsNoConsistent;           //两次输入密码不一致
extern NSInteger const KErrorCodePwdLengthInvalid;           //密码长度不合法
extern NSInteger const KErrorCodePwdContentInvalid;          //密码内容不合法
extern NSInteger const KErrorCodePwdNull;                    //密码为空
extern NSInteger const KErrorCodeVerifyCodeNull;             //验证码为空
extern NSInteger const KErrorCodeVerifyCodeLengthInvalid;    //验证码长度不合法
extern NSInteger const KErrorCodeVerifyCodeContentInvalid;   //验证码内容不合法
extern NSInteger const KErrorCodePwdError;                   //密码错误
extern NSInteger const KErrorCodeUserNameNull;
extern NSInteger const KErrorCodeUserNameLengthInvalid;      //用户名长度不合法
extern NSInteger const KErrorCodeUserNameContentInvalid;
extern NSInteger const KErrorCodePwdOldNull;                 //修改密码时，原始密码为空
extern NSInteger const KErrorCodePwdNewLengthInvalid;        //修改密码时，新密码长度不合法
extern NSInteger const KErrorCodeEmailInvalid;               //邮箱无效
extern NSInteger const KErrorCodeEmerncyContactsNull;        //紧急联系人为空
extern NSInteger const KErrorCodeEmailNull;                  //邮箱为空
extern NSInteger const KErrorCode12306VerifyCodeNull;        //12306验证码为空

/**
 *  错误模块划分
 */
extern NSString *const KErrorDomainNetwork;                  //网络部分
extern NSString *const KErrorDomainDataFormmatter;           //数据格式错误
@end


