//
//  TSShootVideoCtrl.m
//  ThreeShow
//
//  Created by cgw on 2019/6/28.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSShootVideoCtrl.h"
#import "UIViewController+Ext.h"
#import "UIView+LayoutMethods.h"
#import "TSPhotoCountSelectView.h"
#import "TSTakedPhotoListView.h"
#import "SCCaptureSessionManager.h"
#import "SCSlider.h"
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
#import "TSShootVideoCompleteCtrl.h"
#import "MQGradientProgressView.h"

#import "WCLRecordEngine.h"

@interface TSShootVideoCtrl ()<MyBleDelegate,SCCaptureSessionManager,JKRCameraBackgroundViewDelegate,JKRCameraBackgroundViewDatasource,WCLRecordEngineDelegate>
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) TSPhotoCountSelectView *videoTimeView;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *takeBtn;
@property (nonatomic, strong) UIButton *shootingGridBtn;//网格按钮
@property (nonatomic, strong) UILabel  *takedPhotoCountL;//已拍照片数量
@property (nonatomic, strong) UIImageView *shootingGridView;//网格视图

//相机部分
@property (nonatomic, strong) SCCaptureSessionManager *captureManager;
@property (nonatomic, strong) SCSlider       *scSlider;
@property (nonatomic, assign) CGRect         previewRect;

//设备
@property (nonatomic, strong) MyBleClass *bluetoothManager;

@property (nonatomic, strong) JKRCameraBackgroundView *backgroundView; // 控制界面

//记录视频拍摄时间
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger duration; //视频时间单位s
@property (nonatomic, strong) HTProgressHUD *hud;
@property (nonatomic, strong) MQGradientProgressView *recordProgress;

@property (nonatomic, strong) WCLRecordEngine *recordEngine;

@property (nonatomic, assign) BOOL isEndedRecording; //是否已点击结束录制
@end

@implementation TSShootVideoCtrl

-(void)dealloc{
    //移除观察者 在dealloc中
    [[self.recordEngine.inputDevice device] removeObserver:self forKeyPath:@"ISO"];
    [self.captureManager.session stopRunning];
    [self.view removeFromSuperview];
    self.captureManager.previewLayer = nil;
    _recordEngine = nil;
    NSLog(@"===走这里？？？");
}

#pragma mark -  ViewLife

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _duration = -1;

    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self addLeftBarItemWithTitle:nil action:nil];
    //拍照界面常亮
    [UIApplication sharedApplication].idleTimerDisabled = YES;

    //添加镜头拉伸手势
    [self addPinchGesture];
    
    //聚焦手势
    //[self addGestureRecognizer];
    
    [self resetDatas];
//    [self sendRecoverCommandToDevice];
    [self.recordEngine startUp];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self addRecieveDeviceNotiObserver];
    
    if( self.recordEngine.sessionRunning ==NO )
        [self.recordEngine startUp];
//    if (_recordEngine == nil) {
//
    //    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self removeRecieveDeviceNotiObserver];
    
//    if (self.captureManager.session) {
//        [self.captureManager.session stopRunning];
//    }
    
    [self.recordEngine shutdown];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
    
}

#pragma mark - Gesterger

