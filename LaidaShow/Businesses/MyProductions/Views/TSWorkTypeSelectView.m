//
//  TSWorkTypeSelectView.m
//  ThreeShow
//
//  Created by cgw on 2019/7/15.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSWorkTypeSelectView.h"
#import "UIColor+Ext.h"
#import "UIView+LayoutMethods.h"

@implementation TSWorkTypeSelectView{
    
    UIView *_listView;
    UIButton *_listBgView;
}

- (id)initWithFrame:(CGRect)fr inView:(UIView *)inView{
    self = [super initWithFrame:fr];
    if( self ){
        
        _selectedIndex = 0;
        
        [inView addSubview:self];
        
        [self setTitleColor:[UIColor colorWithRgb51] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self setImage:[UIImage imageNamed:@"arrow_down_51_19"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"arrow_up_51_19"] forState:UIControlStateSelected];
        [self addTarget:self action:@selector(handleSelf) forControlEvents:UIControlEventTouchUpInside];
        
        _listBgView = [UIButton new];
        _listBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        _listBgView.frame = inView.bounds;
        [_listBgView addTarget:self action:@selector(hideList) forControlEvents:UIControlEventTouchUpInside];
        
        _listView = [UIView new];
        _listView.backgroundColor = [UIColor whiteColor];
        _listView.frame = CGRectMake(0, CGRectGetMinY(fr)-88, SCREEN_WIDTH, 88);
        [_listBgView addSubview:_listView];
        

        [self updateTitleWithSelectIndex:_selectedIndex];
        
        NSArray *titles = @[NSLocalizedString(@"三维作品", nil),NSLocalizedString(@"视频采编", nil)];
        for( NSUInteger i=0; i<2; i++ ){
            UIButton *btn = [UIButton new];
            [btn setBackgroundImage:UIColorAsImage([UIColor colorWithWhite:0.95 alpha:1], CGSizeMake(3, 3)) forState:UIControlStateHighlighted];
            CGFloat ix = 0;
            btn.frame = CGRectMake(ix, i*44, _listView.width-ix, 44);
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [btn setTitleColor:[UIColor colorWithRgb51] forState:UIControlStateNormal];
//            [btn setImage:[UIImage imageNamed:@"edit_check_blue"] forState:UIControlStateSelected];
//            btn.selected = (i==_selectedIndex);
            btn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
            [btn addTarget:self action:@selector(handleBtn:) forControlEvents:UIControlEventTouchUpInside];
            [_listView addSubview:btn];
            btn.tag = i;
        }
    }
    return self;
}

- (void)handleSelf{
    if( self.selected ){
        [self hideList];
    }else{
        [self showList];
    }
}

- (void)handleBtn:(UIButton*)btn{
    
//    if( btn.isSelected ) return;
    
    [self hideList];
    
    if( _selectedIndex != btn.tag){
        _selectedIndex = btn.tag;
        
        [self updateTitleWithSelectIndex:_selectedIndex];
        
        if( _selectBlock ){
            _selectBlock(_selectedIndex);
        }
        
//        btn.selected = !btn.isSelected;
    }
}

- (void)hideList{
    
    [UIView animateWithDuration:0.2 animations:^{
        _listView.frame = CGRectMake(0, CGRectGetMinY(self.frame)-88, SCREEN_WIDTH, 88);
    } completion:^(BOOL finished) {
        [_listBgView removeFromSuperview];
    }];
}

- (void)showList{
    [self.superview addSubview:_listBgView];
    [UIView animateWithDuration:0.2 animations:^{
        _listView.frame = CGRectMake(0, CGRectGetMinY(self.frame), SCREEN_WIDTH, 88);
    }];
}

- (void)updateTitleWithSelectIndex:(NSInteger)idx{
    if( idx == 1 ){
        [self setTitle:NSLocalizedString(@"视频采编", nil) forState:UIControlStateNormal];
    }else{
        [self setTitle:NSLocalizedString(@"三维作品", nil) forState:UIControlStateNormal];
    }
}

#pragma mark - qita
- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    CGFloat toEdge = 10;
    return CGRectMake(toEdge, 0, 180, contentRect.size.height);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    CGFloat toEdge = 10;
    CGSize size = [UIImage imageNamed:@"arrow_up_51_19"].size;
    return CGRectMake(contentRect.size.width-toEdge-toEdge, contentRect.size.height/2-size.height/2, size.width, size.height);
}

@end
