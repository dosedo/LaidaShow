//
//  TSClearWorkBgCtrl.m
//  ThreeShow
//
//  Created by hitomedia on 07/08/2018.
//  Copyright © 2018 deepai. All rights reserved.
// metwen

#import "TSClearWorkBgCtrl.h"
#import "TSProductionShowView.h"
#import "UIViewController+Ext.h"
#import "UIView+LayoutMethods.h"
#import "HTProgressHUD.h"
#import "UIColor+Ext.h"
#import "UILabel+Ext.h"
#import "TSAlertView.h"
#import "KError.h"
#import "TSEditWorkCtrl.h"
#import "TSHelper.h"
#import "TSClearImgBg.h"
#import "TSLoginCtrl.h"
#import "TSPathManager.h"
#import "PPLocalFileManager.h"
#import "TSClearGuideView.h"
#import "TSSelectDeviceView.h"
#import "TSDataBase.h"

@interface TSClearWorkBgCtrl ()
@property (nonatomic, strong) TSProductionShowView *showView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIButton *switchBtn;       //切换原图和去底图
@property (nonatomic, strong) UIButton *cancleClearBgBtn; //取消去底
@property (nonatomic, strong) HTProgressHUD *hud;
@property (nonatomic, strong) NSArray *clearImgs;
@property (nonatomic, strong) NSArray *oriImgPaths;
@property (nonatomic, strong) NSArray *maskClearImgPaths;
@property (nonatomic, strong) NSArray *ClearImgPaths;
@property (nonatomic, strong) NSURLSessionDataTask *uploadImgTask;
@property (nonatomic, assign) BOOL isCCleared;

@end

@implementation TSClearWorkBgCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self configSelfData];
    [self addLeftBarItemWithTitle:nil action:nil];
    self.view.backgroundColor = [UIColor whiteColor];
    //去底拍找界面常亮
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    self.isCCleared = NO;
    self.imgs = self.workModel.editingImgs;
    self.showView.imgs = self.imgs;
    [self.showView reloadData];
    
//    //是否是第一次进入退底页面
//    NSString *key = @"TSCLEAR_WORK_BG_IS_FIRST_CLEAR_KEY0";
//    BOOL isFirstClear = ![[NSUserDefaults standardUserDefaults] valueForKey:key];
//    if( isFirstClear ){
//        CGRect fr = _clearBgBtn.frame;
//        fr.origin.y += self.bottomView.y;
//        [TSClearGuideView showClearGuideViewWithBtnFrame:fr HideBlock:^{
//            
//        }];
//        
//        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:key];
//    }
}

-(void)viewDidDisappear:(BOOL)animated{
     //[[NSNotificationCenter defaultCenter]removeObserver:self name:@"clearComplete" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"======崩溃====");
    //内存不足处理
    double am = [self availableMemory];
    double um = [self usedMemory];
    NSLog(@"%s___内存不足__awailable=%fMB,used=%fMB",__func__,am,um);
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"内存警告" message:@"可用内存不足" preferredStyle:UIAlertControllerStyleAlert];
//
//    [self presentViewController:alert animated:YES completion:^{
//        NSLog(@"======内存清理====");
//    }];
//
//    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(creatAlert:) userInfo:alert repeats:NO];
    
    [HTProgressHUD showError:@"内存警告"];
    
    NSLog(@"======内存清理====");
}

