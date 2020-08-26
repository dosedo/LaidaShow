//
//  JKRCameraBackgroundView.m
//  JKRCameraDemo
//
//  Created by tronsis_ios on 16/8/30.
//  Copyright © 2016年 tronsis_ios. All rights reserved.
//

#import "JKRCameraBackgroundView.h"
#import "UIImage+image.h"
#import "UIView+LayoutMethods.h"

@interface JKRCameraBackgroundView ()
@property (nonatomic, strong) UIView *sliderBgView;
@end

@implementation JKRCameraBackgroundView

- (UIView*)sliderBgView{
    if( !_sliderBgView ){
        _sliderBgView = [UIView new];
        _sliderBgView.backgroundColor = [UIColor clearColor];
        CGFloat iw = /*280*/220,ih = 40;
        CGFloat bottomViewH = 150;
        CGFloat iy = SCREEN_HEIGHT- ih - (bottomViewH+BOTTOM_NOT_SAVE_HEIGHT);
        _sliderBgView.frame = CGRectMake((SCREEN_WIDTH-iw)/2, iy, iw, ih);
        [self addSubview:_sliderBgView];
        
        iw = /*200*/160;ih = 20;
        _isoSilder = [[UISlider alloc] initWithFrame:CGRectMake((_sliderBgView.width - iw)/2, (_sliderBgView.height-ih)/2, iw, ih)];
        [self setSider:_isoSilder withText:@"感光度调节"];
        _isoSilder.minimumValue = 0.0;
        _isoSilder.maximumValue = 1.0;
        _isoSilder.value = 0.5;
        [_isoSilder addTarget:self action:@selector(changeISO:) forControlEvents:UIControlEventValueChanged];
        [_isoSilder addTarget:self action:@selector(touchDownSlider) forControlEvents:UIControlEventTouchDown];
        [_isoSilder addTarget:self action:@selector(touchUpSlider) forControlEvents:UIControlEventTouchUpInside];
        [_sliderBgView addSubview:_isoSilder];
        
        _butplus = [UIButton buttonWithType:UIButtonTypeCustom];
        _butplus.frame = CGRectMake(0, 0, _isoSilder.x, _sliderBgView.height);

        [_butplus setImage:[UIImage imageNamed:@"shooting_subtract"] forState:UIControlStateNormal];
        [_butplus addTarget:self action:@selector(minus) forControlEvents:UIControlEventTouchUpInside];
        [_sliderBgView addSubview:_butplus];
        
        _minusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _minusBtn.frame = CGRectMake(_isoSilder.right, 0, _butplus.width, _sliderBgView.height);

        [_minusBtn setImage:[UIImage imageNamed:@"shooting_add"] forState:UIControlStateNormal];
            [_minusBtn addTarget:self action:@selector(plus) forControlEvents:UIControlEventTouchUpInside];
        [_sliderBgView addSubview:_minusBtn];
        
        CGAffineTransform rotation =CGAffineTransformMakeRotation((-M_PI*90/180.0));
//        rotation = CGAffineTransformMakeTranslation(10.0, 300.0);
        
        [_sliderBgView setTransform:rotation];
        
        //旋转后，移动view的center到视图的边缘
        //旋转矩阵后，宽度变了高度，高度变为宽度
        CGFloat viewH = _sliderBgView.height;
        CGFloat viewW = _sliderBgView.width;
        CGFloat toBottom = 10;
        
//        _sliderBgView.center = CGPointMake(SCREEN_WIDTH-viewW/2, SCREEN_HEIGHT-bottomViewH-viewH/2-toBottom);
        
        _sliderBgView.center = CGPointMake(SCREEN_WIDTH-viewW/2-50, (SCREEN_HEIGHT-bottomViewH)/2+20);
    }
    return _sliderBgView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if( self ){
        self.backgroundColor = [UIColor clearColor];
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerAction:)];
        _tapGestureRecognizer.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:_tapGestureRecognizer];
        
        self.sliderBgView.hidden = NO;
    
        UIImage *focusImage = [UIImage imageNamed:@"shooting_focus"];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, focusImage.size.width, focusImage.size.height)];
        imageView.image = focusImage;
        _focusLayer = [[CALayer alloc] init];
        _focusLayer = imageView.layer;
        [self.layer addSublayer:_focusLayer];
        _focusLayer.hidden = YES;
    }
    return self;
}

