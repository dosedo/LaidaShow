//
//  TSPhotoCountSelectView.m
//  ThreeShow
//
//  Created by hitomedia on 12/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSPhotoCountSelectView.h"
#import "UIColor+Ext.h"
#import "UIView+LayoutMethods.h"

//产品动画的方向，向左切换，向右切换
typedef NS_ENUM(NSInteger,TSPhotoCountSlideDirection){
    TSPhotoCountSlideDirectionLeft = 0,
    TSPhotoCountSlideDirectionRight
};

static NSInteger const gTagBase   = 100;
static CGFloat   const gItemWidth = 60;

@interface TSPhotoCountSelectView()
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) UIView  *itemView;

@end

@implementation TSPhotoCountSelectView{
    CGFloat _lastTouchX;
    TSPhotoCountSlideDirection _animateDirection;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if( self ){
        UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        [self addGestureRecognizer:gestureRecognizer];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)reloadDatas{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self addSubview:self.itemView];
    [self addSubview:self.titleL];
    [self.itemView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSMutableArray *arr = [NSMutableArray new];
    CGFloat iw = gItemWidth,ix = 0,ih = 40;
    for( NSUInteger i=0; i<self.titles.count; i++){
        UIButton *btn = [UIButton new];
        btn.backgroundColor = [UIColor clearColor];
        [btn addTarget:self action:@selector(handleBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:_titles[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRgb252_199_17] forState:UIControlStateDisabled];
        btn.tag = i+gTagBase;
        [arr addObject:btn];
        [self.itemView addSubview:btn];
        
        ix = i*iw;
        btn.frame = CGRectMake(ix, 0, iw, ih);
        if( _selectedIndex == i ){
            btn.enabled = NO;
        }
    }
    ix = self.width/2 - ((_selectedIndex)*iw + 1/2.0*iw);
    iw = iw*_titles.count;
    
    self.itemView.frame = CGRectMake(ix, self.height-ih, iw, ih);
    CGFloat iy = 10;
    self.titleL.frame = CGRectMake(0, iy, self.width, self.itemView.y-iy);
    _items = arr;
    [self updateItemStateWithSelectIndex:_selectedIndex];
}

#pragma mark - Private

- (NSInteger)getNextImgIndexWithCurrIndex:(NSInteger)currIndex dirction:(TSPhotoCountSlideDirection)direction{
    NSInteger index = currIndex;
    if( currIndex >=0 && self.items.count > currIndex){
        if( direction == TSPhotoCountSlideDirectionLeft ){
            //动画向左，索引应该增大
            index ++;
            if( index >= _items.count ){
                index = _items.count-1;
            }
        }else {
            //动画向右侧，索引应减小
            index--;
            if( index < 0 ){
                index = 0;//_items.count-1;
            }
        }
        
        return index;
    }
    
    return 0;
}

- (void)startAnimate{
    
}

- (void)endAnimate{
    
}

- (void)showItemAtIndex:(NSUInteger)index{
    
    CGRect fr = self.itemView.frame;
    fr.origin.x = self.width/2 - ((index+1/2.0)*gItemWidth);
    
    [UIView animateWithDuration:0.5 animations:^{
        self.itemView.frame = fr;
    }];
    
    _selectedIndex = index;
}

- (void)updateItemStateWithSelectIndex:(NSInteger)si{
    NSUInteger i=0;
    for( UIButton *btn in self.items ){
        btn.enabled = (i!=si);
        
        CGFloat size = 17;
        NSInteger dx = ABS((int)(i-si));
        if( dx >= 2 ){
            size = 12;
        }
        else if( dx >= 1 ){
            size = 14;
        }
        
        btn.titleLabel.font = [UIFont systemFontOfSize:size];
        
        i++;
    }
}

#pragma mark - TouchEvents
- (void)handleBtn:(UIButton*)btn{
    NSUInteger idx = btn.tag -gTagBase;
    if( _selectedIndex == idx ) return;
    
    [self showItemAtIndex:idx];
    [self updateItemStateWithSelectIndex:idx];
}

//滑动手势（里面有手势的不同状态，根据需要进行灵活运用）
- (void)handleGesture:(UIPanGestureRecognizer *)recognizer {
    //UITapGestureRecognizer
    if (recognizer.state == UIGestureRecognizerStateChanged){
        NSLog(@"UIGestureRecognizerStateChanged");
        
    }else if(recognizer.state == UIGestureRecognizerStateEnded){
        NSLog(@"UIGestureRecognizerStateEnded");
        [self startAnimate];
        
        
        CGFloat touchX = [recognizer locationInView:self].x;
        CGFloat touchDisance  = touchX-_lastTouchX;
        
        CGFloat oneImgDistance = 5;
        //滑动的距离 小于5，则不更改图片
        if( ABS(touchDisance) < oneImgDistance ){
            return;
        }
        
        if( touchDisance < 0 ){
            touchDisance = -touchDisance;
            _animateDirection = TSPhotoCountSlideDirectionLeft;
        }else{
            _animateDirection = TSPhotoCountSlideDirectionRight;
        }
        
        //计算应该滚动到某个图片
//        NSInteger scrollImgCount = (NSInteger)(touchDisance/oneImgDistance);
//        for( NSUInteger i=0; i<scrollImgCount; i++ ){
        _selectedIndex = [self getNextImgIndexWithCurrIndex:_selectedIndex dirction:_animateDirection];
//        }
        
        [self showItemAtIndex:_selectedIndex];
        [self updateItemStateWithSelectIndex:_selectedIndex];
        //        [self updateImg];
        
        _lastTouchX = touchX;
        
    }else if(recognizer.state == UIGestureRecognizerStateBegan){
        NSLog(@"UIGestureRecognizerStateBegan");
        
        _lastTouchX = [recognizer locationInView:self].x;
        [self endAnimate];
        
    }else if(recognizer.state == UIGestureRecognizerStateCancelled){
        NSLog(@"UIGestureRecognizerStateCancelled");
    }else if(recognizer.state == UIGestureRecognizerStateFailed){
        NSLog(@"UIGestureRecognizerStateFailed");
    }else if(recognizer.state == UIGestureRecognizerStatePossible){
        NSLog(@"UIGestureRecognizerStatePossible");
    }else if(recognizer.state == UIGestureRecognizerStateRecognized){
        NSLog(@"UIGestureRecognizerStateRecognized");
        
    }
}

#pragma mark - Propertys

- (UIView *)itemView {
    if( !_itemView ){
        _itemView = [[UIView alloc] init];

        [self addSubview:_itemView];
    }
    return _itemView;
}

- (UILabel *)titleL {
    if( !_titleL ){
        _titleL = [[UILabel alloc] init];
        _titleL.textColor = [UIColor whiteColor];
        _titleL.font = [UIFont systemFontOfSize:15];
        _titleL.textAlignment = NSTextAlignmentCenter;
        _titleL.text = NSLocalizedString(@"TaskPhotoShotNumber", nil);//@"拍摄张数";
        [self addSubview:_titleL];
    }
    return _titleL;
}

@end


