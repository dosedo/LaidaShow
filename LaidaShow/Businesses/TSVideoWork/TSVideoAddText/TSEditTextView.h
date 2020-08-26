//
//  TSEditTextView.h
//  ThreeShow
//
//  Created by wkun on 2019/7/21.
//  Copyright © 2019 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TSEditTextFiled;
/**
 文本编辑、可旋转、缩放
 */
@interface TSEditTextView : UIView

@property (nonatomic,strong) UIImage *image;
@property (nonatomic,strong) TSEditTextFiled *contentView;

@property (nonatomic,assign) CGRect selectRect;

- (instancetype)initWithBgView:(UIView *)bgView image:(UIImage *)image withCenterPoint:(CGPoint)centerPoint;

- (UIImage *)getChangedImage;

@end

@interface TSEditTextFiled : UITextField
@property (nonatomic, assign) CGFloat fntSize;
@end

NS_ASSUME_NONNULL_END
