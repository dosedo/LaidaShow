//
//  NSString+Ext.h
//  Hitu
//
//  Created by hitomedia on 16/8/15.
//  Copyright © 2016年 hitomedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Ext)

+ (NSString*)stringWithObj:(NSObject*)obj;

+ (NSString*)stringWithDateStr:(NSString*)dateStr orginFormat:(NSString*)oformat desFormat:(NSString*)dFormat;
+ (NSString*)stringWithDate:(NSDate*)date format:(NSString*)format;

/**
 得到格式化后的时间。

 @param  时间：如2017-11-16 14:25:28.0 。格式必须如此
 @return 如：今天 15:08 , 11-17 16:18 , 2016-11-18 19:22
 */
+ (NSString*)stringOfFormatTimeWithDate:(NSDate*)date;

/**
 *  获取某日期是星期几
 *
 *  @param date 待查询的日期
 *
 *  @return 星期几。如星期一
 */
+ (NSString*)stringWeekWithDate:(NSDate*)date;

//对电话号码中间打星号
+ (NSString*)stringSecurePhoneNum:(NSString*)phoneNum;

//nsdictionnary 转nsstring
+ (NSString*)convertToJSONData:(id)infoDict;


/**
 过滤掉首尾和中间的空格

 @return <#return value description#>
 */
- (NSString*)filterOutSpace;

- (NSString *) md5;


+ (void)callPhoneStr:(NSString*)phoneStr  withVC:(UIViewController *)selfvc;

- (NSString *)encodeToPercentEscapeString: (NSString *) input;

- (NSString *)decodeFromPercentEscapeString: (NSString *) input;

#pragma mark - base64

+(NSString *)stringOfBase64WithData:(NSData *)data;
//字符串转图片
+(NSData *)base64StrToData:(NSString *)encodeStr;

#pragma mark - nunumber //保留两位小数 四舍五入
-(float)roundFloat:(float)price;

#pragma mark - 统计字符长度。中文算一个，2个英文算一个
+ (int)convertToInt:(NSString*)strtemp;

#pragma mark - 隐藏部分字符，保留首尾2个字符。最大用4个星号代替
- (NSString*)hideSectionChar;

#pragma mark - Formattime
//今日：时分  非今日:月日 非今年 年月日
//- (NSString*)formatDate:(NSDate*)date;

#pragma mark - 空判断
+ (BOOL) isEmpty:(NSString *) str;

#pragma mark - 获取DeviceToken字符串
+ (NSString*)deviceTokenWithData:(NSData*)data;

#pragma mark - emoji转义
+ (NSString *)emojiEncoding:(NSString *)string;

+ (NSString *)emojiDecoding:(NSString *)string;

#pragma mark - 富文本转义
- (NSString *)htmlStringByAttributeString:(NSAttributedString *)htmlAttributeString ;
/** 超文本HTML格式转换为富文本AtrributeString格式*/
- (NSAttributedString *)attributeStringByHtmlString:(NSString *)htmlString;

#pragma mark - 多语言判断
//我设置的时英语，所以第一个元素就是en，其中zh-Hans是简体中文，zh-Hant是繁体中文。。
+ (NSString*)getPreferredLanguage;
@end

