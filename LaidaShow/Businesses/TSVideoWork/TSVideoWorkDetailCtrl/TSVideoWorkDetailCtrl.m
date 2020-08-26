//
//  TSVideoWorkDetailCtrl.m
//  ThreeShow
//
//  Created by cgw on 2019/7/15.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSVideoWorkDetailCtrl.h"
#import "SBPlayer.h"
#import "UIView+LayoutMethods.h"
#import "TSVideoWorkDetailBottomView.h"
#import "TSProductionDetailModel.h"
#import "UIViewController+Ext.h"
#import "TSProductDataModel.h"
#import "HTProgressHUD.h"
#import "NSString+Ext.h"
#import "TSHelper.h"
#import "PPAudioPlay.h"
#import "UIButton+RotateAnimate.h"
#import "TSConstants.h"
#import "TSUserModel.h"
#import "TSProductionInfoView.h"
#import "XWSheetView.h"
#import "TSMyWorkDetailItemList.h"
#import "TSAlertView.h"
#import "TSMyWorkCtrl.h"
#import "TSCopyShareWorkPwdView.h"

@interface TSVideoWorkDetailCtrl ()<TSVideoWorkDetailBottomViewDelegate,PPAudioPlayDelegate>
@property (nonatomic, strong) SBPlayer *player;
@property (nonatomic, strong) TSVideoWorkDetailBottomView *bottomView;
@property (nonatomic, strong) TSProductionDetailModel *model;
@property (nonatomic, strong) UIButton *musicBtn;
@property (nonatomic, strong) HTProgressHUD *hud;
@end

@implementation TSVideoWorkDetailCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRgb_246_253_245];
    self.model = [TSProductionDetailModel productionDetailModelWithDm:self.dataModel];
    
    [self.player resetWithUrl:[NSURL URLWithString:self.model.videoUrl]];
    
    self.bottomView.model = self.model;
    
    self.musicBtn.hidden = YES;
    if( self.model.musicName ){
        if( self.model.musicUrl || self.model.dm.recordBase64 ){
            self.musicBtn.hidden = NO;
        }
    }
    
    BOOL isSelf = [self isSelfWork];
    
    if( isSelf ){
        [self addRightBarItemWithAction:@selector(handleRight) imgName:@"work_points_51"];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self.player pause];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [PPAudioPlay shareAudioPlay].delegate = self;
}

#pragma mark - private
//点赞或者取消
- (void)praiseOrCancle{
    //点赞 or 取消赞 需要登录
    if( [self isLoginedWithGotoLoginCtrl] == NO ) return;
    
    BOOL isPraise = !self.model.isPraised;
    [self.dataProcess praiseOrCancle:isPraise workId:[NSString stringWithObj:self.dataModel.ID] completeBlock:^(NSError *err) {
        [self dispatchAsyncMainQueueWithBlock:^{
            if( err ){
                [self showErrMsgWithError:err];
            }else{
                if( isPraise ){
                    [HTProgressHUD showSuccess:NSLocalizedString(@"WorkDetailPraisedSuccess", nil)];
                }else{
                    [HTProgressHUD showSuccess:NSLocalizedString(@"WorkDetailCancleSuccess", nil)];
                }
                
                self.model.isPraised = isPraise;
                self.bottomView.praiseBtn.selected = isPraise;
                NSInteger lastCount = self.bottomView.praiseBtn.titleLabel.text.integerValue;
                if( isPraise ) lastCount++;
                else lastCount--;
                if( lastCount < 0 ) lastCount = 0;
                self.model.praiseCount = @(lastCount).stringValue;
                
                self.dataModel.praise = _model.praiseCount;
                self.dataModel.liked = @(isPraise).stringValue;
                [self.bottomView.praiseBtn setTitle:@(lastCount).stringValue forState:UIControlStateNormal];
            }
        }];
    }];
}

