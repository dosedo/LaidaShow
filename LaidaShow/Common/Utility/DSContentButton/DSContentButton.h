//
//  DSContentButton.h
//  DSComponents
//
//  Created by cgw on 2019/3/14.
//  Copyright © 2019 bill. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 可控制按钮标题和图片Frame，以及背景Frame，背景属性等
 */
@interface DSContentButton : UIButton

/**
 若需要内容视图带有圆角或边框，调用此方法进行初始化

 @param cornerRadius 圆角
 @param borderWidth 边框
 @param borderColor 边框颜色
 @return 按钮
 */
- (id)initWithCornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor*)borderColor;

//相对于内容视图的标题和图片的Frame
@property (nonatomic, assign) CGRect titleRect;  //默认CGRectZero
@property (nonatomic, assign) CGRect imageRect;  //默认CGRectZero
@property (nonatomic, assign) CGRect contentRect;//默认Button的Bounds

/**
 内容视图
 Frame只能通过contentRect设置
 该视图位于视图层级的最底层，也可理解为背景视图
 */
@property (nonatomic, strong, readonly) UIView *contentView;

@end

NS_ASSUME_NONNULL_END
