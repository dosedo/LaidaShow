//
//  TSEditWorkCtrl.m
//  ThreeShow
//
//  Created by hitomedia on 13/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSEditWorkCtrl.h"
#import "UIViewController+Ext.h"
#import "UIView+LayoutMethods.h"
#import "TSProductionShowView.h"
#import "TSMusicBtn.h"
#import "TSEditButton.h"
#import "TSEditClipCtrl.h"
#import "TSEditModifyCtrl.h"
#import "TSSelectMusicCtrl.h"
#import "TSSelectMusicModel.h"
#import "PPAudioPlay.h"
#import "UIButton+RotateAnimate.h"
#import "TSAddRecordCtrl.h"
#import "TSEditAddImgCtrl.h"
//#import "WXWPhotoPicker.h"
#import "TSPublishWorkCtrl.h"
#import "TSWorkModel.h"
#import "PPFileManager.h"
#import "PPLocalFileManager.h"
//#import "UIViewController+MMDrawerController.h"
#import "TSAlertView.h"
#import "HTProgressHUD.h"
#import "TSConstants.h"
#import "TSHelper.h"
#import "TSMyWorkCtrl.h"

#import "TSDataProcess.h"
#import "TSHttpRequest.h"
#import "TSUserModel.h"
#import "TSChangeBGController.h"
#import "TSClearWorkCtrl.h"

static NSUInteger const gTagBase = 100;

@interface TSEditWorkCtrl ()<PPAudioPlayDelegate>

@property (nonatomic, strong) TSProductionShowView *showView;
@property (nonatomic, strong) UIView   *bottomView;
@property (nonatomic, strong) UIButton *musicBtn;
@property (nonatomic, strong) UIButton *cancleMusicBtn;
@property (nonatomic, strong) UIView   *btnView;
@property (nonatomic, strong) UIView   *btnViewHasHuandi;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *completeBtn;
@property (nonatomic, strong) UIButton *clearBgBtn; //去底按钮
@property (nonatomic, strong) TSSelectMusicModel *musicModel;

@property (nonatomic, strong) TSEditAddImgCtrl *addImgCtrl;
//@property (nonatomic,strong) TSWaterMarkCtrl *waterMarkCtrl;
@property (nonatomic, strong) TSEditClipCtrl *clipCtrl;
@property (nonatomic, strong) TSEditModifyCtrl *modifyCtrl;
@property (nonatomic,strong) TSChangeBGController *changeBgCtrl;

@property (nonatomic, assign) BOOL isModifyOriginImg; //是否修改了原图 。默认为NO
@property (nonatomic, strong) NSArray<UIImage*> *tempImgs; //临时保存的原图或退底的图片
@property (nonatomic, strong) HTProgressHUD *hud;

@end

@implementation TSEditWorkCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //隐藏返回键
    [self addLeftBarItemWithTitle:nil action:nil];
//    [self resetDatas];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [PPAudioPlay shareAudioPlay].delegate = self;

//    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

//    self.navigationController.navigationBar.hidden = NO;

    [PPAudioPlay shareAudioPlay].needEndWhenStartPlaying = YES;
    [[PPAudioPlay shareAudioPlay] endPlay];
}
    
- (void)dealloc{
    self.imgs = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
//    double am = [self availableMemory];
//    double um = [self usedMemory];
//    NSLog(@"%s___内存不足__awailable=%fMB,used=%fMB",__func__,am,um);
}

