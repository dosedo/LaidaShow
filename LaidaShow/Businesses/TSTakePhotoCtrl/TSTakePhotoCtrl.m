//
//  TSTakePhotoCtrl.m
//  ThreeShow
//
//  Created by hitomedia on 12/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSTakePhotoCtrl.h"
#import "UIViewController+Ext.h"
#import "UIView+LayoutMethods.h"
#import "TSPhotoCountSelectView.h"
#import "TSTakedPhotoListView.h"
#import "SCCaptureSessionManager.h"
#import "MyBleClass.h"
#import "HTProgressHUD.h"
#import "UIImage+Extras.h"
#import "TSEditWorkCtrl.h"
#import "TSHelper.h"
#import "KCommon.h"
#import "TSClearWorkBgCtrl.h"
#import "UIImage+image.h"
#import "JKRCameraBackgroundView.h"
#import "TSPathManager.h"
#import "TSTakePhotoCompleteCtrl.h"
//#import "SCSlider.h"

@interface TSTakePhotoCtrl ()<MyBleDelegate,SCCaptureSessionManager,JKRCameraBackgroundViewDelegate,JKRCameraBackgroundViewDatasource>
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) TSPhotoCountSelectView *countView;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *takeBtn;
@property (nonatomic, strong) UIButton *shootingGridBtn;//网格按钮
@property (nonatomic, strong) UILabel  *takedPhotoCountL;//已拍照片数量
@property (nonatomic, strong) UIImageView *shootingGridView;//网格视图
@property (nonatomic, strong) TSTakedPhotoListView *photoList;
@property (nonatomic, strong) NSMutableArray *imgArr;

//相机部分
@property (nonatomic, strong) SCCaptureSessionManager *captureManager;
//@property (nonatomic, strong) SCSlider       *scSlider;
@property (nonatomic, assign) CGRect         previewRect;

//设备
@property (nonatomic, strong) MyBleClass *bluetoothManager;


//@property (nonatomic, strong) CAShapeLayer *focusLayer;

@property (nonatomic, strong) JKRCameraBackgroundView *backgroundView; // 控制界面

@end

@implementation TSTakePhotoCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self addLeftBarItemWithTitle:nil action:nil];
    //拍照界面常亮
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    
//    CGFloat ih = 180+BOTTOM_NOT_SAVE_HEIGHT;
//    UIView *expuoreView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-ih, self.view.frame.size.width, 20)];
    
    //添加镜头拉伸手势
    [self addPinchGesture];
    
    //聚焦手势
    //[self addGestureRecognizer];
}

//-(void)addGestureRecognizer{
//
//    //添加镜头拉伸手势
//    //[self addPinchGesture];
//
//}

- (void)resetDatas{

    //设置缩放为初始值
    [_captureManager pinchCameraViewWithScalNum:1];
    
    //展示相机界面
    [self.captureManager.session startRunning];
    [MyPublic shareMyBleClass].delegate = self;
    self.countView.selectedIndex = 0;
    [self.countView reloadDatas];
    
    self.takeBtn.selected = NO;
    [self updateViewStatusWithIsTakingPhoto:NO];
    [self.imgArr removeAllObjects];
    //注：下面这行不能在viewDidload中加载，否则不会显示。注意加载顺序的问题
    //[self.view addSubview:self.isoSilder];
    
    _backgroundView = [[JKRCameraBackgroundView alloc] initWithFrame:self.view.bounds];
    _backgroundView.delegate = self;
    _backgroundView.datasource = self;
    
    //隐藏滑动增加或减少曝光视图
//    _backgroundView.isoSilder.hidden = YES;
//    _backgroundView.butplus.hidden = YES;
//    _backgroundView.minusBtn.hidden = YES;
    
    [self.view addSubview:_backgroundView];
    [_backgroundView addSubview:self.bottomView];

    [self.captureManager focusInPoint:self.backgroundView.center];
    
    // 这里就是监听相机自动对焦的
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:self.captureManager.inputDevice];
    
    [[self.captureManager.inputDevice device] addObserver:self forKeyPath:@"ISO" options:NSKeyValueObservingOptionNew context:NULL];
    
    //[self addGestureRecognizer];
    [self reloadPhotoListData];
    
    self.takedPhotoCountL.hidden = YES;
}

