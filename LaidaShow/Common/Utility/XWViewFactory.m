//
//  XWViewFactory.m
//  HiTravelService
//
//  Created by hitomedia on 2017/4/13.
//  Copyright © 2017年 hitumedia. All rights reserved.
//

#import "XWViewFactory.h"

@implementation XWViewFactory

+ (UILabel*)labelWithTextColor:(UIColor *)textColor font:(UIFont *)font alignment:(NSTextAlignment)ta frame:(CGRect)fr superView:(UIView *)superView{
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:fr];
    [superView addSubview:lbl];
    lbl.textColor = textColor;
    lbl.textAlignment = ta;
    lbl.font = font;
    return lbl;
}

+ (UITextField *)textFieldWithTextColor:(UIColor *)textColor font:(UIFont *)font placeHolder:(NSString *)ph alignment:(NSTextAlignment)ta frame:(CGRect)fr superView:(UIView *)superView{
    UITextField *tf = [[UITextField alloc] initWithFrame:fr];
    [superView addSubview:tf];
    tf.textColor = textColor;
    tf.textAlignment = ta;
    tf.font = font;
    tf.placeholder = ph;
    return tf;
}

+ (UIButton *)buttonWithTextColor:(UIColor *)textColor font:(UIFont *)font title:(NSString*)title normalImgName:(NSString *)nImgName highLightImgName:(NSString *)hlImgName frame:(CGRect)fr superView:(UIView *)superView {
    
    UIButton *btn = [[UIButton alloc] init];
    [btn setTitleColor:textColor forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:nImgName] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:hlImgName] forState:UIControlStateHighlighted];
    btn.frame = fr;
    btn.titleLabel.font = font;
    [superView addSubview:btn];
    return btn;
}

+ (UIImageView *)imageViewWithFrame:(CGRect)fr imageName:(NSString *)imgName contentModel:(UIViewContentMode)cm superView:(UIView *)superView{
    UIImageView *iv = [UIImageView new];
    iv.frame = fr;
    iv.image = [UIImage imageNamed:imgName];
    iv.contentMode = cm;
    [superView addSubview:iv];
    
    return iv;
}

+ (UIImageView *)imageBadgeViewWithFrame:(CGRect)fr badgeViewTag:(NSUInteger)bvTag image:(UIImage *)img mode:(UIViewContentMode)mode superView:(UIView *)superView{
    UIImageView *iv = [[UIImageView alloc] initWithFrame:fr];
    iv.image = img;
    iv.contentMode = mode;
    iv.clipsToBounds = NO;
    [superView addSubview:iv];
    
    UIView *dot = [UIView new];
    CGFloat wh =5;
    dot.frame = CGRectMake(fr.size.width-wh/2-2, -wh/2+2, wh, wh);
    dot.layer.masksToBounds = YES;
    dot.layer.cornerRadius = wh/2;
    dot.backgroundColor = [UIColor redColor];
    [iv addSubview:dot];
    
    return iv;
}

@end
