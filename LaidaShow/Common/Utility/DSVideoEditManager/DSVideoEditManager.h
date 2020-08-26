//
//  DSVideoEditManager.h
//  ThreeShow
//
//  Created by cgw on 2019/7/16.
//  Copyright © 2019 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 视频编辑类，提供滤镜、水印、视频亮度、对比度等
 */
@interface DSVideoEditManager : NSObject

+ (DSVideoEditManager*)shareVideoEditManager;

+ (NSUInteger)degressFromVideoFileWithURL:(NSURL *)url;

/**
 给视频添加水印

 @param img 水印图片
 @param frame 水印在视频上的位置
 @param inputVideoPath 视频路径
 @param completeBlock 添加完成的回调，outputPath添加水印后的视频路径，若合成失败，则outputPath为空
 */
- (void)addWaterMarkWithImg:(UIImage*)img frame:(CGRect)frame inputVideoPath:(NSString*)inputVideoPath complteBlock:(void(^)(NSString* outputPath))completeBlock;

//文字水印
- (void)addWaterMarkWithText:(NSString*)text frame:(CGRect)frame fnt:(CGFloat)fnt transform:(CGAffineTransform)transform inputVideoPath:(nonnull NSString *)inputVideoPath  complteBlock:(nonnull void (^)(NSString * _Nonnull))completeBlock;


@end

NS_ASSUME_NONNULL_END
