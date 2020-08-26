//
//  TSProductionDetailCtrl.m
//  ThreeShow
//
//  Created by hitomedia on 08/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSProductionDetailCtrl.h"
#import "UIViewController+Ext.h"
#import "TSProductionShowView.h"
#import "TSProductionDetailModel.h"
#import "TSProductionInfoView.h"
#import "XWSheetView.h"
#import "TSUserModel.h"
#import "NSString+Ext.h"
#import "TSProductDataModel.h"
#import "HTProgressHUD.h"
#import "PPAudioPlay.h"
#import "UIButton+RotateAnimate.h"
#import "TSHelper.h"
#import "TSReportCtrl.h"
#import "TSConstants.h"
#import "TSAlertView.h"
#import "SBPlayer.h"
#import "XWShareView.h"
#import "TSReportView.h"
#import "TSMyWorkDetailItemList.h"
#import "TSOnlineServiceCtrl.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "YQAssetOperator.h"
#import "TSUploadLaidaPlatformCtrl.h"
#import "TSCopyShareWorkPwdView.h"

@interface TSProductionDetailCtrl ()<TSProductionInfoViewDelegate,PPAudioPlayDelegate,SBPlayerDelegate>

@property (nonatomic, strong) TSProductionDetailModel *model;
@property (nonatomic, strong) TSProductionShowView *showView;
@property (nonatomic, strong) UIButton *showBottomViewBtn;
@property (nonatomic, strong) TSProductionInfoView *infoView;
@property (nonatomic, strong) HTProgressHUD *hud;
@property (nonatomic, strong) UIButton *photoBtn;
@property (nonatomic, strong) UIButton *videoBtn;
@property (nonatomic, strong) SBPlayer *player;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) NSMutableArray *saveToAlbumImgs; //保存到相册的图片
@property (nonatomic, strong) UIButton *musicBtn;

//@property (nonatomic, strong) TSCopyShareWorkPwdView *copyPwdView;

@end

@implementation TSProductionDetailCtrl

- (instancetype)init{
    self = [super init];
    if( self ){
        _titleView = [self getTitleView];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TSConstantNotificationLoginSuccess object:nil];
}

- (void)loginSuccessNoti{
    if( self.model.dm.ID ){
        [self requestWorkDetailWithId:self.model.dm.ID];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.clipsToBounds = YES;
    [self changeBackBarItemWithAction:@selector(handleBack)];
    [self addRightBarItemWithAction:@selector(handleRight) imgName:@"work_points_51"];
    self.navigationItem.titleView = _titleView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessNoti) name:TSConstantNotificationLoginSuccess object:nil];
    
    [self reloadData];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_hud hide];
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    [PPAudioPlay shareAudioPlay].delegate = self;
    
    //禁用左滑
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];

    [PPAudioPlay shareAudioPlay].needEndWhenStartPlaying = YES;
    [[PPAudioPlay shareAudioPlay] endPlay];

    [PPAudioPlay shareAudioPlay].delegate = nil;
    
    //打开左滑
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    
    //    [HTProgressHUD showSuccess:@"内存不足"];
    NSLog(@"%s___内存不足",__func__);
#warning 暂时去掉内存不足时，内存的释放，以避免一些正在用的数据被释放掉。以后再优化
    return;
    
    if( [self.view window] == nil ){
        
        [_showView removeFromSuperview];
        _showView = nil;
        
        _model = nil;
        [_showBottomViewBtn removeFromSuperview];
        _showBottomViewBtn = nil;
        
        [_infoView removeFromSuperview];
        _infoView = nil;
        
        [_hud hide];
        _hud = nil;
        
        [_photoBtn removeFromSuperview];
        _photoBtn = nil;
        
        [_videoBtn removeFromSuperview];
        _videoBtn = nil;
        
        [_player removeFromSuperview];
        _player = nil;
        
        [_saveToAlbumImgs removeAllObjects];
        _saveToAlbumImgs = nil;
        
        [_musicBtn removeFromSuperview];
        _musicBtn = nil;
    }
}