- (void)resetDatas{
    
    //展示相机界面
//    [self.captureManager.session startRunning];
    [MyPublic shareMyBleClass].delegate = self;
    self.videoTimeView.selectedIndex = 0;
    [self.videoTimeView reloadDatas];
    
    self.takeBtn.selected = NO;
    [self updateViewStatusWithIsTakingPhoto:NO];

    _backgroundView = [[JKRCameraBackgroundView alloc] initWithFrame:self.view.bounds];
    _backgroundView.delegate = self;
    _backgroundView.datasource = self;
    
    //隐藏滑动增加或减少曝光视图
    _backgroundView.isoSilder.hidden = NO;
    _backgroundView.butplus.hidden = NO;
    _backgroundView.minusBtn.hidden = NO;
    
    [self.view addSubview:_backgroundView];
    [_backgroundView addSubview:self.bottomView];
    
//    [self.captureManager focusInPoint:self.backgroundView.center];
    
    //设置聚焦在中心点
    [self cameraBackgroundDidTap:self.backgroundView.center];
    
    // 这里就是监听相机自动对焦的
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:self.recordEngine.inputDevice];
    
    [[self.recordEngine.inputDevice device] addObserver:self forKeyPath:@"ISO" options:NSKeyValueObservingOptionNew context:NULL];
    [self addPinchGesture];
    
    self.takedPhotoCountL.hidden = YES;
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
    //先进行判断是否支持控制对焦
    if(self.recordEngine.inputDevice.device.isFocusPointOfInterestSupported &&[self.recordEngine.inputDevice.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error = nil;
        [self.recordEngine.inputDevice.device lockForConfiguration:&error];
        [self.recordEngine.inputDevice.device setFocusMode:AVCaptureFocusModeAutoFocus];
        [self.captureManager focusInPoint:self.view.center];
        
        //操作完成后，记得进行unlock。
        
        [self.recordEngine.inputDevice.device unlockForConfiguration];
    }
    
}
#pragma mark -曝光
//static const NSString *cameraAdjustingExposureContext;
static void *ExposureTargetOffsetContext = &ExposureTargetOffsetContext;
- (void)exposeAtPoint:(CGPoint)point{
    AVCaptureDevice *captureDevice = [self.recordEngine.inputDevice device];
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
- (void)AAAAAcameraBackgroundDidChangeISO:(CGFloat)iso isPlusOrMinusBtn:(BOOL)isPlusOrMinusBtn{
    [[self.recordEngine.inputDevice device] removeObserver:self forKeyPath:@"ISO"];
    AVCaptureDevice *captureDevice = [self.recordEngine.inputDevice device];
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
    //    [[self.recordEngine.inputDevice device] addObserver:self forKeyPath:@"ISO" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)cameraBackgroundDidChangeISO:(CGFloat)iso isPlusOrMinusBtn:(BOOL)isPlusOrMinusBtn{
    
    NSLog(@"1223");
//    return;
    if( isPlusOrMinusBtn )
        [[self.recordEngine.inputDevice device] removeObserver:self forKeyPath:@"ISO"];
    
    AVCaptureDevice *captureDevice = [self.recordEngine.inputDevice device];
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
        [[self.recordEngine.inputDevice device] addObserver:self forKeyPath:@"ISO" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)cameraBackgroundView:(JKRCameraBackgroundView *)cv touchDownSlider:(UISlider *)slider{
    [[self.recordEngine.inputDevice device] removeObserver:self forKeyPath:@"ISO"];
}

- (void)cameraBackgroundView:(JKRCameraBackgroundView *)cv touchUpSlider:(UISlider *)slider{
    [[self.recordEngine.inputDevice device] addObserver:self forKeyPath:@"ISO" options:NSKeyValueObservingOptionNew context:NULL];
}

#pragma mark - 点击屏幕对焦
- (void)cameraBackgroundDidTap:(CGPoint)point {
    
    NSLog(@"===点击屏幕对焦===%f==%f",point.x,point.y);
    AVCaptureDevice *captureDevice = [self.recordEngine.inputDevice device];
    NSError *error;
    if ([captureDevice lockForConfiguration:&error]) {
        CGPoint location = point;
        CGPoint pointOfInerest = CGPointMake(0.5, 0.5);
        CGSize frameSize = self.captureManager.previewLayer.frame.size;
        if ([captureDevice position] == AVCaptureDevicePositionFront) location.x = frameSize.width - location.x;
        pointOfInerest = CGPointMake(location.y / frameSize.height, 1.f - (location.x / frameSize.width));
        [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposureMode:AVCaptureExposureModeContinuousAutoExposure atPoint:pointOfInerest];
        
        //[[self.recordEngine.inputDevice device] addObserver:self forKeyPath:@"ISO" options:NSKeyValueObservingOptionNew context:NULL];
    }else{
        // Handle the error appropriately.
    }
}

-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    AVCaptureDevice *captureDevice = [self.recordEngine.inputDevice device];
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
        CGFloat minISO = self.recordEngine.inputDevice.device.activeFormat.minISO;
        CGFloat maxISO = self.recordEngine.inputDevice.device.activeFormat.maxISO;
        CGFloat currentISO = self.recordEngine.inputDevice.device.ISO;
        CGFloat scale = (currentISO - minISO) / (maxISO - minISO);
        //        _backgroundView.isoSilder.value = valu;
        
        UISlider *islider = _backgroundView.isoSilder;
        CGFloat value = (islider.maximumValue-islider.minimumValue)*scale + islider.minimumValue;
        islider.value = value;
        
//        NSLog(@"===ISO===%f",_backgroundView.isoSilder.value);
        //adjustingExposure
        BOOL res = self.recordEngine.inputDevice.device.adjustingExposure;
//        NSLog(@"===是否改变曝光值：%d",res);
    }
}


