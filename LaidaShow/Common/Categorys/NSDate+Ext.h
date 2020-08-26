//
//  NSDate+Ext.h
//  Hitu
//
//  Created by hitomedia on 16/7/28.
//  Copyright © 2016年 hitomedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Ext)

+ (NSDate*)dateByAddDays:(NSInteger)days toDate:(NSDate*)date;

+ (NSDate*)dateWithString:(NSString*)str format:(NSString*)format;

+ (NSString*)formatTimeWithTimeStr:(NSString*)str format:(NSString*)format;

////今日：时分  非今日:月日 非今年 年月日
- (NSString*)formatDateStr;

/**
 *  是否为今天
 */
- (BOOL)isToday;
/**
 *  是否为昨天
 */
- (BOOL)isYesterday;
/**
 *  是否为今年
 */
- (BOOL)isThisYear;

/**
 *  返回一个只有年月日的时间
 */
- (NSDate *)dateWithYMD;

/**
 *  获得与当前时间的差距
 */
- (NSDateComponents *)deltaWithNow;

//返回： 今天 18:04, 昨天 20:09, 11-15 9:08, 2001-09-23 21:07,
- (NSString*)formatTime;

//返回： 今天, 昨天, 11-15, 2001-09-23,
- (NSString*)formatQuestionAnswerTime;


/**
 格式化日期。1分内为刚刚，几分前，几小时前，几天前，几月前，几年前

 @return 时间字符串
 */
- (NSString*)formatDateBeforeHourDayMonthYear;

@end