- (void)playWorkMusic{
    NSString * newMusicUrl = [NSString stringWithFormat:@"%@%@",TSConstantProductImgMiddUrl,_model.musicUrl];
    
    NSLog(@"musicNmae - %@",self.model.musicName);
    NSLog(@"musicUrl - %@",_model.musicUrl);
    if( self.model.musicName ){
        //音乐
        PPAudioPlay *ap = [PPAudioPlay shareAudioPlay];
        if(self.musicBtn.selected ){//ap.playState == AudioPlayStatePlaying ){
            [ap endPlay];
            [self.musicBtn stopAnimation];
        }else{
            if( [_model.musicUrl isKindOfClass:[NSString class]] &&  _model.musicUrl.length > 1 &&
               [newMusicUrl containsString:@"http"]){
                [ap startPlayWithUrl:newMusicUrl];
            }else if( [NSString stringWithObj:_model.dm.recordBase64] ){
                [self dispatchAsyncQueueWithName:@"playQ" block:^{
                    NSData *playData = [NSString base64StrToData:_model.dm.recordBase64];
                    [ap startPlayAmrWithData:playData];
                }];
            }
            [self.musicBtn startAnimation];
        }
        
        self.musicBtn.selected = !self.musicBtn.isSelected;
    }
}

- (void)gotoBuyUrl{
    if( self.model.buyUrl ){
        NSString *textURL = self.model.buyUrl;//@"http://www.yoururl.com/";
        if( [textURL containsString:@"http"]==NO ){
            textURL = [NSString stringWithFormat:@"http://%@",textURL];
        }

        textURL = [textURL filterOutSpace];
        textURL = [textURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

        NSURL *cleanURL = [NSURL URLWithString:textURL];
        [[UIApplication sharedApplication] openURL:cleanURL];
    }
}

- (BOOL)isSelfWork{
    BOOL isSelf = NO;
    if( [self isLogined] ){
        NSString *uid = self.dataProcess.userModel.userId;
        NSString *workUid = [NSString stringWithObj:self.model.dm.uid];
        if( uid && workUid &&[uid isEqualToString: workUid] ){
            isSelf = YES;
        }
    }
    return  isSelf;
}

#pragma mark - ShareQRCode

- (void)shareQRCodeImg{
    NSString *shareUrl = [TSHelper shareWorkUrlWithWorkId:[NSString stringWithObj:self.model.dm.ID] isVideo:NO];
    UIImage *qrCodeImg = [self qrImgWithStr:shareUrl];
    
    UIImage *img = self.coverImg;//self.showView.imgs[0];
//    if( img == nil ) {
//        img = self.thumbImg;
//    }
    
    if( img == nil ) return;
    
    NSLog(@"%@",[img description]);
    [TSHelper shareWorkQRCodeWithWorkQRImg:qrCodeImg wrokImg:img completeBlock:^(BOOL isSaveToAlbum, NSError *err) {
        [self dispatchAsyncMainQueueWithBlock:^{
            if( err ){
                if( isSaveToAlbum ){
                    //@"保存失败"
                    [HTProgressHUD showError:NSLocalizedString(@"ReleaseSaveFaile", nil)];
                }else{
                    //@"分享失败"
                    [HTProgressHUD showError:NSLocalizedString(@"WorkDetailQRCodeImgShareFailed", nil)];
                }
            }else{
                if( isSaveToAlbum ){
                    //已保存成功
                    [HTProgressHUD showError:NSLocalizedString(@"WorkDetailSavedToTheAblum", nil)];
                }else{
//                    [HTProgressHUD showError:@"分享成功"];
                }
            }
        }];
    }];
}

//生成二维码图片
- (UIImage*)qrImgWithStr:(NSString*)qrStr{
    //创建过滤器
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    //过滤器恢复默认
    [filter setDefaults];
    
    //给过滤器添加数据
    NSString *string = qrStr;//@"http://www.cnblogs.com/PSSSCode/";
    
    //将NSString格式转化成NSData格式
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    [filter setValue:data forKeyPath:@"inputMessage"];
    
    //获取二维码过滤器生成的二维码
    CIImage *image = [filter outputImage];
    
    //将获取到的二维码添加到imageview上
    //    self.imageView.image =[UIImage imageWithCIImage:image];
    UIImage *img = [self createNonInterpolatedUIImageFormCIImage:image withSize:400];

    return img;
}

- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    
    CGRect extent = CGRectIntegral(image.extent);
    
    //设置比例
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 创建bitmap（位图）;
    
    size_t width = CGRectGetWidth(extent) * scale;
    
    size_t height = CGRectGetHeight(extent) * scale;
    
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    
    CGContextScaleCTM(bitmapRef, scale, scale);
    
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 保存bitmap到图片
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    
    CGContextRelease(bitmapRef);
    
    CGImageRelease(bitmapImage);
    
    return [UIImage imageWithCGImage:scaledImage];
}


