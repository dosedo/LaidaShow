//
//  SBView.h
//  SBPlayer
//
//  Created by sycf_ios on 2017/4/10.
//  Copyright © 2017年 shibiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SBCommonHeader.h"
#import "SBControlView.h"
#import "SBPauseOrPlayView.h"
//横竖屏的时候过渡动画时间，设置为0.0则是无动画
#define kTransitionTime 0.2
//填充模式枚举值
typedef NS_ENUM(NSInteger,SBLayerVideoGravity){
    SBLayerVideoGravityResizeAspect,
    SBLayerVideoGravityResizeAspectFill,
    SBLayerVideoGravityResize,
};
//播放状态枚举值
typedef NS_ENUM(NSInteger,SBPlayerStatus){
    SBPlayerStatusFailed,
    SBPlayerStatusReadyToPlay,
    SBPlayerStatusUnknown,
    SBPlayerStatusBuffering,
    SBPlayerStatusPlaying,
    SBPlayerStatusStopped,
};

@protocol SBPlayerDelegate;
@interface SBPlayer : UIView<SBControlViewDelegate,SBPauseOrPlayViewDelegate,UIGestureRecognizerDelegate>{
    id playbackTimerObserver;
}

//暂停和播放视图
@property (nonatomic,strong) SBPauseOrPlayView *pauseOrPlayView;

//AVPlayer
@property (nonatomic,strong) AVPlayer *player;
//AVPlayer的播放item
@property (nonatomic,strong) AVPlayerItem *item;
//总时长
@property (nonatomic,assign) CMTime totalTime;
//当前时间
@property (nonatomic,assign) CMTime currentTime;
//资产AVURLAsset
@property (nonatomic,strong) AVURLAsset *anAsset;
//播放器Playback Rate
@property (nonatomic,assign) CGFloat rate;
//播放状态
@property (nonatomic,assign,readonly) SBPlayerStatus status;
//videoGravity设置屏幕填充模式，（只写）
@property (nonatomic,assign) SBLayerVideoGravity mode;
//是否正在播放
@property (nonatomic,assign,readonly) BOOL isPlaying;
//是否全屏
@property (nonatomic,assign,readonly) BOOL isFullScreen;
//设置标题
@property (nonatomic,copy) NSString *title;
//与url初始化
-(instancetype)initWithUrl:(NSURL *)url;
//将播放url放入资产中初始化播放器
-(void)assetWithURL:(NSURL *)url;
//公用同一个资产请使用此方法初始化
-(instancetype)initWithAsset:(AVURLAsset *)asset;
//播放
-(void)play;
//暂停
-(void)pause;
//停止 （移除当前视频播放下一个或者销毁视频，需调用Stop方法）
-(void)stop;

#pragma mark - wkun add

//重新设置url
- (void)resetWithUrl:(NSURL*)url;

//本地视频的Url
- (void)resetLocalVideoUrl:(NSURL*)fileUrl;

//进度视图 和播放按钮 是否隐藏
-(void)setSubViewsIsHide:(BOOL)isHide;

@property (nonatomic, strong) UIButton *largerBtn;

@property (nonatomic, weak) id<SBPlayerDelegate> delegate;

@property (nonatomic, assign) BOOL allowsRotateScreen; //允许视频横屏。默认为YES

@property (nonatomic, assign) CGRect oldFrame; //为了全屏播放使用

@property (nonatomic, assign) BOOL isShowControlView; //默认为YES

@end


@protocol SBPlayerDelegate <NSObject>
@optional
//开始播放
- (void)playerStartPlay:(SBPlayer*)player;
//暂停播放
- (void)playerPausePlay:(SBPlayer*)player;
//结束播放
- (void)playerEndPlay:(SBPlayer*)player;
//控制视图，展示或隐藏的状态改变
- (void)player:(SBPlayer*)player controlViewChangeState:(BOOL)isShow;
@end

