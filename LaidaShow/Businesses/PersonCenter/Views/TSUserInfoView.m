//
//  TSUserInfoView.m
//  ThreeShow
//
//  Created by wkun on 2019/2/23.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSUserInfoView.h"
#import "UIColor+Ext.h"
#import "UIView+LayoutMethods.h"
#import "TSUserModel.h"
#import "UIImageView+WebCache.h"
#import "TSConstants.h"

@implementation TSUserInfoView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if( self ){
        
    }
    return self;
}

- (void)setModel:(TSUserModel *)model{
    _model = model;
    
    TSUserModel *um = model;
    NSString *un = NSLocalizedString(@"PersonUnloginText", nil);
    if( um.userName.length ){
        un = um.userName;
    }
    
    [self.headImgView sd_setImageWithURL:[NSURL URLWithString:um.userImgUrl] placeholderImage:[UIImage imageNamed:TSConstantDefaultHeadImgName]];
    self.nameL.text = un;
    
    NSString *sign = NSLocalizedString(@"UserInfoSignatureDefault", nil);
    if( um.signature.length ){
        sign = um.signature;
    }
    
    NSString *markText = [NSLocalizedString(@"UserInfoSignatureMark", nil) stringByAppendingString:@":"];
    self.signatureL.text = [markText stringByAppendingString:sign];
    
    BOOL isLogin = (model!=nil);
    self.signatureL.hidden = !isLogin;
    [self doLayoutWithSize:CGSizeMake(SCREEN_WIDTH, self.height) isLogin:isLogin];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
}

- (void)doLayoutWithSize:(CGSize)size isLogin:(BOOL)isLogin{
    self.headImgView.center = CGPointMake(self.headImgView.width/2+15, size.height/2);
    CGFloat ix = _headImgView.right+10;
    CGFloat ih = _headImgView.height/2;
    CGFloat iw = size.width-ix-15;
    CGFloat iy = _headImgView.y;
    if( !isLogin ) iy = _headImgView.center.y-ih/2;
    self.nameL.frame = CGRectMake(ix, iy, iw, ih);
    
    self.signatureL.frame = CGRectMake(ix, _nameL.bottom, _nameL.width, ih);
}

- (UIImageView *)headImgView {
    if( !_headImgView ){
        _headImgView = [[UIImageView alloc] init];
        _headImgView.contentMode = UIViewContentModeScaleAspectFill;
        _headImgView.backgroundColor = [UIColor whiteColor];
        CGFloat wh = 50;
        _headImgView.frame = CGRectMake(0, 0, wh, wh);
        [_headImgView cornerRadius:wh/2];
        [self addSubview:_headImgView];
        
//        _headImgView.userInteractionEnabled = YES;
//        UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleHeadImg)];
//        [_headImgView addGestureRecognizer:ges];
    }
    return _headImgView;
}

- (UILabel *)nameL {
    if( !_nameL ){
        _nameL = [[UILabel alloc] init];
        _nameL.font = [UIFont systemFontOfSize:15];
        _nameL.textColor = [UIColor colorWithRgb51];
        _nameL.numberOfLines = 1;
        [self addSubview:_nameL];
//        _nameL.userInteractionEnabled = YES;
//        UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleNameL)];
//        [_nameL addGestureRecognizer:ges];
    }
    return _nameL;
}

- (UILabel *)signatureL {
    if( !_signatureL ){
        _signatureL = [UILabel new];
        _signatureL.textColor = [UIColor colorWithRgb153];
        _signatureL.font = [UIFont systemFontOfSize:12];
        
        [self addSubview:_signatureL];
        
        
    }
    return _signatureL;
}


@end
