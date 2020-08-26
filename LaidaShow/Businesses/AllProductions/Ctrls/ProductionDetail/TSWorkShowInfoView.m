//
//  TSWorkShowInfoView.m
//  ThreeShow
//
//  Created by cgw on 2019/2/20.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSWorkShowInfoView.h"
#import "UIView+LayoutMethods.h"
#import "UILabel+Ext.h"
#import "UIColor+Ext.h"
#import "TSProductionDetailModel.h"
#import "UIImageView+WebCache.h"

static NSInteger const gTagBase = 100;
static CGFloat   const gAnimateTimeLen = 0.3; //动画时间
@interface TSWorkShowInfoView()
@property (nonatomic, strong) UIButton *bgBtn;
@property (nonatomic, strong) UIImageView *headImgView;
@property (nonatomic, strong) UILabel *userNameL;
@property (nonatomic, strong) UILabel *timeL;
@end

@implementation TSWorkShowInfoView{
    CGFloat _viewWidth;
}

- (TSWorkShowInfoView*)initWorkShowInfoView{

    self = [super init];
    if( self ){
        
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [self cornerRadius:5];
        
//        NSArray *titles = @[@"名称:",@"类别:",@"销量:",@"价格:",@"描述:"];
        
        NSArray *titles = @[NSLocalizedString(@"WorkDetailWorkName", nil),
                            NSLocalizedString(@"WorkDetailCategory", nil),
                            NSLocalizedString(@"WorkDetailPriceText", nil),
                            NSLocalizedString(@"WorkDetailMonthSaleCount", nil),
                            NSLocalizedString(@"WorkDetailWorkDes", nil)];
        CGFloat ih = 44;
        CGFloat iy = 0;
        CGFloat iw = 50;
        
        NSString *des = [titles lastObject];
        if( [des containsString:@"Des"] ){
            //是英文，则加大宽度
            iw = 100;
            _viewWidth = 280;
        }else{
            _viewWidth = 230;
        }
        
        ih = [UILabel lableSizeWithText:des font:[UIFont systemFontOfSize:15] width:100].height;
        CGFloat yGap = (44 - ih)/2;
        for( NSUInteger i=0; i<titles.count; i++ ){
            iy = (ih+yGap)*i + (self.headImgView.bottom+2)+yGap;
            CGRect fr = CGRectMake(0, iy, iw, ih);
            UILabel *titleL =
            [UILabel getLabelWithTextColor:[UIColor whiteColor]
                                      font:[UIFont systemFontOfSize:15]
                             textAlignment:NSTextAlignmentRight
                                     frame:fr
                                 superView:self];
            titleL.text = [NSString stringWithFormat:@"%@:",titles[i]];
            
            fr.origin.x = titleL.right+3;
            fr.size.width = _viewWidth-fr.origin.x-15;
            
            if( i==titles.count-1 ){
                UITextView *desTextView = [UITextView new];
                desTextView.textColor = [UIColor whiteColor];
                desTextView.font = [UIFont systemFontOfSize:15];
                desTextView.frame = fr;
                desTextView.scrollEnabled = YES;
                desTextView.tag = i + gTagBase;
                desTextView.backgroundColor = [UIColor clearColor];
                desTextView.showsHorizontalScrollIndicator = NO;
                desTextView.textContainerInset = UIEdgeInsetsZero;
                
                [self addSubview:desTextView];
            }else{
                UILabel *textL =
                [UILabel getLabelWithTextColor:[UIColor whiteColor]
                                          font:[UIFont systemFontOfSize:15]
                                 textAlignment:NSTextAlignmentLeft
                                         frame:fr
                                     superView:self];
                textL.tag = i+gTagBase;
            }
            
//            if( i==titles.count-1 ){
//                textL.numberOfLines = 0;
//            }
        }
    }
    return self;
}

- (void)setModel:(TSProductionDetailModel *)model{
    _model = model;
    
    self.userNameL.text = model.userName;
    [self.headImgView sd_setImageWithURL:[NSURL URLWithString:model.headImgUrl] placeholderImage:[UIImage imageNamed:@"home_head"]];
    self.timeL.text = model.createTime;
    
    [self getLabelAtIndex:0].text = model.productName;
    [self getLabelAtIndex:1].text = model.productCategory;
    [self getLabelAtIndex:2].text = model.price;
    [self getLabelAtIndex:3].text = model.saleCount;
    [self getLabelAtIndex:4].text = model.productDes;
    
    [self doLayout];
}

- (void)doLayout{
    UILabel *desL = [self getLabelAtIndex:4];
    
    CGFloat maxH = 72;
    CGSize size = [UILabel lableSizeWithText:desL.text font:desL.font width:desL.width];//[desL labelSizeWithMaxWidth:desL.width];
    if( size.height > maxH ){
        size.height = maxH;
    }
    desL.frame = CGRectMake(desL.x, desL.y, desL.width, size.height);
    
    CGFloat ih = desL.bottom+30;
//    CGFloat maxH = SCREEN_HEIGHT-128;
//    if( ih >  maxH ) ih = maxH;
    CGFloat iw = _viewWidth;
    
    self.frame = CGRectMake((SCREEN_WIDTH-iw)/2, (SCREEN_HEIGHT-ih)/2, iw, ih);
}

#pragma mark - Private

- (UILabel*)getLabelAtIndex:(NSInteger)index{
    NSInteger tag = index+gTagBase;
    UILabel *lbl = [self viewWithTag:tag];
    if( [lbl isKindOfClass:[UILabel class]] ){
        return lbl;
    }
    
    if( [lbl isKindOfClass:[UITextView class]] ){
        return lbl;
    }
    
    return nil;
}

- (void)show{
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

#pragma mark - ToucheEvents
- (void)handleSelf{
    if( self.handleHideBlock ){
        self.handleHideBlock();
    }
    [self hide];
}

#pragma mark - Propertys
- (UIButton *)bgBtn {
    if( !_bgBtn ){
        _bgBtn = [[UIButton alloc] init];
        _bgBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        _bgBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [_bgBtn addTarget:self action:@selector(handleSelf) forControlEvents:UIControlEventTouchUpInside];
        [_bgBtn addSubview:self];
    }
    return _bgBtn;
}

- (UIImageView *)headImgView {
    if( !_headImgView ){
        _headImgView = [[UIImageView alloc] init];
        _headImgView.contentMode = UIViewContentModeScaleAspectFill;
        _headImgView.frame = CGRectMake(15, 15, 30, 30);
        [_headImgView cornerRadius:_headImgView.height/2];
        [self addSubview:_headImgView];
    }
    return _headImgView;
}

- (UILabel *)userNameL {
    if( !_userNameL ){
        _userNameL = [[UILabel alloc] init];
        _userNameL.textColor = [UIColor whiteColor];
        _userNameL.font = [UIFont systemFontOfSize:15];
        CGFloat ix = self.headImgView.right+5;
        CGFloat iw = _viewWidth-ix-10;
        _userNameL.frame = CGRectMake(ix, _headImgView.y, iw, 16);
        
        [self addSubview:_userNameL];
    }
    return _userNameL;
}

- (UILabel *)timeL {
    if( !_timeL ){
        _timeL = [[UILabel alloc] init];
        _timeL.textColor = [UIColor whiteColor];
        _timeL.font = [UIFont systemFontOfSize:12];
        _timeL.frame = CGRectMake(self.userNameL.x, self.headImgView.bottom-13, self.userNameL.width, 13);
        [self addSubview:_timeL];
    }
    return _timeL;
}

@end