#pragma mark - Private
- (void)startClearBg{

    NSLog(@"======去底====");
    //判断登录是否失效
//    if([self isLogined]){
//        [self presentViewController:[[TSLoginCtrl alloc]init] animated:YES completion:nil];
//    }
    if( [self isLoginedWithGotoLoginCtrl] == NO ) return;
    //开始去底
    [self updateViewStateWithClearState:TSClearWorkBgStateClearing];
    [TSHelper sharedHelper].isCancleClearBg = NO;
    
    _uploadImgTask =
    [self.dataProcess startSyncClearBgWithWorkImgs:self.imgs completeBlock:^(NSError *err, NSArray *clearImgPaths) {//上传原图成功后得到遮罩图(遮罩图根据返回的遮罩图路径递归进行下载)
        
        [self dispatchAsyncMainQueueWithBlock:^{
            
            if( [TSHelper sharedHelper].isCancleClearBg ){
                [_hud hide];
                return ;
            }
            
            if( err ){

                [_hud hide];
//                NSString *errMsg = [KError errorMsgWithError:err];
//                NSLog(@"====errMsg%@====",errMsg);
                [self showErrMsgWithError:err];

                [self updateViewStateWithClearState:TSClearWorkBgStateNotBegin];
            }else{
                //得到遮罩图，开始本地算法合成
                __weak typeof(self) weakSelf = self;
                NSLog(@"bendimirgclear - %@",clearImgPaths);
                [self startLocalClearWorkWithMaskImgPaths:clearImgPaths completBlock:^(NSError *err, NSArray *resultImgPaths) {
                    
                    NSLog(@"======1可用内存====%fMB",[self availableMemory]);
                    NSLog(@"======1已经内存====%fMB",[self usedMemory]);
                    NSLog(@"======resultImgPaths====%@",resultImgPaths);
                    [_hud hide];
                    if( err ){
                        [self showErrMsgWithError:err];
                        NSLog(@"====err%@====",err);
                        
                    }else{
                        
                        _maskClearImgPaths = clearImgPaths;
                        [weakSelf clearWorkBgSuccessWithResultPaths:resultImgPaths];
                    }
                }];
            }
        }];
    }];
}


//- (void)creatAlert:(NSTimer *)timer{
//
//    UIAlertController *alert = [timer userInfo];
//
//    [alert dismissViewControllerAnimated:YES completion:nil];
//
//    alert = nil;
//}


- (void)clearWorkBgSuccessWithResultPaths:(NSArray*)resultImgPaths{
    [HTProgressHUD showSuccess:NSLocalizedString(@"ClearBgSuccessInfo", nil)];//@"退底成功"
    NSMutableArray *arr = [NSMutableArray new];
    for( NSString *path in resultImgPaths ){
       
        NSData *imageData = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
        UIImage * img = [UIImage imageWithData:imageData];
        
        if( img ){
            [arr addObject:img];
        }
    }
    _clearImgs = arr;
    _ClearImgPaths = resultImgPaths;
    self.showView.imgs = arr;
    [self.showView reloadData];
    NSLog(@"ifReadOnly value: %@" ,_isCCleared?@"YES":@"NO");
    self.isCCleared = YES;
    NSLog(@"ifReadOnly value: %@" ,_isCCleared?@"YES":@"NO");
    [self updateViewStateWithClearState:TSClearWorkBgStateComplete];
}


- (void)cancleClearingBg{
    [TSHelper sharedHelper].isCancleClearBg = YES;
    [_uploadImgTask cancel];
    [self updateViewStateWithClearState:TSClearWorkBgStateNotBegin];
}

- (void)updateViewStateWithClearState:(TSClearWorkBgState)state{
    
    switch (state) {
        case TSClearWorkBgStateNotBegin:
        {
            self.cancleClearBgBtn.hidden = YES;
            self.switchBtn.hidden = YES;
            self.clearBgBtn.enabled = YES;
            
            [_hud hide];
        }
            break;
        case TSClearWorkBgStateClearing:
        {
//            if( _hud == nil ){
                _hud = [HTProgressHUD showMessage:NSLocalizedString(@"ClearBgClearingHudMsg", nil) toView:self.view];
                [self.view bringSubviewToFront:self.cancleClearBgBtn];
//            }

            self.cancleClearBgBtn.hidden = NO;
            self.switchBtn.hidden = YES;
            self.clearBgBtn.enabled = NO;
        }
            break;
        case TSClearWorkBgStateComplete:
        {
            self.cancleClearBgBtn.hidden = YES;
            self.switchBtn.hidden = NO;
            self.clearBgBtn.enabled = NO;
            [_hud hide];
        }
        default:
            break;
    }
}

