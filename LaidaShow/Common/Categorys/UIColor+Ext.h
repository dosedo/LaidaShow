//
//  UIColor+Ext.h
//  Hitu
//
//  Created by hitomedia on 16/6/21.
//  Copyright © 2016年 hitomedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Ext)

//颜色转图片
UIKIT_EXTERN UIImage * __nullable UIColorAsImage(UIColor * __nonnull color, CGSize size);

+ (UIColor *)colorWithR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b;


/**
 *  导航栏背景色
 *
 *  @return
 */
+ (UIColor*)colorWithRgb_4_128_195;

/**
 *  Tabbar item选中时，标题颜色
 *
 *  @return
 */
+ (UIColor*)colorWithRgb_24_148_209;

/**
 *  Tabbar 当选中第一个item时，各标题的颜色
 *
 *  @return 
 */
+ (UIColor*)colorWithRgb221;

/**
 *  tabbar item未选中时，标题颜色
 *
 *  @return
 */
+ (UIColor*)colorWithRgb_155_155_163;

/**
 *  背景色
 *
 *  @return 
 */
+ (UIColor*)colorWithRgb_240_239_244;

+ (UIColor*)colorWithRgb51;

+ (UIColor *)colorWithRgb238;

+ (UIColor *)colorWithRgb245;

+ (UIColor*)colorWithRgb85;

+ (UIColor *)colorWithRgb68;

+ (UIColor*)colorWithRgb102;

+ (UIColor*)colorWithRgb_250_100_92;

+ (UIColor*)colorWithRgb153;

/**
 *  按钮背景蓝
 *
 *  @return 
 */
+ (UIColor *)colorWithRgb_36_149_207;

+(UIColor*)silverColor;

+ (UIColor *)pinkishGreyColor;

+ (UIColor*)colorWithRgb84_97_105;

+ (UIColor*)colorWithRgb255_248_224;

+ (UIColor*)colorWithRgb251_66_56;

+ (UIColor*)colorWithRgb34;

+ (UIColor*)colorWithRgb170;

+ (UIColor*)colorWithRgb153_217_255;

+ (UIColor*)colorWithRgb250_202_121;

+ (UIColor*)colorWithRgb253_151_146;

+ (UIColor*)colorWithRgb_214_213_215;

+ (UIColor*)colorWithRgb_243_152_0;

+ (UIColor*)colorWithRgb_70_169_218;

/**
 tabar文本的蓝色

 @return 蓝色
 */
+ (UIColor*)colorWithRgb_70_187_241;

+ (UIColor*)colorWithRgb_92_191_185;

+ (UIColor*)colorWithRgb_251_131_125;

+ (UIColor*)colorWithRgb_101_186_127;

+ (UIColor*)colorWithRgb_248_101_96;

+ (UIColor*)colorWithRgb_246_253_245;

/**
 淡黄色

 @return
 */
+ (UIColor*)colorWithRgb_245_250_216;

+ (UIColor*)colorWithRgb_62_79_88;
+ (UIColor *)colorWithRgb_42_197_90;

#pragma mark - ThreeShow

/// color转img
/// @param size 图片大小
- (nullable UIImage *)imageWithSize:(CGSize)size;

/**
 主题蓝色

 @return 蓝色
 */
+ (UIColor*)colorWithRgb_0_151_216;

+ (UIColor*)colorWithRgb251_10_10;
//黄色
+ (UIColor*)colorWithRgb252_199_17;
//蓝色
+ (UIColor*)colorWithRgb_20_150_216;

@end