#pragma mark - TouchEvents
- (void)handleMusicBtn:(UIButton*)btn{
    [self playWorkMusic];
}

- (void)handleRight{

    NSArray *titles = @[NSLocalizedString(@"WorkDetailSheetReportText", nil)];
    //是自己的作品
//    if( isSelf ){
    
    NSString *publicTitle = @"公开";
    NSString *pimg = @"more_public";
    if( !self.dataModel.isPublic.boolValue ){
        publicTitle = @"未公开";
        pimg = @"more_public_not";
    }
    
    titles = @[publicTitle,
               NSLocalizedString(@"WorkDetailSheetSaveVideo", nil),
               NSLocalizedString(@"WorkDetailSheetDeleteWork", nil)];
    NSArray *imgNames = @[pimg,@"more_video",@"more_delete"];

    if( !self.model.isCanOnline ){
        NSMutableArray *tempTitles = [NSMutableArray arrayWithArray:titles];
        [tempTitles removeObjectAtIndex:0];
        titles = tempTitles;
        
        NSMutableArray *tempImgs = [NSMutableArray arrayWithArray:imgNames];
        [tempImgs removeObjectAtIndex:0];
        imgNames = tempImgs;
    }


    TSMyWorkDetailItemList *itemList = [[TSMyWorkDetailItemList alloc] initWithTitles:titles imgNames:imgNames handleItemBlock:^(NSInteger idx) {
        
        NSInteger index = idx;

        if( index == 0 ){
            //公开或非公开
            [self requestWorkStatus];
        }
        //保存视频
        else if( index == 1 ){
            [self saveVideoToAlbum];
        }
        
        //删除作品
        else if( index == 2 ){
            //删除此作品
            __weak typeof(self) weakSelf = self;
            NSString *title = NSLocalizedString(@"WorkDetailConfirmDeleteWorkTitle", nil);
            NSString *msg = NSLocalizedString(@"WorkDetailConfirmDeleteWorkDes", nil);
            [TSAlertView showAlertWithTitle:title des:msg handleBlock:^(NSInteger index) {
                
                [weakSelf deleteWork];
            }];
        }
    }];
    [itemList show];
}

#pragma mark - 保存视频
- (void)saveVideoToAlbum{
    if( self.model.videoUrl==nil || [self.model.videoUrl containsString:@"http"]==NO ){
        [HTProgressHUD showError:@"保存视频失败"];
        return;
    }
    
    _hud = [HTProgressHUD showMessage:NSLocalizedString(@"WorkDetailDownloading", nil) toView:self.view];
    [self.dataProcess downLoadWorkVideoWithUrl:self.model.videoUrl completeBlock:^(NSString *videoFilePath, NSError *err) {
        [self dispatchAsyncMainQueueWithBlock:^{
            
            if( err ){
                [_hud hide];
                [self showErrMsgWithError:err];
            }else{
                
                [self saveVideo:videoFilePath];
            }
        }];
    }];
}

