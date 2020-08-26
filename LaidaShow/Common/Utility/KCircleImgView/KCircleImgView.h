//
//  KCircleImgView.h
//  HopeHelpClient
//
//  Created by 端倪 on 16/2/17.
//  Copyright © 2016年 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KCircleImgViewDelegate;
/**
 *  圆形的ImgView.图片可调整大小
 */
@interface KCircleImgView : UIView

@property (nonatomic, strong) UIImage *image;
/**
 *  图片的半径，最大值为本视图的宽度.（默认值为0）
 */
@property (nonatomic, assign) CGFloat imgRadius;

/**
 *  视图以及图片圆角，默认为0
 */
@property (nonatomic, assign) CGFloat cornerRadius;

@property (nonatomic, strong) UIColor *borderColor;

@property (nonatomic, weak) id<KCircleImgViewDelegate> delegate;

/**
 *  仅仅为了 加载网络图片，而开放
 */
@property (nonatomic, strong) UIImageView *imgView;

@end



@protocol KCircleImgViewDelegate <NSObject>

@optional
-(void)clickedCircleImgView:(KCircleImgView*)circleImgView;

@end
