//
//  UIButton+RotateAnimate.m
//  ThreeShow
//
//  Created by hitomedia on 13/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "UIButton+RotateAnimate.h"

@implementation UIButton (RotateAnimate)

#pragma mark - Public
- (void)startAnimation{
    CABasicAnimation *animation = [self roatationAnimatetion];
    animation.duration = self.duration;
    [self.imageView.layer addAnimation:animation forKey:@"btn_rav_add_animation_key"];
}

- (void)stopAnimation{
    [self.imageView.layer removeAnimationForKey:@"btn_rav_add_animation_key"];
}

#pragma mark - Private
- (NSInteger)duration{
    return 2;
}

#pragma mark ====旋转动画======
-(CABasicAnimation *)rotation:(float)dur degree:(float)degree direction:(int)direction repeatCount:(int)repeatCount
{
    CATransform3D rotationTransform = CATransform3DMakeRotation(degree, 0, 0, direction);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:rotationTransform];
    animation.duration  =  dur;
    animation.autoreverses = NO;
    animation.cumulative = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.repeatCount = repeatCount;
//    animation.delegate = self;
    
    return animation;
}

- (CABasicAnimation*)roatationAnimatetion{
    CABasicAnimation *animation =  [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果
    animation.fromValue = [NSNumber numberWithFloat:0.f];
    animation.toValue =  [NSNumber numberWithFloat: M_PI *2];
    animation.duration  = 2;
    animation.autoreverses = NO;
    animation.fillMode =kCAFillModeForwards;
    animation.repeatCount = MAXFLOAT;
    return animation;
}

@end



