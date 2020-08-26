//
//  XWShareView.h
//  Hitu
//
//  Created by hitomedia on 2017/1/9.
//  Copyright © 2017年 hitomedia. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 分享视图。上面有分享按钮如：QQ,新浪微博。底部是取消按钮。
 */
@interface XWShareView : UIView

@property (nonatomic, strong) NSArray<NSString*> *shareTitles; //分享的标题，如QQ，微博，等

//分享二维码图片部分视图
@property (nonatomic, strong) UIImageView *bgImgView;
@property (nonatomic, strong) UIImageView *qrView;
@property (nonatomic, strong) UIImageView *qrMiddleIconView; //二维码中间icon
@property (nonatomic, strong) UIView *qrBgView;
@property (nonatomic, strong) UILabel *qrDesL;

+ (XWShareView*)shareView;

+ (void)showWithShareBtnImgNames:(NSArray*)imgNames handleShareBtnBlock:(void(^)(NSUInteger index))handleShareBtnBlock;

+ (void)hide;


@end

@interface XWShareView(ShareQRCodeImg)

+ (void)showWithShareBtnImgNames:(NSArray *)imgNames bgImg:(UIImage*)bgImg qrImg:(UIImage*)qrImg icon:(UIImage*)icon qrDes:(NSString*)qrDes handleShareBtnBlock:(void (^)(NSUInteger))handleShareBtnBlock;
//缩放二维码背景视图及其子视图的frame
+ (void)scaleQRImgViewFrame:(CGFloat)scale;
@end
