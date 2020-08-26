//
//  TSGestureImageView.m
//  ThreeShow
//
//  Created by hitomedia on 15/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSGestureImageView.h"
#import "UIColor+Ext.h"
#import "UIView+LayoutMethods.h"

@implementation TSGestureImageView{
    CGFloat pinScal;
    UIButton *_closeBtn;
    UIButton *_dragBtn;
//    CGSize _lastSize;
    CGPoint beginDragPoint;
    CGPoint beginClosePoint;
    
    
    //仅仅为了计算坐标
    CGPoint defaultDragPoint;
    CGPoint defaultClosePoint;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if( self ){
        pinScal = 1;
        
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapSelf = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSelf)];
        [self addGestureRecognizer:tapSelf];
        
        _imgView = [UIImageView new];
        _imgView.layer.masksToBounds = YES;
        _imgView.layer.borderColor = [UIColor colorWithRgb_0_151_216].CGColor;
        _imgView.layer.borderWidth = 1;
        [self addSubview:_imgView];
        
        CGFloat wh = 20;
        _closeBtn = [UIButton new];
        _closeBtn.layer.masksToBounds = YES;
        _closeBtn.layer.cornerRadius = wh/2;
        [_closeBtn setImage:[UIImage imageNamed:@"edit_addimg_close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(handleClose) forControlEvents:UIControlEventTouchUpInside];
        _closeBtn.backgroundColor = [UIColor colorWithRgb_0_151_216];
        [self addSubview:_closeBtn];
        
        _dragBtn = [UIButton new];
        _dragBtn.backgroundColor = [UIColor colorWithRgb_0_151_216];
        _dragBtn.layer.masksToBounds = YES;
        _dragBtn.layer.cornerRadius = wh/2;
        [_dragBtn setImage:[UIImage imageNamed:@"edit_addimg_drag"] forState:UIControlStateNormal];
        //拖拽
        UIPanGestureRecognizer *panGesture=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(doBtnPanGesture:)];
        [_dragBtn addGestureRecognizer:panGesture];
        //暂时隐藏
//        [self addSubview:_dragBtn];
        
//        CGSize size = CGSizeMake(260, 260);
//        CGFloat btnWH = 20;
//        _closeBtn.frame = CGRectMake(10, 64, btnWH, btnWH);
//        _imgView.frame = CGRectMake(_closeBtn.center.x, _closeBtn.center.y, size.width, size.height);
//        _dragBtn.frame = CGRectMake(_imgView.right-btnWH/2, _imgView.bottom-btnWH/2, btnWH, btnWH);
        [self resetViews];
        
        [self imgTransfrom];
        
//        beginDragPoint = _dragBtn.center;
//        beginClosePoint = _closeBtn.center;
//
//        //为了计算坐标
//        defaultDragPoint = CGPointMake(_imgView.width, _imgView.height);
//        defaultClosePoint = CGPointZero;
    }
    return self;
}

