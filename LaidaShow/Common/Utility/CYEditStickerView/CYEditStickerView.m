//
//  PPStickerView.m
//  paipai360-2
//
//  Created by jiangyuan on 16/8/7.
//  Copyright © 2016年 DeepAI. All rights reserved.
//

#import "CYEditStickerView.h"

#define STICKER_SLIDE       100.0     //贴纸参考的宽高，实际还要调整
#define btnWH            24.0     //删除按钮，旋转按钮，镜像按钮的宽高

@interface CYEditStickerView ()<UIGestureRecognizerDelegate>
{
    CGFloat _minWidth;
    CGFloat _minHeight;
    CGFloat _maxWidth;
    CGFloat _maxHeight;
    CGFloat _deltaAngle;
    
    CGPoint prevPoint;
    CGPoint touchStart;
    CGRect  bgRect ;
    CGFloat imageRatio;
    
    CGSize preSize;
    CGPoint stickerCenterPoint;
}

@property (nonatomic,strong) UIImageView    *rotatingBtn ;
@property (nonatomic,strong) UIImageView    *flipBtn ;



@end

@implementation CYEditStickerView


#pragma mark - init
- (instancetype)initWithBgView:(UIView *)bgView image:(UIImage *)image withCenterPoint:(CGPoint)centerPoint {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];

        self.image = image ;
        
        imageRatio = image.size.width/image.size.height;
        stickerCenterPoint = centerPoint;
        bgRect = bgView.frame;
        

        
        CGFloat stickerWidth;
        CGFloat stickerHeight;
        
        if (imageRatio>1) {
            stickerWidth=STICKER_SLIDE + btnWH;
            stickerHeight=STICKER_SLIDE/imageRatio  + btnWH;
        }else{
            stickerHeight=STICKER_SLIDE  + btnWH;
            stickerWidth=STICKER_SLIDE*imageRatio  + btnWH;
        }
        
        self.bounds = CGRectMake(0,0,stickerWidth, stickerHeight);
        self.center = stickerCenterPoint;
        
        
        //这个面积的放大和缩小的倍数
        
        _minWidth   = self.bounds.size.width / sqrt(3);
        _minHeight  = self.bounds.size.height / sqrt(3);
        
        _maxWidth   = self.bounds.size.width * sqrt(8);
        _maxHeight  = self.bounds.size.height * sqrt(8);
        
        _deltaAngle = atan2(self.frame.origin.y+self.frame.size.height - self.center.y,
                            self.frame.origin.x+self.frame.size.width - self.center.x);
        
     
        //contentView
        self.contentView = [[UIImageView alloc] init] ;
        self.contentView.contentMode = UIViewContentModeScaleAspectFit;
        self.contentView.userInteractionEnabled = YES;
        self.contentView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.contentView] ;
    
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
        [self.contentView addGestureRecognizer:pan];
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)] ;
        pinch.delegate = self;
        [self.contentView addGestureRecognizer:pinch] ;
        UIRotationGestureRecognizer *rotate = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)] ;
        rotate.delegate = self;
        [self.contentView addGestureRecognizer:rotate] ;
 
        //flipBtn
        self.flipBtn = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,btnWH ,btnWH)] ;
        self.flipBtn.userInteractionEnabled = YES;
        self.flipBtn.image = [UIImage imageNamed:@"edit_addimg_close"];//@"edit_flip"] ;
        [self addSubview:self.flipBtn] ;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(flipBtnClicked)] ;
        [self.flipBtn addGestureRecognizer:tapGesture] ;
  
        //rotatingBtn
        self.rotatingBtn = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - btnWH ,self.frame.size.height - btnWH ,btnWH ,btnWH)] ;
        self.rotatingBtn.userInteractionEnabled = YES;
        self.rotatingBtn.image = [UIImage imageNamed:@"edit_addimg_drag"]; //@"edit_rotating"] ;
        [self addSubview:self.rotatingBtn] ;
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(resizeTranslate:)] ;
        [self.rotatingBtn addGestureRecognizer:panGesture] ;
 
        //阴影
//        self.contentView.layer.shadowColor = [UIColor colorWithRed:0 green:160/255.0 blue:233/255.0 alpha:1].CGColor;
//        self.contentView.layer.shadowRadius = 2;
//        self.contentView.layer.shadowOffset = CGSizeMake(2, 2);
//        self.contentView.layer.shadowOpacity = 0.3;
        
        //边框
        self.contentView.layer.masksToBounds = YES;
        self.contentView.layer.borderWidth = 0.5;
        self.contentView.layer.borderColor = [UIColor colorWithRed:0 green:160/255.0 blue:233/255.0 alpha:1].CGColor;

        
        [bgView addSubview:self] ;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //rotatingBtn
    CGFloat rotatingWH = btnWH;
    CGFloat rotatingY = self.bounds.size.height - rotatingWH;
    CGFloat rotatingX = self.bounds.size.width - rotatingWH;
    self.rotatingBtn.frame = CGRectMake(rotatingX, rotatingY, rotatingWH, rotatingWH);
    
    //flipBtn
    self.flipBtn.frame = CGRectMake(0,0, btnWH, btnWH);
    
    //contentView
    CGFloat contentX = btnWH / 2;
    CGFloat contentY = btnWH / 2;
    CGFloat contentH = self.bounds.size.height - btnWH;
    CGFloat contentW = self.bounds.size.width - btnWH;
    self.contentView.frame = CGRectMake(contentX, contentY, contentW, contentH);
}

#pragma mark - setter

