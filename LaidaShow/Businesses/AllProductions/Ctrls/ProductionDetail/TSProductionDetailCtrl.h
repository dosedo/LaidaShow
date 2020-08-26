//
//  TSProductionDetailCtrl.h
//  LaidaShow
//
//  Created by Met on 2020/8/26.
//  Copyright © 2020 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSProductDataModel;
//作品详情

@interface TSProductionDetailCtrl : UIViewController

@property (nonatomic, strong) TSProductDataModel *dataModel;
//封面图，用来当第一张图未下载完成时，使用其作为二维码分享的背景图
@property (nonatomic, strong) UIImage *thumbImg;

@end