- (void)subjectAreaDidChange:(NSNotification *)notification

{
    //先进行判断是否支持控制对焦
    if(self.captureManager.inputDevice.device.isFocusPointOfInterestSupported &&[self.captureManager.inputDevice.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error = nil;
        [self.captureManager.inputDevice.device lockForConfiguration:&error];
        [self.captureManager.inputDevice.device setFocusMode:AVCaptureFocusModeAutoFocus];
        [self.captureManager focusInPoint:self.view.center];
        
        //操作完成后，记得进行unlock。
        
        [self.captureManager.inputDevice.device unlockForConfiguration];
    }
    
}
#pragma mark -曝光
//static const NSString *cameraAdjustingExposureContext;
static void *ExposureTargetOffsetContext = &ExposureTargetOffsetContext;
- (void)exposeAtPoint:(CGPoint)point{
    AVCaptureDevice *captureDevice = [self.captureManager.inputDevice device];
    if ([captureDevice isExposureModeSupported:(AVCaptureExposureModeContinuousAutoExposure)]) {
        NSError *error;
        if ([captureDevice lockForConfiguration:&error]) {
            captureDevice.exposurePointOfInterest = point;
            captureDevice.focusMode = AVCaptureExposureModeContinuousAutoExposure;
            if ([captureDevice isExposureModeSupported:(AVCaptureExposureModeLocked)]) {
                [captureDevice addObserver:self forKeyPath:@"adjustingExposure" options:(NSKeyValueObservingOptionNew) context:ExposureTargetOffsetContext];
            }
            [captureDevice unlockForConfiguration];
        }else{
            [self showErrMsgWithError:error];
        }
    }
}

#pragma mark - 调节ISO，光感度
- (void)cameraBackgroundDidChangeISO:(CGFloat)iso isPlusOrMinusBtn:(BOOL)isPlusOrMinusBtn{
    
    NSLog(@"1223");
//    return;
    if( isPlusOrMinusBtn )
        [[self.captureManager.inputDevice device] removeObserver:self forKeyPath:@"ISO"];
    
    AVCaptureDevice *captureDevice = [self.captureManager.inputDevice device];
    NSError *error;
    if ([captureDevice lockForConfiguration:&error]) {
        CGFloat minISO = captureDevice.activeFormat.minISO;
        CGFloat maxISO = captureDevice.activeFormat.maxISO;
        CGFloat currentISO = (maxISO - minISO) * iso + minISO;
        NSLog(@"====currentISO %f",currentISO);
//        NSLog(@"====minISO %f",minISO);
//        NSLog(@"====maxISO %f",maxISO);
//        NSLog(@"====当前传入的ISO:%f",iso);
        CMTime minExposure = captureDevice.activeFormat.minExposureDuration;
        CMTime maxExposure = captureDevice.activeFormat.maxExposureDuration;
        float durationFloat = CMTimeGetSeconds(minExposure);
        float durationFloatM = CMTimeGetSeconds(maxExposure);
//        NSLog(@"====durationFloat %f",durationFloat);
//        NSLog(@"====durationFloatM:%f",durationFloatM);
        
        [captureDevice setExposureModeCustomWithDuration:AVCaptureExposureDurationCurrent ISO:currentISO completionHandler:nil];
       
        [captureDevice unlockForConfiguration];
        //NSLog(@"====DurationCurrent: %f",CMTimeGetSeconds(AVCaptureExposureDurationCurrent));
    }else{
        // Handle the error appropriately.
    }
    
    if( isPlusOrMinusBtn )
        [[self.captureManager.inputDevice device] addObserver:self forKeyPath:@"ISO" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)cameraBackgroundView:(JKRCameraBackgroundView *)cv touchDownSlider:(UISlider *)slider{
    [[self.captureManager.inputDevice device] removeObserver:self forKeyPath:@"ISO"];
}

- (void)cameraBackgroundView:(JKRCameraBackgroundView *)cv touchUpSlider:(UISlider *)slider{
    [[self.captureManager.inputDevice device] addObserver:self forKeyPath:@"ISO" options:NSKeyValueObservingOptionNew context:NULL];
}

#pragma mark - 点击屏幕对焦
- (void)cameraBackgroundDidTap:(CGPoint)point {
    NSLog(@"===点击屏幕对焦===%f==%f",point.x,point.y);
    AVCaptureDevice *captureDevice = [self.captureManager.inputDevice device];
    NSError *error;
    if ([captureDevice lockForConfiguration:&error]) {
        CGPoint location = point;
        CGPoint pointOfInerest = CGPointMake(0.5, 0.5);
        CGSize frameSize = self.captureManager.previewLayer.frame.size;
        if ([captureDevice position] == AVCaptureDevicePositionFront) location.x = frameSize.width - location.x;
        pointOfInerest = CGPointMake(location.y / frameSize.height, 1.f - (location.x / frameSize.width));
        [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposureMode:AVCaptureExposureModeContinuousAutoExposure atPoint:pointOfInerest];
        
        //[[self.captureManager.inputDevice device] addObserver:self forKeyPath:@"ISO" options:NSKeyValueObservingOptionNew context:NULL];
    }else{
        // Handle the error appropriately.
    }
}

-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    AVCaptureDevice *captureDevice = [self.captureManager.inputDevice device];
    NSError *error;
    if ([captureDevice lockForConfiguration:&error]) {
        if ([captureDevice isFocusModeSupported:focusMode]) [captureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        if ([captureDevice isFocusPointOfInterestSupported]) [captureDevice setFocusPointOfInterest:point];
        if ([captureDevice isExposureModeSupported:exposureMode]) [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        if ([captureDevice isExposurePointOfInterestSupported]) [captureDevice setExposurePointOfInterest:point];
    }else{
        // Handle the error appropriately.
    }
}

#pragma mark - 重置状态
//- (void)reset {
//    [_backgroundView reset];
//}

#pragma mark - KVO回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    //[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    if ([keyPath isEqualToString:@"ISO"]) {
        CGFloat minISO = self.captureManager.inputDevice.device.activeFormat.minISO;
        CGFloat maxISO = self.captureManager.inputDevice.device.activeFormat.maxISO;
        CGFloat currentISO = self.captureManager.inputDevice.device.ISO;
        CGFloat value = (currentISO - minISO) / (maxISO - minISO);
        _backgroundView.isoSilder.value = value;
//        NSLog(@"===ISO===%f",_backgroundView.isoSilder.value);
        //adjustingExposure
//        BOOL res = self.captureManager.inputDevice.device.adjustingExposure;
//        NSLog(@"===是否改变曝光值：%d",res);
    }
}

-(void)dealloc{
    //移除观察者 在dealloc中
    [[self.captureManager.inputDevice device] removeObserver:self forKeyPath:@"ISO"];
    [self.captureManager.session stopRunning];
    [self.view removeFromSuperview];
    self.captureManager.previewLayer = nil;
    NSLog(@"===走这里？？？");
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self addRecieveDeviceNotiObserver];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self removeRecieveDeviceNotiObserver];
    
    if (self.captureManager.session) {
        [self.captureManager.session stopRunning];
    }
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