#pragma mark - Private

//- (void)reloadPhotoListData{
//    self.photoList.itemCount = [self takeTotalPhotoCount];
//    [self.photoList reloadData];
//}

- (void)addRecieveDeviceNotiObserver{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(recieveDeviceMsg:) name:MyBleDidRecieveDeviceMsgNotification object:nil];
}

- (void)removeRecieveDeviceNotiObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MyBleDidRecieveDeviceMsgNotification object:nil];
    
}

-(void)updatePhotoIndex:(NSUInteger)index{
    NSUInteger count = index;
    self.takedPhotoCountL.hidden = (index<=0);
    self.takedPhotoCountL.text = [NSString stringWithFormat:@"%lus",(unsigned long)count];
}


- (NSInteger)takeTotalPhotoCount{
    
    //    return 1;
    
    if( self.videoTimeView.titles.count > self.videoTimeView.selectedIndex ){
        NSString *countStr = _videoTimeView.titles[_videoTimeView.selectedIndex];
        return  countStr.integerValue;
    }
    
    return 18;
}

- (void)updateViewStatusWithIsTakingPhoto:(BOOL)isTaking{
    self.takeBtn.selected = isTaking;
    self.videoTimeView.hidden = isTaking;
    self.videoTimeView.userInteractionEnabled = !isTaking;
    self.takedPhotoCountL.text = @"0s";
    self.takedPhotoCountL.hidden = YES;
    
    self.backgroundView.isoSilder.hidden = isTaking;
    self.backgroundView.butplus.hidden = isTaking;
    self.backgroundView.minusBtn.hidden = isTaking;
    self.backgroundView.tapGestureRecognizer.enabled = !isTaking;
}

#pragma mark __图片处理

//-(BOOL)deviceMemoryLessThan1G{
//    if( [KCommon getDeviceMemorySize]/1024.0 <= 1 )
//        return YES;
//    return NO;
//}

//-(CGSize)getCompressImgSize{
//    CGFloat scale = 3;
//    if( [self deviceMemoryLessThan1G] ){
//        scale = 2.0;
//    }
//    //    if( [KCommon getDeviceCategory] == DeviceCategoryIPhone6Plus ){
//    //        scale = 1;
//    //    }
//    return CGSizeMake(360*scale, 640*scale);
//}

//-(CGFloat)getCompressImgScale{
//
//    if( self.videoTimeView.selectedIndex >= 1 ){
//        //36 张或 72张
//        return 0.4;
//    }
//    return 0.5;
//
//
//    CGFloat scale = 0.5;
//
//    if( [UIView screenType] == UIScreenTypeIPhone5 ){
//        scale = 0.3;
//    }
//
//    if( [UIView screenType] == UIScreenTypeIPhone5s ){
//        scale = 0.8;
//    }
//    else if( [UIView screenType] == UIScreenTypeIPhone6sPlus ){
//        scale = 0.8;
//    }
//
//    return scale;
//}

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

