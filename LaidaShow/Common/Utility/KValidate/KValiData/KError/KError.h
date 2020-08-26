//
//  KError.h
//  HopeHelpClient
//
//  Created by wkun on 3/27/16.
//  Copyright © 2016 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KErrorCode.h"

/**
 *  错误类
 */
@interface KError : NSObject

/**
 *  通过错误码,获取错误信息（或者说是错误提示)
 *
 *  @param code 错误码
 *
 *  @return 错误提示信息
 */
+ (NSString*)errorMsgWithCode:(NSInteger)code;

/**
 *  若通过错误码获取的本地消息为空，则通过NSError 实例所带内容获取消息
 *
 *  @param err 从NSError实例中获取消息。注意：此NSError实例，必须由本对象的方法创建。
 *
 *  @return 错误提示消息
 */
+ (NSString*)errorMsgWithError:(NSError*)err;

/**
 *  展示Msg的消息。若msg为空，则获取code对应的本地消息
 *
 *  @param code 错误码。详情见 KErrorCode类
 *  @param msg  消息提示。如果msg为空，则获取本地的KError.strings 中，code对应的错误提示
 *
 *  @return 错误提示信息
 */
+ (NSString*)errorMsgWithCode:(NSInteger )code msg:(NSString*)msg;

/**
 *  创建错误实例
 *
 *  @param domain 错误所属的领域
 *  @param code   错误码
 *  @param msg    错误的提示或描述
 *
 *  @return NSError 实例
 */
+ (NSError*)errorWithDomain:(NSString*)domain code:(NSInteger)code msg:(NSString*)msg;

/**
 *  创建错误实例,该错误实例默认domain为 KErrorDomainDataFormmat
 *
 *  @param code 错误码
 *  @param msg  错误的提示或描述
 *
 *  @return NSError 实例
 */
+ (NSError*)errorWithCode:(NSInteger )code msg:(NSString *)msg;


@end