//videoPath为视频下载到本地之后的本地路径
- (void)saveVideo:(NSString *)videoPath{
    
    if (videoPath) {
        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoPath)) {
            //保存相册核心代码
            UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }else{
            [_hud hide];
            NSLog(@"保存失败,视频文件不能打开");
            [HTProgressHUD showError:@"保存失败，视频文件格式不支持"];
        }
    }
}
//保存视频完成之后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [_hud hide];
    if (error) {
        NSLog(@"保存视频失败%@", error.localizedDescription);
        [HTProgressHUD showError:@"保存失败"];
    }
    else {
        NSLog(@"保存视频成功");
        [HTProgressHUD showSuccess:NSLocalizedString(@"ReleaseSaveSuccess",nil)];//@"保存成功"
    }
}

#pragma mark - 删除作品
- (void)deleteWork{
//    self.dataModel.ID = @"8278251508ed4734985bb3c90ac19a2b";
    _hud = [HTProgressHUD showMessage:nil toView:self.view];
    [self.dataProcess deleteWorkWithId:[NSString stringWithObj:self.dataModel.ID] completeBlock:^(NSError *err) {
        [self dispatchAsyncMainQueueWithBlock:^{
            [_hud hide];
            if( err ){
                [self showErrMsgWithError:err];
            }else{
                [HTProgressHUD showSuccess:NSLocalizedString(@"WorkDeleteSuccess", nil)];
                [self.navigationController popViewControllerAnimated:YES];
                
                TSMyWorkCtrl *wc = [self getCtrlAtNavigationCtrlsWithCtrlClass:[TSMyWorkCtrl class]];
                if( wc ){
                    [wc reloadData];
                }
//                [[NSNotificationCenter defaultCenter] postNotificationName:TSConstantNotificationDeleteWorkOnLine object:nil];
            }
        }];
    }];
}

#pragma mark - 分享请求
- (void)requestWorkStatus{
    _hud = [HTProgressHUD showMessage:nil toView:self.view];
    [self.dataProcess updateWorkStateWithPublic:!_dataModel.isPublic.boolValue workId:_dataModel.ID completeBlock:^(NSError *err) {
       
        [self dispatchAsyncMainQueueWithBlock:^{
            [self.hud hide];
            if( err ){
                [self showErrMsgWithError:err];
            }else{
                
                _dataModel.isPublic = _dataModel.isPublic.boolValue?@0:@1;
                
                if( _dataModel.isPublic.boolValue ){
                    [HTProgressHUD showSuccess:NSLocalizedString(@"作品已公开到广场", nil)];
                }else{
                    [HTProgressHUD showSuccess:NSLocalizedString(@"作品已收到私人展厅", nil)];
                }
                
                //发送重加载数据消息
                [[NSNotificationCenter defaultCenter] postNotificationName:TSConstantNotificationLoginSuccess object:nil];
            }
        }];
    }];
}

- (void)requestGetSharePwd{
    
    _hud = [HTProgressHUD showMessage:nil toView:self.view];
    [self.dataProcess getPrivateWorkSharePwdWithWorkId:self.dataModel.ID completeBlock:^(NSString *pwd, NSError *err) {
   
       [self dispatchAsyncMainQueueWithBlock:^{
           [self.hud hide];
           if( err ){
               [self showErrMsgWithError:err];
           }else{
               
               if( ![pwd isKindOfClass:[NSString class]] ){
                   [HTProgressHUD showError:@"获取密码失败"];
               }
               else{
                   //得到密码
                   [self showCopyPwdViewWithPwd:pwd];
               }
           }
       }];
    }];
}

//取消分享的作品密码
- (void)requestCancleSharePwd{
    
    _hud = [HTProgressHUD showMessage:nil toView:self.view];
    [self.dataProcess canclePrivateWorkSharePwdWithWorkId:self.dataModel.ID completeBlock:^(NSError *err) {
   
       [self dispatchAsyncMainQueueWithBlock:^{
           [self.hud hide];
           if( err ){
               [self showErrMsgWithError:err];
           }else{
               //取消成功,展示分享视图
               [self showShareView];
           }
       }];
    }];
}

