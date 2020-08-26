//
//  TSEditNaviView.m
//  ThreeShow
//
//  Created by hitomedia on 14/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSEditNaviView.h"
#import "UIColor+Ext.h"

@interface TSEditNaviView()

@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, strong) UILabel  *titleL;

@end

@implementation TSEditNaviView

- (id)initWithTitle:(NSString *)title target:(id)target cancleSel:(SEL)cancleSel sureSel:(SEL)sureSel{
    
    self = [super initWithFrame:CGRectZero];
    if( self ){
        self.titleL.text = title;
        if( target ){
            if( [target respondsToSelector:cancleSel] ){
                [self.closeBtn addTarget:target action:cancleSel forControlEvents:UIControlEventTouchUpInside];
            }
            
            if( [target respondsToSelector:sureSel] ){
                [self.sureBtn addTarget:target action:sureSel forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat iw = 60,ih = 45+15;//self.frame.size.height;
    self.closeBtn.frame = CGRectMake(0, 0, iw, ih);
    self.sureBtn.frame = CGRectMake(CGRectGetWidth(self.frame)-iw, 0, iw, ih);
    
    iw = 260;
    self.titleL.frame = CGRectMake((CGRectGetWidth(self.frame)-iw)/2, 0, iw, ih);
}

#pragma mark - Propertys
- (UIButton *)closeBtn {
    if( !_closeBtn ){
        _closeBtn = [[UIButton alloc] init];
        [_closeBtn setImage:[UIImage imageNamed:@"edit_close_153"] forState:UIControlStateNormal];
        
        [self addSubview:_closeBtn];
    }
    return _closeBtn;
}

- (UILabel *)titleL {
    if( !_titleL ){
        _titleL = [[UILabel alloc] init];
        _titleL.font = [UIFont systemFontOfSize:16];
        _titleL.textColor = [UIColor colorWithRgb51];
        _titleL.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleL];
    }
    return _titleL;
}

- (UIButton *)sureBtn {
    if( !_sureBtn ){
        _sureBtn = [[UIButton alloc] init];
        [_sureBtn setImage:[UIImage imageNamed:@"edit_check_blue"] forState:UIControlStateNormal];
        
        [self addSubview:_sureBtn];
    }
    return _sureBtn;
}

@end

@implementation TSFilterVideoNaviView{
    NSArray* _titles;
}

- (id)initWithTarget:(id)target cancleSel:(SEL)cancleSel sureSel:(SEL)sureSel titles:(NSArray *)titles handleTitleSel:(SEL)handleTitleSel{
    self = [super initWithTitle:nil target:target cancleSel:cancleSel sureSel:sureSel];
    if( self ){
        
        _titles = titles;
        //移除原有的标题
        [self.titleL removeFromSuperview];
        
        //创建新的标题按钮
        for( NSUInteger i=0; i<titles.count; i++ ){
            UIButton *btn = [UIButton new];
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithRgb51] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithRgb_0_151_216] forState:UIControlStateSelected];
            btn.titleLabel.font = [UIFont systemFontOfSize:16];
            if( target && [target respondsToSelector:handleTitleSel] ){
                [btn addTarget:target action:handleTitleSel forControlEvents:UIControlEventTouchUpInside];
            }
            btn.tag = 100+i;
            [self addSubview:btn];
        }
    }
    return self;
}

- (UIButton*)buttonWithIndex:(NSInteger)index{
    UIButton *btn = [self viewWithTag:index+100];
    if( [btn isKindOfClass:[UIButton class]] ){
        return btn;
    }
    return nil;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if( _titles.count ==0 ) return;
    
    CGSize size = self.frame.size;
    CGFloat iw = 70;
    CGFloat maxW = ( size.width-CGRectGetMaxX(self.closeBtn.frame)*2 )/_titles.count;
    if( iw > maxW ) iw = maxW;
    
    CGFloat totalW = iw * _titles.count;
    CGFloat ix = 0;
    for( NSInteger i=0; i<_titles.count; i++ ){
        ix = size.width/2 - totalW/2 + (iw*i);
        [self viewWithTag:100+i].frame = CGRectMake(ix, 0, iw, 60);
    }
}

@end