#pragma mark - Private

- (void)reloadPhotoListData{
    self.photoList.itemCount = [self takeTotalPhotoCount];
    [self.photoList reloadData];
}

- (void)addRecieveDeviceNotiObserver{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(startTakePicture:) name:MyBleDidRecieveDeviceMsgNotification object:nil];
}

- (void)removeRecieveDeviceNotiObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MyBleDidRecieveDeviceMsgNotification object:nil];
    
}

-(void)updatePhotoIndex:(NSUInteger)index{
    NSUInteger count = index;
    self.takedPhotoCountL.hidden = (index<=0);
    self.takedPhotoCountL.text = [NSString stringWithFormat:@"%lu",(unsigned long)count];
}


- (NSInteger)takeTotalPhotoCount{
    
//    return 1;

    if( self.countView.titles.count > self.countView.selectedIndex ){
        NSString *countStr = _countView.titles[_countView.selectedIndex];
        return  countStr.integerValue;
    }
    
    return 18;
}

- (void)updateViewStatusWithIsTakingPhoto:(BOOL)isTaking{
    self.takeBtn.selected = isTaking;
    self.photoList.hidden = !isTaking;
    self.countView.hidden = isTaking;
    self.countView.userInteractionEnabled = !isTaking;
    self.takedPhotoCountL.text = @"0";
}