#pragma mark - 分享作品链接

- (void)showCopyPwdViewWithPwd:(NSString*)pwd{
    
    
    [self showShareView];
    
    //加载完分享视图后0.5秒，再展示复制密码视图
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        _copyPwdView =
        [TSCopyShareWorkPwdView showCopyPwdViewWithPwd:pwd];
    });
    
}

- (void)showShareSelectPwdView{
    NSString *des = @"检测到您当前要分享的作品是私人作品，为保证您产品的私密性，是否给分享链接设置密码，密码仅本次有效。如果您不设置密码，之前分享的链接也可以不用密码被打开哦！";
    [TSAlertView showAlertWithTitle:@"是否设置分享密码" des:des cancleTitle:@"否" sureTitle:@"是" needCancleBlock:YES handleBlock:^(NSInteger index) {
        if( index == 1 ){

            //否，不需要密码
            [self requestCancleSharePwd];
        }
        else {
            
            //是，需要密码
            [self requestGetSharePwd];
        }
    }];
}

- (void)showShareView{
    
    [TSHelper shareWorkWithWorkId:[NSString stringWithObj:self.model.dm.ID]
                              img:self.coverImg
                         workName:self.model.productName
                          isVideo:YES];
}

#pragma mark - delegate
- (void)videoWorkDetailBottomView:(TSVideoWorkDetailBottomView*)infoView handleBtnAtIndex:(NSUInteger)btnIndex isCancle:(BOOL)isCancle{
    if( btnIndex == 0 ){
        //购买
        [self gotoBuyUrl];
    }

    else if( btnIndex == 1 ){
        
        [self shareQRCodeImg];
    }
    else if( btnIndex == 2 ){
        //点赞
        [self praiseOrCancle];
    }
    else if( btnIndex == 3 ){
            
//        //收藏或取消收藏
//        [self collectOrCancle];
//        
//        //收藏或取消收藏则刷新数据
//        [[NSNotificationCenter defaultCenter] postNotificationName:TSConstantNotificationDeleteWorkOnLine object:nil];
    }
    else if( btnIndex == 4 ){
        //分享
        if( [self isSelfWork] ){
            //是自己的作品且是私有的，则弹出是否需要密码弹窗
            if( self.dataModel.isPublic.boolValue ==NO ){
                [self showShareSelectPwdView];
            }
            
            //是自己作品，但是公开的，则直接分享
            else{
                [self showShareView];
            }
        }else{
            //不是自己的作品，直接分享
            [self showShareView];
        }
    }
}

#pragma mark - PPAudioPlayDelegate
- (void)audioPlayEndPlay:(PPAudioPlay *)auidoPlay{
    [self.musicBtn stopAnimation];
}

#pragma mark - Getters
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

- (TSVideoWorkDetailBottomView *)bottomView {
    if( !_bottomView ){
        _bottomView = [[TSVideoWorkDetailBottomView alloc] init];
        _bottomView.backgroundColor = [UIColor clearColor];
        _bottomView.delegate = self;
        
        CGFloat ih = 50;//190+10+26;
        CGFloat iy = SCREEN_HEIGHT-ih-BOTTOM_NOT_SAVE_HEIGHT;
        _bottomView.frame = CGRectMake(0, iy, SCREEN_WIDTH, ih);
        [self.view addSubview:_bottomView];
    }
    return _bottomView;
}

- (UIButton *)musicBtn {
    if( !_musicBtn ){
        _musicBtn = [UIButton new];
        CGFloat wh = 44,iy = 76-64 + NAVGATION_VIEW_HEIGHT;
        _musicBtn.frame = CGRectMake(SCREEN_WIDTH-15-wh, iy, wh, wh);
        [_musicBtn setImage:[UIImage imageNamed:@"work_music"] forState:UIControlStateNormal];
        _musicBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_musicBtn addTarget:self action:@selector(handleMusicBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_musicBtn];
    }
    return _musicBtn;
}

@end
