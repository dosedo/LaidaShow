//
//  TSClearWorkCtrl.m
//  ThreeShow
//
//  Created by cgw on 2019/6/28.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSClearWorkCtrl.h"
#import "UIView+LayoutMethods.h"
#import "UIViewController+Ext.h"
#import "TSEditWorkCtrl.h"
#import "TSEditNaviView.h"
#import "UIColor+Ext.h"
#import "HTProgressHUD.h"
#import "NSString+Ext.h"
#import "UILabel+Ext.h"
#import "TSAlertView.h"

//去底部分
#import "TSHelper.h"
#import "TSClearImgBg.h"
#import "TSWorkModel.h"
#import "TSSelectDeviceView.h"
#import "TSPathManager.h"

static NSUInteger const gTagBase = 100;
@interface TSClearWorkCtrl ()
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) TSEditNaviView *naviView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UISlider *whiteBalanceSlider;  //白平衡
@property (nonatomic, strong) UISlider *lightSlider;  //亮度
@property (nonatomic, strong) UISlider *compareSlider;//对比度
@property (nonatomic, strong) UISlider *saturationDegreeSlider; //饱和度
@property (nonatomic, strong) HTProgressHUD *hud;
@property (nonatomic, strong) dispatch_queue_t modifyQueue;
@property (nonatomic, strong) UIButton *resetBtn; //重置按钮
@property (nonatomic, strong) UIButton *clearBtn; //一键去底按钮
@property (nonatomic, strong) UIImage *resultImg1; //修改白平衡后的结果
@property (nonatomic, strong) UIImage *resultImg2; //修改明暗、对比度、饱和度后的结果

/****************************去底部分*****************************/
@property (nonatomic, strong) UIButton *switchBtn;       //切换原图和去底图
@property (nonatomic, strong) UIButton *cancleClearBgBtn; //取消去底
@property (nonatomic, strong) NSArray *clearImgs;
@property (nonatomic, strong) NSArray *oriImgPaths;
@property (nonatomic, strong) NSArray *maskClearImgPaths;
@property (nonatomic, strong) NSArray *ClearImgPaths;
@property (nonatomic, strong) NSURLSessionDataTask *uploadImgTask;
@property (nonatomic, assign) BOOL isCleared;

@end

@implementation TSClearWorkCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRgb_240_239_244];
    
    self.modifyQueue = dispatch_queue_create("ModifyImageQ", DISPATCH_QUEUE_PRIORITY_DEFAULT);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetDatas{
    
    if( _imgs.count == 0 ) return;
    
    self.bottomView.hidden = NO;
    self.imgView.image = _imgs[0];
    self.resultImg1 = _imgs[0];
    self.resultImg2 = _imgs[0];
    self.lightSlider.value = 50;
    self.whiteBalanceSlider.value = 50;
    self.compareSlider.value = 0;
    self.saturationDegreeSlider.value = 50;
    
    //    [self modifyimg];
    
    self.resetBtn.enabled = YES;
    self.lightSlider.enabled = YES;
    self.whiteBalanceSlider.enabled = YES;
    self.compareSlider.enabled = YES;
    self.saturationDegreeSlider.enabled = YES;
    NSArray *values = @[@50,@50,@0,@50];
    for( NSUInteger i=0; i<values.count; i++ ){
        UILabel *lbl = (UILabel*)[self.bottomView viewWithTag:i+gTagBase];
        NSNumber *num = values[i];
        lbl.text = [NSString stringWithFormat:@"%ld%%", (long)num.integerValue];
    }
}

#pragma mark - Private
- (UISlider*)getSlider{
    UISlider *sli = [[UISlider alloc] init];
    sli.value = 50;
    sli.maximumValue = 100;
    sli.minimumTrackTintColor = [UIColor colorWithRgb_0_151_216];
    sli.thumbTintColor = [UIColor colorWithRgb_0_151_216];
    [sli addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventTouchUpInside];
    [sli setThumbImage:[UIImage imageNamed:@"edit_slider"] forState:UIControlStateNormal];
    [sli setThumbImage:[UIImage imageNamed:@"edit_slider"] forState:UIControlStateHighlighted];
    [sli setThumbImage:[UIImage imageNamed:@"edit_slider"] forState:UIControlStateSelected];
    return sli;
}

