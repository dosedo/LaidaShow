//
//  TSLocalWorkDetailCtrl.m
//  ThreeShow
//
//  Created by hitomedia on 16/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//  metwen

#import "TSLocalWorkDetailCtrl.h"
#import "UIViewController+Ext.h"
#import "TSProductionShowView.h"
#import "TSProductionDetailModel.h"
#import "TSLocalWorkInfoView.h"
#import "TSWorkModel.h"
#import "TSProductDataModel.h"
#import "TSEditWorkCtrl.h"
#import "HTProgressHUD.h"
#import "PPAudioPlay.h"
#import "UIButton+RotateAnimate.h"
#import "XWSheetView.h"
#import "PPLocalFileManager.h"
#import "PPFileManager.h"
#import "TSConstants.h"
#import "TSWorkReleaseView.h"
#import "NSString+Ext.h"
#import "TSUserModel.h"
#import "HTProgressHUD.h"
#import "TSHelper.h"
#import "TSCategoryModel.h"
#import "TSLoginCtrl.h"
#import "TSClearWorkBgCtrl.h"
#import "TSAlertView.h"
#import "TSMyWorkDetailItemList.h"
#import "TSProductDataModel.h"
#import "SBPlayer.h"
#import "TSPublishWorkCtrl.h"

#import "TSEditVideoWorkCtrl.h"

@interface TSLocalWorkDetailCtrl ()<TSLocalWorkInfoViewDelegate,PPAudioPlayDelegate>

//@property (nonatomic, strong) TSProductionDetailModel *model;
@property (nonatomic, strong) TSProductionShowView *showView;
@property (nonatomic, strong) UIButton *showBottomViewBtn;
@property (nonatomic, strong) TSLocalWorkInfoView *infoView;
@property (nonatomic, strong) HTProgressHUD *hud;
@property (nonatomic, strong) TSEditWorkCtrl *editCtrl;
@property (nonatomic, strong) UIButton *switchBtn;
@property (nonatomic, strong) UIButton *musicBtn;
@property (nonatomic, strong) SBPlayer *player;

@end

@implementation TSLocalWorkDetailCtrl{
    NSMutableArray *_saveToAlbumImgs;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.clipsToBounds = YES;
    [self changeBackBarItemWithAction:@selector(handleBack)];
    [self addRightBarItemWithTitle:NSLocalizedString(@"WorkEdit", nil) action:@selector(handleEdit)];//@"编辑"

    if( self.model.isVideoWork ){
        [self.player resetWithUrl:[NSURL fileURLWithPath:self.model.videoPath]];
        self.player.hidden = NO;
        self.showView.hidden = YES;
    }else{
        self.player.hidden = YES;
        self.showView.hidden = NO;
    }
    
    [self reloadData];
    
    self.switchBtn.selected = NO;//!self.model.showClearBg;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    
    double am = [self availableMemory];
    double um = [self usedMemory];
    NSLog(@"%s___内存不足__awailable=%fMB,used=%fMB",__func__,am,um);
    
//    if( [self.view window] == nil ){
//
//        [self.showView removeFromSuperview];
//        self.view = nil;
//        self.showView = nil;
//    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.switchBtn.hidden = ![self isClearedBg];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [PPAudioPlay shareAudioPlay].delegate = self;
    
//    [self.view bringSubviewToFront:self.switchBtn];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [PPAudioPlay shareAudioPlay].needEndWhenStartPlaying = YES;
    [[PPAudioPlay shareAudioPlay] endPlay];
    
    [self.player pause];
}

#pragma mark - Notification
- (void)dealloc{
    [self removeNotifications];
    
    [_saveToAlbumImgs removeAllObjects];
    _saveToAlbumImgs = nil;
}

#pragma mark - Notifications
- (void)addNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:TSConstantNotificationLoginSuccess object:nil];
}

- (void)removeNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TSConstantNotificationLoginSuccess object:nil];
}

- (void)loginSuccess{
    CGFloat ih = 190+10+26;
    CGFloat iy = SCREEN_HEIGHT-ih-BOTTOM_NOT_SAVE_HEIGHT;
    self.infoView.frame = CGRectMake(0, iy, SCREEN_WIDTH, ih);
    
//    self.infoView.headImgView.hidden = NO;
//    self.infoView.userNameL.hidden = NO;
    self.infoView.model = _infoView.model;
}