#pragma mark - Public
- (void)reloadData{
 
    self.showView.userInteractionEnabled = NO;
    
    self.model = [TSProductionDetailModel productionDetailModelWithDm:self.dataModel];
    
    BOOL showTitleView = (self.model.videoUrl);
    _titleView.hidden = !showTitleView;
    self.player.hidden = !showTitleView;
    

    [self updateViewStatusWithIsShowPhoto:YES];
    
    if( showTitleView ){
//        self.model.videoUrl = @"https://vd3.bdstatic.com/mda-jd3v2uyeez5jnvwz/sc/mda-jd3v2uyeez5jnvwz.mp4";
//        self.model.videoUrl = @"https://schen-user.oss-cn-shenzhen.aliyuncs.com/show/3DShowDemonstration.mp4";
        [self.player resetWithUrl:[NSURL URLWithString:self.model.videoUrl]];
    }
    
    self.showView.imgUrls = self.model.imgUrls;
    
    [self.showView reloadData];
    
    self.infoView.model = self.model;
    
    self.infoView.hidden = NO;
    self.showBottomViewBtn.hidden = YES;
    
    [self.view bringSubviewToFront:self.infoView];
    
    self.musicBtn.hidden = YES;
    if( self.model.musicName ){
        if( self.model.musicUrl || self.model.dm.recordBase64 ){
            self.musicBtn.hidden = NO;
        }
    }
}

#pragma mark - Private

- (void)clearData{
    [self.showView stopAnimate];
    
    _model = nil;
    self.showView.imgUrls = nil;
}

- (void)handleSheetIndex:(NSUInteger)idx isSelf:(BOOL)isSelf{
    
    //举报
    [TSReportView showReportInView:self.view];
    
    return;
    
    if( idx == 0 ){
        if( isSelf ==NO ){
            //举报
            [TSReportView showReportInView:self.view];
//            TSReportCtrl *rc = [TSReportCtrl new];
////            [self pushViewCtrl:rc];
//            [self.navigationController pushViewController:rc animated:NO];
        }else {
            //保存全部视频
            [self saveVideoToAlbum];
        }
    }else if( idx == 1 ){
        //保存全部图片
        [self saveAllImgToAlbum];
    }else if( idx == 2){
        //删除此作品
        __weak typeof(self) weakSelf = self;
        NSString *title = NSLocalizedString(@"WorkDetailConfirmDeleteWorkTitle", nil);
        NSString *msg = NSLocalizedString(@"WorkDetailConfirmDeleteWorkDes", nil);
        [TSAlertView showAlertWithTitle:title des:msg handleBlock:^(NSInteger index) {
            
            [weakSelf deleteWork];
        }];
    }
}

//点赞或者取消
- (void)praiseOrCancle{
    //点赞 or 取消赞 需要登录
    if( [self isLoginedWithGotoLoginCtrl] == NO ) return;
    
    BOOL isPraise = !self.model.isPraised;
    [self.dataProcess praiseOrCancle:isPraise workId:[NSString stringWithObj:self.model.dm.ID] completeBlock:^(NSError *err) {
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
                self.infoView.praiseBtn.selected = isPraise;
                NSInteger lastCount = self.infoView.praiseBtn.titleLabel.text.integerValue;
                if( isPraise ) lastCount++;
                else lastCount--;
                if( lastCount < 0 ) lastCount = 0;
                self.model.praiseCount = @(lastCount).stringValue;
                
                self.dataModel.praise = _model.praiseCount;
                self.dataModel.liked = @(isPraise).stringValue;
                [self.infoView.praiseBtn setTitle:@(lastCount).stringValue forState:UIControlStateNormal];
            }
        }];
    }];
}

- (void)collectOrCancle{
    //收藏 or 取消 需要登录
    if( [self isLoginedWithGotoLoginCtrl] == NO ) return;
    
    BOOL isCollected = !self.model.isCollected;
    [self.dataProcess collectOrCancle:isCollected workId:[NSString stringWithObj:self.model.dm.ID] completeBlock:^(NSError *err) {
        [self dispatchAsyncMainQueueWithBlock:^{
            if( err ){
                [self showErrMsgWithError:err];
            }else{
                if( isCollected ){
                    [HTProgressHUD showSuccess:NSLocalizedString(@"WorkDetailCollectedSuccess", nil)];
                }else{
                    [HTProgressHUD showSuccess:NSLocalizedString(@"WorkDetailCancleCollectedSuccess", nil)];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:TSConstantNotificationUserCancleCollect object:nil];
                }
                
                self.model.isCollected = isCollected;
                self.infoView.collectBtn.selected = isCollected;
                NSInteger lastCount = self.infoView.collectBtn.titleLabel.text.integerValue;
                if( isCollected ) lastCount++;
                else lastCount--;
                if( lastCount < 0 ) lastCount = 0;
                self.model.collectCount = @(lastCount).stringValue;
                
                self.dataModel.collectCount = @(lastCount).stringValue;
                self.dataModel.collected = @(isCollected).stringValue;
                [self.infoView.collectBtn setTitle:@(lastCount).stringValue forState:UIControlStateNormal];
            }
        }];
    }];
}

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
                [[NSNotificationCenter defaultCenter] postNotificationName:TSConstantNotificationDeleteWorkOnLine object:nil];
            }
        }];
    }];
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