- (void)resetViews{
    
    CGSize size = CGSizeMake(260, 260);
    
    UIImage *img = self.imgView.image;
    if( img ){
        if( size.width/img.size.width > size.height /img.size.height ){
            //按高缩放
            size.width = size.height *(img.size.width/img.size.height);
        }else{
            size.height = size.width *(img.size.height/img.size.width);
        }
    }
    CGFloat btnWH = 20;
    _closeBtn.frame = CGRectMake(10, 64, btnWH, btnWH);
    _imgView.frame = CGRectMake(_closeBtn.center.x, _closeBtn.center.y, size.width, size.height);
    _dragBtn.frame = CGRectMake(_imgView.right-btnWH/2, _imgView.bottom-btnWH/2, btnWH, btnWH);
    _imgView.transform = CGAffineTransformIdentity;
    
    beginDragPoint = _dragBtn.center;
    beginClosePoint = _closeBtn.center;
    
    //为了计算坐标
    defaultDragPoint = CGPointMake(_imgView.width, _imgView.height);
    defaultClosePoint = CGPointZero;
    
    _imgView.hidden = NO;
    
    [self updateBtnIsHidden:NO];
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

#pragma mark - Private

- (void)updateBtnIsHidden:(BOOL)hidden{
    if( _closeBtn.isHidden != hidden ){
        _closeBtn.hidden = hidden;
        _dragBtn.hidden = hidden;
        self.imgView.layer.masksToBounds = !hidden;
        self.imgView.layer.borderWidth = hidden?0:1;
    }
}

- (void)updateBtnCenter{
    //设置按钮的圆心
    CGPoint closeCenter = [self convertPoint:defaultClosePoint fromView:self.imgView];
    _dragBtn.center = [self convertPoint:defaultDragPoint fromView:self.imgView];
    _closeBtn.center = closeCenter;
}

#pragma mark - Btn手势
- (void)doBtnPanGesture:(UIPanGestureRecognizer *)pan{
    
    if( pan.state == UIGestureRecognizerStateBegan ){
        beginDragPoint = _dragBtn.center;
        beginClosePoint = _closeBtn.center;
    }
    
    UIView *aView=pan.view;
    CGPoint transform=[pan translationInView:[aView superview]];
    
    [aView setCenter:CGPointMake([aView center].x+transform.x, [aView center].y+transform.y)];
    
    [_closeBtn setCenter:CGPointMake([_closeBtn center].x - transform.x, [_closeBtn center].y - transform.y)];
    [pan setTranslation:CGPointZero inView:[aView superview]];
    
    CGFloat scaleX =   (_dragBtn.center.x-_closeBtn.center.x)/(beginDragPoint.x-beginClosePoint.x);
    
    CGFloat scaleY =  (_dragBtn.center.y-_closeBtn.center.y)/(beginDragPoint.y-beginClosePoint.y);
    CGAffineTransform current= CGAffineTransformScale(self.imgView.transform,scaleX, scaleY);
    self.imgView.transform = current;
    
    beginClosePoint = _closeBtn.center;
    beginDragPoint = _dragBtn.center;
}


- (void)handleClose{
    [self updateBtnIsHidden:YES];
    self.imgView.hidden = YES;
}

- (void)tapSelf{
    
    [self updateBtnIsHidden:YES];
}

#pragma mark - ImgView手势

- (void)imgTransfrom{

    UIImageView *personImgView = self.imgView;
    //捏合
    UIPinchGestureRecognizer *pinchGesture=[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(doPinchGesture:)];
    [personImgView addGestureRecognizer:pinchGesture];
    //拖拽
    UIPanGestureRecognizer *panGesture=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(doPanGesture:)];
    [personImgView addGestureRecognizer:panGesture];
    //默认为关
    personImgView.userInteractionEnabled=YES;
    personImgView.multipleTouchEnabled = YES;
    
    
    //旋转手势
    UIRotationGestureRecognizer *rotateGes = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateView:)];
    [personImgView addGestureRecognizer:rotateGes];
    
    //单击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImgViewGes)];
    [personImgView addGestureRecognizer:tap];
    
}

- (void)tapImgViewGes{
    [self updateBtnIsHidden:NO];
}

//拖拽
-(void)doPanGesture:(UIPanGestureRecognizer *)pan{
    
    [self updateBtnIsHidden:NO];
    
    UIView *aView=pan.view;
    CGPoint transform=[pan translationInView:[aView superview]];
    [aView setCenter:CGPointMake([aView center].x+transform.x, [aView center].y+transform.y)];
    [_closeBtn setCenter:CGPointMake([_closeBtn center].x+transform.x, [_closeBtn center].y+transform.y)];
    [_dragBtn setCenter:CGPointMake([_dragBtn center].x+transform.x, [_dragBtn center].y+transform.y)];
    //设置要改变的视图,并开始移动
    [pan setTranslation:CGPointZero inView:[aView superview]];
}
//捏合
-(void)doPinchGesture:(UIPinchGestureRecognizer *)pinch{
    
    [self updateBtnIsHidden:NO];
    
    UIView *aView=pinch.view;
    if ([pinch state]==UIGestureRecognizerStateEnded) {
        
        pinScal = 1;
        return;
    }
    CGFloat scale1=1.0-(pinScal -[pinch scale]);
    CGAffineTransform current=CGAffineTransformScale(aView.transform,scale1, scale1);
    [aView setTransform:current];
    pinScal=[pinch scale];
    
    //设置按钮的圆心
     [self updateBtnCenter];
}

// 处理旋转手势
- (void) rotateView:(UIRotationGestureRecognizer *)rotationGestureRecognizer
{
    
    [self updateBtnIsHidden:NO];
    
    NSLog(@"rotateValue=%f",rotationGestureRecognizer.rotation);
    UIView *view = rotationGestureRecognizer.view;
    if (rotationGestureRecognizer.state == UIGestureRecognizerStateBegan || rotationGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        view.transform = CGAffineTransformRotate(view.transform, rotationGestureRecognizer.rotation);
        [rotationGestureRecognizer setRotation:0];
        
        [self updateBtnCenter];
    }
}

@end
