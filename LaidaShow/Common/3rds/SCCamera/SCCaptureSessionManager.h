//
//  SCCaptureSessionManager.h
//  SCCaptureCameraDemo
//
//  Created by Aevitx on 14-1-16.
//  Copyright (c) 2014年 Aevitx. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "SCDefines.h"

#define MAX_PINCH_SCALE_NUM   3.f
#define MIN_PINCH_SCALE_NUM   1.f

@protocol SCCaptureSessionManager;

typedef void(^DidCapturePhotoBlock)(UIImage *stillImage);
typedef void(^DidCaptureVideoBlock)(NSURL *videoUrl);

@interface SCCaptureSessionManager : NSObject

@property (nonatomic, strong) UIView *preview;

@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureDeviceInput *inputDevice;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

/**
 带有音频的视频输出
 */
@property (nonatomic, strong) AVCaptureMovieFileOutput *videoOutput;

//@property (nonatomic, strong) UIImage *stillImage;

//pinch
@property (nonatomic, assign) CGFloat preScaleNum;
@property (nonatomic, assign) CGFloat scaleNum;

@property (nonatomic, weak) id <SCCaptureSessionManager> delegate;


- (void)configureWithParentLayer:(UIView*)parent previewRect:(CGRect)preivewRect isVideo:(BOOL)isVideo;

- (void)takePicture:(DidCapturePhotoBlock)block;
//- (void)switchCamera:(BOOL)isFrontCamera;
- (void)pinchCameraViewWithScalNum:(CGFloat)scale;
- (void)pinchCameraView:(UIPinchGestureRecognizer*)gesture;
//- (void)switchFlashMode:(UIButton*)sender;
- (void)focusInPoint:(CGPoint)devicePoint;
//- (void)switchGrid:(BOOL)toShow;

- (void)shootVideo:(DidCaptureVideoBlock)block;


@end


@protocol SCCaptureSessionManager <NSObject>

@optional
- (void)didCapturePhoto:(UIImage*)stillImage;

@end

@interface SCCaptureSessionManager(VideoConvert)
- (void) convertVideoQuailtyWithInputURL:(NSURL*)inputURL
                         completeHandler:(void (^)(AVAssetExportSession*))handler;
- (void)amergeAndExportVideoAtFileURLs:(NSArray *)fileURLArray;
@end
