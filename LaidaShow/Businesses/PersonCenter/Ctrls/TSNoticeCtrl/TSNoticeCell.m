//
//  TSNoticeCell.m
//  ThreeShow
//
//  Created by wkun on 2019/3/10.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSNoticeCell.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+Ext.h"
#import "UILabel+Ext.h"
#import "TSNoticeModel.h"
#import "UIImageView+WebCache.h"

@interface TSNoticeCell()
@property (nonatomic, strong) UILabel *titleL;
@property (nonatomic, strong) UILabel *desL;
@property (nonatomic, strong) UILabel *timeL;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIView *line;

@end

@implementation TSNoticeCell

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    
    self.line.backgroundColor = [UIColor colorWithRgb221];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    
     self.line.backgroundColor = [UIColor colorWithRgb221];
}

- (void)setModel:(TSNoticeModel *)model{
    _model = model;
    
    self.titleL.text = model.title;
    self.desL.text = model.des;
    self.timeL.text = model.time;
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:model.imgUrl]];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat toTop = 13;
    CGFloat ih = 18;
    CGFloat ix = 15;
    CGFloat yGap = ( self.height-toTop*2 - 3*ih )/2;
    CGFloat imgWh = 45;
    self.imgView.frame = CGRectMake(self.width-imgWh-15, 15, imgWh, imgWh);
    self.titleL.frame = CGRectMake(ix, toTop, _imgView.x-ix-10, ih);
    self.desL.frame = CGRectMake(ix, _titleL.bottom+yGap, _titleL.width, ih);
    self.timeL.frame = CGRectMake(ix, _desL.bottom+yGap, _titleL.width, ih);
    
    self.line.frame = CGRectMake(0, self.height-0.5, self.width, 0.5);
}

#pragma mark - Propertys
- (UILabel *)titleL{
    if( !_titleL ){
        _titleL = [UILabel getLabelWithTextColor:[UIColor colorWithRgb51] font:[UIFont systemFontOfSize:16] textAlignment:NSTextAlignmentLeft frame:CGRectZero superView:self.contentView];
    }
    return _titleL;
}

- (UILabel *)desL{
    if( !_desL ){
        _desL = [UILabel getLabelWithTextColor:[UIColor colorWithRgb102] font:[UIFont systemFontOfSize:14] textAlignment:NSTextAlignmentLeft frame:CGRectZero superView:self.contentView];
    }
    return _desL;
}

- (UILabel *)timeL{
    if( !_timeL ){
        _timeL = [UILabel getLabelWithTextColor:[UIColor colorWithRgb153] font:[UIFont systemFontOfSize:12] textAlignment:NSTextAlignmentLeft frame:CGRectZero superView:self.contentView];
    }
    return _timeL;
}

- (UIImageView *)imgView {
    if( !_imgView ){
        _imgView = [[UIImageView alloc] init];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.backgroundColor = [UIColor colorWithRgb221];
        _imgView.clipsToBounds = YES;
        [self.contentView addSubview:_imgView];
    }
    return _imgView;
}

- (UIView *)line{
    if( !_line ){
        _line = [UIView new];
        _line.backgroundColor = [UIColor colorWithRgb221];
        [self.contentView addSubview:_line];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return _line;
}

@end
