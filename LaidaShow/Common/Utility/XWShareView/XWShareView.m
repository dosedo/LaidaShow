//
//  XWShareView.m
//  Hitu
//
//  Created by hitomedia on 2017/1/9.
//  Copyright © 2017年 hitomedia. All rights reserved.
//

#import "XWShareView.h"
#import "UIColor+Ext.h"
#import "UILabel+Ext.h"
#import "UIView+LayoutMethods.h"

static const NSUInteger gBaseTag = 666;

@interface XWShareButton : UIButton
@end

@implementation XWShareButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    CGFloat wh = 35;
    return CGRectMake(contentRect.size.width/2-wh/2, 15, wh, wh);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    return CGRectMake(0, contentRect.size.height-15-17, contentRect.size.width, 17);
}

@end

@interface XWShareView()

@end

@implementation XWShareView{
    void(^_handleShareBtnBlock)(NSUInteger index);
    UIView *_shareBtnsBgView;
}

#pragma mark - Public
+ (void)showWithShareBtnImgNames:(NSArray *)imgNames handleShareBtnBlock:(void (^)(NSUInteger))handleShareBtnBlock{
    XWShareView *sv = [XWShareView shareView];
    sv.bgImgView.hidden = YES;
    
    [sv initSubviewsWithImgNames:imgNames];
    sv->_handleShareBtnBlock = handleShareBtnBlock;
    [sv showShareView];
}

+ (void)hide{
    [[XWShareView shareView] hideShareView];
}

#pragma mark - Private

+ (XWShareView*)shareView{
    static dispatch_once_t onceToken;
    static XWShareView *sv = nil;
    dispatch_once(&onceToken, ^{
        if( sv ==nil ){
            sv = [[XWShareView alloc] init];
        }
    });
    return sv;
}

- (id)init{
    self = [super init ];
    if( self ) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        self.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCancleBtn:)];
        [self addGestureRecognizer:gr];
    }
    return self;
}

