//
//  TSPublishWorkCtrl.h
//  ThreeShow
//
//  Created by hitomedia on 15/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSWorkModel;
/**
 发布作品
 */
@interface TSPublishWorkCtrl : UIViewController

@property (nonatomic, strong) TSWorkModel *model;

#warning 这个参数，暂时不用
/**
 本地保存的数据模型，若已存在本地，则有值，否则为nil
 主要为了 本地数据进行编辑后的二次保存，清除之前存在的数据
 */
//@property (nonatomic, strong) TSWorkModel *localWorkModel;

@end

@interface TSPublishWorkCtrl(VideoWork)
- (BOOL)isVideoWork;
- (void)setupPlayerWithModel:(TSWorkModel*)wm;
@end