#pragma mark __图片处理

-(BOOL)deviceMemoryLessThan1G{
    if( [KCommon getDeviceMemorySize]/1024.0 <= 1 )
        return YES;
    return NO;
}

-(CGSize)getCompressImgSize{
    CGFloat scale = 3;
        if( [self deviceMemoryLessThan1G] ){
            scale = 2.0;
        }
    //    if( [KCommon getDeviceCategory] == DeviceCategoryIPhone6Plus ){
    //        scale = 1;
    //    }
    return CGSizeMake(360*scale, 640*scale);
}

-(CGFloat)getCompressImgScale{
    
    if( self.countView.selectedIndex >= 1 ){
        //36 张或 72张
        return 0.4;
    }
    return 0.5;
    
    
    CGFloat scale = 0.5;

    if( [UIView screenType] == UIScreenTypeIPhone5 ){
        scale = 0.3;
    }
    
    if( [UIView screenType] == UIScreenTypeIPhone5s ){
        scale = 0.8;
    }
    else if( [UIView screenType] == UIScreenTypeIPhone6sPlus ){
        scale = 0.8;
    }
    
    return scale;
}

//-(void)scaleResultImgTo600px{
//
//    NSString *imgPath = [[PPFileManager sharedFileManager] getResultImgPath];
//    UIImage *img = [UIImage imageWithContentsOfFile:imgPath];
//    if( img ){
//
//        CGSize targetSize = [img scaleImg:img scaleToHeight:600 scaleToWidth:0 isScaleHeight:YES];
//        UIImage *retImg = [img imageByScalingToSize:targetSize isNeedCut:YES];
//
//        [[NSFileManager defaultManager] removeItemAtPath:imgPath error:nil];
//
//        [UIImageJPEGRepresentation(retImg, 0.75) writeToFile:imgPath atomically:YES];
//    }
//}

#pragma mark - 发送指令给设备
// 给设备发送拍照数据指令
- (void)sendTakePhotoDataToDevice {

    if (self.bluetoothManager.connectedShield.state  != CBPeripheralStateConnected ) {
        [HTProgressHUD showError:NSLocalizedString(@"TakePhotoPleaseConnectDevice", nil)];//@"设备已断开，请连接设备"];
        
        [self updateViewStatusWithIsTakingPhoto:NO];
        return;
    }
    //0 18张， 1 36张，2 72张 421
    Byte counts[] = {0x04,0x02,0x01};
    Byte takeCount = counts[0];
    if( self.countView.selectedIndex < 3 ){
        takeCount = counts[self.countView.selectedIndex];
    }
    
    Byte refresh = 0x00;
    if( ![self.bluetoothManager.connectedShield.name containsString:@"FC-30M"] ){
        refresh = 0x01;
    }
    
    [self sendCommandToDevieWithMode:0x07 speed:takeCount refresh:refresh];
}

