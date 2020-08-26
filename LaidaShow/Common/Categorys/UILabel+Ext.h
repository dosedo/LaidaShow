//
//  UILabel.h
//  HopeHelpClient
//
//  Created by 端倪 on 16/2/4.
//  Copyright © 2016年 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UILabel(Ext)
+ (UILabel*)getLabelWithTextColor:(UIColor*)textColor font:(UIFont*)font textAlignment:(NSTextAlignment)ta frame:(CGRect)fr superView:(UIView*)superView;
+(CGSize)lableSizeWithText:(NSString*)text font:(UIFont*)font width:(CGFloat)width;
+(CGSize)lableSizeWithAttrText:(NSAttributedString*)text width:(CGFloat)width;

-(void)addStarAtTopRight;

- (CGSize)labelSizeWithMaxWidth:(CGFloat)width;

- (CGSize)labelAttributeTextSizeWithMaxWidth:(CGFloat)width;

@end
