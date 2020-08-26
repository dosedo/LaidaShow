//
//  NSDictionary+Ext.m
//  Hitu
//
//  Created by hitomedia on 2016/11/15.
//  Copyright © 2016年 hitomedia. All rights reserved.
//

#import "NSDictionary+Ext.h"

@implementation NSDictionary (Ext)
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+ (NSString*)convertToJSONData:(id)infoDict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    NSString *jsonString = @"";
    
    if (! jsonData)
    {
        NSLog(@"Got an error: %@", error);
    }else
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    
    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return jsonString;
}

+ (NSDictionary *)dictionaryWithKeys:(NSArray<NSString *> *)keys values:(NSString *)values, ...{
    
    NSLog(@"传多个参数的第一个参数 %@",values);//是other1
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    //1.定义一个指向个数可变的参数列表指针；
    va_list args;
    
    //2.va_start(args, str);string为第一个参数，也就是最右边的已知参数,这里就是获取第一个可选参数的地址.使参数列表指针指向函数参数列表中的第一个可选参数，函数参数列表中参数在内存中的顺序与函数声明时的顺序是一致的。
    va_start(args, values);
    
//    if (values)
    {
        NSUInteger i=0;
        if( keys.count > i ){
            NSString *key = keys[i];
            if( [key isKindOfClass:[NSString class]]  && ([values isKindOfClass:[NSString class]] && [values isEqualToString:@""]==NO) ){
                dic[key]=values;
            }
        }
        //依次取得除第一个参数以外的参数
        //4.va_arg(args,NSString)：返回参数列表中指针所指的参数，返回类型为NSString，并使参数指针指向参数列表中下一个参数。
        i=1;
        NSString *ots = nil;
//        while ((ots = va_arg(args, NSString *)))
        for( NSInteger j=1; j<keys.count; j++)
        {
            ots = va_arg(args, NSString *);
//            if( ots == nil ){
//                i++;
//                continue;
//            }
            NSString *otherString = ots;//va_arg(args, NSString *);
            NSLog(@"otherString %@",otherString);
            
            if( [otherString isKindOfClass:[NSObject class]] ){
                
                BOOL nullStr = ([otherString isKindOfClass:[NSString class]] && [otherString isEqualToString:@""]);
                if( !nullStr ){
                    if( keys.count > i ){
                        NSString *key = keys[i];
                        if( [key isKindOfClass:[NSString class]] ){
                            dic[key]= otherString;
                        }
                    }
                }
            }
            
//            if( ([otherString isKindOfClass:[NSString class]] && [otherString isEqualToString:@""]==NO) || [otherString isKindOfClass:[NSNumber class]] ){
//                if( keys.count > i ){
//                    NSString *key = keys[i];
//                    if( [key isKindOfClass:[NSString class]] ){
//                        dic[key]= otherString;
//                    }
//                }
//            }
            
            i++;
        }
    }
    //5.清空参数列表，并置参数指针args无效。
    va_end(args);
    
    if( [[dic objectEnumerator] allObjects].count == 0 ){
        return nil;
    }
    
    return dic;
}

- (void)testParams:(NSString *)title addMoreParams:(NSString *)string, ...NS_REQUIRES_NIL_TERMINATION {
    
    NSLog(@"传多个参数的第一个参数 %@",string);//是other1
    
    //1.定义一个指向个数可变的参数列表指针；
    va_list args;
    
    //2.va_start(args, str);string为第一个参数，也就是最右边的已知参数,这里就是获取第一个可选参数的地址.使参数列表指针指向函数参数列表中的第一个可选参数，函数参数列表中参数在内存中的顺序与函数声明时的顺序是一致的。
    va_start(args, string);
    
    if (string)
    {
        //依次取得除第一个参数以外的参数
        //4.va_arg(args,NSString)：返回参数列表中指针所指的参数，返回类型为NSString，并使参数指针指向参数列表中下一个参数。
        NSString *ots = nil;
        while ((ots = va_arg(args, NSString *)))
        {
            NSString *otherString = ots;
            NSLog(@"otherString %@",otherString);
        }
    }
    //5.清空参数列表，并置参数指针args无效。
    va_end(args);
    
}

@end
