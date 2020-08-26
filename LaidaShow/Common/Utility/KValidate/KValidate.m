//
//  KValidate.m
//  HopeHelpClient
//
//  Created by wkun on 4/6/16.
//  Copyright © 2016 deepai. All rights reserved.
//

#import "KValidate.h"
#import "KValiData.h"
#import "KErrorCode.h"

#define PWD_MIN_LEN 6
#define PWD_MAX_LEN 18

@implementation KValidate
+ (KValidate*)shareValidate{
    static KValidate *vd = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        vd = [[KValidate alloc] init];
    });
    return vd;
}

+ (BOOL)validateRegisterWithUserName:(NSString *)userName phoneNum:(NSString *)phoneNum verifyCode:(NSString *)verifyCode pwd:(NSString *)pwd confirmPwd:(NSString *)cPwd errCode:(NSInteger *)errCode{
    
    KValidate *vdSelf = [KValidate shareValidate];
    KValiData *kvd = [KValiData shardValiData];
    if( [kvd validateString:userName] ){
        if( [ vdSelf validatePhone:phoneNum errCode:errCode] ){
            if( [vdSelf validateVerfiCode:verifyCode errCode:errCode] ){
                if( [vdSelf validatePwd:pwd confirmPwd:cPwd errCode:errCode] ){
                    return YES;
                }
            }
        }
    }
    else{
        *errCode = KErrorCodeUserNameNull;
    }
    
    return NO;
}

+ (BOOL)validateForgetPwdWithPhoneNum:(NSString *)phoneNum verifyCode:(NSString *)verifyCode pwd:(NSString *)pwd confirmPwd:(NSString *)cPwd errCode:(NSInteger *)errCode{
    KValidate *vdSelf = [KValidate shareValidate];
    if( [ vdSelf validatePhone:phoneNum errCode:errCode] ){
        if( [vdSelf validateVerfiCode:verifyCode errCode:errCode] ){
            if( [vdSelf validatePwd:pwd confirmPwd:cPwd errCode:errCode] ){
                return YES;
            }
        }
    }
    return NO;
}

+ (BOOL)validateLoginWithPhoneNum:(NSString *)phoneNum pwd:(NSString *)pwd errCode:(NSInteger *)errCode{
    KValidate *vdSelf = [KValidate shareValidate];
    if( [vdSelf validatePhone:phoneNum errCode:errCode] ){
        if( [vdSelf validatePassword:pwd errCode:errCode isNeedLimitLen:NO] ){
            return YES;
        }
    }
    return NO;
}

+ (BOOL)validatePhoneNum:(NSString *)phoneNum errCode:(NSInteger *)errCode{
    return [[KValidate shareValidate] validatePhone:phoneNum errCode:errCode];
}

+ (BOOL)validatePhoneNum:(NSString *)phoneNum verifyCode:(NSString *)verifyCode errCode:(NSInteger *)errCode{
    NSInteger code = KErrorCodeDefault;
    [KValidate validatePhoneNum:phoneNum errCode:&code];
    if( code != KErrorCodeDefault ){
        *errCode = code;
        return NO;
    }
    else{
        [[KValidate shareValidate] validateVerfiCode:verifyCode errCode:&code];
        if( code != KErrorCodeDefault ){
            *errCode = code;
            return NO;
        }
    }
    
    return YES;
}

+ (BOOL)validateModifyPwdWithOldPwd:(NSString *)oldPwd newPwd:(NSString *)newPwd confirmPwd:(NSString *)confirmPwd errCode:(NSInteger *)errCode{
    
    KValidate *vdSelf = [KValidate shareValidate];

    if( ![vdSelf validatePassword:oldPwd errCode:errCode isNeedLimitLen:YES] ){
        if( oldPwd.length ==0 ){
            *errCode = KErrorCodePwdOldNull;
        }
        return NO;
    }
    
    if( ![vdSelf validatePwd:newPwd confirmPwd:confirmPwd errCode:errCode]){
        if(*errCode == KErrorCodePwdLengthInvalid ){
            *errCode = KErrorCodePwdNewLengthInvalid;
        }
        return NO;
    }
    return YES;
}

+ (BOOL)validateEmail:(NSString *)email errCode:(NSInteger *)errCode{
    
    if( ![[KValiData shardValiData] validateString:email] ){
        *errCode = KErrorCodeEmailNull;
        return NO;
    }
    
    if( ![[KValiData shardValiData] validateEmail:email] ){
        *errCode = KErrorCodeEmailInvalid;
        return NO;
    }
    return YES;
}

