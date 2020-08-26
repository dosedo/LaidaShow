//
//  TSClearBgStateView.m
//  ThreeShow
//
//  Created by hitomedia on 08/06/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSClearBgStateView.h"
#import "UIView+LayoutMethods.h"

@interface TSClearBgStateView()
@property (nonatomic, strong) UILabel *msgL;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, copy) void(^handleBlock)(void);
@end

@implementation TSClearBgStateView

+ (TSClearBgStateView*)shareClearBgStateView{
    static TSClearBgStateView* sv = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sv = [[TSClearBgStateView alloc] initWithFrame:CGRectMake(0, NAVGATION_VIEW_HEIGHT, SCREEN_WIDTH, 50)];
    });
    return sv;
}

+ (TSClearBgStateView *)showInView:(UIView *)view handleSeeBtn:(void (^)(void))handleSeeBtnBlock{
    TSClearBgStateView *sv = [TSClearBgStateView shareClearBgStateView];
    sv.isClearedBgImg = NO;
    sv.handleBlock = handleSeeBtnBlock;
    [sv removeFromSuperview];
    [view addSubview:sv];
    return sv;
}

+ (void)hide{
    TSClearBgStateView *sv = [TSClearBgStateView shareClearBgStateView];
    [sv removeFromSuperview];
}

- (void)setIsClearedBgImg:(BOOL)isClearedBgImg{
    _isClearedBgImg = isClearedBgImg;
    
    [self updateViewStateAndTextWithIsClearedImg:isClearedBgImg];
}

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if( self ){
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGSize size = self.size;
    CGFloat iw = 90,iLeft = 15,ih = [self btnHeight];
    self.rightBtn.frame = CGRectMake(size.width-iw-iLeft, (size.height-ih)/2, iw, ih);
    
    self.msgL.frame = CGRectMake(iLeft, 0, _rightBtn.x-iLeft*2, size.height);
}

#pragma mark - Private

- (void)updateViewStateAndTextWithIsClearedImg:(BOOL)isClearedImg{
    NSString *text = @"您的作品正在加速去底中";
    NSString *btnTitle = @"去看看";
    if( isClearedImg ){
        text = @"您的作品已经完成去底";
    }
    self.msgL.text = text;
    [self.rightBtn setTitle:btnTitle forState:UIControlStateNormal];
    
    self.rightBtn.hidden = !isClearedImg;
}

- (CGFloat)btnHeight{
    return 30;
}

- (void)handleRight{
    
    if( self.handleBlock ){
        self.handleBlock();
    }
    
    [[self class] hide];
}

#pragma mark - Propertys
- (UILabel *)msgL {
    if( !_msgL ){
        _msgL = [[UILabel alloc] init];
        _msgL.textColor = [UIColor whiteColor];
        _msgL.font = [UIFont systemFontOfSize:15];
        
        [self addSubview:_msgL];
    }
    return _msgL;
}

- (UIButton *)rightBtn {
    if( !_rightBtn ){
        _rightBtn = [[UIButton alloc] init];
        [_rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_rightBtn addTarget:self action:@selector(handleRight) forControlEvents:UIControlEventTouchUpInside];
        _rightBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _rightBtn.layer.masksToBounds = YES;
        _rightBtn.layer.cornerRadius = [self btnHeight]/2;
        _rightBtn.layer.borderWidth = 0.5;
        _rightBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        
        [self addSubview:_rightBtn];
    }
    return _rightBtn;
}

@end
