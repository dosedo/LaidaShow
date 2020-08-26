//
//  TSEditVideoWorkCtrl.m
//  ThreeShow
//
//  Created by cgw on 2019/7/15.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSEditVideoWorkCtrl.h"
#import "UIViewController+Ext.h"
#import "SBPlayer.h"
#import "TSSelectMusicModel.h"
#import "PPAudioPlay.h"
#import "TSMusicBtn.h"
#import "TSEditButton.h"
#import "UIButton+RotateAnimate.h"
#import "TSAlertView.h"
#import "TSSelectMusicCtrl.h"
#import "TSAddRecordCtrl.h"
#import "PPFileManager.h"
#import "TSWorkModel.h"
#import "TSPublishWorkCtrl.h"
#import "TSEditAddImgCtrl.h"
#import "TSFilterVideoCtrl.h"
#import "TSVideoAddTextCtrl.h"

static NSUInteger const gTagBase = 100;

@interface TSEditVideoWorkCtrl ()<PPAudioPlayDelegate>
@property (nonatomic, strong) SBPlayer *player;

@property (nonatomic, strong) UIView   *bottomView;
@property (nonatomic, strong) UIButton *musicBtn;
@property (nonatomic, strong) UIButton *cancleMusicBtn;
@property (nonatomic, strong) UIView   *btnView;
@property (nonatomic, strong) UIView   *btnViewHasHuandi;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *completeBtn;
@property (nonatomic, strong) UIButton *clearBgBtn; //去底按钮
@property (nonatomic, strong) TSSelectMusicModel *musicModel;
//@property (nonatomic, strong) NSURL *editingVideoUrl;  //正在编辑的视频路径
@end

@implementation TSEditVideoWorkCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self resetDatas];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[PPAudioPlay shareAudioPlay] endPlay];
    [self.musicBtn stopAnimation];
    
    [self.player pause];
}

#pragma mark - Public
- (void)resetDatas{
    
    [_btnView removeFromSuperview];
    _btnView = nil;
    [_player removeFromSuperview];
    _player = nil;
    
    self.model.editingVideoUrl = [NSURL fileURLWithPath:self.model.videoPath];
    [self.player resetLocalVideoUrl:self.model.editingVideoUrl];

    [self.view addSubview:_bottomView];
    self.clearBgBtn.selected = NO;
    _isNeedBackToWorkListCtrl = NO;

    TSSelectMusicModel *mm = nil;
    if( self.model ){
        if( self.model.recordPath ){
            mm = [TSSelectMusicModel new];
            mm.name = NSLocalizedString(@"WorkEditBottomRecordFile", nil);//@"录音文件";
            mm.url = _model.recordPath;
            mm.isRecord = YES;
        }else if( self.model.musicName && self.model.musicUrl ){
            mm = [TSSelectMusicModel new];
            mm.name = _model.musicName;
            mm.url = _model.musicUrl;
            mm.isRecord = NO;
        }
    }else{
        self.model.isCanClearBg = YES;
    }
    [self updateMuiscDataWithModel:mm];
}

- (void)resetVideoUrl:(NSURL*)videoUrl{
    [self.player resetWithUrl:videoUrl];
    [self.view sendSubviewToBack:self.player];
}

#pragma mark - Private
- (void)updateBottomViewFrameWithIsShowMusic:(BOOL)showMusic{
    CGFloat ih = 99 + BOTTOM_NOT_SAVE_HEIGHT;
    CGFloat musicH = 45;
    if( showMusic == NO ) {
        ih = ih-musicH;
    }
    self.bottomView.frame = CGRectMake(0, SCREEN_HEIGHT-ih, SCREEN_WIDTH, ih);
    CGRect fr = self.btnView.frame; fr.origin.y = self.bottomView.height-fr.size.height;
    self.btnView.frame = fr;
    self.musicBtn.hidden = !showMusic;
    self.cancleMusicBtn.hidden = !showMusic;
}

