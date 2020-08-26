//
//  TSVideoAddTextCtrl.m
//  ThreeShow
//
//  Created by wkun on 2019/7/21.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSVideoAddTextCtrl.h"
#import "UIViewController+Ext.h"
#import "SBPlayer.h"
#import "DSVideoEditManager.h"
#import <AVFoundation/AVFoundation.h>
#import "TSEditNaviView.h"
//#import "TSEditTextView.h"
#import "IQLabelView.h"
#import "HTProgressHUD.h"

@interface TSVideoAddTextCtrl ()<SBPlayerDelegate,IQLabelViewDelegate>

@property (nonatomic, strong) TSEditNaviView *naviView;
@property (nonatomic, strong) SBPlayer *player;
@property (nonatomic, strong) IQLabelView* stickerView;  //文字贴图视图
@property (nonatomic, strong) HTProgressHUD *hud;

@end

@implementation TSVideoAddTextCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRgb_240_239_244];
    
    [self.player resetLocalVideoUrl:self.videoUrl];
    
    [self setPlayerFrame];
    
//    self.stickerView = [[TSEditTextView alloc] initWithBgView:/*self.imgView*/self.view image:nil withCenterPoint:/*self.imgView.center*/CGPointMake(SCREEN_WIDTH/2, self.player.center.y)];
    
//    self.stickerView.contentView.text = @"123";
//    [self.stickerView.contentView becomeFirstResponder];
//    [self.stickerView becomeFirstResponder];
    
    [self.stickerView.textField becomeFirstResponder];
    
    [self.view bringSubviewToFront:self.naviView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self.player pause];
}

- (void)dealloc{
    [self.stickerView hideEditingHandles];
    [self.stickerView removeFromSuperview];
    _stickerView = nil;
}

#pragma mark - 视频添加水印
- (void)addVideoWaterMark{
    //视频文字水印
    UIImage *img = [self.stickerView getChangeImage];
    _hud = [HTProgressHUD showMessage:@"制作中..." toView:self.view];
    [[DSVideoEditManager shareVideoEditManager] addWaterMarkWithImg:img frame:[self getWaterMarkInVideoFrame] inputVideoPath:self.videoUrl.path complteBlock:^(NSString * _Nonnull outputPath) {
        [_hud hide];
        if( outputPath ==nil ){
            [HTProgressHUD showError:@"添加水印失败"];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
            if( _completeBlock ){
                _completeBlock(([NSURL fileURLWithPath:outputPath]));
            }
        }
    }];
    
//    UITextField *tf = self.stickerView.textField;
//
//    _hud = [HTProgressHUD showMessage:@"制作中..." toView:self.view];
//    [[DSVideoEditManager shareVideoEditManager] addWaterMarkWithText:tf.text frame:[self getWaterMarkInVideoFrame] fnt:tf.font.pointSize transform:self.stickerView.transform inputVideoPath:self.videoUrl.path complteBlock:^(NSString * _Nonnull outputPath) {
//        [_hud hide];
//        if( outputPath ==nil ){
//            [HTProgressHUD showError:@"添加水印失败"];
//        }else{
//            [self.navigationController popViewControllerAnimated:YES];
//            if( _completeBlock ){
//                _completeBlock(([NSURL fileURLWithPath:outputPath]));
//            }
//        }
//    }];
}

