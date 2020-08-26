//
//  TSClearWorkCtrl.h
//  ThreeShow
//
//  Created by cgw on 2019/6/28.
//  Copyright © 2019 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TSClearWorkBgState){
    TSClearWorkBgStateNotBegin =0, //未开始
    TSClearWorkBgStateClearing, //去底中
    TSClearWorkBgStateComplete //去底完成
};

@class TSEditWorkCtrl;
@class TSWorkModel;
/**
 去底，以及调整图片透明度啥的
 */
@interface TSClearWorkCtrl : UIViewController

@property (nonatomic, strong) NSArray *imgs;
@property (nonatomic, strong) TSEditWorkCtrl *editWorkCtrl;
@property (nonatomic, strong) TSWorkModel *workModel;

- (void)resetDatas;

@end

NS_ASSUME_NONNULL_END