- (NSArray*)getOriginImgPathsOrResultImgPathsWithImgCount:(NSUInteger)imgCount isOrigin:(BOOL)isOrigin{
    NSMutableArray *arr = [NSMutableArray new];
    for( NSUInteger i=0; i<imgCount; i++ ){
        NSString *imgDir = [TSHelper takePhotoImgPath];
        if( !isOrigin ){
            imgDir = [TSHelper clearedImgWorkPath];
        }
        NSString *imgFilePath = [imgDir stringByAppendingPathComponent:[TSHelper getSaveWorkImgNameAtIndex:i]];
        if( imgFilePath ){
            [arr addObject:imgFilePath];
        }
//#warning 测试，记得删除
//        [UIImageJPEGRepresentation([UIImage imageNamed:[NSString stringWithFormat:@"%02lu.png",i]], 1) writeToFile:imgFilePath atomically:YES];
    }
    
    if( arr.count == imgCount )
        return arr;
    
    return nil;
}

- (NSArray*)getMaskImgPathsWithImgCount:(NSUInteger)imgCount {
    NSMutableArray *arr = [NSMutableArray new];
    for( NSUInteger i=0; i<imgCount; i++ ){
        NSString *imgDir = [TSHelper maskClearImgPath];

        NSString *imgFilePath = [imgDir stringByAppendingPathComponent:[TSHelper getSaveWorkImgNameAtIndex:i]];
        if( imgFilePath ){
            [arr addObject:imgFilePath];
        }
    }
    
    if( arr.count == imgCount )
        return arr;
    
    return nil;
}


/**
 本地算法去底

 @param maskPaths 遮罩图的路径
 @param completeBlock 完成回调
 */
- (void)startLocalClearWorkWithMaskImgPaths:(NSArray*)maskPaths completBlock:(void (^)(NSError *err, NSArray *resultImgPaths))completeBlock{

    TSPathManager *pm = [TSPathManager sharePathManager];
    
    NSString *originPath = [pm getWorkOriginImgPathWithWorkDirName:_workModel.workDirName];
    NSString *maskPath   = [pm getWorkMaskImgPathWithWorkDirName:_workModel.workDirName];
    NSString *clearPath  = [pm getWorkClearImgPathWithWorkDirName:_workModel.workDirName];
    
    //将下载的去底中间图，移入作品的目录下
    self.workModel.maskImgPathArr =
    [self moveFiles:maskPaths toPath:maskPath];
    
    //得到去底结果图片的路径集合
    NSMutableArray *clearImgPaths = [NSMutableArray new];
    for( NSString *mp in maskPaths){
        NSString *fileName = [mp lastPathComponent];
        NSString *clearImgPath = [clearPath stringByAppendingString:fileName];
        [clearImgPaths addObject:clearImgPath];
    }
    
    NSLog(@"===============================Clear Bg Log=======================");
    NSLog(@"op=%@",originPath);
    NSLog(@"mp=%@",maskPath);
    NSLog(@"cp=%@",clearPath);
    
    [TSClearImgBg startClearImgWithOriginImgPath:originPath maskImgPath:maskPath resultImgPath:clearPath changeBgImg:nil count:maskPaths.count completBlock:^(NSError *error) {
        if( completeBlock ){
            completeBlock(error,clearImgPaths);
            
            self.workModel.clearBgImgPathArr = clearImgPaths;
            //退底成功后，暂不更新本地数据，所以注释掉
//            if( self.workModel.isLocalWork ){
//                [[PPLocalFileManager shareLocalFileManager] updateModel:self.workModel atIndex:self.workModel.imgDataIndex];
//            }
        }
    }];
}

/**
 将多个文件移入某个目录下,文件名不变

 @param filePaths 文件全路径集合
 @param toPath 新的文件的路径。
 @return 返回新的文件路径集合
 */
- (NSArray*)moveFiles:(NSArray<NSString*>*)filePaths toPath:(NSString*)toPath{
    NSMutableArray *arr = [NSMutableArray new];
    NSArray *maskPaths = filePaths;
    NSString *maskPath = toPath;
    for( NSString *mp in maskPaths){
        
        NSString *fileName = [mp lastPathComponent];
        NSString *maskImgPath = [maskPath stringByAppendingPathComponent:fileName];
        [arr addObject:maskImgPath];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        
        if([fm fileExistsAtPath:maskImgPath] ){
            [fm removeItemAtPath:maskImgPath error:nil];
        }
        
        NSError *moveErr = nil;
        [fm moveItemAtPath:mp toPath:maskImgPath error:&moveErr];
    }
    
    return arr;
}

