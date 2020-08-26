//
//  TSFindCtrl.h
//  ThreeShow
//
//  Created by wkun on 2019/2/17.
//  Copyright © 2019 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
#ifndef TSFINDCTRL
#define TSFINDCTRL
typedef NS_ENUM(NSInteger, TSFindType){
    TSFindTypeCompanyNews = 0, //公司动态
    TSFindTypeIndustryNews,    //行业新闻
    TSFindTypeProductNews      //产品资讯
};
#endif

@class TSFindTypeModel;

/**
 发现列表
 */
@interface TSFindCtrl : UIViewController

- (id)initWithTypeModel:(TSFindTypeModel*)typeModel;

- (void)reloadData;

- (void)cancleLoadingData;

@end

NS_ASSUME_NONNULL_END