// 开始拍摄指令
- (void)sendTakeVideoDataToDevice{

    Byte time = 0x48;//self.videoTimeView.selectedIndex==0?(Byte)0x48:0x48;
    Byte refresh = self.videoTimeView.selectedIndex==0?(Byte)0x11:0x00;
    [self sendCommandToDeviceWithFresh:refresh speed:time];
}

//停止拍摄
- (void)sendStopTakeToDevice{
    Byte refresh = self.videoTimeView.selectedIndex==0?(Byte)0x11:0x00;
    [self sendCommandToDeviceWithFresh:refresh speed:0x00];
}

- (void)sendCommandToDeviceWithFresh:(Byte)refresh speed:(Byte)speed{
    
    if (self.bluetoothManager.connectedShield.state  != CBPeripheralStateConnected ) {
        [HTProgressHUD showError:NSLocalizedString(@"TakePhotoPleaseConnectDevice", nil)];//@"设备已断开，请连接设备"];
        
        [self updateViewStatusWithIsTakingPhoto:NO];
        return;
    }
    //0 20s , 1 30s

    Byte time = speed;//0x48;//self.videoTimeView.selectedIndex==0?(Byte)0x48:0x48;
//    Byte refresh = refresh;//self.videoTimeView.selectedIndex==0?(Byte)0x11:0x00;
    Byte mybytes[] = {0x11 ,0x01 ,0x00 ,0x00 ,0x00 ,0x07 ,time,0x00, refresh ,0x00 ,0x00 ,0x00 ,0x00 ,0x00 ,0x00 ,0x0d ,0x0a};
    [self.bluetoothManager MybleSendBytes:mybytes :sizeof(mybytes)];
}


#pragma mark - 拍摄视频部分

//伸缩镜头的手势
- (void)addPinchGesture {
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinch];
}
///// 拍摄完视频，给设备发送复位指令
//- (void)sendRecoverCommandToDevice{
//    //0 18张， 1 36张，2 72张
////    Byte takeCount = self.countView.selectedIndex;
//    Byte mybytes[] = {0x11 ,0x01 ,0x55 ,0x01 ,0x02 ,0x04 ,0x00 ,0x00 ,0x11 ,(Byte) 0x88 ,(Byte) 0x88 ,(Byte) 0x88 ,0x00 ,0x00 ,0x00 ,0x0d ,0x0a};
//    [self.bluetoothManager MybleSendBytes:mybytes :sizeof(mybytes)];
//}

- (void)endShootVideo{
    
    if( _isEndedRecording ) return;
    
    _isEndedRecording = YES;
    _hud = [HTProgressHUD showMessage:@"处理中.." toView:self.view];
    [self.recordEngine stopCaptureHandler:^(UIImage *movieImage) {
        [self invalidateTimer];
        
        [self dispatchAsyncMainQueueWithBlock:^{
            [self.hud hide];
        
            NSURL *videoUrl = nil;
            if( self.recordEngine.videoPath ){
                videoUrl = [NSURL fileURLWithPath:self.recordEngine.videoPath];
            }
            if( videoUrl == nil || movieImage==nil ){
                [HTProgressHUD showError:@"视频制作失败"];
                NSLog(@"视频转码失败，请重试");
                return ;
            }
            
            NSLog(@"拍摄完成:%@",videoUrl);
            TSShootVideoCompleteCtrl *cc = [TSShootVideoCompleteCtrl new];
            cc.videoUrl = videoUrl;
            [self pushViewCtrl:cc];
        }];
    }];
//    return;
//
//    if( self.captureManager.videoOutput.recording ){
//        NSLog(@"点击结束录制。。。");
//        self.takeBtn.selected = NO;
//        _hud = [HTProgressHUD showMessage:@"处理中.." toView:self.view];
//        [self.captureManager.videoOutput stopRecording];
//        [self.captureManager.session stopRunning];
//
//        [self invalidateTimer];
//    }
}

