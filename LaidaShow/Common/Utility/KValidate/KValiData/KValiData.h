//
//  KValiData.h
//  HopeHelpClient
//
//  Created by 端倪 on 16/2/3.
//  Copyright © 2016年 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KValiData : NSObject

+(KValiData*)shardValiData;

/**
 *  是否为有效的字符串
 *
 *  @param string 字符串
 *  @param minLen 满足的最小长度,不限制则传0
 *  @param maxLen 满足的最大长度,不限制则传-1
 *
 *  @return 有效YES，无效NO
 */
-(BOOL)validateString:(NSString*)string minLength:(NSUInteger)minLen maxLength:(NSInteger)maxLen;

/**
 *  验证字符串是否有效，即不为空或@""
 *
 *  @param string 字符串
 *
 *  @return 有效YES。否则NO
 */
-(BOOL)validateString:(NSString*)string;

/**
 *  是否为有效的手机号
 *
 *  @param phone 待验证的手机号
 *
 *  @return 有效YES，无效NO
 */
-(BOOL)valildatePhone:(NSString*)phone;
/**
 *  是否为有效的身份证号
 *
 *  @param phone 待验证的身份证号
 *
 *  @return 有效YES，无效NO
 */

/**
 *  验证邮箱是否有效
 *
 *  @param email 邮箱
 *
 *  @return 有效YES，无效NO
 */
-(BOOL)validateEmail:(NSString*)email;

- (BOOL)valildateIdCard:(NSString *)idCard;
- (BOOL)valildateBandCard:(NSString *)bandCard;
/**
 *  两个字符串是否相等并有效
 *
 *  @param aString 待验证的字符串A
 *  @param bString 待比较的字符串B
 *  @param minLen  合法的最小长度
 *  @param maxLen  合法的最大长度
 *
 *  @return 有效YES, 无效NO
 */
-(BOOL)validateAString:(NSString *)aString equalBString:(NSString*)bString minLength:(NSInteger)minLen maxLength:(NSInteger)maxLen;

/**
 *  是否为有效长度的数字
 *
 *  @param digital 数字字串
 *  @param length  指定的长度
 *
 *  @return 有效YES,无效NO
 */
-(BOOL)validateDigital:(NSString*)digital length:(NSUInteger)length;

@end


