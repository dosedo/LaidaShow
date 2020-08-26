//
//  TSShootVideoCompleteCtrl.m
//  ThreeShow
//
//  Created by wkun on 2019/7/14.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSShootVideoCompleteCtrl.h"
#import "UILabel+Ext.h"
#import "UIViewController+Ext.h"
#import "TSEditWorkCtrl.h"
#import "TSHelper.h"
//#import "TSProductionShowView.h"
#import "TSWorkModel.h"
#import "TSPublishWorkCtrl.h"
#import "SBPlayer.h"
#import "TSEditVideoWorkCtrl.h"

@interface TSShootVideoCompleteCtrl ()<SBPlayerDelegate>
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) SBPlayer *player;

//@property (nonatomic, strong) TSProductionShowView *showView;

@end

@implementation TSShootVideoCompleteCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItems = @[[UIBarButtonItem new]];
//    self.showView.imgs = self.imgs;
//    [self.showView reloadData];
    
    
    [self.player resetLocalVideoUrl:self.videoUrl];
//    [self.player play];
    
    [self.view addSubview:self.bottomView];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self.player pause];
}

#pragma mark - TouchEvents
- (void)handleBottomBtn:(UIButton*)btn{
    if( btn.tag == 100 ){
        
        NSLog(@"=====返回=====");
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }else if( btn.tag == 101 ){
        
        TSWorkModel *wm = [TSWorkModel new];
        wm.isLocalWork = YES;
        wm.isVideoWork = YES;
        wm.videoPath = self.videoUrl.path;
        
        //编辑
        TSEditVideoWorkCtrl *wc = [TSEditVideoWorkCtrl new];
        wc.model = wm;
        wc.isNeedBackToWorkListCtrl = YES;
        [self pushViewCtrl:wc];
        
    }else if( btn.tag == 102 ){
        TSWorkModel *wm = [TSWorkModel new];
        wm.isLocalWork = YES;
        wm.isVideoWork = YES;
        wm.videoPath = self.videoUrl.path;
        wm.editingVideoUrl = self.videoUrl;
        
        TSPublishWorkCtrl *wc = [TSPublishWorkCtrl new];
        wc.model = wm;
        [self pushViewCtrl:wc];
    }
}

#pragma mark - Getters
- (SBPlayer *)player {
    if( !_player ){
        _player = [[SBPlayer alloc]initWithUrl:[NSURL URLWithString:@""]];
        _player.delegate = self;
        _player.largerBtn.enabled = NO;
        _player.isShowControlView = NO;
        //        _player.allowsRotateScreen = NO;
        //设置标题
        //设置播放器背景颜色
        _player.backgroundColor = [UIColor clearColor];
        //设置播放器填充模式 默认SBLayerVideoGravityResizeAspectFill，可以不添加此语句
        //        _player.mode = SBLayerVideoGravityResize;
        //添加播放器到视图
        [self.view addSubview:_player];
        //约束，也可以使用Frame
        CGFloat iw = self.view.frame.size.width;
        _player.frame = CGRectMake(0, 0, iw, SCREEN_HEIGHT);
    }
    return _player;
}

- (UIView *)bottomView {
    if( !_bottomView ){
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor whiteColor];
        CGFloat baseH = 120 - 30;
        CGFloat ih = baseH + BOTTOM_NOT_SAVE_HEIGHT;
        _bottomView.frame = CGRectMake(0, (SCREEN_HEIGHT-ih), SCREEN_WIDTH, ih);
        
        UIView *line = [UIView new];
        line.backgroundColor = [UIColor colorWithRgb221];
        line.frame = CGRectMake(0, 0, _bottomView.width, 0.5);
        [_bottomView addSubview:line];
        
        NSArray *imgs = @[@"complete_back",@"complete_editor",@"complete_next"];
        for( NSUInteger i=0; i<imgs.count; i++ ){
            UIButton *btn = [UIButton new];
            [_bottomView addSubview:btn];
            
            [btn setImage:[UIImage imageNamed:imgs[i]] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            [btn setTitleColor:[UIColor colorWithRgb51] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(handleBottomBtn:) forControlEvents:UIControlEventTouchUpInside];
            CGFloat btnH = 77,btnW = _bottomView.width/imgs.count;
            btn.frame = CGRectMake(i*btnW, (baseH-btnH)/2, btnW, btnH);
            btn.tag = 100+i;
        }
    }
    return _bottomView;
}

@end