//保存当前图片至相册
- (void)saveCurrImgToAlbum{
    _hud = [HTProgressHUD showMessage:nil toView:self.view];
    [self dispatchAsyncQueueWithName:@"saveCurrImgQ" block:^{
        
        UIImage *img = self.showView.imgView.image;
        if( [img isKindOfClass:[UIImage class]] ){
            UIImageWriteToSavedPhotosAlbum(img, self, nil, nil);
        }
        [self dispatchAsyncMainQueueWithBlock:^{
            [self.hud hide];
            [HTProgressHUD showSuccess:NSLocalizedString(@"WorkDetailSavedToTheAblum", nil)];///@"已保存至相册"];
        }];
    }];
}

//保存所有图片至相册
- (void)saveAllImgToAlbum{
    
    [self dispatchAsyncQueueWithName:@"saveAllImgQ" block:^{
        if( _saveToAlbumImgs == nil ){
            _saveToAlbumImgs = [NSMutableArray new];
        }
        [_saveToAlbumImgs removeAllObjects];
        [_saveToAlbumImgs addObjectsFromArray:self.showView.imgs];
    
        [self saveNext];
    }];
}

//- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
//    if (error != NULL) {
//        NSLog(@"保存失败");
//    } else {
//        NSLog(@"保存成功");
//    }
//}

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