- (UILabel*)getLabelWithTextAlignt:(NSTextAlignment)align text:(NSString*)text inView:(UIView*)inView{
    UILabel *lbl = [UILabel new];
    [inView addSubview:lbl];
    
    lbl.textAlignment = align;
    lbl.text = text;
    lbl.textColor = [UIColor colorWithRgb51];//_0_151_216];
    lbl.font = [UIFont systemFontOfSize:14];
    
    return lbl;
}

/**
 修改图片的白平衡
 
 @param value 白平衡的值 0 - 100
 @return 返回新的图片
 */
- (UIImage*)modifyImgWhiteBalance:(CGFloat)value img:(UIImage*)img{
    UIImageOrientation ori = img.imageOrientation;
    if( [img isKindOfClass:[UIImage class]] == NO ) return nil;
    
    UIImage *myImage = img;//[UIImage imageNamed:@"Superman"];
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *superImage = [CIImage imageWithCGImage:myImage.CGImage];
    CIFilter *lighten = [CIFilter filterWithName:@"CIWhitePointAdjust"];
    [lighten setValue:superImage forKey:kCIInputImageKey];
    
    if (@available(iOS 10_0, *)) {
        CGFloat va = (100-value)/100;
        CIColor *color = [CIColor colorWithRed:va green:va blue:va alpha:1];
        [lighten setValue:color forKey:kCIInputColorKey];
    } else {
        // Fallback on earlier versions
    }
    
    CIImage *result = [lighten valueForKey:kCIOutputImageKey];
    
    CGImageRef cgImage = [context createCGImage:result fromRect:[superImage extent]];
    
    // 得到修改后的图片
    
    myImage = [UIImage imageWithCGImage:cgImage scale:1 orientation:ori];
    // 释放对象
    CGImageRelease(cgImage);
    
    return myImage;
}

/**
 修改图片的对比度，白平衡，亮度
 
 @param value 白平衡的值 0 - 100
 @param light 亮度的值 0 - 100
 @param compare 对比度 0 - 100
 @return 返回新的图片
 */
- (UIImage*)modifyImgWhiteBalance:(CGFloat)value light:(CGFloat)light compare:(CGFloat)compare img:(UIImage*)img{
    UIImageOrientation ori = img.imageOrientation;
    if( [img isKindOfClass:[UIImage class]] == NO ) return nil;
    
    UIImage *myImage = img;//[UIImage imageNamed:@"Superman"];
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *superImage = [CIImage imageWithCGImage:myImage.CGImage];
    CIFilter *lighten = [CIFilter filterWithName:@"CIColorControls"];
    [lighten setValue:superImage forKey:kCIInputImageKey];
    
    if( light >= 0 ){
        // 修改亮度   -1---1   数越大越亮
        CGFloat li = (light-50)/(50);
        
        [lighten setValue:@(li) forKey:@"inputBrightness"];
    }
    if( value >=0 ){
        // 修改饱和度  0---2 白平衡
        CGFloat balance = value/(100/2);
        [lighten setValue:@(balance) forKey:@"inputSaturation"];
    }
    
    if( compare >= 0 ){
        // 修改对比度  0---4
        CGFloat compareValue = compare/(100/3) + 1;
        [lighten setValue:@(compareValue) forKey:@"inputContrast"];
    }
    CIImage *result = [lighten valueForKey:kCIOutputImageKey];
    
    CGImageRef cgImage = [context createCGImage:result fromRect:[superImage extent]];
    
    // 得到修改后的图片
    myImage = [UIImage imageWithCGImage:cgImage scale:1 orientation:ori];
    // 释放对象
    CGImageRelease(cgImage);
    
    return myImage;
}

