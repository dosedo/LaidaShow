//
//  DSVideoEditManager.m
//  ThreeShow
//
//  Created by cgw on 2019/7/16.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "DSVideoEditManager.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>

@implementation DSVideoEditManager

+ (DSVideoEditManager *)shareVideoEditManager{
    static DSVideoEditManager *em = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        em = [DSVideoEditManager new];
    });
    return em;
}

#pragma mark - 视频方向问题
- (void)ratateVideoOritinon{
    AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.renderSize = CGSizeMake(320, 240);
    videoComposition.frameDuration = CMTimeMake(1, 30);
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30) );
    
    AVAsset *asset;
    AVMutableVideoCompositionLayerInstruction* rotator = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]];
    CGAffineTransform translateToCenter = CGAffineTransformMakeTranslation( 0,-320);
    CGAffineTransform rotateBy90Degrees = CGAffineTransformMakeRotation( M_PI_2);
    CGAffineTransform shrinkWidth = CGAffineTransformMakeScale(0.66, 1); // needed because Apple does a "stretch" by default - really, we should find and undo apple's stretch - I suspect it'll be a CALayer defaultTransform, or UIView property causing this
    CGAffineTransform finalTransform = CGAffineTransformConcat( shrinkWidth, CGAffineTransformConcat(translateToCenter, rotateBy90Degrees) );
    [rotator setTransform:finalTransform atTime:kCMTimeZero];
    
    instruction.layerInstructions = [NSArray arrayWithObject: rotator];
    videoComposition.instructions = [NSArray arrayWithObject: instruction];
    
}

+ (NSUInteger)degressFromVideoFileWithURL:(NSURL *)url
{
    NSUInteger degress = 0;
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            // Portrait
            degress = 90;
        }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            // PortraitUpsideDown
            degress = 270;
        }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            // LandscapeRight
            degress = 0;
        }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            // LandscapeLeft
            degress = 180;
        }
    }
    
    NSLog(@"video degree = %lu",(unsigned long)degress);
    return degress;
}

#pragma mark - 添加水印
- (void)addWaterMarkWithImg:(UIImage *)img frame:(CGRect)frame inputVideoPath:(nonnull NSString *)inputVideoPath complteBlock:(nonnull void (^)(NSString * _Nonnull))completeBlock{
//    [[self class] addWaterPicWithVideoPath:inputVideoPath];
    
    //1 创建AVAsset实例
    AVURLAsset*videoAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:inputVideoPath]];
    
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    //3 视频通道
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                        ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject]
                         atTime:kCMTimeZero error:nil];
    
    //2 音频通道
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                        ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject]
                         atTime:kCMTimeZero error:nil];
    
    //3.1 AVMutableVideoCompositionInstruction 视频轨道中的一个视频，可以缩放、旋转等
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    
    // 3.2 AVMutableVideoCompositionLayerInstruction 一个视频轨道，包含了这个轨道上的所有视频素材
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    
    [videolayerInstruction setOpacity:0.0 atTime:videoAsset.duration];
    
    // 3.3 - Add instructions
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:videolayerInstruction,nil];
    
    //AVMutableVideoComposition：管理所有视频轨道，水印添加就在这上面
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize naturalSize = videoAssetTrack.naturalSize;
    
    float renderWidth, renderHeight;
    renderWidth = naturalSize.width;
    renderHeight = naturalSize.height;
    mainCompositionInst.renderSize = CGSizeMake(renderWidth, renderHeight);
    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    [[self class] applyVideoEffectsToComposition:mainCompositionInst size:naturalSize img:img imgFrame:frame];

    //    // 4 - 输出路径
    NSString *outPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"waterMarkVideo.mp4"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if( [fm fileExistsAtPath:outPath] ){
        [fm removeItemAtPath:outPath error:nil];
    }
    NSURL* videoUrl = [NSURL fileURLWithPath:outPath];
    
    // 5 - 视频文件输出
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPresetMediumQuality];
    exporter.outputURL = videoUrl;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = mainCompositionInst;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if( exporter.status == AVAssetExportSessionStatusCompleted ){
                
                NSLog(@"视频导出完成，path:%@",videoUrl.path);
                //                UISaveVideoAtPathToSavedPhotosAlbum(myPathDocs, nil, nil, nil);
                if( completeBlock ){
                    completeBlock(outPath);
                }
                
            }else if( exporter.status == AVAssetExportSessionStatusFailed )
            {
                NSLog(@"failed");
                if( completeBlock ){
                    completeBlock(nil);
                }
            }
        });
    }];
}

/**
 设置水印及其对应视频的位置
 
 @param composition 视频的结构
 @param size 视频的尺寸
 */
