//
//  TSWorkShowInfoView.h
//  ThreeShow
//
//  Created by cgw on 2019/2/20.
//  Copyright © 2019 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^HandleHideBlock)(void);

/**
 作品信息展示窗口
 */
@class TSProductionDetailModel;
@interface TSWorkShowInfoView : UIView

@property (nonatomic, strong) TSProductionDetailModel *model;

@property (nonatomic, copy) HandleHideBlock handleHideBlock;

- (TSWorkShowInfoView*)initWorkShowInfoView;

- (void)show;

@end

NS_ASSUME_NONNULL_END
