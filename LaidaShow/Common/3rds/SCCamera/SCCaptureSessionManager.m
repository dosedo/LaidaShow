//
//  SCCaptureSessionManager.m
//  SCCaptureCameraDemo
//
//  Created by Aevitx on 14-1-16.
//  Copyright (c) 2014年 Aevitx. All rights reserved.
//

#import "SCCaptureSessionManager.h"
#import <ImageIO/ImageIO.h>
//#import "SCCommon.h"
//#import "MyPublic.h"
//#import "UIImage+Resize.h"

@interface SCCaptureSessionManager ()<AVCaptureFileOutputRecordingDelegate>

{
}

//@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation SCCaptureSessionManager{
    DidCaptureVideoBlock _videoBlock;
}


#pragma mark -
#pragma mark configure
- (id)init {
    self = [super init];
    if (self != nil) {
        _scaleNum = 1.f;
        _preScaleNum = 1.f;
    }
    return self;
}

- (void)dealloc {
    [_session stopRunning];
    self.previewLayer = nil;
    self.session = nil;
    self.stillImageOutput = nil;
//    self.stillImage = nil;
}

- (void)configureWithParentLayer:(UIView*)parent previewRect:(CGRect)preivewRect{
    [self configureWithParentLayer:parent previewRect:preivewRect isVideo:NO];
}

- (void)configureWithParentLayer:(UIView*)parent previewRect:(CGRect)preivewRect isVideo:(BOOL)isVideo{
    
    self.preview = parent;
    
    //1、队列
    [self createQueue];
    
    //2、session
    [self addSession];
    
    //3、previewLayer
    [self addVideoPreviewLayerWithRect:preivewRect];
    [parent.layer addSublayer:_previewLayer];
    
    //4、input
    [self addVideoInputFrontCamera:NO];
    
    //5、output
    if( isVideo ){
        [self addVideoOutput];
        [self addAudioInput];
    }else{
        [self addStillImageOutput];
    }
}

/**
 *  创建一个队列，防止阻塞主线程
 */
- (void)createQueue {
	dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    self.sessionQueue = sessionQueue;
}

/**
 *  session
 */
- (void)addSession {
    AVCaptureSession *tmpSession = [[AVCaptureSession alloc] init];
    self.session = tmpSession;
    //设置质量，该行代码会改变视频的尺寸
//   _session.sessionPreset = AVCaptureSessionPresetPhoto;
}

/**
 *  相机的实时预览页面
 *
 *  @param previewRect 预览页面的frame
 */
- (void)addVideoPreviewLayerWithRect:(CGRect)previewRect {
    
    AVCaptureVideoPreviewLayer *preview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preview.frame = previewRect;
    self.previewLayer = preview;
}

/**
 *  添加输入设备
 *
 *  @param front 前或后摄像头
 */
- (void)addVideoInputFrontCamera:(BOOL)front {
    
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    for (AVCaptureDevice *device in devices) {
        
        SCDLog(@"Device name: %@", [device localizedName]);
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
                SCDLog(@"Device position : back");
                backCamera = device;
                
            }  else {
                SCDLog(@"Device position : front");
                frontCamera = device;
            }
        }
    }
    
    NSError *error = nil;
    
    if (front) {
        AVCaptureDeviceInput *frontFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        if (!error) {
            if ([_session canAddInput:frontFacingCameraDeviceInput]) {
                [_session addInput:frontFacingCameraDeviceInput];
                self.inputDevice = frontFacingCameraDeviceInput;
                
            } else {
                SCDLog(@"Couldn't add front facing video input");
            }
        }
    } else {
        AVCaptureDeviceInput *backFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
        if (!error) {
            if ([_session canAddInput:backFacingCameraDeviceInput]) {
                [_session addInput:backFacingCameraDeviceInput];
                self.inputDevice = backFacingCameraDeviceInput;
            } else {
                SCDLog(@"Couldn't add back facing video input");
            }
        }
    }
}

