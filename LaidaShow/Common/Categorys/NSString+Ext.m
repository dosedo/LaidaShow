//
//  NSString+Ext.m
//  Hitu
//
//  Created by hitomedia on 16/8/15.
//  Copyright © 2016年 hitomedia. All rights reserved.
//

#import "NSString+Ext.h"
#import<CommonCrypto/CommonDigest.h>

@implementation NSString (Ext)

+(NSString*)stringWithObj:(NSObject*)obj{

    if( [obj isKindOfClass:[NSNumber class]] ){
        return ((NSNumber*)obj).stringValue;
    }
    else if( [obj isKindOfClass:[NSString class]] ){
        NSString *str = (NSString*)obj;
        if( [str isEqualToString:@"null"] ||
            [str isEqualToString:@"(null)"] ||
            str.length == 0){
            return nil;
        }
        return (NSString*)obj;
    }
    
    return nil;
}

+ (NSString *)stringWithDate:(NSDate *)date format:(NSString *)format{
    if( date ==nil || format ==nil || ![date isKindOfClass:[NSDate class]] || ![format isKindOfClass:[NSString class]] ){
        return nil;
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:format];
//    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
//    [df setLocale:usLocale];
    return [df stringFromDate:date];
}

+ (NSString *)stringOfFormatTimeWithDate:(NSDate *)date{
    return nil;
}

+ (NSString *)stringWithDateStr:(NSString *)dateStr orginFormat:(NSString *)oformat desFormat:(NSString *)dFormat {
    if( dateStr ==nil || oformat ==nil || dFormat ==nil || ![dateStr isKindOfClass:[NSString class]] || ![oformat isKindOfClass:[NSString class]] || ![dFormat isKindOfClass:[NSString class]] ){
        return nil;
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:oformat];
    NSDate *dt = [df dateFromString:dateStr];
    [df setDateFormat:dFormat];
    return [df stringFromDate:dt];
}

+ (NSString *)stringWeekWithDate:(NSDate *)date {
    
    //获取今天星期几
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitWeekday;
    comps = [calendar components:unitFlags fromDate:date];
    //    NSLog(@"-----------weekday is %d",[comps weekday]);//在这里需要注意的是：星期日是数字1，星期一时数字2，以此类推。。。
    NSArray *wStr = @[@"日",@"一", @"二", @"三", @"四", @"五", @"六"];
    NSString *weekdayStr = @"";
    if( wStr.count > ([comps weekday]-1) ){
        weekdayStr = [NSString stringWithFormat:@"周%@",wStr[[comps weekday]-1]];
    }
    return weekdayStr;
}

