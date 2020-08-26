//
//  TSProductionShowView.h
//  ThreeShow
//
//  Created by hitomedia on 08/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 作品展示视图
 */
@interface TSProductionShowView : UIView

//作品的图片地址
@property (nonatomic, strong) NSArray<NSString*> *imgUrls;
//作品的图片,若有值，则忽略imgUrls的值，优先加载imgs
@property (nonatomic, strong) NSArray<UIImage*>  *imgs;

//动画图片
@property (nonatomic,strong) NSMutableArray<UIImage*> *animateImgs;

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel     *countNumL;

//图片是否在播放
@property (nonatomic, assign) BOOL isAnimate;


- (void)reloadData;

//停止动画和图片加载
- (void)stopAnimate;
//- (void)endAnimate;
//
//- (void)cancleDownImg;

//点击自己的回调
@property (nonatomic, copy) void(^handleTapBlock)(TSProductionShowView* infoView);
//加载完所有图片的回调
@property (nonatomic, copy) void(^loadCompleteBlock)(TSProductionShowView* infoView);
//长按回调
@property (nonatomic, copy) void(^handleLongPressBlock)(TSProductionShowView* infoView);
@end
