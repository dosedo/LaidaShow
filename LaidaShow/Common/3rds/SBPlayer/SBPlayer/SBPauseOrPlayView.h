//
//  PauseOrPlayView.h
//  SBPlayer
//
//  Created by sycf_ios on 2017/4/11.
//  Copyright © 2017年 shibiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBCommonHeader.h"
@class SBPauseOrPlayView;
@protocol SBPauseOrPlayViewDelegate <NSObject>
@required
/**
 暂停和播放视图和状态

 @param pauseOrPlayView 暂停或者播放视图
 @param state 返回状态
 */
-(void)pauseOrPlayView:(SBPauseOrPlayView *)pauseOrPlayView withState:(BOOL)state;

-(void)hideOrShowControlView:(SBPauseOrPlayView *)pauseOrPlayView;

@end
@interface SBPauseOrPlayView : UIView
@property (nonatomic,strong) UIButton *imageBtn;
@property (nonatomic,weak) id<SBPauseOrPlayViewDelegate> delegate;
@property (nonatomic,assign) BOOL state; //播放中，或者暂停中。YES播放。NO 暂停

@end
