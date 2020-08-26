//
//  UIImage+Extras.m
//  PaiPai
//
//  Created by wkun on 12/17/15.
//  Copyright © 2015 SparkFour. All rights reserved.
//

#import "UIImage+Extras.h"

@implementation UIImage(UIImage_Extras)

- (UIImage *)imageByScalingToSize:(CGSize)targetSize isNeedCut:(BOOL)needCut{
//    CGSize imageSize = sourceImage.size;
//    CGFloat width = imageSize.width;
//    CGFloat height = imageSize.height;
//    CGFloat scaleFactor = 0.0;
    
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize tsize = targetSize;
    CGFloat ix = -2;
    tsize.width = tsize.width-2 + ix;
    
    CGPoint thumbnailPoint = CGPointMake(ix,0.0);

    UIGraphicsBeginImageContext(tsize);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = targetSize.width;
    thumbnailRect.size.height = tsize.height;
    [sourceImage drawInRect:thumbnailRect];
    newImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");

    return newImage ;
}

- (UIImage *)imageByScalingToSize:(CGSize)targetSize
{
    //    CGSize imageSize = sourceImage.size;
    //    CGFloat width = imageSize.width;
    //    CGFloat height = imageSize.height;
    //    CGFloat scaleFactor = 0.0;
    
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize tsize = targetSize;
    CGFloat ix = 0;
    tsize.width = tsize.width + ix;
    
    CGPoint thumbnailPoint = CGPointMake(ix,0.0);
    
    UIGraphicsBeginImageContext(tsize);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = targetSize.width;
    thumbnailRect.size.height = tsize.height;
    [sourceImage drawInRect:thumbnailRect];
    newImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    return newImage ;
}

-(UIImage*)getSubImage:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    //绘制图片的大小
    [self drawInRect:CGRectMake(0, 0, size.width, self.size.height)];
    //从当前context中创建一个改变大小后的图片
    UIImage *endImage=UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    return endImage;
}

///不变形缩放图片
-(UIImage*)imageByScalingToSizeNotChange:(CGSize)targetSize{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGSize imgSize = sourceImage.size;
    
    CGFloat scaledHeight = targetHeight;
    CGFloat scaledWidth =  imgSize.width/(imgSize.height/scaledHeight); //targetWidth;
    
    CGPoint thumbnailPoint = CGPointMake(targetSize.width-scaledWidth,0.0);
    
    UIGraphicsBeginImageContext(targetSize);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    return newImage ;

}

//改变透明度
+ (UIImage *)imageByApplyingAlpha:(CGFloat)alpha  image:(UIImage*)image
{

    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeNormal);//kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    CGContextDrawImage(ctx, area, image.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage*)imageWithView:(UIView *)view{
    
    UIView *v = view;
    CGSize s = view.bounds.size;

    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
    
    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage* viewImage =UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return viewImage;
}

@end



