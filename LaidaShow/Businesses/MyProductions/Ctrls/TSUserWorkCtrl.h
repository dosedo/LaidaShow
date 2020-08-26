//
//  TSUserWorkCtrl.h
//  ThreeShow
//
//  Created by hitomedia on 15/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef TSUSERWORKURL
#define TSUSERWORKURL
typedef NS_ENUM(NSInteger, TSUserWorkType){
    TSUserWorkTypeLocal = 0, //本地作品
    TSUserWorkTypeLinePrivate, //线上私有作品
    TSUserWorkTypeLinePublic, //线上公开
    TSUserWorkTypeCollect    //收藏作品
};
#endif

@interface TSUserWorkCtrl : UIViewController
- (id)initWithType:(TSUserWorkType)orderType;

- (void)reloadData;

- (void)cancleLoadingData;
@end
