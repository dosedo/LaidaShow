//
//  TSProductionInfoView.h
//  ThreeShow
//
//  Created by hitomedia on 09/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TSProductionInfoViewDelegate;
@class TSProductionDetailModel;
/**
 产品信息视图。（详情页的底部展示）
 */
@interface TSProductionInfoView : UIView

//搭 按钮，点击跳转至上传莱搭平台页面。只在我发布的作品中展示此按钮
@property (nonatomic, strong) UIButton *daBtn;

@property (nonatomic, strong) UIButton *showBtn;
@property (nonatomic, strong) UIButton *buyBtn; //购买
@property (nonatomic, strong) UIButton *qrCodeBtn;
@property (nonatomic, strong) UIButton *shareBtn;
@property (nonatomic, strong) UIButton *collectBtn;//收藏
@property (nonatomic, strong) UIButton *praiseBtn;

@property (nonatomic, strong) TSProductionDetailModel *model;

@property (nonatomic, weak) id<TSProductionInfoViewDelegate> delegate;

//点赞成功更新按钮状态 isCancle 是否取消点赞
- (void)praiseSuccess:(BOOL)isCancle;

//收藏成功更新按钮状态 isCancle 是否取消收藏
- (void)collectSuccess:(BOOL)isCancle;

@end

@protocol TSProductionInfoViewDelegate < NSObject>

/**
 点击按钮事件

 @param infoView 本视图实例
 @param btnIndex 按钮索引：0 购买，1 分享二维码，2点赞，3收藏，4分享
 @param isCancle 当按钮索引为2，3时用到，即是否停止播放，是否取消点赞和取消收藏
 */
- (void)productionInfoView:(TSProductionInfoView*)infoView handleBtnAtIndex:(NSUInteger)btnIndex isCancle:(BOOL)isCancle;

@end

