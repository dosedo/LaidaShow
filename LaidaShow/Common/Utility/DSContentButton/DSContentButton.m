//
//  DSContentButton.m
//  DSComponents
//
//  Created by cgw on 2019/3/14.
//  Copyright © 2019 bill. All rights reserved.
//

#import "DSContentButton.h"

@implementation DSContentButton{
    UIImageView *_backgroudImgView;
    CGFloat _cornerRadius;
    CGFloat _borderWidth;
    UIColor *_borderColor;
    BOOL _needCornerRadius;
}

@synthesize contentView = _contentView;

- (id)initWithCornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor*)borderColor{
    self = [super init];
    if( self ){
        _needCornerRadius = YES;
        _cornerRadius = cornerRadius;
        _borderColor = borderColor;
        _borderWidth = borderWidth;
    }
    return self;
}

#pragma mark - UIView Methods

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if( _backgroudImgView && CGRectEqualToRect(_contentRect, CGRectZero)==NO ){
        _backgroudImgView.frame = _contentRect;
    }
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    if( CGRectEqualToRect(_titleRect, CGRectZero) ){
        return [super titleRectForContentRect:contentRect];
    }
    return CGRectMake(contentRect.origin.x+_titleRect.origin.x,
                      contentRect.origin.y+_titleRect.origin.y,
                      _titleRect.size.width, _titleRect.size.height);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    if( CGRectEqualToRect(_imageRect, CGRectZero) ){
        return [super imageRectForContentRect:contentRect];
    }
    return CGRectMake(contentRect.origin.x+_imageRect.origin.x,
                      contentRect.origin.y+_imageRect.origin.y,
                      _imageRect.size.width, _imageRect.size.height);
}

- (CGRect)contentRectForBounds:(CGRect)bounds{

    if( CGRectEqualToRect(_contentRect, CGRectZero) ){
        return [super contentRectForBounds:bounds];
    }
    return _contentRect;
}

- (void)didAddSubview:(UIView *)subview{
    //每当有新的视图添加，则将背景视图移至最底层
    if( _contentView && [subview isEqual:_contentView]==NO ){
        [self sendSubviewToBack:_contentView];
    }
    
    if( [subview isKindOfClass:[UIImageView class]] ){
        if( [subview isEqual:self.imageView] ==NO ){
            _backgroudImgView = (UIImageView*)subview;
            
            if( _needCornerRadius ){
                _backgroudImgView.layer.masksToBounds = YES;
                _backgroudImgView.layer.cornerRadius = _cornerRadius;
                _backgroudImgView.layer.borderWidth = _borderWidth;
                if( _borderColor ){
                    _backgroudImgView.layer.borderColor = _borderColor.CGColor;
                }
            }
        }
    }
}

#pragma mark - getter setter
- (void)setContentRect:(CGRect)contentRect{
    _contentRect = contentRect;
    
    if( _contentView ){
        _contentView.frame = contentRect;
    }
}

- (UIView *)contentView {
    if( !_contentView ){
        _contentView = [UIView new];
        _contentView.frame = _contentRect;
        _contentView.userInteractionEnabled = NO; 
        [self addSubview:_contentView];
        
        if( _needCornerRadius ){
            _contentView.layer.masksToBounds = YES;
            _contentView.layer.cornerRadius = _cornerRadius;
            _contentView.layer.borderWidth = _borderWidth;
            if( _borderColor ){
                _contentView.layer.borderColor = _borderColor.CGColor;
            }
        }
    }
    return _contentView;
}

@end
