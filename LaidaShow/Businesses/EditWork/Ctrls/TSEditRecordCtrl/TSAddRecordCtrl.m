//
//  TSAddRecordCtrl.m
//  ThreeShow
//
//  Created by hitomedia on 14/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSAddRecordCtrl.h"
#import "UIView+LayoutMethods.h"
#import "UIViewController+Ext.h"
#import "TSEditNaviView.h"
#import "UIColor+Ext.h"
#import "HTProgressHUD.h"
#import "MQGradientProgressView.h"
#import "PPAudioRecord.h"
#import "PPAudioPlay.h"
#import "TSSelectMusicModel.h"
#import "TSHelper.h"
#import "SBPlayer.h"

@interface TSAddRecordCtrl ()<PPAudioPlayDelegate, SBPlayerDelegate>
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) TSEditNaviView *naviView;
@property (nonatomic, strong) UIView   *bottomView;
@property (nonatomic, strong) UIButton *recordBtn;
@property (nonatomic, strong) UIButton *reRecordBtn;  //重新录制
@property (nonatomic, strong) UIButton *saveBtn;
@property (nonatomic, strong) UILabel  *noteL;    //提示
@property (nonatomic, strong) MQGradientProgressView *recordProgress;
@property (nonatomic, strong) NSTimer  *timer; //录音计时
@property (nonatomic, assign) CGFloat  recordSecondCount; //录音时长,单位秒
@property (nonatomic, strong) NSString *recordName; //同一个作品的录音文件名字相同

//视频作品部分
@property (nonatomic, strong) SBPlayer *player;

@end

@implementation TSAddRecordCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRgb_240_239_244];
    self.imgView.image = self.img;
    
    [self updateViewStatusWithRecordState:0];
    [PPAudioPlay shareAudioPlay].delegate = self;
    
    self.naviView.sureBtn.enabled = NO;
    
    //判断是视频作品还是图片作品
    if( self.videoUrl ){
        self.imgView.hidden = YES;
        self.player.hidden = NO;
        self.bottomView.hidden = NO;
        [self.view sendSubviewToBack:self.player];
        
        [self.player resetLocalVideoUrl:self.videoUrl];
        
        [self.view bringSubviewToFront:self.bottomView];
        
        CGRect fr = _player.pauseOrPlayView.frame;
        fr.origin.y -= self.bottomView.height;
        _player.pauseOrPlayView.frame = fr;
    }else{
        self.imgView.hidden = NO;
        self.player.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
    
    [[PPAudioPlay shareAudioPlay] endPlay];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self.player pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

//录音最大时长，单位s
- (CGFloat)recordMaxTimeLen{
    return 30;
}

//录音最短时长，单位秒
- (CGFloat)recordMinTimeLen{
    return 2;
}

- (NSString*)recordFileName{
    if( _recordName == nil ){
        _recordName = [TSHelper getNewRecordFileName];
    }
    return _recordName;
}

- (void)startRecordTimer{
    _recordSecondCount = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(recordTimer) userInfo:nil repeats:YES];
}

- (void)invalidateTimer{
    [_timer invalidate];
    _timer = nil;
}

- (void)recordTimer{
    _recordSecondCount ++;
    CGFloat maxLen = [self recordMaxTimeLen];
    self.recordProgress.progress = _recordSecondCount/maxLen;
    if( _recordSecondCount >= maxLen ){
//        [self endRecording];
        [self invalidateTimer];
        [[PPAudioRecord sharedAudioRecord] endRecord];
        [PPAudioRecord sharedAudioRecord].recordTime = maxLen;
        [self updateViewStatusWithRecordState:2];
    
        //为了让松开手指时，继续结束录音，而不是去播放录音
        _recordBtn.selected = NO;
    }
}

- (void)endRecording{
    
    [self invalidateTimer];
    [[PPAudioRecord sharedAudioRecord] endRecord];
    [self updateViewStatusWithRecordState:2];
}

/**
 根据录音状态更新视图
 @param state 0未录音，1录音中，2录音结束，3 播放中
 */