// 给设备发送拍照数据指令
- (void)sendCommandToDevieWithMode:(Byte)mode speed:(Byte)speed refresh:(Byte)refresh{

    if (self.bluetoothManager.connectedShield.state  != CBPeripheralStateConnected ) {
        [HTProgressHUD showError:NSLocalizedString(@"TakePhotoPleaseConnectDevice", nil)];//@"设备已断开，请连接设备"];
        
        [self updateViewStatusWithIsTakingPhoto:NO];
        return;
    }
//    //0 18张， 1 36张，2 72张 421
//    Byte counts[] = {0x04,0x02,0x01};
//    Byte takeCount = counts[0];
//    if( self.countView.selectedIndex < 3 ){
//        takeCount = counts[self.countView.selectedIndex];
//    }
    Byte mybytes[] = {0x11 ,0x01 ,0x00 ,0x00 ,0x00 ,mode ,speed ,refresh ,0x00 ,0x00 ,0x00 ,0x00 ,0x00 ,0x00 ,0x00 ,0x0d ,0x0a};
    [self.bluetoothManager MybleSendBytes:mybytes :sizeof(mybytes)];
}

#pragma mark __拍照部分

//伸缩镜头的手势
- (void)addPinchGesture {
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinch];

//    //竖向
//    CGFloat width = 40;
//    CGFloat height = _previewRect.size.height - 100;
//    SCSlider *slider = [[SCSlider alloc] initWithFrame:CGRectMake(_previewRect.size.width - width, (_previewRect.size.height + 0 - height) / 2, width, height) direction:SCSliderDirectionVertical];
//    slider.alpha = 0.f;
//    slider.minValue = MIN_PINCH_SCALE_NUM;
//    slider.maxValue = MAX_PINCH_SCALE_NUM;
//
//    WEAKSELF_SC
//    [slider buildDidChangeValueBlock:^(CGFloat value) {
//        [weakSelf_SC.captureManager pinchCameraViewWithScalNum:value];
//    }];
//    [slider buildTouchEndBlock:^(CGFloat value, BOOL isTouchEnd) {
//        [weakSelf_SC setSliderAlpha:isTouchEnd];
//    }];
//#warning 暂时去掉了  缩放照片界面时的黄条   slider
//    //    [self.view addSubview:slider];
//
//    self.scSlider = slider;
}

//- (void)setSliderAlpha:(BOOL)isTouchEnd {
//    if (_scSlider) {
//        _scSlider.isSliding = !isTouchEnd;
//
//        if (_scSlider.alpha != 0.f && !_scSlider.isSliding) {
//            double delayInSeconds = 3.88;
//            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                if (_scSlider.alpha != 0.f && !_scSlider.isSliding) {
//                    [UIView animateWithDuration:0.3f animations:^{
//                        _scSlider.alpha = 0.f;
//                    }];
//                }
//            });
//        }
//    }
//}

///// 拍摄完视频，给设备发送复位指令
//- (void)sendRecoverCommandToDevice{
//    //0 18张， 1 36张，2 72张
////    Byte takeCount = self.countView.selectedIndex;
//    Byte mybytes[] = {0x11 ,0x01 ,0x55 ,0x01 ,0x02 ,0x04 ,0x00 ,0x00 ,0x11 ,(Byte) 0x88 ,(Byte) 0x88 ,(Byte) 0x88 ,0x00 ,0x00 ,0x00 ,0x0d ,0x0a};
//    [self.bluetoothManager MybleSendBytes:mybytes :sizeof(mybytes)];
//}

- (void)takePhotoComplete{
    //拍照完成
    [HTProgressHUD showSuccess:NSLocalizedString(@"PhotoCompletion", nil)];//@"拍照完成"
    
    TSTakePhotoCompleteCtrl *compCtrl = [TSTakePhotoCompleteCtrl new];
    compCtrl.imgs = self.imgArr;
    [self pushViewCtrl:compCtrl];
}