#pragma mark - TouchEvents
- (void)handleCancleClear{
    [TSAlertView showAlertWithTitle:NSLocalizedString(@"ClearBgConfirmCancleClearTitle", nil) handleBlock:^(NSInteger index) {
        [self cancleClearingBg];
    }];
}

- (void)handleSwitchWorkBtn:(UIButton*)btn{
    if( btn.isSelected == NO){
        self.showView.imgs = self.imgs;
    }else{
        self.showView.imgs = self.clearImgs;
    }
    
    [self.showView reloadData];
    
    self.workModel.editingImgs = self.showView.imgs;
    self.workModel.editingObject = btn.isSelected?TSWorkEditObjectClearedBgWork:TSWorkEditObjectOriginWork;
    
    btn.selected = !btn.isSelected;
}

- (void)handleBottomBtn:(UIButton*)btn{
    if( btn.tag == 100 ){
        
        self.clearImgs = nil;
        self.uploadImgTask = nil;
        //若去底成功后，直接点击返回，则清空去底的缓存
        if( self.switchBtn.isHidden == NO ){
            for( NSString *path in _workModel.clearBgImgPathArr ){
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            }
            for( NSString *path in _workModel.maskImgPathArr ){
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            }
            
            self.workModel.isCanClearBg = YES;
            self.workModel.clearBgImgPathArr = nil;
            self.workModel.maskImgPathArr = nil;
        }
        
        NSLog(@"=====返回=====");
        //返回
        NSArray *ctrs = self.navigationController.viewControllers;
        //返回上上层控制器
        int index = (int)[[self.navigationController viewControllers]indexOfObject:self];
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:(index -2)] animated:YES];
        
        ctrs = nil;
        
    }else if( btn.tag == 101 ){
        
        //直接开始去底。不再需要选择设备
        if( [self isLoginedWithGotoLoginCtrl] == NO ) return;
        [self startClearBg];
        
        /*
        //是否是第一次退底
        NSString *key = @"TSCLEAR_WORK_BG_IS_FIRST_START_CLEAR_KEY0";
        BOOL isFirstClear = ![[NSUserDefaults standardUserDefaults] valueForKey:key];
        if( isFirstClear ){
            //第一次退底，弹出选择设备框
            [TSSelectDeviceView showSelectDeviceViewWithSureBlock:^{
                [self startClearBg];
            }];
            [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:key];
        }else{
            //非第一次退底，则直接退底
            if( [self isLoginedWithGotoLoginCtrl] == NO ) return;
            [self startClearBg];
        }
        */
        
    }else if( btn.tag == 102 ){
        //编辑
        TSEditWorkCtrl *wc = [TSHelper shareEditWorkCtrl];//[TSEditWorkCtrl new];
//        wc.imgs = self.showView.imgs;
        self.workModel.editingImgs = self.showView.imgs;
        wc.model = self.workModel;
        
        [wc resetDatas];
        wc.isNeedBackToWorkListCtrl = NO;
        [self pushViewCtrl:wc];
    }
}

#pragma mark - Propertys
- (TSProductionShowView *)showView {
    if( !_showView ){
        _showView = [[TSProductionShowView alloc] init];
        _showView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _showView.clipsToBounds = YES;
        [self.view addSubview:_showView];
        
        [self.view addSubview:self.bottomView];
    }
    return _showView;
}

- (UIButton *)cancleClearBgBtn {
    if( !_cancleClearBgBtn ){
        _cancleClearBgBtn = [[UIButton alloc] init];
        [_cancleClearBgBtn setTitle:NSLocalizedString(@"ClearBgCancleWrokClearingTitle", nil) forState:UIControlStateNormal];
        [_cancleClearBgBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _cancleClearBgBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _cancleClearBgBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_cancleClearBgBtn.titleLabel sizeToFit];
        //_cancleClearBgBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_cancleClearBgBtn addTarget:self action:@selector(handleCancleClear) forControlEvents:UIControlEventTouchUpInside];
        _cancleClearBgBtn.hidden = YES;
        [self.view addSubview:_cancleClearBgBtn];
    }
    return _cancleClearBgBtn;
}