- (UIButton*)getBtnWithImgName:(NSString*)imgName hiImgName:(NSString*)hiImgName sImgName:(NSString*)sImgName sel:(SEL)sel{
    UIButton *btn = [TSEditButton buttonWithType:UIButtonTypeCustom];//[[TSEditButton alloc] init];
    [btn setTitleColor:[UIColor colorWithRgb51] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    if( imgName ){
        [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    }
    
    if( hiImgName ){
        [btn setImage:[UIImage imageNamed:hiImgName] forState:UIControlStateHighlighted];
    }
    
    if( sImgName ){
        [btn setImage:[UIImage imageNamed:sImgName] forState:UIControlStateSelected];
    }
    
    if( [self respondsToSelector:sel] ){
        [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    }
    
    //[self.btnView addSubview:btn];
    
    return btn;
}

#pragma mark - music
- (void)updateMuiscDataWithModel:(TSSelectMusicModel*)model{
    self.musicModel = model;
    [self updateBottomViewFrameWithIsShowMusic:model];
    [self.musicBtn setTitle:model.name forState:UIControlStateNormal];
}

- (void)clearMusicDataOrRecordDataWithIsMusic:(BOOL)isMusic{
    
    if( isMusic ){
        PPFileManager *fm = [PPFileManager sharedFileManager];
        if( self.model.recordPath ){
            if( _model.recordPath ) {
                //移除录音文件
                [fm removeFileAtAllPath:_model.recordPath];
            }
        }
        self.model.recordPath = nil;
    }else{
        self.model.musicName = nil;
        self.model.musicUrl = nil;
    }
}

#pragma mark - gotoCtrl
- (void)gotoMusicCtrl{
    TSSelectMusicCtrl *mc = [TSSelectMusicCtrl new];
    __weak typeof(self) weakSelf = self;
    mc.selectCompleteBlock = ^(TSSelectMusicModel *model) {
        if( model ){
            [self clearMusicDataOrRecordDataWithIsMusic:YES];
        }
        [weakSelf updateMuiscDataWithModel:model];
    };
    [self pushViewCtrl:mc];
}

- (void)gotoRecordCtrl{
    TSAddRecordCtrl *rc = [TSAddRecordCtrl new];
    rc.videoUrl = self.model.editingVideoUrl;//[NSURL fileURLWithPath:self.model.videoPath];
//    rc.img = self.showView.imgs[0];
    __weak typeof(self) weakSelf = self;
    rc.selectCompleteBlock = ^(TSSelectMusicModel *model) {
        if( model ){
            [self clearMusicDataOrRecordDataWithIsMusic:NO];
        }
        [weakSelf updateMuiscDataWithModel:model];
    };
    
    [self pushViewCtrl:rc];
}

#pragma mark - TouchEvents

- (void)handleMusicBtn:(UIButton*)musicBtn{
    if( musicBtn.isSelected ){
        
        [PPAudioPlay shareAudioPlay].needEndWhenStartPlaying = YES;
        [musicBtn stopAnimation];
        //停止播放
        [[PPAudioPlay shareAudioPlay] endPlay];
        
    }else{
        [musicBtn startAnimation];
        //开始播放
        [[PPAudioPlay shareAudioPlay] startPlayWithUrl:self.musicModel.url];
    }
    
    musicBtn.selected = !musicBtn.isSelected;
}

- (void)handleBtn:(UIButton*)btn{
    
    @autoreleasepool{
        
//        self.model.editingImgs = self.showView.imgs;
        
        NSInteger startIndex = 0;//self.model.isCleared?0:-1;
        if( btn.tag == 0 + gTagBase ){
            //滤镜
            TSFilterVideoCtrl *fvc = [TSFilterVideoCtrl new];
            fvc.videoUrl = self.model.editingVideoUrl;
            fvc.completeBlock = ^(NSURL * _Nonnull newVideoUrl) {
                self.model.editingVideoUrl = newVideoUrl;
                [self resetVideoUrl:newVideoUrl];
            };
            [self pushViewCtrl:fvc];
        }else if (btn.tag == 1 +gTagBase){
            //文字
            TSVideoAddTextCtrl *tc = [TSVideoAddTextCtrl new];
            tc.videoUrl = self.model.editingVideoUrl;
            tc.completeBlock = ^(NSURL * _Nonnull newVideoUrl) {
                self.model.editingVideoUrl = newVideoUrl;
                [self resetVideoUrl:newVideoUrl];
            };
            [self pushViewCtrl:tc];
            
        }else if (btn.tag == 2+gTagBase + startIndex){
            
            //音乐
            BOOL isNeedShowAlert = self.musicModel.isRecord;
            if( isNeedShowAlert ){
                [TSAlertView showAlertWithTitle:NSLocalizedString(@"WorkEditConfirmAddMusicTitle", nil) des:NSLocalizedString(@"WorkEditConfirmAddMusicDes", nil) handleBlock:^(NSInteger index) {
                    [self gotoMusicCtrl];
                }];
            }else{
                [self gotoMusicCtrl];
            }
            
        }else if( btn.tag == 3 +gTagBase + startIndex ){
            //录音
            BOOL isNeedShowAlert = (self.musicModel && self.musicModel.isRecord==NO);
            if( isNeedShowAlert ){
                [TSAlertView showAlertWithTitle:NSLocalizedString(@"WorkEditConfirmAddRecordTitle", nil) des:NSLocalizedString(@"WorkEditConfirmAddRecordDes", nil) handleBlock:^(NSInteger index) {
                    [self gotoRecordCtrl];
                }];
            }else{
                [self gotoRecordCtrl];
            }
            
        }else if (btn.tag ==4 +gTagBase + startIndex){
            
            //水印
    
//            TSEditAddImgCtrl *mc = _addImgCtrl;
//            if (mc == nil) {
//                mc = [TSEditAddImgCtrl new];
//                _addImgCtrl = mc;
//
//                __weak typeof(self) weakSelf = self;
//                mc.completeBlock = ^(NSArray *newImgArr) {
//                    [weakSelf clipImgComplete:newImgArr];
//                };
//            }
            TSEditAddImgCtrl *mc = [TSEditAddImgCtrl new];
            mc.videoUrl = self.model.editingVideoUrl;//[NSURL fileURLWithPath:self.model.videoPath];
            mc.completeBlock = ^(NSArray *newImgArr) {
                NSURL *newUrl = (NSURL*)(newImgArr);
                if( [newUrl isKindOfClass:[NSURL class]] ){
                    self.model.editingVideoUrl = newUrl;
                    [self resetVideoUrl:newUrl];
                }
            };
            [self pushViewCtrl:mc];
        }
    }
}

- (void)handleClose{
    self.navigationController.navigationBar.hidden = NO;
    
    [PPAudioPlay shareAudioPlay].needEndWhenStartPlaying = YES;
    
    if( _isNeedBackToWorkListCtrl ){
        NSArray *ctrs = self.navigationController.viewControllers;
        [self.navigationController popToRootViewControllerAnimated:YES];
        ctrs = nil;
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)handleSave{
    
    TSWorkModel *wm = self.model;//nil;
    //    if( self.model == nil ){
    //        wm = [TSWorkModel new];
    //        wm.isCanClearBg = !_isModifyOriginImg;
    //
    //        wm.clearBgImgPathArr = self.resultImgs;
    //        wm.maskImgPathArr = self.maskClearImgs;
    //        wm.imgPathArr = self.oriImgs;
    //
    //    }else{
    //        wm = [self.model copy];
    //    }
    //    wm.imgArr = self.showView.imgs;
    if( self.musicModel ){
        
        if( self.musicModel.isRecord ){
            wm.recordPath = self.musicModel.url;
        }else{
            wm.musicName = self.musicModel.name;
            wm.musicUrl = self.musicModel.url;
        }
    }
    
//    wm.editingImgs = self.showView.imgs;
    TSPublishWorkCtrl *wc = [TSPublishWorkCtrl new];
    wc.model = wm;
    [self pushViewCtrl:wc];
}

- (void)handleCancleMusic{
    
    //移除本地的录音文件
    //    [self clearMusicDataOrRecordDataWithIsMusic:YES];
    
    [[PPAudioPlay shareAudioPlay] endPlay];
    
    [self updateMuiscDataWithModel:nil];
}

#pragma mark - AudioPlayDelegate
- (void)audioPlayEndPlay:(PPAudioPlay *)auidoPlay{
    self.musicBtn.selected = NO;
    [self.musicBtn stopAnimation];
}

#pragma mark - Propertys

- (SBPlayer *)player {
    if( !_player ){
        _player = [[SBPlayer alloc]initWithUrl:[NSURL URLWithString:@""]];
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
        _bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        _bottomView.userInteractionEnabled = YES;
        [self.view addSubview:_bottomView];
        
        /*
        CGFloat wh = 45;
        UIButton *cancleBtn = [UIButton new];
        cancleBtn.frame = CGRectMake(15, 20+NAVGATION_VIEW_HEIGHT-64, wh, wh);
        [cancleBtn setImage:[UIImage imageNamed:@"edit_close"] forState:UIControlStateNormal];
        //        [cancleBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_disable220"] forState:UIControlStateHighlighted];
        [cancleBtn addTarget:self action:@selector(handleClose) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:cancleBtn];

        UIButton *saveBtn = [UIButton new];
        saveBtn.frame = CGRectMake(SCREEN_WIDTH-cancleBtn.x-wh, cancleBtn.y, wh, wh);
        [saveBtn setImage:[UIImage imageNamed:@"edit_check"] forState:UIControlStateNormal];
        //        [saveBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_disable220"] forState:UIControlStateHighlighted];
        [saveBtn addTarget:self action:@selector(handleSave) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:saveBtn];
        */
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor whiteColor];
        view.frame = CGRectMake(0, 0, SCREEN_WIDTH, NAVGATION_VIEW_HEIGHT);
        [self.view addSubview:view];
        
        [self addLeftBarItemWithAction:@selector(handleClose) imgName:@"editor_back"];
        
        [self addRightBarItemWithTitle:NSLocalizedString(@"ForgetPwdNextText", nil) action:@selector(handleSave)];
    }
    return _bottomView;
}

- (UIButton *)musicBtn {
    if( !_musicBtn ){
        UIButton *btn = [[TSMusicBtn alloc] init];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setImage:[UIImage imageNamed:@"work_music_w"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(handleMusicBtn:) forControlEvents:UIControlEventTouchUpInside];
        _musicBtn = btn;
        [self.bottomView addSubview:_musicBtn];
        CGFloat ih = 45,topH = 45,ix=10;
        CGFloat cancleW = ih;
        _musicBtn.frame = CGRectMake(ix, (topH-ih)/2, SCREEN_WIDTH-2*ix-cancleW, ih);
        
        UIButton *cancleMusicBtn = [UIButton new];
        _cancleMusicBtn = cancleMusicBtn;
        cancleMusicBtn.frame = CGRectMake(_musicBtn.right, _musicBtn.y, cancleW, ih);
        [cancleMusicBtn addTarget:self action:@selector(handleCancleMusic) forControlEvents:UIControlEventTouchUpInside];
        [cancleMusicBtn setImage:[UIImage imageNamed:@"pc_close_white"] forState:UIControlStateNormal];
        
        [self.bottomView addSubview:cancleMusicBtn];
    }
    return _musicBtn;
}


- (UIView *)btnView {
    if( !_btnView ){
        _btnView = [[UIView alloc] init];
        _btnView.backgroundColor = [UIColor whiteColor];
        _btnView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 56+BOTTOM_NOT_SAVE_HEIGHT);
        _btnView.userInteractionEnabled = YES;
        [self.bottomView addSubview:_btnView];
        
        NSArray *titles = @[NSLocalizedString(@"滤镜", nil),
                            NSLocalizedString(@"文字", nil),
                            NSLocalizedString(@"音乐", nil),
                            NSLocalizedString(@"录音", nil),
                            NSLocalizedString(@"水印", nil)];
        
        NSArray *imgNames = @[@"editor_filter",@"editor_text", @"edit_music",@"edit_record",@"editor_shuiyin"];
 
        CGFloat iLeft = 0;
        
        CGFloat iw = (SCREEN_WIDTH-2*iLeft)/(titles.count);
        for( NSUInteger i=0; i<titles.count; i++ ){
            NSString *title = titles[i];
            NSString *imgName = imgNames[i];
            
            UIButton *btn = [self getBtnWithImgName:imgName hiImgName:nil sImgName:nil sel:@selector(handleBtn:)];
            [btn setTitle:title forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_bg_disable220"] forState:UIControlStateHighlighted];
            btn.tag = i+gTagBase;
            CGFloat ix = iw*i + iLeft;
            btn.frame = CGRectMake(ix, 0, iw, _btnView.height-BOTTOM_NOT_SAVE_HEIGHT);
            [_btnView addSubview:btn];
        }
        
        UIView *topLine = [UIView new];
        topLine.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0.5);
        topLine.backgroundColor = [UIColor colorWithRgb221];
        [_btnView addSubview:topLine];
    }
    return _btnView;
}

@end
