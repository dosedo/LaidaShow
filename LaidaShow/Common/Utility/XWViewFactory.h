//
//  XWViewFactory.h
//  HiTravelService
//
//  Created by hitomedia on 2017/4/13.
//  Copyright © 2017年 hitumedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 快速创建视图类
 */
@interface XWViewFactory : NSObject

+ (UILabel*)labelWithTextColor:(UIColor *)textColor
                          font:(UIFont *)font
                     alignment:(NSTextAlignment)ta
                         frame:(CGRect)fr
                     superView:(UIView *)superView;

+ (UITextField*)textFieldWithTextColor:(UIColor*)textColor
                                  font:(UIFont*)font
                           placeHolder:(NSString*)ph
                             alignment:(NSTextAlignment)ta
                                 frame:(CGRect)fr
                             superView:(UIView *)superView;

+ (UIButton*)buttonWithTextColor:(UIColor*)textColor
                            font:(UIFont*)font
                           title:(NSString*)title
                   normalImgName:(NSString*)nImgName
                highLightImgName:(NSString*)hlImgName
                           frame:(CGRect)fr
                       superView:(UIView*)superView;

+ (UIImageView*)imageViewWithFrame:(CGRect)fr imageName:(NSString*)imgName contentModel:(UIViewContentMode)cm superView:(UIView*)superView;

/**
 右上角带有 红点标识的imgView，

 @param fr frame
 @param bvTag 红点标识视图的tag，红点视图添加在 imageview实例上
 @return uiimageview 实例
 */
+ (UIImageView*)imageBadgeViewWithFrame:(CGRect)fr
                           badgeViewTag:(NSUInteger)bvTag
                                  image:(UIImage*)img
                                   mode:(UIViewContentMode)mode
                              superView:(UIView*)superView;
@end

