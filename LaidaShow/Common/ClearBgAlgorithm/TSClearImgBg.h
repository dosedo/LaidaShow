//
//  NSObject.h
//  ThreeShow
//
//  Created by wkun on 2018/8/16.
//  Copyright © 2018年 deepai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSClearImgBg : NSObject

/**
 对原图去背景。

 @param originImgPaths 原图的全路径的集合  NSString
 @param midImgPaths 遮罩图的全路径集合
 @param resultImgPaths 结果图全路径集合
 @param completeBlock 完成回调
 */
+ (void)startClearImgWithOriginImgPaths:(NSArray<NSString*>*)originImgPaths midImgPaths:(NSArray<NSString*>*)midImgPaths resultImgPaths:(NSArray<NSString*>*)resultImgPaths completBlock:(void (^)(NSError *))completeBlock;


/**
 批量去底。

 @param originImgPath 原图所在的路径 最后带/，如abc/originimgs/
 @param maskImgPath 遮罩图路径，最后带/
 @param resultImgPath 结果图路径，最后带/
 @param changeImgAllPath 换地的背景图的全路径，不是换底传nil
 @param count 去底图片的数量
 @param completeBlock 回调
 */
+ (void)startClearImgWithOriginImgPath:(NSString*)originImgPath maskImgPath:(NSString*)maskImgPath resultImgPath:(NSString*)resultImgPath changeBgImg:(NSString*)changeImgAllPath count:(NSUInteger)count completBlock:(void (^)(NSError *))completeBlock;

+ (void)cancleClearImg;

@end
