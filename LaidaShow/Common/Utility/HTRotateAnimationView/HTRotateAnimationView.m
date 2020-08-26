//
//  HTRotateAnimationView.m
//  Hitu
//
//  Created by hitomedia on 2016/12/27.
//  Copyright © 2016年 hitomedia. All rights reserved.
//

#import "HTRotateAnimationView.h"

#define kDegreesToRadian(x) (M_PI * (x) / 180.0)

#define kRadianToDegrees(radian) (radian*180.0)/(M_PI)
@interface HTRotateAnimationView()<CAAnimationDelegate>

@end

@implementation HTRotateAnimationView

#pragma mark - Public
- (void)startAnimation{
    CABasicAnimation *animation = [self roatationAnimatetion];
    if( self.duration <=0 ){
        self.duration = 2;
    }
    animation.duration = self.duration;
    [self.rotateImgV.layer addAnimation:animation forKey:@"rav_add_animation_key"];
    [self bringSubviewToFront:self.rotateImgV];
}

- (void)stopAnimation{
    [self.rotateImgV.layer removeAnimationForKey:@"rav_add_animation_key"];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGSize size = self.frame.size;
    self.rotateImgV.frame = CGRectMake(0, 0, size.width, size.height);
    CGFloat ix = 2;
    
    self.countL.frame = CGRectMake(ix, 0, size.width-2*ix, size.height);
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
    animation.delegate = self;
    
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

- (UILabel *)countL {
    if( !_countL ){
        _countL = [[UILabel alloc] init];
        _countL.backgroundColor = [UIColor clearColor];
        _countL.textAlignment = NSTextAlignmentCenter;
        _countL.font  =[UIFont systemFontOfSize:9];
        [self addSubview:_countL];
    }
    return _countL;
}

- (UIImageView *)rotateImgV {
    if( !_rotateImgV ){
        _rotateImgV = [[UIImageView alloc] init];
        _rotateImgV.backgroundColor = [UIColor clearColor];
        _rotateImgV.contentMode = UIViewContentModeScaleAspectFit;
        
        [self addSubview:_rotateImgV];
    }
    return _rotateImgV;
}


@end
