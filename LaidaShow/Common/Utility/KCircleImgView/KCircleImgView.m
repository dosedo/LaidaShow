//
//  KCircleImgView.m
//  HopeHelpClient
//
//  Created by 端倪 on 16/2/17.
//  Copyright © 2016年 deepai. All rights reserved.
//

#import "KCircleImgView.h"

@interface KCircleImgView()



@end
@implementation KCircleImgView

-(void)layoutSubviews{

//    CGSize size = self.frame.size;
//    self.imgView.frame = CGRectMake((size.width-_imgRadius*2)/2, (size.height-_imgRadius*2)/2, _imgRadius*2, _imgRadius*2);
//    CGFloat cr = _cornerRadius * _imgRadius/(self.frame.size.width/2);
//    self.imgView.layer.cornerRadius = cr;
    
    [self configImgView];
}

-(id)init{
    self = [super init];
    if( self ){
        [self configSelf];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if( self ){
    
        [self configSelf];
    }
    return self;
}

#pragma mark - Private

-(void)configSelf{
    _borderColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = _cornerRadius;
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = _borderColor.CGColor;
    self.backgroundColor = [UIColor colorWithRed:68/255.0 green:68/255.0 blue:68/255.0 alpha:1.0];
    
    self.imgView.layer.masksToBounds = YES;
}


-(void)configImgView{
    CGSize size = self.frame.size;
    self.imgView.frame = CGRectMake((size.width-_imgRadius*2)/2, (size.height-_imgRadius*2)/2, _imgRadius*2, _imgRadius*2);
    CGFloat cr = _cornerRadius * _imgRadius/(self.frame.size.width/2);
    self.imgView.layer.cornerRadius = cr;
    self.layer.borderWidth = size.width/2 - _imgRadius;
}

#pragma mark - TouchEvents
-(void)handleImgView{
    if( self.delegate && [self.delegate respondsToSelector:@selector(clickedCircleImgView:)] ){
        [_delegate clickedCircleImgView:self];
    }
}

#pragma mark - Property

-(UIImageView*)imgView{
    if( !_imgView ){
        _imgView = [[UIImageView alloc] init];
        _imgView.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:_imgView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImgView)];
        if( self.userInteractionEnabled == NO ){
            self.userInteractionEnabled = YES;
        }
        _imgView.userInteractionEnabled = YES;
        [self addGestureRecognizer:tap];
        [_imgView addGestureRecognizer:tap];
    }
    return _imgView;
}

-(void)setImage:(UIImage *)image{
    if( image && [image isKindOfClass:[UIImage class]] ){
        _image = image;
        self.imgView.image = image;
    }
}

-(void)setImgRadius:(CGFloat)imgRadius{
    _imgRadius = imgRadius;
    
    [self configImgView];
}
-(void)setBorderColor:(UIColor *)borderColor{
    _borderColor = borderColor;
    self.layer.borderColor = borderColor.CGColor;
}

-(void)setCornerRadius:(CGFloat)cornerRadius{
    _cornerRadius = cornerRadius;
    [self configImgView];
    self.layer.cornerRadius = _cornerRadius;
    
    if( self.frame.size.width > 0 ){
        CGFloat cr = _cornerRadius * _imgRadius/(self.frame.size.width/2);
        self.imgView.layer.cornerRadius = cr;
    }
}

@end
