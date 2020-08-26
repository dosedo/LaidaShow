//
//  KValiData.m
//  HopeHelpClient
//
//  Created by 端倪 on 16/2/3.
//  Copyright © 2016年 deepai. All rights reserved.
//

#import "KValiData.h"
/**
 *  验证数据类
 */
@implementation KValiData

+(KValiData*)shardValiData{
    static KValiData *vd = nil;
    static dispatch_once_t preciate;
    dispatch_once(&preciate, ^{
        vd = [[KValiData alloc] init];
    });
    return vd;
}

-(BOOL)validateString:(NSString *)string minLength:(NSUInteger)minLen maxLength:(NSInteger)maxLen{
    if( string == nil ) return NO;
    
    if( string.length < minLen || string.length > maxLen )
        return NO;
    return YES;
}

-(BOOL)validateString:(NSString *)string{
    return !(string==nil || [string isEqualToString:@""] );
}

-(BOOL)validateAString:(NSString *)aString equalBString:(NSString *)bString minLength:(NSInteger)minLen maxLength:(NSInteger)maxLen{
    BOOL a = [self validateString:aString minLength:minLen maxLength:maxLen];
    BOOL b = [self validateString:bString minLength:minLen maxLength:maxLen];
    if( a && b && [aString isEqualToString:bString] )
        return YES;
    return NO;
}

-(BOOL)valildatePhone:(NSString *)phone{
    //手机号以13，15，16,17,18,19开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(16[0-9])|(17[0-9])|(19[0-9])|(18[0,0-9]))\\d{8}$";
//    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(17[0-9])|(18[0,0-9]))\\d{8}$";

    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:phone];
}

-(BOOL)validateEmail:(NSString*)email{
//    NSString *emailRegex = @"^[a-z0-9]+([._\\-]*[a-z0-9])*@([a-z0-9]+[-a-z0-9]*[a-z0-9]+.){1,63}[a-z0-9]+$";
//    NSPredicate *emailText = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
//    return [emailText evaluateWithObject:emailText];
    NSString *emailCheck = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailCheck];
    
    return [emailTest evaluateWithObject:email];
}

- (BOOL)valildateIdCard:(NSString *)idCard{

    if( idCard && idCard.length == 18 ){
        return YES;
    }
    
    return NO;
//    NSString *idCardRegex = @"";
//    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",idCardRegex];
//    return [phoneTest evaluateWithObject:idCard];
    
}
- (BOOL)valildateBandCard:(NSString *)bandCard{
    if (!bandCard.length)
        return NO;
    int oddsum = 0;     //奇数求和
    int evensum = 0;    //偶数求和
    int allsum = 0;
    int cardNoLength = (int)[bandCard length];
    int lastNum = [[bandCard substringFromIndex:cardNoLength-1] intValue];
    
    bandCard = [bandCard substringToIndex:cardNoLength - 1];
    for (int i = cardNoLength -1 ; i>=1;i--) {
        NSString *tmpString = [bandCard substringWithRange:NSMakeRange(i-1, 1)];
        int tmpVal = [tmpString intValue];
        if (cardNoLength % 2 ==1 ) {
            if((i % 2) == 0){
                tmpVal *= 2;
                if(tmpVal>=10)
                    tmpVal -= 9;
                evensum += tmpVal;
            }else{
                oddsum += tmpVal;
            }
        }else{
            if((i % 2) == 1){
                tmpVal *= 2;
                if(tmpVal>=10)
                    tmpVal -= 9;
                evensum += tmpVal;
            }else{
                oddsum += tmpVal;
            }
        }
    }
    
    allsum = oddsum + evensum;
    allsum += lastNum;
    if((allsum % 10) == 0)
        return YES;
    else
        return NO;
}
-(BOOL)validateDigital:(NSString*)digital length:(NSUInteger)length{
    NSString *digi = [NSString stringWithFormat:@"^\\d{%ld}$",length ];
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",digi];
    return [phoneTest evaluateWithObject:digital];
}

@end