- (void)setImage:(UIImage *)image {
    _image = image ;
    
    self.contentView.image = image;
}

#pragma mark - gestureEvents

-(void)pan:(UIPanGestureRecognizer *)pan {
    

    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            
            touchStart = [pan locationOfTouch:0 inView:self.superview];
            break;
        case UIGestureRecognizerStateChanged: {
            
            CGPoint location = [pan locationOfTouch:0 inView:self];
            if (CGRectContainsPoint(self.rotatingBtn.frame, location)) return;
            
            CGPoint touch = [pan locationOfTouch:0 inView:self.superview];
            
            
            CGPoint newCenter = CGPointMake(self.center.x + touch.x - touchStart.x,
                                            self.center.y + touch.y - touchStart.y) ;
            
            if (newCenter.x > self.superview.bounds.size.width)
            {
                newCenter.x = self.superview.bounds.size.width;
            }
            if (newCenter.x < 0)
            {
                newCenter.x = 0;
            }
            
            if (newCenter.y > self.superview.bounds.size.height)
            {
                newCenter.y = self.superview.bounds.size.height;
            }
            if (newCenter.y < 0)
            {
                newCenter.y = 0;
            }
            
            self.center = newCenter;
            
            
            touchStart = touch;
            break;
        }
        default:
            break;
    }
}

- (void)pinch:(UIPinchGestureRecognizer *)pinch {
    
    CGPoint originCenter = self.center;
    
    switch (pinch.state) {
            
        case UIGestureRecognizerStateBegan:

            preSize = self.bounds.size;
            [self setNeedsDisplay];
            break;
            
        case UIGestureRecognizerStateChanged: {
            
            CGFloat finalWidth = preSize.width * pinch.scale ;
            CGFloat finalHeight = preSize.height * pinch.scale ;
            
            if (finalWidth > _maxWidth || finalWidth < _minWidth || finalHeight > _maxHeight || finalHeight < _minHeight) {
                finalWidth  = self.bounds.size.width;
                finalHeight = self.bounds.size.height;
            }
            self.bounds = CGRectMake(self.bounds.origin.x,self.bounds.origin.y,finalWidth,finalHeight) ;

            self.center=originCenter;
            [self setNeedsDisplay];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            
            self.center=originCenter;
            [self setNeedsDisplay];
            break;
        }
        default:
            break;
    }
}

- (void)rotate:(UIRotationGestureRecognizer *)rotate {
    
    self.transform = CGAffineTransformMakeRotation(rotate.rotation);
    [self setNeedsDisplay] ;
}

#pragma mark - btnEvents
- (void)resizeTranslate:(UIPanGestureRecognizer *)pan {
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            prevPoint = [pan locationInView:self];
            [self setNeedsDisplay];
            break;
        case UIGestureRecognizerStateChanged: {
            //拉伸
            CGPoint point = [pan locationInView:self];
            float wChange = 0.0, hChange = 0.0;
            wChange = (point.x - prevPoint.x);
            float wRatioChange = (wChange/(float)self.contentView.frame.size.width);
            
            hChange = wRatioChange * self.contentView.frame.size.height;
            
            CGFloat finalWidth = self.bounds.size.width + 2*(wChange) ;
            CGFloat finalHeight = self.bounds.size.height + 2*(hChange) ;
            
            if (finalWidth > _maxWidth || finalWidth < _minWidth || finalHeight > _maxHeight || finalHeight < _minHeight) {
                finalWidth  = self.bounds.size.width;
                finalHeight = self.bounds.size.height;
            }
            self.bounds = CGRectMake(self.bounds.origin.x,self.bounds.origin.y,finalWidth,finalHeight) ;
            
            
            prevPoint = [pan locationInView:self];
            
            
            //旋转
            float ang = atan2([pan locationInView:self.superview].y - self.center.y,[pan locationInView:self.superview].x - self.center.x) ;
            float angleDiff = ang - _deltaAngle ;
            self.transform = CGAffineTransformMakeRotation(angleDiff) ;
            
            [self setNeedsDisplay] ;
            break;
        }
        case UIGestureRecognizerStateEnded:
            
            prevPoint = [pan locationInView:self];
            [self setNeedsDisplay];
            break;
        default:
            break;
    }
}

- (void)flipBtnClicked {
    
//    self.contentView.transform = CGAffineTransformScale(self.contentView.transform, -1, 1);
    [self removeFromSuperview];
}

#pragma mark - public
//重新绘制变化后的贴纸
- (UIImage *)getChangedImage{
    
    CGSize imgSize = CGSizeMake(self.image.size.width , self.image.size.height);

    CGFloat radius = atan2f(self.transform.b, self.transform.a);
    
    CGRect rect = CGRectMake(0, 0, imgSize.width, imgSize.height);
    rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeRotation(radius));
    
    CGSize outputSize = CGSizeMake(CGRectGetWidth(rect), CGRectGetHeight(rect));
    
    UIGraphicsBeginImageContextWithOptions(outputSize, NO, 1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, outputSize.width / 2, outputSize.height / 2);
    CGContextRotateCTM(context, radius);
    
    if (self.contentView.transform.a<0) {
        CGContextScaleCTM(context, -1, 1);
    }
    
    CGContextTranslateCTM(context, -imgSize.width / 2, -imgSize.height / 2);
    
    [self.image drawInRect:CGRectMake(0, 0, imgSize.width, imgSize.height)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - gestureDeleate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]&&[otherGestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]]) {
        return YES;
    }
    
    return NO;
}



@end
