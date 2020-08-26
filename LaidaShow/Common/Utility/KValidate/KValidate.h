//
//  KValidate.h
//  HopeHelpClient
//
//  Created by wkun on 4/6/16.
//  Copyright © 2016 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KValidate : NSObject

+ (BOOL)validateRegisterWithUserName:(NSString*)userName
                            phoneNum:(NSString*)phoneNum
                          verifyCode:(NSString*)verifyCode
                                 pwd:(NSString*)pwd
                          confirmPwd:(NSString*)cPwd
                             errCode:(NSInteger*)errCode;

+ (BOOL)validateForgetPwdWithPhoneNum:(NSString*)phoneNum
                           verifyCode:(NSString*)verifyCode
                                  pwd:(NSString*)pwd
                           confirmPwd:(NSString*)cPwd
                              errCode:(NSInteger*)errCode;

+ (BOOL)validateLoginWithPhoneNum:(NSString*)phoneNum
                              pwd:(NSString*)pwd
                          errCode:(NSInteger*)errCode;

+ (BOOL)validatePhoneNum:(NSString*)phoneNum
                 errCode:(NSInteger*)errCode;

+ (BOOL)validatePhoneNum:(NSString*)phoneNum
              verifyCode:(NSString*)verifyCode
                 errCode:(NSInteger*)errCode;

+ (BOOL)validateModifyPwdWithOldPwd:(NSString*)oldPwd
                             newPwd:(NSString*)newPwd
                         confirmPwd:(NSString*)confirmPwd
                            errCode:(NSInteger*)errCode;

+ (BOOL)validateEmail:(NSString*)email
              errCode:(NSInteger*)errCode;

+ (BOOL)validateUserName:(NSString*)userName
                  minLen:(NSUInteger)minLen
                  maxLen:(NSUInteger)maxLen
                 errCode:(NSInteger*)errCode;

+ (BOOL)validateLogin12306WithUserName:(NSString*)userName                   minLen:(NSUInteger)minLen maxLen:(NSUInteger)maxLen pwd:(NSString*)pwd pwdMinLen:(NSUInteger)pwdMinL errCode:(NSInteger*)errCode;

/**
 验证12306的验证码坐标字符串是否有效
 
 @param code    12306验证码坐标字符串
 @param errCode 返回的错误码
 
 @return 是否有效
 */
+ (BOOL)validate12306VerCode:(NSString*)code errCode:(NSInteger *)errCode;

@end
