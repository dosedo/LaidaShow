//
//  XWSheetView.m
//  ThreeShow
//
//  Created by hitomedia on 16/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "XWSheetView.h"
//仅仅为了 适配刘海平
#import "UIView+LayoutMethods.h"
#import "UIColor+Ext.h"

static NSUInteger const gTagBase = 100;
static CGFloat    const gAnimateTimeLen = 0.3; //动画时间
@interface XWSheetView()
@property (nonatomic, strong) UIButton *bgBtn;
@property (nonatomic, copy) void (^handleIndexBlock)(NSInteger);
@property (nonatomic, copy) void (^handleCancleBlock)(void);
@end

@implementation XWSheetView

+ (XWSheetView *)shareSheetView {
    static XWSheetView *sv = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sv = [XWSheetView new];
        [sv initViews];
    });
    
    return sv;
}

+ (void)showWithTitles:(NSArray *)titles handleIndexBlock:(void (^)(NSInteger))handleIndexBlock{
    [XWSheetView shareSheetView].handleCancleBlock = nil;
    [[XWSheetView shareSheetView] showWithTitles:titles handleIndexBlock:handleIndexBlock];
}

+ (void)showWithTitles:(NSArray *)titles cancleTitle:(NSString *)cancleTitle handleIndexBlock:(void (^)(NSInteger))handleIndexBlock{
    XWSheetView *sv = [XWSheetView new];
    [sv initViews];
    
    sv.handleCancleBlock = nil;
    [sv showWithTitles:titles handleIndexBlock:handleIndexBlock];
    
    UIButton *btn = (UIButton*)
    [sv viewWithTag:XWSheetViewCancleBtnTag];
    [btn setTitle:cancleTitle forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithRgb102] forState:UIControlStateNormal];
}


+ (void)showWithTitles:(NSArray *)titles handleIndexBlock:(void (^)(NSInteger))handleIndexBlock handleCancleBlock:(void (^)(void))handleCancleBlock{
    [XWSheetView shareSheetView].handleCancleBlock = handleCancleBlock;
    [[XWSheetView shareSheetView] showWithTitles:titles handleIndexBlock:handleIndexBlock];
}

#pragma mark - TouchEvents
- (void)handleBgBtn{
    [self hide];
}

- (void)handleBtn:(UIButton*)btn{
    
    [UIView animateWithDuration:gAnimateTimeLen animations:^{
        self.center = CGPointMake(self.center.x, (SCREEN_HEIGHT+self.height/2));
    } completion:^(BOOL finished) {
        [_bgBtn removeFromSuperview];
        
        if( btn.tag != XWSheetViewCancleBtnTag ){
            
            if( self.handleIndexBlock ){
                self.handleIndexBlock(btn.tag-gTagBase);
            }
        }
        
        if( _handleCancleBlock ){
            _handleCancleBlock();
        }
    }];
}

#pragma mark - Private

- (void)hide{
    [UIView animateWithDuration:gAnimateTimeLen animations:^{
        self.center = CGPointMake(self.center.x, (SCREEN_HEIGHT+self.height/2));
    } completion:^(BOOL finished) {
        [_bgBtn removeFromSuperview];
        
        if( _handleCancleBlock ){
            _handleCancleBlock();
        }
    }];
}

- (void)showWithTitles:(NSArray*)titles handleIndexBlock:(void (^)(NSInteger))handleIndexBlock{
    self.handleIndexBlock = handleIndexBlock;
    self.titles = titles;
    
    [self createItemsWithTitles:titles];
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
    
    self.backgroundColor = [UIColor colorWithWhite:240/255.0 alpha:1];
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
//        }else{
//            color = [UIColor colorWithRgb51];
//        }
        color = [UIColor colorWithRgb51];
        [self getBtnWithTitle:titles[i] tag:i+gTagBase textColor:color fr:fr needBottomLine:YES];
    }
    
    if( titles.count ){
        //添加取消按钮
        CGFloat iy = titles.count *ih + 5;
        CGRect fr = CGRectMake(0, iy, SCREEN_WIDTH, ih);
        UIButton *cancleBtn =
        [self getBtnWithTitle:NSLocalizedString(@"WorkDetailSheetCancle", nil) tag:XWSheetViewCancleBtnTag textColor:[UIColor colorWithRgb51] fr:fr needBottomLine:NO];
        
        ih = cancleBtn.bottom + BOTTOM_NOT_SAVE_HEIGHT;
        self.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, ih);
    }
}

- (UIButton*)getBtnWithTitle:(NSString*)title tag:(NSUInteger)tag textColor:(UIColor*)textColor fr:(CGRect)fr needBottomLine:(BOOL)needLine{
    UIButton *btn = [UIButton new];
    btn.backgroundColor = [UIColor whiteColor];
    btn.tag = tag;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:textColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(handleBtn:) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_bg_disable220"] forState:UIControlStateHighlighted];
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
