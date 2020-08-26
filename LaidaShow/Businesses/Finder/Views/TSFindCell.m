//
//  TSFindCell.m
//  ThreeShow
//
//  Created by wkun on 2019/2/23.
//  Copyright © 2019 deepai. All rights reserved.
//

#import "TSFindCell.h"
#import "TSFindModel.h"
#import "UIColor+Ext.h"
#import "UIView+LayoutMethods.h"
#import "UIImageView+WebCache.h"

@interface TSFindCell()
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *titleL;
@property (nonatomic, strong) UILabel *contentL;
@property (nonatomic, strong) UILabel *seeCountL;  //浏览数量
@property (nonatomic, strong) UIView *cellSelectedBgView;
@end

@implementation TSFindCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.imgView.backgroundColor = [UIColor colorWithRgb221];
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    
    self.imgView.backgroundColor = [UIColor colorWithRgb221];
}

- (void)setModel:(TSFindModel *)model{
    _model = model;
    
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:model.imgUrl]];
    self.titleL.text = model.title;
    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSString *cnt = model.content;
//        NSInteger wordCount = 150;
//        if( cnt.length > wordCount ){
//            cnt = [cnt substringToIndex:wordCount];
//        }
//        NSAttributedString *cas = [[NSAttributedString alloc] initWithData:[cnt dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//        NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithAttributedString:cas];
//        [as addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, cas.length)];
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.contentL.attributedText = as;
//        });
//    });
    self.contentL.text = model.content;
    self.seeCountL.text = model.count;
}

//替换掉文本中的<p>标签以及其他标签

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGSize size = self.size;
    self.imgView.frame = CGRectMake(10, 15, 140, 90);
    
    CGFloat ix = _imgView.right+10;
    self.titleL.frame = CGRectMake(ix, _imgView.y+2, size.width-ix-15, 14);
    
    self.contentL.frame = CGRectMake(_titleL.x, _titleL.bottom, _titleL.width, 51);
    self.seeCountL.frame = CGRectMake(_contentL.x, _contentL.bottom, _contentL.width, _imgView.bottom-_contentL.bottom);
    
    self.cellSelectedBgView.frame = CGRectMake(0, _imgView.y-7, size.width, _imgView.height+14);
}

#pragma mark - Propertys
- (UIImageView*)imgView{
    if( !_imgView ){
        _imgView = [UIImageView new];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.backgroundColor = [UIColor colorWithRgb221];
        _imgView.clipsToBounds = YES;
        [self.contentView addSubview:_imgView];
    }
    return _imgView;
}

- (UILabel *)titleL{
    if( !_titleL ){
        _titleL = [UILabel new];
        _titleL.textColor = [UIColor colorWithRgb51];
        _titleL.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_titleL];
    }
    return _titleL;
}

- (UILabel *)contentL{
    if( !_contentL ){
        _contentL = [UILabel new];
        _contentL.textColor = [UIColor colorWithRgb51];
        _contentL.font = [UIFont systemFontOfSize:15];
        _contentL.numberOfLines = 2;
        [self.contentView addSubview:_contentL];
    }
    return _contentL;
}

- (UILabel *)seeCountL{
    if( !_seeCountL ){
        _seeCountL = [UILabel new];
        _seeCountL.textColor = [UIColor colorWithRgb153];
        _seeCountL.font = [UIFont systemFontOfSize:11];
        [self.contentView addSubview:_seeCountL];
    }
    return _seeCountL;
}

- (UIView *)cellSelectedBgView {
    if( !_cellSelectedBgView ){
        _cellSelectedBgView = [[UIView alloc] init];
        _cellSelectedBgView.backgroundColor = [UIColor colorWithRgb238];
        self.selectedBackgroundView = _cellSelectedBgView;
    }
    return _cellSelectedBgView;
}


@end