- (void)updateViewStatusWithRecordState:(NSInteger)state{
    if( state == 0 ){
        self.noteL.text = NSLocalizedString(@"WorkEditBottomRecordLongPressStartRecord", nil);//@"长按开始录音";
        self.reRecordBtn.hidden = YES;
        self.saveBtn.hidden = YES;
        self.recordBtn.selected = NO;
        [self invalidateTimer];
        self.recordProgress.progress = 0;
        
        self.naviView.sureBtn.enabled = NO;
    }else if (state == 1 ){
        self.noteL.text = NSLocalizedString(@"WorkEditBottomRecordRecording", nil);//@"录音中...";
    }else if( state == 2){
        self.noteL.text = NSLocalizedString(@"WorkEditBottomRecordClickPlay", nil);//@"点击播放录音";
        self.reRecordBtn.hidden = NO;
        self.saveBtn.hidden = NO;
        self.recordBtn.selected = YES;
        [self.saveBtn setTitle:[NSString stringWithFormat:@"%lldS",(long long)[PPAudioRecord sharedAudioRecord].recordTime] forState:UIControlStateNormal];
        
        self.naviView.sureBtn.enabled = YES;
    }
    
    else if( state == 3 ){
        self.noteL.text = NSLocalizedString(@"WorkEditBottomRecordPlaying", nil);//@"播放中...";
    }
}

