//
//  TSDragAreaView.m
//  ThreeShow
//
//  Created by hitomedia on 14/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSDragAreaView.h"
#import "UIView+LayoutMethods.h"

@interface TSDragAreaView()
@property (nonatomic, strong) UIView *pointA;
@property (nonatomic, strong) UIView *pointB;
@property (nonatomic, strong) UIView *pointC;
@property (nonatomic, strong) UIView *pointD;
@property (nonatomic, strong) UIView *lineAB1;
@property (nonatomic, strong) UIView *lineAB2;
@property (nonatomic, strong) UIView *lineAD1;
@property (nonatomic, strong) UIView *LineAD2;

@property (nonatomic, strong) UIView *lineAB;
@property (nonatomic, strong) UIView *lineBC;
@property (nonatomic, strong) UIView *lineCD;
@property (nonatomic, strong) UIView *LineDA;
@end

@implementation TSDragAreaView

- (id)initWithFrame:(CGRect)frame pointRadius:(CGFloat)radius{
    self = [super initWithFrame:frame];
    if( self ){
        _pointRadius = radius;
        
        _pointA = [self getPointView];
        _pointB = [self getPointView];
        _pointC = [self getPointView];
        _pointD = [self getPointView];
        
        _lineAB = [self getBorderLine];
        _lineBC = [self getBorderLine];
        _lineCD = [self getBorderLine];
        _LineDA = [self getBorderLine];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat iw = self.frame.size.width;
    CGFloat ih = self.frame.size.height;
    
    _pointA.center = CGPointZero;
    _pointB.center = CGPointMake(iw, 0);
    _pointC.center = CGPointMake(iw, ih);
    _pointD.center = CGPointMake(0, ih);
    
    CGFloat lineW = 4;
    _lineAB.frame = CGRectMake(0, 0-lineW/2, iw, lineW);
    _lineBC.frame = CGRectMake(iw-lineW/2, 0, lineW, ih);
    _lineCD.frame = CGRectMake(0, ih-lineW/2, iw, lineW);
    _LineDA.frame = CGRectMake(0-lineW/2, 0, lineW, ih);
}

#pragma mark - Private
- (UIView*)getPointView{
    UIView *point = [UIView new];
    point.backgroundColor = [UIColor whiteColor];
    point.layer.masksToBounds = YES;
    point.layer.cornerRadius = self.pointRadius;
    point.frame = CGRectMake(0, 0, _pointRadius*2, _pointRadius*2);
    [self addSubview:point];
    return point;
}

- (UIView*)getBorderLine{
    UIView *line = [UIView new];
    line.backgroundColor = [UIColor whiteColor];
    [self addSubview:line];
    return line;
}

@end
