//
//  TSClearWorkBgCtrl.h
//  ThreeShow
//
//  Created by hitomedia on 07/08/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSWorkModel.h"

typedef NS_ENUM(NSUInteger, TSClearWorkBgState){
    TSClearWorkBgStateNotBegin =0, //未开始
    TSClearWorkBgStateClearing, //去底中
    TSClearWorkBgStateComplete //去底完成
};

@class TSWorkModel;
/**
 去底页面
 本页面逻辑
 1.从本地作品进入本页面，需要传递作品的Model，原图路径从Model取，此时去底，直接将中间图和结果图直接存在该Model下，并更新Model
 2.从拍照进入，只需传imgs,原图路径，在拍照时已保存。
 */
@interface TSClearWorkBgCtrl : UIViewController

@property (nonatomic, strong) NSArray *imgs;
@property (nonatomic, strong) UIButton *clearBgBtn;      //开始去底

/**
 是否是从本地作品进入。默认为NO
 */
//@property (nonatomic, assign) BOOL isFromLocalwork;

#pragma mark - new
@property (nonatomic, strong) TSWorkModel *workModel;

@end