#pragma mark - Public
- (void)reloadData{

    [self dispatchAsyncQueueWithName:@"loadImgs" block:^{
        NSArray *imgs = nil;
        if( self.model.imgArr ){
            imgs = self.model.imgArr;
        }
        else {
            
            NSArray *paths = self.model.imgPathArr;
            //若已经退底，显示退底图
            if( self.model.clearBgImgPathArr.count ){
                paths = self.model.clearBgImgPathArr;
            }
            NSMutableArray *newArr = [NSMutableArray new];
            for( NSString *path in paths ){
                if( [path isKindOfClass:[NSString class]] ){
                    //解决了一个内存问题
                    NSData *imageData = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
                    UIImage * img = [UIImage imageWithData:imageData];
                    if( img ){
                        [newArr addObject:img];
                    }
                }
            }
            if( newArr.count ) imgs = newArr;
        }

        TSProductionDetailModel *pm = [TSProductionDetailModel productionDetailModelWithWorkModel:self.model];
        
        [self dispatchAsyncMainQueueWithBlock:^{
            self.showView.imgs = imgs;
            [self.showView reloadData];
            self.infoView.model = pm;
            
            self.musicBtn.hidden = YES;
            if( self.model.musicName ){
                if( self.model.recordPath || self.model.musicUrl ){
                    self.musicBtn.hidden = NO;
                }
            }
            self.inputView.hidden = NO;
        }];
    }];
}

#pragma mark - Private

- (BOOL)isClearedBg{
    if(self.model.clearBgImgPathArr.count && self.model.maskImgPathArr.count ){
        return YES;
    }
    
    return NO;
}

- (void)clearData{
    [self.showView stopAnimate];
    
    _model = nil;
    self.showView.imgUrls = nil;
}

