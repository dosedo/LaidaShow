//
//  TSProductCell.m
//  ThreeShow
//
//  Created by hitomedia on 07/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSProductCell.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+Ext.h"
#import "TSProductModel.h"
#import "UIImageView+WebCache.h"
#import "UILabel+Ext.h"


@interface TSPraiseBtn : UIButton

@end

@interface TSProductCell()
@property (nonatomic, strong) UIImageView *userHeadImgView;
@property (nonatomic, strong) UILabel     *productNameL;
@property (nonatomic, strong) UILabel     *userNameL;
@property (nonatomic, strong) UIView      *bgView;
@end

@implementation TSProductCell

- (void)setModel:(TSProductModel *)model{
    _model = model;
    
//    model.praiseCount = @"9999";
    
    if( model.productImgUrl && [model.productImgUrl containsString:@"http"]){
        
//        model.productImgUrl = @"https://img02.sogoucdn.com/app/a/100520076/42afade95d11880e7d51eca8067baaa8";
        //压缩下图片
//        model.productImgUrl = [model.productImgUrl stringByAppendingString:@"?x-oss-process=image/resize,w_720"];
        [self.productImgView sd_setImageWithURL:[NSURL URLWithString:model.productImgUrl]];
    }else{
        NSData *imageData = [NSData dataWithContentsOfFile:model.productImgUrl];
        UIImage * backImage = [UIImage imageWithData:imageData];
        self.productImgView.image = backImage;
    }
    [self.userHeadImgView sd_setImageWithURL:[NSURL URLWithString:model.userImgUrl] placeholderImage:[UIImage imageNamed:@"home_head"]];
    self.productNameL.text = model.productName;
    self.userNameL.text = model.userName;
    [self.praiseBtn setTitle:model.praiseCount forState:UIControlStateNormal];
    self.praiseBtn.selected = model.isPraised;

    [self setNeedsLayout];
}

#pragma mark - Layout
- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGSize size = self.size;
    self.bgView.frame = CGRectMake(0, 0, size.width, size.height);
    
    CGFloat iBottom = 10,iLeft = 10,imgWh = 20;
    CGFloat iy = _bgView.height-iBottom-imgWh;
    self.userHeadImgView.frame = CGRectMake(iLeft, iy, imgWh, imgWh);
    
    CGFloat iw = 45;
    
    iw = [_praiseBtn.titleLabel labelSizeWithMaxWidth:80].width;
    if( iw < 3 ){
        iw = 45;
    }else{
        iw = 27+iw;
    }
    
    CGFloat ix = size.width-iw-iLeft;
    iy = _userHeadImgView.y - iBottom;
    CGFloat ih = size.height-iy;
    self.praiseBtn.frame = CGRectMake(ix, iy, iw, ih);
    
    ix = _userHeadImgView.right+5;
    iw = _praiseBtn.x - ix;
    self.userNameL.frame = CGRectMake(ix, _userHeadImgView.y, iw, _userHeadImgView.height);
    
    ih = 18;iy = _userHeadImgView.y-iBottom-ih;
    self.productNameL.frame = CGRectMake(iLeft, iy, size.width-2*iLeft, ih);
    self.productImgView.frame = CGRectMake(0, 0, _bgView.width, self.productNameL.y-9);
}

#pragma mark - TouchEvents
- (void)handlePraiseBtn:(UIButton*)btn{
//    btn.selected = !btn.isSelected;
    
    if( _delegate && [_delegate respondsToSelector:@selector(productCell:handlePraiseBtn:)] ){
        [_delegate productCell:self handlePraiseBtn:_praiseBtn];
    }
}

-(void)selectHeaderImage:(UIImageView*)imageview{
    NSLog(@"点击了头像");
    if (_delegate && [_delegate respondsToSelector:@selector(productCell:handleHeadImgView:)]) {
        [_delegate productCell:self handleHeadImgView:_userHeadImgView];
    }
}

#pragma mark - Propertys
- (UIView *)bgView {
    if( !_bgView ){
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor whiteColor];
        [_bgView cornerRadius:3];
        [self.contentView addSubview:_bgView];
    }
    return _bgView;
}

- (UIImageView *)productImgView {
    if( !_productImgView ){
        _productImgView = [[UIImageView alloc] init];
        _productImgView.backgroundColor = [UIColor colorWithRgb221];
        _productImgView.contentMode = UIViewContentModeScaleAspectFill;
        _productImgView.clipsToBounds = YES;
        [self.bgView addSubview:_productImgView];
    }
    return _productImgView;
}

- (UIImageView *)userHeadImgView {
    if( !_userHeadImgView ){
        _userHeadImgView = [[UIImageView alloc] init];
        _userHeadImgView.contentMode = UIViewContentModeScaleAspectFill;
        [_userHeadImgView cornerRadius:10];
        _userHeadImgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectHeaderImage:)];
        [_userHeadImgView addGestureRecognizer:tap];
        [self.bgView addSubview:_userHeadImgView];
    }
    return _userHeadImgView;
}

- (UILabel *)productNameL {
    if( !_productNameL ){
        _productNameL = [[UILabel alloc] init];
        _productNameL.textColor = [UIColor colorWithRgb51];
        _productNameL.font = [UIFont systemFontOfSize:14];
        _productNameL.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.bgView addSubview:_productNameL];
    }
    return _productNameL;
}

- (UILabel *)userNameL {
    if( !_userNameL ){
        _userNameL = [[UILabel alloc] init];
        _userNameL.textColor = [UIColor colorWithRgb102];
        _userNameL.font = [UIFont systemFontOfSize:12];
        
        [self.bgView addSubview:_userNameL];
    }
    return _userNameL;
}

- (UIButton *)praiseBtn {
    if( !_praiseBtn ){
        _praiseBtn = [[TSPraiseBtn alloc] init];
        [_praiseBtn setTitleColor:[UIColor colorWithRgb102] forState:UIControlStateNormal];
        _praiseBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_praiseBtn setImage:[UIImage imageNamed:@"all_praise_n"] forState:UIControlStateNormal];
        [_praiseBtn setImage:[UIImage imageNamed:@"all_praise_s"] forState:UIControlStateSelected];
        [_praiseBtn addTarget:self action:@selector(handlePraiseBtn:) forControlEvents:UIControlEventTouchUpInside];
        _praiseBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [self.bgView addSubview:_praiseBtn];
    }
    return _praiseBtn;
}

@end

#pragma mark - 本地作品的cell
@implementation TSProductCell(LocalWork)
- (id)initLocalWorkCell{
    self = [super init];
    if( self ){
        self.praiseBtn = [UIButton new];
        [self.praiseBtn setImage:[UIImage imageNamed:@"work_del"] forState:UIControlStateNormal];
        [self.praiseBtn addTarget:self action:@selector(handlePraiseBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:self.praiseBtn];
    }
    return self;
}

@end


@implementation TSPraiseBtn

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    CGFloat iw = 15, ih = 13;
    return CGRectMake(6, contentRect.size.height/2-ih/2, iw, ih);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    
    CGFloat imgRight = 21+5;
    return CGRectMake(imgRight, 0, contentRect.size.width-imgRight, contentRect.size.height);
}

@end
