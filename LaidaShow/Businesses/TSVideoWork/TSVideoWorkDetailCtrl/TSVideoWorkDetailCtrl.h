//
//  TSVideoWorkDetailCtrl.h
//  ThreeShow
//
//  Created by cgw on 2019/7/15.
//  Copyright © 2019 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TSProductDataModel;
@interface TSVideoWorkDetailCtrl : UIViewController

@property (nonatomic, strong) TSProductDataModel *dataModel;

//主要为了分享视频
@property (nonatomic, strong) UIImage *coverImg;

@end

NS_ASSUME_NONNULL_END