- (void)gotoBuyUrl{
    if( self.infoView.model.buyUrl ){
        NSString *textURL = self.infoView.model.buyUrl;//@"http://www.yoururl.com/";
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

////保存所有图片至相册
//- (void)saveAllImgToAlbum{
//    _hud = [HTProgressHUD showMessage:nil toView:self.view];
//    [self dispatchAsyncQueueWithName:@"saveAllImgQ" block:^{
//        for(UIImage *img in self.showView.imgs ){
//            if( [img isKindOfClass:[UIImage class]] ){
//                UIImageWriteToSavedPhotosAlbum(img, self, nil, nil);
//            }
//        }
//        [self dispatchAsyncMainQueueWithBlock:^{
//            [self.hud hide];
//            [HTProgressHUD showSuccess:NSLocalizedString(@"WorkDetailSavedToTheAblum", nil)];///@"已保存至相册"];
//        }];
//    }];
//}

- (BOOL)deleteLocalWork{
    //    //已经存在本地，则清除之前的数据
    if( _model == nil ){
        return NO;
    }

    PPFileManager *fm = [PPFileManager sharedFileManager];
    if( self.model ){
        if( _model.recordPath ) {
            //移除录音文件
            [fm removeFileAtAllPath:_model.recordPath];
        }
        
        for( NSString *imgPath in _model.imgPathArr ){
            if( [imgPath isKindOfClass:[NSString class]] ){
                [fm removeFileAtAllPath:imgPath];
            }
        }
    }
    
    [[PPLocalFileManager shareLocalFileManager] removeFileWithIndex:_model.imgDataIndex];
    
    return YES;
}

- (void)handleSaveSheetViewItemAtIndex:(NSInteger)idx{
    if( idx == 0 ){
        //保存全部图片
        [self saveAllImgToAlbum];
    }else if( idx == 1 ){
        //删除作品
        [self dispatchAsyncQueueWithName:@"deleteLocalQ" block:^{
            BOOL ret = [self deleteLocalWork];
            [self dispatchAsyncMainQueueWithBlock:^{
                if( ret == NO ){
                    [HTProgressHUD showError:@"删除失败"];
                }else{
                    [HTProgressHUD showSuccess:NSLocalizedString(@"WorkDeleteSuccess", nil)];
                    [[NSNotificationCenter defaultCenter] postNotificationName:TSConstantNotificationDeleteWorkLocal object:nil];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        }];
    }
}

- (void)startReleaseWorkWithIsSaveToLocal:(BOOL)saveLocal isOnlySelfSee:(BOOL)isOnlySelfSee{
    if( saveLocal == NO ){
        //则清除本地作品
        [self deleteLocalWork];
    }
}

- (NSString*)getValuesWithText:(NSString*)text{
    NSString *tf =[NSString stringWithObj:text];
    if(  tf ){
        return tf;
    }
    return @"";
}

- (NSMutableDictionary*)getInfoParameters {
    NSMutableDictionary *dic = [NSMutableDictionary new];
//    NSArray *keys = @[@"title",@"price",@"saleCount",@"link",@"desc"];
    dic[@"name"] = [self getValuesWithText:self.model.workName];
    dic[@"price"] = @([self getValuesWithText:self.model.workPrice].floatValue);
    dic[@"saleCount"] = @([self getValuesWithText:self.model.workSaleCount].floatValue);
    dic[@"link"] = [self getValuesWithText:self.model.workBuyUrl];
    dic[@"desc"] = [self getValuesWithText:self.model.workDes];
    
    if( dic.allKeys.count ){
        
        dic[@"publicLevel"] = @1;
        dic[@"picTags"] = @{@"0":@"hhhaa"};
        dic[@"audioNum"] = @"1";
        dic[@"time"] = @"10";
        dic[@"category"] = @"";
        
        NSString *category = @"";
        NSArray *names = [TSCategoryModel categoryNames];
        NSArray *codes = [TSCategoryModel categoryCodes];
        if( _model.workCategory && [names containsObject:_model.workCategory] ){
            category = codes[[names indexOfObject:_model.workCategory]];
            if( category == nil ){
                category = @"";
            }
        }
        dic[@"category"] = category;
        dic[@"audio"] = @"";
        if( self.model.musicUrl && self.model.musicName ){
            //dic[@"audio"] = _model.musicUrl;
            dic[@"audio"] = [NSString stringWithFormat:@"%@%@",@"m/",_model.musicName];
        }
        
        return dic;
    }
    
    return nil;
}

-(void)startReleaseWorkWithDic:(NSDictionary*)dic isSaveToLocal:(BOOL)saveToLocal{
    _hud = [HTProgressHUD showMessage:NSLocalizedString(@"Releaseing", nil) toView:self.view];//发布中
    [self dispatchAsyncQueueWithName:@"relaseWOrkQ" block:^{
        NSMutableDictionary *recordDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        
        recordDic[@"recordBase64"] = @"";
        if( self.model.recordPath ){
            NSData *data = [NSData dataWithContentsOfFile:_model.recordPath];
            if( data ){
                NSString *base64 = [NSString stringOfBase64WithData:data];
                if( base64.length ){
                    NSLog(@"存在录音=%@",base64);
                    recordDic[@"recordBase64"] = base64;
                }
            }
        }
        
        NSString *token = @"";
        if( self.dataProcess.userModel.token ){
            token = self.dataProcess.userModel.token;
        }
        
        recordDic[@"uid"] = self.dataProcess.userModel.userId;
        recordDic[@"username"] = self.dataProcess.userModel.userName;
        recordDic[@"token"] = token;
        recordDic[@"deviceType"] = @"3";
        
        NSURL *videoUrl = nil;
        if( self.model.isVideoWork ){
            if( self.model.videoPath ){
                videoUrl = [NSURL fileURLWithPath:self.model.videoPath];
            }
        }

        [self.dataProcess releaseWorkWithImgs:self.showView.imgs video:videoUrl isVideoWork:self.model.isVideoWork recordBase64Data:nil parameters:recordDic completeBlock:^(NSError *err) {
            if( err == nil ){
                //则移除本地作品
                if( saveToLocal == NO ){
                    [self deleteLocalWorkWithModel:self.model];
                }
            }
            [self dispatchAsyncMainQueueWithBlock:^{
                [_hud hide];
                if( err ){
                    NSString *errStt = NSLocalizedString(@"LogonValidity", nil);//登录失效，请重新登录
                    NSString *msg = [NSString stringWithFormat:@"%@",errStt];
                    [self showErrMsg:msg];
                    //[self showErrMsgWithError:err];
                }else{
                    [HTProgressHUD showSuccess:NSLocalizedString(@"ReleaseSuccess", nil)];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }];
        }];
    }];
}

- (void)deleteLocalWorkWithModel:(TSWorkModel*)wm{
    PPFileManager *fm = [PPFileManager sharedFileManager];
    if( wm ){
        if( wm.recordPath ) {
            //移除录音文件
            [fm removeFileAtAllPath:wm.recordPath];
        }
        
        for( NSString *imgPath in wm.imgPathArr ){
            if( [imgPath isKindOfClass:[NSString class]] ){
                [fm removeFileAtAllPath:imgPath];
            }
        }
        
        for( NSString *imgPath in wm.clearBgImgPathArr ){
            if( [imgPath isKindOfClass:[NSString class]] ){
                [fm removeFileAtAllPath:imgPath];
            }
        }
    }
    [[PPLocalFileManager shareLocalFileManager] removeFileWithIndex:wm.imgDataIndex];
    
    //发送一个 重新加载本地作品数据的消息
    [[NSNotificationCenter defaultCenter] postNotificationName:TSConstantNotificationDeleteWorkOnLine object:nil];
}

- (void)startDeleteLocalWork{
    [self dispatchAsyncQueueWithName:@"deleteLocalQ" block:^{
        BOOL ret = [self deleteLocalWork];
        [self dispatchAsyncMainQueueWithBlock:^{
            if( ret == NO ){
                [HTProgressHUD showError:@"删除失败"];
            }else{
                [HTProgressHUD showSuccess:NSLocalizedString(@"WorkDeleteSuccess", nil)];
                [[NSNotificationCenter defaultCenter] postNotificationName:TSConstantNotificationDeleteWorkLocal object:nil];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }];
}

- (void)showSaveImgSelectView{
    NSArray *titles = @[NSLocalizedString(@"WorkDetailSheetSaveThisImg", nil),
                        NSLocalizedString(@"WorkDetailSheetSaveWholeImg", nil)];
    NSArray *imgNames = @[@"more_photo",@"more_photos"];
    
    //若播放动画，则不展示保存当前图片按钮
    if( self.showView.isAnimate ){
        titles = @[NSLocalizedString(@"WorkDetailSheetSaveWholeImg", nil)];
        imgNames = @[@"more_photos"];
    }
    
    //若当前展示的是视频，则展示保存视频按钮
    if( self.model.isVideoWork ){
        titles = @[NSLocalizedString(@"WorkDetailSheetSaveVideo", nil)];
        imgNames = @[@"more_video"];
    }
    TSMyWorkDetailItemList *itemList = [[TSMyWorkDetailItemList alloc] initWithTitles:titles imgNames:imgNames handleItemBlock:^(NSInteger idx) {
        
        if( self.model.isVideoWork ){
            //保存视频
            [self saveVideoToAlbum];
            return ;
        }
        
        NSInteger index = idx;
        if( self.showView.isAnimate ){
            index ++;
        }
        //保存当前图片
        if( index == 0 ){
            [self saveCurrImgToAlbum];
        }
        //保存全部图片
        else {
            [self saveAllImgToAlbum];
        }
    }];
    [itemList show];
}

- (void)playWorkMusic{
//    NSString * newMusicUrl = [NSString stringWithFormat:@"%@%@",TSConstantProductImgMiddUrl,_model.musicUrl];
//    NSLog(@"musicNmae - %@",self.model.musicName);
//    NSLog(@"musicUrl - %@",_model.musicUrl);
    if( self.model.musicName ){
        //音乐
        PPAudioPlay *ap = [PPAudioPlay shareAudioPlay];
        if(self.musicBtn.selected ){//ap.playState == AudioPlayStatePlaying ){
            [ap endPlay];
            [self.musicBtn stopAnimation];
        }else{
            if( self.model.recordPath )
                [ap startPlayWithUrl:self.model.recordPath];
            else{
                [ap startPlayWithUrl:self.model.musicUrl];
                NSLog(@"locaol -- %@",self.model.musicUrl);
            }
            [self.musicBtn startAnimation];
        }
        
        self.musicBtn.selected = !self.musicBtn.isSelected;
    }
}

//展示分享视频的视图
- (void)showShareVideoView{
    
    UIImage *cover = [UIImage imageWithContentsOfFile:_model.coverPath];
    
    [TSHelper shareWorkVideoWithVideoUrl:[NSURL URLWithString:_model.videoPath] videoCover:cover workName:_model.workName completeBlock:^(NSError *err) {
        
    }];
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

-(void) savedPhotoImage:(UIImage*)image didFinishSavingWithError: (NSError *)error contextInfo: (void *)contextInfo {
    
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
    else {
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

#pragma mark - 保存视频
- (void)saveVideoToAlbum{

    if( self.model.videoPath==nil ){
        [HTProgressHUD showError:@"保存视频失败"];
        return;
    }
    
     [self saveVideo:self.model.videoPath];
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


#pragma mark - TSLocalWorkInfoViewDelegate
- (void)localWorkInfoView:(TSLocalWorkInfoView *)infoView handleBtnAtIndex:(NSInteger)index{
    
    //切换去底图
    if( index == 0 ){
        [self handleSwitchWorkBtn:infoView.switchBtn];
    }
    
    //展示产品信息
    else if( index == 1 ){
//        //音乐
//        if( self.model.recordPath || ([NSString stringWithObj:self.model.musicUrl] && self.model.musicName && [self.model.musicUrl containsString:@"http"])){
//            //音乐
//            PPAudioPlay *ap = [PPAudioPlay shareAudioPlay];
//            if(ap.playState == AudioPlayStatePlaying ){
//                [ap endPlay];
////                [self.infoView.musicBtn stopAnimation];
//            }else{
//                if( self.model.recordPath )
//                    [ap startPlayWithUrl:self.model.recordPath];
//                else{
//                    [ap startPlayWithUrl:self.model.musicUrl];
//                    NSLog(@"locaol -- %@",self.model.musicUrl);
//                }
////                [self.infoView.musicBtn startAnimation];
//            }
//        }
    }
    //购买
    else if( index == 2 ){
        [self gotoBuyUrl];
    }
    
    //保存当前图片 或 全部图片
    else if( index == 3 ){
        
        [self showSaveImgSelectView];
    }
    //删除作品
    else if (index == 4 ){
        //删除作品
        
        __weak typeof(self) weakSelf = self;
        
        NSString *title = NSLocalizedString(@"WorkDetailConfirmDeleteWorkTitle", nil);
        NSString *msg = NSLocalizedString(@"WorkDetailConfirmDeleteWorkDes", nil);
        
        [TSAlertView showAlertWithTitle:title des:msg handleBlock:^(NSInteger index) {
            [weakSelf startDeleteLocalWork];
        }];
    }
    
    //发布作品
    else if( index == 5 || index == 6 ){
        if( ![self isLoginedWithGotoLoginCtrl] ) return;
        
        //视频作品，且索引为5，说明是分享
        if( self.model.isVideoWork && index == 5 ){
            [self showShareVideoView];
            return;
        }
        
        //分享 改为发布作品
        __weak typeof(self) weakSelf = self;
        [TSWorkReleaseView showWithHandleIndexBlock:^(NSInteger index, BOOL isSaveToLocal, BOOL isOnlySelfSee) {
            NSMutableDictionary *dic =
            [self getInfoParameters];
            if( isOnlySelfSee==NO ){
                dic[@"publicLevel"] = @(1);
            }else{
                dic[@"publicLevel"] = @(0);
            }
            [weakSelf startReleaseWorkWithDic:dic isSaveToLocal:isSaveToLocal];
        }];
    }
}

#pragma mark - PPAudioPlayDelegate
- (void)audioPlayEndPlay:(PPAudioPlay *)auidoPlay{
//    [self.infoView.musicBtn stopAnimation];
    
    [self.musicBtn stopAnimation];
}

#pragma mark - TouchEvents
- (void)handleBack{
    
    [PPAudioPlay shareAudioPlay].needEndWhenStartPlaying = YES;
    [self.navigationController popViewControllerAnimated:YES];
        
    [self clearData];
}

- (void)handleEdit{
    @autoreleasepool{
        
        if (self.dataProcess.userModel.userId) {
            
            //视频作品，则点击编辑，直接去发布页面
            if( self.model.isVideoWork ){
                
                TSEditVideoWorkCtrl *wc = [TSEditVideoWorkCtrl new];
                wc.model = self.model;
                [self pushViewCtrl:wc];
                return;
                
                TSPublishWorkCtrl *pc = [TSPublishWorkCtrl new];
                pc.model = self.model;
                [self pushViewCtrl:pc];
                return;
            }
            
            self.model.editingImgs = self.showView.imgs;
//            //已换底，则跳入编辑页
//            if( self.model.clearBgImgPathArr.count ){
            //编辑
            TSEditWorkCtrl *wc = [TSHelper shareEditWorkCtrl];
            wc.model = self.model;
            [wc resetDatas];
            wc.isNeedBackToWorkListCtrl = NO;
            [self pushViewCtrl:wc];
//            }
//            else{
//                TSClearWorkBgCtrl *wc = [TSClearWorkBgCtrl new];
//                wc.workModel = self.model;
//                [self pushViewCtrl:wc];
//            }
                
        }else if (self.dataProcess.userModel.userId == nil){
            TSLoginCtrl *lc = [TSLoginCtrl new];
            [self pushViewCtrl:lc];
        }
    }
}

//- (void)handleShowImgView{
//    //    if( self.infoView.hi
//    self.infoView.hidden = !self.infoView.isHidden;
//    self.showBottomViewBtn.hidden = !self.infoView.isHidden;
//}

- (void)handleSwitchWorkBtn:(UIButton*)btn{
    NSArray *paths = nil;
    if( !btn.isSelected ){
        //切换原图
        paths = self.model.imgPathArr;
    }else{
        //切换去底图
        paths = self.model.clearBgImgPathArr;
    }
    
    NSMutableArray *imgs = [NSMutableArray new];
    for( NSUInteger i=0; i<paths.count; i++){
        NSString *pa = paths[i];
        if( [pa isKindOfClass:[NSString class]] ){
            NSData *imageData = [NSData dataWithContentsOfFile:pa options:NSDataReadingMappedIfSafe error:nil];
            if( imageData ){
                UIImage * img = [UIImage imageWithData:imageData];
                if( img )
                    [imgs addObject:img];
            }
        }
    }
    
    if( imgs.count ){
        self.showView.imgs = imgs;
        
        [self.showView reloadData];
        
        btn.selected = !btn.isSelected;
        
        self.model.showClearBg = !btn.selected;
        
        self.model.editingObject = (btn.isSelected?TSWorkEditObjectOriginWork:TSWorkEditObjectClearedBgWork);
    }
}

- (void)handleMusicBtn:(UIButton*)btn{
    [self playWorkMusic];
}

#pragma mark - Propertys

- (TSProductionShowView *)showView {
    if( !_showView ){
        _showView = [[TSProductionShowView alloc] init];
        _showView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        __weak typeof(self) weakSelf = self;
        _showView.handleTapBlock = ^(TSProductionShowView *infoView) {
//            [weakSelf handleShowImgView];
        };
        _showView.loadCompleteBlock = ^(TSProductionShowView *infoView) {
            [weakSelf getButtonAtRightBarItem].enabled = YES;
        };
        [self.view addSubview:_showView];
        
        [self.view bringSubviewToFront:self.infoView];
    }
    return _showView;
}

- (TSLocalWorkInfoView *)infoView {
    if( !_infoView ){
        if( self.model.isVideoWork ){
            _infoView = [[TSLocalWorkInfoView alloc] initLocalVideoWorkInfoView];
        }else{
            _infoView = [[TSLocalWorkInfoView alloc] init];
        }
        _infoView.backgroundColor = [UIColor clearColor];
        _infoView.delegate = self;
        
        CGFloat ih = 50+BOTTOM_NOT_SAVE_HEIGHT;
        CGFloat iy = SCREEN_HEIGHT-ih;
        _infoView.frame = CGRectMake(0, iy, SCREEN_WIDTH, ih);
        [self.view addSubview:_infoView];
    }
    return _infoView;
}

- (UIButton *)switchBtn {
    if( !_switchBtn ){
        _switchBtn = self.infoView.switchBtn;
        
//        _switchBtn = [[UIButton alloc] init];
//        [_switchBtn setImage:[UIImage imageNamed:@"finished_switch"] forState:UIControlStateNormal];
//        [_switchBtn setTitle:NSLocalizedString(@"ClearBgSwitchOriginImgTitle", nil) forState:UIControlStateNormal];
//        [_switchBtn setTitle:NSLocalizedString(@"ClearBgSwitchCleardImgTitle", nil) forState:UIControlStateSelected];
//        _switchBtn.titleLabel.font = [UIFont systemFontOfSize:17];
//        [_switchBtn.titleLabel sizeToFit];
//        _switchBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
//        [_switchBtn setBackgroundColor:[UIColor colorWithRgb_0_151_216]];
//        [_switchBtn addTarget:self action:@selector(handleSwitchWorkBtn:) forControlEvents:UIControlEventTouchUpInside];
//        _switchBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 5);
        _switchBtn.hidden = YES;
//        [self.view addSubview:_switchBtn];
    }
    return _switchBtn;
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


- (SBPlayer *)player {
    if( !_player ){
        _player = [[SBPlayer alloc]initWithUrl:[NSURL URLWithString:@""]];
//        _player.delegate = self;
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

@end