+ (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size img:(UIImage*)img imgFrame:(CGRect)imgFr
{
    // 文字
    //    CATextLayer *subtitle1Text = [[CATextLayer alloc] init];
    //    //    [subtitle1Text setFont:@"Helvetica-Bold"];
    //    [subtitle1Text setFontSize:36];
    //    [subtitle1Text setFrame:CGRectMake(10, size.height-10-100, size.width, 100)];
    //    [subtitle1Text setString:@"ZHIMABAOBAO"];
    //    //    [subtitle1Text setAlignmentMode:kCAAlignmentCenter];
    //    [subtitle1Text setForegroundColor:[[UIColor whiteColor] CGColor]];
    
    //图片
    CALayer*picLayer = [CALayer layer];
    picLayer.contents = (id)(img.CGImage);
    picLayer.frame = imgFr;
    
//    CALayer*picLayer = [CALayer layer];
//    picLayer.contents = (id)([UIImage imageNamed:@"1111.jpg"].CGImage);
//    [picLayer setFrame:CGRectMake(99, 193, 69, 92)];
    
    // 2 - The usual overlay
    CALayer *overlayLayer = [CALayer layer];
    [overlayLayer addSublayer:picLayer];
    overlayLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [overlayLayer setMasksToBounds:YES];
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayer];
    
    composition.animationTool = [AVVideoCompositionCoreAnimationTool
                                 videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
}


#pragma mark - 文字水印

- (void)addWaterMarkWithText:(NSString*)text frame:(CGRect)frame fnt:(CGFloat)fnt transform:(CGAffineTransform)transform inputVideoPath:(nonnull NSString *)inputVideoPath  complteBlock:(nonnull void (^)(NSString * _Nonnull))completeBlock{
  
    //1 创建AVAsset实例
    AVURLAsset*videoAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:inputVideoPath]];
    
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    //3 视频通道
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                        ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject]
                         atTime:kCMTimeZero error:nil];
    
    //2 音频通道
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                        ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject]
                         atTime:kCMTimeZero error:nil];
    
    //3.1 AVMutableVideoCompositionInstruction 视频轨道中的一个视频，可以缩放、旋转等
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    
    // 3.2 AVMutableVideoCompositionLayerInstruction 一个视频轨道，包含了这个轨道上的所有视频素材
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    
    [videolayerInstruction setOpacity:0.0 atTime:videoAsset.duration];
    
    // 3.3 - Add instructions
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:videolayerInstruction,nil];
    
    //AVMutableVideoComposition：管理所有视频轨道，水印添加就在这上面
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize naturalSize = videoAssetTrack.naturalSize;
    
    float renderWidth, renderHeight;
    renderWidth = naturalSize.width;
    renderHeight = naturalSize.height;
    mainCompositionInst.renderSize = CGSizeMake(renderWidth, renderHeight);
    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    
    CGAffineTransform tran;
    [[self class] applyVideoEffectsToComposition:mainCompositionInst size:naturalSize text:text textFieldFr:frame fontSize:30 transform3D:tran];
    
//    [[self class] applyVideoEffectsToComposition:mainCompositionInst size:naturalSize img:img imgFrame:frame];
    
    //    // 4 - 输出路径
    NSString *outPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"waterMarkVideo.mp4"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if( [fm fileExistsAtPath:outPath] ){
        [fm removeItemAtPath:outPath error:nil];
    }
    NSURL* videoUrl = [NSURL fileURLWithPath:outPath];
    
    // 5 - 视频文件输出
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPresetMediumQuality];
    exporter.outputURL = videoUrl;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = mainCompositionInst;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if( exporter.status == AVAssetExportSessionStatusCompleted ){
                
                NSLog(@"视频导出完成，path:%@",videoUrl.path);
                //                UISaveVideoAtPathToSavedPhotosAlbum(myPathDocs, nil, nil, nil);
                if( completeBlock ){
                    completeBlock(outPath);
                }
                
            }else if( exporter.status == AVAssetExportSessionStatusFailed )
            {
                NSLog(@"failed");
                if( completeBlock ){
                    completeBlock(nil);
                }
            }
        });
    }];
}

/**
 设置水印及其对应视频的位置
 
 @param composition 视频的结构
 @param size 视频的尺寸
 */
+ (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size text:(NSString*)text textFieldFr:(CGRect)textFieldFr fontSize:(CGFloat)fntSize transform3D:(CGAffineTransform)transform3d
{
    // 文字
    CATextLayer *subtitle1Text = [[CATextLayer alloc] init];
    [subtitle1Text setFont:@"Helvetica-Bold"];
    [subtitle1Text setFontSize:fntSize];
//    [subtitle1Text setFrame:CGRectMake(99, 193, 69, 92)];
    [subtitle1Text setFrame:textFieldFr];
    [subtitle1Text setForegroundColor:[UIColor whiteColor].CGColor];
//    [subtitle1Text setString:@"ZHIMABAOBAOssfsdsf"];
    [subtitle1Text setString:text];
    [subtitle1Text setAlignmentMode:kCAAlignmentCenter];
//    CGAffineTransform transform = CGAffineTransformMakeScale(0.79,0.79);//CGAffineTransformScale(subtitle1Text.affineTransform, 0.79, 0.79);
//    [subtitle1Text setAffineTransform:transform];
//    subtitle1Text.affineTransform = transform3d;
    
    //图片
//    CALayer*picLayer = [CALayer layer];
//    picLayer.contents = (id)([UIImage imageNamed:@"1111.jpg"].CGImage);
//    [picLayer setFrame:CGRectMake(99, 193, 69, 92)];
    
    //    picLayer.frame = CGRectMake(imgFr.origin.x, size.height-imgFr.size.height-imgFr.origin.y, imgFr.size.width, imgFr.size.height);
    //
    //    picLayer.frame = CGRectMake(0, size.height/4, size.width/2, size.height/2);
    
    // 2 - The usual overlay
    CALayer *overlayLayer = [CALayer layer];
    [overlayLayer addSublayer:subtitle1Text];
    overlayLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [overlayLayer setMasksToBounds:YES];
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayer];
    
    composition.animationTool = [AVVideoCompositionCoreAnimationTool
                                 videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
}

@end