+ (BOOL)validateUserName:(NSString*)userName minLen:(NSUInteger)minLen maxLen:(NSUInteger)maxLen errCode:(NSInteger*)errCode{

    KValiData *kvd = [KValiData shardValiData];
    if( ![kvd validateString:userName] ){
        *errCode = KErrorCodeUserNameNull;
        return NO;
    }
    if( ![kvd validateString:userName minLength:minLen maxLength:maxLen] ){
        *errCode = KErrorCodeUserNameLengthInvalid;
        return NO;
    }
    
    return YES;
}

#pragma mark - 12306Login
+ (BOOL)validateLogin12306WithUserName:(NSString *)userName minLen:(NSUInteger)minLen maxLen:(NSUInteger)maxLen pwd:(NSString *)pwd pwdMinLen:(NSUInteger)pwdMinL errCode:(NSInteger *)errCode{
    
    KValiData *kvd = [KValiData shardValiData];
    if( ![kvd validateString:userName] ){
        *errCode = KErrorCodeUserNameNull;
        return NO;
    }
    if( ![kvd validateString:userName minLength:minLen maxLength:maxLen] ){
        *errCode = KErrorCodeUserNameLengthInvalid;
        return NO;
    }
    
    if( ![kvd validateString:pwd] ){
        *errCode = KErrorCodePwdNull;
        return NO;
    }
    
    if( ![kvd validateString:pwd minLength:pwdMinL maxLength:100] ){
        *errCode = KErrorCodePwdLengthInvalid;
        return NO;
    }
    
    return YES;
}

/**
 验证12306的验证码坐标字符串是否有效

 @param code    12306验证码坐标字符串
 @param errCode 返回的错误码

 @return 是否有效
 */
+ (BOOL)validate12306VerCode:(NSString*)code errCode:(NSInteger *)errCode{
    KValiData *kvd = [KValiData shardValiData];
    if( ![kvd validateString:code] ){
        *errCode = KErrorCode12306VerifyCodeNull;
        return NO;
    }
    return YES;
}

#pragma mark - Private

- (BOOL)validatePhone:(NSString*)phoneNum errCode:(NSInteger*)errCode{
   
    KValiData *kvd = [KValiData shardValiData];
    if( ![kvd validateString:phoneNum] ){
        *errCode = KErrorCodePhoneNumNull;
        return NO;
    }
    
    if( ![kvd valildatePhone:phoneNum] ){
        *errCode = KErrorCodePhoneNumInvalid;
        return NO;
    }

    return YES;
}

- (BOOL)validateVerfiCode:(NSString*)verfiCode errCode:(NSInteger*)errCode{
    
    KValiData *kvd = [KValiData shardValiData];
    if( ![kvd validateString:verfiCode] ){
        *errCode = KErrorCodeVerifyCodeNull;
        return NO;
    }
    
    if( ![kvd validateDigital:verfiCode length:6] ){
        *errCode = KErrorCodeVerifyCodeContentInvalid;
        return NO;
    }
    
    return YES;
}

- (BOOL)validatePwd:(NSString*)pwd confirmPwd:(NSString*)confirmPwd errCode:(NSInteger*)errCode{
    
    NSUInteger minLen = PWD_MIN_LEN;
    NSUInteger maxLen = PWD_MAX_LEN;
    
    BOOL ret = NO;
    KValiData *kvd = [KValiData shardValiData];
    if( ![kvd validateString:pwd] && ![kvd validateString:confirmPwd] ){
        *errCode = KErrorCodePwdNull;
    }
    
//    else if (![kvd validateAString:pwd equalBString:confirmPwd minLength:minLen maxLength:maxLen] ){
    else if (![pwd isEqualToString:confirmPwd]){
        *errCode = KErrorCodePwdsNoConsistent;
    }
    else if ( ![kvd validateString:pwd minLength:minLen maxLength:maxLen] || ![kvd validateString:confirmPwd minLength:minLen maxLength:maxLen] ){
        *errCode = KErrorCodePwdLengthInvalid;
    }

    else{
        ret = YES;
    }
    return ret;
}

/**
 *  验证密码
 *
 *  @param pwd            待验证的字符串
 *  @param errCode        错误码
 *  @param isNeedLimitLen 是否需要验证密码的长度
 *
 *  @return 合法YES， 不合法NO
 */
- (BOOL)validatePassword:(NSString*)pwd errCode:(NSInteger*)errCode isNeedLimitLen:(BOOL)isNeedLimitLen{
    
    NSUInteger minLen = PWD_MIN_LEN;
    NSUInteger maxLen = PWD_MAX_LEN;
    
    KValiData *kvd = [KValiData shardValiData];
    if( ![kvd validateString:pwd] ){
        *errCode = KErrorCodePwdNull;
        return NO;
    }
    
    if( isNeedLimitLen ){
    
        if( ![kvd validateString:pwd minLength:minLen maxLength:maxLen] ){
            *errCode = KErrorCodePwdLengthInvalid;
            return NO;
        }
    }
    
    return YES;
}

@end
