//
//  UILabel.m
//  HopeHelpClient
//
//  Created by 端倪 on 16/2/4.
//  Copyright © 2016年 deepai. All rights reserved.
//

#import "UILabel+Ext.h"

@implementation UILabel(Ext)

+(CGSize)lableSizeWithText:(NSString *)text font:(UIFont *)font width:(CGFloat)width{
    
    if( text == nil || font == nil ){
        return CGSizeZero;
    }
    
    CGSize size = CGSizeMake(width, MAXFLOAT);
    return [ text boundingRectWithSize:size
                               options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                            attributes:@{NSFontAttributeName:font} context:nil].size;
}

+ (CGSize)lableSizeWithAttrText:(NSAttributedString *)text width:(CGFloat)width{
    if( text == nil ){
        return CGSizeZero;
    }
    
    CGSize size = CGSizeMake(width, MAXFLOAT);
    return [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil].size;
}

+ (UILabel*)getLabelWithTextColor:(UIColor *)textColor font:(UIFont *)font textAlignment:(NSTextAlignment)ta frame:(CGRect)fr superView:(UIView *)superView{
    UILabel *lbl = [[UILabel alloc] initWithFrame:fr];
    [superView addSubview:lbl];
    lbl.textColor = textColor;
    lbl.textAlignment = ta;
    lbl.font = font;
    return lbl;
}

- (CGSize)labelSizeWithMaxWidth:(CGFloat)width{
    NSString *text = self.text;
    UIFont *font = self.font;
    if( [text isKindOfClass:[NSString class]]==NO  ) return CGSizeZero;
    
    if( text == nil || font == nil ){
        return CGSizeZero;
    }
    
    CGSize size = CGSizeMake(width, MAXFLOAT);
    return [ text boundingRectWithSize:size
                               options:NSStringDrawingUsesLineFragmentOrigin
                            attributes:@{NSFontAttributeName:font} context:nil].size;
    
}

-(void)addStarAtTopRight{
    UILabel *starLbl = [[UILabel alloc] init];
    starLbl.text = @"*";
    UIFont *font = self.font;
    if( font == nil ){
        font = [UIFont systemFontOfSize:14.0];
    }
    starLbl.textColor = [UIColor redColor];
    starLbl.textAlignment = NSTextAlignmentLeft;
    starLbl.frame = CGRectMake(0, 0, 10, 10);
}

- (CGSize)labelAttributeTextSizeWithMaxWidth:(CGFloat)width{
    return [UILabel lableSizeWithAttrText:self.attributedText width:width];
}

@end
