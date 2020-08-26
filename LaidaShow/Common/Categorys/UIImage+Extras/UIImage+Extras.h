//
//  UIImage+Extras.h
//  PaiPai
//
//  Created by wkun on 12/17/15.
//  Copyright © 2015 SparkFour. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage(UIImage_Extras)
- (UIImage *)imageByScalingToSize:(CGSize)targetSize; 
-(UIImage*)getSubImage:(CGSize)size;
///不变形缩放图片
-(UIImage*)imageByScalingToSizeNotChange:(CGSize)targetSize;

- (UIImage *)imageByScalingToSize:(CGSize)targetSize isNeedCut:(BOOL)needCut;

+ (UIImage *)imageByApplyingAlpha:(CGFloat)alpha  image:(UIImage*)image;

/**
 uiview生成UIImage

 @param view 需要转图片的view
 @return 图片
 */
+ (UIImage*)imageWithView:(UIView*)view;
@end