#pragma mark - Public
- (void)resetDatas{
    
    [_btnView removeFromSuperview];
    _btnView = nil;
    
    _imgs = _model.editingImgs;
    [self.view addSubview:_bottomView];
    self.clearBgBtn.selected = NO;
    _isModifyOriginImg = NO;
    _isNeedBackToWorkListCtrl = NO;
    self.tempImgs = nil;
    self.showView.imgs =  self.imgs;
    [self.showView reloadData];

    [self updateClearBgBtnStateWithModel:self.model];
    TSSelectMusicModel *mm = nil;
    if( self.model ){
        _isModifyOriginImg = !self.model.isCanClearBg;
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

- (void)clipImgComplete:(NSArray *)newimgs{
    
    if( self.showView.imgs == self.imgs ){
        self.imgs = newimgs;
    }else{
        self.tempImgs = newimgs;
    }
    
    self.showView.imgs =  newimgs;
    [self.showView reloadData];
    
    _isModifyOriginImg = YES;
    
    if( self.model == nil ){
        if( self.clearBgBtn.enabled ){
            self.clearBgBtn.enabled = NO;
        }
    }else{
        if( self.model.clearState == TSWorkClearBgStateNotBegin ){
            if( self.model.isCanClearBg ){
                self.model.isCanClearBg = NO;
            }
        }
    }
    
    //配置model的编辑后的图片存储
    self.model.editingImgs = newimgs;
    NSMutableArray *editImgPaths = [NSMutableArray new];
    NSUInteger i=0;
    BOOL isEditOriginImg = self.model.editingObject == TSWorkEditObjectOriginWork;
    for( UIImage *img in newimgs ){
        NSString *dirName =
        isEditOriginImg ? @"originEditDir":@"clearEditDir";
        
        NSString *dir = [NSTemporaryDirectory() stringByAppendingPathComponent:dirName];
        NSFileManager *fm = [NSFileManager defaultManager];
        if( [fm fileExistsAtPath:dir] ==NO ){
            [fm createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSString *path = [dir stringByAppendingPathComponent:[TSHelper getSaveWorkImgNameAtIndex:i]];
        
        [UIImageJPEGRepresentation(img, 1) writeToFile:path atomically:YES];
        
        [editImgPaths addObject:path];
        i++;
    }
    
    if( isEditOriginImg ){
        self.model.tempEditOriginImgPaths = editImgPaths;
    }else{
        self.model.tempEditClearImgPaths = editImgPaths;
    }
}

- (void)modifyImgCompete:(NSArray *)newImgs{
    [self clipImgComplete:newImgs];
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

//- (void)gotoAddImgCtrl:(UIImage*)img{
//    TSEditAddImgCtrl *ic;// = _addImgCtrl;
////    if( ic == nil ){
//        ic = [TSEditAddImgCtrl new];
////        _addImgCtrl = ic;
////    }
//    ic.imgs = self.showView.imgs;
//    ic.selectImg = img;
//    __weak typeof(self) weakSelf = self;
//    ic.completeBlock = ^(NSArray *newImgArr) {
//        [weakSelf clipImgComplete:newImgArr];
//    };
//    [ic resetDatas];
//    [self pushViewCtrl:ic];
//}

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

#pragma mark __去底部分
//开始去除背景
//- (void)startClearImgBg{
//
//    if([self isLoginedWithGotoLoginCtrl]==NO ) return;
//
//    _hud = [HTProgressHUD showMessage:nil toView:self.view];
//    NSArray *imgs = self.showView.imgs;
//
//    [self.dataProcess startClearBgWithWorkImgs:imgs completeBlock:^(NSError *err, NSString *clearBgId) {
//        [self dispatchAsyncMainQueueWithBlock:^{
//            [_hud hide];
//            if( err ){
//                [self showErrMsgWithError:err];
//                return ;
//            }else{
//                [HTProgressHUD showSuccess:@"您上传的作品正在去底,完成后将在本地作品展示"];
//            }
//            //上传成功。
//            //保存退底状态到本地。
//            [self saveClearIdToLocalWork:clearBgId];
//
//            //保存去底ID，用来查询是否去底完成。同时将该ID 加入去底查询队列，
//            [[TSHelper sharedHelper] addNewClearId:clearBgId];
//
//            //发送开始退底通知
//            [[NSNotificationCenter defaultCenter] postNotificationName:TSConstantNotificationStartWorkClearBg object:nil];
//
//            //跳转至我的作品或首页
//            [self gotoCtrlAfterStartClearBg];
//        }];
//    }];
//}


/// 若编辑了图片，如裁切，此时去底。则将编辑后的图片，作为原图的去底图片。
/// 所以此时，将编辑的图片，移动到原图的图片路径下。若编辑图不存在，则不移动
- (void)moveTempEditImgsToOriginImgsIfNeed{
    if( self.model.isCleared == NO ){
        NSArray *tempEditImgPaths = self.model.tempEditOriginImgPaths;
        
        NSInteger i =0;
        for( NSString *path in tempEditImgPaths ){
            NSFileManager *fm = [NSFileManager defaultManager];
            BOOL isExist = [fm fileExistsAtPath:path];
            if( isExist ){
                if( self.model.imgPathArr.count > i){
                    NSString *toPath = self.model.imgPathArr[i];
                    if( [fm fileExistsAtPath:toPath] ){
                        [fm removeItemAtPath:toPath error:nil];
                        [fm moveItemAtPath:path toPath:toPath error:nil];
                    }
                }
            }
            
            i++;
        }
    }
}

- (void)gotoCtrlAfterStartClearBg{

    [PPAudioPlay shareAudioPlay].needEndWhenStartPlaying = YES;
    
    self.navigationController.navigationBar.hidden = NO;
    
    NSArray *ctrs = self.navigationController.viewControllers;
    UIViewController *toCtrl = nil;
    for(UIViewController *vc in ctrs ){
        //若存在我的作品，则返回我的作品
        if( [vc isKindOfClass:[TSMyWorkCtrl class]] ){
            toCtrl = vc;
            break;
        }
    }
    
    if( toCtrl ){
        [self.navigationController popToViewController:toCtrl animated:YES];
        return;
    }
    
    //不存在我的作品，直接返回首页
    [self.navigationController popToRootViewControllerAnimated:YES];
//    ctrs = nil;
}

/*  暂时无用，所以隐藏该函数
//保存作品id 到本地作品中。若是拍照退底，则将作品保存至本地
- (void)saveClearIdToLocalWork:(NSString*)clearid{
    BOOL needSaveWorkToLocal = NO;
    if( self.model == nil ){
        self.model = [TSWorkModel new];
        needSaveWorkToLocal = YES;
        self.model.clearBgWorkId = clearid;
        self.model.clearState = TSWorkClearBgStateClearing;
        self.model.imgArr = self.showView.imgs;
        [self saveWorkData];
    }
    else{
        self.model.clearBgWorkId = clearid;
        self.model.clearState = TSWorkClearBgStateClearing;
        
        [[PPLocalFileManager shareLocalFileManager] updateModel:self.model atIndex:self.model.imgDataIndex];
    }
}

- (void)saveWorkData{
    
    //将所有图片写入本缓存
    NSMutableArray *imgPaths = [NSMutableArray new];
    for( UIImage *img in self.model.imgArr ){
        if( [img isKindOfClass:[UIImage class]] ){
            PPFileManager *fm = [PPFileManager sharedFileManager];
            NSString *imgName = [TSHelper getNewImgFileName];
            BOOL ret =
            [fm saveSanweishowImgToNotClearPath:img imgAllName:imgName];
            if( ret == NO ){
                NSLog(@"写入图片失败index=%lu",(unsigned long)[_model.imgArr indexOfObject:img]);
            }
            
            NSString *imgPath = [fm getSanweishowWorkImgWithImgAllName:imgName];
            if( imgPath ) [imgPaths addObject:imgPath];
        }
    }
    self.model.imgPathArr = imgPaths;
    
    NSArray *tempImgs = self.model.imgArr;
    self.model.imgArr = nil;
    [[PPLocalFileManager shareLocalFileManager] saveFileToLocal:self.model];
    self.model.imgArr = tempImgs;
}
*/

/**
 已去底成功，展示本地去底图片
 */
- (void)showLocalClearImg{
    NSArray *clearImgs = nil;
    TSWorkModel *wm = self.model;
    if( wm.clearBgImgArr ){
        clearImgs = wm.clearBgImgArr;
    }else{
        NSMutableArray *newArr = [NSMutableArray new];
        for( NSString *path in wm.clearBgImgPathArr ){
            if( [path isKindOfClass:[NSString class]] ){
                //解决了一个内存问题
                NSData *imageData = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
                UIImage * img = [UIImage imageWithData:imageData];
                if( img ){
                    [newArr addObject:img];
                }
            }
        }
        if( newArr.count ) {
            clearImgs = newArr;
        }
    }
}

/**
 更新去底按钮的状态，

 @param isOriginImg 要去底的图片是否为原图。是原图，则可以去底。
 */
- (void)updateClearBgBtnStateWithIsOriginImg:(BOOL)isOriginImg{
    BOOL enable = isOriginImg;
    
    self.clearBgBtn.enabled = enable;
}

/**
 更新去底按钮的状态，根据去底的状态

 @param clearState 正在去底，则不可操作；未开始去底或去底成功，则可去底。
 */
- (void)updateClearBgBtnStateWithClearState:(TSWorkClearBgState)clearState{
    
    [self updateClearBgBtnStateWithIsOriginImg:(clearState!=TSWorkClearBgStateClearing)];
}

- (void)updateClearBgBtnStateWithModel:(TSWorkModel*)wm{
    if( wm ==nil ){
        [self updateClearBgBtnStateWithIsOriginImg:YES];
    }else{
        if( wm.clearState == TSWorkClearBgStateNotBegin ){
            BOOL isOrigingImg = wm.isCanClearBg;
            [self updateClearBgBtnStateWithIsOriginImg:isOrigingImg];
        }else{
            [self updateClearBgBtnStateWithClearState:wm.clearState];
        }
    }
}

/**
 是否正在展示退底的图片

 @return YES是,NO 未展示退底图
 */
- (BOOL)isShowingClearBgImg{
    return self.clearBgBtn.isSelected;
}

- (NSArray*)getClearBgImgsWithModel:(TSWorkModel*)wm{
//#warning 测试
//    wm.clearBgImgPathArr = wm.imgPathArr;
    
    NSArray *imgs = nil;
    if( wm.clearBgImgArr ){
        imgs = wm.clearBgImgArr;
    }
    else if(wm.clearBgImgPathArr ){
        NSMutableArray *newArr = [NSMutableArray new];
        NSUInteger i =0;
        for( NSString *path in wm.clearBgImgPathArr ){
            if( [path isKindOfClass:[NSString class]] ){
                
//                #warning 测试
//                NSString *lastPath = [path lastPathComponent];
//                NSString *testPath = [path substringToIndex:[path rangeOfString:lastPath].location];
//                testPath = [testPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%02lu.png",(unsigned long)i]];
                
                //解决了一个内存问题
                NSData *imageData = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
                UIImage * img = [UIImage imageWithData:imageData];
                if( img ){
                    [newArr addObject:img];
                }
            }
            
            i++;
        }
        if( newArr.count ) imgs = newArr;
    }
    
    return imgs;
}

- (NSArray*)getOriginImgsWithModel:(TSWorkModel*)wm{
    
    NSArray *imgs = nil;
    if( wm.imgArr ){
        imgs = wm.imgArr;
    }
    else if(wm.imgPathArr ){
        NSMutableArray *newArr = [NSMutableArray new];
        for( NSString *path in wm.imgPathArr ){
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
    
    return imgs;
}

- (void)gotoClipCtrl{
    TSEditClipCtrl *cc = _clipCtrl;
    if( cc == nil ){
        cc = [TSEditClipCtrl new];
        _clipCtrl = cc;
    }
    cc.imgs = self.showView.imgs;
    cc.editWorkCtrl = self;
    [cc resetDatas];
    [self pushViewCtrl:cc];
}

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
    rc.img = self.showView.imgs[0];
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
        
        self.model.editingImgs = self.showView.imgs;
        
        NSInteger startIndex = 0;//self.model.isCleared?0:-1;
        if( btn.tag == 0 + gTagBase ){
            //裁剪
            [self gotoClipCtrl];
        }else if (btn.tag == 1 +gTagBase){
            //去底
            
            //去底之前，先把编辑后的图片存入到 原图路径中，
            //也就是替换原图路径的图片为编辑后的图片。
            //若未编辑，则不进行替换
            [self moveTempEditImgsToOriginImgsIfNeed];
            
            TSClearWorkCtrl *wc = [TSClearWorkCtrl new ];
            wc.imgs = self.showView.imgs;
            wc.editWorkCtrl = self;
            wc.workModel = self.model;
            [wc resetDatas];
            [self pushViewCtrl:wc];
            
            return;
            
            TSEditModifyCtrl *mc = _modifyCtrl;
            if( mc == nil ){
                mc = [TSEditModifyCtrl new];
                _modifyCtrl = mc;
            }
            mc.imgs = self.showView.imgs;
            mc.editWorkCtrl = self;
            [mc resetDatas];
            [self pushViewCtrl:mc];
            
        }else if (btn.tag == 2+gTagBase + startIndex){
            
            //换底
            if ( !self.model.isCleared ) {
                [TSAlertView showAlertWithTitle:NSLocalizedString(@"去底之后才可以换底哦，请先进行去底", nil)];
                return;
            }
            
            TSChangeBGController *mc = _changeBgCtrl;
            if (mc == nil) {
                mc = [TSChangeBGController new];
                _changeBgCtrl = mc;
            }
            mc.editWorkCtrl =self;
            mc.model = self.model;
            [mc resetDatas];
            [self pushViewCtrl:mc];
            
        }else if (btn.tag == 3+gTagBase + startIndex){
            
            //音乐
            BOOL isNeedShowAlert = self.musicModel.isRecord;
            if( isNeedShowAlert ){
                [TSAlertView showAlertWithTitle:NSLocalizedString(@"WorkEditConfirmAddMusicTitle", nil) des:NSLocalizedString(@"WorkEditConfirmAddMusicDes", nil) handleBlock:^(NSInteger index) {
                    [self gotoMusicCtrl];
                }];
            }else{
                [self gotoMusicCtrl];
            }
            
        }else if( btn.tag == 4 +gTagBase + startIndex ){
            //录音
            if( self.showView.imgs.count ==0 ) return;
            BOOL isNeedShowAlert = (self.musicModel && self.musicModel.isRecord==NO);
            if( isNeedShowAlert ){
                [TSAlertView showAlertWithTitle:NSLocalizedString(@"WorkEditConfirmAddRecordTitle", nil) des:NSLocalizedString(@"WorkEditConfirmAddRecordDes", nil) handleBlock:^(NSInteger index) {
                    [self gotoRecordCtrl];
                }];
            }else{
                [self gotoRecordCtrl];
            }
            
        }else if (btn.tag ==5 +gTagBase + startIndex){
            
            //水印
            if( self.showView.imgs.count ==0 ) return;
            TSEditAddImgCtrl *mc = _addImgCtrl;
            if (mc == nil) {
                mc = [TSEditAddImgCtrl new];
                _addImgCtrl = mc;
                
                __weak typeof(self) weakSelf = self;
                mc.completeBlock = ^(NSArray *newImgArr) {
                    [weakSelf clipImgComplete:newImgArr];
                };
            }
            mc.imgs = self.showView.imgs;
            [mc resetDatas];
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
    
    wm.editingImgs = self.showView.imgs;
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

#pragma mark - WXWPhotoDelegate
//- (void)photoPicker:(WXWPhotoPicker *)picker didFinishSelectImg:(UIImage *)img{
//    [self gotoAddImgCtrl:img];
//}

#pragma mark - Propertys
- (TSProductionShowView *)showView {
    if( !_showView ){
        _showView = [[TSProductionShowView alloc] init];
        _showView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _showView.clipsToBounds = YES;
        [self.view addSubview:_showView];
    }
    return _showView;
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
        
        [self addRightBarItemWithTitle:NSLocalizedString(@"ForgetPwdNextText", nil)  action:@selector(handleSave)];
        
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

        NSArray *titles = @[NSLocalizedString(@"WorkEditBottomClipText", nil),
                            NSLocalizedString(@"WorkEditBottomClearBgText", nil),
                            NSLocalizedString(@"WorkEditBottomChangeBg", nil),
                            NSLocalizedString(@"WorkEditBottomMusic", nil),
                            NSLocalizedString(@"WorkEditBottomRecord", nil),
                            NSLocalizedString(@"WorkEditBottomWaterMark", nil)];
            
        NSArray *imgNames = @[@"edit_cut",@"edit_remove",@"editor_huandi", @"edit_music",@"edit_record",@"editor_shuiyin"];
        
//        //已经退底
//        if (self.model.isCleared ) {
//            titles = @[NSLocalizedString(@"WorkEditBottomClipText", nil),
//                       NSLocalizedString(@"WorkEditBottomWaterMark", nil),
//                       NSLocalizedString(@"WorkEditBottomChangeBg", nil),
//                       NSLocalizedString(@"WorkEditBottomModify", nil),
//                       NSLocalizedString(@"WorkEditBottomMusic", nil),
//                       NSLocalizedString(@"WorkEditBottomRecord", nil)];
//
//            imgNames = @[@"edit_cut",@"editor_shuiyin",@"editor_huandi",@"edit_modify",@"edit_music",@"edit_record"];
//        }
        
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

//- (UIButton *)clearBgBtn {
//    if( !_clearBgBtn ){
//        NSString *imgName = @"edit_remove";
//        _clearBgBtn = [self getBtnWithImgName:imgName hiImgName:nil sImgName:nil sel:@selector(handleClearBgBtn:)];
//        NSString *title = NSLocalizedString(@"WorkEditBottomClearBgText", nil);
//        [_clearBgBtn setTitle:title forState:UIControlStateNormal];
//        [_clearBgBtn setTitle:@"原图" forState:UIControlStateSelected];
//        [_clearBgBtn setTitleColor:[UIColor colorWithRgb153] forState:UIControlStateDisabled];
//    }
//    return _clearBgBtn;
//}

//- (BOOL)prefersStatusBarHidden{
//    return YES;
//}

@end


