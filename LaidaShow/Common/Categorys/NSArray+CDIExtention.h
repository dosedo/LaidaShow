//
//  NSArray+CDIExtention.h
//  ThreeShow
//
//  Created by DeepAI on 2019/1/18.
//  Copyright © 2019年 deepai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (CDIExtention)
/** 将一个gif图转换为一帧一帧的图片数组*/
+ (NSArray *)cdi_imagesWithGif:(NSString *)gifName;
+ (NSMutableArray *)praseGIFDataToImageArray:(NSData *)data;
@end

NS_ASSUME_NONNULL_END