#pragma mark - Layouts
- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    CGFloat wh = 66;
    self.closeBtn.frame = CGRectMake(0, self.takeBtn.center.y-wh/2.0, wh, wh);
    self.shootingGridBtn.frame = CGRectMake(SCREEN_WIDTH-wh, self.closeBtn.y, wh, wh);
    self.takedPhotoCountL.frame = CGRectMake(SCREEN_WIDTH-2*wh, self.takeBtn.center.y-wh/2.0, wh, wh);
}

#pragma mark - TouchEvents
- (void)handleCloseBtn{
    [self.navigationController popViewControllerAnimated:YES];
    [self.backgroundView.isoSilder removeFromSuperview];
    [self.backgroundView removeFromSuperview];
    [self.captureManager.session stopRunning];
    [[self.captureManager.inputDevice device] removeObserver:self forKeyPath:@"ISO"];
    //[self reset];
}

- (void)handleTakeBtn:(UIButton*)btn{
//    [self.imgArr removeAllObjects];
//    for(int i=1; i<=1; i++){
//        NSString *name = [NSString stringWithFormat:@"%02d.jpg",i];
//        UIImage *img = [UIImage imageNamed:name];
//        [self.imgArr addObject:img];
//        [self.photoList addImg:img];
//        //拍完照之后 写入图片至本地
//        TSPathManager *pm = [TSPathManager sharePathManager];
//        NSString *imgDir = [pm getWorkOriginImgPathWithWorkDirName:[pm takePhotoWorkImgDirName]];
//        NSString *imgFilePath = [imgDir stringByAppendingPathComponent:[TSHelper getSaveWorkImgNameAtIndex:i-1]];
//
//        [UIImageJPEGRepresentation(img, 1) writeToFile:imgFilePath atomically:YES];
//    }
//    TSTakePhotoCompleteCtrl *compCtrl = [TSTakePhotoCompleteCtrl new];
//    compCtrl.imgs = self.imgArr;
//    [self pushViewCtrl:compCtrl];
//    return;
    
    self.backgroundView.isoSilder.hidden = YES;
    self.backgroundView.butplus.hidden = YES;
    self.backgroundView.minusBtn.hidden = YES;
    self.backgroundView.tapGestureRecognizer.enabled = NO;
    //已经再拍照，点击按钮 不进行任何操作
    if( btn.isSelected ) return;
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [HTProgressHUD showError:@"设备不支持拍照功能"];
        return;
    }

    btn.selected = !btn.isSelected;
    [self updateViewStatusWithIsTakingPhoto:YES];
    [self.imgArr removeAllObjects];
    
    [self sendTakePhotoDataToDevice];
    
    [self reloadPhotoListData];
}

-(void)handleGridBtn:(UIButton*)btn{
    
    if (self.shootingGridView.hidden==NO) {
        self.shootingGridView.hidden = YES;
        [self.shootingGridBtn setImage:[UIImage imageNamed:@"shooting_grid_normal"] forState:UIControlStateSelected];
    }
    else if (self.shootingGridView.hidden==YES){
        self.shootingGridView.hidden = NO;
        [self.shootingGridBtn setImage:[UIImage imageNamed:@"shooting_grid_selected"] forState:UIControlStateSelected];
    }
       btn.selected = !self.shootingGridView.hidden;

}

//伸缩镜头
- (void)handlePinch:(UIPinchGestureRecognizer*)gesture {

    [_captureManager pinchCameraView:gesture];

//    if (_scSlider) {
//        if (_scSlider.alpha != 1.f) {
//            [UIView animateWithDuration:0.3f animations:^{
//                _scSlider.alpha = 1.f;
//            }];
//        }
//        [_scSlider setValue:_captureManager.scaleNum shouldCallBack:NO];
//
//        if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
//            [self setSliderAlpha:YES];
//        } else {
//            [self setSliderAlpha:NO];
//        }
//    }
}