- (CGSize)getVideoNaturalSize{
    AVAssetTrack *videoAssetTrack = [[self.player.anAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize naturalSize = videoAssetTrack.naturalSize;
    //得到视频大小，有可能是横向的，所以交换下宽高
    if( naturalSize.width > naturalSize.height ){
        CGFloat ih = naturalSize.height;
        naturalSize.height = naturalSize.width;
        naturalSize.width = ih;
    }
    return naturalSize;
}

//按视频比例缩放播放器的frame
- (void)setPlayerFrame{
    CGRect fr = CGRectMake(0, 0, SCREEN_WIDTH, self.naviView.y);
    CGSize size = fr.size;
    
    CGSize naturalSize = [self getVideoNaturalSize];
    size.width = (naturalSize.width/naturalSize.height)*size.height;
    fr.size = size;
    fr.origin.x = (SCREEN_WIDTH-size.width)/2;
    self.player.frame = fr;
}

- (CGRect)getWaterMarkInVideoFrame{
    CGRect rect = [self.stickerView convertRect:self.stickerView.textField.frame toView:self.player];
    
//    AVAssetTrack *videoAssetTrack = [[self.player.anAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize naturalSize = [self getVideoNaturalSize];//videoAssetTrack.naturalSize;
    
    CGFloat scale = naturalSize.width/self.player.width;
    rect.origin.x *= scale;
    rect.origin.y *= scale;
    rect.size.width  *= scale;
    rect.size.height *= scale;
    
    rect.origin.y = (naturalSize.height-rect.size.height-rect.origin.y);
    
    return rect;
}

#pragma mark - TouchEvents
- (void)handleClose{
    NSLog(@"%@",[_stickerView superview]);
//    [self dismissViewControllerAnimated:YES completion:nil];
//
//    return;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleSave{
    
    NSString *text = self.stickerView.textField.text;
    if( text == nil || [text isEqualToString:@""] ){
        
        [HTProgressHUD showError:@"文字不可以为空"];
        return;
    }
    
    //不存在贴图，点击保存，则直接返回
    if( [_stickerView superview] == nil ){
        [self.navigationController popViewControllerAnimated:YES];
//        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    //若是视频，则去给视频添加水印
    if( self.videoUrl ){
        
        [self addVideoWaterMark];
    }
}

#pragma mark - PlayerDelegate
- (void)playerStartPlay:(SBPlayer *)player{
    [self.view endEditing:YES];
}

- (void)playerPausePlay:(SBPlayer *)player{
    [self.view endEditing:YES];
}

- (void)player:(SBPlayer *)player controlViewChangeState:(BOOL)isShow{
    [self.view endEditing:YES];
}

#pragma mark - Getters
- (TSEditNaviView *)naviView {
    if( !_naviView ){
        _naviView = [[TSEditNaviView alloc] initWithTitle:NSLocalizedString(@"文字", nil) target:self cancleSel:@selector(handleClose) sureSel:@selector(handleSave)];
        CGFloat ih = BOTTOM_NOT_SAVE_HEIGHT+45+15;
        _naviView.frame = CGRectMake(0, SCREEN_HEIGHT-ih, SCREEN_WIDTH, ih);
        [self.view addSubview:_naviView];
    }
    return _naviView;
}


- (SBPlayer *)player {
    if( !_player ){
        _player = [[SBPlayer alloc] initWithUrl:[NSURL URLWithString:@""]];
        _player.largerBtn.enabled = NO;
        _player.isShowControlView = NO;
        _player.delegate = self;
        //        _player.allowsRotateScreen = NO;
        //设置标题
        //设置播放器背景颜色
        _player.backgroundColor = [UIColor clearColor];
//        设置播放器填充模式 默认SBLayerVideoGravityResizeAspectFill，可以不添加此语句
        _player.mode = SBLayerVideoGravityResizeAspectFill;
        //添加播放器到视图
        [self.view addSubview:_player];
        //约束，也可以使用Frame
        CGFloat iw = SCREEN_WIDTH;//self.view.frame.size.width;
        _player.frame = CGRectMake(0, 0, iw, self.naviView.y);
    }
    return _player;
}

- (IQLabelView *)stickerView{
    if( !_stickerView ){
        CGRect labelFrame = CGRectMake(SCREEN_WIDTH/2-30,SCREEN_HEIGHT/2-50-70,
                                       60, 50);
        
        IQLabelView *labelView = [[IQLabelView alloc] initWithFrame:labelFrame];
        [labelView setDelegate:self];
        [labelView setShowsContentShadow:NO];
        [labelView setEnableMoveRestriction:NO];
        [labelView setFontName:@"Helvetica-Bold"];//@"Baskerville-BoldItalic"];
        [labelView setFontSize:21.0];
        
        labelView.borderColor = [UIColor colorWithRed:0 green:160/255.0 blue:233/255.0 alpha:1];//[UIColor whiteColor];
//        labelView.edit_addimg_close drag
        labelView.closeImage = [UIImage imageNamed:@"edit_addimg_close"];
        labelView.rotateImage = [UIImage imageNamed:@"edit_addimg_drag"];
        labelView.enableClose = NO;
        
        [self.view addSubview:labelView];
        [self.view setUserInteractionEnabled:YES];
        
        _stickerView = labelView;
        
        [self addDoneBtnWithView:labelView.textField];
    }
    return _stickerView;
}


@end