- (void)beginShootVideo{
    [self startTimer];
    NSLog(@"点击开始录制。。。");
    
    
    _isEndedRecording = NO;

    [self.recordEngine startCapture];
//    return;
//
//    [self.captureManager shootVideo:^(NSURL *videoUrl) {
//        [self dispatchAsyncMainQueueWithBlock:^{
//            [self.hud hide];
//            if( videoUrl == nil ){
//                [HTProgressHUD showError:@"视频制作失败"];
//                NSLog(@"视频转码失败，请重试");
//                return ;
//            }
//
//            NSLog(@"拍摄完成:%@",videoUrl);
//            TSShootVideoCompleteCtrl *cc = [TSShootVideoCompleteCtrl new];
//            cc.videoUrl = videoUrl;
//            [self pushViewCtrl:cc];
//        }];
//    }];
    
    self.takeBtn.selected = YES;
}

#pragma mark __视频计时
- (NSInteger)maxVideoLength{
    NSInteger maxSeconds = self.videoTimeView.selectedIndex==0?20:30;
    return maxSeconds;
}

- (void)startTimer{
    [self invalidateTimer];
    _duration = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(shootVideoTimerSel) userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)invalidateTimer{
    [_timer invalidate];
    _timer = nil;
}

- (void)shootVideoTimerSel{
    NSInteger maxSeconds = [self maxVideoLength];
    if( _duration >= maxSeconds ){
        //到达最大时长，则停止拍摄
        [self invalidateTimer];
        [self endShootVideo];
        return;
    }
    _duration ++;
    
    self.recordProgress.progress = _duration*1.0/maxSeconds;
    [self updatePhotoIndex:_duration];
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
    

    [[self.recordEngine.inputDevice device] removeObserver:self forKeyPath:@"ISO"];
    //[self reset];
    _isEndedRecording = YES;
    [self sendStopTakeToDevice];
}

- (void)handleTakeBtn:(UIButton*)btn{
        
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [HTProgressHUD showError:@"设备不支持拍照功能"];
        return;
    }
    
    btn.selected = !btn.isSelected;
    [self updateViewStatusWithIsTakingPhoto:btn.isSelected];
    
    if( btn.selected ){
        //发送拍摄指令给设备，告诉设备转圈
        [self sendTakeVideoDataToDevice];
        
        //给设备发指令后，直接开始拍摄，不必等待设备的反馈
        [self beginShootVideo];
    }else{
        //停止拍摄
        [self endShootVideo];
        _isEndedRecording = YES;
        
        //发送停止拍摄指令，让设备停止转动
        [self sendStopTakeToDevice];
    }
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

    [_recordEngine pinchCameraView:gesture];
//    [_captureManager pinchCameraView:gesture];

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


/**
 
 //以下注释作废，设备反馈的内容不准确，所以只开始拍摄时，给设备发指令让其转圈，倒计时控制停止录制。
 
 //作废注释
 当像设备发送拍摄视频指令时，设备会反馈开始拍摄和结束拍摄的指令。
 
 @param noti 通知内容
 */
