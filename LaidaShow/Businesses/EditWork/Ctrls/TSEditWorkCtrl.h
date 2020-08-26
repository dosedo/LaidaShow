//
//  TSEditWorkCtrl.h
//  ThreeShow
//
//  Created by hitomedia on 13/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSWorkModel;
@interface TSEditWorkCtrl : UIViewController

@property (nonatomic, strong) NSArray *imgs;
@property (nonatomic, strong) TSWorkModel *model;

/**
 点击返回时，是否需要返回到作品列表页，默认为NO
 */
@property (nonatomic, assign) BOOL isNeedBackToWorkListCtrl;

- (void)resetDatas;

//裁剪图片成功
- (void)clipImgComplete:(NSArray*)newimgs;

- (void)modifyImgCompete:(NSArray*)newImgs;

@end
