//
//  TSClearBgStateView.h
//  ThreeShow
//
//  Created by hitomedia on 08/06/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSWorkModel;
@interface TSClearBgStateView : UIView

//是否完成去底 ，默认为NO
@property (nonatomic, assign) BOOL isClearedBgImg;

+ (TSClearBgStateView*)shareClearBgStateView;

+ (TSClearBgStateView*)showInView:(UIView*)view handleSeeBtn:(void(^)(void))handleSeeBtnBlock;

+ (void)hide;

@end