- (void)modifyimgWithIsModifyWhiteBalance:(BOOL)isModifyWhiteBalance{
    self.naviView.sureBtn.enabled = NO;
    dispatch_async(self.modifyQueue, ^{
        if( _imgs.count ){
            UIImage *oriImg = _imgs[0];
            UIImage *img = nil;
            if( isModifyWhiteBalance ){
                img =
                [self modifyImgWhiteBalance:self.whiteBalanceSlider.value img:oriImg];
//                self.resultImg1 = img;
            }
            else{
                img =
                [self modifyImgWhiteBalance:self.saturationDegreeSlider.value light:self.lightSlider.value compare:self.compareSlider.value img:oriImg];
//                self.resultImg2 = img;
            }
            
            [self dispatchAsyncMainQueueWithBlock:^{
                self.naviView.sureBtn.enabled = YES;
                self.imgView.image = img;
                
                self.compareSlider.enabled = YES;
                self.lightSlider.enabled = YES;
                self.whiteBalanceSlider.enabled = YES;
                self.resetBtn.enabled = YES;
                self.saturationDegreeSlider.enabled = YES;
            }];
        }
    });
}

//保存所有修改的图片
- (void)saveModifyImgs{
    _hud = [HTProgressHUD showMessage:NSLocalizedString(@"WorkEditSaveingImgs", nil) toView:self.view];
    [self dispatchAsyncQueueWithName:@"modifyImgsQ" block:^{
        NSMutableArray *arr = [NSMutableArray new];
        NSUInteger idx= 0;
        for( UIImage *oriImg in _imgs ){
            @autoreleasepool {
                UIImage *img =
                [self modifyImgWhiteBalance:self.whiteBalanceSlider.value light:self.lightSlider.value compare:self.compareSlider.value img:oriImg];
                img = [self regetModifyImg:img atIndex:idx];
                if( img ){
                    [arr addObject:img];
                }
                
                idx ++;
            }
        }
        
        [self dispatchAsyncMainQueueWithBlock:^{
            
            [_hud hide];
            
            [self.editWorkCtrl modifyImgCompete:arr];
            [self handleClose];
        }];
    }];
}

- (UIImage*)regetModifyImg:(UIImage*)myImage atIndex:(NSUInteger)idx{
    if( myImage ){
        NSString *tempImgPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"editModifyTemp%ld.jpg",idx]];
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isExist = [fm fileExistsAtPath:tempImgPath];
        if( isExist ){
            [fm removeItemAtPath:tempImgPath error:nil];
        }
        
        [UIImageJPEGRepresentation(myImage, 1) writeToFile:tempImgPath atomically:YES];
        
        myImage = nil;
        
        NSData *imageData = [NSData dataWithContentsOfFile:tempImgPath options:NSDataReadingMappedIfSafe error:nil];
        UIImage * img = [UIImage imageWithData:imageData];
        imageData = nil;
        
        return img;
    }
    return nil;
}

#pragma mark - 去底部分
- (void)startClearBg{
    
    NSLog(@"======去底====");
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

- (void)updateViewStateWithClearState:(TSClearWorkBgState)state{
    
    switch (state) {
        case TSClearWorkBgStateNotBegin:
        {
            self.cancleClearBgBtn.hidden = YES;
            self.switchBtn.hidden = YES;
            self.clearBtn.enabled = YES;
            
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
            self.clearBtn.enabled = NO;
        }
            break;
        case TSClearWorkBgStateComplete:
        {
            self.cancleClearBgBtn.hidden = YES;
            self.switchBtn.hidden = NO;
            self.clearBtn.enabled = NO;
            [_hud hide];
        }
        default:
            break;
    }
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
    //去底成功，更新图片数据
//    self.showView.imgs = arr;
//    [self.showView reloadData];
    NSLog(@"ifReadOnly value: %@" ,_isCleared?@"YES":@"NO");
    self.isCleared = YES;
    NSLog(@"ifReadOnly value: %@" ,_isCleared?@"YES":@"NO");
    [self updateViewStateWithClearState:TSClearWorkBgStateComplete];
    
    //去底成功 返回上一页,并将去底传过
    self.editWorkCtrl.model.editingObject = TSWorkEditObjectClearedBgWork;
    [self.editWorkCtrl modifyImgCompete:arr];
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)cancleClearingBg{
    [TSHelper sharedHelper].isCancleClearBg = YES;
    [_uploadImgTask cancel];
    [self updateViewStateWithClearState:TSClearWorkBgStateNotBegin];
}

- (void)handleCancleClear{
    [TSAlertView showAlertWithTitle:NSLocalizedString(@"ClearBgConfirmCancleClearTitle", nil) handleBlock:^(NSInteger index) {
        [self cancleClearingBg];
    }];
}

#pragma mark - TouchEvents
- (void)handleClose{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleSave{
    [self saveModifyImgs];
}

- (void)handleResetBtn{
    
    [self resetDatas];
    
//    self.lightSlider.value = 50;
//    self.whiteBalanceSlider.value = 50;
//    self.compareSlider.value = 0;
//    self.saturationDegreeSlider.value = 50;
////    [self modifyimg];
//    
//    NSArray *values = @[@50,@50,@0];
//    for( NSUInteger i=0; i<3; i++ ){
//        UILabel *lbl = (UILabel*)[self.bottomView viewWithTag:i+gTagBase];
//        NSNumber *num = values[i];
//        lbl.text = [NSString stringWithFormat:@"%ld", (long)num.integerValue];
//    }
}

- (void)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    UILabel *lbl = (UILabel*)[self.bottomView viewWithTag:slider.tag+gTagBase];
    lbl.text = [NSString stringWithFormat:@"%d%%", (int)slider.value];
    
    self.whiteBalanceSlider.enabled = NO;
    self.lightSlider.enabled = NO;
    self.compareSlider.enabled = NO;
    self.resetBtn.enabled = NO;
    [self modifyimgWithIsModifyWhiteBalance:[sender isEqual:self.whiteBalanceSlider]];
}

- (void)handleClearBtn{
    //点击一键去底
    if ( self.workModel.isCleared ) {
        [TSAlertView showAlertWithTitle:@"已经去底过了，试试换底吧"];
        return;
    }
    
    //直接退底
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
        [self startClearBg];
    }
     */
}