/**
 *  添加输出设备
 */
- (void)addStillImageOutput {
    
    AVCaptureStillImageOutput *tmpOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];//输出jpeg
    tmpOutput.outputSettings = outputSettings;
    
//    AVCaptureConnection *videoConnection = [self findVideoConnection];
    
    [_session addOutput:tmpOutput];
    
    self.stillImageOutput = tmpOutput;
}

- (void)addVideoOutput{
    AVCaptureMovieFileOutput *movieOutput = [[AVCaptureMovieFileOutput alloc] init];

    if( movieOutput ){
        if( [_session canAddOutput:movieOutput] ){
            [_session addOutput:movieOutput];
        }
    }
    _videoOutput = movieOutput;
}

- (void)addAudioInput{
    AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:nil];
    
    if ([_session canAddInput:audioDeviceInput]) {
        [_session addInput:audioDeviceInput];
    }
}

/**
 *  拍完照片后预览图片
 */
//- (void)addPreviewImageView {
//    CGFloat headHeight = _previewLayer.bounds.size.height - SC_APP_SIZE.width;
//    CGRect imageFrame = _previewLayer.bounds;
//    imageFrame.origin.y = headHeight;
//    
//    UIImageView *imgView = [[UIImageView alloc] initWithFrame:imageFrame];
//    imgView.contentMode = UIViewContentModeScaleAspectFill;
//    [_preview addSubview:imgView];
//    
//    self.imageView = imgView;
//}

#pragma mark - actions
#pragma mark --- ---- 拍照按钮事件
- (void)takePicture:(DidCapturePhotoBlock)block {
    AVCaptureConnection *videoConnection = [self findVideoConnection];
    
//    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
//    AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
//    [videoConnection setVideoOrientation:avcaptureOrientation];
    
    [videoConnection setVideoScaleAndCropFactor:_scaleNum];
    
	SCDLog(@"about to request a capture from: %@", _stillImageOutput);
    
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        CFDictionaryRef exifAttachments = CMGetAttachment(imageDataSampleBuffer, kCGImagePropertyExifDictionary, NULL);
        if (exifAttachments) {
            SCDLog(@"attachements: %@", exifAttachments);
        } else {
            SCDLog(@"no attachments");
        }
    #pragma mark -- 测试用
        NSData *imageData;
        if (imageDataSampleBuffer) {//如果有内容,再添加
            imageData  = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        }
    
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        UIImage *croppedImage = image;
        
        SCDLog(@"originImage:%@", [NSValue valueWithCGSize:image.size]);

        //block、delegate、notification 3选1，传值
        if (block) {
            block(croppedImage);
        } //else if ([_delegate respondsToSelector:@selector(didCapturePhoto:)]) {
            //[_delegate didCapturePhoto:croppedImage];
        //}
     else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kCapturedPhotoSuccessfully object:croppedImage];
        }
    }];
}

- (void)shootVideo:(DidCaptureVideoBlock)block{
    _videoBlock = block;
    
    AVCaptureConnection *videoConnection = //[self findVideoConnection];
    [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
    [videoConnection setVideoScaleAndCropFactor:_scaleNum];
    
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tempVideo.mov"];
    NSURL *url = [NSURL fileURLWithPath:path];
    [_videoOutput startRecordingToOutputFileURL:url recordingDelegate:self];
}

#pragma mark - AVCaptureOutputFileDelegate
//- (void)captureOutput:(AVCaptureFileOutput *)output willFinishRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error {
//    //拍摄完成
//    if( _videoBlock ){
//        _videoBlock(fileURL);
//    }
//}

- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections{
    NSLog(@"start recording video");
}

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error{
    
    NSLog(@"end recrding video=========%s=======",__func__);
    //拍摄完成
//    [self mergeAndExportVideoAtFileURLs:@[outputFileURL]];
    [self convertVideoQuailtyWithInputURL:outputFileURL completeHandler:^(AVAssetExportSession *a) {
        
    }];
    
//    if( _videoBlock ){
//        _videoBlock(outputFileURL);
//    }
}

#pragma mark -其他

- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
	AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
	if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
		result = AVCaptureVideoOrientationLandscapeRight;
	else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
		result = AVCaptureVideoOrientationLandscapeLeft;
	return result;
}

