//
//  TSAlertView.m
//  ThreeShow
//
//  Created by hitomedia on 18/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSAlertView.h"
#import "UIColor+Ext.h"
#import "UIView+LayoutMethods.h"
#import "UILabel+Ext.h"

static CGFloat    const gAnimateTimeLen = 0.3; //动画时间
@interface TSAlertView()
@property (nonatomic, strong) UIButton *bgBtn;
@property (nonatomic, strong) UIButton *cancleBtn;
@property (nonatomic, strong) UIButton *sureBtn;
@property (nonatomic, strong) UILabel  *titleL;
@property (nonatomic, strong) UILabel  *desL;


@property (nonatomic, strong) NSString *desStr;
@property (nonatomic, assign) BOOL needCancleBlock;

@property (nonatomic, copy) void(^handleBlock)(NSInteger);
@end

@implementation TSAlertView{
    BOOL _needLayout;
}

#pragma mark - Public

//+ (TSAlertView*)shareAlertView{
//    static TSAlertView *av = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        av = [TSAlertView new];
//    });
//
//    return av;
//}

+ (void)showAlertWithTitle:(NSString *)title des:(NSString *)des cancleTitle:(NSString *)cti sureTitle:(NSString *)sti needCancleBlock:(BOOL)needCancleBlock handleBlock:(void (^)(NSInteger))handleBlock{
    
    TSAlertView *av = [[TSAlertView alloc] initWithFrame:CGRectZero des:des];
    av.desStr = des;
    av.desL.hidden = NO;
    av.needCancleBlock = needCancleBlock;
    [av setNeedsLayout];
    [av showAlertWithTitle:title des:des handleBlock:handleBlock];
    if( sti.length )
        [av.sureBtn setTitle:sti forState:UIControlStateNormal];
    if( cti ){
        [av.cancleBtn setTitle:cti forState:UIControlStateNormal];
    }
}

+ (void)showAlertWithTitle:(NSString *)title des:(NSString *)des handleBlock:(void (^)(NSInteger))handleBlock{
    
    TSAlertView *av = [[TSAlertView alloc] initWithFrame:CGRectZero des:des];
//    CGRect fr = av.titleL.frame;
//    fr.size.height = av.desL.y-av.titleL.y;
//    av.titleL.frame = fr;
    av.desL.hidden = NO;
    [av setNeedsLayout];
    [av showAlertWithTitle:title des:des handleBlock:handleBlock];
}

+ (void)showAlertWithTitle:(NSString *)title handleBlock:(void (^)(NSInteger))handleBlock{
    
    TSAlertView *av = [TSAlertView new];
    av.desL.hidden = YES;
    [av setNeedsLayout];
    [av showAlertWithTitle:title des:nil handleBlock:handleBlock];
}

+ (void)showAlertWithTitle:(NSString *)title{
    TSAlertView *av = [TSAlertView new];
    av.desL.hidden = YES;
    av.cancleBtn.hidden = YES;
    
    CGFloat iw = 424/2, ih = 272/2;
    av.frame = CGRectMake(av.center.x-iw/2, av.center.y-ih/2, iw, ih);
    CGFloat ix = 15;
    CGFloat maxW = av.width - 2*15;
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:title];
    [as addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, title.length)];
    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
    ps.lineSpacing = 5;
    ps.alignment = NSTextAlignmentCenter;
    [as addAttribute:NSParagraphStyleAttributeName value:ps range:NSMakeRange(0, title.length)];
    [as addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRgb51] range:NSMakeRange(0, title.length)];
    av.titleL.numberOfLines = 0;
    
    
    ih = [UILabel lableSizeWithAttrText:as width:maxW].height;
    CGFloat btnH = 30,btnW = 70;
    
    CGFloat ygap = (av.height-btnH-ih)/3;
    av.titleL.frame = CGRectMake(ix, ygap, maxW, ih);
    
    [av.sureBtn setTitle:NSLocalizedString(@"知道了", nil) forState:UIControlStateNormal];
    [av.sureBtn setTitleColor:[UIColor colorWithRgb51] forState:UIControlStateNormal];
    
    av.sureBtn.frame = CGRectMake(av.width/2-btnW/2, av.titleL.bottom+ygap, btnW, btnH);
    av.sureBtn.layer.masksToBounds = YES;
    av.sureBtn.layer.borderWidth = 0.5;
    av.sureBtn.layer.borderColor = [UIColor colorWithRgb102].CGColor;
    av.sureBtn.layer.cornerRadius = 5;
    av.layer.masksToBounds = YES;
    av.layer.cornerRadius = 6;
    
    av->_needLayout = NO;
    
    [av showAlertWithTitle:nil des:nil handleBlock:nil];
    av.titleL.attributedText = as;
}

#pragma mark - Private
- (void)showAlertWithTitle:(NSString *)title des:(NSString *)des handleBlock:(void (^)(NSInteger))handleBlock{
    self.handleBlock = handleBlock;
    self.titleL.text = title;
    self.desL.text = des;

    UIView *sv = [UIApplication sharedApplication].keyWindow;
    [sv addSubview:self.bgBtn];

    [UIView animateWithDuration:gAnimateTimeLen animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

- (void)hide{
    [UIView animateWithDuration:gAnimateTimeLen animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self.bgBtn removeFromSuperview];
    }];
}

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame{
    return [self initWithFrame:frame des:nil];
}