#pragma mark - Propertys

- (UIView *)bottomView {
    if( !_bottomView ){
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor whiteColor];
        CGFloat ih = self.naviView.height + 140 + 30 + 10;
        _bottomView.frame = CGRectMake(0, SCREEN_HEIGHT-ih, SCREEN_WIDTH, ih);
        CGRect fr = self.naviView.frame;
        fr.origin.y = _bottomView.height-fr.size.height;
        self.naviView.frame = fr;
        [_bottomView addSubview:self.naviView];
        
        self.clearBtn.center = CGPointMake(self.clearBtn.center.x, 4*30/2);
        [_bottomView addSubview:self.clearBtn];
        
        
        NSArray *titles = @[NSLocalizedString(@"WorkEditBottomModifyWhiteBalance", nil),
                            NSLocalizedString(@"WorkEditBottomModifyLight", nil),
                            NSLocalizedString(@"WorkEditBottomModifyDuibidu", nil),
                            NSLocalizedString(@"WorkEditBottomModifySaturation", nil)];//@[@"白平衡",@"明暗",@"对比度"];
        NSArray *values = @[@"50",@"50",@"0",@"50"];
        NSArray *sliders = @[self.whiteBalanceSlider,self.lightSlider,self.compareSlider,self.saturationDegreeSlider];
        for( NSUInteger i=0; i<titles.count; i++ ){
            CGFloat ix = 15,iw = 45+15,ih = 30;
            CGFloat iy = i*ih;
            UILabel *markL = [self getLabelWithTextAlignt:NSTextAlignmentRight text:titles[i] inView:_bottomView];
//            markL.numberOfLines = 2;
//            markL.adjustsFontSizeToFitWidth = YES;
            markL.frame = CGRectMake(ix, iy, iw, ih);
            
            UILabel *valueL = [self getLabelWithTextAlignt:NSTextAlignmentRight text:values[i] inView:_bottomView];
            iw = 40;
            ix = self.clearBtn.x-iw;
            valueL.frame = CGRectMake(ix, markL.y, iw, markL.height);
            valueL.tag = i+gTagBase;
            
            UISlider* slider = sliders[i];
            slider.tag = i;
            iw = valueL.x - markL.right-5;
            ih = 20;
            slider.frame = CGRectMake(markL.right+5, markL.center.y-ih/2, iw, ih);
            [_bottomView addSubview:slider];
        }
        
        UIButton *resetBtn = [UIButton new];
        CGFloat iw = 70;ih  = 35;
        CGFloat ix = (_bottomView.width-iw)/2;
        CGFloat topH = 90+40;
        resetBtn.frame = CGRectMake(ix, (self.naviView.y-topH-ih)/2+topH, iw, ih);
        [resetBtn setTitle:NSLocalizedString(@"WorkEditBottomModifyResetTitle", nil) forState:UIControlStateNormal];
        [resetBtn setTitleColor:[UIColor colorWithRgb51] forState:UIControlStateNormal];
        [resetBtn setTitleColor:[UIColor colorWithRgb153] forState:UIControlStateHighlighted];
        [resetBtn cornerRadius:ih/2];
        resetBtn.layer.borderColor = [UIColor colorWithRgb102].CGColor;
        resetBtn.layer.borderWidth = 0.5;
        resetBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [resetBtn addTarget:self action:@selector(handleResetBtn) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:resetBtn];
        _resetBtn = resetBtn;
        
        [self.view addSubview:_bottomView];
        
        iw = 150;
        self.cancleClearBgBtn.frame = CGRectMake((SCREEN_WIDTH-iw)/2, _bottomView.y-ih-20, iw, ih);
        [self.cancleClearBgBtn cornerRadius:ih/2];
    }
    return _bottomView;
}

