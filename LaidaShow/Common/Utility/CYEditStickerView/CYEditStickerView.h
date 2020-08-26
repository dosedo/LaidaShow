//
//  PPStickerView.h
//  paipai360-2
//
//  Created by jiangyuan on 16/8/7.
//  Copyright © 2016年 DeepAI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYEditStickerView : UIView

@property (nonatomic,strong) UIImage *image;
@property (nonatomic,strong) UIImageView *contentView;

@property (nonatomic,assign) CGRect selectRect;

///** 裁剪图片的真实尺寸数据 */
//@property (assign,nonatomic,readonly) CGRect originalRect;

- (instancetype)initWithBgView:(UIView *)bgView image:(UIImage *)image withCenterPoint:(CGPoint)centerPoint;

- (UIImage *)getChangedImage;

@end
