//
//  TSPersonCenterCell.m
//  ThreeShow
//
//  Created by hitomedia on 03/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSPersonCenterCell.h"
#import "UILabel+Ext.h"
#import "UIColor+Ext.h"
#import "UIView+LayoutMethods.h"
#import "TSPersonCenterCellModel.h"

static CGFloat const edgeDistance = 14;
static CGFloat const gap = 10;

@interface TSPersonCenterCell()

@end

@implementation TSPersonCenterCell

#pragma mark - Public

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if( self ){
        self.showLeftImg = NO;
        self.showArrow = YES;
        self.leftLabelWidth = -1;
//        self.line.hidden = NO;
    }
    return self;
}

- (CGFloat)getEdgeDistance{
    return edgeDistance;
}

- (void)setModel:(TSPersonCenterCellModel *)model{
    _model = model;
    if( _model ){
        //        self.leftL.text = model.leftText;
        [self setLeftLabelText:model.leftText noteText:model.leftNoteText];
        self.rightL.text = [self getRightStrWithText:model.rightText maxWordCount:model.maxShowRightTextWordCount];//model.rightText;
        if( _showLeftImg ){
            self.leftImgV.image = [UIImage imageNamed:model.leftImgName];
        }
        [self doLayout];
    }
}

- (void)setShowLeftImg:(BOOL)showLeftImg{
    _showLeftImg = showLeftImg;
    self.leftImgV.hidden = !showLeftImg;
}

#pragma mark - init

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat iw = 9;
    CGFloat ih = 15;
    if( !_showArrow ) iw = 0;
    self.arrowImgV.frame = CGRectMake( self.width-iw-edgeDistance, (self.height-ih)/2, iw, ih);
    CGFloat lineH = 0.5;
    self.line.frame = CGRectMake(0, self.height-lineH, self.width, lineH);
    
    [self doLayout];
}

#pragma mark - Private

- (void)setLeftLabelText:(NSString*)text noteText:(NSString*)nt{
    if( [nt isKindOfClass:[NSString class]] && [text isKindOfClass:[NSString class]] && nt.length ){
        NSString *str = [NSString stringWithFormat:@"%@ %@",text,nt];
        NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:str];
        NSRange range = [str rangeOfString:nt];
        [as addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:range];
        [as addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRgb102] range:range];
        self.leftL.attributedText = as;
    }else{
        self.leftL.text = text;
    }
}

- (NSString*)getRightStrWithText:(NSString*)text maxWordCount:(NSInteger)count{
    if( count <=0 ) return text;
    
    if( text.length > count ){
        text = [text substringToIndex:count];
        return [NSString stringWithFormat:@"%@...",text];
    }
    
    return text;
}

- (void)doLayout{
    CGFloat ih = [UILabel lableSizeWithText:@"左文本" font:self.leftL.font width:self.width].height;
    CGFloat iw = _leftLabelWidth;
    CGFloat lblMaxW = self.width;
    CGFloat leftLabelX = edgeDistance;
    
    if( _showLeftImg ){
        CGFloat ix = 4;
        CGFloat imgw = 20;//44-ix;
        CGFloat imggap = (44-ix-imgw)/2;
        ix = imggap+ix;
        self.leftImgV.frame = CGRectMake(ix, 0, imgw, self.height);
        
        leftLabelX = self.leftImgV.right+imggap;
        lblMaxW = self.width - self.leftImgV.right-imggap;
    }
    
    CGSize lblSize = [UILabel lableSizeWithText:self.leftL.text font:_leftL.font
                                          width:(lblMaxW-_arrowImgV.width-edgeDistance-leftLabelX)-gap];
    if( iw <= 0 ) iw = lblSize.width;
    
    _leftL.frame = CGRectMake(leftLabelX, (self.height-ih)/2, iw, ih);
    
    CGFloat maxW = lblMaxW-self.leftL.right-_arrowImgV.width-edgeDistance- gap*2;
    lblSize = [UILabel lableSizeWithText:self.rightL.text
                                    font:_rightL.font
                                   width:maxW];
    
    if( _leftLabelWidth <=0 ) lblSize.width = maxW;
    
    CGFloat ix = self.width-(lblSize.width+gap)-(_arrowImgV.width+edgeDistance);
    if( !_showArrow ) ix+=gap;
    _rightL.frame = CGRectMake(ix, _leftL.y, lblSize.width, ih);
}

#pragma mark - Propertys

- (UILabel *)leftL{
    if( !_leftL ){
        _leftL = [[UILabel alloc] init];
        _leftL.font = [UIFont systemFontOfSize:15.0];
        _leftL.textColor = [UIColor colorWithRgb51];
        _leftL.textAlignment = NSTextAlignmentLeft;
        
        [self addSubview:_leftL];
    }
    return _leftL;
}

- (UILabel*)rightL{
    if( !_rightL) {
        _rightL = [[UILabel alloc] init];
        _rightL.font = [UIFont systemFontOfSize:13];
        _rightL.textColor = [UIColor colorWithRgb102];
        _rightL.textAlignment = NSTextAlignmentRight;
        
        [self addSubview:_rightL];
    }
    return _rightL;
}

- (UIImageView*)arrowImgV{
    if( !_arrowImgV ){
        _arrowImgV = [[UIImageView alloc] init];
        _arrowImgV.image = [UIImage imageNamed:@"arrow_right_153"];
        
        [self addSubview:_arrowImgV];
    }
    return _arrowImgV;
}

- (UIView*)line{
    if( !_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = [UIColor colorWithRgb221];

        [self addSubview:_line];
    }
    return _line;
}

- (UIImageView *)leftImgV{
    if( !_leftImgV ){
        _leftImgV = [UIImageView new];
        _leftImgV.contentMode = UIViewContentModeScaleAspectFit;
        _leftImgV.hidden = YES;
        [self addSubview:_leftImgV];
    }
    return _leftImgV;
}

@end


