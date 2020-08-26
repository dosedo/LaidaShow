//
//  TSEditVideoWorkCtrl.h
//  ThreeShow
//
//  Created by cgw on 2019/7/15.
//  Copyright © 2019 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TSWorkModel;
@interface TSEditVideoWorkCtrl : UIViewController

@property (nonatomic, strong) TSWorkModel *model;

/**
 点击返回时，是否需要返回到作品列表页，默认为NO
 */
@property (nonatomic, assign) BOOL isNeedBackToWorkListCtrl;

@end

NS_ASSUME_NONNULL_END
