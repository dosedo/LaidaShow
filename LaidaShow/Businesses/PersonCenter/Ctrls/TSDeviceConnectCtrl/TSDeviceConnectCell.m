//
//  TSDeviceConnectCell.m
//  ThreeShow
//
//  Created by hitomedia on 12/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSDeviceConnectCell.h"
#import "UIColor+Ext.h"
#import "UIView+LayoutMethods.h"
#import "WBLoadingView.h"
#import <CoreBluetooth/CoreBluetooth.h>

@implementation TSDeviceConnectCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(CBPeripheral *)model{
    _model = model;
    
    self.leftL.text = model.name;
    
    self.animateView. hidden = (model.state != CBPeripheralStateConnecting);
    self.rightImgView.hidden = (model.state != CBPeripheralStateConnected);
    
    if( self.animateView.hidden == NO ) {
        [self.animateView startAnimate];
    }else{
        [self.animateView endAnimate];
    }
}

#pragma mark - Layout

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat ix = 15,ih = self.height,iw=self.width;
    self.leftL.frame = CGRectMake(ix, 0, 200, ih);
    CGSize size = CGSizeMake(16, 16);//self.rightImgView.image.size;
    self.rightImgView.frame = CGRectMake(iw-size.width-ix, (ih-size.height)/2, size.width, size.height);
    
    CGFloat wh = 30;
    self.animateView.frame = CGRectMake(iw-wh-20, (ih-wh)/2, wh+20, wh);
    
    self.line.frame = CGRectMake(0, ih-0.5, iw, 0.5);
}

#pragma mark - Propertys
- (UILabel *)leftL {
    if( !_leftL ){
        _leftL = [[UILabel alloc] init];
        _leftL.textColor = [UIColor colorWithRgb51];
        _leftL.font = [UIFont systemFontOfSize:15];
        
        [self.contentView addSubview:_leftL];
    }
    return _leftL;
}

- (UIImageView *)rightImgView {
    if( !_rightImgView ){
        _rightImgView = [[UIImageView alloc] init];
        _rightImgView.image = [UIImage imageNamed:@"at_check_s"];
        _rightImgView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.contentView addSubview:_rightImgView];
    }
    return _rightImgView;
}

- (WBLoadingView *)animateView {
    if( !_animateView ){
        _animateView=[[WBLoadingView alloc]initWithFrame:CGRectZero];
        _animateView.lineWidth = 2;
        _animateView.lineColor=[UIColor colorWithRgb_0_151_216];
        _animateView.backgroundColor=[UIColor whiteColor];
        
        [self.contentView addSubview:_animateView];
    }
    return _animateView;
}

- (UIView*)line{
    if( !_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = [UIColor colorWithRgb221];
        
        [self addSubview:_line];
    }
    return _line;
}

@end