- (void)startTakePicture:(NSNotification*)noti{
    
    NSInteger photoIndex = -1;
    if( [noti.userInfo isKindOfClass:[NSDictionary class]] ){
        NSString *index = noti.userInfo[@"index"];
        if( [index isKindOfClass:[NSString class]] ){
            photoIndex = index.integerValue;
        }
    }
    
    //给设备发送拍照指令，设备会反馈两次指令，所以判断返回的索引为10的时间，是否为2，为2 代表转动结束
    if( photoIndex != 2 ) return;
    
    photoIndex = self.takedPhotoCountL.text.intValue;
    NSInteger totalCount = [self takeTotalPhotoCount];
    // 参数值大于等于当前要拍的总张数，则结束拍照
    if( photoIndex >= totalCount ){
        [self updateViewStatusWithIsTakingPhoto:NO];
        return;
    }
    
    [self updatePhotoIndex:photoIndex+1];

    NSLog(@"开始拍照");

    [self.captureManager takePicture:^(UIImage *stillImage) {
        
        //暂时不压缩
        CGSize desImgSize = [self getCompressImgSize];//
        UIImage *resizeImg = [stillImage imageByScalingToSize:desImgSize];
        
        NSData *imgData = UIImageJPEGRepresentation(resizeImg, [self getCompressImgScale]);
        
        //拍完照之后 写入图片至本地
        TSPathManager *pm = [TSPathManager sharePathManager];
        NSString *imgDir = [pm getWorkOriginImgPathWithWorkDirName:[pm takePhotoWorkImgDirName]];//[TSHelper takePhotoImgPath];
        NSString *imgFilePath = [imgDir stringByAppendingPathComponent:[TSHelper getSaveWorkImgNameAtIndex:photoIndex]];
        
        [imgData writeToFile:imgFilePath atomically:YES];
        
        UIImage *fImg = [UIImage imageWithData:imgData];
        if (fImg) {
            [self.imgArr addObject:fImg];
            [self.photoList addImg:fImg];
        }
        
        if( photoIndex == totalCount-1 ){
            //已经拍了足够的张数
            [self takePhotoComplete];
            return ;
        }

        NSLog(@"发送指令");
        [self sendTakePhotoDataToDevice];
    }];
}

#pragma mark - MyBLEDelegate
- (void)MyBleDelegateSetConnectBool:(BOOL)thisBool err:(NSError*)err{
    
//    if( err ){
//        if( thisBool == YES )
//            [HTProgressHUD showError:@"蓝牙连接失败"];
//        return;
//    }
    
    if( thisBool ){
        [HTProgressHUD showSuccess:NSLocalizedString(@"设备已连接", nil)];
    }else{
        [HTProgressHUD showError:NSLocalizedString(@"设备已断开", nil)];
    }
}

#pragma mark - Propertys

- (TSPhotoCountSelectView*)countView {
    if( !_countView ){
        _countView = [[TSPhotoCountSelectView alloc] init];
        CGFloat ih = 65;
        _countView.frame = CGRectMake(0, 0, SCREEN_WIDTH, ih);
        _countView.titles = @[@"18",@"36"];//,@"72"];
        _countView.selectedIndex = 0;
        [self.bottomView addSubview:_countView];
    }
    return _countView;
}

- (UIView *)bottomView {
    if( !_bottomView ){
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        CGFloat ih = 150+BOTTOM_NOT_SAVE_HEIGHT;
        _bottomView.frame = CGRectMake(0, SCREEN_HEIGHT-ih, SCREEN_WIDTH, ih);
        //[self.view addSubview:_bottomView];
    }
    return _bottomView;
}