/**
 *  切换前后摄像头
 *
 *  @param isFrontCamera YES:前摄像头  NO:后摄像头
 */
- (void)switchCamera:(BOOL)isFrontCamera {
    if (!_inputDevice) {
        return;
    }
    [_session beginConfiguration];
    
    [_session removeInput:_inputDevice];
    
    [self addVideoInputFrontCamera:isFrontCamera];
    
    [_session commitConfiguration];
}

/**
 *  拉近拉远镜头
 *
 *  @param scale 拉伸倍数
 */
- (void)pinchCameraViewWithScalNum:(CGFloat)scale {
    _scaleNum = scale;
    if (_scaleNum < MIN_PINCH_SCALE_NUM) {
        _scaleNum = MIN_PINCH_SCALE_NUM;
    } else if (_scaleNum > MAX_PINCH_SCALE_NUM) {
        _scaleNum = MAX_PINCH_SCALE_NUM;
    }
    [self doPinch];
    _preScaleNum = scale;
}

- (void)pinchCameraView:(UIPinchGestureRecognizer *)gesture {
    
    BOOL allTouchesAreOnThePreviewLayer = YES;
	NSUInteger numTouches = [gesture numberOfTouches], i;
	for ( i = 0; i < numTouches; ++i ) {
		CGPoint location = [gesture locationOfTouch:i inView:_preview];
		CGPoint convertedLocation = [_previewLayer convertPoint:location fromLayer:_previewLayer.superlayer];
		if ( ! [_previewLayer containsPoint:convertedLocation] ) {
			allTouchesAreOnThePreviewLayer = NO;
			break;
		}
	}
	
	if ( allTouchesAreOnThePreviewLayer ) {
		_scaleNum = _preScaleNum * gesture.scale;
        
        if (_scaleNum < MIN_PINCH_SCALE_NUM) {
            _scaleNum = MIN_PINCH_SCALE_NUM;
        } else if (_scaleNum > MAX_PINCH_SCALE_NUM) {
            _scaleNum = MAX_PINCH_SCALE_NUM;
        }
        
        [self doPinch];
	}
    
    if ([gesture state] == UIGestureRecognizerStateEnded ||
        [gesture state] == UIGestureRecognizerStateCancelled ||
        [gesture state] == UIGestureRecognizerStateFailed) {
        _preScaleNum = _scaleNum;
        SCDLog(@"final scale: %f", _scaleNum);
    }
}

- (void)doPinch {
//    AVCaptureStillImageOutput* output = (AVCaptureStillImageOutput*)[_session.outputs objectAtIndex:0];
//    AVCaptureConnection *videoConnection = [output connectionWithMediaType:AVMediaTypeVideo];
    
    AVCaptureConnection *videoConnection = [self findVideoConnection];
    
    CGFloat maxScale = videoConnection.videoMaxScaleAndCropFactor;//videoScaleAndCropFactor这个属性取值范围是1.0-videoMaxScaleAndCropFactor。iOS5+才可以用
    NSLog(@"maxScale=%f",maxScale);
    
    if (_scaleNum > maxScale) {
        _scaleNum = maxScale;
    }
    
    videoConnection.videoScaleAndCropFactor = _scaleNum;
    [CATransaction begin];
    [CATransaction setAnimationDuration:.025];
    [_previewLayer setAffineTransform:CGAffineTransformMakeScale(_scaleNum, _scaleNum)];
    [CATransaction commit];
}

