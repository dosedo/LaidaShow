//
//  UITabBarController+Ext.h
//  HiTravelService
//
//  Created by hitomedia on 2017/4/14.
//  Copyright © 2017年 hitumedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBarController (Ext)

- (void)configTabbarWithCtrls:(NSArray*)ctrls
                       titles:(NSArray*)titles
             selectedImgNames:(NSArray*)sImgNames
               normalImgNames:(NSArray*)nImgNames
                    textColor:(UIColor*)textColor
             selctedTextColor:(UIColor*)sTextColor;

@end
