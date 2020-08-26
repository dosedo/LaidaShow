//
//  TSSelectVideoLenRadioView.m
//  ThreeShow
//
//  Created by cgw on 2019/3/20.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSSelectVideoLenRadioView.h"

static NSUInteger const gTabBase = 12666;

@implementation TSSelectVideoLenRadioView

@synthesize selectedIndex = _selectedIndex;

- (id)initWithSelectedIndex:(NSInteger)selectIndex titles:(NSArray *)titles{
    self = [super init];
    if( self ){
        _selectedIndex = selectIndex;
        
        [self createBtnsWithRadioTitles:titles];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    for( NSUInteger i=0; i< self.subviews.count; i++ ){
        
        UIView *radioBtn = self.subviews[i];
        
        CGFloat iw = 60;
        CGFloat ix = iw*i;
        radioBtn.frame =
        CGRectMake(ix, 0, iw, CGRectGetHeight(self.frame));
    }
}

#pragma mark - TouchEvents
- (void)handleRadioBtn:(UIButton*)btn{
    //按钮选中时，则不进行操作
    if( btn.isSelected ) return;
    
    NSInteger idx = (btn.tag-gTabBase-1);
    _selectedIndex = idx;
    [self updateRadionBtnStatusWithSelectedIdx:idx];
    if( self.selectBlock ){
        self.selectBlock(idx);
    }
}

#pragma mark - Private
- (void)createBtnsWithRadioTitles:(NSArray*)titles{
    NSUInteger count = titles.count;
    NSUInteger rvCount = self.subviews.count;
    NSUInteger cnt = (count>rvCount)?count:rvCount;
    for( NSUInteger i =0 ; i<cnt; i++ ){
        NSUInteger tag = 1+i+gTabBase;
        UIButton *btn = [self viewWithTag:tag];
        if( i>=count){
            if( btn ==nil ){
                break;
            }else{
                [btn removeFromSuperview];
            }
        }else{
            if( btn ==nil ){
                btn = [[UIButton alloc] init];
                btn.tag = tag;
                [self addSubview:btn];
            }
            [btn setImage:[UIImage imageNamed:@"radiobutton"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"radiobutton_s"] forState:UIControlStateSelected];
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithWhite:51/255.0 alpha:1] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            btn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
            [btn addTarget:self action:@selector(handleRadioBtn:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        if( i== _selectedIndex ){
            btn.selected = YES;
        }
    }
}

- (void)updateRadionBtnStatusWithSelectedIdx:(NSUInteger)idx{
    for( NSUInteger i=0; i<self.subviews.count; i++ ){
        UIButton *btn = (UIButton*)self.subviews[i];
        if( [btn isKindOfClass:[UIButton class]] ){
            btn.selected = (i==idx);
        }
    }
}

@end
