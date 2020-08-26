//
//  PauseOrPlayView.m
//  SBPlayer
//
//  Created by sycf_ios on 2017/4/11.
//  Copyright © 2017年 shibiao. All rights reserved.
//

#import "SBPauseOrPlayView.h"
@interface SBPauseOrPlayView ()
@property (nonatomic, strong) UIButton *bgBtn;
@end

@implementation SBPauseOrPlayView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if( self ){
        UIButton *bgBtn =[UIButton new];
        _bgBtn = bgBtn;
        bgBtn.frame = self.bounds;
        [bgBtn addTarget:self action:@selector(handleBgBtn) forControlEvents:UIControlEventTouchUpInside];
        bgBtn.backgroundColor = [UIColor clearColor];
        [self addSubview:bgBtn];
        
        self.imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.imageBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [self.imageBtn setShowsTouchWhenHighlighted:YES];
        [self.imageBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
        [self.imageBtn addTarget:self action:@selector(handleImageTapAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.imageBtn];
        //    [self.imageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        //        make.edges.mas_equalTo(self);
        //    }];
        CGFloat wh = 50;CGSize size = self.frame.size;
        self.imageBtn.frame = CGRectMake((size.width-wh)/2, (size.height-wh)/2, wh, wh);
        self.imageBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        self.imageBtn.layer.masksToBounds = YES;
        self.imageBtn.layer.cornerRadius = wh/2;
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat wh = 50;CGSize size = self.frame.size;
    self.imageBtn.frame = CGRectMake((size.width-wh)/2, (size.height-wh)/2, wh, wh);
    _bgBtn.frame = self.bounds;
}

- (void)setState:(BOOL)state{
    _state = state;
    self.imageBtn.selected = state;
}

//- (void)drawRect:(CGRect)rect {
//
//
//}
-(void)handleImageTapAction:(UIButton *)button{
    button.selected = !button.selected;
    _state = button.isSelected ? YES : NO;
    if ([self.delegate respondsToSelector:@selector(pauseOrPlayView:withState:)]) {
        [self.delegate pauseOrPlayView:self withState:_state];
    }
}

- (void)handleBgBtn{
    if(_delegate && [_delegate respondsToSelector:@selector(hideOrShowControlView:)]){
        [_delegate hideOrShowControlView:self];
    }
}

@end