/**
 *  切换闪光灯模式
 *  （切换顺序：最开始是auto，然后是off，最后是on，一直循环）
 *  @param sender: 闪光灯按钮
 */
- (void)switchFlashMode:(UIButton*)sender {
    
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (!captureDeviceClass) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"您的设备没有拍照功能" delegate:nil cancelButtonTitle:NSLocalizedString(@"Sure", nil) otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    NSString *imgStr = @"";
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    if ([device hasFlash]) {
//        if (!sender) {//设置默认的闪光灯模式
//            device.flashMode = AVCaptureFlashModeAuto;
//        } else {
            if (device.torchMode == AVCaptureFlashModeOff) {
                device.torchMode = AVCaptureFlashModeOn;
                imgStr = @"flashing_on.png";
                
            } else if (device.torchMode == AVCaptureFlashModeOn) {
                device.torchMode = AVCaptureFlashModeAuto;
                imgStr = @"flashing_auto.png";
                
            } else if (device.torchMode == AVCaptureFlashModeAuto) {
                device.torchMode = AVCaptureFlashModeOff;
                imgStr = @"flashing_off.png";
                
            }
//        }
        
        if (sender) {
            [sender setImage:[UIImage imageNamed:imgStr] forState:UIControlStateNormal];
        }
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"您的设备没有闪光灯功能" delegate:nil cancelButtonTitle:@"噢T_T" otherButtonTitles: nil];
        [alert show];
    }
    [device unlockForConfiguration];
}

/**
 *  点击后对焦
 *
 *  @param devicePoint 点击的point
 */