+ (NSString *)stringSecurePhoneNum:(NSString *)phoneNum{
    if( [phoneNum isKindOfClass:[NSString class]] ){
        if( phoneNum.length == 11 ){
           return [phoneNum stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
        }
    }
    return nil;
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

- (NSString *)filterOutSpace{
    NSString * headerData = self;
    headerData = [headerData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去除掉首尾的空白字符和换行字符
    headerData = [headerData stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
    headerData = [headerData stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    return headerData;
}
//- (NSString *) md5
//{
//    const char *cStr = [self UTF8String];
//    unsigned char result[16];
//    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
//    NSMutableString *hash =[NSMutableString string];
//    for (int i = 0; i < 16; i++)
//        [hash appendFormat:@"%02X", result[i]];
//    return [hash uppercaseString];
//}

-(NSString *)md5{
    NSString *str = self;
    const char *cStr = [str UTF8String];//转换成utf-8
    unsigned char result[16];//开辟一个16字节（128位：md5加密出来就是128位/bit）的空间（一个字节=8字位=8个二进制数）
    CC_MD5( cStr, strlen(cStr), result);
    /*
     extern unsigned char *CC_MD5(const void *data, CC_LONG len, unsigned char *md)官方封装好的加密方法
     把cStr字符串转换成了32位的16进制数列（这个过程不可逆转） 存储到了result这个空间中
     */
    NSString *md5Str = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
    
    return [md5Str lowercaseString];
    /*
     x表示十六进制，%02X  意思是不足两位将用0补齐，如果多余两位则不影响
     NSLog("%02X", 0x888);  //888
     NSLog("%02X", 0x4); //04
     */
}

#pragma mark - number

-(float)roundFloat:(float)price{
    NSString *temp = [NSString stringWithFormat:@"%.7f",price];
    NSDecimalNumber *numResult = [NSDecimalNumber decimalNumberWithString:temp];
    NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler
                                       decimalNumberHandlerWithRoundingMode:NSRoundBankers
                                       scale:2
                                       raiseOnExactness:NO
                                       raiseOnOverflow:NO
                                       raiseOnUnderflow:NO
                                       raiseOnDivideByZero:YES];
    return [[numResult decimalNumberByRoundingAccordingToBehavior:roundUp] floatValue];
}
#pragma mark - 统计字符长度。中文算一个，2个英文算一个
+  (int)convertToInt:(NSString*)strtemp {
    
    if(strtemp==nil || [strtemp isEqualToString:@""] ) return 0;
    
    int strlength = 0;
    // 这里一定要使用gbk的编码方式，网上有很多用Unicode的，但是混合的时候都不行
    NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    char* p = (char*)[strtemp cStringUsingEncoding:gbkEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:gbkEncoding] ;i++) {
        if (p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    strlength =
    strlength / 2 + (strlength%2?1:0); //2个字符算一个
    
    return strlength;
}

#pragma mark - 隐藏部分字符，保留首尾2个字符。最大用4个星号代替
- (NSString*)hideSectionChar{
    if( self.length > 3 ){
        return
        [self stringByReplacingCharactersInRange:NSMakeRange(1, self.length-2) withString:@"****"];
    }else{
        return @"****";
    }
}

#pragma mark - Formattime
//今日：时分  非今日:月日 非今年 年月日
#pragma mark - 空判断
//是否是无效字符串
+ (BOOL) isEmpty:(NSString *) str {
    
    if (!str || [str isKindOfClass:[NSString class]] ==NO || str.length==0) {
        
        return true;
        
    } else {
        
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
        
        if ([trimedString length] == 0) {
            
            return true;
            
        } else {
            
            return false;
            
        }
        
    }
    
}

#pragma mark - 获取devicetoken
+ (NSString*)deviceTokenWithData:(NSData *)deviceToken{
    if( [deviceToken isKindOfClass:[NSData class]] ==NO ) return nil;
    
    NSMutableString *tokenAsString = [[NSMutableString alloc]
                                      initWithCapacity:deviceToken.length * 2];
    char *bytes = (char*)malloc(deviceToken.length);
    [deviceToken getBytes:bytes length:deviceToken.length];
    for (NSUInteger byteCounter = 0; byteCounter < deviceToken.length; byteCounter++){
        char byte = bytes[byteCounter];
        [tokenAsString appendFormat:@"%02hhX", byte];
    }
    free(bytes);
    
    return tokenAsString;
}

#pragma mark - Call Phone

+ (void)callPhoneStr:(NSString*)phoneStr  withVC:(UIViewController *)selfvc{
    if (phoneStr.length >= 8) {
        NSString *str2 = [[UIDevice currentDevice] systemVersion];
        if ([str2 compare:@"10.2" options:NSNumericSearch] == NSOrderedDescending || [str2 compare:@"10.2" options:NSNumericSearch] == NSOrderedSame)
        {
            NSString* PhoneStr = [NSString stringWithFormat:@"telprompt://%@",phoneStr];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:PhoneStr] options:@{} completionHandler:^(BOOL success) {
                NSLog(@"phone success");
            }];
            
        }else {
            NSMutableString* str1 = [[NSMutableString alloc]initWithString:phoneStr];// 存在堆区，可变字符串
            if (phoneStr.length == 10) {
                [str1 insertString:@"-"atIndex:3];// 把一个字符串插入另一个字符串中的某一个位置
                [str1 insertString:@"-"atIndex:7];// 把一个字符串插入另一个字符串中的某一个位置
            }else {
                [str1 insertString:@"-"atIndex:3];// 把一个字符串插入另一个字符串中的某一个位置
                [str1 insertString:@"-"atIndex:8];// 把一个字符串插入另一个字符串中的某一个位置
            }
            NSString * str = [NSString stringWithFormat:@"是否拨打电话\n%@",str1];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:str message: nil preferredStyle:UIAlertControllerStyleAlert];
            // 设置popover指向的item
            alert.popoverPresentationController.barButtonItem = selfvc.navigationItem.leftBarButtonItem;
            // 添加按钮
            [alert addAction:[UIAlertAction actionWithTitle:@"呼叫" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                NSLog(@"点击了呼叫按钮10.2下");
                NSString* PhoneStr = [NSString stringWithFormat:@"tel://%@",phoneStr];
                if ([PhoneStr hasPrefix:@"sms:"] || [PhoneStr hasPrefix:@"tel:"]) {
                    UIApplication * app = [UIApplication sharedApplication];
                    if ([app canOpenURL:[NSURL URLWithString:PhoneStr]]) {
                        [app openURL:[NSURL URLWithString:PhoneStr]];
                    }
                }
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                NSLog(@"点击了取消按钮");
            }]];
            [selfvc presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (NSString *)encodeToPercentEscapeString: (NSString *) input
{
    // Encode all the reserved characters, per RFC 3986
    // (<http://www.ietf.org/rfc/rfc3986.txt>)
    NSString *outputStr = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)input,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    return outputStr;
}

- (NSString *)decodeFromPercentEscapeString: (NSString *) input
{
    NSMutableString *outputStr = [NSMutableString stringWithString:input];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@" "
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [outputStr length])];
    
    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - base64

+(NSString *)stringOfBase64WithData:(NSData *)data
{
    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return encodedImageStr;
}

//字符串转图片
+(NSData *)base64StrToData:(NSString *)encodeStr
{
    NSData *data   = [[NSData alloc] initWithBase64EncodedString:encodeStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    return data;
}

#pragma mark - emoji转义
+ (NSString *)emojiEncoding:(NSString *)string
{
    NSString *tempStr1 = [string stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
    NSString *tempStr3 = [[@"\""stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *returnStr = [NSPropertyListSerialization propertyListWithData:tempData options:(NSPropertyListImmutable) format:NULL error:NULL];
//    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
//                                                           mutabilityOption:NSPropertyListImmutable
//                                                                     format:NULL
//                                                           errorDescription:NULL];
    
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
}

+ (NSString *)emojiDecoding:(NSString *)string
{
    if ([NSString stringWithObj:string]==NO )
    {
        return string;
    }
    //正则表达式
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\ud83c\\udd23-\\ud83e\\udfff]|[\\ud83d\\udd23-\\ud83e\\udfff]|[\\u2600-\\u27ff]" options:0 error:nil];
    //筛选出匹配的字段
    NSMutableArray *matches = [[NSMutableArray alloc] initWithArray:[regex matchesInString:string options:0 range:NSMakeRange(0, string.length)]];
    
    NSMutableString *resultStr = string.mutableCopy;
    for (int i = (int)matches.count; i > 0; i--)
    {
        NSTextCheckingResult *result = matches[i-1];
        NSRange matchRange = [result range];
        NSString *emoji = [resultStr substringWithRange:matchRange];
        NSString *uniStr = [NSString stringWithUTF8String:[emoji UTF8String]];
        NSData *uniData = [uniStr dataUsingEncoding:NSNonLossyASCIIStringEncoding];
        [resultStr replaceCharactersInRange:matchRange withString:[[NSString alloc] initWithData:uniData encoding:NSUTF8StringEncoding]];
    }
    
    return resultStr;
}

#pragma mark - 富文本转义HTML
/** 富文本NSAtrributeString格式转换为超文本HTML格式*/
- (NSString *)htmlStringByAttributeString:(NSAttributedString *)htmlAttributeString {
    NSString *htmlString;
    NSDictionary *exportParams = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                   NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]
                                   };
    NSData *htmlData = [htmlAttributeString dataFromRange:NSMakeRange(0, htmlAttributeString.length) documentAttributes:exportParams error:nil];
    htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    return htmlString;
}

/** 超文本HTML格式转换为富文本AtrributeString格式*/
- (NSAttributedString *)attributeStringByHtmlString:(NSString *)htmlString {
    NSAttributedString *attributeString;
    NSData *htmlData = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *importParams = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                   NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]
                                   };
    NSError *error = nil;
    attributeString = [[NSAttributedString alloc] initWithData:htmlData options:importParams documentAttributes:NULL error:&error];
    return attributeString;
}

#pragma mark - 多语言判断
//我设置的时英语，所以第一个元素就是en，其中zh-Hans是简体中文，zh-Hant是繁体中文。。
+ (NSString*)getPreferredLanguage
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
    
    NSString * preferredLang = [allLanguages objectAtIndex:0];
    
    NSLog(@"当前语言:%@", preferredLang);
    
    return preferredLang;
}

#pragma mark - Private

+ (NSDate *)getDateWithString:(NSString *)str format:(NSString *)format{
    if( str ==nil || format ==nil || ![str isKindOfClass:[NSString class]] || ![format isKindOfClass:[NSString class]] ){
        return nil;
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:format];
    return [df dateFromString:str];
}


@end
