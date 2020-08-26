//
//  DSShareSheetCell.m
//  ThreeShow
//
//  Created by wkun on 2020/1/10.
//  Copyright © 2020 deepai. All rights reserved.
//

#import "DSShareSheetCell.h"

@implementation DSShareSheetCell

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.imgView.frame = CGRectMake(0, 0, 50, 50);
}

- (UIImageView *)imgView {
    if( !_imgView ){
        _imgView = [UIImageView new];
        [self.contentView addSubview:_imgView];
    }
    return _imgView;
}

- (UILabel *)titleL {
    if( !_titleL ){
        _titleL = [UILabel new];
        _titleL.font = [UIFont systemFontOfSize:14];
        _titleL.numberOfLines = 2;
        _titleL.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_titleL];
    }
    return _titleL;
}

@end

@implementation  DSShareSheetModel

@end