-(void)plus{
//    self.tapGestureRecognizer.enabled = NO;
    self.isoSilder.value += 0.01;
    [self.delegate cameraBackgroundDidChangeISO:self.isoSilder.value isPlusOrMinusBtn:YES];
    //adjustingExposure
}

-(void)minus{
//    self.tapGestureRecognizer.enabled = NO;
    self.isoSilder.value -= 0.01;
    [self.delegate cameraBackgroundDidChangeISO:self.isoSilder.value isPlusOrMinusBtn:YES];
}

- (void)setSider:(UISlider *)silder withText:(NSString *)text {
    UIImage *bgImage = [UIImage imageWithColor:[UIColor colorWithRed:252.0/255.0 green:199.0/255.0 blue:17/255.0 alpha:1] size:CGSizeMake(200, 2)];
    UIImage *slImage = [UIImage imageNamed:@"shooting_light"] ;
    [silder setMinimumTrackImage:bgImage forState:UIControlStateNormal];
    [silder setMaximumTrackImage:bgImage forState:UIControlStateNormal];
    [silder setThumbImage:slImage forState:UIControlStateNormal];
    //[silder setThumbImage:slImage forState:UIControlStateNormal];
//    CATextLayer *textLayer = [CATextLayer new];
//    textLayer.fontSize = 13;
//    textLayer.frame = CGRectMake(CGRectGetMinX(silder.frame) + 20, CGRectGetMinY(silder.frame) - 15, 100, 15);
//    textLayer.foregroundColor = [UIColor redColor].CGColor;
//    textLayer.string = text;
//    textLayer.contentsScale = [UIScreen mainScreen].scale;
//    [self.layer addSublayer:textLayer];
}


#pragma mark - 改变ISO
- (void)changeISO:(UISlider *)sender {
    NSLog(@"====改变ISO:%f",sender.value);
    
    [self.delegate cameraBackgroundDidChangeISO:sender.value isPlusOrMinusBtn:NO];
    //self.tapGestureRecognizer.enabled = NO;
}

- (void)touchDownSlider{
    if( _delegate && [_delegate respondsToSelector:@selector(cameraBackgroundView:touchDownSlider:)] ){
        [_delegate cameraBackgroundView:self touchDownSlider:self.isoSilder];
    }
}

- (void)touchUpSlider{
    if( _delegate && [_delegate respondsToSelector:@selector(cameraBackgroundView:touchUpSlider:)] ){
        [_delegate cameraBackgroundView:self touchUpSlider:self.isoSilder];
    }
}

#pragma mark -点击屏幕自动对焦
- (void)tapGestureRecognizerAction:(UITapGestureRecognizer *)tap {
    if (tap.state == UIGestureRecognizerStateRecognized) {
        CGPoint location = [tap locationInView:self];
        [self.delegate cameraBackgroundDidTap:location];
        [self addFocusLayerWithPoint:location];
        NSLog(@"===点击屏幕自动对焦===%f==%f",location.x,location.y);
    }
}

- (void)addFocusLayerWithPoint:(CGPoint)point {
    CGPoint position = point;//CGPointMake(point.x - 50, point.y - 50);
    [_focusLayer setPosition:position];
    [_focusLayer removeAllAnimations];
    _focusLayer.hidden = NO;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.focusLayer.hidden = YES;
    });
}

#pragma mark - 重置状态
- (void)reset {
    //[_progressView reset];
    
}

@end