- (void)recieveDeviceMsg:(NSNotification*)noti{
    
    //本函数暂无意义
    return;
    
    NSInteger photoIndex = -1;
    if( [noti.userInfo isKindOfClass:[NSDictionary class]] ){
        NSString *index = noti.userInfo[@"index"];
        if( [index isKindOfClass:[NSString class]] ){
            photoIndex = index.integerValue;
        }
        
        //过滤掉发送停止反馈后，收到的两次结束指令
        NSString *isEndVideo = noti.userInfo[@"isEndRecordVideo"];
        if( isEndVideo && isEndVideo.intValue == 0 && photoIndex ==1 ){
            //是结束录制
            return;
        }
    }
    
    if( photoIndex == 1 ){
        //开始拍摄
        [self beginShootVideo];
    }else if( photoIndex == 2 ){
        //结束拍摄
        [self endShootVideo];
    }
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

- (TSPhotoCountSelectView*)videoTimeView {
    if( !_videoTimeView ){
        _videoTimeView = [[TSPhotoCountSelectView alloc] init];
        CGFloat ih = 65;
        _videoTimeView.frame = CGRectMake(0, 0, SCREEN_WIDTH, ih);
        _videoTimeView.titles = @[@"20s",@"30s"];//,@"72"];
        _videoTimeView.titleL.text = NSLocalizedString(@"拍摄时间", nil);
        _videoTimeView.selectedIndex = 0;
        [self.bottomView addSubview:_videoTimeView];
    }
    return _videoTimeView;
}

- (UIView *)bottomView {
    if( !_bottomView ){
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        CGFloat ih = 150+BOTTOM_NOT_SAVE_HEIGHT;
        _bottomView.frame = CGRectMake(0, SCREEN_HEIGHT-ih, SCREEN_WIDTH, ih);
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
        [_takeBtn setImage:[UIImage imageNamed:@"shooting_video_n"] forState:UIControlStateNormal];
        [_takeBtn setImage:[UIImage imageNamed:@"shooting_video_s"] forState:UIControlStateSelected];
        CGFloat wh = 60;
        _takeBtn.frame = CGRectMake((SCREEN_WIDTH-wh)/2, self.videoTimeView.bottom+5, wh, wh);
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

//- (SCCaptureSessionManager *)captureManager {
//
//    return nil;
//
//    if( !_captureManager ){
//        //session manager
//        SCCaptureSessionManager *manager = [[SCCaptureSessionManager alloc] init];
//        _captureManager = manager;
//        //AvcaptureManager
//        CGRect previewRect = self.view.bounds;
//        [manager configureWithParentLayer:self.view previewRect:previewRect isVideo:YES];
//
//        self.previewRect = previewRect;
//    }
//    return _captureManager;
//}

- (MyBleClass *)bluetoothManager {
    return [MyPublic shareMyBleClass];
}

//- (NSMutableArray *)imgArr {
//    if( !_imgArr ){
//        _imgArr = [[NSMutableArray alloc] init];
//    }
//    return _imgArr;
//}

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

- (MQGradientProgressView *)recordProgress {
    if( !_recordProgress ){
        _recordProgress = [[MQGradientProgressView alloc] init];
        _recordProgress.frame = CGRectMake(0, 20, SCREEN_WIDTH, 4);
        _recordProgress.progress = 0;
        _recordProgress.backgroundColor = [UIColor colorWithRgb221];
        
        _recordProgress.colorArr = @[(id)(MQRGBColor(252,199,17).CGColor),(id)(MQRGBColor(252,199,17).CGColor)];
        [self.view addSubview:_recordProgress];
    }
    return _recordProgress;
}

- (WCLRecordEngine *)recordEngine {
    if (_recordEngine == nil) {
        _recordEngine = [[WCLRecordEngine alloc] init];
        _recordEngine.delegate = self;
        
        [self.recordEngine previewLayer].frame = self.view.bounds;
        [self.view.layer insertSublayer:[self.recordEngine previewLayer] atIndex:0];
        
        _recordEngine.preview = self.view;
        _recordEngine.scaleNum = 1;
        _recordEngine.preScaleNum = 1;
    }
    return _recordEngine;
}

#pragma mark - WCLRecordEngineDelegate
- (void)recordProgress:(CGFloat)progress {
    NSLog(@"progress=%f",progress);
//    if (progress >= 1) {
//        [self recordAction:self.recordBt];
//    }
//    self.progressView.progress = progress;
}

@end


