//
//  NSDate+Ext.m
//  Hitu
//
//  Created by hitomedia on 16/7/28.
//  Copyright © 2016年 hitomedia. All rights reserved.
//

#import "NSDate+Ext.h"

@implementation NSDate (Ext)

+ (NSDate*)dateByAddDays:(NSInteger)days toDate:(NSDate*)date{
    if( date == nil )
        return nil;
    NSDate *newDate = [date dateByAddingTimeInterval:60 * 60 * 24 * days];
    
    return newDate;
}

+ (NSDate *)dateWithString:(NSString *)str format:(NSString *)format{
    if( str ==nil || format ==nil || ![str isKindOfClass:[NSString class]] || ![format isKindOfClass:[NSString class]] ){
        return nil;
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:format];
    return [df dateFromString:str];
}

+ (NSString *)formatTimeWithTimeStr:(NSString *)str format:(NSString *)format{
    NSDate *date = [NSDate dateWithString:str format:format];
    return [date formatTime];
}

- (NSString*)formatDateStr{

    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    if( [self isToday] ){
        fmt.dateFormat = @"HH:mm";
        NSString *selfStr = [fmt stringFromDate:self];
        return selfStr;//[NSString stringWithFormat:@"今天 %@",selfStr];
    }
    else if( [self isThisYear ]  ){
        fmt.dateFormat = @"MM-dd";
        NSString *selfStr = [fmt stringFromDate:self];
        return selfStr;
    }
    else{
        fmt.dateFormat = @"yyyy-MM-dd";
        NSString *selfStr = [fmt stringFromDate:self];
        return selfStr;
    }
}

/**
 *  是否为今天
 */
- (BOOL)isToday
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear;
    
    // 1.获得当前时间的年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    // 2.获得self的年月日
    NSDateComponents *selfCmps = [calendar components:unit fromDate:self];
    return
    (selfCmps.year == nowCmps.year) &&
    (selfCmps.month == nowCmps.month) &&
    (selfCmps.day == nowCmps.day);
}

/**
 *  是否为昨天
 */
- (BOOL)isYesterday
{
    // 2014-05-01
    NSDate *nowDate = [[NSDate date] dateWithYMD];
    
    // 2014-04-30
    NSDate *selfDate = [self dateWithYMD];
    
    // 获得nowDate和selfDate的差距
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *cmps = [calendar components:NSCalendarUnitDay fromDate:selfDate toDate:nowDate options:0];
    return cmps.day == 1;
}

/**
 *  是否为今年
 */
- (BOOL)isThisYear
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitYear;
    
    // 1.获得当前时间的年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    // 2.获得self的年月日
    NSDateComponents *selfCmps = [calendar components:unit fromDate:self];
    
    return nowCmps.year == selfCmps.year;
}

/**
 *  返回一个只有年月日的时间
 */
- (NSDate *)dateWithYMD
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    NSString *selfStr = [fmt stringFromDate:self];
    return [fmt dateFromString:selfStr];
}

/**
 *  获得与当前时间的差距
 */
- (NSDateComponents *)deltaWithNow
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    return [calendar components:unit fromDate:self toDate:[NSDate date] options:0];
}

- (NSString *)formatTime{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    if( [self isToday] ){
        fmt.dateFormat = @"HH:mm";
        NSString *selfStr = [fmt stringFromDate:self];
        return [NSString stringWithFormat:@"今天 %@",selfStr];
    }
    else if( [self isYesterday ] ){
        fmt.dateFormat = @"HH:mm";
        NSString *selfStr = [fmt stringFromDate:self];
        return [NSString stringWithFormat:@"昨天 %@",selfStr];
    }
    else if( [self isThisYear ] ){
        fmt.dateFormat = @"MM-dd HH:mm";
        NSString *selfStr = [fmt stringFromDate:self];
        return selfStr;
    }
    else{
        fmt.dateFormat = @"yyyy-MM-dd";
        NSString *selfStr = [fmt stringFromDate:self];
        return selfStr;
    }
}

- (NSString *)formatQuestionAnswerTime{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    if( [self isToday] ){
        
        fmt.dateFormat = @"HH:mm";
        NSString *selfStr = [fmt stringFromDate:self];
        return selfStr;
    }
    else if( [self isYesterday ] ){
        
        fmt.dateFormat = @"MM-dd";
        NSString *selfStr = [fmt stringFromDate:self];
        return selfStr;
    }
    else if( [self isThisYear ] ){
        fmt.dateFormat = @"MM-dd";
        NSString *selfStr = [fmt stringFromDate:self];
        return selfStr;
    }
    else{
        fmt.dateFormat = @"yyyy-MM-dd";
        NSString *selfStr = [fmt stringFromDate:self];
        return selfStr;
    }
}

- (NSString *)formatDateBeforeHourDayMonthYear{
    NSTimeInterval ti = [self timeIntervalSinceNow];
    
    //一分钟
    NSInteger secondOfMin = 60;
    
    //一小时的秒数
    NSInteger secondOfHour = 60*secondOfMin;
    
    //一天的秒数
    NSInteger secondOfDay = 24*secondOfHour;
    
    //一周的秒
    NSInteger secondOfWeek = 7*secondOfDay;
    
    //一个月的秒数
    NSInteger secondOfMonth = 30 *secondOfDay;
    
    //一年的秒
    NSInteger secondOfYear = 366*secondOfMonth;
    
    long seconds = (long)(-ti);
    
    NSInteger years = seconds/secondOfYear;
    if( years > 1 ) {
        return [NSString stringWithFormat:@"%ld年前",years];
    }
    
    NSInteger months = seconds/secondOfMonth;
    if( months > 1 ){
        return [NSString stringWithFormat:@"%ld月前",months];
    }
    
    NSInteger weeks = seconds/secondOfWeek;
    if( weeks > 1 ){
        return [NSString stringWithFormat:@"%ld周前",weeks];
    }
    
    NSInteger days = seconds/secondOfDay;
    if( days > 1 ){
        return [NSString stringWithFormat:@"%ld天前",days];
    }
    
    NSInteger hours = seconds/secondOfHour;
    if( hours > 1 ){
        return [NSString stringWithFormat:@"%ld小时前",hours];
    }
    
    NSInteger mins = seconds/secondOfMin;
    if( mins > 1 ){
        return [NSString stringWithFormat:@"%ld分钟前",mins];
    }else{
        return @"刚刚";
    }
    
    return @"";
}

@end
