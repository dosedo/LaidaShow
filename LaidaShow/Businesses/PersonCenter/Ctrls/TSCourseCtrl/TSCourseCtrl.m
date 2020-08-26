//
//  TSCourseCtrl.m
//  ThreeShow
//
//  Created by hitomedia on 11/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSCourseCtrl.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "UIViewController+Ext.h"
#import "SBPlayer.h"
#import "AppDelegate+Orientation.h"

@interface TSCourseCtrl ()
@property (nonatomic, strong) SBPlayer *player;
@property (nonatomic, strong) UIButton *bgBtn;
@end

@implementation TSCourseCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configSelfData];
    
    self.navigationItem.title = NSLocalizedString(@"CoursePageTitle", nil);//@"视频教程";
    
    [self addVideoPlayer];
    
    [self addNotificationCenter];
    
    [self changeBackBarItemWithAction:@selector(handleBack)];
    
    
}

- (void)dealloc{
    [self removeNotificaitons];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [((AppDelegate*) [UIApplication sharedApplication].delegate) setAppIsForcePortrait:NO];
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [((AppDelegate*) [UIApplication sharedApplication].delegate) setAppIsForcePortrait:YES];
    
    [self.player stop];
}

- (void)addVideoPlayer{
    //初始化播放器
    self.player = [[SBPlayer alloc]initWithUrl:[NSURL URLWithString:
                                                @"https://schen-user.oss-cn-shenzhen.aliyuncs.com/show/3DShowDemonstration.mp4"]];
//    self.player.allowsRotateScreen = NO;
    //设置标题
//    [self.player setTitle:@"教程"];
    //设置播放器背景颜色
    self.player.backgroundColor = [UIColor colorWithRgb221];
    //设置播放器填充模式 默认SBLayerVideoGravityResizeAspectFill，可以不添加此语句
    self.player.mode = SBLayerVideoGravityResizeAspectFill;
    //添加播放器到视图
    [self.view addSubview:self.player];
    //约束，也可以使用Frame
    CGFloat iw = self.view.frame.size.width;
    self.player.frame = CGRectMake(0, NAVGATION_VIEW_HEIGHT, iw, iw*3/4);
    [self.player mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.mas_equalTo(self.view);
        make.top.mas_equalTo(NAVGATION_VIEW_HEIGHT);
        make.height.mas_equalTo(@(_player.height));
    }];
    
    _bgBtn = [UIButton new];
    _bgBtn.frame = self.player.frame;
    [_bgBtn setImage:[UIImage imageNamed:@"course_video_play"] forState:UIControlStateNormal];
    [_bgBtn setBackgroundImage:[UIImage imageNamed:@"course_video_home"] forState:UIControlStateNormal];
    [_bgBtn addTarget:self action:@selector(handleBgBtn) forControlEvents:UIControlEventTouchUpInside];
    CGFloat wh = 50;
    CGFloat iTop = (_bgBtn.height-wh)/2;
    CGFloat iLeft = (_bgBtn.width-wh)/2;
    _bgBtn.imageEdgeInsets = UIEdgeInsetsMake(iTop, iLeft, iTop, iLeft);
    [self.view addSubview:_bgBtn];
}

- (void)handleBack{
    [self.player stop];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleBgBtn{
    self.bgBtn.hidden = YES;
    [self.player play];
}

- (void)SBPlayerItemDidPlayToEndTimeNotification:(id)obj{
    //视频播放结束
    
    //暂时不处理 播放结束的view展示问题
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.view bringSubviewToFront:self.bgBtn];
//        self.bgBtn.hidden = NO;
//    });
}

-(void)deviceOrientationDidChange:(NSNotification *)notification{
    UIInterfaceOrientation _interfaceOrientation=[[UIApplication sharedApplication]statusBarOrientation];
    switch (_interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            self.bgBtn.frame = CGRectMake(0, 0, SCREEN_HEIGHT , SCREEN_WIDTH);
        }
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
        case UIInterfaceOrientationPortrait:
        {
            self.bgBtn.frame = CGRectMake(0, NAVGATION_VIEW_HEIGHT, SCREEN_WIDTH, SCREEN_WIDTH*3/4);
        }
            break;
        case UIInterfaceOrientationUnknown:
            NSLog(@"UIInterfaceOrientationUnknown");
            break;
    }
}

#pragma mark - notificaiotns

-(void)addNotificationCenter{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(SBPlayerItemDidPlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.player.player currentItem]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)removeNotificaitons{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[self.player.player currentItem]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}


#pragma mark - 支持横屏

@end

