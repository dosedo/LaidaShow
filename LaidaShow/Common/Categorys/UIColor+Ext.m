//
//  UIColor+Ext.m
//  Hitu
//
//  Created by hitomedia on 16/6/21.
//  Copyright © 2016年 hitomedia. All rights reserved.
//

#import "UIColor+Ext.h"

@implementation UIColor (Ext)


//颜色转图片
UIKIT_EXTERN UIImage * __nullable UIColorAsImage(UIColor * __nonnull color, CGSize size) {
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIColor*)pColorWithR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b{
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
}

+ (UIColor *)colorWithR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b{
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
}

+ (UIColor *)colorWithRgb_4_128_195{
    return [UIColor pColorWithR:4 G:128 B:195];
}

+ (UIColor *)colorWithRgb_24_148_209{
//    return [UIColor pColorWithR:238 G:134 B:53];
    return [UIColor pColorWithR:24 G:148 B:209];
}

+ (UIColor*)colorWithRgb221{
    return [UIColor pColorWithR:221 G:221 B:221];
}

+ (UIColor*)colorWithRgb_155_155_163{
    return [UIColor pColorWithR:155 G:155 B:163];
}

+ (UIColor*)colorWithRgb_240_239_244{
    return [UIColor pColorWithR:240 G:239 B:244];
}

+ (UIColor *)colorWithRgb51{
    return [UIColor pColorWithR:51 G:51 B:51];
}

+ (UIColor *)colorWithRgb85{
    return [UIColor pColorWithR:85 G:85 B:85];
}

+ (UIColor *)colorWithRgb68{
    return [UIColor pColorWithR:68 G:68 B:68];
}

+ (UIColor*)colorWithRgb102{
    return [UIColor pColorWithR:102 G:102 B:102];
}

+ (UIColor*)colorWithRgb_250_100_92{
    return [UIColor pColorWithR:250 G:100 B:92];
}

+ (UIColor *)colorWithRgb153{
    return [UIColor pColorWithR:153 G:153 B:153];
}

+ (UIColor *)colorWithRgb_36_149_207{
    return [UIColor pColorWithR:36 G:149 B:207];
}

+(UIColor*)silverColor{
    return [UIColor pColorWithR:227 G:228 B:230];
}

+ (UIColor *)pinkishGreyColor{
    return [UIColor pColorWithR:204 G:204 B:204];
}

+ (UIColor*)colorWithRgb84_97_105{
    return [UIColor pColorWithR:84 G:97 B:105];
}

+ (UIColor*)colorWithRgb255_248_224{
    return [UIColor pColorWithR:255 G:248 B:224];
}


+ (UIColor*)colorWithRgb251_66_56{
    return [UIColor pColorWithR:251 G:66 B:56];
}

+ (UIColor*)colorWithRgb34{
    return [UIColor pColorWithR:34 G:34 B:34];
}

+ (UIColor*)colorWithRgb170{
    return [UIColor pColorWithR:170 G:170 B:170];
}

+ (UIColor *)colorWithRgb238{
    return [UIColor pColorWithR:238 G:238 B:238];
}

+ (UIColor *)colorWithRgb245{
    return [UIColor pColorWithR:245 G:245 B:245];
}

+ (UIColor *)colorWithRgb153_217_255{
    return [UIColor pColorWithR:153 G:217 B:255];
}

+ (UIColor*)colorWithRgb250_202_121{
    return [UIColor pColorWithR:250 G:202 B:121];
}

+ (UIColor*)colorWithRgb253_151_146{
    return [UIColor pColorWithR:253 G:151 B:146];
}

+ (UIColor*)colorWithRgb_214_213_215{
    return [UIColor pColorWithR:214 G:213 B:215];
}

+ (UIColor*)colorWithRgb_243_152_0{
    return [UIColor pColorWithR:243 G:152 B:0];
}

+ (UIColor*)colorWithRgb_70_169_218{//旅途中
    return [UIColor pColorWithR:70 G:169 B:218];
}

+ (UIColor*)colorWithRgb_70_187_241{//tabbar
    return [UIColor pColorWithR:70 G:169 B:218];
}

+ (UIColor*)colorWithRgb_92_191_185{//3小时40分钟后出发
    return [UIColor pColorWithR:92 G:191 B:185];
}

+ (UIColor*)colorWithRgb_251_131_125{//晚点，检票
    return [UIColor pColorWithR:251 G:131 B:125];
}

+ (UIColor*)colorWithRgb_101_186_127{//添加乘客
    return [UIColor pColorWithR:101 G:186 B:127];
}

+ (UIColor*)colorWithRgb_248_101_96{//
    return [UIColor pColorWithR:248 G:101 B:96];
}

+ (UIColor*)colorWithRgb_246_253_245{//
    return [UIColor pColorWithR:246 G:253 B:245];
}

+ (UIColor *)colorWithRgb_245_250_216{
    return [UIColor colorWithRed:254/255.0 green:250/255.0 blue:216/255.0 alpha:1.0];
}

+ (UIColor*)colorWithRgb_62_79_88{
    return [UIColor pColorWithR:62 G:79 B:88];
}

+ (UIColor *)colorWithRgb_42_197_90{
    return [UIColor pColorWithR:41 G:197 B:90];
}

#pragma mark - ThreeShow

- (nullable UIImage *)imageWithSize:(CGSize)size {

    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,self.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


//蓝色
+ (UIColor*)colorWithRgb_0_151_216{
    return [UIColor pColorWithR:238 G:134 B:53];
    return [UIColor pColorWithR:0 G:151 B:216];
}

+ (UIColor *)colorWithRgb251_10_10{
     return [UIColor pColorWithR:251 G:10 B:10];
}

+ (UIColor *)colorWithRgb252_199_17{
    return [UIColor colorWithR:252 G:199 B:17];
}

+ (UIColor*)colorWithRgb_20_150_216{
    return [UIColor pColorWithR:20 G:150 B:216];
}



@end