- (id)initWithFrame:(CGRect)frame des:(NSString*)des{
    self = [super initWithFrame:frame];
    if( self ){
        _needLayout = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.bgBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        
        self.desStr = des;
        
        CGFloat iw = 231,ih = 160;
        CGFloat desH = [self calculateDesHeightWithMaxW:231-20]-44;
        ih += desH;
        self.frame = CGRectMake((SCREEN_WIDTH-iw)/2, (SCREEN_HEIGHT-ih)/2, iw, ih);
        self.alpha = 0;
        
        [self cornerRadius:3];
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor colorWithRgb153].CGColor;
    }
    return self;
}

- (CGFloat)calculateDesHeightWithMaxW:(CGFloat)maxW{
    CGFloat ih = [UILabel lableSizeWithText:self.desStr font:self.desL.font width:maxW].height+30;//44;
    if( ih < 44 ) ih = 44;
    
    return  ih;;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if( _needLayout ==NO ) return;
    
    CGFloat ix = 10;
    CGSize size = self.size;
    CGFloat ih = 20;
    CGFloat iy = 15;
    if( self.desL.isHidden ){
        ih = 64;
        iy = 0;
    }
    self.titleL.frame = CGRectMake(ix, iy, size.width-ix*2, ih);
    
    ih = [self calculateDesHeightWithMaxW:size.width-2*ix];
    if( self.desL.isHidden ){
        ih = 0;
    }
    self.desL.frame = CGRectMake(ix, _titleL.bottom, size.width-2*ix, ih);
    ih = (size.height-_desL.bottom)/2;
    self.cancleBtn.frame = CGRectMake(0, _desL.bottom, size.width, ih);
    self.sureBtn.frame = CGRectMake(0, _cancleBtn.bottom, size.width, ih);
    
    [self.cancleBtn viewWithTag:11].frame =
    CGRectMake(ix, 0, _cancleBtn.width-2*ix, 0.5);
    [self.sureBtn viewWithTag:11].frame =
    CGRectMake(ix, 0, _sureBtn.width-2*ix, 0.5);
}

#pragma mark - TouchEvents

- (void)handleSelf{
//    [self hide];
}

- (void)handleSure{
    [self hide];
    if( self.handleBlock) {
        self.handleBlock(0);
    }
}

- (void)handleCancle{
    
    [self hide];
    
    if( _needCancleBlock ){
        if( self.handleBlock) {
            self.handleBlock(1);
        }
    }
}

#pragma mark - Propertys

- (UIButton *)bgBtn {
    if( !_bgBtn ){
        _bgBtn = [[UIButton alloc] init];
        _bgBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
//        _bgBtn.userInteractionEnabled = NO;
        [_bgBtn addTarget:self action:@selector(handleSelf) forControlEvents:UIControlEventTouchUpInside];
        [_bgBtn addSubview:self];
    }
    return _bgBtn;
}

- (UILabel *)titleL {
    if( !_titleL ){
        _titleL = [[UILabel alloc] init];
        _titleL.textAlignment = NSTextAlignmentCenter;
        _titleL.font = [UIFont systemFontOfSize:16];
        _titleL.textColor = [UIColor colorWithRgb51];
        
        [self addSubview:_titleL];
    }
    return _titleL;
}

- (UILabel *)desL {
    if( !_desL ){
        _desL = [[UILabel alloc] init];
        _desL.textAlignment = NSTextAlignmentCenter;
        _desL.font = [UIFont systemFontOfSize:14];
        _desL.textColor =[UIColor colorWithRgb102];
        _desL.numberOfLines = 0;
        [self addSubview:_desL];
    }
    return _desL;
}

- (UIButton *)sureBtn {
    if( !_sureBtn ){
        _sureBtn = [[UIButton alloc] init];
        _sureBtn.backgroundColor = [UIColor whiteColor];
        [_sureBtn setTitle:NSLocalizedString(@"WorkEditBottomMusicConfirmText", @"确认") forState:UIControlStateNormal];
        [_sureBtn setTitleColor:[UIColor colorWithRgb_250_100_92] forState:UIControlStateNormal];
        _sureBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_sureBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_disable220"] forState:UIControlStateHighlighted];
        [_sureBtn addTarget:self action:@selector(handleSure) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_sureBtn];
        
        UIView *topLine = [UIView new];
        topLine.tag = 11;
        topLine.backgroundColor = [UIColor colorWithRgb221];
        [_sureBtn addSubview:topLine];
    }
    return _sureBtn;
}

- (UIButton *)cancleBtn{
    if( !_cancleBtn ){
        _cancleBtn = [[UIButton alloc] init];
        
        [_cancleBtn setTitle:NSLocalizedString(@"WorkDetailSheetCancle", @"取消") forState:UIControlStateNormal];
        [_cancleBtn setTitleColor:[UIColor colorWithRgb51] forState:UIControlStateNormal];
        _cancleBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_cancleBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_disable220"] forState:UIControlStateHighlighted];
        [_cancleBtn addTarget:self action:@selector(handleCancle) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_cancleBtn];
        
        UIView *topLine = [UIView new];
        topLine.tag = 11;
        topLine.backgroundColor = [UIColor colorWithRgb221];
        [_cancleBtn addSubview:topLine];
    }
    return _cancleBtn;
}

@end
