//
//  UIImage+image.m
//  JKRAVCameraDemo
//
//  Created by Lucky on 2016/10/22.
//  Copyright © 2016年 tronsis_ios. All rights reserved.
//

#import "UIImage+image.h"

#import <AVFoundation/AVAsset.h>

#import <AVFoundation/AVAssetImageGenerator.h>

#import <AVFoundation/AVTime.h>

@implementation UIImage (image)

+ (instancetype)iconImageNamed:(NSString *)name {
    UIImage *image = [UIImage imageNamed:name];
    UIImage *iconImage = nil;
    UIGraphicsBeginImageContext(CGSizeMake(20, 20));
    [image drawInRect:CGRectMake(0, 0, 20, 20)];
    iconImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return iconImage;
}

+ (instancetype)imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!color || size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (instancetype)imageClipCircle {
    CGRect mframe = CGRectMake(0, 0, self.size.width, self.size.height);
    
    UIGraphicsBeginImageContextWithOptions(mframe.size, NO, 0.0);
    UIBezierPath *pathClip = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    [pathClip addClip];
    [self drawAtPoint:CGPointMake(0, 0)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage*)getVideoFirstViewImage:(NSURL *)path {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
    
//    ---------------------
//    作者：weixin_34074740
//    来源：CSDN
//    原文：https://blog.csdn.net/weixin_34074740/article/details/87618940
//    版权声明：本文为博主原创文章，转载请附上博文链接！
}
@end