- (void)initSubviewsWithImgNames:(NSArray*)imgNames{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    [_shareBtnsBgView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if( _shareBtnsBgView == nil ){
        _shareBtnsBgView = [UIView new];
        _shareBtnsBgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_shareBtnsBgView];
    }
    
    CGFloat shareBtnBottom = 0.0;
    NSUInteger colum = imgNames.count;
    for( NSUInteger i=0;i < imgNames.count; i++ ){
        NSString *name = imgNames[i];
        if( [name isKindOfClass:[NSString class]] ){
            NSUInteger btnTag = i+gBaseTag;
            UIButton *shareBtn = [_shareBtnsBgView viewWithTag:btnTag];
            if( shareBtn ==nil ){
                shareBtn = [XWShareButton new];
                shareBtn.tag = btnTag;
                [_shareBtnsBgView addSubview:shareBtn];
            }
            [shareBtn setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
            [shareBtn addTarget:self action:@selector(handleShareBtn:) forControlEvents:UIControlEventTouchUpInside];
            
            NSUInteger rowIndex = 0;//i/colum;
            NSUInteger columIndex = i;//i%colum;
            CGFloat edgeDistance = 10;
            CGFloat iw = (screenSize.width-2*edgeDistance)/colum;
            CGFloat ix = columIndex * iw + edgeDistance;
            CGFloat ih = 25+40+25;
            CGFloat iy = ih*rowIndex + (10);
            shareBtn.frame = CGRectMake(ix, iy, iw, ih);
            if( _shareTitles.count && i<_shareTitles.count){
                NSString *title = _shareTitles[i];
                
//                [self configShareBtnTitleWithBtn:shareBtn title:title];
//                shareBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
                [shareBtn setTitle:title forState:UIControlStateNormal];
                shareBtn.titleLabel.font  =[UIFont systemFontOfSize:14];
                [shareBtn setTitleColor:[UIColor colorWithRgb51] forState:UIControlStateNormal];
            }
            shareBtnBottom = CGRectGetMaxY(shareBtn.frame);
        }
    }
    
    if( shareBtnBottom > 0 ){
        CGFloat lineTag = 1111;
        UIView *line = [_shareBtnsBgView viewWithTag:lineTag];
        if( !line ){
            line = [UIView new];
            line.backgroundColor = [UIColor colorWithRgb221];
            [_shareBtnsBgView addSubview:line];
            line.tag = lineTag;
        }
        CGFloat lineH = 0.5;
        line.frame = CGRectMake(0, shareBtnBottom+10, screenSize.width, lineH);
        
        //添加取消按钮
        NSUInteger cancleTag = lineTag+1;
        UIButton *cancleBtn = [_shareBtnsBgView viewWithTag:cancleTag];
        if( [cancleBtn isKindOfClass:[UIButton class]] == NO ){
            cancleBtn = [UIButton new];
            [_shareBtnsBgView addSubview:cancleBtn];
            cancleBtn.tag = cancleTag;
        }
        [cancleBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
        [cancleBtn setTitleColor:[UIColor colorWithRgb51] forState:UIControlStateNormal];
        [cancleBtn setTitleColor:[UIColor colorWithRgb102] forState:UIControlStateHighlighted];
        cancleBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        cancleBtn.frame = CGRectMake(0, CGRectGetMaxY(line.frame), screenSize.width, 45);
        [cancleBtn addTarget:self action:@selector(handleCancleBtn:) forControlEvents:UIControlEventTouchUpInside];
        cancleBtn.backgroundColor = [UIColor clearColor];
        
        CGFloat ih = CGRectGetMaxY(cancleBtn.frame);
        _shareBtnsBgView.frame = CGRectMake(0, screenSize.height, screenSize.width, ih);
    }
}

//- (void)configShareBtnTitles:(NSArray*)titles{
//    for( NSUInteger i=0; i<titles.count; i++ ){
//        UIButton *btn = (UIButton*)[_shareBtnsBgView viewWithTag:i+gBaseTag];
//        if( [btn isKindOfClass:[UIButton class]] == NO ) continue;
//
//        [self configShareBtnTitleWithBtn:btn title:titles[i]];
//    }
//}

- (void)configShareBtnTitleWithBtn:(UIButton*)btn title:(NSString*)title{
    
    btn.titleLabel.font  =[UIFont systemFontOfSize:14];
    [btn setTitleColor:[UIColor colorWithRgb51] forState:UIControlStateNormal];
    
    [btn setTitle:title forState:UIControlStateNormal];
    CGSize imgSize = btn.currentImage.size;
    CGFloat btnW = CGRectGetWidth(btn.frame);
    CGFloat btnH = CGRectGetHeight(btn.frame);
    CGSize textSize = [btn.titleLabel labelSizeWithMaxWidth:btnW+1000];
    
    CGFloat ygap = 10;
    CGFloat toTop = (btnH-imgSize.height-ygap-textSize.height)/2;
    CGFloat imgToLeft = (btnW-imgSize.width)/2;
    btn.imageEdgeInsets = UIEdgeInsetsMake(toTop, imgToLeft, btnH-toTop-imgSize.height, imgToLeft-textSize.width);
    toTop = (toTop+imgSize.height+ygap);
    CGFloat toRight = (btnW-textSize.width)/2;
    btn.titleEdgeInsets = UIEdgeInsetsMake(toTop, toRight-imgSize.width, btnH-toTop-textSize.height, toRight);
}

- (void)showShareView{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:0.5 animations:^{
        CGRect fr = _shareBtnsBgView.frame;
        fr.origin.y = ([UIScreen mainScreen].bounds.size.height-fr.size.height);
        _shareBtnsBgView.frame = fr;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideShareView{
    [UIView animateWithDuration:0.5 animations:^{
        CGRect fr = _shareBtnsBgView.frame;
        fr.origin.y = ([UIScreen mainScreen].bounds.size.height);
        _shareBtnsBgView.frame = fr;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}



#pragma mark - TouchEvents

- (void)handleShareBtn:(UIButton*)btn{
    if( _handleShareBtnBlock ){
        _handleShareBtnBlock(btn.tag-gBaseTag);
    }
    [self hideShareView];
}

- (void)handleCancleBtn:(UIButton*)btn{
    [self hideShareView];
}

@end


@implementation XWShareView(ShareQRCodeImg)

+ (void)showWithShareBtnImgNames:(NSArray *)imgNames bgImg:(UIImage*)bgImg qrImg:(UIImage*)qrImg icon:(UIImage*)icon qrDes:(NSString*)qrDes handleShareBtnBlock:(void (^)(NSUInteger))handleShareBtnBlock{
    XWShareView *sv = [XWShareView shareView];
    [sv initSubviewsWithImgNames:imgNames];
    
    sv.bgImgView.hidden = NO;
    sv.bgImgView.image = bgImg;
    sv.qrView.image = qrImg;
    sv.qrMiddleIconView.image = icon;
    sv.qrDesL.text = qrDes;
    
    [sv doLayoutQRViewWithScale:1];
    
    sv->_handleShareBtnBlock = handleShareBtnBlock;
    [sv showShareView];
}

+ (void)scaleQRImgViewFrame:(CGFloat)scale{
    XWShareView *sv = [XWShareView shareView];
    if( sv.bgImgView.hidden ) return;
    
    [sv doLayoutQRViewWithScale:scale];
}

#pragma mark - private

- (void)doLayoutQRViewWithScale:(CGFloat)scale{
    CGFloat ih = 300*scale,iw = 240*scale;
    CGFloat shareViewH = 145;
    self.bgImgView.frame = CGRectMake((SCREEN_WIDTH-iw)/2, (SCREEN_HEIGHT-ih-shareViewH)*1.8/3, iw, ih);

    iw = 65*scale; ih = 27*scale;
    CGFloat ix = self.bgImgView.width-iw-15*scale;
    CGFloat iy = self.bgImgView.height-ih-10*scale;
    self.qrDesL.frame = CGRectMake(ix, iy, iw, ih);
    self.qrDesL.font = [UIFont systemFontOfSize:12*scale];
    CGFloat wh = self.qrDesL.width;
    _qrView.frame = CGRectMake(0, 0, wh, wh);
    
    self.qrBgView.frame = CGRectMake(self.qrDesL.x, self.qrDesL.y-wh, wh, wh);

    wh = 16*scale;
    self.qrMiddleIconView.frame = CGRectMake((_qrView.width-wh)/2, (_qrView.height-wh)/2, wh, wh);
    
}

#pragma mark - propretys

- (UIImageView*)bgImgView{
    if(!_bgImgView ){
        _bgImgView = [UIImageView new];
//        CGFloat ih = 300,iw = 240; //145;
//        CGFloat shareViewH = 145;
//        _bgImgView.frame = CGRectMake((SCREEN_WIDTH-iw)/2, (SCREEN_HEIGHT-ih-shareViewH)*1.8/3, iw, ih);
        _bgImgView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImgView.clipsToBounds = YES;
        [self addSubview:_bgImgView];
        
        _bgImgView.hidden = YES;
    }
    return _bgImgView;
}

- (UIView *)qrBgView{
    if( !_qrBgView ){
        _qrBgView = [UIView new];
        _qrBgView.backgroundColor = [UIColor whiteColor];
        [self.bgImgView addSubview:_qrBgView];
    }
    
    return _qrBgView;
}

- (UILabel*)qrDesL {
    if( !_qrDesL ){
        _qrDesL = [UILabel new];
        _qrDesL.adjustsFontSizeToFitWidth = YES;
        _qrDesL.backgroundColor = [UIColor clearColor];
//        CGFloat iw = 65,ih = 27;
//        _qrDesL.frame = CGRectMake(self.bgImgView.width-iw-15, self.bgImgView.height-ih-10, iw, ih);
        [self.bgImgView addSubview:_qrDesL];
        
        _qrDesL.font = [UIFont systemFontOfSize:12];
        _qrDesL.textColor = [UIColor colorWithRgb102];
        _qrDesL.textAlignment = NSTextAlignmentCenter;
        
    }
    
    return _qrDesL;
}

- (UIImageView *)qrView {
    if( !_qrView ){
        _qrView = [UIImageView new];
        [self.qrBgView addSubview:_qrView];
        
//        CGFloat wh = self.qrDesL.width;
//        _qrView.frame = CGRectMake(0, 0, wh, wh);
//
//        self.qrBgView.frame = CGRectMake(self.qrDesL.x, self.qrDesL.y-wh, wh, wh);
//
//        wh = 16;
//        self.qrMiddleIconView.frame = CGRectMake((_qrView.width-wh)/2, (_qrView.height-wh)/2, wh, wh);
        [_qrView addSubview:self.qrMiddleIconView];
    }
    
    return _qrView;
}

- (UIImageView *)qrMiddleIconView {
    if( !_qrMiddleIconView ){
        _qrMiddleIconView = [UIImageView new];
//        _qrMiddleIconView.layer.masksToBounds = YES;
//        _qrMiddleIconView.layer.cornerRadius = 8;
    }
    return _qrMiddleIconView;
}

@end
