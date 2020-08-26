//
//  TSFilterVideoCtrl.h
//  ThreeShow
//
//  Created by cgw on 2019/7/17.
//  Copyright © 2019 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSFilterVideoCtrl : UIViewController

@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, copy) void(^completeBlock)(NSURL *newVideoUrl);

@end

@interface TSFilterVideoCtrl(Filter)
-(void)commit_movie;
-(void)handleFilterChange;
-(void)addAdjustFilters;
- (void)compositionFilterWithCallBack:(void(^)(BOOL success,NSURL * outUrl))callBack;
@end

NS_ASSUME_NONNULL_END



