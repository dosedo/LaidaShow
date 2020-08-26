//
//  TSCancleLoadingView.m
//  ThreeShow
//
//  Created by cgw on 2019/3/15.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSCancleLoadingView.h"

@interface TSCancleLoadingView()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicator;

@end

@implementation TSCancleLoadingView{
    UIView *_bgView;
    TSCancleLoadingViewCancleBlock _cancleBlock;
}

+ (TSCancleLoadingView*)shareView{
    static TSCancleLoadingView *sv = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sv = [TSCancleLoadingView new];
        sv.frame = CGRectMake(0, 0, 0, 0);
    });
    
    return sv;
}

+ (void)showWithCancleBlock:(TSCancleLoadingViewCancleBlock)cancleBlock{
    [self hide];
    [TSCancleLoadingView shareView]->_cancleBlock = cancleBlock;
    [[UIApplication sharedApplication].keyWindow addSubview:[TSCancleLoadingView shareView]];
}

+ (void)hide{
    TSCancleLoadingView *view = [TSCancleLoadingView shareView];
    [view.activityIndicator stopAnimating];
    view->_cancleBlock  = nil;
    [view removeFromSuperview];
}

+ (CGSize)shareSize{
    return CGSizeMake(100, 100);
}

- (UIView*)bgView{
    if( !_bgView ){
        
        _bgView = [UIView new];
        _bgView.backgroundColor = [UIColor whiteColor];
        CGSize size = [[self class] shareSize];
        _bgView.frame = CGRectMake(0, 0, size.width, size.height);

        UIBlurEffect * blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView * effe = [[UIVisualEffectView alloc]initWithEffect:blur];
        effe.alpha = 0.97;
        effe.frame = _bgView.bounds;
        [self addSubview:effe];
        
        [effe addSubview:_bgView];
    }
    
    return _bgView;
}

- (UIActivityIndicatorView *)activityIndicator{
    if( !_activityIndicator ){
        _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
        //设置小菊花的frame
        
        _activityIndicator.frame= CGRectMake(([[self class] shareSize].width-40)/2, 20, 40, 40);
        //设置小菊花颜色
        _activityIndicator.color = [UIColor redColor];
        //设置背景颜色
        _activityIndicator.backgroundColor = [UIColor clearColor];
        //刚进入这个界面会显示控件，并且停止旋转也会显示，只是没有在转动而已，没有设置或者设置为YES的时候，刚进入页面不会显示
        _activityIndicator.hidesWhenStopped = NO;
        
        [self.bgView addSubview:_activityIndicator];
    }
    
    return _activityIndicator;
}

@end