- (UIButton *)closeBtn {
    if( !_closeBtn ){
        _closeBtn = [[UIButton alloc] init];
        [_closeBtn setImage:[UIImage imageNamed:@"pc_close_white"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(handleCloseBtn) forControlEvents:UIControlEventTouchUpInside];
        
        [self.bottomView addSubview:_closeBtn];
    }
    return _closeBtn;
}

- (UIButton *)takeBtn {
    if( !_takeBtn ){
        _takeBtn = [[UIButton alloc] init];
        [_takeBtn setImage:[UIImage imageNamed:@"pc_takephoto_n"] forState:UIControlStateNormal];
        [_takeBtn setImage:[UIImage imageNamed:@"pc_takephoto_s"] forState:UIControlStateSelected];
        CGFloat wh = 60;
        _takeBtn.frame = CGRectMake((SCREEN_WIDTH-wh)/2, self.countView.bottom+5, wh, wh);
        [_takeBtn addTarget:self action:@selector(handleTakeBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.bottomView addSubview:_takeBtn];
    }
    return _takeBtn;
}

- (UIButton*)shootingGridBtn{
    if (!_shootingGridBtn) {
        _shootingGridBtn = [[UIButton alloc] init];
        [_shootingGridBtn setImage:[UIImage imageNamed:@"shooting_grid_normal"] forState:UIControlStateNormal];
        [_shootingGridBtn setImage:[UIImage imageNamed:@"shooting_grid_selected"] forState:UIControlStateSelected];
        [_shootingGridBtn addTarget:self action:@selector(handleGridBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.bottomView addSubview:_shootingGridBtn];
    }
    return _shootingGridBtn;
}

- (UILabel *)takedPhotoCountL {
    if( !_takedPhotoCountL ){
        _takedPhotoCountL = [[UILabel alloc] init];
        _takedPhotoCountL.textColor = [UIColor whiteColor];
        _takedPhotoCountL.font = [UIFont systemFontOfSize:15];
        _takedPhotoCountL.textAlignment = NSTextAlignmentCenter;
        _takedPhotoCountL.hidden = YES;
        [self.bottomView addSubview:_takedPhotoCountL];
    }
    return _takedPhotoCountL;
}

- (TSTakedPhotoListView *)photoList {
    if( !_photoList ){
        CGRect fr = CGRectMake(5, 10, SCREEN_WIDTH-5, 50);
        CGSize size = CGSizeMake(35, 50);
        //CGSizeMake(fr.size.height*(SCREEN_WIDTH/SCREEN_HEIGHT), fr.size.height);
        _photoList = [[TSTakedPhotoListView alloc] initWithItemSize:size];
        _photoList.frame = fr;
        _photoList.backgroundColor = [UIColor clearColor];
        [self.bottomView addSubview:_photoList];
    }
    return _photoList;
}

- (SCCaptureSessionManager *)captureManager {
    if( !_captureManager ){
        //session manager
        SCCaptureSessionManager *manager = [[SCCaptureSessionManager alloc] init];
        _captureManager = manager;
        //AvcaptureManager
        CGRect previewRect = self.view.bounds;
        [manager configureWithParentLayer:self.view previewRect:previewRect isVideo:NO];
        
        self.previewRect = previewRect;
    }
    return _captureManager;
}

- (MyBleClass *)bluetoothManager {
    return [MyPublic shareMyBleClass];
}

- (NSMutableArray *)imgArr {
    if( !_imgArr ){
        _imgArr = [[NSMutableArray alloc] init];
    }
    return _imgArr;
}

- (UIImageView *)shootingGridView{
    if (!_shootingGridView) {
        _shootingGridView = [[UIImageView alloc] init];
        _shootingGridView.image = [UIImage imageNamed:@"shooting_grids"];
        _shootingGridView.frame = CGRectMake(0, 150, SCREEN_WIDTH, (SCREEN_HEIGHT-300));
        _shootingGridView.contentMode = UIViewContentModeScaleToFill;
        [self.view addSubview:_shootingGridView];
        
        _shootingGridView.hidden = NO;
    }
    return _shootingGridView;
}


@end