- (UIImageView *)imgView {
    if( !_imgView ){
        _imgView = [[UIImageView alloc] init];
        _imgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.bottomView.y);
        _imgView.userInteractionEnabled = YES;
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:_imgView];
    }
    return _imgView;
}

- (TSEditNaviView *)naviView {
    if( !_naviView ){
        _naviView = [[TSEditNaviView alloc] initWithTitle:NSLocalizedString(@"WorkEditBottomModify", nil) target:self cancleSel:@selector(handleClose) sureSel:@selector(handleSave)];
        CGFloat ih = BOTTOM_NOT_SAVE_HEIGHT+45+15;
        _naviView.frame = CGRectMake(0, SCREEN_HEIGHT-ih, SCREEN_WIDTH, ih);
    }
    return _naviView;
}

- (UISlider *)whiteBalanceSlider {
    if( !_whiteBalanceSlider ){
        _whiteBalanceSlider = [self getSlider];
        _whiteBalanceSlider.value = 50;
    }
    return _whiteBalanceSlider;
}

- (UISlider *)lightSlider {
    if( !_lightSlider ){
        _lightSlider = [self getSlider];
        _lightSlider.value = 50;
    }
    return _lightSlider;
}

- (UISlider *)compareSlider {
    if( !_compareSlider ){
        _compareSlider = [self getSlider];
        _compareSlider.value = 0;
    }
    return _compareSlider;
}

- (UISlider *)saturationDegreeSlider {
    if( !_saturationDegreeSlider ){
        _saturationDegreeSlider = [self getSlider];
        _saturationDegreeSlider.value = 50;
    }
    return _saturationDegreeSlider;
}

- (UIButton *)clearBtn{
    if( !_clearBtn ){
        NSString *title = NSLocalizedString(@"ClearBgStartClearTitle", nil);
        NSString *imgName = @"editor_qudi_n";
       
        UIButton *btn = [UIButton new];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [btn setTitleColor:[UIColor colorWithRgb51] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(handleClearBtn) forControlEvents:UIControlEventTouchUpInside];
        CGFloat btnH = 77,btnW = 100;//_bottomView.width/titles.count;
        btn.frame = CGRectMake(SCREEN_WIDTH-btnW, 0, btnW, btnH);
        
        CGFloat maxImgWH = 60,titleH = 20;
        CGSize imgSize = CGSizeMake(60, 60);//btn.currentImage.size;
        CGFloat titleLen = [btn.titleLabel labelSizeWithMaxWidth:btnW].width;
        CGFloat toLeft = (btnW-titleLen)/2;
        btn.titleEdgeInsets = UIEdgeInsetsMake(btnH-titleH, toLeft-imgSize.width, 0, toLeft);
        
        toLeft = (btnW-imgSize.width)/2;
        CGFloat toTop =  (maxImgWH-imgSize.height)/2;
        btn.imageEdgeInsets = UIEdgeInsetsMake(toTop, toLeft, btnH-(toTop+imgSize.height), toLeft-titleLen);
        [btn setImage:[UIImage imageNamed:@"editor_qudi_s"] forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor colorWithRgb102] forState:UIControlStateDisabled];
        
        _clearBtn = btn;
    }
    return _clearBtn;
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

@end