- (void)focusInPoint:(CGPoint)devicePoint {
//    if (CGRectContainsPoint(_previewLayer.bounds, devicePoint) == NO) {
//        return;
//    }
    
    devicePoint = [self convertToPointOfInterestFromViewCoordinates:devicePoint];
	[self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange {
    
	dispatch_async(_sessionQueue, ^{
        AVCaptureDevice *device = [self->_inputDevice device];
		NSError *error = nil;
		if ([device lockForConfiguration:&error])
		{
			if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
			{
				[device setFocusMode:focusMode];
				[device setFocusPointOfInterest:point];
			}
			if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
			{
				[device setExposureMode:exposureMode];
				[device setExposurePointOfInterest:point];
			}
			[device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
			[device unlockForConfiguration];
		}
		else
		{
			SCDLog(@"%@", error);
		}
	});
}

- (void)subjectAreaDidChange:(NSNotification *)notification {
    
	CGPoint devicePoint = CGPointMake(.5, .5);
	[self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

/**
 *  外部的point转换为camera需要的point(外部point/相机页面的frame)
 *
 *  @param viewCoordinates 外部的point
 *
 *  @return 相对位置的point
 */
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates {
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = _previewLayer.bounds.size;
    
    AVCaptureVideoPreviewLayer *videoPreviewLayer = self.previewLayer;
    
    if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResize]) {
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        for(AVCaptureInputPort *port in [[self.session.inputs lastObject]ports]) {
            if([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResizeAspect]) {
                    if(viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
                        if(point.x >= blackBar && point.x <= blackBar + x2) {
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
                        if(point.y >= blackBar && point.y <= blackBar + y2) {
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
                    if(viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2;
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2);
                        xc = point.y / frameSize.height;
                    }
                    
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

/**
 *  显示/隐藏网格
 *
 *  @param toShow 显示或隐藏
 */
- (void)switchGrid:(BOOL)toShow {
    
}


#pragma mark ---------------private--------------
- (AVCaptureConnection*)findVideoConnection {
    AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in _stillImageOutput.connections) {
		for (AVCaptureInputPort *port in connection.inputPorts) {
			if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) {
            break;
        }
	}
    return videoConnection;
}

@end

@implementation SCCaptureSessionManager(VideoConvert)

- (void) convertVideoQuailtyWithInputURL:(NSURL*)inputURL
//                               outputURL:(NSURL*)outputURL
                         completeHandler:(void (^)(AVAssetExportSession*))handler
{
    
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tempVideoConvertToMp41111.mp4"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if( [fm fileExistsAtPath:filePath] ){
        [fm removeItemAtPath:filePath error:nil];
    }
    NSURL *outputURL = [NSURL fileURLWithPath:filePath];
    
//    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAsset *avAsset = [AVAsset assetWithURL:inputURL];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPreset960x540];
    // NSLog(resultPath);
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse= YES;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         switch (exportSession.status) {
             case AVAssetExportSessionStatusCancelled:
                 NSLog(@"AVAssetExportSessionStatusCancelled");
                 break;
             case AVAssetExportSessionStatusUnknown:
                 NSLog(@"AVAssetExportSessionStatusUnknown");
                 break;
             case AVAssetExportSessionStatusWaiting:
                 NSLog(@"AVAssetExportSessionStatusWaiting");
                 break;
             case AVAssetExportSessionStatusExporting:
                 NSLog(@"AVAssetExportSessionStatusExporting");
                 break;
             case AVAssetExportSessionStatusCompleted:
                 NSLog(@"AVAssetExportSessionStatusCompleted");
//                 NSLog(@"%@",[NSString stringWithFormat:@"%f s", [self getVideoLength:outputURL]]);
                 NSLog(@"%@", [NSString stringWithFormat:@"%.2ld kb", (long)[self getFileSize:[outputURL path]]]);
                 //UISaveVideoAtPathToSavedPhotosAlbum([outputURL path], self, nil, NULL);//这个是保存到手机相册
                 //制作完成
                 if( _videoBlock ){
                     _videoBlock(outputURL);
                     return ;
                 }
                 break;
             case AVAssetExportSessionStatusFailed:{
                 NSLog(@"AVAssetExportSessionStatusFailed");
                 if( _videoBlock ){
                     _videoBlock(nil);
                 }
             }
                 break;
         }
     }];
}


/*
 * 合成并导出视频
 */
- (void)amergeAndExportVideoAtFileURLs:(NSArray *)fileURLArray
{
    NSError *error = nil;
    
    //渲染尺寸
    CGSize renderSize = CGSizeMake(0, 0);
    
    NSMutableArray *layerInstructionArray = [NSMutableArray array];
    
    //用来合成视频
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    CMTime totalDuration = kCMTimeZero;
    
    //先取assetTrack 也为了取renderSize
    NSMutableArray *assetTrackArray = [NSMutableArray array];
    NSMutableArray *assetArray = [NSMutableArray array];
    
    for (NSURL *fileURL in fileURLArray) {
        
        //AVAsset：素材库里的素材
        AVAsset *asset = [AVAsset assetWithURL:fileURL];
        
        if (!asset) {
            continue;
        }
        
        [assetArray addObject:asset];
        
        //素材的轨道
        AVAssetTrack *assetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];//返回一个数组AVAssetTracks资产
        [assetTrackArray addObject:assetTrack];
        
        renderSize.width = MAX(renderSize.width, assetTrack.naturalSize.height);
        renderSize.height = MAX(renderSize.height, assetTrack.naturalSize.width);
    }
    
    CGFloat renderW = renderSize.width; //375
    
    for (NSInteger i = 0; i < [assetArray count] && i < assetTrackArray.count; i++) {
        
        AVAsset *asset = [assetArray objectAtIndex:i];
        AVAssetTrack *assetTrack = [assetTrackArray objectAtIndex:i];
        
        //文件中的音频轨道，里面可以插入各种对应的素材
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        NSArray*dataSourceArray= [asset tracksWithMediaType:AVMediaTypeAudio];//获取声道，即麦克风相关信息
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:((dataSourceArray.count > 0)?[dataSourceArray objectAtIndex:0]:nil) atTime:totalDuration error:nil];
        
        //工程文件中的轨道，有音频轨，里面可以插入各种对应的素材
        AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:assetTrack atTime:totalDuration error:&error];
        
        //视频轨道中的一个视频，可以缩放、旋转等
        AVMutableVideoCompositionLayerInstruction *layerInstrucition = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        totalDuration = CMTimeAdd(totalDuration, asset.duration);
        
        CGFloat rate = renderW / MIN(assetTrack.naturalSize.width, assetTrack.naturalSize.height);

        CGAffineTransform layerTransform = CGAffineTransformMake(assetTrack.preferredTransform.a, assetTrack.preferredTransform.b, assetTrack.preferredTransform.c, assetTrack.preferredTransform.d, assetTrack.preferredTransform.tx * rate, assetTrack.preferredTransform.ty * rate);
//        layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, 0, -(assetTrack.naturalSize.width - assetTrack.naturalSize.height) / 2.0));//向上移动取中部影相
        layerTransform = CGAffineTransformScale(layerTransform, rate, rate);//放缩，解决前后摄像结果大小不对称
//
        [layerInstrucition setTransform:layerTransform atTime:kCMTimeZero];
        [layerInstrucition setOpacity:0.0 atTime:totalDuration];
        
        //data
        [layerInstructionArray addObject:layerInstrucition];
    }
    
    //get save path
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tempVideoConvertToMp41111.mp4"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if( [fm fileExistsAtPath:filePath] ){
        [fm removeItemAtPath:filePath error:nil];
    }
    NSURL *mergeFileURL = [NSURL fileURLWithPath:filePath];
    
    //export
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
    mainInstruction.layerInstructions = layerInstructionArray;
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = @[mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 100);
    CGFloat scale = [UIScreen mainScreen].bounds.size.height/[UIScreen mainScreen].bounds.size.width;
    mainCompositionInst.renderSize = CGSizeMake(renderW, renderW *scale );//0.75);
    //资源导出
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    exporter.videoComposition = mainCompositionInst;
    exporter.outputURL = mergeFileURL;
    exporter.outputFileType = AVFileTypeMPEG4;//视频格式MP4
    exporter.shouldOptimizeForNetworkUse = YES;
    
    NSLog(@"----正在导出合成的视频------");
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
//            if (self.delegate && [self.delegate conformsToProtocol:@protocol(IMVideoRecorderDelegate)] && [self.delegate respondsToSelector:@selector(didFinishMergingVideosToOutPutFileAtURL:)]) {
                NSInteger kb = [self getFileSize:[mergeFileURL absoluteString]];
                NSString *kbStr = [NSString stringWithFormat:@"%ld kb", (long)kb];
                NSLog(@"视频大小 kb == > %@",kbStr);
                NSLog(@"本段视频的时间: %f", totalDuration.value);
                NSLog(@"录制视频完成: %@", mergeFileURL);
            
            if( exporter.status == AVAssetExportSessionStatusCompleted )
            {
                //制作完成
                if( _videoBlock ){
                    _videoBlock(mergeFileURL);
                }
            }
            else{
                //制作失败
                if( _videoBlock ){
                    _videoBlock(nil);
                }
            }
            
//                [self.delegate didFinishMergingVideosToOutPutFileAtURL:mergeFileURL];
//            }
            
//            [self removeMovFile];
            
//            [[ChatDataProxy sharedProxy] addNewHistorySight:[mergeFileURL absoluteString]];
        });
    }];
}

- (NSInteger) getFileSize:(NSString*) path
{
    path = [path stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    NSFileManager * filemanager = [NSFileManager defaultManager];
    if([filemanager fileExistsAtPath:path]){
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:path error:nil];
        NSNumber *theFileSize;
        if ( (theFileSize = [attributes objectForKey:NSFileSize]) )
            return  [theFileSize intValue]/1024;
        else
            return -1;
    }
    else
    {
        return -1;
    }
}

@end