#pragma mark - TouchEvents
- (void)handleClose{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleSave{
    if( self.selectCompleteBlock ){
        TSSelectMusicModel *mm = [TSSelectMusicModel new];
        mm.name = NSLocalizedString(@"WorkEditBottomRecordFile", nil);//@"录音文件";
        mm.url = [[PPAudioRecord sharedAudioRecord] recordFileURLWithFileName:[self recordFileName]].path;
        mm.isRecord = YES;
        self.selectCompleteBlock(mm);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleDownRecordBtn:(UIButton*)btn{

    if( _videoUrl )
        [self.player pause];
    
    //若按钮被选中时，按下则什么也不做
    if( btn.isSelected ) return;
    
    //按下录音
    [self startRecordTimer];
    [self updateViewStatusWithRecordState:1];
    
    [[PPAudioRecord sharedAudioRecord] startRecordWithFileName:[self recordFileName]];
}

- (void)handleEndRecordBtn:(UIButton*)btn{
    //若按钮被选中，
    if( btn.isSelected ) {

        //播放录音
        PPAudioPlay *play = [PPAudioPlay shareAudioPlay] ;
        if( play.playState == AudioPlayStatePlaying ){
            [play endPlay];
            [self updateViewStatusWithRecordState:2];
        }
        else{
            [self updateViewStatusWithRecordState:3];
            NSURL *url = [[PPAudioRecord sharedAudioRecord] recordFileURLWithFileName:[self recordFileName]];
            [play startPlayWithUrl:url];
        }
        return;
    }

    if( _recordSecondCount < [self recordMinTimeLen]){
        //录音过短
        [HTProgressHUD showError:NSLocalizedString(@"WorkEditBottomRecordTooShort", nil)];//@"录音过短"];
        [[PPAudioRecord sharedAudioRecord] endRecord];
        
        [self updateViewStatusWithRecordState:0];
        
        self.naviView.sureBtn.enabled = NO;
        
        return;
    }else{
        //录音完成，结束录音
        if( _timer && _timer.isValid ){
            //如果录音未超过最大时长的限制。则调用结束录音
            [self endRecording];
            
            self.naviView.sureBtn.enabled = YES;
        }
    }
    
    btn.selected = YES;
}

//重新录制
- (void)handleReRecordOrSaveBtn:(UIButton*)btn{
    if( [btn isEqual:_saveBtn] ){
        [self handleSave];
    }else{
        //重新录制
        [[PPAudioPlay shareAudioPlay] endPlay];
        [self updateViewStatusWithRecordState:0];
        self.naviView.sureBtn.enabled = NO;
    }
}

#pragma mark - AudioPlayDelegate
- (void)audioPlayEndPlay:(PPAudioPlay *)auidoPlay{
    [self updateViewStatusWithRecordState:2];
}

#pragma mark - SBPlayerDelegate
- (void)playerStartPlay:(SBPlayer *)player{
    if([PPAudioPlay shareAudioPlay].playState == AudioPlayStatePlaying ){
        [[PPAudioPlay shareAudioPlay] endPlay];
        [self updateViewStatusWithRecordState:2];
    }
}

#pragma mark - Propertys

- (UIView *)bottomView {
    if( !_bottomView ){
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor whiteColor];
        CGFloat ih = self.naviView.height + 110;
        _bottomView.frame = CGRectMake(0, SCREEN_HEIGHT-ih, SCREEN_WIDTH, ih);
        CGRect fr = self.naviView.frame;
        fr.origin.y = _bottomView.height-fr.size.height;
        self.naviView.frame = fr;
        [_bottomView addSubview:self.naviView];
        
        [_bottomView addSubview:self.recordProgress];
        [_bottomView addSubview:self.recordBtn];
        CGFloat wh = 45;
        [self.recordBtn cornerRadius:wh/2];
        self.recordBtn.frame = CGRectMake((_bottomView.width-wh)/2, (_naviView.y-wh)/2, wh, wh);
        self.noteL.frame = CGRectMake(0, _recordBtn.bottom+5, _bottomView.width, 20);
        [_bottomView addSubview:_noteL];
        
        NSArray *titles = @[NSLocalizedString(@"WorkEditBottomRecordRerecord", nil),@""];//NSLocalizedString(@"WorkEditBottomRecordSave", nil)];//@[@"重录",@"保存"];
        for( NSInteger i=0; i<titles.count; i++ ){
            UIButton *resetBtn = [UIButton new];
            CGFloat iw = 100, xgap = 20;ih  = 44;
            CGFloat ix = _recordBtn.x-iw-xgap;
            
            if( i== 1 ){
                ix = _recordBtn.right+xgap;
                _saveBtn = resetBtn;
                _saveBtn.userInteractionEnabled = NO;
            }
            else{
                _reRecordBtn = resetBtn;
            }
            resetBtn.frame = CGRectMake(ix, _recordBtn.center.y-ih/2, iw, ih);
            [resetBtn setTitle:titles[i] forState:UIControlStateNormal];
            [resetBtn setTitleColor:[UIColor colorWithRgb51] forState:UIControlStateNormal];
            [resetBtn setTitleColor:[UIColor colorWithRgb153] forState:UIControlStateHighlighted];
            resetBtn.titleLabel.font = [UIFont systemFontOfSize:14];
            [resetBtn addTarget:self action:@selector(handleReRecordOrSaveBtn:) forControlEvents:UIControlEventTouchUpInside];
            [_bottomView addSubview:resetBtn];
        }
        [self.view addSubview:_bottomView];
    }
    return _bottomView;
}

- (UIImageView *)imgView {
    if( !_imgView ){
        _imgView = [[UIImageView alloc] init];
        _imgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.bottomView.y);
        _imgView.userInteractionEnabled = YES;
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = YES;
        [self.view addSubview:_imgView];
    }
    return _imgView;
}

- (TSEditNaviView *)naviView {
    if( !_naviView ){
        _naviView = [[TSEditNaviView alloc] initWithTitle:NSLocalizedString(@"WorkEditBottomRecord", nil) target:self cancleSel:@selector(handleClose) sureSel:@selector(handleSave)];
        CGFloat ih = BOTTOM_NOT_SAVE_HEIGHT+45+15;
        _naviView.frame = CGRectMake(0, SCREEN_HEIGHT-ih, SCREEN_WIDTH, ih);
    }
    return _naviView;
}

- (MQGradientProgressView *)recordProgress {
    if( !_recordProgress ){
        _recordProgress = [[MQGradientProgressView alloc] init];
        _recordProgress.frame = CGRectMake(0, 0, SCREEN_WIDTH, 4);
        _recordProgress.progress = 0;
        _recordProgress.bgProgressColor = [UIColor colorWithRgb_0_151_216];
        _recordProgress.backgroundColor = [UIColor colorWithRgb221];
    }
    return _recordProgress;
}

- (UIButton *)recordBtn {
    if( !_recordBtn ){
        _recordBtn = [UIButton new];
        [_recordBtn setBackgroundImage:[UIImage imageNamed:@"edit_record_unrecord"] forState:UIControlStateNormal];
        [_recordBtn setBackgroundImage:[UIImage imageNamed:@"edit_recording"] forState:UIControlStateHighlighted];
        [_recordBtn setBackgroundImage:[UIImage imageNamed:@"edit_record_play"] forState:UIControlStateSelected];
        [_recordBtn addTarget:self action:@selector(handleEndRecordBtn:) forControlEvents:UIControlEventTouchUpOutside];
        [_recordBtn addTarget:self action:@selector(handleEndRecordBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_recordBtn addTarget:self action:@selector(handleDownRecordBtn:) forControlEvents:UIControlEventTouchDown];
    }
    return _recordBtn;
}

- (UILabel *)noteL {
    if( !_noteL ){
        _noteL = [[UILabel alloc] init];
        _noteL.textColor = [UIColor colorWithRgb51];
        _noteL.font = [UIFont systemFontOfSize:14];
        _noteL.textAlignment = NSTextAlignmentCenter;
    }
    return _noteL;
}

//视频作品
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
        
        CGRect fr = _player.pauseOrPlayView.frame;
        fr.origin.y -= self.bottomView.height;
        _player.pauseOrPlayView.frame = fr;
    }
    return _player;
}

@end
