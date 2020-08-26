//
//  TSLocalWorkInfoView.h
//  ThreeShow
//
//  Created by cgw on 2019/3/15.
//  Copyright © 2019 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TSLocalWorkInfoViewDelegate;
@class TSProductionDetailModel;
@interface TSLocalWorkInfoView : UIView

@property (nonatomic, strong) UIButton *switchBtn;
@property (nonatomic, strong) UIButton *showBtn;

@property (nonatomic, strong) TSProductionDetailModel *model;

@property (nonatomic, weak) id<TSLocalWorkInfoViewDelegate> delegate;

@end

@protocol TSLocalWorkInfoViewDelegate<NSObject>

@optional
- (void)localWorkInfoView:(TSLocalWorkInfoView*)infoView handleBtnAtIndex:(NSInteger)index;
@end

@interface TSLocalWorkInfoView(LocalVideoWork)
- (id)initLocalVideoWorkInfoView;
@end

NS_ASSUME_NONNULL_END
