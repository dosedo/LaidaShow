//
//  NSArray+CDIExtention.m
//  ThreeShow
//
//  Created by DeepAI on 2019/1/18.
//  Copyright © 2019年 deepai. All rights reserved.
//

#import "NSArray+CDIExtention.h"
#import <ImageIO/ImageIO.h>
#import <UIKit/UIKit.h>

@implementation NSArray (CDIExtention)

+ (NSArray *)cdi_imagesWithGif:(NSString *)gifName {
  //  http://n.res.aipp3d.com/g/2018/12/21/1139/9f85a33f7891450190e234e7dd217d83.gif
    //NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:gifName withExtension:@"gif"];
    NSURL *fileUrl = [NSURL URLWithString:@"http://n.res.aipp3d.com/g/2018/12/21/1139/9f85a33f7891450190e234e7dd217d83.gif"];
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)fileUrl, NULL);
    size_t gifCount = CGImageSourceGetCount(gifSource);
    NSMutableArray *frames = [[NSMutableArray alloc]init];
    for (size_t i = 0; i< gifCount; i++) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
        [frames addObject:image];
        CGImageRelease(imageRef);
        
    }
    return frames;
    
}


+ (NSMutableArray *)praseGIFDataToImageArray:(NSData *)data
{
    NSMutableArray *frames = [[NSMutableArray alloc] init];
    CGImageSourceRef src = CGImageSourceCreateWithData((CFDataRef)data, NULL);
    CGFloat animationTime = 0.f;
    if (src) {
        size_t l = CGImageSourceGetCount(src);
        frames = [NSMutableArray arrayWithCapacity:l];
        for (size_t i = 0; i < l; i++) {
            CGImageRef img = CGImageSourceCreateImageAtIndex(src, i, NULL);
            NSDictionary *properties = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(src, i, NULL));
            NSDictionary *frameProperties = [properties objectForKey:(NSString *)kCGImagePropertyGIFDictionary];
            NSNumber *delayTime = [frameProperties objectForKey:(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
            animationTime += [delayTime floatValue];
            if (img) {
                [frames addObject:[UIImage imageWithCGImage:img]];
                CGImageRelease(img);
            }
        }
        CFRelease(src);
    }
    return frames;
}

@end