- (UIButton *)switchBtn {
    if( !_switchBtn ){
        _switchBtn = [[UIButton alloc] init];
        [_switchBtn setImage:[UIImage imageNamed:@"finished_switch"] forState:UIControlStateNormal];
        [_switchBtn setTitle:NSLocalizedString(@"ClearBgSwitchOriginImgTitle", nil) forState:UIControlStateNormal];
        [_switchBtn setTitle:NSLocalizedString(@"ClearBgSwitchCleardImgTitle", nil) forState:UIControlStateSelected];
        _switchBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [_switchBtn.titleLabel sizeToFit];
        _switchBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_switchBtn setBackgroundColor:[UIColor colorWithRgb_0_151_216]];
        [_switchBtn addTarget:self action:@selector(handleSwitchWorkBtn:) forControlEvents:UIControlEventTouchUpInside];
        _switchBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 5);
        _switchBtn.hidden = YES;
        [self.view addSubview:_switchBtn];
    }
    return _switchBtn;
}

//"ClearBgClearingHudMsg"="Clearing";
- (UIView *)bottomView {
    if( !_bottomView ){
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor whiteColor];
        CGFloat baseH = 120;
        CGFloat ih = baseH + BOTTOM_NOT_SAVE_HEIGHT;
        _bottomView.frame = CGRectMake(0, (SCREEN_HEIGHT-ih), SCREEN_WIDTH, ih);
        
        UIView *line = [UIView new];
        line.backgroundColor = [UIColor colorWithRgb221];
        line.frame = CGRectMake(0, 0, _bottomView.width, 0.5);
        [_bottomView addSubview:line];
        
        NSArray *titles = @[NSLocalizedString(@"ClearBgBackTitle", nil),
                            NSLocalizedString(@"ClearBgStartClearTitle", nil),
                            NSLocalizedString(@"ClearBgEditTitle", nil)];
        NSArray *imgs = @[@"preview_back",@"preview_remove_normal",@"preview_editor"];
        for( NSUInteger i=0; i<titles.count; i++ ){
            UIButton *btn = [UIButton new];
            [_bottomView addSubview:btn];
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:imgs[i]] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            [btn setTitleColor:[UIColor colorWithRgb51] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(handleBottomBtn:) forControlEvents:UIControlEventTouchUpInside];
            CGFloat btnH = 77,btnW = _bottomView.width/titles.count;
            btn.frame = CGRectMake(i*btnW, (baseH-btnH)/2, btnW, btnH);
            
            CGFloat maxImgWH = 50,titleH = 20;
            CGSize imgSize = btn.currentImage.size;
            CGFloat titleLen = [btn.titleLabel labelSizeWithMaxWidth:btnW].width;
            CGFloat toLeft = (btnW-titleLen)/2;
            btn.titleEdgeInsets = UIEdgeInsetsMake(btnH-titleH, toLeft-imgSize.width, 0, toLeft);
            
            toLeft = (btnW-imgSize.width)/2;
            CGFloat toTop =  (maxImgWH-imgSize.height)/2;
            btn.imageEdgeInsets = UIEdgeInsetsMake(toTop, toLeft, btnH-(toTop+imgSize.height), toLeft-titleLen);
            btn.tag = 100+i;
            
            if( i==1){
                _clearBgBtn = btn;
                [_clearBgBtn setImage:[UIImage imageNamed:@"preview_remove_unnormal"] forState:UIControlStateDisabled];
                [_clearBgBtn setTitleColor:[UIColor colorWithRgb102] forState:UIControlStateDisabled];
            }
        }
        
        CGFloat iw = 180;ih = 26;
        self.switchBtn.frame = CGRectMake(SCREEN_WIDTH-iw-15, _bottomView.y - ih-15 ,iw,ih);
        [self.switchBtn cornerRadius:ih/2];
        
        iw = 150;
        self.cancleClearBgBtn.frame = CGRectMake((SCREEN_WIDTH-iw)/2, _bottomView.y-ih-20, iw, ih);
        [self.cancleClearBgBtn cornerRadius:ih/2];
        
    }
    return _bottomView;
}

@end