- (void)updateIsShowWorkInfoView:(BOOL)showInfoView{
    self.infoView.hidden = !showInfoView;
    self.showBottomViewBtn.hidden = showInfoView;
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

#pragma mark __保存照片到相册
-(void) saveNext{
    NSMutableArray *listOfImages = _saveToAlbumImgs;
    if (listOfImages.count > 0) {
        UIImage *image = [listOfImages objectAtIndex:0];
    
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
    }
    else {
        [self allDone];
    }
}

//- (void)saveAllImageToAlbumFinish:(id)obj{

-(void)savedPhotoImage:(UIImage*)image didFinishSavingWithError: (NSError *)error contextInfo: (void *)contextInfo {
    
    if (error) {
        //NSLog(@"%@", error.localizedDescription);
    }
    else
    {
        NSMutableArray *listOfImages = _saveToAlbumImgs;
        [listOfImages removeObjectAtIndex:0];
    }
    [self saveNext];
}

- (void)allDone{
    [self dispatchAsyncMainQueueWithBlock:^{
        [HTProgressHUD showSuccess:NSLocalizedString(@"WorkDetailSavedToTheAblum", nil)];//@"已保存至相册"];
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
    UIImage *img = nil;
    if( self.showView.animateImgs.count ){
       img = self.showView.animateImgs[0];
    }
    //分享
    NSString *wid = [NSString stringWithObj:self.model.dm.ID];
    [TSHelper shareWorkWithWorkId:wid img:img
                         workName:self.model.productName
                          isVideo:self.showView.isHidden];
}

#pragma mark - 作品视频部分
- (UIView*)getTitleView{
    UIView *titleView = [UIView new];
    titleView.frame = CGRectMake(0, 0, 70*2, 40);
    titleView.backgroundColor = [UIColor clearColor];
    
    NSArray *titles = @[NSLocalizedString(@"WorkDetailImageBtnTitle", nil),NSLocalizedString(@"WorkDetailVideoBtnTitle", nil)];
//    NSArray *colors = @[[UIColor colorWithRgb_0_151_216],[UIColor colorWithRgb102]];
    
    for( NSUInteger i=0; i<titles.count; i++ ){
        UIButton *btn = [UIButton new];
//        btn.enabled = (i==1);
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:17];
        [btn setTitleColor:[UIColor colorWithRgb102] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRgb_0_151_216] forState:UIControlStateSelected];
        
        [btn addTarget:self action:@selector(handleTitleBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitleColor:[UIColor colorWithRgb51] forState:UIControlStateHighlighted];
      
        if( i==1){
            _videoBtn = btn;
        }else{
            _photoBtn = btn;
        }
        
        CGFloat iw = 70,ih = titleView.height;
        CGFloat ix = i*iw;
        btn.frame = CGRectMake(ix, 0, iw, ih);
        [titleView addSubview:btn];
    }
    
    return titleView;
}

- (void)updateViewStatusWithIsShowPhoto:(BOOL)showPhoto{
    
    _photoBtn.selected = showPhoto;
    _videoBtn.selected = !showPhoto;
    self.player.hidden = showPhoto;
    self.showView.hidden = !showPhoto;
}

- (void)playerStartPlay:(SBPlayer *)player{
    if( self.infoView.hidden == NO )
        [self updateIsShowWorkInfoView:NO];
    
    self.showBottomViewBtn.hidden = YES;
}

- (void)playerPausePlay:(SBPlayer *)player{
    if( self.infoView.hidden ){
        [self updateIsShowWorkInfoView:YES];
    }
    
    self.showBottomViewBtn.hidden = NO;
}

#pragma mark - ShareQRCode

- (void)shareQRCodeImg{
    NSString *shareUrl = [TSHelper shareWorkUrlWithWorkId:[NSString stringWithObj:self.model.dm.ID] isVideo:NO];
    UIImage *qrCodeImg = [self qrImgWithStr:shareUrl];
    
    UIImage *img = nil;//self.showView.imgs[0];
    
    if( self.showView.imgs.count ){
        img = self.showView.imgs[0];
    }
    
    if( img == nil ){
        if( self.showView.animateImgs.count ){
            img = self.showView.animateImgs[0];
        }
    }
    if( img == nil ) {
        img = self.thumbImg;
    }
    
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

#pragma mark - Request
- (void)requestWorkDetailWithId:(NSString*)wid{
    _hud = [HTProgressHUD showMessage:nil toView:self.view];
    [self dispatchAsyncQueueWithName:@"detailQ" block:^{
        [self.dataProcess workDetailWithId:wid completeBlock:^(TSProductDataModel *dataModel, NSError *er) {
            [self dispatchAsyncMainQueueWithBlock:^{
                [_hud hide];
                
                if( er ){
                    [self showErrMsgWithError:er];
                }else{
//                    [self gotoDetailCtrlWithDm:dataModel];
                    
                    self.dataModel = dataModel;
                    self.model = [TSProductionDetailModel productionDetailModelWithDm:self.dataModel];
                    
                    self.infoView.model = self.model;
//                    [self reloadData];
                }
            }];
        }];
    }];
}

- (void)requestDownloadGifWithUrl:(NSString*)url{
    
    _hud = [HTProgressHUD showMessage:nil toView:self.view];
    
    [self dispatchAsyncQueueWithName:@"downloadGifQ" block:^{
       
        NSString *fileName = @"savegiftemp";
        NSString *savePath = NSTemporaryDirectory();
        
        //若文件已存在，则清除之前的
        NSString* fileAllName = [NSString stringWithFormat:@"%@.%@",fileName,url.pathExtension];
        NSString *fileAllPath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileAllName];
        NSFileManager *fm = [NSFileManager defaultManager];
        if( [fm fileExistsAtPath:fileAllPath] ){
            [fm removeItemAtPath:fileAllPath error:nil];
        }
        
        [self.dataProcess dowloadImg:url saveImgPath:savePath saveImgName:fileName completeBlock:^(UIImage *img, NSString *path, NSError *err) {
            
            if( err == nil ){
                YQAssetOperator *asset = [[YQAssetOperator alloc] initWithFolderName:@"Gif"];
                
                [asset saveImagePath:path];
            }
            [self dispatchAsyncMainQueueWithBlock:^{
                [_hud hide];
                if( err ){
                    [self showErrMsgWithError:err];
                }else{
                    [HTProgressHUD showSuccess:NSLocalizedString(@"ReleaseSaveSuccess", nil)];
                }
            }];
        }];
        
    }];
}

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


#pragma mark - ProductInfoViewDelegate
- (void)productionInfoView:(TSProductionInfoView *)infoView handleBtnAtIndex:(NSUInteger)btnIndex isCancle:(BOOL)isCancle{
    
    //点击搭按钮
    if( btnIndex == 11 ){
        TSUploadLaidaPlatformCtrl *pc = [TSUploadLaidaPlatformCtrl new];
        pc.workId = self.dataModel.ID;
        [self pushViewCtrl:pc];
        return;
    }
  
    if( btnIndex == 0 ){
        //购买
        [self gotoBuyUrl];
    }
    
    else if( btnIndex == 1 ){
        
        [self shareQRCodeImg];
//        [self showAlertViewWithTitle:@"二维码" msg:nil okBlock:^{
//
//        } cancleBlock:nil];

    }else if( btnIndex == 2 ){
        
//        if(![self isLoginedWithGotoLoginCtrl]) return;
        //点赞或取消赞
        [self praiseOrCancle];
        
        //收藏或取消收藏则刷新数据
        [[NSNotificationCenter defaultCenter] postNotificationName:TSConstantNotificationDeleteWorkOnLine object:nil];
        
    }else if( btnIndex == 3 ){
        
//        if(![self isLoginedWithGotoLoginCtrl]) return;
        //收藏或取消收藏
        [self collectOrCancle];
        
        //收藏或取消收藏则刷新数据
        [[NSNotificationCenter defaultCenter] postNotificationName:TSConstantNotificationDeleteWorkOnLine object:nil];
        
    }else if (btnIndex == 4 ){
        
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

#pragma mark - TouchEvents
- (void)handleRight{

    NSArray *titles = @[NSLocalizedString(@"WorkDetailSheetReportText", nil)];
    
    BOOL isSelf = [self isSelfWork];
    //是自己的作品
    if( isSelf ){
        NSString *publicTitle = @"公开";
        NSString *pimg = @"more_public";
        if( !self.dataModel.isPublic.boolValue ){
            publicTitle = @"未公开";
            pimg = @"more_public_not";
        }
        titles = @[NSLocalizedString(@"WorkOnlineServiceTitle", nil),
                   NSLocalizedString(publicTitle, nil),
                   NSLocalizedString(@"WorkDetailSheetSaveVideo", nil),
                   NSLocalizedString(@"WorkDetailSheetSaveGif", nil),
                   NSLocalizedString(@"WorkDetailSheetSaveThisImg", nil),
                   NSLocalizedString(@"WorkDetailSheetSaveWholeImg", nil),
                   NSLocalizedString(@"WorkDetailSheetDeleteWork", nil)];
        NSArray *imgNames = @[@"more_service",pimg,@"more_video",@"more_gif",@"more_photo",@"more_photos",@"more_delete"];
        
        if( !self.model.isCanOnline ){
            NSMutableArray *tempTitles = [NSMutableArray arrayWithArray:titles];
            [tempTitles removeObjectAtIndex:0];
            titles = tempTitles;
            
            NSMutableArray *tempImgs = [NSMutableArray arrayWithArray:imgNames];
            [tempImgs removeObjectAtIndex:0];
            imgNames = tempImgs;
        }
        
        //若在播放图片，则不展示保存当前图片
        if( self.showView.isAnimate ){
            
            NSInteger saveCurrPhotoIndex = titles.count-1-2;
            NSMutableArray *tempTitles = [NSMutableArray arrayWithArray:titles];
            [tempTitles removeObjectAtIndex:saveCurrPhotoIndex];
            titles = tempTitles;
            
            NSMutableArray *tempImgs = [NSMutableArray arrayWithArray:imgNames];
            [tempImgs removeObjectAtIndex:saveCurrPhotoIndex];
            imgNames = tempImgs;
        }
        
        TSMyWorkDetailItemList *itemList = [[TSMyWorkDetailItemList alloc] initWithTitles:titles imgNames:imgNames handleItemBlock:^(NSInteger idx) {
            
            NSInteger index = idx;
            if( !self.model.isCanOnline ){
                index ++;
            }
            
            //若图片正在轮播，则不展示保存当前图片按钮
            NSInteger minusCount = 0;
            if( self.showView.isAnimate ){
                minusCount = 1;
            }
            
            //在线服务
            if( index == 0 ){
                TSOnlineServiceCtrl *sc = [TSOnlineServiceCtrl new];
                sc.detailModel = self.model;
                [self pushViewCtrl:sc];
            }
            
            else if( index == 1 ){
                //公开和未公开
                
                [self requestWorkStatus];
            }
            
            //保存视频
            else if( index == 2 ){
                [self saveVideoToAlbum];
            }
            
            //保存Gif图片
            else if( index == 3 ){
//                [self saveCurrImgToAlbum];
                
                [self requestDownloadGifWithUrl:self.model.gifUrl];
            }
     
            /*  当minusCount为1 时，则优先进入保存全部图片，忽略保存当前图片
             *  所以将保存全部图片，放在保存当前图片前面
             */
            
            //保存全部图片
            else if( index == 5-minusCount ){
                [self saveAllImgToAlbum];
            }
            
            //保存当前图片
            else if( index == 4 ){
                [self saveCurrImgToAlbum];
            }
            
            //删除作品
            else if( index == 6-minusCount ){
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
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [XWSheetView showWithTitles:titles handleIndexBlock:^(NSInteger index) {
        [weakSelf handleSheetIndex:index isSelf:isSelf];
    }];
}

- (void)handleBack{
    [PPAudioPlay shareAudioPlay].needEndWhenStartPlaying = YES;
    [self.navigationController popViewControllerAnimated:YES];
    
    [self clearData];
}

- (void)handleShowImgView{

//    self.infoView.hidden = !self.infoView.isHidden;
//    self.showBottomViewBtn.hidden = !self.infoView.isHidden;
    
    [self updateIsShowWorkInfoView:self.infoView.isHidden];
}

- (void)handleLongPressShowImgView{
    [TSAlertView showAlertWithTitle:NSLocalizedString(@"WorkDetailSiglePhotoSaveDes", nil) handleBlock:^(NSInteger index) {
        UIImage *image = self.showView.imgView.image;
        if( image ){
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            [HTProgressHUD showSuccess:NSLocalizedString(@"WorkDetailSavedToTheAblum", nil)];//@"已保存至相册"];
        }
    }];
}

- (void)handleTitleBtn:(UIButton*)btn{
    if( btn.isSelected) return;
    
    BOOL showPhoto = NO;
    if( [btn isEqual:_photoBtn] ){
        //照片
        showPhoto = YES;
        [self.player pause];
        
        self.showBottomViewBtn.hidden = !self.infoView.isHidden;
    }
    else{
        //视频
        showPhoto = NO;
        self.showBottomViewBtn.hidden = YES;
        [self.player setSubViewsIsHide:NO];
    }
    
    [self updateViewStatusWithIsShowPhoto:showPhoto];
}

- (void)handleMusicBtn:(UIButton*)btn{
    [self playWorkMusic];
}

#pragma mark - Propertys

- (TSProductionShowView *)showView {
    if( !_showView ){
        _showView = [[TSProductionShowView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        __weak typeof(self) weakSelf = self;
        _showView.handleTapBlock = ^(TSProductionShowView *infoView) {
//            [weakSelf handleShowImgView];
        };
        _showView.loadCompleteBlock = ^(TSProductionShowView *infoView) {
//            [weakSelf getButtonAtRightBarItem].enabled = YES;
            weakSelf.showView.userInteractionEnabled = YES;
        };
        
        _showView.handleLongPressBlock = ^(TSProductionShowView *infoView) {
            [weakSelf handleLongPressShowImgView];
        };
        [self.view addSubview:_showView];
    }
    return _showView;
}

- (TSProductionInfoView *)infoView {
    if( !_infoView ){
        _infoView = [[TSProductionInfoView alloc] init];
        _infoView.backgroundColor = [UIColor clearColor];
        _infoView.delegate = self;

        CGFloat ih = 50;//190+10+26;
        CGFloat iy = SCREEN_HEIGHT-ih-BOTTOM_NOT_SAVE_HEIGHT;
        _infoView.frame = CGRectMake(0, iy, SCREEN_WIDTH, ih);
        [self.view addSubview:_infoView];
        
        self.musicBtn.hidden = NO;
    }
    return _infoView;
}

//- (UIButton *)showBottomViewBtn {
//    if( !_showBottomViewBtn ){
//        _showBottomViewBtn = [[UIButton alloc] init];
//        [_showBottomViewBtn setImage:[UIImage imageNamed:@"arrow_up_51"] forState:UIControlStateNormal];
//        
//        CGFloat ih = 44;
//        _showBottomViewBtn.frame = CGRectMake(0, SCREEN_HEIGHT-ih-BOTTOM_NOT_SAVE_HEIGHT, SCREEN_WIDTH, ih);
//        _showBottomViewBtn.hidden = YES;
//        [_showBottomViewBtn addTarget:self action:@selector(handleShowImgView) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:_showBottomViewBtn];
//    }
//    return _showBottomViewBtn;
//}

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
//        [_player mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(@0);
//            make.top.mas_equalTo(@0);
//            make.width.mas_equalTo(@(SCREEN_WIDTH));
//            make.height.mas_equalTo(@(SCREEN_HEIGHT));
//        }];
    }
    return _player;
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
