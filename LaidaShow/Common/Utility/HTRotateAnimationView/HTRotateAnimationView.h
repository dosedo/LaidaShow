//
//  HTRotateAnimationView.h
//  Hitu
//
//  Created by hitomedia on 2016/12/27.
//  Copyright © 2016年 hitomedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HTRotateAnimationView : UIView

/**
 数量展示
 */
@property (nonatomic, strong) UILabel *countL;

/**
 旋转的图片视图
 */
@property (nonatomic, strong) UIImageView *rotateImgV;

/**
 转动一周的时间 单位秒
 */
@property (nonatomic, assign) CGFloat duration; //转动时间


- (void)startAnimation;
- (void)stopAnimation;
@end
