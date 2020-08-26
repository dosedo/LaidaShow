//
//  TSWorkReleaseView.m
//  ThreeShow
//
//  Created by hitomedia on 17/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSWorkReleaseView.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+Ext.h"

#ifndef TSWORKRELEASEView
#define TSWORKRELEASEView

#define XWWorkReleaseViewCancleBtnTag (987654321)

#endif

static NSUInteger const gTagBase = 100;
static CGFloat    const gAnimateTimeLen = 0.3; //动画时间

@interface TSWorkReleaseViewBtn : UIButton
@end

@interface TSWorkReleaseView()
@property (nonatomic, strong) UIButton *bgBtn;
@property (nonatomic, copy) void (^handleIndexBlock)(NSInteger,BOOL,BOOL);
@end

@implementation TSWorkReleaseView


+ (TSWorkReleaseView *)shareWorkReleaseView {
    static TSWorkReleaseView *rv = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rv = [TSWorkReleaseView new];
        [rv initViews];
        
    });
    
    return rv;
}

+ (void)showWithHandleIndexBlock:(void (^)(NSInteger,BOOL,BOOL))handleIndexBlock{
    [[TSWorkReleaseView shareWorkReleaseView] showWithTitles:nil handleIndexBlock:handleIndexBlock];
}

#pragma mark - TouchEvents
- (void)handleBgBtn{
    [self hide];
}

- (void)handleBtn:(UIButton*)btn{
    if( btn.tag == 2+gTagBase){
        [self hide];
        //发布
        UIButton *saveBtn = (UIButton*)[self viewWithTag:0+gTagBase];
        UIButton *seeBtn = (UIButton*)[self viewWithTag:1+gTagBase];
        
        if( self.handleIndexBlock ){
            self.handleIndexBlock(btn.tag-gTagBase,saveBtn.isSelected,seeBtn.isSelected);
        }
    }else{
        btn.selected = !btn.isSelected;
    }
    
    
    
//    if( btn.tag != XWWorkReleaseViewCancleBtnTag ){
//
//        if( self.handleIndexBlock ){
//            self.handleIndexBlock(btn.tag-gTagBase);
//        }
//    }
}

#pragma mark - Private

- (void)hide{
    [UIView animateWithDuration:gAnimateTimeLen animations:^{
        self.center = CGPointMake(self.center.x, (SCREEN_HEIGHT+self.height/2));
    } completion:^(BOOL finished) {
        [_bgBtn removeFromSuperview];
    }];
}

- (void)showWithTitles:(NSArray*)titles handleIndexBlock:(void (^)(NSInteger,BOOL,BOOL))handleIndexBlock{
    self.handleIndexBlock = handleIndexBlock;
//    self.titles = titles;
    
    [[UIApplication sharedApplication].keyWindow addSubview:_bgBtn];
    [UIView animateWithDuration:gAnimateTimeLen animations:^{
        self.center = CGPointMake(self.center.x, (SCREEN_HEIGHT-self.height/2));
    } completion:^(BOOL finished) {
        
    }];
}

- (void)initViews{
    _bgBtn = [UIButton new];
    _bgBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    _bgBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [_bgBtn addTarget:self action:@selector(handleBgBtn) forControlEvents:UIControlEventTouchUpInside];
    [_bgBtn addSubview:self];
    
    self.backgroundColor = [UIColor clearColor];

    [self createItemsWithTitles:@[NSLocalizedString(@"ReleaseSaveToLocal", nil),NSLocalizedString(@"ReleaseOnlyMeToSee", nil)]];
}

- (void)createItemsWithTitles:(NSArray*)titles {
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat ih = 44;
    for( NSUInteger i=0; i<titles.count; i++ ){
        CGFloat iy = i*ih;
        CGRect fr = CGRectMake(0, iy, SCREEN_WIDTH, ih);
        UIColor *color = nil;
//        if( i== 0){
//            //最上面一个是蓝色
//            color = [UIColor colorWithRgb_0_151_216];
//
//        }else{
            color = [UIColor colorWithRgb51];
//        }
        UIButton *btn =
        [self getBtnWithTitle:titles[i] tag:i+gTagBase textColor:color fr:fr needBottomLine:YES];
        if( i==1){
            btn.selected = YES;
        }
    }
    
    if( titles.count ){
        //添加发布按钮
        CGFloat iy = titles.count *ih;
        CGRect fr = CGRectMake(0, iy, SCREEN_WIDTH, ih+10);
        UIButton *cancleBtn = [self releaseBtn];
        cancleBtn.frame = fr;
        cancleBtn.tag = 2+gTagBase;
//        [self getBtnWithTitle:@"发布" tag:0 textColor:[UIColor colorWithRgb51] fr:fr needBottomLine:NO];
        ih = cancleBtn.bottom + BOTTOM_NOT_SAVE_HEIGHT;
        self.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, ih);
    }
}

- (UIButton *)releaseBtn {
//    if( !_releaseBtn ){
    UIButton *
        _releaseBtn = [[UIButton alloc] init];
        [_releaseBtn setTitle:NSLocalizedString(@"ReleaseGotoPublish", nil) forState:UIControlStateNormal];
        [_releaseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _releaseBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [_releaseBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_blue"] forState:UIControlStateNormal];
        [_releaseBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_blue_hi"] forState:UIControlStateHighlighted];
        [_releaseBtn addTarget:self action:@selector(handleBtn:) forControlEvents:UIControlEventTouchUpInside];
//        CGFloat ih = 44;
//        _releaseBtn.frame = CGRectMake(0, SCREEN_HEIGHT-ih-BOTTOM_NOT_SAVE_HEIGHT, SCREEN_WIDTH, ih);
        [self addSubview:_releaseBtn];
//    }
    return _releaseBtn;
}

- (UIButton*)getBtnWithTitle:(NSString*)title tag:(NSUInteger)tag textColor:(UIColor*)textColor fr:(CGRect)fr needBottomLine:(BOOL)needLine{
    UIButton *btn = [TSWorkReleaseViewBtn new];
    btn.backgroundColor = [UIColor whiteColor];
    btn.tag = tag;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:textColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(handleBtn:) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
//    [btn setBackgroundImage:[UIImage imageNamed:@"btn_bg_disable220"] forState:UIControlStateHighlighted];
    [btn setImage:[UIImage imageNamed:@"release_unopen"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"release_open"] forState:UIControlStateSelected];
    btn.titleLabel.textAlignment = NSTextAlignmentLeft;
    btn.frame = fr;
    [self addSubview:btn];
    
    if( needLine ){
        UIView *line = [UIView new];
        line.frame = CGRectMake(15, btn.height-0.5, btn.width-2*15, 0.5);
        line.backgroundColor = [UIColor colorWithRgb221];
        [btn addSubview:line];
    }
    return btn;
}


@end


@implementation TSWorkReleaseViewBtn
- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    CGFloat iw = 30,ih = 20;
    CGFloat iLeft = 15;
    return CGRectMake(contentRect.size.width-iw-iLeft, (contentRect.size.height-ih)/2, iw, ih);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    CGFloat iw = 200,ih = 40;
    CGFloat iLeft = 15;
    return CGRectMake(iLeft, (contentRect.size.height-ih)/2, iw, ih);
}
@end
