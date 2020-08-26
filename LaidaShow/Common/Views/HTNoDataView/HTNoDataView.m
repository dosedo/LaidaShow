//
//  HTNoDataView.m
//  Hitu
//
//  Created by hitomedia on 2016/12/8.
//  Copyright © 2016年 hitomedia. All rights reserved.
//

#import "HTNoDataView.h"
#import "UIColor+Ext.h"
#import "UIView+LayoutMethods.h"


@implementation HTNoDataView{
    UIButton *_reloadBtn;
}

#pragma mark - Public

- (void)setContentVerticalAlignment:(UIControlContentVerticalAlignment)contentVerticalAlignment{
    _contentVerticalAlignment = contentVerticalAlignment;
    
    [self doLayoutWithFr:self.frame];
}

#pragma mark - Private
- (id)initWithFrame:(CGRect)fr text:(NSString*)text action:(SEL)loadDataSel target:(UIViewController*)target{
    self = [super initWithFrame:fr];
    if( self ){
        
        _contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        
        _isAutoLayout = NO;
        UIView *noDataView = self;//[UIView new];
        noDataView.frame = fr;
        UIImageView *iv = [[UIImageView alloc] init];
        _imgView = iv;
        iv.tag = 1008;
        iv.image = [UIImage imageNamed:@"nodata_placeholder"];
        UILabel *lbl = [UILabel new];
        lbl.tag = 1009;
        lbl.text = text;
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont systemFontOfSize:15.0];
        lbl.textColor = [UIColor colorWithRgb102];
        self.textLabel = lbl;
        
        [noDataView addSubview:iv];
        [noDataView addSubview:lbl];
        
        UIButton *loadBtn = [[UIButton alloc ] init];
        _loadBtn = loadBtn;
        loadBtn.tag = 1010;
        [loadBtn setTitle:NSLocalizedString(@"ReloadInfo", nil) forState:UIControlStateNormal];//@"重新加载"
        [loadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        loadBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [loadBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_blue"] forState:UIControlStateNormal];
        [loadBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_blue_hi"] forState:UIControlStateHighlighted];

        if( loadDataSel && [target respondsToSelector:loadDataSel] ){
            [loadBtn addTarget:target action:loadDataSel forControlEvents:UIControlEventTouchUpInside];
        }
        loadBtn.layer.masksToBounds = YES;
        loadBtn.layer.cornerRadius = 5.0;
        [noDataView addSubview:loadBtn]; //去掉重新加载按钮
        _reloadBtn = loadBtn;
        _loadBtn = loadBtn;
        self.userInteractionEnabled = YES;
        
        [self doLayoutWithFr:fr];
    }
    return self;
}

- (void)setHideReloadBtn:(BOOL)hideReloadBtn{
    _hideReloadBtn = hideReloadBtn;
    _reloadBtn.hidden = hideReloadBtn;
}

- (void)setText:(NSString *)text{
    _text = text;
    UILabel *lbl = (UILabel*)[self viewWithTag:1009];
    if( [lbl isKindOfClass:[UILabel class]] ){
        lbl.text = text;
    }
}

- (void)setImgName:(NSString *)imgName{
    UIImageView *iv = (UIImageView*)[self viewWithTag:1008];
    if( [iv isKindOfClass:[UIImageView class]] == NO ) return;
    iv.image = [UIImage imageNamed:imgName];
    
    [self doLayoutWithFr:self.frame];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if( _isAutoLayout )
        [self doLayoutWithFr:self.frame];
}

- (void)doLayoutWithFr:(CGRect)fr{
    
    CGFloat yDeviation = 0; //y方向的便宜。相对于内容居中时而言的。
    if( _contentVerticalAlignment == UIControlContentVerticalAlignmentTop ){
        yDeviation = 35;
    }else if( _contentVerticalAlignment == UIControlContentVerticalAlignmentBottom ){
        yDeviation = -35;
    }else{
        yDeviation = 0;
    }
    
    UIImageView *iv = (UIImageView*)[self viewWithTag:1008];
    if( [iv isKindOfClass:[UIImageView class]] == NO ) return;
    
    UIView *lbl = [self viewWithTag:1009];
    UIView *loadBtn = [self viewWithTag:1010];
    
    CGFloat lh = 20; //label 高度
    CGFloat bh = 40;//按钮高度
    CGFloat yGap = 5;
    //按钮和label以及图片的总高度
    CGFloat th = iv.image.size.height + lh + yGap + bh + 4*yGap;
    CGFloat ix = (fr.size.width - iv.image.size.width)/2;
    CGFloat iy = (fr.size.height-th)/2 - yDeviation;
    iv.frame = CGRectMake(ix, iy, iv.image.size.width, iv.image.size.height);
    lbl.frame = CGRectMake(0, iv.bottom+yGap*2, fr.size.width, lh);
    CGFloat bw = 170;
    loadBtn.frame = CGRectMake((fr.size.width-bw)/2, lbl.bottom+4*yGap, bw, bh);
}

@end
